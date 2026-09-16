# US-09 — Documentatie uitbreiden

| Veld | Waarde |
|---|---|
| ID | US-09 |
| Titel | Documentatie uitbreiden voor deployment en gebruik |
| Rol | Developer |
| Afhankelijk van | US-00 |
| Status | **Klaar** |
| Datum voltooid | 2025-09-16 |
| Prioriteit | **P3 — Low** |
| Geschatte effort | 1 uur |

## Verhaal

Als developer/SOC engineer wil ik uitgebreide documentatie hebben over deployment, configuratie en use cases, zodat ik de app snel kan uitrollen en collega's weet hoe ze hem moeten gebruiken.

## Doel

Creëer de volgende documentatie bestanden:

1. **DEPLOYMENT.md** — Installatie en configuratie
2. **USE_CASES.md** — Detection rules en use case beschrijvingen
3. **TROUBLESHOOTING.md** — Veelvoorkomende problemen en oplossingen
4. **CHANGELOG.md** — Versie historie

## Acceptatiecriteria

- [ ] DEPLOYMENT.md met stap-voor-stap installatie
- [ ] USE_CASES.md met alle detection rules beschreven
- [ ] TROUBLESHOOTING.md met veelvoorkomende errors
- [ ] CHANGELOG.md met versie numbering (SemVer)
- [ ] README.md bijgewerkt met links naar nieuwe docs
- [ ] Documentatie in `docs/` map of root

## Proposed Structure

```
SOC-Analyst/
├── README.md                 # Bestaand - bijwerken
├── docs/
│   ├── DEPLOYMENT.md
│   ├── USE_CASES.md
│   ├── TROUBLESHOOTING.md
│   └── CHANGELOG.md
└── user-stories/             # Bestaand
```

## DEPLOYMENT.md Inhoud

```markdown
# Deployment Guide

## Requirements

- Splunk Enterprise 8.x of Splunk Cloud
- Admin access voor app installatie
- Data sources: Windows Event Logs, Sysmon, Network logs

## Installatie

### Optie 1: Via Splunk Web

1. Download SOC-Analyst.splunk app
2. Ga naar Settings → Manage Apps → Install App from File
3. Upload het .splunk bestand
4. Restart Splunk

### Optie 2: Handmatig

1. Pak SOC-Analyst.zip uit in `$SPLUNK_HOME/etc/apps/`
2. Set permissions:
   ```bash
   chown -R splunk:splunk $SPLUNK_HOME/etc/apps/SOC-Analyst
   chmod -R 755 $SPLUNK_HOME/etc/apps/SOC-Analyst
   ```
3. Restart Splunk:
   ```bash
   $SPLUNK_HOME/bin/splunk restart
   ```

## Configuratie

### 1. Macros aanpassen

Ga naar Settings → Advanced Search → Search Macros:

- `soc_analyst`: Pas aan naar jouw indexes (bijv. `index=main OR index=security`)
- `soc_endpoint`: Configureer Sysmon sourcetypes
- `soc_auth`: Windows Security log index
- `soc_network`: Netflow/firewall indexes

### 2. Lookups uploaden

1. Ga naar Settings → Lookups → Lookup table files
2. Upload CSV bestanden uit `lookups/` map
3. Configureer lookup definitions

### 3. Alerts configureren

1. Ga naar Settings → Saved Searches
2. Enable alle detection rules
3. Configureer email alerts (vereist SMTP setup)

## Verificatie

1. Open SOC-Analyst app
2. Controleer of alle 5 dashboards laden
3. Test time range picker
4. Verifieer dat searches resultaten tonen

## Next Steps

- Configureer threat intel lookups (US-06)
- Pas detection rules aan voor jouw environment (US-03)
- Stel email notifications in voor critical alerts
```

## USE_CASES.md Inhoud

Voor elke detection rule uit US-03:

```markdown
# Use Cases

## [Detection] Brute Force Login Attempts

**MITRE ATT&CK:** T1110 - Brute Force  
**Severity:** High  
**Data Source:** Windows Security Logs (Event ID 4625)

### Beschrijving

Detecteert meerdere failed login pogingen (>5) binnen 1 uur vanaf dezelfde source IP of tegen dezelfde user.

### Query

```spl
`soc_auth` EventCode=4625 
| stats count by user, src_ip 
| where count > 5
```

### Response Acties

1. Identificeer betrokkene user accounts
2. Check of account gelocked is (Event ID 4740)
3. Blokkeer source IP als external
4. Reset user password als compromised
5. Documenteer incident

### False Positives

- Vergeetachtige gebruikers
- Application service accounts met verkeerde credentials
- Automated scanning tools

### Tuning

Verhoog threshold van 5 naar 10 voor drukke environments.
```

## Definition of Done

- [ ] DEPLOYMENT.md compleet
- [ ] USE_CASES.md met alle 8 detection rules
- [ ] TROUBLESHOOTING.md met minstens 5 veelvoorkomende issues
- [ ] CHANGELOG.md met versie 1.0.0
- [ ] README.md bijgewerkt met links
- [ ] Git commit gemaakt

## Notes

- Gebruik Markdown voor alle documentatie
- Houd documentatie bij bij elke nieuwe feature
- Overweeg GitHub Wiki voor langere docs
