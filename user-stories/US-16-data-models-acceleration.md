# US-16 — Data Models + Acceleration

| Veld | Waarde |
|---|---|
| ID | `US-16` |
| Titel | Data Models voor Performance Optimalisatie |
| Rol | Developer / Performance Engineer |
| Afhankelijk van | US-00 (Projectstructuur) |
| Status | Open |

## Verhaal

**Als** SOC Analyst,  
**wil ik** dat dashboards snel laden (< 5 seconden) zelfs bij grote datasets,  
**zodat** ik efficiënt kan werken tijdens incident response zonder te wachten op search resultaten.

## Acceptatiecriteria

- [ ] **Data models aangemaakt** voor veelgebruikte datasets (authentication, network, endpoint)
- [ ] **Acceleration ingeschakeld** met 70% summary retention
- [ ] **Pivot support** — Data models bruikbaar in Splunk Pivot
- [ ] **Performance improvement** — Dashboard load time < 5 seconden
- [ ] **Documentatie** — Data model usage en maintenance guide

## Technische Specificaties

### Data Model Structuur

```
SOC_Analyst_Data_Model
├── Authentication
│   ├── Successful_Logons
│   ├── Failed_Logons
│   ├── Account_Creation
│   └── Privilege_Escalation
├── Network
│   ├── DNS_Queries
│   ├── HTTP_Requests
│   ├── Firewall_Allowed
│   └── Firewall_Blocked
├── Endpoint
│   ├── Process_Creation
│   ├── File_Access
│   ├── Registry_Changes
│   └── PowerShell_Activity
└── Threat_Intel
    ├── Malicious_IPs
    ├── Malicious_Hashes
    └── Malicious_Domains
```

### Data Model Configuration (datamodel.conf)

```ini
[SOC_Analyst_Data_Model]
access = read : [ * ], write : [ admin ]
description = SOC Analyst data model for accelerated searches

[SOC_Analyst_Data_Model:Authentication]
description = Authentication events (Windows Event Logs, Sysmon)
object = Successful_Logons
object = Failed_Logons
object = Account_Creation
object = Privilege_Escalation

[SOC_Analyst_Data_Model:Authentication.Successful_Logons]
fields = _time, host, user, src_ip, logon_type, process_name
constraints = EventCode=4624 OR EventCode=4675
```

### Acceleration Settings

```ini
# Acceleratie voor grote datasets
[SOC_Analyst_Data_Model:Authentication]
acceleration = true
acceleration.earliest_time = -30d
acceleration.max_build_minutes = 30
acceleration.summary_range = 70
```

### Performance Targets

| Dashboard | Huidige Load Time | Doel (met acceleration) |
|-----------|------------------|-------------------------|
| Overview | 15-30s | < 5s |
| Authentication | 10-20s | < 3s |
| Network | 20-40s | < 5s |
| Endpoint | 15-25s | < 4s |
| MITRE ATT&CK | 30-60s | < 10s |

## Deliverables

1. **default/datamodel.conf** — Data model definities
2. **README.md update** — Data model usage instructies
3. **docs/DATA_MODELS.md** — Performance tuning guide
4. **Makefile target** — `make accelerate` voor summary rebuild
5. **Performance benchmarks** — Before/after metrics

## Implementation Steps

1. **Analyse existing searches** — Identificeer slow searches (>10s)
2. **Design data models** — Groepeer gerelateerde datasets
3. **Configure acceleration** — Enable met juiste retention
4. **Update dashboards** — Gebruik `| from datamodel` syntax
5. **Test performance** — Meet load times voor/na
6. **Document usage** — Schrijf guide voor onderhoud

## Data Model Usage in Searches

```spl
# Oude search (langzaam)
index=security EventCode=4624 
| stats count by user, host

# Nieuwe search (versneld met data model)
| from datamodel:"SOC_Analyst_Data_Model.Authentication.Successful_Logons"
| stats count by user, host
```

## Test Scenario's

1. **Data model build** — Summary build succesvol voltooid
2. **Performance test** — Dashboard load < 5 seconden
3. **Data accuracy** — Results match non-accelerated searches
4. **Summary retention** — 70% summary range correct geconfigureerd
5. **Pivot compatibility** — Data models zichtbaar in Splunk Pivot

## Dependencies

- Splunk Enterprise (acceleration niet beschikbaar in Free versie)
- Voldoende storage voor acceleration summaries
- Index toegang voor alle benodigde datasets
- US-03 saved searches moeten bestaan

## Risico's en Mitigatie

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| Summary build duurt lang | Medium | Schedule buiten piekuren, split grote models |
| Storage usage hoog | Medium | Monitor summary size, adjust retention |
| Data inconsistency | Hoog | Regular rebuild schedule, validation checks |
| Acceleration faalt | Medium | Alerting op build failures, manual rebuild procedure |

## Definition of Done

- [ ] datamodel.conf aangemaakt met alle data models
- [ ] Acceleration ingeschakeld voor alle models
- [ ] Dashboards geüpdatet om data models te gebruiken
- [ ] Performance improvement gemeten en gedocumenteerd
- [ ] DATA_MODELS.md documentatie compleet
- [ ] Makefile target `make accelerate` werkt
- [ ] User Story gemarkeerd als "Klaar" in README

## Notes

- Acceleration vereist Splunk Enterprise license
- Summary build kan lang duren bij eerste run (plan maintenance window)
- Data models moeten worden gerebuild na schema changes
- Overweeg CIM (Common Information Model) compatibility voor Fase 3
- Monitor storage usage: acceleration kan 10-30% extra storage vereisen
