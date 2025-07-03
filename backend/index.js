const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
const jwt = require('jsonwebtoken')
const bodyParser = require('body-parser')
const multer = require('multer')
const path = require('path')
const fs = require('fs')
const { v4: uuidv4 } = require('uuid')
const cloudinary = require('cloudinary').v2
const app = express()
const port = 3000
const JWT_SECRET = 'super_secret_key_123'

app.use(cors())
app.use(bodyParser.json())

// Cloudinary Setup
cloudinary.config({
  cloud_name: 'dbdlaoews',    // <--- replace with your Cloudinary cloud name
  api_key: '934196156288849',          // <--- replace with your Cloudinary API key
  api_secret: 'B_8UWhShgif6QQTzMx501A1af8Y'     // <--- replace with your Cloudinary API secret
})

// Multer Setup for file upload
const upload = multer({ dest: 'uploads/' })
const otpStore = {}

const accountSid = 'ACf017e34c36c3d3888a81351a91792996'
const authToken = '784178795821b423500dae787c176a1b'
const client = require('twilio')(accountSid, authToken)
const axios = require('axios');

async function sendNotification(title, message, playerIds = []) {
  const ONESIGNAL_APP_ID = 'c07579f1-3b55-40a1-87f3-642019d265c9';
  const REST_API_KEY = 'os_v2_app_yb2xt4j3kvakdb7tmqqbtutfzeqi4fy3p62e6sfts6yzbacx6rxa3znflhjrku5pn5c3rvsizcyqgooe4sqi3zo7k5nocnam6e6fx6a';
  const headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': `Basic ${REST_API_KEY}`,
  };

  const body = {
    app_id: ONESIGNAL_APP_ID,
    included_segments: ['All'], // if empty, use segments instead
    headings: { en: title },
    contents: { en: message },
  };

  try {
    const response = await axios.post(
      'https://onesignal.com/api/v1/notifications',
      body,
      { headers }
    );
    console.log('📩 Notification sent:', response.data);
  } catch (error) {
    console.error('❌ Notification error:', error.response?.data || error.message);
  }
}

// ⏱ MongoDB Connection
mongoose.connect("mongodb+srv://27ranjali:clubaikya@cluster0.nd2ipt3.mongodb.net/ClubAIKYA?retryWrites=true&w=majority&appName=Cluster0", {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log("✅ Connected to MongoDB")
}).catch(err => {
  console.error("❌ MongoDB connection error:", err.message)
  process.exit(1)
})

// 📄 Schemas
const userSchema = new mongoose.Schema({
  phone: String,
  name: String,
  rollNo: String,
  course: String,
  branch: String,
  dob: Date,
  validity: String,
  role: { type: String, enum: ['Student', 'Admin'], default: 'Student' },
  adminCode: String
})
const User = mongoose.model("User", userSchema)

const associatedLinkSchema = new mongoose.Schema({
  label: String,
  url: String
})

const eventSchema = new mongoose.Schema({
  clubName: String,
  title: String,
  description: String,
  location: String,
  mode: { type: String, enum: ['Offline', 'Online'], default: 'Offline' },
  date: Date,
  time: String,
  registrationDeadline: Date,
  customFieldLabel: String,
  customFieldValue: String,
  associatedLinks: [associatedLinkSchema],
  imageUrl: String
}, { timestamps: true })
const Event = mongoose.model("Event", eventSchema)

// Middleware to authenticate JWT token and extract user
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'] || req.headers['Authorization']
  const token = authHeader && authHeader.split(' ')[1]

  if (!token) return res.status(401).json({ success: false, message: 'Token missing' })

  try {
    const decoded = jwt.verify(token, JWT_SECRET)
    const user = await User.findById(decoded.id)
    if (!user) return res.status(404).json({ success: false, message: 'User not found' })
    req.user = user
    console.log(token)
    next()
  } catch (err) {
    return res.status(403).json({ success: false, message: 'Invalid or expired token' })
  }
}

// 🔐 OTP Routes
app.post('/send-otp', async (req, res) => {
  const { phone } = req.body
  const otp = Math.floor(100000 + Math.random() * 900000).toString()
  otpStore[phone] = otp
  try {
    await client.messages.create({
      body: `Your otp is ${otp}`, // Fixed template to use backticks and interpolation
      from: '+1 816 451 5164',
      to: phone,
    })
    res.send({ success: true, message: 'OTP sent' })
  } catch (err) {
    res.status(500).send({ success: false, message: err.message })
  }
})

app.post('/verify-otp', async (req, res) => {
  const { phone, otp } = req.body
  if (otpStore[phone] === otp) {
    delete otpStore[phone]
    try {
      let user = await User.findOne({ phone })
      if (!user) {
        // Option 1: Create a new user automatically (if you want seamless signup)
        user = await User.create({ phone }) // create user with minimal info
        // Option 2: Or just return a token for a temporary unregistered user (less common)
      }
      const token = jwt.sign({ id: user._id, phone: user.phone, role: user.role }, JWT_SECRET, { expiresIn: '7d' })
      res.send({ success: true, message: 'OTP verified', token, user })
      console.log(token)
    } catch (err) {
      res.status(500).send({ success: false, message: 'Server error' })
    }
  } else {
    res.status(400).send({ success: false, message: 'Invalid OTP' })
  }
})


