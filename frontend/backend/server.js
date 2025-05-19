const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')

const app = express()
app.use(cors())
app.use(express.json())

mongoose.connect("mongodb+srv://27ranjali:clubaikya@cluster0.nd2ipt3.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0", {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log("Connected to MongoDB")
}).catch(err => {
  console.error("MongoDB connection error:", err)
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

app.post("/api/users", async (req, res) => {
  try {
    console.log("Received user data:", req.body)
    const newUser = new User(req.body)
    await newUser.save()
    res.status(201).json({ message: "User saved" })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

app.listen(3000, () => console.log("Server running on port 3000"))
