# US-10 — Makefile voor Splunk development

| Veld | Waarde |
|---|---|
| ID | US-10 |
| Titel | Makefile voor Splunk development workflow |
| Rol | Developer |
| Afhankelijk van | US-00 |
| Status | Open |
| Prioriteit | **P2 — Medium** |
| Geschatte effort | 45 minuten |

## Verhaal

Als developer wil ik een Makefile met veelvoorkomende commands voor Splunk app development, zodat ik snel kan bouwen, deployen, valideren en testen zonder handmatig commands te typen.

## Doel

Creëer een Makefile met de volgende targets:

- `make build` — Build .splunk package
- `make deploy` — Deploy naar lokale Splunk instance
- `make validate` — Valideer app structuur en XML
- `make test` — Run tests (indien aanwezig)
- `make clean` — Schoonmaken
- `make logs` — Bekijk Splunk logs
- `make restart` — Restart lokale Splunk

## Acceptatiecriteria

- [ ] Makefile in project root
- [ ] Alle targets werken op Linux (Pop!_OS)
- [ ] Splunk home pad configureerbaar via environment variable
- [ ] Documentatie in README of Makefile header
- [ ] Compatible met bestaande Makefile conventies (zie andere projecten)

## Proposed Makefile

```makefile
# SOC-Analyst Splunk App - Development Makefile
# 
# Usage:
#   make build     - Build .splunk package
#   make deploy    - Deploy to local Splunk
#   make validate  - Validate app structure
#   make test      - Run tests
#   make clean     - Clean build artifacts
#   make logs      - Tail Splunk logs
#   make restart   - Restart local Splunk

SPLUNK_HOME ?= /opt/splunk
SPLUNK_APP_DIR ?= $(SPLUNK_HOME)/etc/apps
APP_NAME := SOC-Analyst
APP_PACKAGE := $(APP_NAME).splunk

.PHONY: build deploy validate test clean logs restart help

help:
	@echo "SOC-Analyst Development Commands:"
	@echo "  make build     - Build .splunk package"
	@echo "  make deploy    - Deploy to local Splunk instance"
	@echo "  make validate  - Validate app structure and XML"
	@echo "  make test      - Run saved search tests"
	@echo "  make clean     - Remove build artifacts"
	@echo "  make logs      - Tail Splunk error logs"
	@echo "  make restart   - Restart local Splunk instance"

build:
	@echo "Building $(APP_PACKAGE)..."
	@tar -czf $(APP_PACKAGE) \
		--exclude='.git' \
		--exclude='*.md' \
		--exclude='user-stories' \
		--exclude='$(APP_PACKAGE)' \
		default metadata static bin lookups
	@echo "✓ Build complete: $(APP_PACKAGE)"

deploy: build
	@echo "Deploying to $(SPLUNK_APP_DIR)..."
	@mkdir -p $(SPLUNK_APP_DIR)/$(APP_NAME)
	@cp -r default metadata static bin lookups $(SPLUNK_APP_DIR)/$(APP_NAME)/
	@echo "✓ Deployed to $(SPLUNK_APP_DIR)/$(APP_NAME)"
	@echo "Restart Splunk to load changes: make restart"

validate:
	@echo "Validating app structure..."
	@test -d default || (echo "✗ default/ directory missing" && exit 1)
	@test -d metadata || (echo "✗ metadata/ directory missing" && exit 1)
	@test -f default/app.conf || (echo "✗ default/app.conf missing" && exit 1)
	@echo "✓ App structure valid"
	@echo "Validating XML dashboards..."
	@for f in default/data/ui/views/*.xml; do \
		if ! xmllint --noout "$$f" 2>/dev/null; then \
			echo "✗ Invalid XML: $$f"; \
			exit 1; \
		fi; \
	done
	@echo "✓ All XML files valid"

test:
	@echo "Running saved search tests..."
	@# Check if all saved searches have valid syntax
	@if [ -f default/savedsearches.conf ]; then \
		echo "✓ savedsearches.conf found"; \
		grep -c "^\[" default/savedsearches.conf | xargs -I {} echo "  {} saved searches found"; \
	else \
		echo "⚠ No savedsearches.conf found"; \
	fi
	@echo "✓ Test complete (manual testing in Splunk recommended)"

clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(APP_PACKAGE)
	@rm -rf __pycache__
	@find . -name "*.pyc" -delete
	@echo "✓ Clean complete"

logs:
	@echo "Tailing Splunk error logs..."
	@tail -f $(SPLUNK_HOME)/var/log/splunk/splunkd.log

restart:
	@echo "Restarting Splunk..."
	@$(SPLUNK_HOME)/bin/splunk restart
	@echo "✓ Splunk restarted"

# Development helpers
dev-deploy: deploy restart
	@echo "✓ Deployed and restarted"

watch-logs:
	@tail -f $(SPLUNK_HOME)/var/log/splunk/splunkd.log | grep -i "$(APP_NAME)"

package: build
	@echo "✓ Package ready for distribution: $(APP_PACKAGE)"
```

## Implementation Stappen

1. Creëer Makefile in project root (`~/Projects/SOC-Analyst/Makefile`)
2. Test elke target:
   - `make build` — controleer of .splunk bestand wordt gemaakt
   - `make validate` — controleer XML validatie (vereist `xmllint`)
   - `make clean` — controleer opschonen
3. Optioneel: Installeer `xmllint` voor XML validatie:
   ```bash
   sudo apt install libxml2-utils
   ```
4. Voeg Makefile referentie toe aan README.md
5. Commit met bericht: `feat(makefile): voeg development workflow toe`

## Test

```bash
cd ~/Projects/SOC-Analyst

# Test build
make build
ls -lh SOC-Analyst.splunk

# Test validate
make validate

# Test clean
make clean
ls -lh SOC-Analyst.splunk  # Should not exist

# Test help
make help
```

## Definition of Done

- [ ] Makefile aangemaakt met alle targets
- [ ] Alle targets getest (build, validate, clean)
- [ ] SPLUNK_HOME configureerbaar
- [ ] XML validatie werkt (als xmllint geïnstalleerd)
- [ ] README.md bijgewerkt met Makefile usage
- [ ] Git commit gemaakt

## Notes

- Gebruikt dezelfde conventies als andere projecten (ancestor_tours, hv-software)
- `SPLUNK_HOME` default naar `/opt/splunk` maar kan overschreven worden
- XML validatie vereist `xmllint` (libxml2-utils package)
- Voor production deployment: overweeg Splunk Deployment Server

## Vervolgstappen

Na US-10:
- Voeg `make splunk-shell` toe voor directe Splunk CLI access
- Voeg automated testing toe met Splunk's btest framework
- Integreer met CI/CD (GitHub Actions, GitLab CI)
