---
description: Deploy updates to GitHub
---

# Deploy to GitHub Workflow

This workflow helps you deploy updates to your GitHub repository.

## Prerequisites
- Git installed on your system
- GitHub repository URL
- GitHub account with push access

## Steps

### 1. Check git status
```bash
git status
```

### 2. Add all changes
```bash
git add .
```

### 3. Commit changes
```bash
git commit -m "Update: [describe your changes]"
```

### 4. Push to GitHub
// turbo
```bash
git push origin main
```

## First-time Setup (if not already done)

If this is your first deployment:

### 1. Initialize git repository
```bash
git init
```

### 2. Add remote repository
```bash
git remote add origin [YOUR_GITHUB_REPO_URL]
```

### 3. Create initial commit
```bash
git add .
git commit -m "Initial commit"
```

### 4. Push to GitHub
```bash
git branch -M main
git push -u origin main
```

## Notes
- Make sure to replace `[YOUR_GITHUB_REPO_URL]` with your actual GitHub repository URL
- Use descriptive commit messages to track changes
- Pull before pushing if working with others: `git pull origin main`
