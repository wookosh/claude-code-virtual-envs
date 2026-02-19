# ccenv — Claude Code Environments

Manage reusable configuration profiles for Claude Code. Think `pyenv` or `nvm`, but for your Claude Code settings — snapshot, switch, and sync different configurations across projects.

## The Problem

Claude Code stores configuration in `~/.claude/` (global) and `.claude/` (per-project), but there's no built-in way to maintain different environments — a "backend" profile, a "frontend" profile, a "client X" profile — and apply them cleanly across projects.

## How It Works

`ccenv` manages **profiles** — named snapshots of Claude Code configuration stored in `~/.claude-profiles/`. Each profile can contain:

| File / Directory | Purpose |
|---|---|
| `CLAUDE.md` | System instructions |
| `settings.json` | Claude Code settings |
| `agents/` | Custom agents |
| `skills/` | Custom skills |
| `rules/` | Project rules |

When you apply a profile to a project, `ccenv` copies these files into the project's `.claude/` directory and writes a `.profile` marker that tracks sync state via content hashing.

## Installation

```sh
git clone https://github.com/wookosh/claude-code-virtual-envs.git
cd claude-code-virtual-envs
./install.sh
```

This copies `ccenv` to `~/.local/bin/`. Make sure it's on your `PATH`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

**Requires Python 3.10+** with no external dependencies.

## Quick Start

```sh
# Save your current global config as a profile
ccenv save my-setup

# Clear global config so it doesn't bleed into projects
ccenv clear

# Apply the profile to a project
cd ~/projects/my-app
ccenv use my-setup
```

## Commands

### `ccenv save <name> [--from global|project]`

Snapshot current configuration as a named profile.

```sh
ccenv save backend              # from ~/.claude/ (default)
ccenv save frontend --from project  # from ./.claude/
```

### `ccenv use <name>`

Apply a profile to the current project's `.claude/` directory. Warns if untracked config exists and suggests saving it first.

### `ccenv status`

Show the active profile and sync state — whether the project is in sync with the profile template, has drifted, or the template has been updated.

### `ccenv update`

Preview what would change, then re-sync the project from the profile template.

### `ccenv diff [name]`

Show a unified diff between the project's `.claude/` and a profile. Defaults to the active profile.

### `ccenv list`

List all profiles with a summary of their contents (agent count, skill count, rules, CLAUDE.md presence).

### `ccenv clear [--scope global|project]`

Remove all managed config files for a clean slate. Defaults to `--scope global` (`~/.claude/`). Shows exactly what will be removed and asks for confirmation.

```sh
ccenv clear                   # clear ~/.claude/ (global)
ccenv clear --scope project   # clear ./.claude/ (project)
```

### `ccenv eject`

Detach the project from its profile. Config files stay, but tracking stops — changes no longer sync in either direction.

## Typical Workflows

### Apply a profile to a project

```
1. ccenv save original          # Preserve your current config
2. cd ~/projects/api-service
3. ccenv use original           # Apply to project
4. (customize .claude/ for this project)
5. ccenv status                 # Check sync state
6. ccenv diff                   # See what changed
7. ccenv update                 # Pull in template updates
```

### Build a new profile from scratch

```
1. ccenv save backup            # Preserve what you have
2. ccenv clear                  # Clean slate (global config)
3. (install tools, configure Claude Code)
4. ccenv save new-profile       # Save the new config as a profile
5. ccenv clear                  # Clean up again
6. ccenv use backup             # Restore your original config (in a project)
```

## How Sync Detection Works

When a profile is applied, `ccenv` stores a SHA-256 hash of the profile's contents in `.claude/.profile`. On `status` or `update`, it compares three hashes:

- **Marker hash** — what was applied
- **Project hash** — current state of `.claude/`
- **Template hash** — current state of the profile in `~/.claude-profiles/`

This tells you whether the project drifted, the template was updated, or both.

## License

MIT
