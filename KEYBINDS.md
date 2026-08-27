# ⌨ niri Hotkey Cheatsheet

`Mod` = **Super** (Windows key). Live overlay anytime: **`Mod+Shift+/`**.
Source of truth is [`niri/.config/niri/config.kdl`](niri/.config/niri/config.kdl) — keep this in sync when binds change.

## 🚀 App launchers
| Key | App |
|---|---|
| `Mod+B` | Browser (Firefox) |
| `Mod+C` | VS Code *(laptop only)* |
| `Mod+E` | Files (Thunar) |
| `Mod+P` | Passwords (rbw picker → clipboard) |
| `Mod+O` | TOTP codes (rbw picker → clipboard) |
| `Mod+N` | Notes (Joplin) |
| `Mod+M` | Music (Supersonic) *(laptop only)* |
| `Mod+G` | Comms screen (fresh workspace: Evolution ∣ Slack / Discord) |
| `Mod+D` | App launcher (fuzzel — type any app) |

## 📻 Ham radio (shack PC only)
| Key | App |
|---|---|
| `Mod+W` | **W**SJT-X — weak-signal digital (FT8/FT4) |
| `Mod+S` | **S**tation log (QLog) |
| `Mod+A` | **A**ll-mode digital (fldigi) |
| `Mod+I` | **I**nbox — Winlink: starts VARA + `pat http`, opens the web UI |

`Mod+I` brings the whole Winlink stack up in one go and only starts the parts that
are not already running, so pressing it again is a safe way to re-open the browser.
These binds do nothing on the laptop, where none of the apps are installed.

Evolution, Slack and Discord have no keys of their own — `Mod+G` lays all three
out together, and `Mod+D` launches any one on its own.

*(laptop only)* binds are hostname-guarded: they exist in the shared config but do
nothing on the kb3lyb shack PC, where those apps are installed but not wanted on a
shortcut. `Mod+D` (fuzzel) still launches any of them there by name.

## 🖥 System & tools
| Key | Action |
|---|---|
| `Mod+Return` | Terminal (ghostty) |
| `Mod+V` | Clipboard history |
| `Mod+Escape` | Lock screen |
| `Mod+Shift+C` | Caffeine (stay awake — stop idle-lock + block suspend) |
| `Mod+Shift+G` | Game mode (toggle touchpad disable-while-typing) |
| `Mod+/` | This cheatsheet |
| `Mod+Shift+/` | Show hotkey overlay (niri's own raw bind list) |

## 🎤 Voice
| Key | Action |
|---|---|
| `Mod+T` | Dictation — speak, it types into the focused window (whisper) |
| `Mod+Shift+T` | Command mode — control niri by voice (toggle on / off) |

Command-mode phrases: **focus** / **move** *left · right · up · down* ∣ **close window** ∣ **full screen** ∣ **maximize** ∣ **center** ∣ **next** / **previous workspace** ∣ **workspace** *one…nine*

## 🪟 Windows
| Key | Action |
|---|---|
| `Mod+Q` | Close window |
| `Mod+H` `Mod+J` `Mod+K` `Mod+L` *(or arrows)* | Focus left / down / up / right |
| `Mod+Shift+←↓↑→` | Move window / column |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen |
| `Mod+R` | Cycle column width (⅓ → ½ → ⅔) |
| `Mod+Shift+X` | Un-stick an X11 app that fullscreened itself (SDL / Ren'Py games) |

## 🗂 Workspaces
| Key | Action |
|---|---|
| `Mod+1`…`Mod+4` | Switch to workspace |
| `Mod+Shift+1`…`Mod+Shift+4` | Move column to workspace |

## 📸 Screenshots
| Key | Action |
|---|---|
| `Print` | Region |
| `Ctrl+Print` | Whole screen |
| `Alt+Print` | Focused window |

## 🎛 Hardware keys (Framework Fn row)
| Key | Action |
|---|---|
| Volume Up / Down / Mute | `wpctl` |
| Brightness Up / Down | `brightnessctl` |
| ⏯ / ⏭ / ⏮ | `playerctl` play-pause / next / prev |

## 🚪 Session
| Key | Action |
|---|---|
| `Mod+Shift+P` | Power off monitors |
| `Mod+Shift+E` | **Quit niri** (ends the session) |
