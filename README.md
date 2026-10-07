# Onboarding survey

Mobile-first kickoff survey for new customers, with an `/admin` page where the team creates
a magic link per customer and watches the answers come in. Static HTML, no build step.
Data lives in Supabase. Vercel runs a small packaging command to copy the public app
files into `dist/`; there are no npm dependencies.

## Shared GitHub → Vercel deployment

Use one shared Vercel project connected to
[bookedbuilders/brokery-onboarding](https://github.com/bookedbuilders/brokery-onboarding).
Both developers can work on their own computers; deployment runs in Vercel.

1. In Vercel, choose the team that should own the app, then **Add New → Project**.
2. Import `bookedbuilders/brokery-onboarding`. If it is missing, authorize the
   Vercel GitHub integration for that repository.
3. Use the repository root (`.`), Framework Preset **Other**, Build Command
   `npm run build`, and Output Directory `dist`. These settings are recorded in
   `vercel.json`. No environment variables are needed for the current frontend;
   `config.js` already contains its public Supabase configuration.
4. Deploy, then check that **Settings → Git** uses `main` as the production branch.
5. Give your teammate appropriate GitHub repository and Vercel project/team access.
   Each person should connect their own GitHub account to Vercel and use a Git
   commit email associated with that account. Do not share login credentials.
6. Configure Supabase redirects as described below, using the final production URL.

After connection, pushes to feature branches get preview deployments. Merging into
`main` deploys production. Your teammate does not need to create another Vercel
project or install the Vercel CLI for this workflow.

Vercel access and plan requirements depend on repository visibility and team setup;
see [Vercel Git deployments](https://vercel.com/docs/git). Private GitHub organization
repositories cannot use Vercel Hobby's Git integration.

### Supabase after the first deployment

The existing app already points to a shared Supabase project. Hosting the frontend
does not require creating another database or rerunning its migrations.

In Supabase **Authentication → URL Configuration**:

- Set **Site URL** to the production origin, for example `https://your-app.vercel.app`.
- Add `https://your-app.vercel.app/admin` to **Redirect URLs**, plus the matching
  `/admin/` URL if used. Keep `http://localhost:3093/admin/` for local work.
- Add exact preview admin URLs only when you need email authentication on a preview.

Keep `[auth].site_url` and `[auth].additional_redirect_urls` in
`supabase/config.toml` aligned with those values before any future
`supabase config push`. The current values are local placeholders; do not push
the local config over production without reviewing it.

Then verify admin sign-in, a password-reset link, and a disposable customer survey
from the production domain. Create customer links from production `/admin` so they
use the stable live domain. Local and preview builds currently use the same database
as production; use a separate Supabase project for isolated testing.

### Teammate workflow

Prerequisites: Git, Node.js (22 or newer), and Python 3 for the local preview.

```sh
git clone https://github.com/bookedbuilders/brokery-onboarding.git
cd brokery-onboarding
git switch -c feature/your-change
npm run dev
```

Open `http://localhost:3093/admin/`. After editing, run:

```sh
npm run build
git add <files-you-changed>
git commit -m "Describe your change"
git push -u origin feature/your-change
```

Open a pull request on GitHub, review its Vercel preview, and merge to `main` when
ready. Run `git switch main` and `git pull --ff-only` before starting the next branch.
If adding images, stylesheets, or other public assets, add them to the allowlist in
`scripts/build.mjs` so they are included in deployment. `dist/` is generated and ignored.

Optional manual deployment from either computer (with project access):

```sh
npx vercel login
npx vercel link
npx vercel
# Deploy production only when ready:
npx vercel --prod
```

When linking, select the existing shared team and project. `.vercel/` stays local
and is intentionally gitignored.

## Set up an independent copy with a new database

1. Fork this repo on GitHub.
2. Create a Supabase project at supabase.com (free tier is fine).
3. In the Supabase dashboard open SQL Editor, paste `supabase/migrations/20261006000000_init.sql`, run it.
4. Project Settings, then API: copy the Project URL and the `anon` public key into `config.js`.
5. Authentication, then Providers, then Email: turn off "Allow new users to sign up".
6. Authentication, then Users: Add user for each admin (email + password). Only these people can open `/admin`.
7. Authentication, then URL Configuration: set Site URL to your Vercel URL and add `https://<your-domain>/admin` to Redirect URLs (needed for password reset emails).
8. Commit `config.js`, push.
9. In Vercel: Add New Project, import your fork, Framework Preset "Other", build command `npm run build`, output directory `dist`, deploy.

Every push to `main` redeploys. Local preview: `python3 -m http.server 3093` in the folder, then open http://localhost:3093/admin/.

## How it works

- `/admin`: sign in, create an onboarding (business, contact, what you found: Facebook, Instagram, website, domain host, legal name, address, phone). You get a link like `https://<your-domain>/?t=<token>`.
- The customer opens the link. Each screen's answer saves the moment they tap Next. They can close the tab and come back.
- `/admin` shows progress per customer, and every saved answer. Blank prefills become questions.

## Security

- The `anon` key in `config.js` is public by design. The `onboardings` table is closed to it; customers reach only their own row through three token-gated database functions.
- Admins are Supabase Auth users. With sign-ups off, nobody else can get in.
- Pages are `noindex,nofollow`.

See `HANDOFF.md` for the screen-by-screen flow and copy rules.
