# US-17 — Correlation Searches (Splunk ES Compatible)

| Veld | Waarde |
|---|---|
| ID | `US-17` |
| Titel | Splunk Enterprise Security Correlation Searches |
| Rol | Threat Hunter / SOC Analyst |
| Afhankelijk van | US-03 (Saved searches), US-16 (Data models) |
| Status | Open |

## Verhaal

**Als** Threat Hunter,  
**wil ik** correlation searches die compatible zijn met Splunk Enterprise Security (ES),  
**zodat** ik de app kan gebruiken in combinatie met ES voor geavanceerde threat detection.

## Acceptatiecriteria

- [ ] **ES-compatible correlation searches** — Volgen ES naming conventions
- [ ] **Risk scoring** — Risk points toegekend aan correlation results
- [ ] **Notable events** — Format compatible met ES notable events
- [ ] **MITRE mapping** — Alle searches hebben MITRE ATT&CK mapping
- [ ] **Documentation** — ES integration guide

## Technische Specificaties

### Correlation Search Naming Convention

```
SOC-Analyst: <Detection Type> - <Specific Threat>
Voorbeelden:
- SOC-Analyst: Brute Force - Multiple Failed Logons
- SOC-Analyst: Lateral Movement - Suspicious SMB Sessions
- SOC-Analyst: Data Exfiltration - Large Outbound Transfer
```

### Risk Scoring Framework

| Severity | Risk Points | Description |
|----------|-------------|-------------|
| Critical | 100 | Immediate threat, active compromise |
| High | 75 | Likely malicious, requires investigation |
| Medium | 50 | Suspicious activity, monitor closely |
| Low | 25 | Anomaly detected, low confidence |

### Notable Event Format

```ini
# Voorbeeld correlation search
[SOC-Analyst: Brute Force - Multiple Failed Logons]
search = | from datamodel:"SOC_Analyst_Data_Model.Authentication.Failed_Logons" | stats count by user, src_ip | where count > 10
correlation_search = 1
correlation_search.enabled = 1
risk_score = 75
risk_object = user
risk_object_field = user
mitre_attack_id = T1110
mitre_attack_tactic = Credential Access
description = Detected multiple failed logon attempts indicating possible brute force attack
```

### ES Integration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `risk_score` | ✅ | Numeric risk score (25-100) |
| `risk_object` | ✅ | Type of object (user, host, ip) |
| `risk_object_field` | ✅ | Field containing the risk object |
| `mitre_attack_id` | ✅ | MITRE technique ID |
| `mitre_attack_tactic` | ✅ | MITRE tactic name |
| `description` | ✅ | Human-readable description |
| `drilldown_search` | ⚠️ | Search for investigation |
| `recommended_action` | ⚠️ | Suggested response |

## Deliverables

1. **default/correlationsearches.conf** — ES-compatible correlation searches
2. **default/risk.conf** — Risk scoring definitions
3. **docs/ES_INTEGRATION.md** — Splunk ES integration guide
4. **MITRE mapping matrix** — Complete mapping voor alle searches
5. **Test cases** — ES notable event validation

## Correlation Searches (Voorbeelden)

### 1. Brute Force Detection

```ini
[SOC-Analyst: Brute Force - Multiple Failed Logons]
search = | from datamodel:"SOC_Analyst_Data_Model.Authentication.Failed_Logons" | bucket _time span=5m | stats count by user, src_ip, _time | where count > 10
correlation_search = 1
correlation_search.enabled = 1
risk_score = 75
risk_object = user
risk_object_field = user
mitre_attack_id = T1110
mitre_attack_tactic = Credential Access
description = Detected multiple failed logon attempts from same source IP indicating possible brute force attack
recommended_action = Block source IP, reset user password, investigate source
```

### 2. Privilege Escalation

```ini
[SOC-Analyst: Privilege Escalation - Suspicious Token Manipulation]
search = | from datamodel:"SOC_Analyst_Data_Model.Authentication.Privilege_Escalation" | search EventCode=4673 OR EventCode=4674
correlation_search = 1
correlation_search.enabled = 1
risk_score = 100
risk_object = user
risk_object_field = user
mitre_attack_id = T1134
mitre_attack_tactic = Defense Evasion
description = Detected suspicious privilege escalation attempt via token manipulation
recommended_action = Isolate host, investigate user activity, review privileged access
```

### 3. Lateral Movement

```ini
[SOC-Analyst: Lateral Movement - Suspicious SMB Sessions]
search = | from datamodel:"SOC_Analyst_Data_Model.Network" | search EventCode=5140 OR EventCode=5145 | stats count by src_ip, dest_ip, share_name
correlation_search = 1
correlation_search.enabled = 1
risk_score = 75
risk_object = host
risk_object_field = dest_ip
mitre_attack_id = T1021
mitre_attack_tactic = Lateral Movement
description = Detected suspicious SMB lateral movement between hosts
recommended_action = Isolate affected hosts, investigate source, review share permissions
```

## Test Scenario's

1. **ES compatibility** — Searches zichtbaar in ES Correlation Search UI
2. **Risk scoring** — Risk points correct toegekend
3. **Notable events** — Events verschijnen in ES notable queue
4. **MITRE mapping** — Alle searches hebben correcte MITRE codes
5. **Drilldown search** — Investigation searches werken vanuit notable events

## Dependencies

- Splunk Enterprise Security (optioneel, voor volledige integratie)
- US-03 saved searches moeten bestaan
- US-16 data models moeten bestaan
- ES data models (optioneel voor CIM compatibility)

## Risico's en Mitigatie

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| ES niet geïnstalleerd | Laag | App werkt standalone, ES features optioneel |
| Risk scoring incorrect | Medium | Test met sample data, validate scores |
| Notable event spam | Hoog | Tune thresholds, implementeer rate limiting |
| MITRE mapping fouten | Laag | Review door security team, update bij changes |

## Definition of Done

- [ ] correlationsearches.conf aangemaakt met alle ES-compatible searches
- [ ] risk.conf met risk scoring definitions
- [ ] Alle searches getest in ES environment (indien beschikbaar)
- [ ] MITRE mapping compleet en gevalideerd
- [ ] ES_INTEGRATION.md documentatie compleet
- [ ] User Story gemarkeerd als "Klaar" in README

## Notes

- App werkt ook zonder Splunk ES (standalone mode)
- ES integration vereist Splunk Enterprise Security license
- Overweeg CIM (Common Information Model) compatibility voor betere ES integratie
- Risk scoring kan worden aangepast per environment
- Notable events vereisen ES voor visualisatie in Security Posture dashboard
