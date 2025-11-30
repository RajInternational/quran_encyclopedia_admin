# Flutter Web App Deployment Script for GitHub Pages (PowerShell)
# Usage: .\deploy.ps1 YOUR_REPO_NAME

param(
    [string]$RepoName = "quran_encyclopedia_admin"
)

Write-Host "Building Flutter web app for GitHub Pages..." -ForegroundColor Green
Write-Host "Repository name: $RepoName" -ForegroundColor Cyan

# Build the web app with the correct base href
flutter build web --base-href "/$RepoName/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Choose one of these deployment methods:"
Write-Host ""
Write-Host "   Option A - Using gh-pages branch:" -ForegroundColor Cyan
Write-Host "   git checkout --orphan gh-pages"
Write-Host "   git rm -rf ."
Write-Host "   Copy-Item -Path build\web\* -Destination . -Recurse -Force"
Write-Host "   git add ."
Write-Host "   git commit -m 'Deploy to GitHub Pages'"
Write-Host "   git push origin gh-pages"
Write-Host ""
Write-Host "   Option B - Using docs folder:" -ForegroundColor Cyan
Write-Host "   Copy-Item -Path build\web -Destination docs -Recurse -Force"
Write-Host "   git add docs"
Write-Host "   git commit -m 'Deploy to GitHub Pages'"
Write-Host "   git push origin main"
Write-Host ""
Write-Host "2. Go to GitHub repository Settings > Pages" -ForegroundColor Yellow
Write-Host "3. Select the source (gh-pages branch or docs folder)" -ForegroundColor Yellow
Write-Host "4. Your app will be available at:" -ForegroundColor Yellow
Write-Host "   https://YOUR_USERNAME.github.io/$RepoName/" -ForegroundColor Green

