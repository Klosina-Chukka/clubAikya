const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const cloudinary = require('cloudinary').v2;
const axios = require('axios');
const cron = require('node-cron');
const app = express();
const port = 3000;
const JWT_SECRET = 'super_secret_key_123';

app.use(cors());
app.use(express.json());

// 🌩️ Cloudinary Config
cloudinary.config({
  cloud_name: 'dbdlaoews',
  api_key: '934196156288849',
  api_secret: 'B_8UWhShgif6QQTzMx501A1af8Y'
});

// 🗃️ Multer
const upload = multer({ dest: 'uploads/' });

// 📞 Twilio
const accountSid = 'ACf017e34c36c3d3888a81351a91792996';
const authToken = '784178795821b423500dae787c176a1b';
const client = require('twilio')(accountSid, authToken);

// 📲 OneSignal
async function sendNotification(title, message) {
  const headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': `Basic os_v2_app_yb2xt4j3kvakdb7tmqqbtutfzeqi4fy3p62e6sfts6yzbacx6rxa3znflhjrku5pn5c3rvsizcyqgooe4sqi3zo7k5nocnam6e6fx6a`
  };

  const body = {
    app_id: 'c07579f1-3b55-40a1-87f3-642019d265c9',
    included_segments: ['All'],
    headings: { en: title },
    contents: { en: message }
  };

  try {
    const response = await axios.post('https://onesignal.com/api/v1/notifications', body, { headers });
    console.log('📩 Notification sent:', response.data);
  } catch (error) {
    console.error('❌ Notification error:', error.response?.data || error.message);
  }
}

// ⏱ MongoDB Connect
mongoose.connect('mongodb+srv://27ranjali:clubaikya@cluster0.nd2ipt3.mongodb.net/ClubAIKYA?retryWrites=true&w=majority&appName=Cluster0')
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => {
    console.error('❌ MongoDB error:', err.message);
    process.exit(1);
  });

// 🔧 Schemas
const userSchema = new mongoose.Schema({
  phone: String, name: String, rollNo: String,
  course: String, branch: String, dob: Date,
  validity: String, role: { type: String, enum: ['Student', 'Admin'], default: 'Student' },
  adminCode: String
});
const User = mongoose.model('User', userSchema);

const associatedLinkSchema = new mongoose.Schema({ label: String, url: String });

const eventSchema = new mongoose.Schema({
  clubName: String, title: String, description: String,
  location: String, mode: { type: String, enum: ['Offline', 'Online'], default: 'Offline' },
  date: Date, time: String, registrationDeadline: Date,
  customFieldLabel: String, customFieldValue: String,
  associatedLinks: [associatedLinkSchema],
  imageUrl: String
}, { timestamps: true });
const Event = mongoose.model('Event', eventSchema);

const announcementSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  eventName: { type: String, required: true },
  club: { type: String, required: true },
  date: { type: Date, default: Date.now }
});
const Announcement = mongoose.model('Announcement', announcementSchema);

// 🔒 Auth Middleware
const authenticateToken = async (req, res, next) => {
  const token = (req.headers['authorization'] || '').split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: 'Token missing' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await User.findById(decoded.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    req.user = user;
    next();
  } catch (err) {
    return res.status(403).json({ success: false, message: 'Invalid or expired token' });
  }
};

// 🔐 OTP
const otpStore = {};
app.post('/send-otp', async (req, res) => {
  const { phone } = req.body;
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  otpStore[phone] = otp;
  try {
    await client.messages.create({
      body: `Your otp is ${otp}`,
      from: '+1 816 451 5164',
      to: phone
    });
    res.send({ success: true, message: 'OTP sent' });
  } catch (err) {
    res.status(500).send({ success: false, message: err.message });
  }
});

app.post('/verify-otp', async (req, res) => {
  const { phone, otp } = req.body;
  if (otpStore[phone] === otp) {
    delete otpStore[phone];
    let user = await User.findOne({ phone });
    if (!user) user = await User.create({ phone });
    const token = jwt.sign({ id: user._id, phone: user.phone, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.send({ success: true, message: 'OTP verified', token, user });
  } else {
    res.status(400).send({ success: false, message: 'Invalid OTP' });
  }
});

// 📥 Create Event
app.post("/api/events", authenticateToken, upload.single('image'), async (req, res) => {
  try {
    const {
      clubName, title, description, location, mode,
      date, time, registrationDeadline,
      customFieldLabel, customFieldValue, associatedLinks
    } = req.body;

    if (!req.file) return res.status(400).json({ success: false, message: "Image file is required" });

    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: 'events',
      public_id: `${uuidv4()}_${req.file.originalname}`
    });

    fs.unlinkSync(req.file.path);

    const newEvent = new Event({
      clubName, title, description, location, mode,
      date: new Date(date), time, registrationDeadline: new Date(registrationDeadline),
      customFieldLabel, customFieldValue,
      associatedLinks: JSON.parse(associatedLinks || '[]'),
      imageUrl: result.secure_url
    });

    await newEvent.save();
    await sendNotification(`📢 New Event: ${title}`, `${clubName} is hosting ${title} on ${date} at ${time}`);
    res.status(201).json({ success: true, event: newEvent });
  } catch (err) {
    if (req.file) fs.unlinkSync(req.file.path);
    res.status(500).json({ success: false, error: err.message });
  }
});

