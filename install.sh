#!/usr/bin/env bash
#
# install.sh — symlink dotfiles from this repo into their expected locations.
#
# Safe to run multiple times (idempotent):
#   * Determines its own location, so it works from any working directory.
#   * Creates any parent directories needed for a target.
#   * Backs up an existing real file/dir before replacing it.
#   * Skips links that already point at the correct source.
#   * Never deletes your data without first backing it up.
#
# Usage:
#   ./install.sh            # create/update symlinks
#   ./install.sh --dry-run  # show what would happen, change nothing
#
set -euo pipefail

# --- Resolve the repository root (directory containing this script) ---------
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DOTFILES_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# --- Small logging helpers --------------------------------------------------
info()  { printf '  \033[0;34m•\033[0m %s\n' "$*"; }
ok()    { printf '  \033[0;32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[0;33m!\033[0m %s\n' "$*"; }
run()   { if [ "$DRY_RUN" -eq 1 ]; then printf '    (dry-run) %s\n' "$*"; else eval "$@"; fi; }

# link_file <source-relative-to-repo> <target-absolute-path>
link_file() {
  local src="$DOTFILES_DIR/$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    warn "source missing, skipping: $1"
    return
  fi

  # Already the correct symlink? Nothing to do.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    ok "up to date: ${dest/#$HOME/~}"
    return
  fi

  # Ensure parent directory exists.
  local parent; parent="$(dirname "$dest")"
  if [ ! -d "$parent" ]; then
    info "creating dir: ${parent/#$HOME/~}"
    run "mkdir -p \"$parent\""
  fi

  # Back up an existing file/dir/wrong-symlink before replacing it.
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    info "backing up existing ${dest/#$HOME/~}"
    run "mkdir -p \"$BACKUP_DIR$parent\""
    run "mv \"$dest\" \"$BACKUP_DIR$dest\""
  fi

  info "linking ${dest/#$HOME/~} -> ${src/#$HOME/~}"
  run "ln -s \"$src\" \"$dest\""
}

main() {
  printf '\nInstalling dotfiles from: %s\n' "${DOTFILES_DIR/#$HOME/~}"
  [ "$DRY_RUN" -eq 1 ] && warn "DRY RUN — no changes will be made"
  printf '\n'

  # Shell
  link_file "shell/.zshrc"    "$HOME/.zshrc"
  link_file "shell/.zprofile" "$HOME/.zprofile"
  link_file "shell/.profile"  "$HOME/.profile"
  link_file "shell/.p10k.zsh" "$HOME/.p10k.zsh"

  # Git
  link_file "git/.gitconfig"        "$HOME/.gitconfig"
  link_file "git/.gitignore_global" "$HOME/.gitignore_global"

  # Terminal
  link_file "terminal/ghostty/config"             "$HOME/.config/ghostty/config"
  link_file "terminal/ghostty/ghostty-term.icns"  "$HOME/.config/ghostty/ghostty-term.icns"

  # Application configs
  link_file "config/htop/htoprc"             "$HOME/.config/htop/htoprc"
  link_file "config/neofetch/config.conf"    "$HOME/.config/neofetch/config.conf"
  link_file "config/flameshot/flameshot.ini" "$HOME/.config/flameshot/flameshot.ini"
  link_file "config/gh/config.yml"           "$HOME/.config/gh/config.yml"

  # Editors — VS Code lives under Library on macOS.
  link_file "editors/vscode/settings.json" \
    "$HOME/Library/Application Support/Code/User/settings.json"

  printf '\n'
  if [ "$DRY_RUN" -eq 1 ]; then
    warn "Dry run complete. Re-run without --dry-run to apply."
  else
    ok "Done."
    [ -d "$BACKUP_DIR" ] && info "Backups saved to: ${BACKUP_DIR/#$HOME/~}"
  fi
  printf '\n'
}

main "$@"
