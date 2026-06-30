# ClubAIKYA Backend Deployment Guide

## Quick Start - Deploy to Render (Free)

### Step 1: Create a MongoDB Atlas account (Free)
1. Go to https://www.mongodb.com/cloud/atlas
2. Click "Sign Up" and create an account
3. Create a free cluster
4. In "Database Access", create a user with username/password
5. In "Network Access", add `0.0.0.0/0` to allow all IPs
6. Get your connection string: `mongodb+srv://username:password@cluster.mongodb.net/clubaikya?retryWrites=true&w=majority`

### Step 2: Get Twilio Credentials (for OTP)
1. Go to https://www.twilio.com/console
2. Copy your **Account SID** and **Auth Token**
3. Get a Twilio phone number or use trial SMS

### Step 3: Get Cloudinary Credentials (for Image Upload)
1. Go to https://cloudinary.com/
2. Sign up free
3. In your dashboard, copy **Cloud Name**, **API Key**, **API Secret**

### Step 4: Deploy to Render
1. Go to https://render.com
2. Sign up with GitHub
3. Click "New +" → "Web Service"
4. Select your GitHub repository `clubAikya`
5. Configure:
   - **Name**: `clubaikya-backend`
   - **Branch**: `main`
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && npm start`
   - **Runtime**: `Node`
6. Click "Advanced" and add environment variables:
   ```
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/clubaikya?retryWrites=true&w=majority
   TWILIO_ACCOUNT_SID=your_account_sid
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_PHONE_NUMBER=+1234567890
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   ONESIGNAL_API_KEY=test_key
   ONESIGNAL_APP_ID=test_app_id
   JWT_SECRET=super_secret_key_123
   ```
7. Click "Create Web Service"
8. Wait for deployment (5-10 minutes)
9. Copy your deployed URL (e.g., `https://clubaikya-backend.onrender.com`)

### Step 5: Update Frontend APK
- Tell me your Render backend URL
- I'll update the frontend code
- We'll rebuild the APK

## Local Testing (Optional)

```bash
cd backend
npm install
# Create .env file with your credentials
npm start
```

The backend will run on `http://localhost:3000`

## API Endpoints

- `POST /send-otp` - Send OTP to phone
- `POST /verify-otp` - Verify OTP and get JWT token
- `POST /api/users/{phone}` - Update user profile
- `GET /announcements/all` - Get all announcements
- `GET /api/clubs/{clubName}/events` - Get club events
