# Firebase Setup Guide for Team Members

## 🔥 Important Notice

**Firebase configuration files are NOT included in the GitHub repository for security reasons.**

You need to get these files from the project owner to run the app.

---

## 📁 Required Files

### 1. For Android: `google-services.json`
- **Location**: `android/app/google-services.json`
- **Get from**: Project owner or Firebase Console

### 2. For iOS: `GoogleService-Info.plist`
- **Location**: `ios/Runner/GoogleService-Info.plist`
- **Get from**: Project owner or Firebase Console

### 3. For Flutter: `firebase_options.dart`
- **Location**: `lib/firebase_options.dart`
- **Get from**: Project owner

---

## 🚀 Setup Steps

### Step 1: Get Files from Project Owner

Contact **Mwangye Arafat** (Project Lead) to get:
1. `google-services.json`
2. `GoogleService-Info.plist`
3. `firebase_options.dart`

### Step 2: Place Files in Correct Locations

```
home_care/
├── android/
│   └── app/
│       └── google-services.json          ← Place here
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist      ← Place here
└── lib/
    └── firebase_options.dart             ← Place here
```

### Step 3: Verify Setup

Run the app to check if Firebase is working:

```bash
flutter run -d chrome
```

If you see Firebase errors, the files are missing or in wrong location.

---

## 🔐 Alternative: Download from Firebase Console

If you have access to the Firebase project:

### For Android (`google-services.json`):
1. Go to https://console.firebase.google.com
2. Select project: `home-care-2a997`
3. Click ⚙️ (Settings) → Project settings
4. Scroll to "Your apps"
5. Click Android app
6. Click "Download google-services.json"
7. Place in `android/app/`

### For iOS (`GoogleService-Info.plist`):
1. Same steps as above
2. Click iOS app instead
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`

### For Flutter (`firebase_options.dart`):
1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Run configuration:
   ```bash
   flutterfire configure
   ```
3. Select the Firebase project
4. This generates `lib/firebase_options.dart`

---

## ⚠️ Security Warning

**NEVER commit these files to GitHub!**

They are already in `.gitignore`, but be careful:
- Don't share them publicly
- Don't post screenshots containing them
- Don't commit them accidentally

---

## 🧪 Testing Firebase Connection

After setup, test if Firebase is working:

```dart
// This should work without errors
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

---

## 🆘 Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
**Solution**: Firebase files are missing or in wrong location

### Error: "google-services.json not found"
**Solution**: Place file in `android/app/` folder

### Error: "GoogleService-Info.plist not found"
**Solution**: Place file in `ios/Runner/` folder

### Error: "firebase_options.dart not found"
**Solution**: Get file from project owner or regenerate using FlutterFire CLI

---

## 📞 Contact

If you need the Firebase files, contact:

**Project Owner**: Mwangye Arafat (23/BSU/BIT/1951)

Or ask in the team WhatsApp/Telegram group.

---

## ✅ Checklist

Before running the app, make sure you have:

- [ ] Cloned the repository
- [ ] Installed Flutter dependencies (`flutter pub get`)
- [ ] Received `google-services.json` from project owner
- [ ] Placed `google-services.json` in `android/app/`
- [ ] Received `GoogleService-Info.plist` from project owner
- [ ] Placed `GoogleService-Info.plist` in `ios/Runner/`
- [ ] Received `firebase_options.dart` from project owner
- [ ] Placed `firebase_options.dart` in `lib/`
- [ ] Tested the app (`flutter run`)

---

**Once you have all files, you're ready to develop! 🚀**
