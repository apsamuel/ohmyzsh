# ──────────────────────────────────────────────────────────────────────────────
# oh-my-zsh — custom plugin & theme submodule management
#
# Usage:
#   make                                          # print help
#   make install                                  # init & update all submodules
#   make add-plugin OWNER=org REPO=name           # add a custom plugin
#   make add-theme  OWNER=org REPO=name           # add a custom theme
#   make add-plugin OWNER=org REPO=name EXEC="cmd" # add plugin with post-init command
#   make remove-plugin OWNER=org REPO=name        # remove a custom plugin
#   make remove-theme  OWNER=org REPO=name        # remove a custom theme
#   make sync-plugins                              # reconcile plugin submodules from data
#   make sync-themes                               # reconcile theme submodules from data
#
# Parameters:
#   CONFIG   path to zsh.yaml data file (default: ../../data/zsh.yaml)
#   OWNER    GitHub owner/org for the submodule
#   REPO     GitHub repo name for the submodule
#   EXEC     optional command to run after submodule init
# ──────────────────────────────────────────────────────────────────────────────

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

# ── Parameters ────────────────────────────────────────────────────────────────
CONFIG ?= ../../data/zsh.yaml
OWNER  ?=
REPO   ?=
EXEC   ?=

# ── Guards ────────────────────────────────────────────────────────────────────
define require_yq
	@command -v yq >/dev/null 2>&1 || { echo "ERROR: yq (mikefarah/yq v4+) is required but not found in PATH." >&2; echo "Install via: brew install yq" >&2; exit 1; }
endef

define require_params
	@if [[ -z "$(OWNER)" ]]; then echo "ERROR: OWNER is required (e.g., OWNER=romkatv)" >&2; exit 1; fi
	@if [[ -z "$(REPO)" ]]; then echo "ERROR: REPO is required (e.g., REPO=powerlevel10k)" >&2; exit 1; fi
endef

# ── Phony declarations ────────────────────────────────────────────────────────
.PHONY: help install add-plugin add-theme remove-plugin remove-theme sync-plugins sync-themes

# ══════════════════════════════════════════════════════════════════════════════
# Help
# ══════════════════════════════════════════════════════════════════════════════

help: ## Show this help
	@echo "oh-my-zsh — custom plugin & theme submodule management"
	@echo ""
	@echo "Usage:  make <target> [PARAMS]"
	@echo ""
	@echo "Parameters:"
	@echo "  CONFIG=<path>   zsh.yaml data file (default: ../../data/zsh.yaml)"
	@echo "  OWNER=<org>     GitHub owner/org"
	@echo "  REPO=<name>     GitHub repo name"
	@echo "  EXEC=<cmd>      command to run after submodule init (optional)"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# ══════════════════════════════════════════════════════════════════════════════
# Targets
# ══════════════════════════════════════════════════════════════════════════════

install: ## Initialize and update all submodules from .gitmodules
	@echo "Initializing submodules..."
	@git submodule init
	@git submodule update --recursive
	@echo "Done."

add-plugin: ## Add a custom plugin (OWNER, REPO required; EXEC optional)
	$(require_yq)
	$(require_params)
	@echo "Adding plugin: $(OWNER)/$(REPO)"
	@if yq -e '.plugins.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)")' "$(CONFIG)" >/dev/null 2>&1; then \
		echo "  ✓ Already in $(CONFIG)"; \
	else \
		echo "  Adding to $(CONFIG)..."; \
		yq -i '.plugins.custom += [{"owner": "$(OWNER)", "repo": "$(REPO)", "exec": "$(EXEC)", "enabled": true}]' "$(CONFIG)"; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/plugins/$(REPO).url" >/dev/null 2>&1; then \
		echo "  ✓ Submodule already registered in .gitmodules"; \
	else \
		echo "  Registering submodule..."; \
		git submodule add "git@github.com:$(OWNER)/$(REPO).git" "custom/plugins/$(REPO)"; \
	fi
	@echo "  Initializing submodule..."
	@git submodule update --init "custom/plugins/$(REPO)"
	@if [[ -n "$(EXEC)" ]]; then \
		echo "  Running post-init command: $(EXEC)"; \
		cd "custom/plugins/$(REPO)" && $(EXEC); \
	fi
	@echo "Done."

add-theme: ## Add a custom theme (OWNER, REPO required; EXEC optional)
	$(require_yq)
	$(require_params)
	@echo "Adding theme: $(OWNER)/$(REPO)"
	@if yq -e '.themes.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)")' "$(CONFIG)" >/dev/null 2>&1; then \
		echo "  ✓ Already in $(CONFIG)"; \
	else \
		echo "  Adding to $(CONFIG)..."; \
		yq -i '.themes.custom += [{"owner": "$(OWNER)", "repo": "$(REPO)", "exec": "$(EXEC)", "enabled": true}]' "$(CONFIG)"; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/themes/$(REPO).url" >/dev/null 2>&1; then \
		echo "  ✓ Submodule already registered in .gitmodules"; \
	else \
		echo "  Registering submodule..."; \
		git submodule add "git@github.com:$(OWNER)/$(REPO).git" "custom/themes/$(REPO)"; \
	fi
	@echo "  Initializing submodule..."
	@git submodule update --init "custom/themes/$(REPO)"
	@if [[ -n "$(EXEC)" ]]; then \
		echo "  Running post-init command: $(EXEC)"; \
		cd "custom/themes/$(REPO)" && $(EXEC); \
	fi
	@echo "Done."

