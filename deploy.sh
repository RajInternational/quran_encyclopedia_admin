#!/bin/bash

# Flutter Web App Deployment Script for GitHub Pages
# Usage: ./deploy.sh YOUR_REPO_NAME

REPO_NAME=${1:-quran_encyclopedia_admin}

echo "Building Flutter web app for GitHub Pages..."
echo "Repository name: $REPO_NAME"

# Build the web app with the correct base href
flutter build web --base-href "/$REPO_NAME/"

if [ $? -ne 0 ]; then
    echo "Build failed! Please check the errors above."
    exit 1
fi

echo ""
echo "Build completed successfully!"
echo ""
echo "Next steps:"
echo "1. Choose one of these deployment methods:"
echo ""
echo "   Option A - Using gh-pages branch:"
echo "   git checkout --orphan gh-pages"
echo "   git rm -rf ."
echo "   cp -r build/web/* ."
echo "   git add ."
echo "   git commit -m 'Deploy to GitHub Pages'"
echo "   git push origin gh-pages"
echo ""
echo "   Option B - Using docs folder:"
echo "   cp -r build/web docs"
echo "   git add docs"
echo "   git commit -m 'Deploy to GitHub Pages'"
echo "   git push origin main"
echo ""
echo "2. Go to GitHub repository Settings > Pages"
echo "3. Select the source (gh-pages branch or docs folder)"
echo "4. Your app will be available at:"
echo "   https://YOUR_USERNAME.github.io/$REPO_NAME/"






