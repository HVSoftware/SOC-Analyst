# US-21 — Fix MITRE ATT&CK Dashboard XML Syntax Error

| Veld | Waarde |
|---|---|
| ID | `US-21` |
| Titel | Fix MITRE ATT&CK Dashboard XML EntityRef Error |
| Rol | Developer / SOC Analyst |
| Afhankelijk van | US-07 (MITRE ATT&CK dashboard) |
| Status | In uitvoering |

## Verhaal

**Als** SOC Analyst,  
**wil ik** dat het MITRE ATT&CK dashboard correct laadt zonder XML errors,  
**zodat** ik threat hunting kan uitvoeren zonder technische problemen.

## Probleem

```
XML Syntax Error: EntityRef: expecting ';', line 2, column 22
File: mitre_attack.xml
```

**Oorzaak:** XML special characters (`&`, `<`, `>`) zijn niet geëscaped in dashboard XML.

## Acceptatiecriteria

- [ ] **XML validatie** — mitre_attack.xml valideert zonder errors
- [ ] **Dashboard laadt** — Geen XML syntax errors in Splunk
- [ ] **Entity escaping** — Alle `&` zijn `&amp;`, alle `<` zijn `&lt;`
- [ ] **Functie behouden** — Dashboard functionaliteit blijft intact
- [ ] **Getest** — Dashboard getest in Splunk environment

## Technische Fix

```xml
<!-- FOUT -->
<search>index=security & MITRE=T1059</search>
<link>https://attack.mitre.org/techniques/T1059/&subtechnique=1</link>

<!-- GOED -->
<search>index=security &amp; MITRE=T1059</search>
<link>https://attack.mitre.org/techniques/T1059/&amp;subtechnique=1</link>
```

## Definition of Done

- [ ] mitre_attack.xml gefixt
- [ ] XML validatie succesvol
- [ ] Dashboard getest in Splunk
- [ ] Commit met fix message
- [ ] User Story gemarkeerd als "Klaar"
