#!/bin/bash
# Build the Slackware-style package and stamp its version + MD5 into intel-npu-stats.plg.
# Usage: bash build.sh [version]     (default version: today's date, YYYY.MM.DD)
set -euo pipefail
cd "$(dirname "$0")"

NAME=intel-npu-stats
VERSION=${1:-$(date +%Y.%m.%d)}
PKG="pkg/${NAME}-${VERSION}-x86_64-1.txz"

# Syntax-check PHP sources before packaging
for f in src/usr/local/emhttp/plugins/${NAME}/*.php src/usr/local/emhttp/plugins/${NAME}/*.page; do
  php -l "$f" >/dev/null
done

mkdir -p pkg
# Reproducible-ish archive: root ownership, fixed perms, sorted entries, fixed mtime
tar --owner=0 --group=0 --numeric-owner --sort=name \
    --mtime="${VERSION//./-} 00:00:00 UTC" \
    --mode='u=rwX,go=rX' \
    -C src -cJf "$PKG" .

MD5=$(md5sum "$PKG" | cut -d' ' -f1)

# Stamp version and checksum into the .plg
sed -i -E "s#(<!ENTITY version +\")[^\"]*(\">)#\1${VERSION}\2#; s#(<!ENTITY md5 +\")[^\"]*(\">)#\1${MD5}\2#" ${NAME}.plg
xmllint --noout ${NAME}.plg 2>/dev/null || python3 -c "import xml.dom.minidom,sys; xml.dom.minidom.parse('${NAME}.plg')"

echo "built:   $PKG"
echo "md5:     $MD5"
echo "version: $VERSION"
