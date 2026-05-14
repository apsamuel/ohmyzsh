# oh-my-zsh — Makefile Reference

> Custom plugin & theme submodule management for the oh-my-zsh fork.

This Makefile manages custom plugins and themes that live under
`custom/plugins/` and `custom/themes/` as nested git submodules. It
reconciles them against the `data/zsh.yaml` data file that serves as the
single source of truth for which plugins/themes are active.

---

## Quick Start

```bash
make                     # print help
make install             # init and update all submodules from .gitmodules
make doctor              # read-only health check
```

---

## Parameters

| Parameter       | Effect                                                      |
| --------------- | ----------------------------------------------------------- |
| `CONFIG`        | Path to zsh.yaml data file (default: `../../data/zsh.yaml`) |
| `OWNER`         | GitHub owner/org for the submodule                          |
| `REPO`          | GitHub repo name for the submodule                          |
| `EXEC`          | Command to run after submodule init (optional)              |
| `DOT_DRY_RUN=1` | Preview all actions, no mutations                           |
| `DOT_DEBUG=1`   | Enable bash xtrace for debugging                            |
| `DOT_VERBOSE=1` | Pass `--verbose` to git submodule operations                |

---

## Targets

| Target          | Description                                                     |
| --------------- | --------------------------------------------------------------- |
| `help`          | Show all targets with descriptions                              |
| `install`       | Initialize and update all submodules from `.gitmodules`         |
| `add-plugin`    | Add a custom plugin (`OWNER`, `REPO` required; `EXEC` optional) |
| `add-theme`     | Add a custom theme (`OWNER`, `REPO` required; `EXEC` optional)  |
| `remove-plugin` | Remove a custom plugin (`OWNER`, `REPO` required)               |
| `remove-theme`  | Remove a custom theme (`OWNER`, `REPO` required)                |
| `sync-plugins`  | Reconcile plugin submodules from data file                      |
| `sync-themes`   | Reconcile theme submodules from data file                       |
| `doctor`        | Read-only health check (plugins, themes, submodules)            |

---

## Examples

```bash
# Install all declared submodules
make install

# Preview what install would do
DOT_DRY_RUN=1 make install

# Add a new plugin
make add-plugin OWNER=zsh-users REPO=zsh-autosuggestions

# Add a plugin with a post-init command
make add-plugin OWNER=Aloxaf REPO=fzf-tab EXEC="git checkout main"

# Remove a plugin
make remove-plugin OWNER=zsh-users REPO=zsh-autosuggestions

# Reconcile all plugins from data/zsh.yaml
make sync-plugins

# Health check
make doctor

# Debug a failing target
DOT_DEBUG=1 make install
```

---

## Data-Driven Reconciliation

The `sync-plugins` and `sync-themes` targets read `data/zsh.yaml` to
determine which submodules should exist. Plugins/themes listed in the YAML
but missing on disk are cloned; submodules on disk but not in YAML are
flagged (but not removed — use `remove-plugin`/`remove-theme` explicitly).

---

## Root Makefile Integration

The parent `dot` Makefile provides passthrough targets with automatic flag
propagation:

```bash
# These are equivalent:
make omz-add-plugin OWNER=org REPO=name       # from ~/.dot
cd vendor/oh-my-zsh && make add-plugin OWNER=org REPO=name  # directly

# Dry-run propagates automatically:
DRY=1 make omz-sync-plugins                   # from ~/.dot
```

Available root passthroughs: `omz-install`, `omz-add-plugin`, `omz-add-theme`,
`omz-remove-plugin`, `omz-remove-theme`, `omz-sync-plugins`, `omz-sync-themes`,
`omz-doctor`.
