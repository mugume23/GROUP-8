# HomeCare Project - Collaboration Guide

## 👥 Team Members

1. **Mwangye Arafat** - 23/BSU/BIT/1951
2. **Amanya Davis** - 24/BSU/BIT/3148
3. **Muhereza Allan Mugume** - 23/BSU/BIT4/156
4. **Kateregga Naseem** - 23/BSU/BIT/2484
5. **Tumuhimbise Justus** - 23/BSU/BIT/2631

---

## 🚀 Initial Setup (For Project Owner)

### Step 1: Create GitHub Repository

1. Go to https://github.com
2. Click "New Repository"
3. Repository name: `home_care`
4. Description: "HomeCare - Caregiver Matching Platform for Uganda"
5. Choose: **Private** (recommended) or Public
6. **DO NOT** initialize with README (we already have one)
7. Click "Create Repository"

### Step 2: Push Project to GitHub

Open terminal in project folder and run:

```bash
# Initialize git
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: HomeCare app - Complete caregiver matching platform"

# Add remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/home_care.git

# Push to GitHub
git push -u origin main
```

If it asks for `master` instead of `main`, use:
```bash
git branch -M main
git push -u origin main
```

### Step 3: Add Collaborators

1. Go to your repository on GitHub
2. Click **Settings** tab
3. Click **Collaborators** (left sidebar)
4. Click **Add people**
5. Enter each team member's GitHub username or email
6. They'll receive an invitation email

---

## 👨‍💻 For Team Members (Collaborators)

### Step 1: Accept Invitation

1. Check your email for GitHub invitation
2. Click "Accept invitation"
3. Or go to: https://github.com/YOUR_USERNAME/home_care/invitations

### Step 2: Install Required Software

1. **Git** - Download from: https://git-scm.com/downloads
2. **Flutter SDK** - Download from: https://flutter.dev/docs/get-started/install
3. **VS Code** or **Android Studio** - Your preferred IDE

### Step 3: Clone the Repository

Open terminal/command prompt and run:

```bash
# Navigate to where you want the project
cd Desktop  # or any folder you prefer

# Clone the repository (replace YOUR_USERNAME)
git clone https://github.com/YOUR_USERNAME/home_care.git

# Enter the project folder
cd home_care
```

### Step 4: Install Dependencies

```bash
# Install Flutter packages
flutter pub get

# Check if everything is working
flutter doctor
```

### Step 5: Set Up Firebase (IMPORTANT!)

⚠️ **These files are NOT in the repository for security reasons!**

**Contact the project owner to get:**
1. `google-services.json` (for Android)
2. `GoogleService-Info.plist` (for iOS)
3. `firebase_options.dart`

**Place them in:**
- `google-services.json` → `android/app/`
- `GoogleService-Info.plist` → `ios/Runner/`
- `firebase_options.dart` → `lib/`

### Step 6: Run the App

```bash
# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS (macOS only)
flutter run -d ios
```

---

## 🔄 Daily Workflow

### Before Starting Work

**ALWAYS pull latest changes first!**

```bash
# Pull latest changes from GitHub
git pull origin main
```

### While Working

1. Make your changes
2. Test your changes
3. Commit frequently with clear messages

### After Completing Work

```bash
# Check what files you changed
git status

# Add all changed files
git add .

# Or add specific files
git add lib/screens/parent/parent_home_screen.dart

# Commit with a clear message
git commit -m "Add: Parent dashboard statistics feature"

# Push to GitHub
git push origin main
```

---

## 📝 Commit Message Guidelines

Use clear, descriptive commit messages:

### Good Examples:
```bash
git commit -m "Add: Caregiver profile photo upload feature"
git commit -m "Fix: Chat screen overflow on small devices"
git commit -m "Update: Admin dashboard statistics display"
git commit -m "Remove: Unused imports from auth service"
```

### Bad Examples:
```bash
git commit -m "changes"
git commit -m "update"
git commit -m "fix bug"
```

### Prefixes to Use:
- `Add:` - New feature
- `Fix:` - Bug fix
- `Update:` - Modify existing feature
- `Remove:` - Delete code/feature
- `Refactor:` - Code improvement (no functionality change)
- `Docs:` - Documentation changes

---

## 🔀 Handling Conflicts

### If You Get a Conflict Error:

```bash
# Pull changes first
git pull origin main

# If there are conflicts, Git will tell you which files
# Open those files and look for:
<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> main

# Choose which code to keep, then:
git add .
git commit -m "Resolve: Merge conflicts in [filename]"
git push origin main
```

---

