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
#   DOT_DRY_RUN=1  print planned changes, do not mutate
#   DOT_DEBUG=1    enable bash xtrace (-x)
#   DOT_VERBOSE=1  pass --verbose to git submodule operations
# ──────────────────────────────────────────────────────────────────────────────

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

# ── Parameters ────────────────────────────────────────────────────────────────
CONFIG ?= ../../data/zsh.yaml
OWNER  ?=
REPO   ?=
EXEC   ?=
DOT_DRY_RUN ?= 0
DOT_DEBUG   ?= 0
DOT_VERBOSE ?= 0

RECIPE_ENV := set -euo pipefail; \
	if [[ "$(DOT_DEBUG)" == "1" ]]; then set -x; fi; \
	dry="$(DOT_DRY_RUN)"; \
	vflag=""; \
	if [[ "$(DOT_VERBOSE)" == "1" ]]; then vflag="--verbose"; fi

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
	@echo "  DOT_DRY_RUN=1   preview only, no mutations"
	@echo "  DOT_DEBUG=1     enable xtrace"
	@echo "  DOT_VERBOSE=1   verbose git submodule output"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# ══════════════════════════════════════════════════════════════════════════════
# Targets
# ══════════════════════════════════════════════════════════════════════════════

install: ## Initialize and update all submodules from .gitmodules
	@$(RECIPE_ENV); \
	echo "Initializing submodules..."; \
	if [[ "$$dry" == "1" ]]; then \
		echo "[dry-run] git submodule init"; \
	else \
		git submodule init; \
	fi; \
	if [[ "$$dry" == "1" ]]; then \
		echo "[dry-run] git submodule update $$vflag --recursive"; \
	else \
		git submodule update $$vflag --recursive; \
	fi; \
	echo "Done."

add-plugin: ## Add a custom plugin (OWNER, REPO required; EXEC optional)
	$(require_yq)
	$(require_params)
	@echo "Adding plugin: $(OWNER)/$(REPO)"
	@if yq -e '.plugins.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)")' "$(CONFIG)" >/dev/null 2>&1; then \
		echo "  ✓ Already in $(CONFIG)"; \
	else \
		echo "  Adding to $(CONFIG)..."; \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] yq -i '.plugins.custom += [{\"owner\": \"$(OWNER)\", \"repo\": \"$(REPO)\", \"exec\": \"$(EXEC)\", \"enabled\": true}]' '$(CONFIG)'"; \
		else \
			yq -i '.plugins.custom += [{"owner": "$(OWNER)", "repo": "$(REPO)", "exec": "$(EXEC)", "enabled": true}]' "$(CONFIG)"; \
		fi; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/plugins/$(REPO).url" >/dev/null 2>&1; then \
		echo "  ✓ Submodule already registered in .gitmodules"; \
	else \
		echo "  Registering submodule..."; \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] git submodule add $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) git@github.com:$(OWNER)/$(REPO).git custom/plugins/$(REPO)"; \
		else \
			git submodule add $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) "git@github.com:$(OWNER)/$(REPO).git" "custom/plugins/$(REPO)"; \
		fi; \
	fi
	@echo "  Initializing submodule..."
	@if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
		echo "[dry-run] git submodule update --init $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) custom/plugins/$(REPO)"; \
	else \
		git submodule update --init $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) "custom/plugins/$(REPO)"; \
	fi
	@if [[ -n "$(EXEC)" ]]; then \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "  [dry-run] post-init command skipped: (cd custom/plugins/$(REPO) && $(EXEC))"; \
		else \
			echo "  Running post-init command: $(EXEC)"; \
			cd "custom/plugins/$(REPO)" && $(EXEC); \
		fi; \
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
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] yq -i '.themes.custom += [{\"owner\": \"$(OWNER)\", \"repo\": \"$(REPO)\", \"exec\": \"$(EXEC)\", \"enabled\": true}]' '$(CONFIG)'"; \
		else \
			yq -i '.themes.custom += [{"owner": "$(OWNER)", "repo": "$(REPO)", "exec": "$(EXEC)", "enabled": true}]' "$(CONFIG)"; \
		fi; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/themes/$(REPO).url" >/dev/null 2>&1; then \
		echo "  ✓ Submodule already registered in .gitmodules"; \
	else \
		echo "  Registering submodule..."; \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] git submodule add $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) git@github.com:$(OWNER)/$(REPO).git custom/themes/$(REPO)"; \
		else \
			git submodule add $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) "git@github.com:$(OWNER)/$(REPO).git" "custom/themes/$(REPO)"; \
		fi; \
	fi
	@echo "  Initializing submodule..."
	@if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
		echo "[dry-run] git submodule update --init $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) custom/themes/$(REPO)"; \
	else \
		git submodule update --init $$([[ "$(DOT_VERBOSE)" == "1" ]] && echo --verbose) "custom/themes/$(REPO)"; \
	fi
	@if [[ -n "$(EXEC)" ]]; then \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "  [dry-run] post-init command skipped: (cd custom/themes/$(REPO) && $(EXEC))"; \
		else \
			echo "  Running post-init command: $(EXEC)"; \
			cd "custom/themes/$(REPO)" && $(EXEC); \
		fi; \
	fi
	@echo "Done."

