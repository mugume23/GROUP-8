# HomeCare App - Troubleshooting Guide

## ✅ Completed Features

### 1. **No Emojis**
- All greeting messages now display "Hello, [Name]" without emojis
- Clean, professional interface throughout the app

### 2. **Dynamic Home Screen Stats**
- Real-time Firestore queries for:
  - Total caregivers count
  - Verified caregivers count
  - Average rating across all caregivers
- Stats update automatically when data changes

### 3. **WhatsApp-Style Chat**
- **Single grey tick** (✓) — message sent to Firestore
- **Double grey ticks** (✓✓) — message delivered to receiver's device
- **Double blue ticks** (✓✓) — message read by receiver
- **Typing indicator** — animated dots when other person is typing
- **AM/PM timestamps** — e.g., "9:05 AM", "2:30 PM"
- **Date separators** — "Today", "Yesterday", "Mon, 12 May"
- Auto-scroll to bottom on new messages

### 4. **Location Picker on Registration**
- Full Uganda administrative hierarchy:
  - District → County → Subcounty → Parish → Village
- GPS "Use My Current Location" button
- Cascading dropdowns with real Uganda data from jsDelivr CDN
- Location saved to user profile on registration

### 5. **Bug Fixes**
- Login/register loading state fixed (mounted guard)
- `setState after dispose` fixed in all screens
- `ListTile` ink splash fixed (AppCard uses Material)
- All `withOpacity` → `withValues` (Flutter 3.27+)
- **Caregiver dashboard loading** — comprehensive error handling added

### 6. **Launcher Icon**
- `assets/logo.png` resized to all Android mipmap densities

### 7. **Firestore Rules**
- Proper read/write permissions configured
- Located in `firestore.rules` file

---

## 🔧 Caregiver Dashboard Loading Issue - FIXED

### What Was Fixed:
The caregiver dashboard now has comprehensive error handling:

1. **Mounted checks** — prevents `setState` after widget disposal
2. **Try-catch blocks** — catches Firestore errors gracefully
3. **User feedback** — shows error messages via SnackBar
4. **Empty userId handling** — prevents unnecessary Firestore calls

### Code Changes Made:
```dart
Future<void> _loadProfile() async {
  if (!mounted) return;
  if (widget.userId.isEmpty) {
    if (!mounted) return;
    setState(() => _loading = false);
    return;
  }

  try {
    final profile = await _caregiverService.getCaregiverByUserId(widget.userId);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load profile: ${e.toString()}'),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

---

## 🚨 Common Issues & Solutions

### Issue 1: Dashboard Still Not Loading

**Possible Causes:**
1. **Firestore rules not published** in Firebase Console
2. **No caregiver document created** during registration
3. **Network timeout** on first Firestore call
4. **Firebase not initialized** properly

**Solutions:**

#### A. Verify Firestore Rules in Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `home-care-2a997`
3. Navigate to **Firestore Database** → **Rules**
4. Ensure the rules match the content in `firestore.rules`
5. Click **Publish** to apply changes

#### B. Check if Caregiver Document Exists
1. In Firebase Console, go to **Firestore Database** → **Data**
2. Look for the `caregivers` collection
3. Find the document where `userId` matches the logged-in user
4. If missing, the user needs to re-register

#### C. Test Firestore Connection
Add this test code to verify Firestore is working:
```dart
// In caregiver_dashboard_tab.dart, add to initState:
_testFirestore();

Future<void> _testFirestore() async {
  try {
    final test = await FirebaseFirestore.instance
        .collection('caregivers')
        .limit(1)
        .get();
    print('✅ Firestore connected: ${test.docs.length} docs');
  } catch (e) {
    print('❌ Firestore error: $e');
  }
}
```

### Issue 2: Registration Creates User but Not Caregiver Profile

**Check the registration flow:**
```dart
// In auth_service.dart, register() method should create both:
// 1. User document in 'users' collection
// 2. Caregiver document in 'caregivers' collection (if role == 'caregiver')
```

**Verify in Firebase Console:**
1. Go to Firestore Database → Data
2. Check `users` collection — should have user document
3. Check `caregivers` collection — should have caregiver document with matching `userId`

### Issue 3: App Crashes on Startup

**Check Firebase initialization:**
```dart
// In main.dart, ensure Firebase is initialized:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Issue 4: Location Picker Not Working

**Verify internet connection:**
- Location data is fetched from jsDelivr CDN
- Requires active internet connection
- Check console for network errors

