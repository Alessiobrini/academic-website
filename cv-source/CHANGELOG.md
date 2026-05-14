# CV changelog

Tracks edits to the LaTeX CV in this folder. Entries are newest-first.

**The `.tex` is the single source of truth.** The website does not render a structured CV any more — there is no `_data/cv.yml`, no `_pages/cv.md` content page, and no `_layouts/cv.html`. The CV is surfaced on the site only as a PDF: an icon in the homepage social-icons row links to `assets/pdf/cv_brini.pdf`. `alessiobrini.com/cv/` redirects to the same PDF for backward compatibility.

## How to update

1. Edit the `.tex` source.
2. Compile: `latexmk -pdf CV_Alessio_<date>.tex` (requires `resume.cls` in this folder).
3. Copy the resulting PDF over `../assets/pdf/cv_brini.pdf`.
4. Rename the `.tex` to the new date and remove or archive the old one.
5. Add a dated entry below summarizing what changed.
6. Commit and push — the GitHub Action redeploys; the homepage icon and `/cv/` redirect both pick up the new PDF automatically.

## Notes / open items

- **`resume.cls` is missing from this folder.** The template requires it (header comment in the `.tex` says so). Until it's added, the CV can't be recompiled here. Provide the file (likely from your prior Windows setup) so the toolchain is self-contained.
- **Scholar URL in the CV points to a stale ID** (`NHmzS7YAAAAJ`). The real profile is `thrQtBcAAAAJ`. Update the `\scholar{}` line on the next pass.

## History

### 2026-05-14
- Imported `CV_Alessio_11212025.tex` into version control under `cv-source/`.
- Added `resume.cls` (template dependency).
- Fixed stale Google Scholar URL in the `.tex` (`NHmzS7YAAAAJ` → `thrQtBcAAAAJ`).
- Recompiled with `latexmk -pdf`; replaced `assets/pdf/cv_brini.pdf` (5 pages, ~110 KB).
- **Retired the structured CV page on the website.** Removed `_data/cv.yml`, `_pages/cv.md` (content), `_layouts/cv.html`, and `_includes/cv/*`. Replaced `_pages/cv.md` with a tiny meta-refresh page that redirects `/cv/` to the PDF, so any external link to `alessiobrini.com/cv/` still works.
- Added a CV-download icon to the homepage social-icons row (`_includes/social.html`), gated on the new `cv_pdf` site setting in `_config.yml`.
- **Pending edit to the `.tex`** — move "On Deep Reinforcement Learning for Dynamic Trading with PPO" from Working Papers to Published Papers (Journal of Financial Data Science, 2026).
