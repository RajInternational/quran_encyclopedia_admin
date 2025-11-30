# Quick Deploy Script for GitHub Pages
# Run this in Cursor terminal: .\deploy.ps1

$REPO_NAME = "quran_encyclopedia_admin"

Write-Host "🚀 Starting deployment to GitHub Pages..." -ForegroundColor Green
Write-Host ""

# Step 1: Build
Write-Host "📦 Building Flutter web app..." -ForegroundColor Cyan
flutter build web --base-href "/$REPO_NAME/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build completed!" -ForegroundColor Green
Write-Host ""

# Step 2: Copy to docs
Write-Host "📁 Copying build files to docs folder..." -ForegroundColor Cyan
if (Test-Path "docs") {
    Remove-Item -Path "docs" -Recurse -Force
}
Copy-Item -Path "build\web" -Destination "docs" -Recurse -Force

Write-Host "✅ Files copied!" -ForegroundColor Green
Write-Host ""

# Step 3: Git operations
Write-Host "📤 Preparing to push to GitHub..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Run these commands:" -ForegroundColor Yellow
Write-Host "  git add docs" -ForegroundColor White
Write-Host "  git commit -m 'Deploy to GitHub Pages'" -ForegroundColor White
Write-Host "  git push origin main" -ForegroundColor White
Write-Host ""
Write-Host "Then go to:" -ForegroundColor Yellow
Write-Host "  https://github.com/RajInternational/$REPO_NAME/settings/pages" -ForegroundColor Cyan
Write-Host ""
Write-Host "Select: Branch: main, Folder: /docs" -ForegroundColor Yellow
Write-Host ""
Write-Host "Your app will be at:" -ForegroundColor Green
Write-Host "  https://rajinternational.github.io/$REPO_NAME/" -ForegroundColor Cyan