## 🌿 Working with Branches (Optional but Recommended)

### Create a Branch for Your Feature

```bash
# Create and switch to new branch
git checkout -b feature/parent-dashboard

# Work on your feature...

# Commit your changes
git add .
git commit -m "Add: Parent dashboard improvements"

# Push your branch
git push origin feature/parent-dashboard

# On GitHub, create a Pull Request
# Team reviews and merges your code
```

### Switch Between Branches

```bash
# See all branches
git branch

# Switch to main branch
git checkout main

# Switch to your feature branch
git checkout feature/parent-dashboard

# Delete a branch (after merging)
git branch -d feature/parent-dashboard
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "Permission denied"
**Solution:** Make sure you accepted the collaboration invitation

### Issue 2: "Authentication failed"
**Solution:** 
```bash
# Use personal access token instead of password
# Generate token at: https://github.com/settings/tokens
# Use token as password when prompted
```

### Issue 3: "Your local changes would be overwritten"
**Solution:**
```bash
# Save your changes first
git stash

# Pull latest changes
git pull origin main

# Restore your changes
git stash pop
```

### Issue 4: "Failed to push"
**Solution:**
```bash
# Pull first, then push
git pull origin main
git push origin main
```

---

## 📋 Best Practices

### DO:
✅ Pull before starting work
✅ Commit frequently with clear messages
✅ Test your code before pushing
✅ Communicate with team about major changes
✅ Keep commits focused (one feature per commit)
✅ Push your work at end of day

### DON'T:
❌ Push broken code
❌ Commit sensitive files (Firebase configs, API keys)
❌ Work on same file simultaneously without coordination
❌ Force push (`git push -f`) unless you know what you're doing
❌ Commit large binary files (videos, large images)

---

## 🔐 Security Reminders

**NEVER commit these files:**
- `google-services.json`
- `GoogleService-Info.plist`
- `firebase_options.dart`
- API keys or passwords

These are already in `.gitignore` but double-check!

---

## 📞 Communication

### Before Making Major Changes:
1. Discuss with team
2. Create a branch
3. Make changes
4. Create Pull Request
5. Get review
6. Merge to main

### Daily Standup (Recommended):
- What did you work on yesterday?
- What will you work on today?
- Any blockers?

---

## 🛠️ Useful Git Commands

```bash
# See commit history
git log

# See who changed what
git blame filename.dart

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard HEAD

# See differences
git diff

# See remote repository URL
git remote -v

# Update remote URL
git remote set-url origin NEW_URL
```

---

## 📚 Learning Resources

- **Git Basics**: https://git-scm.com/book/en/v2
- **GitHub Guides**: https://guides.github.com/
- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs

---

## 🎯 Project Structure

```
home_care/
├── lib/
│   ├── main.dart              # App entry
│   ├── models/                # Data models
│   ├── screens/               # UI screens
│   │   ├── admin/            # Admin screens
│   │   ├── auth/             # Login/Register
│   │   ├── caregiver/        # Caregiver screens
│   │   ├── parent/           # Parent screens
│   │   └── shared/           # Shared screens
│   ├── services/             # Business logic
│   ├── utils/                # Utilities
│   └── widgets/              # Reusable widgets
├── android/                   # Android config
├── ios/                       # iOS config
├── assets/                    # Images, fonts
└── README.md                  # Documentation
```

---

## 🎓 Team Workflow Example

### Scenario: Adding a New Feature

**Mwangye (Team Lead):**
```bash
git checkout -b feature/notifications
# Implement notification system
git add .
git commit -m "Add: Push notification service"
git push origin feature/notifications
# Create Pull Request on GitHub
```

**Amanya (Reviewer):**
- Reviews code on GitHub
- Leaves comments
- Approves or requests changes

**Muhereza:**
```bash
git pull origin main  # Get latest after merge
# Continue with his task
```

---

## ✅ Quick Reference

### Daily Routine:
```bash
# Morning
git pull origin main

# During work
git add .
git commit -m "Clear message"

# End of day
git push origin main
```

### When Stuck:
```bash
git status          # See what's happening
git log             # See recent commits
git pull origin main # Get latest changes
```

---

## 🎉 Success Tips

1. **Communicate** - Use WhatsApp/Telegram for quick coordination
2. **Pull Often** - Avoid conflicts by staying updated
3. **Commit Small** - Easier to track and revert if needed
4. **Test First** - Don't push broken code
5. **Ask Questions** - Better to ask than break something

---

**Happy Coding! 🚀**

*Bishop Stuart University - BIT Year 3*
*Mobile Programming Applications*