// Protect events creation route with authenticateToken middleware
app.post("/api/events", authenticateToken, upload.single('image'), async (req, res) => {
  try {
    console.log('here in backend')
    const {
      clubName, title, description, location, mode,
      date, time, registrationDeadline,
      customFieldLabel, customFieldValue, associatedLinks
    } = req.body

    if (!req.file) return res.status(400).json({ success: false, message: "Image file is required" })

    // Upload image to Cloudinary
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: 'events',
      public_id: `${uuidv4()}_${req.file.originalname}`,
      resource_type: 'image'
    })

    // Delete local file after upload
    fs.unlinkSync(req.file.path)

    const newEvent = new Event({
      clubName, title, description, location, mode: mode || 'Offline',
      date: new Date(date), time, registrationDeadline: new Date(registrationDeadline),
      customFieldLabel, customFieldValue,
      associatedLinks: JSON.parse(associatedLinks || '[]'),
      imageUrl: result.secure_url
    })

    await newEvent.save()

    // ✅ Send OneSignal push notification to all users
    const notifTitle = `📢 New Event: ${title}`
    const notifMessage = `${clubName} is hosting ${title} on ${date} at ${time}`
    await sendNotification(notifTitle, notifMessage)

    console.log("New event created and notification sent.")
    res.status(201).json({ success: true, event: newEvent })
  } catch (err) {
    if (req.file) fs.unlinkSync(req.file.path)
    res.status(500).json({ success: false, error: err.message })
  }
})

const cron = require('node-cron');

// 🔁 Daily notification at 9:00 AM IST (which is 3:30 AM UTC)
cron.schedule('16 14 * * *', async () => {
  console.log('⏰ [CRON] Running daily event notifier at', new Date().toLocaleString());

  // IST math
  const now = new Date();
  const istOffsetMs = 5.5 * 60 * 60 * 1000;
  const istNow = new Date(now.getTime() + istOffsetMs);
  const istStart = new Date(istNow);
  istStart.setHours(0, 0, 0, 0);
  const istEnd = new Date(istNow);
  istEnd.setHours(24, 0, 0, 0);
  const utcStart = new Date(istStart.getTime() - istOffsetMs);
  const utcEnd = new Date(istEnd.getTime() - istOffsetMs);

  try {
    const eventsToday = await Event.find({
      date: { $gte: utcStart, $lt: utcEnd }
    });

    if (eventsToday.length === 0) {
      console.log('📭 No events today at', new Date().toLocaleString());
      return;
    }

    console.log(`✅ Found ${eventsToday.length} events for today`);
    for (const event of eventsToday) {
      const title = `🎉 Today: ${event.title}`;
      const message = `${event.clubName} is hosting ${event.title} at ${event.time} (${event.mode}) in ${event.location}.`;

      await sendNotification(title, message);
      console.log(`📢 Notified for event: ${event.title}`);
    }
  } catch (err) {
    console.error('❌ Error in daily event notification:', err.message);
  }
},{
  timezone: 'Asia/Kolkata'
});


app.post("/api/users", async (req, res) => {
  try {
    console.log("📥 Received user data:", req.body)
    const newUser = new User(req.body)
    await newUser.save()
    console.log("✅ User saved:", newUser.name)
    const token = jwt.sign(
      { id: newUser._id, phone: newUser.phone, role: newUser.role },
      JWT_SECRET,
      { expiresIn: '7d' }
    )
    res.status(201).json({ message: "User saved", token, user: newUser })
  } catch (err) {
    console.error("❌ Error saving user:", err)
    res.status(500).json({ error: err.message })
  }
}) 
app.put('/api/users/:phone', authenticateToken, async (req, res) => {
  try {
    console.log(`🔍 Updating phone: ${req.params.phone}`);
    console.log(`📥 Body:`, req.body);

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
    console.log(`➡ Update:`, update);

    const user = await User.findOneAndUpdate(
      { phone: req.params.phone },
      update,
      { new: true }
    );

    if (user) {
      console.log(`✅ Updated user:`, user);
      res.status(200).json({ success: true, user });
    } else {
      console.log(`❌ No user found for phone: ${req.params.phone}`);
      res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (err) {
    console.error(`❌ Update error:`, err);
    res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
});

app.get('/events/today', async (req, res) => {
  try {
    const now = new Date();

    // Offset in milliseconds for IST (UTC+5:30)
    const istOffsetMs = 5.5 * 60 * 60 * 1000;

    // Convert current time to IST
    const istNow = new Date(now.getTime() + istOffsetMs);

    // Get IST start and end of the day
    const istStart = new Date(istNow);
    istStart.setHours(0, 0, 0, 0);

    const istEnd = new Date(istNow);
    istEnd.setHours(24, 0, 0, 0);

    // Convert those IST boundaries back to UTC for MongoDB query
    const utcStart = new Date(istStart.getTime() - istOffsetMs);
    const utcEnd = new Date(istEnd.getTime() - istOffsetMs);

    console.log("Query UTC range:", utcStart.toISOString(), "to", utcEnd.toISOString());

    const events = await Event.find({
      date: { $gte: utcStart, $lt: utcEnd },
    });

    res.status(200).json(events);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch today's events" });
  }
});



// New route to get logged-in user's profile
app.get('/profile', authenticateToken, (req, res) => {
  res.json({ success: true, user: req.user })
})
// Get events by club name
app.get('/api/clubs/:clubName/events', async (req, res) => {
  try {

    const { clubName } = req.params;
    const events = await Event.find({ clubName });
    console.log('hello');
    if (!events || events.length === 0) {
      return res.status(404).json({ success: false, message: 'No events found for this club.' });
    }

    res.status(200).json({ success: true, events });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
});

app.get('/ping-db', async (req, res) => {
  try {
    const ping = await mongoose.connection.db.admin().ping()
    res.send({ success: true, message: "MongoDB is reachable", ping })
  } catch (err) {
    res.status(500).send({ success: false, message: "MongoDB not reachable", error: err.message })
  }
})

app.listen(port, () => console.log(`🚀 Server running on port ${port}`))
