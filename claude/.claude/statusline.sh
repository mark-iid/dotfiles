#!/bin/bash
input=$(cat)

model=$(jq -r '.model.display_name // "?"' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // 0' <<<"$input")
dir=$(jq -r ".workspace.current_dir // """ <<<"$input"); dir=${dir##*/}

h5=$(jq -r '.rate_limits.five_hour.used_percentage // 0' <<<"$input")
h5r=$(jq -r '.rate_limits.five_hour.resets_at // 0' <<<"$input")
d7=$(jq -r '.rate_limits.seven_day.used_percentage // 0' <<<"$input")

now=$(date +%s)
rem=$(( h5r - now ))
(( rem < 0 )) && rem=0
eta=$(printf '%dh%02dm' $(( rem / 3600 )) $(( rem % 3600 / 60 )))

if   (( h5 >= 90 )); then c=red
elif (( h5 >= 70 )); then c=colour208
elif (( h5 >= 50 )); then c=yellow
else                      c=green
fi

printf '#[fg=%s]5h %d%%#[default] (%s) | 7d %d%%' "$c" "$h5" "$eta" "$d7" \
  > /tmp/cc-limits.txt

printf '%s | %s | ctx %.0f%%' "$model" "$dir" "$ctx"
