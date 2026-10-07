# Onboarding survey

Mobile-first kickoff survey for new customers, with an `/admin` page where the team creates
a magic link per customer and watches the answers come in. Static HTML, no build step.
Data lives in Supabase.

## Run it on your own Vercel

1. Fork this repo on GitHub.
2. Create a Supabase project at supabase.com (free tier is fine).
3. In the Supabase dashboard open SQL Editor, paste `supabase/migrations/20261006000000_init.sql`, run it.
4. Project Settings, then API: copy the Project URL and the `anon` public key into `config.js`.
5. Authentication, then Providers, then Email: turn off "Allow new users to sign up".
6. Authentication, then Users: Add user for each admin (email + password). Only these people can open `/admin`.
7. Authentication, then URL Configuration: set Site URL to your Vercel URL and add `https://<your-domain>/admin` to Redirect URLs (needed for password reset emails).
8. Commit `config.js`, push.
9. In Vercel: Add New Project, import your fork, Framework Preset "Other", no build command, deploy.

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