remove-plugin: ## Remove a custom plugin (OWNER, REPO required)
	$(require_yq)
	$(require_params)
	@echo "Removing plugin: $(OWNER)/$(REPO)"
	@if yq -e '.plugins.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)")' "$(CONFIG)" >/dev/null 2>&1; then \
		echo "  Removing from $(CONFIG)..."; \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] yq -i 'del(.plugins.custom[] | select(.owner == \"$(OWNER)\" and .repo == \"$(REPO)\"))' '$(CONFIG)'"; \
		else \
			yq -i 'del(.plugins.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)"))' "$(CONFIG)"; \
		fi; \
	else \
		echo "  ✓ Not in $(CONFIG)"; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/plugins/$(REPO).url" >/dev/null 2>&1; then \
		echo "  Removing submodule..."; \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] git submodule deinit -f custom/plugins/$(REPO)"; \
			echo "[dry-run] git rm -f custom/plugins/$(REPO)"; \
			echo "[dry-run] rm -rf .git/modules/custom/plugins/$(REPO)"; \
		else \
			git submodule deinit -f "custom/plugins/$(REPO)" 2>/dev/null || true; \
			git rm -f "custom/plugins/$(REPO)" 2>/dev/null || true; \
			rm -rf ".git/modules/custom/plugins/$(REPO)"; \
		fi; \
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
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] yq -i 'del(.themes.custom[] | select(.owner == \"$(OWNER)\" and .repo == \"$(REPO)\"))' '$(CONFIG)'"; \
		else \
			yq -i 'del(.themes.custom[] | select(.owner == "$(OWNER)" and .repo == "$(REPO)"))' "$(CONFIG)"; \
		fi; \
	else \
		echo "  ✓ Not in $(CONFIG)"; \
	fi
	@if git config -f .gitmodules --get "submodule.custom/themes/$(REPO).url" >/dev/null 2>&1; then \
		echo "  Removing submodule..."; \
		if [[ "$(DOT_DRY_RUN)" == "1" ]]; then \
			echo "[dry-run] git submodule deinit -f custom/themes/$(REPO)"; \
			echo "[dry-run] git rm -f custom/themes/$(REPO)"; \
			echo "[dry-run] rm -rf .git/modules/custom/themes/$(REPO)"; \
		else \
			git submodule deinit -f "custom/themes/$(REPO)" 2>/dev/null || true; \
			git rm -f "custom/themes/$(REPO)" 2>/dev/null || true; \
			rm -rf ".git/modules/custom/themes/$(REPO)"; \
		fi; \
	else \
		echo "  ✓ Submodule not registered in .gitmodules"; \
	fi
	@echo "Done."

