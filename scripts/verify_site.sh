#!/usr/bin/env bash
# Confirms the published pages still carry the real business facts,
# the Netlify form, and the files those pages reference.
set -eu
cd "$(dirname "$0")/.."

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

html="index.html"
test -f "$html" || fail "missing index.html"
test -f netlify.toml || fail "missing netlify.toml"
test -f favicon.svg || fail "missing favicon"
test -f images/og.jpg || fail "missing og image"
test -f thanks.html || fail "missing thanks page"
test -f 404.html || fail "missing 404"

grep -q 'data-netlify="true"' "$html" || fail "Netlify form attribute"
grep -q 'name="estimate"' "$html" || fail "form name"
grep -q 'tel:2489782560' "$html" || fail "phone link"
grep -q 'mailto:genesworkllc@gmail.com' "$html" || fail "email link"
grep -q 'https://genesworkllc.com/' "$html" || fail "canonical"
grep -q 'Gene Kalis' "$html" || fail "owner name"
grep -q 'Kioti CK2620 HST' "$html" || fail "tractor"
grep -q 'KL4030C' "$html" || fail "loader"

for town in Howell Brighton Hartland Fowlerville Pinckney Milford "South Lyon" Highland; do
  grep -q "$town" "$html" || fail "missing town: $town"
done

for gear in "Box blade" "Landscape rake" "Rotary cutter" "Tiller" "Stump bucket"; do
  grep -q "$gear" "$html" || fail "missing equipment: $gear"
done

if grep -Eiq 'lawn prep|tearing up the yard|finished yards|tight residential|testimonial|mowing|landscaper|five-star|5-star' \
  index.html thanks.html 404.html css/styles.css; then
  fail "positioning or invented social proof slipped in"
fi

python3 - << 'PY'
import pathlib, re, sys
text = pathlib.Path("index.html").read_text()
keys = [
    "Brush hogging",
    "Dirt grading",
    "Gravel driveways",
    "Tilling gardens",
    "Brush cleanup",
    "Ditch work",
]
last = -1
for key in keys:
    found = text.find(key)
    if found < 0 or found < last:
        print(f"service order failed at {key!r} (index {found})")
        sys.exit(1)
    last = found
root = pathlib.Path(".")
missing = []
for page in ("index.html", "thanks.html", "404.html"):
    body = pathlib.Path(page).read_text()
    refs = re.findall(r'(?:src|href|imagesrcset|srcset)="([^"]+)"', body)
    expanded = []
    for raw in refs:
        for part in raw.split(","):
            token = part.strip().split(" ")[0]
            if token.startswith("/"):
                expanded.append(token)
    for src in expanded:
        if src.startswith("//"):
            continue
        # ignore in-page anchors and query strings
        path = src.split("#", 1)[0].split("?", 1)[0]
        if path in ("", "/"):
            continue
        if not (root / path.lstrip("/")).exists():
            missing.append(f"{page} -> {src}")
if missing:
    print("missing files:")
    print("\n".join(missing))
    sys.exit(1)
print("service order and asset paths ok")
PY

echo "Site checks passed."
