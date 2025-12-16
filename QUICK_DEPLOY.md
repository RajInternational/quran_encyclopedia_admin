# Quick Deploy Commands for Cursor

## One-Command Deploy (Easiest)

Just copy and paste this entire block into Cursor's terminal:

```powershell
flutter build web --base-href "/quran_encyclopedia_admin/" && Copy-Item -Path "build\web" -Destination "docs" -Recurse -Force && git add docs && git commit -m "Deploy to GitHub Pages" && git push origin main
```

## Step-by-Step Commands (Recommended)

Copy and run these commands one by one in Cursor terminal:

### 1. Build the app
```powershell
flutter build web --base-href "/quran_encyclopedia_admin/"
```

### 2. Copy to docs folder
```powershell
Copy-Item -Path "build\web" -Destination "docs" -Recurse -Force
```

### 3. Add to git
```powershell
git add docs
```

### 4. Commit
```powershell
git commit -m "Deploy to GitHub Pages"
```

### 5. Push to GitHub
```powershell
git push origin main
```

### 6. Configure GitHub Pages
1. Open: https://github.com/RajInternational/quran_encyclopedia_admin/settings/pages
2. Select: **Branch:** `main`, **Folder:** `/docs`
3. Click **Save**

### 7. Access your app
Wait 2-5 minutes, then visit:
**https://rajinternational.github.io/quran_encyclopedia_admin/**

---

## Using the Script

Or run the script:
```powershell
.\deploy.ps1
```

Then follow the instructions it shows.

---

## Update After Changes

To update your deployed app, just run steps 1-5 again!







