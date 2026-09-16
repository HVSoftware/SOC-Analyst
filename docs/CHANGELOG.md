# Changelog

Alle noemenswaardige veranderingen aan dit project worden hier opgenomen.

## [1.1.0] - 2025-09-16

### Added
- **US-01:** Navigation menu met alle 5 dashboards
- **US-02:** Time range pickers op alle dashboards
- **US-03:** 10 detection rules voor security monitoring
  - Brute Force Login Attempts (high)
  - Privilege Escalation (critical)
  - PowerShell Encoded Command (high)
  - Lateral Movement - RDP (medium)
  - Data Exfiltration (critical)
  - Account Lockout (medium)
  - Process Injection (critical)
  - Unusual Login Time (low)
  - New Service Installation (medium)
  - Scheduled Task Creation (medium)
- **US-05:** 20 KPI single-value panels (4 per dashboard)
- **US-06:** Lookup tables voor threat intel en asset inventory
  - threat_intel_hashes.csv
  - threat_intel_ips.csv
  - threat_intel_domains.csv
  - asset_inventory.csv
  - user_identity.csv
- **US-10:** Makefile voor development workflow
- **US-09:** Documentatie (DEPLOYMENT.md, USE_CASES.md, TROUBLESHOOTING.md)
- Input fields voor filtering op alle dashboards (US-04)

### Changed
- Alle dashboards hebben nu KPI rij bovenaan
- Navigation menu gegroepeerd per categorie (Monitoring, Investigations)

### Fixed
- Navigation menu toonde alleen overview dashboard

## [1.0.0] - 2025-09-15

### Added
- Initiële projectstructuur
- Basis app configuratie (app.conf)
- 4 macros: soc_analyst, soc_endpoint, soc_auth, soc_network
- 5 basis dashboards:
  - Overview
  - Security Alerts
  - Authentication Monitoring
  - Endpoint Monitoring
  - Network Monitoring
- Sample saved search

---

## Versioning

Dit project volgt [SemVer](https://semver.org/):
- **MAJOR** (1.x.x): Breaking changes
- **MINOR** (x.1.x): Nieuwe features, backward compatible
- **PATCH** (x.x.1): Bugfixes, backward compatible

## Git Tags

```bash
# Tag releases
git tag -a v1.1.0 -m "Release 1.1.0 - Complete P0+P1+P2"
git push origin --tags
```
