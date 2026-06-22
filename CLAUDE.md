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

- `_config.yml` — site-wide settings (title, bio blurb, social links, theme, plugin config). Edit here for the description shown under the name on the homepage.
- `_pages/` — top-level pages: `about.md` (homepage), `publications.md`, `teaching.md`, `projects.md`, `repositories.md`. Each declares `permalink:` and nav order in front matter. `cv.md` is a stub that redirects `/cv/` to the served PDF (see CV section below).
- `_bibliography/papers.bib` — **source of truth for publications.** Entries are filtered on `_pages/publications.md` by the `keywords` field (`published` vs. `working-paper`). Sorted by `year` descending.
- `_data/` — structured YAML: `coauthors.yml`, `venues.yml`, `repositories.yml`.
- `_news/` — short announcement posts shown on the homepage when `news: true`.
- `_projects/`, `_posts/` — collections for project cards and blog posts.
- `_includes/`, `_layouts/`, `_sass/` — theme internals. Avoid editing unless making a real layout change.
- `_plugins/` — custom Ruby plugins (`details.rb`, `external-posts.rb`, `hideCustomBibtex.rb`).
- `assets/` — images, PDFs, CSS, JS.

## Editing conventions

- **Adding a publication**: append a BibTeX entry to `_bibliography/papers.bib`. Set `keywords={published}` or `keywords={working-paper}` so it routes to the right section. Use `selected={true}` to surface it on the homepage. Include `year` (publications sort on it). Optional fields: `pdf`, `code`, `website`, `abstract`, `bibtex_show`.
- **Adding a news item**: drop a markdown file in `_news/` (e.g., `announcement_4.md`) following the existing front matter. Items render in date order.
- **Updating the CV**: the CV is **not** maintained in this repo. Its single source of truth is the dedicated, Overleaf-bridged repo [`Alessiobrini/Academic-CV-Alessio`](https://github.com/Alessiobrini/Academic-CV-Alessio) (`main.tex` + `resume.cls`, local checkout at `~/Academia/Academic-CV-Alessio/`). Edit there or on Overleaf. This site only serves the compiled PDF at `assets/pdf/cv_brini.pdf` (linked from a homepage social icon; `/cv/` redirects to it via the `_pages/cv.md` stub). To publish a new CV version, run `bin/refresh-cv-pdf.sh` (pulls the CV repo, compiles, copies the PDF here), then commit `assets/pdf/cv_brini.pdf`. Do not re-add a `cv-source/` folder — it was retired to avoid a duplicate `.tex` diverging from the canonical repo.
- **Updating the homepage bio**: edit `_pages/about.md` (prose) or `_config.yml` (the short description / contact lines under the name).

## Style

- American English throughout (already enforced by global instructions).
- Keep BibTeX entries deduplicated — same paper should not appear under both `published` and `working-paper`.
- Don't commit `_site/`, `Gemfile.lock`, or `vendor/` (already gitignored).

## Verifying changes

After non-trivial edits, run `bundle exec jekyll build --trace` locally before pushing — the Actions workflow will fail the deploy if the build breaks. For visual changes, also `serve` locally and check the affected pages in a browser.