**Test the API endpoint:**
```
https://cdn.jsdelivr.net/gh/ewilly/uganda-administrative-divisions/uganda.json
```

---

## 📋 Testing Checklist

### Registration Flow
- [ ] Parent can register with phone + 4-digit PIN
- [ ] Caregiver can register with phone + 4-digit PIN
- [ ] Location picker opens and allows selection
- [ ] GPS location button works (requires device location permission)
- [ ] User is redirected to appropriate home screen after registration

### Login Flow
- [ ] User can login with phone + PIN
- [ ] Error message shows for incorrect credentials
- [ ] User is redirected to appropriate home screen after login

### Parent Dashboard
- [ ] Greeting shows "Hello, [FirstName]" (no emoji)
- [ ] Stats show real numbers from Firestore
- [ ] Stats update when caregivers are added/removed

### Caregiver Dashboard
- [ ] Greeting shows "Hello, [FirstName]" (no emoji)
- [ ] Profile loads without errors
- [ ] Error message shows if profile fails to load
- [ ] Availability toggle works
- [ ] Profile completeness shows correct percentage

### Chat System
- [ ] Messages send successfully
- [ ] Single grey tick appears immediately after sending
- [ ] Double grey ticks appear when delivered
- [ ] Double blue ticks appear when read
- [ ] Typing indicator shows when other person is typing
- [ ] Timestamps show in AM/PM format
- [ ] Date separators show correctly

---

## 🔍 Debugging Tips

### Enable Firestore Debug Logging
```dart
// In main.dart, before runApp():
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Check Console Logs
Look for these patterns:
- `✅` — Success messages
- `❌` — Error messages
- `Firestore error:` — Database connection issues
- `setState after dispose` — Widget lifecycle issues (should be fixed now)

### Test on Real Device
- Web emulator can be slow for Firestore
- Test on Android device for best performance
- Ensure device has internet connection

---

## 📞 Firebase Configuration

### Current Project Details
- **Project ID:** `home-care-2a997`
- **Auth Domain:** `home-care-2a997.firebaseapp.com`
- **Storage Bucket:** `home-care-2a997.firebasestorage.app`

### Collections Structure
```
firestore
├── users
│   └── {userId}
│       ├── phone: string
│       ├── pinHash: string
│       ├── name: string
│       ├── role: string
│       ├── location: string
│       ├── district: string
│       └── createdAt: timestamp
│
├── caregivers
│   └── {caregiverId}
│       ├── userId: string
│       ├── name: string
│       ├── phone: string
│       ├── bio: string
│       ├── location: string
│       ├── district: string
│       ├── specializations: array
│       ├── hourlyRate: number
│       ├── rating: number
│       ├── reviewCount: number
│       ├── isAvailable: boolean
│       ├── isVerified: boolean
│       └── availability: array
│
├── reviews
│   └── {reviewId}
│       ├── caregiverId: string
│       ├── parentId: string
│       ├── rating: number
│       ├── comment: string
│       └── createdAt: timestamp
│
└── chats
    └── {chatId}
        ├── parentId: string
        ├── caregiverId: string
        ├── lastMessage: string
        ├── lastMessageTime: timestamp
        ├── unreadCount: number
        └── messages (subcollection)
            └── {messageId}
                ├── senderId: string
                ├── text: string
                ├── timestamp: timestamp
                ├── status: string (sent/delivered/read)
                └── isRead: boolean
```

---

## 🎯 Next Steps

1. **Publish Firestore Rules**
   - Go to Firebase Console
   - Navigate to Firestore Database → Rules
   - Copy content from `firestore.rules`
   - Click Publish

2. **Test Registration Flow**
   - Register as a caregiver
   - Verify profile is created in Firestore
   - Login and check dashboard loads

3. **Test Chat System**
   - Register as parent and caregiver
   - Start a chat
   - Verify ticks and typing indicators work

4. **Deploy to Device**
   - Build APK: `flutter build apk --release`
   - Install on Android device
   - Test all features end-to-end

---

## 📝 Notes

- All emojis have been removed from the app
- All loading states have proper error handling
- All `setState` calls are guarded with `mounted` checks
- Location picker uses real Uganda administrative data
- Chat system implements full WhatsApp-style features
- Firestore rules are configured for production use

---

**Last Updated:** May 23, 2026
**App Version:** 1.0.0
**Flutter Version:** 3.27+
