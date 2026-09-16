# SOC-Analyst Splunk App - Development Makefile
# 
# Usage:
#   make build         - Build .splunk package
#   make deploy        - Deploy to local Splunk instance
#   make deploy-remote - Deploy to remote Splunk server via SCP
#   make validate      - Validate app structure and XML
#   make test          - Run saved search tests
#   make clean         - Remove build artifacts
#   make docker-start  - Start local Splunk in Docker
#   make docker-stop   - Stop local Splunk Docker container
#   make docker-logs   - View Docker container logs
#   make package       - Build package for distribution

SPLUNK_HOME ?= /opt/splunk
SPLUNK_APP_DIR ?= $(SPLUNK_HOME)/etc/apps
APP_NAME := SOC-Analyst
APP_PACKAGE := $(APP_NAME).spl

# Docker settings
DOCKER_CONTAINER ?= splunk
DOCKER_PORT_WEB ?= 8000
DOCKER_PORT_MGMT ?= 8089
DOCKER_PASSWORD ?= ChangeMe123!

# Remote deployment settings
SPLUNK_REMOTE_USER ?= admin
SPLUNK_REMOTE_HOST ?= splunk-server.example.com
SPLUNK_REMOTE_PATH ?= /tmp

.PHONY: all help build deploy deploy-remote validate test clean package \
        docker-start docker-stop docker-logs docker-restart

all: help

help:
	@echo "========================================"
	@echo "SOC-Analyst Development Commands"
	@echo "========================================"
	@echo ""
	@echo "Build & Deploy:"
	@echo "  make build         - Build .splunk package"
	@echo "  make deploy        - Deploy to local Splunk instance"
	@echo "  make deploy-remote - Deploy to remote Splunk server (via SCP)"
	@echo "  make package       - Build package with info (alias for build)"
	@echo ""
	@echo "Docker (Local Testing):"
	@echo "  make docker-start  - Start Splunk Enterprise in Docker"
	@echo "  make docker-stop   - Stop Splunk Docker container"
	@echo "  make docker-restart- Restart Splunk Docker container"
	@echo "  make docker-logs   - View Docker container logs"
	@echo "  make docker-status - Show Docker container status"
	@echo ""
	@echo "Validation & Testing:"
	@echo "  make validate      - Validate app structure and XML"
	@echo "  make test          - Run saved search tests"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean         - Remove build artifacts"
	@echo ""
	@echo "Configuration:"
	@echo "  SPLUNK_HOME=$(SPLUNK_HOME)"
	@echo "  SPLUNK_APP_DIR=$(SPLUNK_APP_DIR)"
	@echo "  DOCKER_CONTAINER=$(DOCKER_CONTAINER)"
	@echo "  DOCKER_PORT_WEB=$(DOCKER_PORT_WEB)"
	@echo "  DOCKER_PORT_MGMT=$(DOCKER_PORT_MGMT)"
	@echo ""
	@echo "Remote Deployment:"
	@echo "  SPLUNK_REMOTE_USER=$(SPLUNK_REMOTE_USER)"
	@echo "  SPLUNK_REMOTE_HOST=$(SPLUNK_REMOTE_HOST)"
	@echo "  SPLUNK_REMOTE_PATH=$(SPLUNK_REMOTE_PATH)"
	@echo ""
	@echo "Override: make deploy SPLUNK_HOME=/custom/path"
	@echo ""

build:
	@echo "Building $(APP_PACKAGE)..."
	@tar -czf $(APP_PACKAGE) \
		--exclude='.git' \
		--exclude='*.md' \
		--exclude='user-stories' \
		--exclude='$(APP_PACKAGE)' \
		--exclude='docker-compose.yml' \
		default metadata static bin lookups
	@echo "✓ Build complete: $(APP_PACKAGE)"
	@ls -lh $(APP_PACKAGE)

deploy: build
	@echo "Deploying to $(SPLUNK_APP_DIR)/$(APP_NAME)..."
	@if [ -d "$(SPLUNK_APP_DIR)" ]; then \
		mkdir -p $(SPLUNK_APP_DIR)/$(APP_NAME); \
		cp -r default metadata static bin lookups $(SPLUNK_APP_DIR)/$(APP_NAME)/; \
		echo "✓ Deployed to $(SPLUNK_APP_DIR)/$(APP_NAME)"; \
		echo ""; \
		if [ -x "$(SPLUNK_HOME)/bin/splunk" ]; then \
			echo "Restart Splunk: make restart"; \
		else \
			echo "⚠ Splunk binary not found at $(SPLUNK_HOME)/bin/splunk"; \
			echo "  Manual reload required:"; \
			echo "  1. Open Splunk Web"; \
			echo "  2. Go to Settings → Manage Apps"; \
			echo "  3. Click 'Refresh' or restart Splunk"; \
		fi; \
	else \
		echo "✗ SPLUNK_APP_DIR not found: $(SPLUNK_APP_DIR)"; \
		echo "  Use 'make deploy SPLUNK_HOME=/path/to/splunk'"; \
		echo "  Or use 'make deploy-remote' for remote deployment"; \
		exit 1; \
	fi

