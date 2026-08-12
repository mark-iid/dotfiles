# kb3lyb .zshrc — portable across Linux (linuxbrew at /home/linuxbrew/.linuxbrew)
# and Apple Silicon macOS (brew at /opt/homebrew). No oh-my-zsh, no framework
# (DESIGN §1). brew plugins are sourced via $(brew --prefix), never a hardcoded
# path, so this same file works on both machines.

# --- Homebrew (locate on either platform) --------------------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
BREW_PREFIX="$(brew --prefix 2>/dev/null)"

# --- PATH ----------------------------------------------------------------------
# ~/.local/bin holds the scripts stowed from the dotfiles `bin` package
# (kb3lyb-backup, voice-dictate, voice-setup…) plus pip/pipx user installs.
# Fedora's /etc/profile.d only adds it for login bash and it does not reliably
# reach zsh here, which is why kb3lyb-bootstrap invokes voice-setup by absolute
# path with a comment about it not being on PATH. Adding it once here fixes the
# whole class rather than working around it per-caller.
#
# Guarded against re-sourcing: plain prepending would stack duplicates every time
# you `source ~/.zshrc`.
if [[ -d "$HOME/.local/bin" ]]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi

# --- completions ---------------------------------------------------------------
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
zstyle ':completion:*' menu select

# --- history -------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt share_history hist_ignore_all_dups hist_reduce_blanks hist_verify

# --- zsh plugins from brew (guarded so a missing formula never breaks the shell)-
if [[ -n "$BREW_PREFIX" ]]; then
  # zsh-fast-syntax-highlighting must be sourced BEFORE autosuggestions.
  for f in \
    "$BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" \
    "$BREW_PREFIX/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" \
    "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  do
    [[ -r "$f" ]] && source "$f"
  done
fi

# --- prompt + shell tools ------------------------------------------------------
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v direnv   >/dev/null && eval "$(direnv hook zsh)"
# atuin: Aurora ships this init commented out; enable it here (DESIGN §1). The
# cross-shell search behaviour is configured in ~/.config/atuin/config.toml.
command -v atuin    >/dev/null && eval "$(atuin init zsh)"

# --- yazi: TUI file manager, cd-on-quit ----------------------------------------
# yazi leaves the shell where it started unless it is wrapped. --cwd-file makes it
# write the directory it ended in, and the wrapper cds there: `y` to browse, `q` to
# quit and follow, `Q` to quit without moving. Guarded like the plugins above so a
# machine without yazi (or a fresh macOS box) still gets a working shell.
#
# $(<file) is a zsh builtin read rather than cat, on purpose. zsh expands aliases
# when it PARSES a function body, so a `cat` here would pick up the
# `bat --paging=never` alias if that alias were defined earlier in the file. It is
# defined below this block today, so it would not bite right now — the builtin read
# just removes the dependency on that ordering, since moving either section would
# silently start piping the cwd through bat.
if command -v yazi >/dev/null; then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return 1
    yazi "$@" --cwd-file="$tmp"
    cwd="$(<"$tmp")"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
  }
fi

# --- modern coreutils aliases (all from brew) ----------------------------------
command -v eza >/dev/null && {
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
  alias tree='eza --tree'
}
command -v bat   >/dev/null && alias cat='bat --paging=never'
command -v ugrep >/dev/null && alias grep='ugrep'

# --- SDKMAN (Java for SailPoint IIQ — DESIGN §2), installed in $HOME ------------
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
