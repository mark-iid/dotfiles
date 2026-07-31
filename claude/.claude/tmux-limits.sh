#!/bin/bash
f=/tmp/cc-limits.txt
[ -f "$f" ] || exit 0
mt=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null) || exit 0
[ $(( $(date +%s) - mt )) -lt 900 ] || exit 0
cat "$f"
