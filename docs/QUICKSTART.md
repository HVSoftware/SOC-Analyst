# Quick Start — SOC-Analyst SIEM

## Introductie

**SOC-Analyst** is een Splunk SIEM app voor security monitoring, threat hunting en incident response.

### Splunk als SIEM Oplossing

SOC-Analyst biedt volledige SIEM capabilities:

- **Real-Time Monitoring** — Live dashboards en alerts
- **Historical Analysis** — Patronen zoeken in historische data
- **Threat Hunting** — MITRE ATT&CK mapping en correlaties
- **Incident Response** — Drilldown van alert naar details
- **User Behavior Analytics (UBA)** — Enrichment via lookups

---

## 5-Minute Setup

### 1. Installeer App

```bash
# Via Makefile (lokaal)
make build
make deploy

# Of via Splunk Web
Settings → Manage Apps → Install App from File
Upload: SOC-Analyst.spl
```

### 2. Configureer Data Inputs

Zorg dat de volgende data bronnen beschikbaar zijn:

| Data Source | Sourcetype | Index |
|-------------|-----------|-------|
| Windows Security Events | `WinEventLog:Security` | `windows_security` |
| Sysmon Logs | `xmlwineventlog` | `sysmon` |
| Firewall Logs | `firewall` | `firewall` |
| Proxy Logs | `proxy` | `proxy` |

### 3. Verify Installatie

1. Open **SOC-Analyst → Overview** dashboard
2. Controleer dat "Total Events" data toont
3. Test time range picker (Last 24h, Last 7 days)

### 4. Email Alerts Instellen

Voor High/Critical alerts:

```
Settings → Server settings → Email settings
→ Configureer SMTP server
→ Test email verbinding
```

---

## Basic Searching (SPL)

### Fundamentals

Elke search begint met een basis query die verfijnd kan worden:

```spl
# Alle events (breed)
index=*

# Specifieke index
index=windows_security

# Met zoekterm
index=windows_security "failed login"
```

### Narrow Down Searches

| Methode | Voorbeeld | Beschrijving |
|---------|-----------|--------------|
| **Keywords** | `index=security "failed login"` | Zoek op termen |
| **Boolean** | `EventCode=4625 OR EventCode=4672` | AND, OR, NOT |
| **Comparison** | `severity="high"` | =, !=, <, >, <=, >= |
| **Wildcards** | `user*=admin` | * (meerdere chars), ? (één char) |

### Voorbeelden

```spl
# Brute force detectie (meerdere failed logins)
index=windows_security EventCode=4625 | stats count by src_ip

# Privilege escalation
index=windows_security EventCode=4672 | table _time user src_ip

# Met wildcard
index=sysmon CommandLine="*powershell*"
```

---

## Essentiële SPL Commands

### 1. `lookup` — Data Enrichment

Verrijk search results met externe bronnen (threat intel):

```spl
# Voeg threat intel toe aan events
index=windows_security 
| lookup threat_intel_ips.csv ip_address AS src_ip 
| where is_notnull(threat_type)
| table _time src_ip threat_type severity
```

**Use Case:** Detecteer communicatie met known malicious IPs

### 2. `inputlookup` — Lookup Data Ophalen

Haal data uit lookup files zonder te joinen:

```spl
# Toon alle known malicious IPs
| inputlookup threat_intel_ips.csv 
| table ip_address threat_type confidence

# Gebruik in subsearch
index=* src_ip IN (
    [ | inputlookup threat_intel_ips.csv | fields ip_address ]
)
```

**Use Case:** Quick reference of threat intel zonder grote search

### 3. `earliest` / `latest` — Time Range

Beperk searches tot specifieke tijdperiodes:

```spl
# Laatste 24 uur
index=windows_security 
| stats count by EventCode

# Specifiek time range
index=windows_security 
| stats count by user
| where _time >= relative_time(now(), "-7d@d")
| where _time <= relative_time(now(), "@d")

# Via time picker (in dashboards)
index=windows_security 
earliest=$time_range.earliest$ 
latest=$time_range.latest$
```

**Use Case:** Historical analysis, trend detection

