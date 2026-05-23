HomeCare Project - Simple Setup Guide

Repository: https://github.com/mugume23/GROUP-8


PART 1: FIRST TIME SETUP (Do this once)

Step 1: Accept Invitation
- Check your email for GitHub invitation
- Click "Accept invitation"

Step 2: Install Software
- Install Git from https://git-scm.com/downloads
- Install Flutter from https://flutter.dev

Step 3: Download Project
Open terminal and type:

cd Desktop
git clone https://github.com/mugume23/GROUP-8.git
cd GROUP-8
flutter pub get

Step 4: Get Firebase Files
Contact Mwangye to get these 3 files:
- google-services.json (put in android/app/)
- GoogleService-Info.plist (put in ios/Runner/)
- firebase_options.dart (put in lib/)

Step 5: Test
flutter run -d chrome


PART 2: DAILY WORK (Do this every day)

Morning - Before you start working:
git pull origin main

Evening - After you finish working:
git add .
git commit -m "What you did today"
git push origin main


PART 3: COMMIT MESSAGES

Good examples:
git commit -m "Added parent dashboard"
git commit -m "Fixed chat screen bug"
git commit -m "Updated caregiver profile"

Bad examples:
git commit -m "changes"
git commit -m "update"


PART 4: IF YOU GET ERRORS

Error: "Your local changes would be overwritten"
Solution:
git stash
git pull origin main
git stash pop

Error: "Permission denied"
Solution: Make sure you accepted the GitHub invitation

Error: "Authentication failed"
Solution: Use Personal Access Token from https://github.com/settings/tokens


QUICK REFERENCE

Pull latest code:        git pull origin main
Check what changed:      git status
Save your work:          git add .
                        git commit -m "message"
                        git push origin main


That's it! Just remember:
1. Pull before you start
2. Push when you finish
3. Write clear commit messages

Contact Mwangye if you need help.
