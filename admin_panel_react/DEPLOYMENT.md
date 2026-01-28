# Deploying to Vercel

The Admin Panel is a standardized **Vite React** application, making it extremely easy to deploy on Vercel.

## Option 1: Deploy via GitHub (Recommended)
This method ensures that every time you `git push`, your site is automatically updated.

1.  **Push your code to GitHub**:
    Ensure your `admin_panel_react` folder is in a GitHub repository.

2.  **Log in to Vercel**:
    Go to [vercel.com](https://vercel.com) and sign in with GitHub.

3.  **Add New Project**:
    - Click **"Add New..."** > **"Project"**.
    - Import your Git repository.

4.  **Configure Project**:
    - **Framework Preset**: Vercel should auto-detect **Vite**.
    - **Root Directory**: Click "Edit" and select `admin_panel_react` (since your project is in a subfolder).

5.  **Environment Variables** (Critical!):
    - Expand the **"Environment Variables"** section.
    - Add the keys from your `.env` file:
        - `VITE_SUPABASE_URL`: (Paste your URL)
        - `VITE_SUPABASE_ANON_KEY`: (Paste your Key)

6.  **Deploy**:
    - Click **Deploy**. Vercel will build your site and give you a live URL (e.g., `community-health-admin.vercel.app`).

---

## Option 2: Deploy via CLI
If you don't want to use Git integration or want to test quickly.

1.  **Install Vercel CLI**:
    ```bash
    npm i -g vercel
    ```

2.  **Login**:
    ```bash
    vercel login
    ```

3.  **Deploy**:
    Navigate to the admin folder and run:
    ```bash
    cd admin_panel_react
    vercel
    ```
    - Follow the prompts (Select Scope, Link to Project: No, etc.).
    - When asked `? Want to modify these settings?`, say **No** (Defaults are usually correct).

4.  **Set Environment Variables**:
    Go to the Vercel Dashboard for your new project > Settings > Environment Variables and add the secrets there.

5.  **Production Deploy**:
    ```bash
    vercel --prod
    ```

## ⚠️ Important Note on SPA Routing
Since this is a Single Page Application (SPA), we need to ensure all routes redirect to `index.html`. Vercel handles this automatically for Vite, but if you face 404 errors on refresh, create a `vercel.json` in `admin_panel_react/`:

```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```
