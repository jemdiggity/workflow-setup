#!/usr/bin/env bash
set -euo pipefail

# Terminal Workflow Setup
# Idempotent — safe to run repeatedly.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jemdiggity/workflow-setup/main/setup.sh | bash
#   ./setup.sh

ZSHRC="$HOME/.zshrc"
GITCONFIG="$HOME/.gitconfig"
TMUX_CONF="$HOME/.tmux.conf"
NVIM_DIR="$HOME/.config/nvim"
STARSHIP_CONF="$HOME/.config/starship.toml"
TPM_DIR="$HOME/.tmux/plugins/tpm"

MARKER_START="# >>> workflow-setup >>>"
MARKER_END="# <<< workflow-setup <<<"

info() { printf '\033[1;34m[info]\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m[ok]\033[0m   %s\n' "$1"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$1"; }

# -------------------------------------------------------------------
# 1. Homebrew
# -------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for the rest of this script
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  ok "Homebrew already installed"
fi

# -------------------------------------------------------------------
# 2. Brew packages
# -------------------------------------------------------------------
PACKAGES=(
  neovim
  fzf
  fd
  git-delta
  ripgrep
  zoxide
  eza
  starship
  tmux
  bat
)

for pkg in "${PACKAGES[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    ok "$pkg already installed"
  else
    info "Installing $pkg..."
    brew install "$pkg"
  fi
done

# -------------------------------------------------------------------
# 3. Git configuration
# -------------------------------------------------------------------
info "Configuring git..."

# Aliases
git config --global alias.st   "status"
git config --global alias.co   "checkout"
git config --global alias.br   "branch"
git config --global alias.ci   "commit"
git config --global alias.lg   "log --oneline --graph --decorate --all"
git config --global alias.df   "diff"
git config --global alias.dfs  "diff --staged"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "reset HEAD --"
git config --global alias.amend "commit --amend --no-edit"
git config --global alias.sync "pull --rebase"
git config --global alias.wip  "!git add -A && git commit -m 'WIP'"
git config --global alias.undo "reset --soft HEAD~1"
git config --global alias.please "push --force-with-lease"

# Delta as pager
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate "true"
git config --global delta.side-by-side "true"
git config --global delta.line-numbers "true"
git config --global merge.conflictstyle "diff3"
git config --global diff.colorMoved "default"

ok "Git aliases and delta configured"

# -------------------------------------------------------------------
# 4. Zshrc
# -------------------------------------------------------------------
touch "$ZSHRC"

if grep -qF "$MARKER_START" "$ZSHRC"; then
  ok "Zshrc block already present — skipping"
else
  info "Appending workflow config to $ZSHRC..."
  cp "$ZSHRC" "$ZSHRC.bak.$(date +%s)"
  cat >> "$ZSHRC" << 'ZSHBLOCK'

# >>> workflow-setup >>>
# Managed by workflow-setup — do not edit this block manually.

# Prompt
eval "$(starship init zsh)"

# Smart cd
eval "$(zoxide init zsh)"

# Fuzzy finder
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Aliases
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias tree="eza --tree --icons"
alias cat="bat"

# Editor
export EDITOR=nvim

# <<< workflow-setup <<<
ZSHBLOCK
  ok "Zshrc updated (backup saved)"
fi

# -------------------------------------------------------------------
# 5. Starship config
# -------------------------------------------------------------------
mkdir -p "$(dirname "$STARSHIP_CONF")"

if [[ -f "$STARSHIP_CONF" ]]; then
  ok "Starship config already exists — skipping"
else
  info "Writing starship config..."
  cat > "$STARSHIP_CONF" << 'STARSHIPCONF'
format = """
$directory\
$git_branch\
$git_status\
$nodejs\
$rust\
$python\
$cmd_duration\
$line_break\
$character"""

[directory]
truncation_length = 3
truncate_to_repo = true

[git_branch]
format = "[$symbol$branch]($style) "
symbol = " "

[git_status]
format = '([$all_status$ahead_behind]($style) )'

[nodejs]
format = "[$symbol($version)]($style) "
symbol = " "

[rust]
format = "[$symbol($version)]($style) "

[python]
format = "[$symbol($version)]($style) "

[cmd_duration]
min_time = 2000
format = "[$duration]($style) "

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
STARSHIPCONF
  ok "Starship config written"
fi

# -------------------------------------------------------------------
# 6. LazyVim
# -------------------------------------------------------------------
if [[ -d "$NVIM_DIR" ]] && [[ -n "$(ls -A "$NVIM_DIR" 2>/dev/null)" ]]; then
  ok "Neovim config already exists — skipping LazyVim bootstrap"
else
  info "Bootstrapping LazyVim..."
  rm -rf "$NVIM_DIR"
  git clone https://github.com/LazyVim/starter "$NVIM_DIR"
  rm -rf "$NVIM_DIR/.git"
  ok "LazyVim installed"
fi

# -------------------------------------------------------------------
# 7. Tmux
# -------------------------------------------------------------------
if [[ -f "$TMUX_CONF" ]]; then
  ok "Tmux config already exists — skipping"
else
  info "Writing tmux config..."
  cat > "$TMUX_CONF" << 'TMUXCONF'
# Prefix: Ctrl-a
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Quality of life
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 50000
set -sg escape-time 0
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Vi-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Split panes with | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# New windows keep current path
bind c new-window -c "#{pane_current_path}"

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded"

# Status bar
set -g status-position top
set -g status-style "bg=default,fg=white"
set -g status-left "#[bold] #S "
set -g status-right "%H:%M "
set -g status-left-length 30

# TPM plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'

# Initialize TPM (keep at bottom)
run '~/.tmux/plugins/tpm/tpm'
TMUXCONF
  ok "Tmux config written"
fi

# Install TPM
if [[ -d "$TPM_DIR" ]]; then
  ok "TPM already installed"
else
  info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "TPM installed — run prefix + I inside tmux to install plugins"
fi

# -------------------------------------------------------------------
# Done
# -------------------------------------------------------------------
echo ""
info "Setup complete. Restart your terminal or run: source $ZSHRC"
info "In tmux, press Ctrl-a + I to install tmux plugins."
info "Open nvim to let LazyVim install its plugins on first launch."
