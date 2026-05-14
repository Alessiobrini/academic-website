---
name: sync-scholar-papers
description: Compare Alessio Brini's Google Scholar profile against `_bibliography/papers.bib` on the academic-website repo and report which papers are missing. Use when the user says things like "check Scholar for new papers", "sync my Scholar publications", "any new papers to add from Scholar", "update papers.bib from Scholar", or "what's missing on my publications page". Optionally drafts BibTeX entries for missing papers and adds them to the bib file.
---

# Sync Google Scholar → academic-website publications

This skill keeps `_bibliography/papers.bib` in sync with Alessio Brini's Google Scholar profile. It fetches Scholar, diffs against the bib, applies a skip list, and proposes additions.

## When to use

Trigger phrases:
- "check Scholar for new papers"
- "sync my Scholar publications"
- "any new papers to add from Scholar"
- "what's missing on my publications page"
- "update papers.bib from Scholar"

## Inputs (in this order of preference)

1. **Scholar ID**: read from `_config.yml` → `scholar_userid:`. Current value is `thrQtBcAAAAJ`. If it 404s, search the web for "Alessio Brini Google Scholar Duke" and confirm the correct ID; if it changed, also fix `_config.yml`.
2. **Existing publications**: `_bibliography/papers.bib`.
3. **Skip list**: see memory entry `scholar_sync_skip_list.md` — never propose adding those entries.

## Steps

1. Read `_config.yml` to get `scholar_userid`.
2. Fetch `https://scholar.google.com/citations?user=<ID>&hl=en&cstart=0&pagesize=100` via WebFetch. Ask the model to return a numbered list of every entry as: `title | authors | venue exactly as shown | year`. Do not summarize.
3. If the page 404s, run a WebSearch for `Alessio Brini Google Scholar Duke FinTech` to find the correct ID, then retry. If the new ID differs from `_config.yml`, update it.
4. Read `_bibliography/papers.bib` and extract the `title={...}` field from every entry. Normalize for comparison: lowercase, strip punctuation and whitespace, collapse spaces.
5. For each Scholar entry, check whether a normalized-title match exists in the bib. Treat the same title with different author orderings as a single paper (Scholar sometimes shows duplicates).
6. Apply the skip list from [[scholar-sync-skip-list]] before reporting.
7. Present the diff to the user, grouped:
   - **Published — likely missing**: Scholar entries with a real journal/conference venue not in the bib.
   - **Working papers / preprints — likely missing**: Scholar entries with "arXiv", "SSRN", "Working paper", or institutional venues.
   - **Skipped per memory**: list them briefly so the user can confirm the skip list is still right.
8. If the user confirms additions, draft BibTeX entries using the same style as existing entries in `papers.bib`:
   - Citation key: `<lastauthor><year><shortslug>` lowercase (e.g., `brini2026ppo`).
   - For published papers: include `journal`, `year`, `publisher` if known; set `keywords = {published}`.
   - For preprints: use the actual venue as the journal (e.g., `arXiv preprint arXiv:XXXX.XXXXX`, `Available at SSRN <id>`); set `keywords = {working-paper}`.
   - Insert at the top of the file to maintain newest-first ordering (matches `publications.md` which sorts by `year` desc anyway, but in-file ordering is a nice-to-have).
   - Use `selected = {true}` only if the user asks.
   - **MUST populate a canonical URL** so the paper title on `/publications/` is clickable — see the URL resolution section below.

## URL field (REQUIRED on every new entry)

Each entry must resolve to a canonical URL that `_layouts/bib.html` reads in this priority order:

1. **`url = {…}`** — explicit override (use only when nothing else is appropriate, e.g., a personal landing page).
2. **`doi = {10.xxxx/yyyy}`** — for **all published papers**. Renders as `https://doi.org/<doi>`.
3. **`arxiv = {XXXX.XXXXX}`** — explicit arXiv ID. Renders as `https://arxiv.org/abs/<id>`.
4. **`ssrn = {NNNNNNN}`** — explicit SSRN ID. Renders as the SSRN abstract URL.
5. As a fallback the template parses `journal` for `arXiv:` or `SSRN` patterns. **Don't rely on this for new entries** — set the explicit field above so the URL is robust to journal-text edits.

### How to find the URL when drafting a new entry

- **Published paper (journal or proceedings)**: look up the DOI via Crossref. The reliable one-liner:
  ```bash
  python3 -c "import urllib.request,urllib.parse,json; q=urllib.parse.urlencode({'query.bibliographic':'<TITLE> <VENUE>','rows':3}); print(json.dumps(json.loads(urllib.request.urlopen('https://api.crossref.org/works?'+q,timeout=10).read()),indent=2))" | head -60
  ```
  Pick the result whose `container-title` matches the venue and whose `title` matches the paper. Add it as `doi = {10.…}`.
