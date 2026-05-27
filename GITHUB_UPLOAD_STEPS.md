# GitHub Upload Steps - For Project Owner

## 📋 Pre-Upload Checklist

✅ Git installed
✅ GitHub account created
✅ DevicePreview disabled (set to `false` in main.dart)
✅ Sensitive files in .gitignore
✅ README.md updated
✅ Documentation files created

---

## 🚀 Step-by-Step Upload Process

### Step 1: Create GitHub Repository

1. Go to https://github.com
2. Click the **"+"** icon (top right) → **"New repository"**
3. Fill in details:
   - **Repository name**: `home_care`
   - **Description**: "HomeCare - Caregiver Matching Platform for Uganda"
   - **Visibility**: Choose **Private** (recommended) or **Public**
   - **DO NOT** check "Initialize with README"
4. Click **"Create repository"**

### Step 2: Initialize Git in Your Project

Open terminal in your project folder (`C:\Users\mbaro\home_care`):

```bash
# Initialize git repository
git init

# Check status
git status
```

### Step 3: Add All Files

```bash
# Add all files to staging
git add .

# Verify what will be committed
git status
```

### Step 4: Create First Commit

```bash
# Create commit with message
git commit -m "Initial commit: HomeCare app - Complete caregiver matching platform"
```

### Step 5: Connect to GitHub

Replace `YOUR_USERNAME` with your actual GitHub username:

```bash
# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/home_care.git

# Verify remote was added
git remote -v
```

### Step 6: Push to GitHub

```bash
# Push to main branch
git push -u origin main
```

If you get an error about `master` vs `main`:

```bash
# Rename branch to main
git branch -M main

# Push again
git push -u origin main
```

### Step 7: Verify Upload

1. Go to https://github.com/YOUR_USERNAME/home_care
2. You should see all your files
3. Check that README.md displays properly

---

## 👥 Step 8: Add Team Members as Collaborators

### On GitHub Website:

1. Go to your repository: https://github.com/YOUR_USERNAME/home_care
2. Click **"Settings"** tab (top menu)
3. Click **"Collaborators"** (left sidebar)
4. Click **"Add people"** button
5. Enter each team member's GitHub username or email:
   - Amanya Davis
   - Muhereza Allan Mugume
   - Kateregga Naseem
   - Tumuhimbise Justus
6. Click **"Add [username] to this repository"**
7. They'll receive an email invitation

### Team Members Must:
1. Check their email
2. Click "Accept invitation"
3. Or go to: https://github.com/YOUR_USERNAME/home_care/invitations

---

## 📤 Step 9: Share Firebase Files with Team

**IMPORTANT**: Firebase files are NOT in GitHub (for security)

### Files to Share Privately:

1. `android/app/google-services.json`
2. `ios/Runner/GoogleService-Info.plist`
3. `lib/firebase_options.dart`

### How to Share:

**Option 1: WhatsApp/Telegram**
- Zip the 3 files
- Send to team group
- Tell them where to place each file

**Option 2: Google Drive**
- Upload files to shared folder
- Share link with team

**Option 3: Email**
- Send files as attachments
- Include placement instructions

### Message Template:

```
Hi Team,

I've uploaded the HomeCare project to GitHub!

Repository: https://github.com/YOUR_USERNAME/home_care

To get started:
1. Accept the GitHub collaboration invitation (check your email)
2. Read COLLABORATION_GUIDE.md for setup instructions
3. Download these Firebase files: [attach files or link]
   - google-services.json → place in android/app/
   - GoogleService-Info.plist → place in ios/Runner/
   - firebase_options.dart → place in lib/

See FIREBASE_SETUP.md for detailed instructions.

Let me know if you have any issues!
```

---

## 📝 Step 10: Team Instructions

Share this with your team:

### For Team Members to Clone and Setup:

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/home_care.git

# 2. Enter project folder
cd home_care

# 3. Install dependencies
flutter pub get

# 4. Get Firebase files from project owner
# Place them in correct locations (see FIREBASE_SETUP.md)

# 5. Run the app
flutter run -d chrome
```

---

## 🔄 Daily Workflow (For Everyone)

### Morning:
```bash
git pull origin main
```

### During Work:
```bash
# Make changes...
git add .
git commit -m "Clear message about what you did"
```

### End of Day:
```bash
git push origin main
```

---

## ⚠️ Important Reminders

### DO:
✅ Pull before starting work
✅ Commit with clear messages
✅ Push at end of day
✅ Test before pushing
✅ Communicate with team

### DON'T:
❌ Push broken code
❌ Commit Firebase files
❌ Force push without team agreement
❌ Work on same file simultaneously

---

## 🆘 Troubleshooting

### "Permission denied"
**Solution**: Make sure you're logged into GitHub
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### "Authentication failed"
**Solution**: Use Personal Access Token
1. Go to https://github.com/settings/tokens
2. Generate new token (classic)
3. Copy token
4. Use as password when pushing

### "Repository not found"
**Solution**: Check repository URL
```bash
git remote -v
git remote set-url origin https://github.com/YOUR_USERNAME/home_care.git
```

---

## ✅ Success Checklist

After completing all steps:

- [ ] Repository created on GitHub
- [ ] Code pushed successfully
- [ ] README displays correctly
- [ ] All team members added as collaborators
- [ ] Team members received invitations
- [ ] Firebase files shared with team
- [ ] COLLABORATION_GUIDE.md shared with team
- [ ] Team knows how to clone and setup

---

## 📞 Next Steps

1. **Monitor Pull Requests** - Review team members' code
2. **Set Up Branch Protection** (Optional) - Require reviews before merging
3. **Create Issues** - Track bugs and features
4. **Use Projects** - Organize tasks

---

## 🎉 You're Done!

Your project is now on GitHub and your team can collaborate!

**Repository URL**: https://github.com/YOUR_USERNAME/home_care

Share this URL with your team and the collaboration guides.

---

**Good luck with your project! 🚀**

*Bishop Stuart University - BIT Year 3*
