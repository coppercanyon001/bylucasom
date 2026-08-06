#!/bin/zsh
# Generate web-optimized copies + manifest.json from the PORTFOLIO folder.
SRC="/Users/lucaso.m./Library/CloudStorage/GoogleDrive-lucas@afterschoolprogram.cc/My Drive/PHOTOS/PHOTOS/STREET PHOTOS/PORTFOLIO"
DEST="$HOME/street-portfolio/photos"
MANIFEST="$HOME/street-portfolio/manifest.json"

# Duplicates excluded from the site (kept in the source folder untouched)
# (list pruned 2026-08-05 after Lucas curated the folder himself)
EXCLUDE=(
  "Street-14 3.jpg"        # same frame as Beach.jpg
  "Street-5 6.jpg"         # byte-identical to Street-5 5.jpg
)

echo "[" > "$MANIFEST"
first=1
i=0
for f in "$SRC"/*.(jpg|JPG|jpeg|JPEG)(N); do
  i=$((i+1))
  base=$(basename "$f")
  if [[ ${EXCLUDE[(Ie)$base]} -gt 0 ]]; then continue; fi
  # slug: lowercase, spaces->-, strip extension
  slug=$(echo "${base%.*}" | tr 'A-Z ' 'a-z-' | tr -cd 'a-z0-9-')
  out="p$(printf %02d $i)-$slug.jpg"
  if [ ! -f "$DEST/full/$out" ]; then
    sips -s format jpeg -s formatOptions 80 -Z 2000 "$f" --out "$DEST/full/$out" >/dev/null 2>&1
  fi
  if [ ! -f "$DEST/thumb/$out" ]; then
    sips -s format jpeg -s formatOptions 75 -Z 800 "$f" --out "$DEST/thumb/$out" >/dev/null 2>&1
  fi
  w=$(sips -g pixelWidth "$DEST/full/$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$DEST/full/$out" 2>/dev/null | awk '/pixelHeight/{print $2}')
  [ -z "$w" ] && continue
  [ $first -eq 0 ] && echo "," >> "$MANIFEST"
  first=0
  printf '  {"file":"%s","src":"%s","w":%s,"h":%s}' "$base" "$out" "$w" "$h" >> "$MANIFEST"
done
echo "" >> "$MANIFEST"
echo "]" >> "$MANIFEST"
echo "Processed $i photos"
