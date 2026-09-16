# US-03 — Saved searches + alerts uitbreiden

| Veld | Waarde |
|---|---|
| ID | US-03 |
| Titel | Saved searches en detection rules toevoegen |
| Rol | SOC Analyst |
| Afhankelijk van | US-00 |
| Status | Open |
| Prioriteit | **P1 — High** |
| Geschatte effort | 2 uur |

## Verhaal

Als SOC Analyst wil ik geautomatiseerde detection rules en alerts hebben voor veelvoorkomende security incidents, zodat ik proactief bedreigingen kan identificeren in plaats van alleen reactief te monitoren.

## Huidige Situatie

**Bestand:** `default/savedsearches.conf`

```ini
[incident - sample search]
disabled = 0
search = `soc_analyst` | stats count by index
cron_schedule = 0 * * * *
earliest_time = -24h@h
latest_time = now
description = Example saved search for the SOC-Analyst app
is_scheduled = 1
```

**Probleem:** Slechts 1 voorbeeld search die elk uur draait, geen echte detection logic.

## Doel

Voeg minimaal 8 detection rules toe voor veelvoorkomende security use cases:

1. Brute force login pogingen
2. Privilege escalation (token elevation)
3. Suspicious process execution (Sysmon Event ID 1)
4. Lateral movement (RDP/SSH naar meerdere hosts)
5. Data exfiltration indicators (grote outbound transfers)
6. Malware indicators (known bad hashes/domains)
7. Account lockout events
8. Unusual login times/locations

## Acceptatiecriteria

- [ ] Minimaal 8 saved searches met detection logic
- [ ] Elke search heeft:
  - Duidelijke naam (`[Detection] Brute Force Login`)
  - Beschrijving met use case
  - Correcte SPL query met macros
  - Schedule (cron of `*/5 * * * *` voor high-freq)
  - Alert configuratie (severity level)
- [ ] Searches gebruiken bestaande macros (`soc_auth`, `soc_endpoint`, etc.)
- [ ] Severity levels: `low`, `medium`, `high`, `critical`
- [ ] Tests beschreven in US

## Proposed Saved Searches

### 1. Brute Force Login Detection
```ini
[Detection] Brute Force Login Attempts
search = `soc_auth` EventCode=4625 | stats count by user, src_ip | where count > 5
cron_schedule = */15 * * * *
earliest_time = -1h@h
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = high
description = Detecteert meerdere failed login pogingen (>5) binnen 1 uur
```

### 2. Privilege Escalation (Token Elevation)
```ini
[Detection] Privilege Escalation - Token Elevation
search = `soc_auth` EventCode=4672 | stats count by user, logon_id
cron_schedule = */30 * * * *
earliest_time = -4h@h
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = critical
description = Detecteert privilege escalation via token elevation (SeDebugPrivilege)
```

### 3. Suspicious Process Execution
```ini
[Detection] Suspicious Process - PowerShell Encoded Command
search = `soc_endpoint` EventCode=1 (ProcessName="powershell.exe" OR ProcessName="pwsh.exe") CommandLine="* -enc*" OR CommandLine="* -EncodedCommand*"
cron_schedule = */10 * * * *
earliest_time = -2h@h
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = high
description = Detecteert PowerShell met encoded commands (vaak gebruikt door malware)
```

### 4. Lateral Movement - RDP naar Meerdere Hosts
```ini
[Detection] Lateral Movement - RDP Session to Multiple Hosts
search = `soc_auth` EventCode=4624 LogonType=10 | stats dc(dest_host) as host_count by user | where host_count > 3
cron_schedule = 0 * * * *
earliest_time = -1h@h
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = medium
description = Gebruiker maakt RDP verbinding met >3 hosts binnen 1 uur (mogelijke lateral movement)
```

### 5. Data Exfiltration - Large Outbound Transfer
```ini
[Detection] Data Exfiltration - Large Outbound Network Transfer
search = `soc_network` bytes_out > 100000000 | stats sum(bytes_out) as total_bytes by src_ip, dest_ip | where total_bytes > 500000000
cron_schedule = 0 */2 * * *
earliest_time = -2h@h
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = critical
description = Detecteert grote outbound data transfers (>500MB) mogelijk data exfiltration
```

### 6. Account Lockout
```ini
[Detection] Account Lockout Events
search = `soc_auth` EventCode=4740 | table _time user src_ip caller_computer_name
cron_schedule = */5 * * * *
earliest_time = -30m@m
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = medium
description = Gebruikersaccount is locked out (vaak indicator van brute force of compromised account)
```

### 7. Suspicious Sysmon Event - Process Injection
```ini
[Detection] Process Injection Detected (Sysmon Event ID 8)
search = `soc_endpoint` EventCode=8 | table _time host user source_image target_image
cron_schedule = */15 * * * *
earliest_time = -1h@h
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = critical
description = Process injection gedetecteerd (vaak malware techniek)
```

### 8. Unusual Login Time
```ini
[Detection] Unusual Login Time (Outside Business Hours)
search = `soc_auth` EventCode=4624 earliest=-1h@h latest=now | eval hour=strftime(_time,"%H") | where hour < 6 OR hour > 22 | stats count by user, hour
cron_schedule = 0 * * * *
earliest_time = -1h@h
latest_time = now
alert_type = number_of_events
alert_threshold = 1
alert_severity = low
description = Login buiten kantoortijden (voor 6:00 of na 22:00)
```

## Implementatie Stappen

1. Open `default/savedsearches.conf`
2. Voeg bovenstaande 8 searches toe (of pas aan naar environment)
3. Voor elke search:
   - Gebruik correcte macros
   - Stel appropriate cron schedule in
   - Definieer alert threshold en severity
4. Optioneel: Voeg `alert.email.to` en `alert.email.subject` toe voor email alerts
5. Test searches in Splunk Search & Reporting app
6. Commit met bericht: `feat(alerts): voeg 8 detection rules toe voor security monitoring`

## Test

Na implementatie:

1. **Syntax check:**
   ```bash
   # In Splunk: Settings -> Saved Searches -> Controleer op parse errors
   ```

2. **Manual test per search:**
   - Kopieer search string naar Search & Reporting
   - Verifieer dat resultaten terugkomen (of 0 als geen events)
   - Check dat macros correct expanden

3. **Alert test:**
   - Trigger test event (bijv. meerdere failed logins)
   - Wacht tot scheduled search draait
   - Verifieer alert verschijnt in Alert Manager

## Definition of Done

- [ ] 8+ saved searches toegevoegd aan `savedsearches.conf`
- [ ] Alle searches gebruiken correcte macros
- [ ] Alert thresholds en severity levels ingesteld
- [ ] Cron schedules appropriate voor use case
- [ ] Tests uitgevoerd (geen syntax errors)
- [ ] Git commit gemaakt
- [ ] Documentatie bijgewerkt (README of aparte alerts.md)

## Notes

- **Cron format:** `minute hour day month dayofweek`
  - `*/5 * * * *` = elke 5 minuten
  - `0 * * * *` = elk uur op minuut 0
  - `0 */2 * * *` = elke 2 uur
- **Alert severity:** `0=debug, 1=info, 2=warn, 3=error, 4=critical`
- **Email alerts:** Vereist SMTP configuratie in Splunk
- **Performance:** Zorg dat `earliest_time` niet te breed is voor performance

## Vervolgstappen

Na US-03:
- **US-07**: MITRE ATT&CK mapping voor deze alerts
- **US-06**: Lookup tables voor known bad IPs/hashes
- **US-08**: Drilldown van alerts naar investigation dashboard
