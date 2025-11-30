# Quick Deploy Script for GitHub Pages
# Run in PowerShell or Cursor terminal: .\deploy.ps1

$REPO_NAME = "quran_encyclopedia_admin"

Write-Host "Starting deployment to GitHub Pages..." -ForegroundColor Green
Write-Host ""

# Step 1: Build
Write-Host "Building Flutter web app..." -ForegroundColor Cyan
flutter build web --base-href "/$REPO_NAME/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build completed!" -ForegroundColor Green
Write-Host ""

# Step 2: Copy to docs (correct way)
Write-Host "Copying build files to docs folder..." -ForegroundColor Cyan

# Remove docs folder if exists
if (Test-Path "docs") {
    Remove-Item -Recurse -Force "docs"
}

# Create fresh docs folder
New-Item -ItemType Directory -Path "docs" | Out-Null

# Copy only the content of build/web into docs
Copy-Item -Path "build\web\*" -Destination "docs" -Recurse -Force

Write-Host "Files copied successfully!" -ForegroundColor Green
Write-Host ""

# Step 3: Git instructions
Write-Host "Ready to push changes to GitHub." -ForegroundColor Cyan
Write-Host ""
Write-Host "Run the following commands:" -ForegroundColor Yellow
Write-Host "  git add docs"
Write-Host "  git commit -m 'Deploy to GitHub Pages'"
Write-Host "  git push origin main"
Write-Host ""
Write-Host "Ensure GitHub Pages is set to:" -ForegroundColor Yellow
Write-Host "  Branch: main"
Write-Host "  Folder: /docs"
Write-Host ""
Write-Host "Your site will be available at:" -ForegroundColor Green
Write-Host "  https://rajinternational.github.io/$REPO_NAME/"
