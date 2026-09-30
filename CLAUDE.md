# CLAUDE.md — academic-website

Personal academic site for Alessio Brini, served at https://alessiobrini.com.

## Stack

- **Jekyll** static site built on the [al-folio](https://github.com/alshedivat/al-folio) theme.
- **Ruby 3.3.5** (matches the GitHub Actions build).
- Key plugins: `jekyll-scholar` (publications from BibTeX), `jekyll-paginate-v2`, `jekyll-imagemagick`, `jekyll-minifier`, `jekyll-feed`, `jekyll-sitemap`. Full list in `Gemfile`.
- Hosted on **GitHub Pages**: pushes to `master` trigger `.github/workflows/deploy.yml`, which builds the site and publishes `_site/` to the `gh-pages` branch. `CNAME` pins the custom domain.

## Local development (macOS, native Ruby)

```bash
bundle install
bundle exec jekyll serve --livereload
```

Site serves at http://localhost:4000. Use `--trace` if a build error is opaque. `bundle exec jekyll build` produces `_site/` without serving.

If `imagemagick` or `webp` errors surface, install via Homebrew: `brew install imagemagick webp`.

The `bin/deploy` script is a legacy manual-deploy path — **do not run it**. Deploys happen automatically via the GitHub Action.

## Repository layout

- `_config.yml` — site-wide settings (title, social links, theme, plugin config). `description` is the default meta description that search engines and AI agents read (it is not displayed on any page), and the `person:` block holds the structured identity (job title, affiliation, alma mater, research topics, obfuscated contact) that feeds the Schema.org data and `/llms.txt`.
- `_pages/` — top-level pages: `about.md` (homepage), `publications.md`, `teaching.md`, `talks.md` (entries in `_data/talks.yml`). Each declares `permalink:` and nav order in front matter. `cv.md` is a stub that redirects `/cv/` to the served PDF (see CV section below). Only these four (plus the CV redirect) are live: al-folio's `projects.md`, `repositories.md`, `dropdown.md`, and the `_projects/` demo collection were deleted so no orphan URLs build. Do not re-add them.
- `_bibliography/papers.bib` — **source of truth for publications.** Entries are filtered on `_pages/publications.md` by the `keywords` field (`published` vs. `working-paper`). Sorted by `year` descending.
- `_data/` — structured YAML: `coauthors.yml`, `venues.yml`, `repositories.yml`.
- There is no blog and no news feed. al-folio's demo `_posts/`, `_news/`, `blog/index.html` and `news.html` were deleted because crawlers indexed the 2015 sample posts as Alessio's content. `blog_nav_title` must stay empty rather than `""`, since an empty string is truthy in Liquid and renders an invisible nav link to `/blog/`.
- `_includes/`, `_layouts/`, `_sass/` — theme internals. Avoid editing unless making a real layout change.
- `_plugins/` — custom Ruby plugins (`details.rb`, `external-posts.rb`, `hideCustomBibtex.rb`, `bib_data.rb`). `bib_data.rb` parses `papers.bib` into `site.data.papers` so templates outside jekyll-scholar can loop over the publications.
- `llms.txt`, `llms-full.txt` — plain-text summaries of the site for AI agents (llmstxt.org convention), built from `_includes/llms_body.txt` and `_includes/llms_papers.txt`. Publications come from `papers.bib` and talks from `_data/talks.yml`, so both files update themselves. `llms-full.txt` adds every abstract. Both must stay in the `jekyll-minifier` `exclude` list in `_config.yml`, because the minifier runs only when `JEKYLL_ENV=production` (as in CI) and treats a `.txt` page as HTML, which collapses it onto one line. Build with `JEKYLL_ENV=production` to check them.
- Schema.org JSON-LD lives in `_includes/metadata.html`: a `Person` on every page, and on `/publications/` one `ScholarlyArticle` per bib entry. Validate it after template edits by parsing every `<script type="application/ld+json">` block in `_site/` as JSON.
- `assets/` — images, PDFs, CSS, JS.
- `google237cce16d70f0f01.html` — Google Search Console ownership file (added 2026-09-29). Do not delete or edit it, or the property loses verification. It is excluded from the sitemap and from `jekyll-minifier` in `_config.yml` so it is served byte for byte.

## Editing conventions

- **Adding a publication**: append a BibTeX entry to `_bibliography/papers.bib`. Set `keywords={published}` or `keywords={working-paper}` so it routes to the right section. Use `selected={true}` to surface it on the homepage. Include `year` (publications sort on it). Optional fields: `pdf`, `code`, `website`, `abstract`, `bibtex_show`. Always add the `abstract` when one exists: it is hidden behind the Abs button but it is still in the HTML, the JSON-LD and `/llms-full.txt`, and it is the text agents match a research question against. Use the published abstract verbatim (Crossref or OpenAlex by DOI, arXiv for preprints) and escape `&`, `%` and `$` as `\&`, `\%` and `\$`. When the open indexes do not carry one (Elsevier withholds its abstracts), ask Alessio to paste it. `brini2022crypto`, the DAREC white paper, has no abstract by Alessio's choice (2026-09-29), so leave it without one.
- **Updating the CV**: the CV is **not** maintained in this repo. Its single source of truth is the dedicated, Overleaf-bridged repo [`Alessiobrini/Academic-CV-Alessio`](https://github.com/Alessiobrini/Academic-CV-Alessio) (`main.tex` + `resume.cls`, local checkout at `~/Academia/CV-Alessio/`). Edit there or on Overleaf. This site only serves the compiled PDF at `assets/pdf/cv_brini.pdf` (linked from a homepage social icon; `/cv/` redirects to it via the `_pages/cv.md` stub). To publish a new CV version, run `bin/refresh-cv-pdf.sh` (pulls the CV repo, compiles, copies the PDF here), then commit `assets/pdf/cv_brini.pdf`. Do not re-add a `cv-source/` folder — it was retired to avoid a duplicate `.tex` diverging from the canonical repo.
- **Updating the homepage bio**: edit `_pages/about.md` (prose). If the role, affiliation or research focus changes, also update `description` and the `person:` block in `_config.yml`, which feed the meta description, the JSON-LD and `/llms.txt`.
- **Page descriptions**: every page in `_pages/` should carry its own `description:` front matter. It becomes that page's meta description and JSON-LD description, and `page` layouts also show it as the subtitle.
- **Keeping the research profile in sync**: this site is the upstream source for Alessio's research profile at `~/.claude/research/` (agenda derives from `_pages/about.md`, collaborators from `_data/coauthors.yml`, and `publications.md` is reconciled against `_bibliography/papers.bib`). After editing the bio, adding a coauthor, or adding a paper here, run `/research-sync` and review `~/.claude/research/agenda.md` so the two do not drift.

## Style

- American English throughout (already enforced by global instructions).
- Keep BibTeX entries deduplicated — same paper should not appear under both `published` and `working-paper`.
- Don't commit `_site/`, `Gemfile.lock`, or `vendor/` (already gitignored).

## Search Console

The site is verified in Google Search Console (via `google237cce16d70f0f01.html`) and in Bing Webmaster Tools (imported from Search Console), with `sitemap.xml` submitted in both, all set up on 2026-09-29. Claude can read Search Console directly through a read-only service account, so checking it never needs Alessio to log in. Run `/opt/homebrew/opt/ruby/bin/ruby ~/.claude/tools/gsc/gsc.rb` with one of these subcommands, or with none to get all three:

- `sitemaps`: whether Google has downloaded the sitemap and how many URLs it found.
- `inspect [URL...]`: index status, last crawl time and Google's canonical URL for each page. With no URL it checks every page in the live sitemap. When a page is missing from Google, this gives the reason (unknown to Google, crawled but not indexed, redirected, blocked).
- `queries [DAYS]`: the top search queries and pages over the last DAYS (default 28), with clicks, impressions and average position. This shows which papers and topics people search for, which GoatCounter cannot tell.

Use it in three situations. A few days after pushing a content change, run `inspect` on the changed pages and confirm the last crawl postdates the push. When Alessio asks why a page or paper does not show up in Google, start from `inspect`. When Alessio asks how the site or the research is being found, run `queries`. Search analytics lag about two days, and the URL Inspection API allows 2,000 calls per day. Access setup, and how to replace the key, are in `~/.claude/tools/gsc/README.md`.

## Verifying changes

After non-trivial edits, run `bundle exec jekyll build --trace` locally before pushing — the Actions workflow will fail the deploy if the build breaks. For visual changes, also `serve` locally and check the affected pages in a browser.
