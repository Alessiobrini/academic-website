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

## After editing the bib

1. Run a Jekyll build to confirm BibTeX parses: `bundle exec jekyll build` (Ruby path may need to be set — see CLAUDE.md). The `jekyll-scholar` plugin will error loudly on malformed entries.
2. Show the resulting Published / Working Papers section counts if helpful.
3. Don't commit unless the user asks.

## Notes

- Scholar's `pagesize=100` is enough for now; if the profile grows past 100, paginate with `cstart=100`.
- Scholar occasionally shows duplicate entries for the same paper with different author orderings — collapse them on title.
- BibTeX export from Scholar (the "Cite → BibTeX" popup) requires a session cookie and won't work via WebFetch. Use the title/authors/venue/year visible on the profile page and match the file's existing style.
- Volume/issue/pages may not be displayed on Scholar. If missing, stub the entry without those fields and tell the user what to fill in later, rather than guessing.
