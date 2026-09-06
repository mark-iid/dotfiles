#!/bin/bash
# Claude Code statusLine. Mirrors the [directory]/[git_branch]/[git_status]
# styling and symbols from ~/dotfiles/starship/.config/starship.toml (the
# source of truth is that file, not this comment — keep them in sync by
# hand if one changes), then appends a Claude-Code-only segment (model +
# context used) after a "│" separator, since starship has no
# equivalent for those. Starship's $cmd_duration/$python/$nodejs/$rust/$java
# modules are skipped: no session-level analogue in a statusLine call.
set -u
export GIT_OPTIONAL_LOCKS=0

input=$(cat)

model=$(jq -r '.model.display_name // "?"' <<<"$input")
ctx_used=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
# Both HOME and the incoming cwd may be expressed through different but
# equivalent paths (e.g. /home/mark is a symlink to /var/home/mark on
# ostree-style systems, and workspace.current_dir arrives already resolved
# to the physical path) — realpath both before any ~ substitution or
# repo-root comparison so a plain prefix match actually fires.
cwd=$(realpath -m "$cwd" 2>/dev/null || printf '%s' "$cwd")
home=$(realpath -m "$HOME" 2>/dev/null || printf '%s' "$HOME")

# Colors matching the styles in starship.toml.
BOLD_CYAN='\033[1;36m'
BOLD_PURPLE='\033[1;35m'
BOLD_YELLOW='\033[1;33m'
DIM='\033[2m'
RESET='\033[0m'

# --- [directory]: truncation_length = 4, truncate_to_repo = true ----------
dir_display="$cwd"
[[ "$dir_display" == "$home"* ]] && dir_display="~${dir_display#"$home"}"

repo_root=$(git --no-optional-locks -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
[[ -n "$repo_root" ]] && repo_root=$(realpath -m "$repo_root" 2>/dev/null || printf '%s' "$repo_root")
repo_depth=0
if [[ -n "$repo_root" ]]; then
  repo_display="$repo_root"
  [[ "$repo_display" == "$home"* ]] && repo_display="~${repo_display#"$home"}"
  IFS='/' read -ra _repo_parts <<<"$repo_display"
  repo_depth=${#_repo_parts[@]}
fi

IFS='/' read -ra _dir_parts <<<"$dir_display"
total_depth=${#_dir_parts[@]}

keep=4
(( repo_depth > keep )) && keep=$repo_depth
(( keep > total_depth )) && keep=$total_depth

if (( total_depth > keep )); then
  start=$(( total_depth - keep ))
  truncated=$(IFS='/'; echo "${_dir_parts[*]:$start}")
  dir_display="…/${truncated}"
fi

# --- [git_branch] (symbol " ", bold purple) + [git_status] (bold yellow) --
git_segment=""
if [[ -n "$repo_root" ]]; then
  branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
           git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    branch_symbol=" "  # same glyph as [git_branch].symbol in starship.toml
    git_segment="${BOLD_PURPLE}${branch_symbol}${branch}${RESET}"

    staged=$(git --no-optional-locks -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    modified=$(git --no-optional-locks -C "$cwd" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    untracked=$(git --no-optional-locks -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    ahead=0; behind=0
    if git --no-optional-locks -C "$cwd" rev-parse '@{upstream}' >/dev/null 2>&1; then
      read -r ahead behind < <(git --no-optional-locks -C "$cwd" rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
      ahead=${ahead:-0}; behind=${behind:-0}
    fi

    status=""
    (( modified  > 0 )) && status+="!${modified}"
    (( staged    > 0 )) && status+="✚${staged}"
    (( untracked > 0 )) && status+="?${untracked}"
    (( ahead     > 0 )) && status+="⇡${ahead}"
    (( behind    > 0 )) && status+="⇣${behind}"

    [[ -n "$status" ]] && git_segment+=" ${BOLD_YELLOW}${status}${RESET}"
  fi
fi

# --- Claude Code segment: model + context used, no starship analogue -----
cc_segment="$model"
[[ -n "$ctx_used" ]] && cc_segment+=" · ctx $(printf '%.0f' "$ctx_used")%"

line="${BOLD_CYAN}${dir_display}${RESET}"
[[ -n "$git_segment" ]] && line+="  ${git_segment}"
line+="  ${DIM}│${RESET}  ${cc_segment}"

printf '%b\n' "$line"

# --- tmux status bar side-channel (unrelated to the line above; feeds the
# tmux status bar on hosts running `claude` under tmux with Claude.ai
# subscription rate-limit usage) --------------------------------------------
h5=$(jq -r '.rate_limits.five_hour.used_percentage // 0' <<<"$input")
h5r=$(jq -r '.rate_limits.five_hour.resets_at // 0' <<<"$input")
d7=$(jq -r '.rate_limits.seven_day.used_percentage // 0' <<<"$input")

now=$(date +%s)
rem=$(( h5r - now ))
(( rem < 0 )) && rem=0
eta=$(printf '%dh%02dm' $(( rem / 3600 )) $(( rem % 3600 / 60 )))

if   (( $(printf '%.0f' "$h5") >= 90 )); then c=red
elif (( $(printf '%.0f' "$h5") >= 70 )); then c=colour208
elif (( $(printf '%.0f' "$h5") >= 50 )); then c=yellow
else                                          c=green
fi

printf '#[fg=%s]5h %d%%#[default] (%s) | 7d %d%%' "$c" "$h5" "$eta" "$d7" \
  > /tmp/cc-limits.txt
