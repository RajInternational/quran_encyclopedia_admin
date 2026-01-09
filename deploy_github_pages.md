# Deploy Flutter Web App to GitHub Pages

## Step 1: Build the Flutter Web App

Run this command to build the web app optimized for GitHub Pages:

```bash
flutter build web --base-href "/quran_encyclopedia_admin/"
```

**Note:** Replace `quran_encyclopedia_admin` with your actual GitHub repository name.

## Step 2: Create a Deployment Script

I'll create a script to automate the deployment process.

## Step 3: Push to GitHub Pages

### Option A: Using `gh-pages` branch (Recommended)

1. Build the app:
   ```bash
   flutter build web --base-href "/YOUR_REPO_NAME/"
   ```

2. Copy build files to a temporary location:
   ```bash
   # The build output is in build/web/
   ```

3. Create and switch to gh-pages branch:
   ```bash
   git checkout --orphan gh-pages
   git rm -rf .
   ```

4. Copy build/web contents to root:
   ```bash
   cp -r build/web/* .
   ```

5. Commit and push:
   ```bash
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin gh-pages
   ```

### Option B: Using `docs` folder

1. Build the app:
   ```bash
   flutter build web --base-href "/YOUR_REPO_NAME/"
   ```

2. Copy build/web to docs:
   ```bash
   cp -r build/web docs
   ```

3. Commit and push:
   ```bash
   git add docs
   git commit -m "Deploy to GitHub Pages"
   git push origin main
   ```

4. In GitHub repository settings:
   - Go to Settings > Pages
   - Source: Select "Deploy from a branch"
   - Branch: main, folder: /docs

## Step 4: Configure GitHub Pages

1. Go to your GitHub repository
2. Click on **Settings**
3. Scroll down to **Pages** section
4. Under **Source**, select:
   - **Branch:** `gh-pages` (if using Option A)
   - **Branch:** `main` / `docs` (if using Option B)
5. Click **Save**

Your app will be available at:
`https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`

## Important Notes:

- Replace `YOUR_REPO_NAME` with your actual repository name
- The base-href must match your repository name
- After deployment, wait a few minutes for GitHub Pages to build
- Check the Actions tab for deployment status















