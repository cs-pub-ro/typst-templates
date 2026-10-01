# ============================================================
#  Makefile — typst-templates
#  Install, build and test for the Typst templates.
#  Run `make help` for the list of commands.
# ============================================================

# Allow overriding the typst binary: `make thesis TYPST=/path/typst`
TYPST       ?= typst
BUILD_DIR   ?= build
ROOT        ?= .

# Optional config overrides.
# Note: we use THESIS_LANG (not LANG) to avoid clashing with the shell's LANG
# environment variable.
THESIS_LANG ?=
TYPE        ?=
DEPT        ?=

# Build the --input list only for the variables that are set.
INPUTS :=
ifneq ($(THESIS_LANG),)
INPUTS += --input language=$(THESIS_LANG)
endif
ifneq ($(TYPE),)
INPUTS += --input thesis_type=$(TYPE)
endif
ifneq ($(DEPT),)
INPUTS += --input department=$(DEPT)
endif

# Detect the operating system for the `install` target.
UNAME_S := $(shell uname -s)

.DEFAULT_GOAL := help

# ------------------------------------------------------------
.PHONY: help
help: ## Show this list of commands
	@echo "typst-templates — available commands:"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Config override (optional): make thesis THESIS_LANG=ro TYPE=master DEPT=acse"

# ------------------------------------------------------------
.PHONY: install
install: ## Install Typst + Liberation fonts (apt/brew, with fallback)
	@echo ">> Checking Typst..."
	@if command -v $(TYPST) >/dev/null 2>&1; then \
		echo "   Typst is already installed: $$($(TYPST) --version 2>/dev/null || echo ok)"; \
	else \
		echo "   Typst is missing — attempting install..."; \
		if [ "$(UNAME_S)" = "Darwin" ]; then \
			if command -v brew >/dev/null 2>&1; then brew install typst; \
			else echo "   ! Homebrew is missing. Install it from https://brew.sh then: brew install typst"; fi; \
		elif [ "$(UNAME_S)" = "Linux" ]; then \
			if command -v snap >/dev/null 2>&1; then sudo snap install typst; \
			elif command -v cargo >/dev/null 2>&1; then cargo install --locked typst-cli; \
			else echo "   ! Cannot install automatically. See https://github.com/typst/typst#installation"; fi; \
		else \
			echo "   ! Unknown OS ($(UNAME_S)). See https://github.com/typst/typst#installation"; \
		fi; \
	fi
	@echo ">> Checking fonts (Liberation = Times/Courier metric-compatible)..."
	@if command -v fc-list >/dev/null 2>&1 && fc-list 2>/dev/null | grep -qi "Liberation Serif"; then \
		echo "   Liberation fonts are installed."; \
	else \
		echo "   Liberation fonts are missing — attempting install..."; \
		if [ "$(UNAME_S)" = "Darwin" ]; then \
			if command -v brew >/dev/null 2>&1; then brew install --cask font-liberation || true; \
			else echo "   ! Install the Liberation font manually (Homebrew)."; fi; \
		elif [ "$(UNAME_S)" = "Linux" ]; then \
			if command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y fonts-liberation; \
			elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y liberation-fonts; \
			elif command -v pacman >/dev/null 2>&1; then sudo pacman -S --noconfirm ttf-liberation; \
			else echo "   ! Install the Liberation fonts package manually."; fi; \
		fi; \
	fi
	@echo ">> Done. Run 'make check' for a full verification."

# ------------------------------------------------------------
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

.PHONY: thesis
thesis: | $(BUILD_DIR) ## Compile the thesis -> build/thesis.pdf
	$(TYPST) compile --root $(ROOT) $(INPUTS) thesis/main.typ $(BUILD_DIR)/thesis.pdf
	@echo "OK: $(BUILD_DIR)/thesis.pdf"

.PHONY: presentation
presentation: | $(BUILD_DIR) ## Compile the presentation -> build/presentation.pdf (first run downloads packages)
	$(TYPST) compile --root $(ROOT) $(INPUTS) thesis/presentation.typ $(BUILD_DIR)/presentation.pdf
	@echo "OK: $(BUILD_DIR)/presentation.pdf"

.PHONY: pdf
pdf: thesis presentation ## Compile both PDFs

# ------------------------------------------------------------
.PHONY: check
check: ## Run the verification suite (thesis + presentation)
	./scripts/check-all.sh

# ------------------------------------------------------------
.PHONY: clean
clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR)
	@echo "Cleaned $(BUILD_DIR)/"
