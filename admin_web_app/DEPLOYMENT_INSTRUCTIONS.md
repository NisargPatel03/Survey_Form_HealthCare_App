# How to Deploy to Vercel

Since this is a Flutter Web App, we will deploy it as a "Static Site".

## Method 1: The Easiest Way (Drag & Drop)

1.  **Build the Project** (if you haven't already):
    *   Run `flutter build web --release` in the terminal.
    *   *OR* double-click the `build_web.bat` file I created.

2.  **Locate the Output**:
    *   Go to the folder: `admin_web_app\build\web`.
    *   This folder contains `index.html`, `main.dart.js`, etc.

3.  **Upload to Vercel**:
    *   Go to [vercel.com/new](https://vercel.com/new).
    *   Look for the section **"Import a Third-Party Git Repository"** -> **"Or click here to upload"**.
    *   **Drag and drop** the **entire `web` folder** (from step 2) into that area.
    *   Click **Deploy**.
    *   Done! Vercel will give you a live URL (e.g., `community-survey.vercel.app`).

---

## Method 2: Using Vercel CLI (Professional Way)

If you have Node.js installed:

1.  Open terminal in `admin_web_app`.
2.  Install Vercel CLI:
    ```bash
    npm install -g vercel
    ```
3.  Deploy:
    ```bash
    cd build/web
    vercel --prod
    ```
    *   Follow the prompts (keep pressing Enter).