remove-plugin: ## Remove a custom plugin (OWNER, REPO required)
	$(require_yq)
	$(require_params)
	@echo "Removing plugin: $(OWNER)/$(REPO)"
	@if yq -e '.plugins.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)")' "$(CONFIG)" >/dev/null 2>&1; then \
		echo "  Removing from $(CONFIG)..."; \
		yq -i 'del(.plugins.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)"))' "$(CONFIG)"; \
	else \
		echo "  ✓ Not in $(CONFIG)"; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/plugins/$(REPO).url" >/dev/null 2>&1; then \
		echo "  Removing submodule..."; \
		git submodule deinit -f "custom/plugins/$(REPO)" 2>/dev/null || true; \
		git rm -f "custom/plugins/$(REPO)" 2>/dev/null || true; \
		rm -rf ".git/modules/custom/plugins/$(REPO)"; \
	else \
		echo "  ✓ Submodule not registered in .gitmodules"; \
	fi
	@echo "Done."

remove-theme: ## Remove a custom theme (OWNER, REPO required)
	$(require_yq)
	$(require_params)
	@echo "Removing theme: $(OWNER)/$(REPO)"
	@if yq -e '.themes.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)")' "$(CONFIG)" >/dev/null 2>&1; then \
		echo "  Removing from $(CONFIG)..."; \
		yq -i 'del(.themes.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)"))' "$(CONFIG)"; \
	else \
		echo "  ✓ Not in $(CONFIG)"; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/themes/$(REPO).url" >/dev/null 2>&1; then \
		echo "  Removing submodule..."; \
		git submodule deinit -f "custom/themes/$(REPO)" 2>/dev/null || true; \
		git rm -f "custom/themes/$(REPO)" 2>/dev/null || true; \
		rm -rf ".git/modules/custom/themes/$(REPO)"; \
	else \
		echo "  ✓ Submodule not registered in .gitmodules"; \
	fi
	@echo "Done."

sync-plugins: ## Reconcile plugin submodules from data file
	$(require_yq)
	@echo "Syncing plugins from $(CONFIG)..."
	@count=$$(yq '.plugins.custom | length' "$(CONFIG)"); \
	for i in $$(seq 0 $$((count - 1))); do \
		owner=$$(yq ".plugins.custom[$$i].owner" "$(CONFIG)"); \
		repo=$$(yq ".plugins.custom[$$i].repo" "$(CONFIG)"); \
		exec_cmd=$$(yq ".plugins.custom[$$i].exec" "$(CONFIG)"); \
		enabled=$$(yq ".plugins.custom[$$i].enabled" "$(CONFIG)"); \
		echo "  [$${owner}/$${repo}] enabled=$${enabled}"; \
		if [[ "$$enabled" == "true" ]]; then \
			if ! git config -f .gitmodules --get "submodule.custom/plugins/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Registering submodule..."; \
				git submodule add "git@github.com:$${owner}/$${repo}.git" "custom/plugins/$${repo}"; \
			fi; \
			echo "    Initializing..."; \
			git submodule update --init "custom/plugins/$${repo}"; \
			if [[ -n "$$exec_cmd" && "$$exec_cmd" != "null" && "$$exec_cmd" != "''" && "$$exec_cmd" != "" ]]; then \
				echo "    Running post-init command: $${exec_cmd}"; \
				(cd "custom/plugins/$${repo}" && eval "$$exec_cmd"); \
			fi; \
		else \
			if git config -f .gitmodules --get "submodule.custom/plugins/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Deinitializing..."; \
				git submodule deinit -f "custom/plugins/$${repo}" 2>/dev/null || true; \
			else \
				echo "    ✓ Already inactive"; \
			fi; \
		fi; \
	done
	@echo "Done."




sync-themes: ## Reconcile theme submodules from data file
	$(require_yq)
	@echo "Syncing themes from $(CONFIG)..."
	@count=$$(yq '.themes.custom | length' "$(CONFIG)"); \
	for i in $$(seq 0 $$((count - 1))); do \
		owner=$$(yq ".themes.custom[$$i].owner" "$(CONFIG)"); \
		repo=$$(yq ".themes.custom[$$i].repo" "$(CONFIG)"); \
		exec_cmd=$$(yq ".themes.custom[$$i].exec" "$(CONFIG)"); \
		enabled=$$(yq ".themes.custom[$$i].enabled" "$(CONFIG)"); \
		echo "  [$${owner}/$${repo}] enabled=$${enabled}"; \
		if [[ "$$enabled" == "true" ]]; then \
			if ! git config -f .gitmodules --get "submodule.custom/themes/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Registering submodule..."; \
				git submodule add "git@github.com:$${owner}/$${repo}.git" "custom/themes/$${repo}"; \
			fi; \
			echo "    Initializing..."; \
			git submodule update --init "custom/themes/$${repo}"; \
			if [[ -n "$$exec_cmd" && "$$exec_cmd" != "null" && "$$exec_cmd" != "''" && "$$exec_cmd" != "" ]]; then \
				echo "    Running post-init command: $${exec_cmd}"; \
				(cd "custom/themes/$${repo}" && eval "$$exec_cmd"); \
			fi; \
		else \
			if git config -f .gitmodules --get "submodule.custom/themes/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Deinitializing..."; \
				git submodule deinit -f "custom/themes/$${repo}" 2>/dev/null || true; \
			else \
				echo "    ✓ Already inactive"; \
			fi; \
		fi; \
	done
	@echo "Done."