- **arXiv preprint**: the ID is visible in the Scholar venue (`arXiv preprint arXiv:XXXX.XXXXX`). Add `arxiv = {XXXX.XXXXX}`.
- **SSRN working paper**: the ID is in the Scholar venue (`Available at SSRN <id>`). Add `ssrn = {<id>}`.
- **ACM conference paper (ICAIF, etc.)**: Crossref returns the `10.1145/…` DOI.
- **Institutional working paper with no public landing page** (e.g., DAREC working papers): omit URL fields — the title renders as plain text. Don't fabricate a URL.

If Crossref returns multiple plausible matches, show them to the user and ask which is correct rather than guessing.

## Cover image / logo (`preview` field — REQUIRED on every new entry that has one available)

The left column on `/publications/` shows `entry.preview` (an image in `assets/img/publication_preview/`). Reuse the existing shared logos when applicable, and probe publisher CDNs for the journal cover otherwise. **Never fabricate a cover.** If you cannot find one, omit `preview` and the template renders an academicon fallback.

### Step 1 — reuse a shared logo if it applies

These are already in `assets/img/publication_preview/` and should be reused, not re-downloaded:

| Venue                                       | `preview` value |
| ------------------------------------------- | --------------- |
| arXiv preprint                              | `arxiv.jpg`     |
| SSRN working paper                          | `ssrn.png`      |
| ACM conference proceedings (ICAIF, etc.)    | `acm.svg`       |

Rationale for `acm.svg` on ACM proceedings: per-conference logos (e.g., ICAIF'24 vs ICAIF'25) change every year, so the stable ACM mark is preferred.

### Step 2 — reuse a per-journal cover already in the folder

Every journal we have a paper in already has a cover. Check `ls assets/img/publication_preview/` first. Current covers:

| Journal                                                    | `preview` value           |
| ---------------------------------------------------------- | ------------------------- |
| International Journal of Forecasting (IJF)                 | `ijf.jpg`                 |
| Economic Modelling                                         | `econ-modelling.jpg`      |
| Economics Letters                                          | `econ-letters.jpg`        |
| Journal of Financial Stability                             | `jfs.jpg`                 |
| Physica A: Statistical Mechanics and its Applications      | `physica-a.jpg`           |
| Soft Computing                                             | `soft-computing.jpg`      |
| Financial Innovation                                       | `financial-innovation.jpg`|
| The Journal of Financial Data Science (JFDS)               | `jfds.gif`                |

If the new paper is in one of these journals, reuse the existing file. Do not re-download.

### Step 3 — download a new cover for a new journal

When the paper is in a journal we haven't covered yet, fetch from the publisher's public CDN. These have worked reliably:

- **Elsevier (DOI prefix `10.1016`)**: `https://ars.els-cdn.com/content/image/X{ISSN_no_dash}.jpg`. Look up the ISSN on the journal's ScienceDirect landing page or Crossref.
- **Springer (DOI prefix `10.1007` or `10.1186`)**: `https://media.springernature.com/w400/springer-static/cover/journal/{journal_code}.jpg`. The numeric `journal_code` is the path on `link.springer.com/journal/{code}` for SpringerLink journals, or `40854` for `jfin-swufe.springeropen.com` style SpringerOpen journals (find it on the journal's landing page).
- **Portfolio Management Research / Institutional Investor Journals (DOI prefix `10.3905`)**: `https://www.pm-research.com/content/iij<abbrev>/<vol>/<iss>.cover.gif` (e.g., `iijjfds/8/2.cover.gif`). The page requires a browser User-Agent header — pass `-A "Mozilla/5.0 …"` to `curl`. Use the latest issue's vol/iss.
- **Other publishers**: probe the journal's homepage for an `<img>` whose src/href contains `cover` (`curl -sL '<journal-url>' | grep -oiE '<src|href>="[^"]*cover[^"]*"'`). If nothing is publicly served, omit `preview` and let the academicon fallback render — do not generate a fake cover.

Save under `assets/img/publication_preview/<slug>.<ext>` using a short kebab-case slug (e.g., `quant-finance.jpg`). Add it to this skill's reference table so future runs find it.

### After populating `preview`

The publisher-icon fallback in `bib.html` only renders when `preview` is absent. So if you set `preview = 'foo.jpg'`, the academicon and the DOI-prefix-derived publisher icon both disappear — the cover replaces them. That is intended.

## After editing the bib

1. Run a Jekyll build to confirm BibTeX parses: `bundle exec jekyll build` (Ruby path may need to be set — see CLAUDE.md). The `jekyll-scholar` plugin will error loudly on malformed entries.
2. Show the resulting Published / Working Papers section counts if helpful.
3. Don't commit unless the user asks.

## Notes

- Scholar's `pagesize=100` is enough for now; if the profile grows past 100, paginate with `cstart=100`.
- Scholar occasionally shows duplicate entries for the same paper with different author orderings — collapse them on title.
- BibTeX export from Scholar (the "Cite → BibTeX" popup) requires a session cookie and won't work via WebFetch. Use the title/authors/venue/year visible on the profile page and match the file's existing style.
- Volume/issue/pages may not be displayed on Scholar. If missing, stub the entry without those fields and tell the user what to fill in later, rather than guessing.
