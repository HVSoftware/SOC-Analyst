# US-18 — Custom Fields (fields.conf)

| Veld | Waarde |
|---|---|
| ID | `US-18` |
| Titel | Custom Fields Definitie voor Consistente Searches |
| Rol | Developer / SOC Analyst |
| Afhankelijk van | US-00 (Projectstructuur) |
| Status | Open |

## Verhaal

**Als** SOC Analyst,  
**wil ik** consistente veldnamen across alle dashboards en searches,  
**zodat** searches herbruikbaar zijn en resultaten voorspelbaar blijven.

## Acceptatiecriteria

- [ ] **fields.conf aangemaakt** — Alle custom fields gedefinieerd
- [ ] **Field aliases** — Mapping van bron-specifieke velden naar standaard namen
- [ ] **Calculated fields** — Afgeleide velden voor enrichment
- [ ] **Field extractions** — REGEX voor parsing van log data
- [ ] **Documentation** — Field dictionary met alle beschikbare velden

## Technische Specificaties

### Field Naming Convention

```
Standaard veldnamen (lowercase, underscores):
- src_ip (niet: sourceIP, srcIP, source_ip)
- dest_ip (niet: destIP, destinationIP)
- user_name (niet: username, userName, User)
- host_name (niet: hostname, computerName)
- process_name (niet: processName, imageName)
- file_path (niet: filePath, fullpath)
- timestamp (niet: time, _time, eventTime)
```

### fields.conf Structuur

```ini
# fields.conf — Custom field definitions

[src_ip]
datatype = ip
description = Source IP address
aliases = srcip, source_ip, SourceIP, IpSrc

[dest_ip]
datatype = ip
description = Destination IP address
aliases = destip, destination_ip, DestIP, IpDest

[user_name]
datatype = string
description = Username or account name
aliases = username, userName, User, AccountName, TargetUserName

[host_name]
datatype = string
description = Hostname or computer name
aliases = hostname, computername, Computer, Host, src_host

[process_name]
datatype = string
description = Process executable name
aliases = processname, imageName, Image, Process, NewProcessName

[file_path]
datatype = string
description = Full file path
aliases = filepath, filePath, FullPath, ImagePath

[severity_level]
datatype = string
description = Alert severity (Low, Medium, High, Critical)
aliases = severity, Severity, alert_severity
```

### Field Aliases (props.conf)

```ini
# props.conf — Field alias mapping per sourcetype

[WinEventLog:Security]
FIELDALIAS-src_ip = SourceNetworkAddress AS src_ip
FIELDALIAS-user_name = TargetUserName AS user_name
FIELDALIAS-host_name = ComputerName AS host_name
FIELDALIAS-process_name = ProcessName AS process_name

[Sysmon:1]
FIELDALIAS-src_ip = SourceIp AS src_ip
FIELDALIAS-user_name = User AS user_name
FIELDALIAS-host_name = ComputerName AS host_name
FIELDALIAS-process_name = Image AS process_name
FIELDALIAS-file_path = Image AS file_path
```

### Calculated Fields (calculatedfields.conf)

```ini
# calculatedfields.conf — Afgeleide velden

[security_alerts]
EVAL-severity_numeric = case(severity_level="Critical", 4, severity_level="High", 3, severity_level="Medium", 2, severity_level="Low", 1)
EVAL-is_high_severity = if(severity_numeric >= 3, "Yes", "No")
EVAL-alert_age_hours = round((now() - _time) / 3600, 2)
EVAL-response_required = if(severity_numeric >= 3 AND alert_age_hours < 24, "Yes", "No")
```

### Field Extractions (transforms.conf)

```ini
# transforms.conf — REGEX field extractions

[extract_src_ip]
REGEX = src[_\s]?ip[=:\s]+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})
FORMAT = src_ip::$1
WRITE_META = true

[extract_dest_ip]
REGEX = dest[_\s]?ip[=:\s]+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})
FORMAT = dest_ip::$1
WRITE_META = true

[extract_user_name]
REGEX = (?:user[_\s]?name|account[_\s]?name)[=:\s]+([^\s,]+)
FORMAT = user_name::$1
WRITE_META = true
```

## Deliverables

1. **default/fields.conf** — Custom field definitions
2. **default/props.conf** — Field aliases per sourcetype
3. **default/calculatedfields.conf** — Calculated field definitions
4. **default/transforms.conf** — Field extractions (REGEX)
5. **docs/FIELD_DICTIONARY.md** — Complete field reference
6. **Field mapping matrix** — Sourcetype → field mappings

## Field Dictionary (Voorbeeld)

| Field Name | Type | Description | Source Fields |
|-----------|------|-------------|---------------|
| src_ip | IP | Source IP address | SourceIP, srcip, IpSrc |
| dest_ip | IP | Destination IP | DestIP, destip, IpDest |
| user_name | String | Username | TargetUserName, AccountName |
| host_name | String | Hostname | ComputerName, Host |
| process_name | String | Process executable | Image, ProcessName |
| file_path | String | Full file path | FullPath, ImagePath |
| severity_level | String | Alert severity | severity, Severity |
| alert_id | String | Unique alert ID | AlertID, _key |
| timestamp | Time | Event timestamp | _time, Timestamp |

## Test Scenario's

1. **Field consistency** — Dezelfde veldnamen across alle dashboards
2. **Alias mapping** — Bron-specifieke velden correct gemapped
3. **Calculated fields** — Afgeleide velden correct berekend
4. **Field extractions** — REGEX correct parse van log data
5. **Search compatibility** — Bestaande searches werken met nieuwe fields

## Dependencies

- US-03 saved searches moeten bestaan
- US-06 lookup tables moeten bestaan
- Sourcetype definitions (Windows Event Logs, Sysmon, etc.)

## Risico's en Mitigatie

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| Field conflicts | Hoog | Check bestaande fields, use unique names |
| Performance impact | Medium | Test extraction performance, optimize REGEX |
| Breaking changes | Hoog | Version fields.conf, provide migration guide |
| Inconsistent naming | Medium | Enforce naming convention in code review |

## Definition of Done

- [ ] fields.conf aangemaakt met alle custom fields
- [ ] props.conf met field aliases per sourcetype
- [ ] calculatedfields.conf met afgeleide velden
- [ ] transforms.conf met field extractions
- [ ] FIELD_DICTIONARY.md documentatie compleet
- [ ] Alle dashboards geüpdatet met consistente veldnamen
- [ ] User Story gemarkeerd als "Klaar" in README

## Notes

- Field names moeten backward compatible zijn
- Overweeg CIM (Common Information Model) naming conventions
- Document alle field changes in CHANGELOG.md
- Test field extractions met sample data van alle sourcetypes
- Field aliases kunnen performance impact hebben bij grote datasets
