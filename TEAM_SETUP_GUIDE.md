HomeCare Project - Team Setup and Collaboration Guide

Bishop Stuart University
Faculty of Applied Sciences and Technology
BIT Year 3 - Mobile Programming Applications

Project: HomeCare - Caregiver Matching Platform
Repository: https://github.com/mugume23/GROUP-8


INTRODUCTION

This document provides step-by-step instructions for team members to set up the HomeCare project on their local machines and collaborate effectively using Git and GitHub. Please follow these instructions carefully to ensure smooth collaboration throughout the development process.


SECTION 1: INITIAL SETUP

1.1 Prerequisites

Before you begin, ensure you have the following software installed on your computer:

- Git (download from https://git-scm.com/downloads)
- Flutter SDK (download from https://flutter.dev/docs/get-started/install)
- Visual Studio Code or Android Studio
- A GitHub account


1.2 Accepting the Collaboration Invitation

You will receive an email invitation to collaborate on the project. Follow these steps:

1. Open the invitation email from GitHub
2. Click on the "Accept invitation" button
3. You will be redirected to the project repository
4. Alternatively, visit https://github.com/mugume23/GROUP-8/invitations


1.3 Cloning the Repository

Open your terminal or command prompt and execute the following commands:

cd Desktop

git clone https://github.com/mugume23/GROUP-8.git

cd GROUP-8

This will download the entire project to your computer.


1.4 Installing Project Dependencies

After cloning the repository, install the required Flutter packages:

flutter pub get

Wait for the process to complete. This may take a few minutes depending on your internet connection.


1.5 Firebase Configuration

The Firebase configuration files are not included in the repository for security reasons. You must obtain these files from the project owner and place them in the correct locations:

Required files:
- google-services.json
- GoogleService-Info.plist
- firebase_options.dart

File placement:
- Place google-services.json in: android/app/
- Place GoogleService-Info.plist in: ios/Runner/
- Place firebase_options.dart in: lib/

Contact the project owner to receive these files via a secure channel.


1.6 Verifying the Setup

Test that everything is working correctly by running the application:

flutter run -d chrome

If the application launches successfully in your web browser, your setup is complete.


SECTION 2: DAILY WORKFLOW

2.1 Starting Your Work Day

Before making any changes to the code, always pull the latest updates from GitHub:

git pull origin main

This ensures you are working with the most recent version of the code and helps prevent conflicts.


2.2 Making Changes

Work on your assigned tasks as normal. Edit files, add features, fix bugs, etc. Save your work frequently using your code editor.


2.3 Checking Your Changes

Before committing your work, review what files you have modified:

git status

This command shows all files that have been changed, added, or deleted.


2.4 Staging Your Changes

Add your changes to the staging area:

git add .

This command stages all modified files. Alternatively, you can stage specific files:

git add path/to/specific/file.dart


2.5 Committing Your Changes

Create a commit with a descriptive message:

git commit -m "Brief description of what you changed"

Examples of good commit messages:
- "Add parent dashboard statistics feature"
- "Fix chat screen overflow issue"
- "Update caregiver profile layout"
- "Remove unused imports from auth service"

Examples of poor commit messages:
- "changes"
- "update"
- "fixed stuff"


2.6 Pushing Your Changes

Upload your commits to GitHub:

git push origin main

Your changes are now available to the entire team.


SECTION 3: HANDLING COMMON SITUATIONS

3.1 When Someone Else Has Pushed Changes

If you try to push and receive an error saying the remote has changes you don't have:

git pull origin main

Resolve any conflicts if they occur, then push again:

git push origin main


3.2 Resolving Merge Conflicts

If Git cannot automatically merge changes, you will see conflict markers in your files:

<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> main

To resolve:
1. Open the conflicted file
2. Decide which changes to keep
3. Remove the conflict markers
4. Save the file
5. Stage and commit the resolved file:

git add .
git commit -m "Resolve merge conflicts in filename"
git push origin main


3.3 Discarding Local Changes

If you want to discard all your local changes and start fresh:

git reset --hard HEAD
git pull origin main

Warning: This will permanently delete your uncommitted changes.


3.4 Temporarily Saving Changes

If you need to pull changes but have uncommitted work:

git stash

Pull the latest changes:

git pull origin main

Restore your work:

git stash pop


SECTION 4: BEST PRACTICES

4.1 Communication

- Inform the team before working on major features
- Coordinate when multiple people need to edit the same file
- Use the team communication channel for questions and updates


4.2 Code Quality

- Test your changes before committing
- Ensure the application runs without errors
- Follow the existing code style and conventions
- Write clear and descriptive commit messages


4.3 Commit Frequency

- Commit your work regularly, not just at the end of the day
- Each commit should represent a logical unit of work
- Push your commits at least once per day


4.4 Security

Never commit the following files:
- google-services.json
- GoogleService-Info.plist
- firebase_options.dart
- Any files containing passwords or API keys

These files are already listed in .gitignore and should not be uploaded to GitHub.


SECTION 5: USEFUL COMMANDS REFERENCE

View commit history:
git log

View commit history in compact format:
git log --oneline

See differences in files:
git diff

Undo last commit but keep changes:
git reset --soft HEAD~1

View remote repository information:
git remote -v

Check current branch:
git branch


SECTION 6: TROUBLESHOOTING

Problem: Permission denied when pushing
Solution: Verify you have accepted the collaboration invitation

Problem: Authentication failed
Solution: Use a Personal Access Token instead of your password
- Generate at https://github.com/settings/tokens
- Select "repo" scope
- Use the token as your password

Problem: Cannot find Firebase files
Solution: Contact the project owner to receive the configuration files

Problem: Flutter packages not installing
Solution: Run flutter clean then flutter pub get

Problem: Application not running
Solution: Ensure all Firebase files are in the correct locations


SECTION 7: PROJECT STRUCTURE

Understanding the project organization:

lib/
  main.dart - Application entry point
  models/ - Data models
  screens/ - User interface screens
    admin/ - Administrator screens
    auth/ - Authentication screens
    caregiver/ - Caregiver-specific screens
    parent/ - Parent-specific screens
    shared/ - Shared screens
  services/ - Business logic and API calls
  utils/ - Utility functions and theme
  widgets/ - Reusable UI components

android/ - Android platform configuration
ios/ - iOS platform configuration
assets/ - Images and other resources


SECTION 8: TEAM MEMBERS

Project Owner: Mwangye Arafat (23/BSU/BIT/1951)
Team Members:
- Amanya Davis (24/BSU/BIT/3148)
- Muhereza Allan Mugume (23/BSU/BIT4/156)
- Kateregga Naseem (23/BSU/BIT/2484)
- Tumuhimbise Justus (23/BSU/BIT/2631)


SECTION 9: SUPPORT

If you encounter any issues or have questions:

1. Check this document first
2. Review the error message carefully
3. Search for the error online
4. Ask in the team communication channel
5. Contact the project owner


CONCLUSION

Following these guidelines will ensure smooth collaboration and help maintain code quality throughout the project. Remember to pull before you start working, commit regularly with clear messages, and push your changes at the end of each work session.

Good luck with the project development.


Document Version: 1.0
Last Updated: May 2026
