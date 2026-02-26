# Terminal Workflow Setup

Idempotent setup script for a macOS terminal workflow. Safe to run on a fresh machine or an existing one.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/jemdiggity/setup-workflow/main/setup.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/jemdiggity/setup-workflow.git
cd setup-workflow
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
| ghostty | Fast, GPU-accelerated terminal emulator (optional) |

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

1. **Open a new terminal window** (or run `source ~/.zshrc` in your current one) so the shell picks up the new config.

2. **Install tmux plugins:**
   - Start tmux: `tmux`
   - Press `Ctrl-b` then `I` (capital I) to install plugins
   - You should see a message confirming plugins were installed
   - Note: `Ctrl-b + I` only works **from inside a tmux session**. It will not work from a regular terminal.

3. **Launch neovim** (`nvim`) and wait for LazyVim to automatically download and install its plugins on first launch.

## Troubleshooting

**Shell changes didn't take effect:**
Make sure you opened a **new** terminal window after running the script. Running `source ~/.zshrc` in an existing window also works.

**`Ctrl-b + I` does nothing in tmux:**
- Make sure you're inside a tmux session (run `tmux` first).
- If tmux was already running before you ran the setup script, reload the config by running this from inside tmux:
  1. `Ctrl-b` then `:` to open the tmux command prompt
  2. Type `source-file ~/.tmux.conf` and press Enter
  3. Try `Ctrl-b + I` again

**Script failed partway through when using `curl | bash`:**
Try running it locally instead:
```bash
git clone https://github.com/jemdiggity/setup-workflow.git
cd setup-workflow
./setup.sh
```
