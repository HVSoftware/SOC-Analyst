# SOC-Analyst

Splunk app voor SOC monitoring, threat hunting en incident response.

## Quick Start

### Lokale Development (zonder Splunk installatie)

```bash
# 1. Start Splunk in Docker
make docker-start

# Wacht 2-3 minuten tot Splunk gestart is
make docker-status

# 2. Build en deploy
make build
make deploy

# 3. Open Splunk Web
# http://localhost:8000 (admin / ChangeMe123!)
```

### Remote Deployment

```bash
# Build package
make build

# Upload naar Splunk Cloud/Server
# Settings → Manage Apps → Install App from File
# Upload: SOC-Analyst.splunk
```

## Features

### Dashboards (7)
- **Overview** — KPIs en index overzicht
- **Security Alerts** — Severity filtering en alerts
- **Authentication Monitoring** — User/host filters
- **Endpoint Monitoring** — Process monitoring
- **Network Monitoring** — IP filtering
- **MITRE ATT&CK** — Threat hunting dashboard
- **Incident Investigation** — Drilldown voor incident response

### Detection Rules (10)
- Brute Force Login Attempts (High)
- Privilege Escalation (Critical)
- PowerShell Encoded Command (High)
- Lateral Movement RDP (Medium)
- Data Exfiltration (Critical)
- Account Lockout (Medium)
- Process Injection (Critical)
- Unusual Login Time (Low)
- New Service Installation (Medium)
- Scheduled Task Creation (Medium)

### KPI Panels (20)
- Total Events, Alerts, Unique Users/Hosts
- Critical/High Alerts met kleurcodering
- Data Volume, Network Statistics

### Lookup Tables (5)
- Threat Intel: IPs, Domains, Hashes
- Asset Inventory
- User Identity Mapping

## Commands

### Build & Deploy

```bash
make build              # Build .splunk package
make deploy             # Deploy naar lokale Splunk
make deploy-remote      # Deploy naar remote server (SCP)
make package            # Build met package info
```

### Docker (Lokaal Testen)

```bash
make docker-start       # Start Splunk in Docker
make docker-status      # Toon container status
make docker-logs        # Bekijk logs
make docker-restart     # Restart container
make docker-stop        # Stop en verwijder container
```

### Validation & Testing

```bash
make validate           # Valideer app structuur en XML
make test               # Toon saved searches overzicht
make clean              # Verwijder build artifacts
```

## Documentatie

- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)** — Installatie en configuratie
- **[USE_CASES.md](docs/USE_CASES.md)** — Detection rules en use cases
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Veelvoorkomende problemen
- **[CHANGELOG.md](docs/CHANGELOG.md)** — Release historie

## Project Status

✅ **100% Complete** — Alle 11 User Stories voltooid

| Priority | Status |
|----------|--------|
| P0 | ✅ Navigation menu |
| P1 | ✅ Time ranges + Alerts |
| P2 | ✅ Input fields + KPIs + Lookups + Makefile |
| P3 | ✅ MITRE ATT&CK + Drilldown + Documentation |

## Requirements

- **Splunk Enterprise** 8.x of **Splunk Cloud**
- **Docker** (voor lokaal testen)
- **libxml2-utils** (voor XML validatie)

## License

MIT License — zie [LICENSE](LICENSE) bestand.

## Author

SOC-Analyst Team
