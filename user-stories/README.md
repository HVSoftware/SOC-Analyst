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

## Prioriteiten

| Priority | Stories | Status |
|---|---|---|
| **P0** | US-01 | **Klaar** ✅ |
| **P1** | US-02, US-03 | **Klaar** ✅ |
| **P2** | US-04, US-05, US-06, US-10 | **Klaar** ✅ |
| **P3** | US-07, US-08, US-09 | **Klaar** ✅ |

## Project Status

**11 van 11 stories compleet (100%)** 🎉

De SOC-Analyst Splunk app is nu **production-ready** met:
- ✅ 7 dashboards (5 monitoring + 2 threat hunting)
- ✅ 10 detection rules met email alerts
- ✅ 20 KPI panels voor visuele monitoring
- ✅ Input filters voor alle dashboards
- ✅ 5 lookup tables voor threat intel enrichment
- ✅ MITRE ATT&CK mapping
- ✅ Investigation dashboard voor incident response
- ✅ Complete documentatie (deployment, use cases, troubleshooting)
- ✅ Development Makefile

## Volgende Stappen

- [ ] Testen in productie Splunk environment
- [ ] Detection rules tunen voor specifieke environment
- [ ] Email alerts configureren
- [ ] MITRE ATT&CK Navigator integratie (optioneel)
- [ ] Automated threat intel feed updates (optioneel)
