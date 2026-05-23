# Git Quick Reference Card

## 🚀 Essential Commands

### First Time Setup
```bash
git clone https://github.com/YOUR_USERNAME/home_care.git
cd home_care
flutter pub get
```

### Daily Workflow
```bash
# 1. Start of day - Get latest changes
git pull origin main

# 2. Make your changes...

# 3. Check what changed
git status

# 4. Add changes
git add .

# 5. Commit with message
git commit -m "Add: Your feature description"

# 6. Push to GitHub
git push origin main
```

---

## 📝 Commit Message Format

```bash
git commit -m "Add: New feature"
git commit -m "Fix: Bug description"
git commit -m "Update: Modified feature"
git commit -m "Remove: Deleted feature"
```

---

## 🔄 Common Scenarios

### Scenario 1: Pull Latest Changes
```bash
git pull origin main
```

### Scenario 2: Save Your Work
```bash
git add .
git commit -m "Your message"
git push origin main
```

### Scenario 3: Undo Last Commit (Keep Changes)
```bash
git reset --soft HEAD~1
```

### Scenario 4: Discard All Local Changes
```bash
git reset --hard HEAD
```

### Scenario 5: See What Changed
```bash
git status
git diff
```

### Scenario 6: See Commit History
```bash
git log
git log --oneline
```

---

## 🚨 Emergency Commands

### "I messed up, start over!"
```bash
git reset --hard HEAD
git pull origin main
```

### "I have conflicts!"
```bash
git pull origin main
# Fix conflicts in files
git add .
git commit -m "Resolve: Merge conflicts"
git push origin main
```

### "I need to save work but not commit"
```bash
git stash
# Do other work
git stash pop
```

---

## 🌿 Branch Commands (Optional)

```bash
# Create new branch
git checkout -b feature/my-feature

# Switch to main
git checkout main

# See all branches
git branch

# Delete branch
git branch -d feature/my-feature
```

---

## ✅ Before You Leave

```bash
git status          # Check if you have uncommitted changes
git add .           # Add all changes
git commit -m "..."  # Commit with message
git push origin main # Push to GitHub
```

---

## 🆘 Help Commands

```bash
git status          # What's happening?
git log             # What was done?
git remote -v       # Where am I pushing?
git branch          # What branch am I on?
```

---

## 📞 When Stuck

1. Check status: `git status`
2. Pull latest: `git pull origin main`
3. Ask team for help
4. Google the error message

---

## 🎯 Golden Rules

1. **ALWAYS** pull before starting work
2. **ALWAYS** test before pushing
3. **NEVER** push broken code
4. **NEVER** commit Firebase files
5. Commit often, push daily

---

**Print this and keep it handy! 📌**
