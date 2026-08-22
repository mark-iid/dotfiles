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

# --- remote Claude Code session on the mac mini --------------------------------
# Attach a local pane to a long-lived `claude` running on iidmacmini. `tmux new -A`
# attaches if the session exists and creates it otherwise, so this one command is
# both "start" and "reconnect" — which matters because this laptop suspends for
# long stretches and every suspend drops the ssh connection.
#
# tmux rather than zellij ON THE FAR END, deliberately: the near end is already a
# zellij pane, and nested zellij means both layers fight over Ctrl+p/t/n/o and
# keystrokes get eaten by whichever sees them first. tmux's Ctrl+b prefix collides
# with none of zellij's mode keys.
#
# `zsh -lc` is load-bearing, NOT decoration. `ssh host 'cmd'` runs a
# non-interactive, non-login shell, which reads only .zshenv — never .zshrc or
# .zprofile — so the `brew shellenv` line never runs and PATH is Apple's bare
# path_helper default (/usr/bin:/bin:/usr/sbin:/sbin) with no /opt/homebrew in it.
# Without the login shell this fails with "command not found: tmux" even though
# tmux is installed. -t is needed too: tmux refuses to start without a TTY.
#
# `claude` itself resolves fine inside the session without any extra help, because
# tmux spawns login shells for its panes.
alias claude-mini="ssh -t iidmacmini 'zsh -lc \"tmux new -A -s claude\"'"

# --- the same session over mosh, for when the laptop has been asleep -----------
# Same destination, same tmux session, different transport. Reach for this one by
# default; keep the ssh alias above for the times you need agent forwarding, port
# forwarding or scp, none of which mosh does.
#
# WHY: ssh over a suspend is the failure documented by the terminal-mode hook at
# the bottom of this file. The laptop sleeps, the TCP connection dies unnoticed,
# and the ssh client hangs on a socket that will not time out — still holding the
# LOCAL tty in raw mode, so the keyboard is dead until `~.` or `stty sane`. mosh
# has no long-lived TCP connection to hang: it is UDP with a session key, so it
# reattaches after a suspend, a wifi change or a move to a different network,
# without a reconnect and without leaving the terminal wedged.
#
# --server= is load-bearing, and for EXACTLY the reason `zsh -lc` is above: mosh
# starts the far end by running `mosh-server` over a non-interactive, non-login
# ssh, which never reads .zprofile, so /opt/homebrew is not in PATH. Without the
# absolute path this fails with "Did not find mosh server startup message",
# which reads like a network problem and is not one.
#
# `-- zsh -lc ...` needs mosh >= 1.4.0 for remote commands (brew ships 1.4.0).
# Note the quoting is one level shallower than the ssh alias: mosh execs this
# argv directly rather than handing a string to a remote shell, so nothing gets
# re-parsed on the far end and the inner quotes do not need escaping. `-t` is
# gone too — mosh always allocates a pty.
#
# tmux is still wanted underneath, for two reasons that mosh does not cover: mosh
# survives the network but not a reboot or a killed client, and it owns the screen
# it paints, so it has no scrollback of its own — tmux's copy mode is what gives
# scrollback back.
#
# Two things to fix on iidmacmini the first time this is used, both of which look
# like hangs rather than errors:
#   * inbound UDP 60000-61000 must be open; the macOS application firewall drops
#     it silently, so ssh succeeds and then mosh sits there
#   * both ends need a UTF-8 locale or mosh refuses to start outright
alias claude-mini-mosh="mosh --server=/opt/homebrew/bin/mosh-server iidmacmini -- zsh -lc 'tmux new -A -s claude'"

# --- SDKMAN (Java for SailPoint IIQ — DESIGN §2), installed in $HOME ------------
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# --- undo terminal modes left behind by a dead remote session ------------------
# When an ssh connection drops mid-TUI (nvim, tmux, htop on the far end), the
# remote program never gets to run its exit sequences, so the LOCAL terminal keeps
# whatever modes that program switched on. The usual casualty is mouse reporting:
# ?1003h/?1006h are still set, nothing remains to consume the reports, so every
# mouse movement is typed into the shell as literal "35;86;37M" garbage. A hidden
# cursor and a stuck alternate screen leak the same way.
#
# Nothing can prevent this — the sequences that would undo it die with the
# connection — so undo them locally at every prompt instead. Each one is a no-op
# when the mode is already off, so this costs nothing in the normal case.
#
# ?2004 (bracketed paste) is deliberately NOT reset here: zle owns that one and
# re-enables it per line, so touching it can only break paste.
# NOTHING IN HERE MAY MOVE THE CURSOR. Every sequence below is a pure mode
# toggle, and that is the whole design constraint — see fixterm for why.
_reset_terminal_modes() {
  # mouse: normal, button-event, any-event, focus, SGR ext, urxvt ext
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1004l\e[?1006l\e[?1015l'
  # cursor visible, autowrap on, attributes cleared
  printf '\e[?25h\e[?7h\e[0m'
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _reset_terminal_modes

# The same cleanup on demand, plus the two things that must NOT happen at every
# prompt: a tty-mode reset, and leaving the alternate screen.
#
# \e[?1049l WAS in the precmd hook above and it silently ate command output.
# 1049 is not just a screen switch: on `l` it also RESTORES THE SAVED CURSOR
# POSITION. Sent without a matching `h` it restores a stale save, so the cursor
# jumps back up the screen — and zsh redraws its prompt with \e[J, "erase from
# cursor to end of display", which then wipes everything below that point.
# Net effect at every prompt: the command's output flashes up and is deleted.
# Confirmed by capturing the raw pty stream, where the two sequences land
# back to back.
#
# It is safe here because you run this deliberately, when the screen is already
# wrong and there is nothing worth preserving below the cursor.
fixterm() {
  stty sane
  _reset_terminal_modes
  printf '\e[?1049l'
}
