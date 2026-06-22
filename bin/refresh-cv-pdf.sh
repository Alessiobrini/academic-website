#!/usr/bin/env bash
# Refresh the CV PDF served by the website from the canonical CV source.
#
# The CV source of truth is the dedicated, Overleaf-bridged repo
# Academic-CV-Alessio (NOT this website repo). This script pulls the latest
# source, compiles it, and copies the resulting PDF over the served artifact.
# After running, commit assets/pdf/cv_brini.pdf here to deploy.
#
# Usage: bin/refresh-cv-pdf.sh
set -euo pipefail

CV_REPO="${CV_REPO:-$HOME/Academia/Academic-CV-Alessio}"
SITE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST_PDF="$SITE_DIR/assets/pdf/cv_brini.pdf"

if [ ! -d "$CV_REPO/.git" ]; then
  echo "CV source repo not found at $CV_REPO" >&2
  echo "Clone it first: git clone git@github.com:Alessiobrini/Academic-CV-Alessio.git \"$CV_REPO\"" >&2
  exit 1
fi

echo "Pulling latest CV source from $CV_REPO ..."
git -C "$CV_REPO" pull --ff-only

echo "Compiling main.tex ..."
( cd "$CV_REPO" && latexmk -pdf -interaction=nonstopmode main.tex >/tmp/cv-refresh.log 2>&1 ) || {
  echo "Compile failed; see /tmp/cv-refresh.log" >&2
  exit 1
}

cp "$CV_REPO/main.pdf" "$DEST_PDF"
echo "Updated $DEST_PDF ($(stat -f%z "$DEST_PDF") bytes)."
echo "Now commit it:  git -C \"$SITE_DIR\" add assets/pdf/cv_brini.pdf && git -C \"$SITE_DIR\" commit -m 'Refresh CV PDF'"
