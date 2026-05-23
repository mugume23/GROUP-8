# HomeCare - Caregiver Matching Platform

A comprehensive Flutter application connecting parents with trusted caregivers in Uganda.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange.svg)
![License](https://img.shields.io/badge/License-Academic-green.svg)

## 📱 About

HomeCare is a mobile application that bridges the gap between parents seeking childcare services and qualified caregivers in Uganda. The platform provides a secure, efficient way to find, verify, and connect with trusted caregivers.

### 🎓 Academic Project

**Institution**: Bishop Stuart University  
**Faculty**: Applied Sciences & Technology  
**Course**: BIT Year 3 - Mobile Programming Applications  
**Semester**: 2

### 👥 Development Team

1. **Mwangye Arafat** - 23/BSU/BIT/1951
2. **Amanya Davis** - 24/BSU/BIT/3148
3. **Muhereza Allan Mugume** - 23/BSU/BIT4/156
4. **Kateregga Naseem** - 23/BSU/BIT/2484
5. **Tumuhimbise Justus** - 23/BSU/BIT/2631

---

## ✨ Features

### For Parents
- 🔍 Browse and search verified caregivers
- 📍 Filter by location, experience, and rating
- 💬 Real-time chat with caregivers
- 📝 Send service requests
- ⭐ View profiles and reviews
- 📊 Personal dashboard

### For Caregivers
- 👤 Complete profile management
- 📸 Photo upload capability
- 💼 Manage service requests
- 💬 Chat with parents
- ✅ Verification system
- 📊 Performance dashboard

### For Admins
- 🎛️ Complete platform management
- ✅ Verify/reject caregiver applications
- 👥 Manage all users
- 📊 Comprehensive analytics
- 🔐 Create additional admins
- 👁️ View detailed user profiles

### Core Features
- 🔐 Phone + PIN authentication
- 💬 WhatsApp-style chat (read receipts, typing indicators)
- 📍 Uganda location picker (District → Village)
- 🌐 Real-time Firestore synchronization
- 📱 Responsive design (Web, Android, iOS)
- 🎨 Modern UI with animations

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase account
- Android Studio (for Android builds)
- Xcode (for iOS builds - macOS only)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/home_care.git
cd home_care
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**

⚠️ **IMPORTANT**: You need to set up your own Firebase project

- Create a new Firebase project at https://console.firebase.google.com
- Enable Firestore Database
- Enable Authentication (if needed)
- Download configuration files:
  - `google-services.json` for Android → Place in `android/app/`
  - `GoogleService-Info.plist` for iOS → Place in `ios/Runner/`
- Update `lib/firebase_options.dart` with your Firebase config

4. **Run the app**
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 🔧 Configuration

### Firebase Collections

The app uses the following Firestore collections:
- `users` - All user accounts (parents, caregivers, admins)
- `chats` - Chat conversations
- `requests` - Service requests
- `reviews` - Caregiver reviews

### ImgBB API

For image uploads, you'll need an ImgBB API key:
1. Get a free API key from https://api.imgbb.com/
2. Update the key in `lib/services/imgbb_service.dart`

---

## 📚 Documentation for Team

- **README.md** - Project overview and setup guide
- **COLLABORATION_GUIDE.md** - Complete Git workflow for team members
- **FIREBASE_SETUP.md** - Firebase configuration instructions
- **QUICK_REFERENCE.md** - Git commands quick reference card

---

## 🔐 Admin Setup

### Creating the First Admin

1. **Generate PIN Hash**
   - Use: https://emn178.github.io/online-tools/sha256.html
   - Enter your 4-digit PIN
   - Copy the hash

2. **Add to Firestore**
   - Go to Firebase Console → Firestore
   - Collection: `users`
   - Add document:
     ```json
     {
       "phone": "0700000000",
       "name": "Admin Name",
       "role": "admin",
       "pinHash": "YOUR_GENERATED_HASH",
       "location": "Kampala, Uganda",
       "district": "Kampala",
       "createdAt": "CURRENT_TIMESTAMP"
     }
     ```

3. **Login & Create More Admins**
   - Login with phone + PIN
   - Use "Create Admin Account" feature in dashboard

---

## 📱 Building for Production

### Android APK
```bash
# Single APK
flutter build apk --release

# Split per ABI (smaller files)
flutter build apk --split-per-abi
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

---

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Database**: Firebase Firestore
- **Authentication**: Custom (Phone + PIN with SHA-256)
- **Image Storage**: ImgBB API
- **State Management**: StatefulWidget
- **Local Storage**: SharedPreferences

### Key Packages
- `firebase_core` & `cloud_firestore` - Backend
- `crypto` - PIN hashing
- `image_picker` - Photo selection
- `geolocator` - Location services
- `http` - API calls
- `shared_preferences` - Local storage

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── screens/
│   ├── admin/                   # Admin screens
│   ├── auth/                    # Authentication
│   ├── caregiver/              # Caregiver screens
│   ├── parent/                 # Parent screens
│   └── shared/                 # Shared screens
├── services/                    # Business logic
├── utils/                       # Utilities & theme
└── widgets/                     # Reusable widgets
```

---

## 🔒 Security

- ✅ PIN hashing with SHA-256
- ✅ Firestore security rules
- ✅ Role-based access control
- ✅ Input validation
- ✅ Secure API calls

⚠️ **Important**: Never commit sensitive files:
- `google-services.json`
- `GoogleService-Info.plist`
- `firebase_options.dart`
- API keys

---

## 📸 Screenshots

*Add screenshots of your app here*

---

## 🤝 Contributing

This is an academic project. For questions or suggestions, contact the development team.

---

## 📝 License

This project is developed as part of academic coursework at Bishop Stuart University.

---

## 📞 Contact

For inquiries:
- **Institution**: Bishop Stuart University
- **Faculty**: FAEST
- **Course**: BIT Year 3

---

## 🙏 Acknowledgments

- Bishop Stuart University
- Faculty of Applied Sciences & Technology
- Mobile Programming Applications Course Instructors
- Firebase & Flutter Communities

---

**Made with ❤️ by BIT Year 3 Students at Bishop Stuart University**

*Last Updated: May 2026*

