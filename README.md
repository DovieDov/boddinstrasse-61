# Boddinstrasse 61 – Hausabstimmung 2027

Informal voting site for the owners of Boddinstrasse 61: 2027 initiatives with estimated costs, live votes (no login), the 2026 cost sheet and a realistic 2027 budget.

- `index.html` – the whole site (German/English). Open it in a browser to try it.
- Votes are stored in the Supabase project **EMBER**, table `boddinstrasse_61`, through the `cast_vote` function. The page uses only the public (publishable) key; nobody can delete or edit votes directly.
- `supabase/boddinstrasse_61.sql` – the database setup (already applied to EMBER).
- `supabase/boddinstrasse_61_priority.sql` – adds the high/medium/low priority per initiative (a new table and function). Run it once in the EMBER SQL editor; until then the priority buttons stay hidden.
- `data/` – the 2026 bank data behind the cost figures. It stays on this computer only: it is listed in `.gitignore` and is never published (it contains payment names).

## Publish with GitHub Pages
1. In GitHub Desktop: File → Add Local Repository → choose this folder → "create a repository" → Publish repository (uncheck "Keep this code private", owner Xhibit-AI-DEV or your account).
2. On github.com open the repo → Settings → Pages → Source: "Deploy from a branch", Branch: `main`, folder `/ (root)` → Save.
3. After a minute the site is live at `https://<owner>.github.io/<repo>/`.