deploy-remote: build
	@echo "Deploying to remote Splunk server..."
	@echo "Target: $(SPLUNK_REMOTE_USER)@$(SPLUNK_REMOTE_HOST):$(SPLUNK_REMOTE_PATH)"
	@echo ""
	@echo "Step 1: Copy package to remote server"
	@scp $(APP_PACKAGE) $(SPLUNK_REMOTE_USER)@$(SPLUNK_REMOTE_HOST):$(SPLUNK_REMOTE_PATH)/
	@echo "✓ Package copied to remote server"
	@echo ""
	@echo "Step 2: Install on remote server"
	@echo "  SSH into $(SPLUNK_REMOTE_HOST) and run:"
	@echo "  sudo /opt/splunk/bin/splunk install app $(SPLUNK_REMOTE_PATH)/$(APP_PACKAGE) -auth admin:YOUR_PASSWORD"
	@echo "  sudo /opt/splunk/bin/splunk restart"
	@echo ""
	@echo "Or use one-click install (requires password):"
	@echo "  make deploy-remote-install SPLUNK_REMOTE_PASSWORD=your_password"

deploy-remote-install: build
	@echo "Deploying and installing on remote Splunk server..."
	@scp $(APP_PACKAGE) $(SPLUNK_REMOTE_USER)@$(SPLUNK_REMOTE_HOST):$(SPLUNK_REMOTE_PATH)/
	@ssh $(SPLUNK_REMOTE_USER)@$(SPLUNK_REMOTE_HOST) \
		"sudo /opt/splunk/bin/splunk install app $(SPLUNK_REMOTE_PATH)/$(APP_PACKAGE) -auth admin:$(SPLUNK_REMOTE_PASSWORD) && sudo /opt/splunk/bin/splunk restart"
	@echo "✓ Deployed and restarted remote Splunk"

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
	@echo "Use 'make docker-start' for local testing."

clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(APP_PACKAGE)
	@rm -rf __pycache__
	@find . -name "*.pyc" -delete
	@echo "✓ Clean complete"

package: build
	@echo ""
	@echo "✓ Package ready for distribution: $(APP_PACKAGE)"
	@echo "  Size: $$(du -h $(APP_PACKAGE) | cut -f1)"
	@echo "  To install: Upload to Splunk via Settings → Manage Apps → Install App from File"

# Docker commands for local Splunk testing
docker-start:
	@echo "Starting Splunk Enterprise in Docker..."
	@echo ""
	@echo "Container: $(DOCKER_CONTAINER)"
	@echo "Web UI: http://localhost:$(DOCKER_PORT_WEB) (admin / $(DOCKER_PASSWORD))"
	@echo "Management: https://localhost:$(DOCKER_PORT_MGMT)"
	@echo ""
	@if docker ps | grep -q $(DOCKER_CONTAINER); then \
		echo "⚠ Container already running"; \
	else \
		docker run -d --name $(DOCKER_CONTAINER) \
			-p $(DOCKER_PORT_WEB):8000 \
			-p $(DOCKER_PORT_MGMT):8089 \
			-e SPLUNK_START_ARGS=--accept-license \
			-e SPLUNK_PASSWORD=$(DOCKER_PASSWORD) \
			splunk/splunk:latest; \
		echo ""; \
		echo "✓ Container started"; \
		echo ""; \
		echo "⏳ Waiting for Splunk to start (this takes 2-3 minutes)..."; \
		sleep 5; \
		echo "  Check status with: make docker-status"; \
		echo "  View logs with: make docker-logs"; \
	fi

docker-stop:
	@echo "Stopping Splunk Docker container..."
	@docker stop $(DOCKER_CONTAINER) 2>/dev/null || echo "⚠ Container not running"
	@docker rm $(DOCKER_CONTAINER) 2>/dev/null || true
	@echo "✓ Container stopped and removed"

docker-restart:
	@echo "Restarting Splunk Docker container..."
	@docker restart $(DOCKER_CONTAINER)
	@echo "✓ Container restarted"
	@echo "⏳ Waiting for Splunk to be ready..."
	@sleep 10
	@echo "✓ Splunk should be ready now"

docker-logs:
	@echo "Docker container logs (last 50 lines):"
	@docker logs --tail 50 $(DOCKER_CONTAINER)

docker-status:
	@echo "Docker container status:"
	@docker ps --filter "name=$(DOCKER_CONTAINER)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "Access:"
	@echo "  Web UI: http://localhost:$(DOCKER_PORT_WEB)"
	@echo "  Management: https://localhost:$(DOCKER_PORT_MGMT)"
	@echo "  Username: admin"
	@echo "  Password: $(DOCKER_PASSWORD)"

docker-clean:
	@echo "Removing all Splunk Docker data..."
	@docker stop $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker rm $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker volume rm $$(docker volume ls -q | grep splunk) 2>/dev/null || true
	@echo "✓ All Docker data removed"

# Quick development workflow
dev: clean build
	@echo ""
	@echo "✓ Development build complete"
	@echo "  Package: $(APP_PACKAGE)"
	@echo "  Deploy with: make deploy or make docker-start"
