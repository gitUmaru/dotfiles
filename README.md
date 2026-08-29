# dotfiles

<p align="center">
    <a href="https://github.com/gitUmaru/dotfiles" target="_blank">
    <img align="center" alt="dotfiles" src="https://i.imgur.com/3u88rUC.png" width="250" height="auto"/>
    </a>
</p>
<p align="center">

Personal configuration files for my macOS development environment, managed as
symlinks from this repository into their expected locations.

</p>

## Supported environment

- **OS:** macOS (Apple Silicon)
- **Shell:** zsh with [Oh My Zsh](https://ohmyz.sh/) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Package manager:** [Homebrew](https://brew.sh/)

Most files are portable to other macOS machines. A few tools referenced by the
configs (Oh My Zsh, Powerlevel10k, `lsd`, Ghostty, etc.) must be installed
separately.

## What's included

| Area      | Files                                                                 |
| --------- | --------------------------------------------------------------------- |
| Shell     | `.zshrc`, `.zprofile`, `.profile`, `.p10k.zsh`                        |
| Git       | `.gitconfig`, `.gitignore_global`                                    |
| Terminal  | Ghostty `config` (+ custom icon)                                      |
| Editors   | VS Code `settings.json`                                               |
| pi        | [pi coding agent](https://github.com/earendil-works) settings, theme, statusline, extension manifest |
| Configs   | `htop`, `neofetch`, `flameshot`, `gh` (CLI preferences only)          |

## Repository structure

```
dotfiles/
├── README.md
├── .gitignore
├── install.sh              # idempotent symlink installer
├── shell/                  # .zshrc, .zprofile, .profile, .p10k.zsh
├── git/                    # .gitconfig, .gitignore_global
├── terminal/
│   └── ghostty/            # config + ghostty-term.icns
├── editors/
│   └── vscode/             # settings.json
├── pi/                     # -> ~/.pi (portable config only, no auth/state)
│   ├── .pi.gitignore       # -> ~/.pi/.gitignore
│   ├── web-search.json
│   └── agent/              # settings.json, theme, statusline, npm manifest, custom extension
└── config/                 # -> ~/.config/*
    ├── htop/
    ├── neofetch/
    ├── flameshot/
    └── gh/                 # config.yml only (never hosts.yml)
```

## Installation

```sh
git clone https://github.com/gitUmaru/dotfiles.git ~/Documents/Github/gitUmaru/dotfiles
cd ~/Documents/Github/gitUmaru/dotfiles
./install.sh
```

Preview the changes without touching anything:

```sh
./install.sh --dry-run
```

## How it works

`install.sh` creates **symlinks** from your home directory to the files in this
repo, so edits in either place stay in sync. The script:

- resolves its own location, so it works from any working directory;
- creates any missing parent directories;
- **backs up** an existing real file before replacing it, under
  `~/.dotfiles-backup/<timestamp>/`;
- skips links that already point to the correct source;
- is safe to run repeatedly (idempotent);
- reports every action it takes and uses no external dependencies.

## Adding a new dotfile

1. Move the file into the matching folder in this repo (e.g. `shell/`, `config/foo/`).
2. Add a `link_file "<repo-path>" "<home-target>"` line in `install.sh`.
3. **Inspect it for secrets** before committing (see caveats).
4. Commit with a Conventional Commit message, e.g. `feat(shell): add foo config`.
5. Run `./install.sh` to create the symlink.

## Caveats

- Configs assume Homebrew at `/opt/homebrew` (Apple Silicon). On Intel Macs the
  Homebrew prefix differs.
- `.zshrc` expects Oh My Zsh + Powerlevel10k and aliases `ls` to
  [`lsd`](https://github.com/lsd-rs/lsd); install those tools for the full setup.
- VS Code `remote.SSH.remotePlatform` entries are **placeholders** — replace
  them with your own hosts.
- Flameshot's `savePath` is intentionally blank; set it in the app.
- `.gitconfig` uses `~/.gitignore_global` (portable) instead of an absolute path.

## Excluded for security

The following are **never** committed here. They contain credentials, private
keys, tokens, or machine-specific state:

- `~/.ssh/`, `~/.gnupg/`, `~/.aws/`, `~/.azure/`, `~/.docker/config.json`
- `~/.netrc` (contains a W&B API password)
- `~/.npmrc` (contains an npm auth token)
- `~/.config/gh/hosts.yml` (GitHub auth/identity)
- `~/.claude.json`, `~/.config/herdr`, `~/.config/wandb`, `~/.config/mlflow`
- pi agent secrets/state: `~/.pi/agent/auth.json` (+ backups), `models-store.json`,
  `sessions/`, `web-search-cache/`, `run-history.jsonl`, `missions/`, `bin/`,
  and the separately-versioned `extensions/pi-pretty/` (reinstall via npm)
- Shell/tool history and generated state (`.zsh_history`, `.zcompdump*`, `.viminfo`, …)

The repository `.gitignore` guards against accidentally committing these, but it
is **not** a substitute for inspecting files before adding them.