sync-plugins: ## Reconcile plugin submodules from data file
	$(require_yq)
	@$(RECIPE_ENV); \
	echo "Syncing plugins from $(CONFIG)..."; \
	count=$$(yq '.plugins.custom | length' "$(CONFIG)"); \
	for i in $$(seq 0 $$((count - 1))); do \
		owner=$$(yq ".plugins.custom[$$i].owner" "$(CONFIG)"); \
		repo=$$(yq ".plugins.custom[$$i].repo" "$(CONFIG)"); \
		exec_cmd=$$(yq ".plugins.custom[$$i].exec" "$(CONFIG)"); \
		enabled=$$(yq ".plugins.custom[$$i].enabled" "$(CONFIG)"); \
		echo "  [$${owner}/$${repo}] enabled=$${enabled}"; \
		if [[ "$$enabled" == "true" ]]; then \
			if ! git config -f .gitmodules --get "submodule.custom/plugins/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Registering submodule..."; \
				if [[ "$$dry" == "1" ]]; then \
					echo "[dry-run] git submodule add $$vflag git@github.com:$${owner}/$${repo}.git custom/plugins/$${repo}"; \
				else \
					git submodule add $$vflag "git@github.com:$${owner}/$${repo}.git" "custom/plugins/$${repo}"; \
				fi; \
			fi; \
			echo "    Initializing..."; \
			if [[ "$$dry" == "1" ]]; then \
				echo "[dry-run] git submodule update --init $$vflag custom/plugins/$${repo}"; \
			else \
				git submodule update --init $$vflag "custom/plugins/$${repo}"; \
			fi; \
			if [[ -n "$$exec_cmd" && "$$exec_cmd" != "null" && "$$exec_cmd" != "''" && "$$exec_cmd" != "" ]]; then \
				if [[ "$$dry" == "1" ]]; then \
					echo "    [dry-run] post-init command skipped: (cd custom/plugins/$${repo} && $${exec_cmd})"; \
				else \
					echo "    Running post-init command: $${exec_cmd}"; \
					(cd "custom/plugins/$${repo}" && eval "$$exec_cmd"); \
				fi; \
			fi; \
		else \
			if git config -f .gitmodules --get "submodule.custom/plugins/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Deinitializing..."; \
				if [[ "$$dry" == "1" ]]; then \
					echo "[dry-run] git submodule deinit -f custom/plugins/$${repo}"; \
				else \
					git submodule deinit -f "custom/plugins/$${repo}" 2>/dev/null || true; \
				fi; \
			else \
				echo "    ✓ Already inactive"; \
			fi; \
		fi; \
	done
	@echo "Done."




sync-themes: ## Reconcile theme submodules from data file
	$(require_yq)
	@$(RECIPE_ENV); \
	echo "Syncing themes from $(CONFIG)..."; \
	count=$$(yq '.themes.custom | length' "$(CONFIG)"); \
	for i in $$(seq 0 $$((count - 1))); do \
		owner=$$(yq ".themes.custom[$$i].owner" "$(CONFIG)"); \
		repo=$$(yq ".themes.custom[$$i].repo" "$(CONFIG)"); \
		exec_cmd=$$(yq ".themes.custom[$$i].exec" "$(CONFIG)"); \
		enabled=$$(yq ".themes.custom[$$i].enabled" "$(CONFIG)"); \
		echo "  [$${owner}/$${repo}] enabled=$${enabled}"; \
		if [[ "$$enabled" == "true" ]]; then \
			if ! git config -f .gitmodules --get "submodule.custom/themes/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Registering submodule..."; \
				if [[ "$$dry" == "1" ]]; then \
					echo "[dry-run] git submodule add $$vflag git@github.com:$${owner}/$${repo}.git custom/themes/$${repo}"; \
				else \
					git submodule add $$vflag "git@github.com:$${owner}/$${repo}.git" "custom/themes/$${repo}"; \
				fi; \
			fi; \
			echo "    Initializing..."; \
			if [[ "$$dry" == "1" ]]; then \
				echo "[dry-run] git submodule update --init $$vflag custom/themes/$${repo}"; \
			else \
				git submodule update --init $$vflag "custom/themes/$${repo}"; \
			fi; \
			if [[ -n "$$exec_cmd" && "$$exec_cmd" != "null" && "$$exec_cmd" != "''" && "$$exec_cmd" != "" ]]; then \
				if [[ "$$dry" == "1" ]]; then \
					echo "    [dry-run] post-init command skipped: (cd custom/themes/$${repo} && $${exec_cmd})"; \
				else \
					echo "    Running post-init command: $${exec_cmd}"; \
					(cd "custom/themes/$${repo}" && eval "$$exec_cmd"); \
				fi; \
			fi; \
		else \
			if git config -f .gitmodules --get "submodule.custom/themes/$${repo}.url" >/dev/null 2>&1; then \
				echo "    Deinitializing..."; \
				if [[ "$$dry" == "1" ]]; then \
					echo "[dry-run] git submodule deinit -f custom/themes/$${repo}"; \
				else \
					git submodule deinit -f "custom/themes/$${repo}" 2>/dev/null || true; \
				fi; \
			else \
				echo "    ✓ Already inactive"; \
			fi; \
		fi; \
	done
	@echo "Done."