### 4. `transaction` — Events Groeperen

Groepeer gerelateerde events tot transactions:

```spl
# Track user sessie (meerdere events)
index=windows_security 
| transaction user maxspan=1h 
| table _time user duration event_count

# Detect lateral movement (RDP sessies)
index=windows_security EventCode=4624 LogonType=10 
| transaction src_ip user maxspan=30m 
| where event_count > 5
| table _time src_ip user duration
```

**Use Case:** User sessions, attack chains, multi-step attacks

### 5. `subsearch` — Nested Searches

Gebruik results van één search in een andere:

```spl
# Zoek users met failed logins, dan hun successful logins
index=windows_security EventCode=4624 
[ search index=windows_security EventCode=4625 
  | stats count by user 
  | where count > 5 
  | fields user ]
| table _time user src_ip

# Threat intel matching
index=* 
[ | inputlookup threat_intel_ips.csv | fields ip_address ]
| table _time src_ip dest_ip
```

**Use Case:** Correlate events, filter op dynamische criteria

---

## Use Cases (SIEM)

### 1. Brute Force Detection

```spl
index=windows_security EventCode=4625 
| stats count by src_ip user 
| where count > 10
| sort - count
```

**Severity:** High  
**MITRE ATT&CK:** T1110 - Brute Force

### 2. Privilege Escalation

```spl
index=windows_security EventCode=4672 
| stats count by user src_ip 
| where count > 5
```

**Severity:** Critical  
**MITRE ATT&CK:** T1134 - Access Token Manipulation

### 3. Lateral Movement (RDP)

```spl
index=windows_security EventCode=4624 LogonType=10 
| transaction src_ip user maxspan=1h 
| where event_count > 3
| table _time src_ip user duration
```

**Severity:** Medium  
**MITRE ATT&CK:** T1021 - Remote Services

### 4. Threat Intel Matching

```spl
index=* 
| lookup threat_intel_ips.csv ip_address AS src_ip 
| where is_notnull(threat_type)
| table _time src_ip threat_type confidence severity
```

**Severity:** Afhankelijk van threat intel  
**Use Case:** Detecteer C2 communicatie

---

## Dashboards Overzicht

| Dashboard | Doel | Key Metrics |
|-----------|------|-------------|
| **Overview** | KPIs en index overzicht | Total events, unique indexes, data volume |
| **Security Alerts** | Alert monitoring | Severity breakdown, alert count |
| **Authentication** | User/host monitoring | Failed logins, privilege changes |
| **Endpoint** | Process monitoring | Suspicious processes, command lines |
| **Network** | Network traffic | Top IPs, ports, protocols |
| **MITRE ATT&CK** | Threat hunting | Techniques detected, tactics |
| **Investigation** | Incident response | Drilldown, timeline |

---

## Tips & Best Practices

### Performance

```spl
# ✓ Goed - specifiek
index=windows_security EventCode=4625

# ✗ Slecht - te breed
index=* | search EventCode=4625

# ✓ Gebruik earliest/latest
index=security earliest=-7d@d latest=@d

# ✣ Vermijd lange time ranges zonder filter
index=* earliest=-30d@d
```

### Detection Rules

- Begin met **brede detectie**, verfijn dan (tune false positives)
- Gebruik **lookups** voor enrichment (threat intel, asset inventory)
- Documenteer **MITRE ATT&CK mapping** voor elke rule
- Test rules in **ontwikkelomgeving** voordat je naar productie gaat

### Incident Response

1. **Alert** → Open Security Alerts dashboard
2. **Filter** → Op severity, time range, user/host
3. **Drilldown** → Klik op alert voor details
4. **Investigate** → Gebruik Investigation dashboard
5. **Document** → Noteer bevindingen in ticketing systeem

---

## Resources

- [Splunk Docs: SPL Reference](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/SPL)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [SOC-Analyst GitHub](https://github.com/HVSoftware/SOC-Analyst)
- [Documentation Site](https://hvsoftware.github.io/SOC-Analyst/)

---

**Versie:** 1.0  
**Laatst bijgewerkt:** 2025-09-17
