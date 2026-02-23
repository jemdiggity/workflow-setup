# Terminal Workflow Setup

Idempotent setup script for a macOS terminal workflow. Safe to run on a fresh machine or an existing one.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/jemdiggity/workflow-setup/main/setup.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/jemdiggity/workflow-setup.git
cd workflow-setup
./setup.sh
```

## What It Does

### Tools (via Homebrew)

| Tool | Purpose |
|------|---------|
| neovim | Editor (bootstrapped with LazyVim) |
| tmux | Terminal multiplexer (with TPM + config) |
| fzf | Fuzzy finder |
| fd | Fast `find` replacement |
| ripgrep | Fast `grep` replacement |
| git-delta | Syntax-highlighted git diffs |
| bat | `cat` with syntax highlighting |
| eza | Modern `ls` with icons and git status |
| zoxide | Smart `cd` that learns your directories |
| starship | Fast, customizable prompt |

### Git Aliases

| Alias | Command |
|-------|---------|
| `git st` | `status` |
| `git co` | `checkout` |
| `git br` | `branch` |
| `git ci` | `commit` |
| `git lg` | Pretty one-line log graph |
| `git df` | `diff` |
| `git dfs` | `diff --staged` |
| `git last` | Show last commit |
| `git unstage` | `reset HEAD --` |
| `git amend` | `commit --amend --no-edit` |
| `git sync` | `pull --rebase` |
| `git wip` | Stage all + commit "WIP" |
| `git undo` | Soft reset last commit |
| `git please` | `push --force-with-lease` |

Delta is configured as the default git pager with side-by-side diffs.

### Shell (zshrc)

Appends a managed block to `~/.zshrc` with:

- Starship prompt
- zoxide (`z` command)
- fzf keybindings
- Aliases: `ls` -> eza, `ll` -> eza -la, `tree` -> eza --tree, `cat` -> bat
- `$EDITOR` set to nvim

### Neovim

Bootstraps [LazyVim](https://www.lazyvim.org/) if no config exists at `~/.config/nvim`.

### Tmux

Writes a config with:

- Mouse mode, vi-style pane navigation
- `|` and `-` for splits
- TPM with tmux-sensible and tmux-yank

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. In tmux: press `Ctrl-b` then `I` to install plugins
3. Open `nvim` to let LazyVim install on first launch
