# kb3lyb Brewfile — the $HOME toolchain the .zshrc expects (DESIGN §1). Portable
# across linuxbrew and Apple Silicon. `brew bundle --file=~/dotfiles/Brewfile` is
# run by kb3lyb-bootstrap; `brew bundle dump` refreshes it (DESIGN §10 backup).
brew "starship"
brew "atuin"
brew "zsh-autosuggestions"
brew "zsh-fast-syntax-highlighting"
brew "eza"
brew "bat"
brew "glow"          # markdown renderer — powers the Mod+/ keybind cheatsheet popup
brew "rbw"           # Rust Bitwarden CLI + agent — powers the Mod+P password picker
brew "btop"          # system monitor — click the waybar cpu/memory modules to open it
brew "aerc"          # TUI email client (personal IMAP); password via rbw, config in ~/.config/aerc
brew "w3m"           # HTML email renderer used by aerc's html filter
brew "cmatrix"       # matrix screensaver shown on idle by swayidle (niri/scripts/screensaver)
brew "ugrep"
brew "zoxide"
brew "direnv"
# mosh — UDP remote shell. Needed on BOTH ends, which is why it is in this file
# rather than the image: this Brewfile is what bootstraps the mac mini too, so one
# line gets the client here and mosh-server on iidmacmini. See claude-mini-mosh in
# .zshrc for the two flags that are load-bearing.
brew "mosh"
