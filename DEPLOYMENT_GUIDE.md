# GitHub Pages Deployment Guide

## Quick Start (For Your Repository)

Your repository: `RajInternational/quran_encyclopedia_admin`

### Step 1: Build the Web App

Run this command in PowerShell:

```powershell
flutter build web --base-href "/quran_encyclopedia_admin/"
```

### Step 2: Deploy Using One of These Methods

#### Method A: Using `gh-pages` Branch (Recommended)

```powershell
# Create orphan branch
git checkout --orphan gh-pages

# Remove all files
git rm -rf .

# Copy build files to root
Copy-Item -Path build\web\* -Destination . -Recurse -Force

# Add and commit
git add .
git commit -m "Deploy to GitHub Pages"

# Push to GitHub
git push origin gh-pages

# Switch back to main branch
git checkout main
```

#### Method B: Using `docs` Folder (Simpler)

```powershell
# Copy build to docs folder
Copy-Item -Path build\web -Destination docs -Recurse -Force

# Add, commit and push
git add docs
git commit -m "Deploy to GitHub Pages"
git push origin main
```

### Step 3: Configure GitHub Pages

1. Go to: https://github.com/RajInternational/quran_encyclopedia_admin/settings/pages
2. Under **Source**, select:
   - **Method A**: Branch `gh-pages` / `(root)`
   - **Method B**: Branch `main` / `docs`
3. Click **Save**

### Step 4: Access Your App

Your app will be available at:
**https://rajinternational.github.io/quran_encyclopedia_admin/**

Wait 2-5 minutes for GitHub Pages to build and deploy.

---

## Automated Deployment Script

You can also use the PowerShell script:

```powershell
.\deploy.ps1 quran_encyclopedia_admin
```

This will build the app and show you the next steps.

---

## Troubleshooting

### If the app doesn't load:
1. Check the base-href matches your repo name
2. Wait a few minutes for GitHub Pages to build
3. Check the Actions tab for deployment status
4. Clear browser cache and try again

### If you see a 404:
- Make sure the base-href in the build command matches your repository name exactly
- Check that all files were copied correctly

### To update the deployment:
Just rebuild and push again:
```powershell
flutter build web --base-href "/quran_encyclopedia_admin/"
# Then follow Method A or B again
```







