# Ethiopian Material Price Directory — Phase 1

Supplier signup/login + schema foundation. RLS is ON but has **zero policies**
right now — that's intentional (default-deny), per spec. Phase 2 adds policies.

## What's in this phase

- `supabase/migrations/0001_phase1_schema.sql` — creates `profiles`, `listings`,
  `listing_price_history`, enables RLS on all three with no policies attached,
  and adds a trigger that auto-creates a `profiles` row on signup (needed so
  `is_admin` checks in later phases have something to check against).
- React + Vite frontend with Supabase Auth: `/signup`, `/login`, and a
  protected `/` home page that just proves you're logged in.

## Setup

1. Create a Supabase project at supabase.com if you don't have one yet.
2. In the Supabase SQL Editor, run `supabase/migrations/0001_phase1_schema.sql`.
3. Copy `.env.example` to `.env` and fill in your project's URL + anon key
   (Project Settings → API).
4. Install and run:
   ```bash
   npm install
   npm run dev
   ```
5. By default Supabase requires email confirmation for new signups. For fast
   local testing you can turn this off: Authentication → Providers → Email →
   disable "Confirm email". (Turn it back on before going live.)

## What to actually test for Phase 1 sign-off

Run through this and report back what happened at each step — not just "it worked":

1. **Tables exist with the right columns.** In Supabase Table Editor, confirm:
   - `profiles`: `id`, `is_admin`, `created_at`
   - `listings`: `id`, `supplier_id`, `material_name`, `unit`, `price`,
     `location`, `status`, `created_at`, `updated_at`
   - `listing_price_history`: `id`, `listing_id`, `old_price`, `old_unit`,
     `old_location`, `changed_at`
2. **RLS is on, no policies yet.** In Table Editor, each table should show
   the RLS shield icon as enabled. Table Editor → Policies tab → should be empty
   for all three.
3. **Signup works end to end.** Go to `/signup`, create an account, confirm
   (or skip confirmation if disabled per step 5 above), and land on `/`.
4. **A profiles row was auto-created.** Check the `profiles` table in Supabase
   — a row with your new user's `id` and `is_admin = false` should exist.
   (The app's home page will say "not loaded yet" even though the row exists
   — that's expected, since there's no SELECT policy until Phase 2. Confirm
   the row exists by looking directly in Table Editor, not through the app.)
5. **Login works end to end.** Log out, then log back in with the same
   credentials, and confirm you land on `/` again.

## Known Phase-1-only limitations (by design, not bugs)

- The home page can't actually display your profile — no RLS policy allows
  reading it yet. That's correct; it comes in Phase 2.
- There's no dashboard, no listing form, no admin view. Those are Phases 3–4.
- `listings` and `listing_price_history` are currently unreachable from the
  client entirely (zero policies = default deny), which is exactly what the
  spec asked for at this stage.