// 👤 Create or Update User
app.post("/api/users", async (req, res) => {
  try {
    const newUser = new User(req.body);
    await newUser.save();
    const token = jwt.sign({ id: newUser._id, phone: newUser.phone, role: newUser.role }, JWT_SECRET, { expiresIn: '7d' });
    res.status(201).json({ message: "User saved", token, user: newUser });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/users/:phone', authenticateToken, async (req, res) => {
  try {
    const update = {
      name: req.body.name,
      rollNo: req.body.rollNo,
      course: req.body.course,
      branch: req.body.branch,
      dob: req.body.dob ? new Date(req.body.dob) : undefined,
      validity: req.body.validity,
      role: req.body.role
    };
    Object.keys(update).forEach(key => update[key] === undefined && delete update[key]);

    const user = await User.findOneAndUpdate(
      { phone: req.params.phone },
      update,
      { new: true }
    );

    if (user) {
      res.status(200).json({ success: true, user });
    } else {
      res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
});

// 🔍 Today's Events
app.get("/api/events/today", async (req, res) => {
  try {
    const now = new Date();
    const istOffset = 5.5 * 60 * 60 * 1000;
    const istNow = new Date(now.getTime() + istOffset);
    const startIST = new Date(istNow.setHours(0, 0, 0, 0));
    const endIST = new Date(istNow.setHours(24, 0, 0, 0));
    const utcStart = new Date(startIST.getTime() - istOffset);
    const utcEnd = new Date(endIST.getTime() - istOffset);

    const events = await Event.find({ date: { $gte: utcStart, $lt: utcEnd } });
    res.status(200).json(events);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch today's events" });
  }
});

// 📢 Announcements
app.post('/api/announcements/create', async (req, res) => {
  try {
    const { title, description, eventName, club } = req.body;
    if (!title || !eventName || !club) {
      return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    const announcement = new Announcement({ title, description, eventName, club });
    await announcement.save();
    res.status(201).json({ success: true, announcement });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Error creating announcement', error: err.message });
  }
});

app.get('/api/announcements/all', async (req, res) => {
  try {
    const announcements = await Announcement.find().sort({ date: -1 });
    const enriched = await Promise.all(announcements.map(async (a) => {
      const event = await Event.findOne({ title: a.eventName });
      if (!event) {
        return {
          title: a.title,
          description: a.description,
          eventName: a.eventName,
          date: a.date
        };
      }

      return {
        title: a.title,
        description: a.description,
        eventName: a.eventName,
        eventDescription: event.description,
        eventLocation: event.location,
        eventMode: event.mode,
        eventDate: event.date,
        eventTime: event.time,
        eventDeadline: event.registrationDeadline,
        eventImageUrl: event.imageUrl,
        eventLinks: event.associatedLinks,
        date: a.date
      };
    }));
    res.status(200).json({ success: true, announcements: enriched });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Error fetching announcements', error: err.message });
  }
});

// 🧑 Profile
app.get('/profile', authenticateToken, (req, res) => {
  res.json({ success: true, user: req.user });
});

// 📅 Events by Club
app.get('/api/clubs/:clubName/events', async (req, res) => {
  const events = await Event.find({ clubName: req.params.clubName });
  res.json({ success: true, events });
});

// 🧪 Health Check
app.get('/ping-db', async (req, res) => {
  try {
    const ping = await mongoose.connection.db.admin().ping();
    res.send({ success: true, message: "MongoDB is reachable", ping });
  } catch (err) {
    res.status(500).send({ success: false, message: "MongoDB not reachable", error: err.message });
  }
});

// ⏰ Daily CRON Job at 9 AM
cron.schedule('0 9 * * *', async () => {
  const now = new Date();
  const istOffset = 5.5 * 60 * 60 * 1000;
  const istNow = new Date(now.getTime() + istOffset);
  const startIST = new Date(istNow.setHours(0, 0, 0, 0));
  const endIST = new Date(istNow.setHours(24, 0, 0, 0));
  const utcStart = new Date(startIST.getTime() - istOffset);
  const utcEnd = new Date(endIST.getTime() - istOffset);

  const todayEvents = await Event.find({ date: { $gte: utcStart, $lt: utcEnd } });
  for (const e of todayEvents) {
    await sendNotification(`🎉 Today: ${e.title}`, `${e.clubName} is hosting at ${e.time} (${e.mode})`);
  }
}, { timezone: 'Asia/Kolkata' });

// 🚀 Start Server
app.listen(port, () => console.log(`🚀 Server running on port ${port}`));
