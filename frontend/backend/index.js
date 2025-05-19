const jwt = require('jsonwebtoken')
const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
const bodyParser = require('body-parser')
const app = express()
const port = 3000
const JWT_SECRET = 'super_secret_key_123'

app.use(cors())
app.use(bodyParser.json())

const otpStore = {}

const accountSid = 'ACf017e34c36c3d3888a81351a91792996'
const authToken = '784178795821b423500dae787c176a1b'
const client = require('twilio')(accountSid, authToken)

// ⏱ DEBUG: Track connection start time
const connectionStart = Date.now()

mongoose.connect("mongodb+srv://27ranjali:clubaikya@cluster0.nd2ipt3.mongodb.net/ClubAIKYA?retryWrites=true&w=majority&appName=Cluster0", {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  const connectionEnd = Date.now()
  console.log(`✅ Connected to MongoDB in ${connectionEnd - connectionStart}ms`)
  console.log("📦 Using DB:", mongoose.connection.name)
}).catch(err => {
  const connectionEnd = Date.now()
  console.error(`❌ MongoDB connection failed after ${connectionEnd - connectionStart}ms`)
  console.error("❌ Error:", err.message)
  process.exit(1) // stop the app if DB fails
})

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true },
  name: { type: String, required: true },
  rollNo: { type: String, required: true },
  course: { type: String, required: true },
  branch: { type: String, required: true },
  dob: { type: Date, required: true },
  validity: { type: String },
  role: { type: String, enum: ['Student', 'Admin'], default: 'Student' },
  adminCode: { type: String }
})

const User = mongoose.model("User", userSchema)

app.post('/send-otp', async (req, res) => {
  const { phone } = req.body
  const otp = Math.floor(100000 + Math.random() * 900000).toString()
  otpStore[phone] = otp
  console.log(`📤 Sent OTP: ${otp} for phone: ${phone}`)
  try {
    await client.messages.create({
      body: `Your OTP is ${otp}`,
      from: '+1 816 451 5164',
      to: phone,
    })
    res.send({ success: true, message: 'OTP sent' })
  } catch (err) {
    console.error('❌ Error sending OTP:', err)
    res.status(500).send({ success: false, message: err.message })
  }
})

app.post('/verify-otp', async (req, res) => {
  const { phone, otp } = req.body
  console.log(`🔐 Verifying OTP. Received: ${otp}, Stored: ${otpStore[phone]}`)
  if (otpStore[phone] === otp) {
    delete otpStore[phone]
    try {
      console.log(`🔍 Checking user in DB for phone: ${phone}`)
      const user = await User.findOne({ phone })
      console.log(user ? `✅ User found: ${user.name}` : `ℹ️ No user registered with this phone.`)
      if (user) {
        const token = jwt.sign(
          { id: user._id, phone: user.phone, role: user.role },
          JWT_SECRET,
          { expiresIn: '7d' }
        )
        res.send({ success: true, message: 'OTP verified and user logged in', token, user })
      } else {
        res.send({ success: true, message: 'OTP verified but user not registered' })
      }
    } catch (err) {
      console.error('❌ Server error during verification:', err)
      res.status(500).send({ success: false, message: 'Server error' })
    }
  } else {
    console.warn(`❌ Invalid OTP attempt for ${phone}`)
    res.status(400).send({ success: false, message: 'Invalid OTP' })
  }
})

app.post("/api/users", async (req, res) => {
  try {
    console.log("📥 Received user data:", req.body)
    const newUser = new User(req.body)
    await newUser.save()
    console.log("✅ User saved:", newUser.name)
    const token = jwt.sign(
      { id: newUser._id, phone: newUser.phone, role: newUser.role },
      JWT_SECRET,
      { expiresIn: '1h' }
    )
    res.status(201).json({ message: "User saved", token, user: newUser })
  } catch (err) {
    console.error("❌ Error saving user:", err)
    res.status(500).json({ error: err.message })
  }
})

// Optional: Add a DB ping endpoint
app.get('/ping-db', async (req, res) => {
  try {
    const admin = mongoose.connection.db.admin()
    const ping = await admin.ping()
    res.send({ success: true, message: "MongoDB is reachable", ping })
  } catch (err) {
    res.status(500).send({ success: false, message: "MongoDB not reachable", error: err.message })
  }
})

app.listen(port, () => console.log(`🚀 Server running on port ${port}`))
