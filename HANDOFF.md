# Brokery Onboarding Survey: Handoff

Mobile-first onboarding survey for The Brokery (Tucker Blalock, Managing Broker). Collects system access and business details so we can set up paid ads, the recruiting CRM (GoHighLevel sub-account) and texting registration. One survey, many customers: each gets a magic link from `/admin`.

Built under DeNovo Brand Identity (Landon Nelson). Joe Harrington runs setup.

## Files

- `index.html`: the customer survey. Loads the customer's onboarding by the `?t=<token>` in their magic link, autosaves after every screen.
- `admin/index.html`: Joe and Landon sign in, create onboardings (prefills), copy magic links, view saved answers.
- `config.js`: Supabase URL and anon key (public by design).
- `supabase/migrations/`: schema. One table `onboardings`; customers reach their row only through three token-gated functions.
- `.claude/launch.json`: local dev server, port 3093.
- `HANDOFF.md`: this file.

## Backend (Supabase)

- Admins are Supabase Auth users (email + password, sign-ups disabled). Password set or reset by email link from the sign-in page.
- Customers never log in. `onboarding_load(token)`, `onboarding_save(...)`, `onboarding_submit(...)` are `security definer` RPCs; the table itself is closed to `anon`.
- Row: `prefill` (what admin typed), `raw` (survey state, for resume), `answers` (rendered, in screen order), `follow_up`, `progress`, `setup_call`, `submitted_at`.

## Tasks for Claude Code

1. Done: github.com/bookedbuilders/brokery-onboarding (public as verified October 7, 2026).
2. Vercel configuration is in `vercel.json`; `npm run build` packages the public files into `dist/`. Connect the existing GitHub repo to one shared Vercel project, then merge to `main` to deploy. See README for setup and teammate instructions. First hosted deployment still pending. Page has `noindex,nofollow`.
2b. Done: Supabase project "Brokery Onboarding" (ref qayaarhzznotvlttazxd, org Denovo MVP, free). Schema applied, sign-ups off, admins joe@ and landon@smileconvert.com created (temporary passwords in `.env`, gitignored). When the public host URL is known: set `site_url` and `additional_redirect_urls` in `supabase/config.toml`, run `supabase config push`.
3. Wire submissions (they currently go nowhere):
   - Create a GoHighLevel workflow with an **Inbound Webhook** trigger.
   - Paste its URL into `WEBHOOK_URL` in `index.html`.
   - Submit a test run and map the fields in GHL.
4. Done: `BOOKING_URL` removed.
5. Retest on a real phone.
6. First real onboarding (The Brokery) already exists in `/admin` with Tucker's prefills. Copy its link from there.

## Config (top of the `<script>`)

| Constant | Value | Notes |
|---|---|---|
| `META_EMAIL` | joe@smileconvert.com | Must match the email on Joe's Facebook login or the Meta invite fails |
| `INVITE_EMAIL` | joe@smileconvert.com | Cloudflare admin invite |
| `WEBHOOK_URL` | empty | Set to GHL inbound webhook |

## Submit payload (POST JSON)

```json
{
  "form": "The Brokery kickoff",
  "setup_call_availability": "Thursday after 2pm",
  "submitted_at": "ISO timestamp",
  "answers": { "Primary contact": "...", "Facebook Page": "Confirmed: ...", "...": "..." },
  "follow_up": ["Meta admin access", "EIN"]
}
```

`answers` keys are each question's `short` label. Values are prefixed "Confirmed:" or "Changed to:" for prefilled screens, "(skipped)" for blanks. `follow_up` lists anything not done.

## Flow

Welcome slide, then up to 15 questions, then a review checklist, then a thank-you page.

| # | Section | Screen | Type | Device | Notes |
|---|---|---|---|---|---|
| 1 | Primary contact | Is Tucker your primary contact? | primary | Phone | Optional "+ Add another primary contact" (name, title, email, phone) |
| 2 | Facebook and Instagram | Facebook Page | confirm | Phone | Prefilled facebook.com/TheBrokeryAZ |
| 3 | | Instagram | confirm | Phone | Prefilled @thebrokery |
| 4 | | Has Meta Business Manager? | choice, required | Phone | Yes / No / Not sure |
| 5 | | Who is the admin? | contact | Phone | Only if #4 = Yes. "It's me" checkbox |
| 6 | | Add Joe as admin in Meta | task, required | Computer | Only if #4 = Yes. Full access invite |
| 7 | Website | Website | confirm | Phone | Prefilled thebrokery.com |
| 8 | | Add Joe as admin in Cloudflare | task, required | Computer | Administrator role |
| 9 | Software | Brokerage CRM | choice, required | Phone | BoldTrail (kvCORE), Follow Up Boss, Lofty, Other, None, Not sure |
| 10 | | Who can add an admin login to CRM and BrokerMint? | contact | Phone | Login is for Joseph Harrington |
| 11 | Business details | Legal business name | confirm | Phone | Prefilled Bortlock, LLC dba The Brokery |
| 12 | | Business address | confirm | Phone | Prefilled 4546 N 40th St, Phoenix, AZ 85018 |
| 13 | | Business phone | confirm | Phone | Prefilled (602) 888-6375 |
| 14 | | Business email | text | Phone | |
| 15 | | EIN | text | Phone | For A2P 10DLC texting registration |

## UX rules (Joe's decisions, keep them)

- One question per screen. Footer pinned to the bottom: Back + Next only.
- Same title size and position on every screen.
- Every field stacked full width. Never put name, email and phone in one row.
- Prefilled answers are editable fields. Tap Next to accept, or type over to fix.
- Text/contact screens: button reads "Skip" when empty, "Next" once something is typed.
- Choice and task screens: Next stays disabled until an option is picked.
- Device pill in the top right: "Phone OK" (green) or "Computer" (orange). Legend explained on the welcome slide.
- Review checklist: green check = done, orange "Needs follow-up" or "On setup call". Tap a row to edit; Next returns to the checklist.
- Setup call card shows only when items are open. At 100% it collapses to an optional "Book an optional call" button.
- Thank-you page: "You're all set, Tucker." with a "Review answers" button. Resubmitting sends again.
- No em dashes in any copy.

## Prefill sources

- Legal name, license: Arizona Department of Real Estate, Bortlock, LLC dba The Brokery (LC693902000)
- Address, phone: public listings (Lantern, Poyst)
- Facebook, Instagram: Poyst
- Domain: registered at GoDaddy, DNS on Cloudflare (Verisign RDAP)

## Open items

- ADRE lists the designated broker as Timothy J. Menghini, not Tucker. A2P registration may need the authorized rep to be an owner or officer. Confirm Tucker qualifies.
- Even with every item done, Tucker still has to add the payment card to the new ad account. Joe creates the ad account once he has Meta admin.
- Joe's Facebook login email must be joe@smileconvert.com for the Meta invite. Verify.
- Brokerage CRM is a guess (BoldTrail). Confirm with Tucker.

## Out of scope for v1

Approvals, content workflow, SOPs, lead routing. Handled separately.
