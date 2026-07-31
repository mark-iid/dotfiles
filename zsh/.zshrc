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
