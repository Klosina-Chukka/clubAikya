# ClubAIKYA

Clubaikya is a mobile application designed to centralize and simplify the management of college clubs, events, and announcements. It provides students with a single verified platform to stay updated on club activities, avoiding information scattered across social media and chat groups.

---

## 🚀 Features

* OTP-based user authentication using mobile number
* JWT-based authorization with automatic login
* Role-based access control for club admins
* Dedicated pages for each club with events and announcements
* Event creation and announcement management for admins
* Real-time push notifications for updates
* OCR-based signup to extract student details from ID cards
* Cloud-based image upload and storage

---

## 🛠 Tech Stack

### Frontend

* Flutter (Dart)

### Backend

* Node.js
* Express.js

### Database

* MongoDB

### Integrations & Services

* Twilio – OTP-based phone number verification
* OneSignal – Push notifications
* Cloudinary – Image upload and storage
* Google ML Kit – OCR for ID card data extraction

---

## 🏗 System Architecture

* Flutter mobile app communicates with backend via RESTful APIs
* Backend handles authentication, business logic, and data access
* MongoDB stores users, clubs, events, and announcements
* Third-party services integrated for messaging, notifications, and media

---

## 🔐 Authentication Flow

1. User signs up using mobile number
2. OTP is sent via Twilio for verification
3. On successful verification, a JWT token is generated
4. JWT token is used for secure API access and auto-login

---

## 📱 App Modules

* **Authentication**: OTP login and signup with JWT
* **Home**: Displays clubs, events, and announcements
* **Club Page**: Detailed club information with events and updates
* **Event Management**: Admin-only event creation and management
* **Profile**: User details and session management

---

## 🧪 API Testing

* APIs can be tested using Postman
* All endpoints are protected using JWT middleware

---

## ⚙️ Setup Instructions

### Prerequisites

* Flutter SDK
* Node.js & npm
* MongoDB (local or Atlas)
* Git

### Backend Setup

```bash
git clone <backend-repo-url>
cd backend
npm install
npm start
```

### Frontend Setup

```bash
git clone <frontend-repo-url>
cd frontend
flutter pub get
flutter run
```

---

## 🌱 Future Enhancements

* Admin web dashboard
* In-app messaging between clubs and members
* AI-based club recommendations
* Offline mode support
* Feedback and polling system

---

## 📄 License

This project is developed for academic and learning purposes.


