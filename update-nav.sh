#!/usr/bin/env bash
set -e

SOURCE="index.html"

# Extract the <nav id="nav">...</nav> block from index.html
NAV_CONTENT=$(awk '
    /<nav[[:space:]]+id="nav"/ {inside=1}
    inside {print}
    /<\/nav>/ {inside=0}
' "$SOURCE")

if [[ -z "$NAV_CONTENT" ]]; then
  echo "Error: Could not find <nav id=\"nav\"> in $SOURCE"
  exit 1
fi

# Update all .html files except index.html
for f in *.html; do
  if [[ "$f" != "$SOURCE" ]]; then
    echo "Updating $f..."
    awk -v repl="$NAV_CONTENT" '
      BEGIN {inside=0}
      /<nav[[:space:]]+id="nav"/ {print repl; inside=1; next}
      /<\/nav>/ {inside=0; next}
      inside==0 {print}
    ' "$f" > "$f.new"
    mv "$f.new" "$f"
  fi
done

echo "Done."