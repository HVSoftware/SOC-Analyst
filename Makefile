# SOC-Analyst Splunk App - Development Makefile
# 
# Usage:
#   make build     - Build .splunk package
#   make deploy    - Deploy to local Splunk instance
#   make validate  - Validate app structure and XML
#   make test      - Run saved search tests
#   make clean     - Remove build artifacts
#   make logs      - Tail Splunk error logs
#   make restart   - Restart local Splunk instance

SPLUNK_HOME ?= /opt/splunk
SPLUNK_APP_DIR ?= $(SPLUNK_HOME)/etc/apps
APP_NAME := SOC-Analyst
APP_PACKAGE := $(APP_NAME).splunk

.PHONY: all help build deploy validate test clean logs restart dev-deploy watch-logs package

all: help

help:
	@echo "========================================"
	@echo "SOC-Analyst Development Commands"
	@echo "========================================"
	@echo ""
	@echo "Build & Deploy:"
	@echo "  make build       - Build .splunk package"
	@echo "  make deploy      - Deploy to local Splunk instance"
	@echo "  make dev-deploy  - Deploy and restart Splunk"
	@echo "  make package     - Build package (alias for build)"
	@echo ""
	@echo "Validation & Testing:"
	@echo "  make validate    - Validate app structure and XML"
	@echo "  make test        - Run saved search tests"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean       - Remove build artifacts"
	@echo "  make logs        - Tail Splunk error logs"
	@echo "  make watch-logs  - Tail logs filtered by app name"
	@echo "  make restart     - Restart local Splunk instance"
	@echo ""
	@echo "Configuration:"
	@echo "  SPLUNK_HOME=$(SPLUNK_HOME)"
	@echo "  SPLUNK_APP_DIR=$(SPLUNK_APP_DIR)"
	@echo ""

build:
	@echo "Building $(APP_PACKAGE)..."
	@tar -czf $(APP_PACKAGE) \
		--exclude='.git' \
		--exclude='*.md' \
		--exclude='user-stories' \
		--exclude='$(APP_PACKAGE)' \
		default metadata static bin lookups
	@echo "✓ Build complete: $(APP_PACKAGE)"
	@ls -lh $(APP_PACKAGE)

deploy: build
	@echo "Deploying to $(SPLUNK_APP_DIR)/$(APP_NAME)..."
	@mkdir -p $(SPLUNK_APP_DIR)/$(APP_NAME)
	@cp -r default metadata static bin lookups $(SPLUNK_APP_DIR)/$(APP_NAME)/
	@echo "✓ Deployed to $(SPLUNK_APP_DIR)/$(APP_NAME)"
	@echo ""
	@echo "Restart Splunk to load changes: make restart"
	@echo "Or use: make dev-deploy (deploy + restart)"

validate:
	@echo "========================================"
	@echo "Validating app structure..."
	@echo "========================================"
	@test -d default || (echo "✗ default/ directory missing" && exit 1)
	@echo "✓ default/ directory exists"
	@test -d metadata || (echo "✗ metadata/ directory missing" && exit 1)
	@echo "✓ metadata/ directory exists"
	@test -f default/app.conf || (echo "✗ default/app.conf missing" && exit 1)
	@echo "✓ default/app.conf exists"
	@echo ""
	@echo "Validating XML dashboards..."
	@if command -v xmllint >/dev/null 2>&1; then \
		for f in default/data/ui/views/*.xml; do \
			if ! xmllint --noout "$$f" 2>/dev/null; then \
				echo "✗ Invalid XML: $$f"; \
				exit 1; \
			fi; \
			echo "✓ $$f"; \
		done; \
		echo ""; \
		echo "Validating navigation XML..."; \
		if ! xmllint --noout default/data/ui/nav/default.xml 2>/dev/null; then \
			echo "✗ Invalid XML: default/data/ui/nav/default.xml"; \
			exit 1; \
		fi; \
		echo "✓ default/data/ui/nav/default.xml"; \
	else \
		echo "⚠ xmllint not installed. Install with: sudo apt install libxml2-utils"; \
		echo "  Skipping XML validation..."; \
	fi
	@echo ""
	@echo "✓ All validations passed"

test:
	@echo "========================================"
	@echo "Running saved search tests..."
	@echo "========================================"
	@if [ -f default/savedsearches.conf ]; then \
		echo "✓ savedsearches.conf found"; \
		COUNT=$$(grep -c "^\[" default/savedsearches.conf 2>/dev/null || echo 0); \
		echo "  Found $$COUNT saved searches"; \
		echo ""; \
		echo "Saved searches:"; \
		grep "^\[" default/savedsearches.conf | sed 's/^/  - /'; \
	else \
		echo "⚠ No savedsearches.conf found"; \
	fi
	@echo ""
	@echo "✓ Test complete"
	@echo ""
	@echo "Note: Full testing requires Splunk instance."
	@echo "Deploy with 'make deploy' and test searches manually in Splunk."

clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(APP_PACKAGE)
	@rm -rf __pycache__
	@find . -name "*.pyc" -delete
	@echo "✓ Clean complete"

logs:
	@echo "Tailing Splunk error logs..."
	@echo "Log file: $(SPLUNK_HOME)/var/log/splunk/splunkd.log"
	@echo "Press Ctrl+C to stop"
	@echo ""
	@tail -f $(SPLUNK_HOME)/var/log/splunk/splunkd.log

restart:
	@echo "Restarting Splunk..."
	@if [ -x $(SPLUNK_HOME)/bin/splunk ]; then \
		$(SPLUNK_HOME)/bin/splunk restart; \
		echo "✓ Splunk restarted"; \
	else \
		echo "⚠ Splunk binary not found at $(SPLUNK_HOME)/bin/splunk"; \
		echo "  Set SPLUNK_HOME environment variable if Splunk is installed elsewhere."; \
		echo "  Example: make restart SPLUNK_HOME=/opt/splunk"; \
		exit 1; \
	fi

# Development helpers
dev-deploy: deploy
	@echo ""
	@echo "Restarting Splunk..."
	@if [ -x $(SPLUNK_HOME)/bin/splunk ]; then \
		$(SPLUNK_HOME)/bin/splunk restart; \
		echo "✓ Deployed and restarted"; \
	else \
		echo "⚠ Splunk binary not found. Manual restart required."; \
		echo "  Deployed files to: $(SPLUNK_APP_DIR)/$(APP_NAME)"; \
		echo "  Restart Splunk manually to load changes."; \
	fi

watch-logs:
	@echo "Tailing Splunk logs filtered by $(APP_NAME)..."
	@echo "Press Ctrl+C to stop"
	@echo ""
	@tail -f $(SPLUNK_HOME)/var/log/splunk/splunkd.log | grep -i "$(APP_NAME)"

package: build
	@echo ""
	@echo "✓ Package ready for distribution: $(APP_PACKAGE)"
	@echo "  Size: $$(du -h $(APP_PACKAGE) | cut -f1)"
	@echo "  To install: Upload to Splunk via Settings → Manage Apps → Install App from File"

# Quick deployment for development
dev: clean build deploy
	@echo ""
	@echo "✓ Development build deployed"
	@echo "  Restart Splunk manually or run: make restart"
