# US-07 — MITRE ATT&CK mapping dashboard

| Veld | Waarde |
|---|---|
| ID | US-07 |
| Titel | MITRE ATT&CK mapping dashboard voor threat hunting |
| Rol | Threat Hunter |
| Afhankelijk van | US-03, US-06 |
| Status | Open |
| Prioriteit | **P3 — Advanced** |
| Geschatte effort | 2 uur |

## Verhaal

Als Threat Hunter wil ik security alerts en events kunnen mapperen naar MITRE ATT&CK techniques en tactics, zodat ik attack patterns kan herkennen en gerichte hunting queries kan uitvoeren.

## Doel

Creëer een MITRE ATT&CK dashboard dat:
1. Alerts visualiseert per ATT&CK tactic (Initial Access, Execution, Persistence, etc.)
2. Techniques toont met bijbehorende detection rules
3. Heatmap van activity per tactic/technique
4. Hunting queries per technique

## Acceptatiecriteria

- [ ] MITRE ATT&CK lookup table (`mitre_attack.csv`) met technique mapping
- [ ] Dashboard met:
  - Tactic overview (bar chart)
  - Technique heatmap
  - Recent alerts per technique
  - Hunting query library
- [ ] Saved searches uit US-03 gemapped naar ATT&CK IDs
- [ ] Documentatie van mapping

## MITRE ATT&CK Mapping Table

### Voorbeeld mapping voor US-03 detection rules:

| Detection Rule | MITRE Tactic | MITRE Technique | ID |
|----------------|--------------|-----------------|-----|
| Brute Force Login | Credential Access | Brute Force | T1110 |
| Privilege Escalation | Privilege Escalation | Token Impersonation | T1134 |
| PowerShell Encoded Command | Execution | Command and Scripting Interpreter | T1059.001 |
| Lateral Movement - RDP | Lateral Movement | Remote Services | T1021 |
| Data Exfiltration | Exfiltration | Exfiltration Over C2 Channel | T1041 |
| Process Injection | Defense Evasion | Process Injection | T1055 |

## Proposed Dashboard Layout

```
┌─────────────────────────────────────────────────────────────┐
│  MITRE ATT&CK Overview                           [Time Picker] │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Total Alerts │  │ Techniques   │  │ Top Tactic   │      │
│  │    (24h)     │  │   Detected   │  │   (7d)       │      │
│  │     47       │  │      8       │  │  Credential  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  Alerts per Tactic (Bar Chart)                              │
│  ██████████ Initial Access                                  │
│  ██████████████ Execution                                   │
│  ███████ Persistence                                        │
│  ████████████████████ Credential Access                     │
│  ██████████ Lateral Movement                                │
├─────────────────────────────────────────────────────────────┤
│  Technique Heatmap                                          │
│  [Grid met tactics als rijen, techniques als kolommen]      │
├─────────────────────────────────────────────────────────────┤
│  Recent Alerts by Technique (Table)                         │
│  Time | Technique | Alert | Severity | Host                 │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Stappen

1. **MITRE Lookup aanmaken:**
   ```csv
   technique_id,technique_name,tactic,tactic_id,detection_rule
   T1110,Brute Force,Credential Access,TA0006,[Detection] Brute Force Login
   T1134,Token Impersonation,Privilege Escalation,TA0004,[Detection] Privilege Escalation
   ```

2. **Dashboard XML creëren:**
   - `default/data/ui/views/mitre_attack.xml`
   - Gebruik lookup om alerts te mapperen
   - Visualiseer per tactic/technique

3. **Hunting queries toevoegen:**
   - Per technique een voorbeeld hunting query
   - Link naar MITRE ATT&CK website (https://attack.mitre.org/techniques/<ID>/)

## Example SPL with MITRE Mapping

```spl
`soc_analyst`
| eval mitre_technique=case(
    EventCode=4625, "T1110 - Brute Force",
    EventCode=4672, "T1134 - Token Impersonation",
    EventCode=4624 AND LogonType=10, "T1021 - Remote Services",
    EventCode=1 AND CommandLine="* -enc*", "T1059.001 - PowerShell"
  )
| eval mitre_tactic=case(
    EventCode=4625, "Credential Access",
    EventCode=4672, "Privilege Escalation",
    EventCode=4624 AND LogonType=10, "Lateral Movement",
    EventCode=1 AND CommandLine="* -enc*", "Execution"
  )
| stats count by mitre_tactic, mitre_technique
```

## Definition of Done

- [ ] MITRE ATT&CK lookup table aangemaakt
- [ ] Dashboard `mitre_attack.xml` geïmplementeerd
- [ ] Alle detection rules uit US-03 gemapped
- [ ] Heatmap visualisatie werkt
- [ ] Hunting query library aanwezig
- [ ] Git commit gemaakt
- [ ] Link naar MITRE ATT&CK navigator (optioneel)

## Notes

- MITRE ATT&CK wordt voortdurend bijgewerkt — gebruik laatste versie
- Overweeg MITRE ATT&CK Navigator voor advanced visualisatie
- Enterprise ATT&CK vs Mobile ATT&CK — focus op Enterprise voor nu
- Sommige techniques hebben sub-techniques (T1059.001, T1059.002, etc.)

## Resources

- MITRE ATT&CK: https://attack.mitre.org/
- ATT&CK Navigator: https://mitre-attack.github.io/attack-navigator/
- CSV Export: https://attack.mitre.org/resources/attack-stix-data/
