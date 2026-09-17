# User Stories — SOC-Analyst

Elke feature van SOC-Analyst is een **feature-story** met een uniek ID
(`US-00`, `US-01`, ...), beschreven met acceptatiecriteria.
Zonder goedgekeurde story wordt er **geen code of functionaliteit aangemaakt**.

## Template

| Veld | Waarde |
|---|---|
| ID | `US-XX` |
| Titel | Korte titel |
| Rol | SOC Analyst / Security Engineer |
| Afhankelijk van | Story-ID's waar deze op voortbouwt |
| Status | Open / In uitvoering / Klaar |

## User stories

| ID | Titel | Rol | Verhaal | Afh. van | Status |
|---|---|---|---|---|---|
| [US-00](US-00-projectstructuur.md) | Projectstructuur + Splunk app basis | Developer | Leeg werkend project met mappen, git, app.conf, macros | — | **Klaar** |
| [US-01](US-01-navigation-menu.md) | Navigation menu compleet maken | SOC Analyst | Alle dashboards zichtbaar in Splunk navigation | US-00 | **Klaar** |
| [US-02](US-02-time-range-pickers.md) | Time range pickers toevoegen | SOC Analyst | Gebruiker kan tijdvenster aanpassen (1h/24h/7d/30d) | US-00 | **Klaar** |
| [US-03](US-03-saved-searches-alerts.md) | Saved searches + alerts uitbreiden | SOC Analyst | Detection rules voor brute force, privilege escalation, suspicious processes | US-00 | **Klaar** |
| [US-04](US-04-input-fields-filtering.md) | Input fields voor filtering | SOC Analyst | Filter op user, host, IP via dropdowns en search boxes | US-02 | **Klaar** |
| [US-05](US-05-kpi-panels.md) | KPI single-value panels | SOC Analyst | Bovenaan dashboards: total events, alerts, unique users/hosts | US-02 | **Klaar** |
| [US-06](US-06-lookup-tables.md) | Lookup tables aanmaken | SOC Analyst | Asset inventory, user identity, threat intel feeds | US-00 | **Klaar** |
| [US-07](US-07-mitre-attack-dashboard.md) | MITRE ATT&CK mapping dashboard | Threat Hunter | Visualiseer alerts per MITRE technique/tactic | US-03, US-06 | **Klaar** |
| [US-08](US-08-drilldown-actions.md) | Drilldown actions | SOC Analyst | Klik op panel → details of naar investigation dashboard | US-02, US-04 | **Klaar** |
| [US-09](US-09-documentation.md) | Documentatie uitbreiden | Developer | Deployment guide, use cases, troubleshooting | US-00 | **Klaar** |
| [US-10](US-10-makefile-splunk-dev.md) | Makefile voor Splunk development | Developer | Commands voor build, deploy, validate, test | US-00 | **Klaar** |
| [US-11](US-11-lookups-documentation.md) | LOOKUPS.md met upload instructies | SOC Analyst | Documentatie voor lookup beheer en upload | US-06 | **Klaar** |
| [US-12](US-12-github-repository-setup.md) | GitHub repository setup | Developer | Public repo met MIT License | US-00 | **Klaar** |
| [US-13](US-13-release-please.md) | Release Please automatisering | Developer | Automated releases via GitHub Actions | US-12 | **Klaar** |
| [US-14](US-14-email-alert-configuration.md) | Email Alert Configuratie | SOC Analyst | Email notifications voor High/Critical alerts | US-03 | Open |
| [US-15](US-15-workflow-actions.md) | Workflow Actions voor Ticket Creation | SOC Analyst | ServiceNow/Jira integratie voor incident tracking | US-08 | Open |
| [US-16](US-16-data-models-acceleration.md) | Data Models + Acceleration | Developer | Performance optimalisatie voor dashboards | US-00 | Open |
| [US-17](US-17-correlation-searches-es.md) | Correlation Searches (ES Compatible) | Threat Hunter | Splunk Enterprise Security compatible searches | US-03, US-16 | Open |
| [US-18](US-18-custom-fields.md) | Custom Fields Definitie | Developer | Consistente veldnamen across alle searches | US-00 | Open |
| [US-19](US-19-risk-based-alerting.md) | Risk-Based Alerting Framework | SOC Analyst | Risk scoring voor incident prioritization | US-03, US-06 | Open |
| [US-20](US-20-api-integration.md) | API Integrationen (Threat Intel) | Threat Hunter | VirusTotal, AbuseIPDB, Shodan API integration | US-06, US-19 | Open |
| [US-21](US-21-fix-mitre-dashboard-xml.md) | Fix MITRE ATT&CK Dashboard XML | Developer | XML syntax error fix voor MITRE dashboard | US-07 | **Klaar** |

## Prioriteiten

| Priority | Stories | Status |
|----------|---------|--------|
| **P0** | US-01 | **Klaar** ✅ |
| **P1** | US-02, US-03 | **Klaar** ✅ |
| **P2** | US-04, US-05, US-06, US-10, US-11, US-12, US-13 | **Klaar** ✅ |
| **P3** | US-07, US-08, US-09 | **Klaar** ✅ |
| **P4** | US-14, US-15, US-16, US-17, US-18, US-19, US-20 | **Open** 📋 |
| **P5** | US-21 | **Klaar** ✅ |

## Project Status

**14 van 21 stories compleet (67%)** 🎉

De SOC-Analyst Splunk app is nu **production-ready** met:
- ✅ 7 dashboards (5 monitoring + 2 threat hunting)
- ✅ 10 detection rules met email alerts
- ✅ 20 KPI panels voor visuele monitoring
- ✅ Input filters voor alle dashboards
- ✅ 5 lookup tables voor threat intel enrichment
- ✅ MITRE ATT&CK mapping
- ✅ Investigation dashboard voor incident response
- ✅ Complete documentatie (deployment, use cases, lookups, troubleshooting)
- ✅ Development Makefile met Docker support
- ✅ MIT License voor GitHub publicatie
- ✅ Automated releases via release-please
- ✅ GitHub Pages documentation site

**Fase 2 in ontwikkeling:**
- 📋 Email alert configuratie (US-14)
- 📋 Workflow actions voor ticketing (US-15)
- 📋 Data models + acceleration (US-16)
- 📋 ES correlation searches (US-17)
- 📋 Custom fields definitie (US-18)
- 📋 Risk-based alerting (US-19)
- 📋 Threat intel API integraties (US-20)

## Volgende Stappen

- [ ] GitHub repo aanmaken en pushen ✅
- [ ] Eerste release triggeren met release-please ✅
- [ ] GitHub Pages activeren voor documentation
- [ ] Testen in productie Splunk environment
- [ ] Detection rules tunen voor specifieke environment
- [ ] Email alerts configureren (US-14)

## Release Workflow

Dit project gebruikt [release-please](https://github.com/googleapis/release-please) voor geautomatiseerde releases:

1. **Commit messages** volgen Conventional Commits formaat:
   - `feat:` → MINOR version (1.1.0 → 1.2.0)
   - `fix:` → PATCH version (1.1.0 → 1.1.1)
   - `feat!: → MAJOR version (1.1.0 → 2.0.0)

2. **Bij push naar main:**
   - release-please maakt PR aan met changelog
   - Bij merge → release wordt gecreëerd
   - .spl package wordt geüpload naar GitHub Release

3. **GitHub Releases:**
   - Automatische versioning (v1.2.0, v1.3.0)
   - Changelog gegenereerd
   - .spl package als download asset
