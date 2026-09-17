# US-22 — Fix MITRE ATT&CK Dashboard XML EntityRef Error (Recurring)

| Veld | Waarde |
|---|---|
| ID | `US-22` |
| Titel | Fix MITRE ATT&CK Dashboard XML EntityRef Error - Recurring Issue |
| Rol | Developer / SOC Analyst |
| Afhankelijk van | US-07 (MITRE ATT&CK dashboard), US-21 (previous fix attempt) |
| Status | **In uitvoering** |
| Datum gecreëerd | 2025-09-17 |
| Prioriteit | **P1 — Critical** |

## Verhaal

**Als** SOC Analyst,  
**wil ik** dat het MITRE ATT&CK dashboard correct laadt zonder XML errors,  
**zodat** ik threat hunting kan uitvoeren zonder technische problemen.

## Probleem (Recurring - US-21 niet volledig gefixt)

```
XML Syntax Error: EntityRef: expecting ';', line 2, column 22
File: mitre_attack.xml
URL: http://10.129.23.57:8000/en-US/app/SOC-Analyst-1.4.2/mitre_attack
```

**Root Cause:** De `&` in `ATT&CK` op regel 2 is niet geëscaped:
```xml
<label>MITRE ATT&CK Overview</label>
                    ^
                    column 22
```

**Waarom US-21 niet geholpen heeft:**
- US-21 focuste op `&` in search queries en links
- De `&` in de dashboard label tekst over het hoofd gezien
- XML vereist dat ALLE `&` tekens geëscaped worden als `&amp;`

## Acceptatiecriteria

- [ ] **XML validatie** — mitre_attack.xml valideert zonder EntityRef errors
- [ ] **Dashboard laadt** — Geen XML syntax errors in Splunk
- [ ] **Label correct** — `ATT&CK` wordt `ATT&amp;CK` in XML
- [ ] **Weergave** — Dashboard toont "MITRE ATT&CK Overview" correct voor gebruiker
- [ ] **Getest** — Dashboard getest in Splunk environment via browser

## Technische Fix

```xml
<!-- FOUT (huidig) -->
<label>MITRE ATT&CK Overview</label>

<!-- GOED (fix) -->
<label>MITRE ATT&amp;CK Overview</label>
```

**XML Entity Escaping:**
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&apos;`

## Implementatie Stappen

1. Open `default/data/ui/views/mitre_attack.xml`
2. Zoek alle voorkomens van `&` in tekst (niet in attribute values)
3. Escape ze als `&amp;`
4. Test in Splunk
5. Validateer XML
6. Commit met fix message

## Files to Modify

```
default/data/ui/views/mitre_attack.xml
```

## Test

Na implementatie:
1. Open MITRE ATT&CK dashboard in Splunk
2. Verifieer geen XML error pagina
3. Dashboard laadt correct met "MITRE ATT&CK Overview" titel
4. Alle panels werken correct

## Definition of Done

- [ ] mitre_attack.xml gefixt (alle & geëscaped)
- [ ] XML validatie succesvol
- [ ] Dashboard getest in Splunk (geen errors)
- [ ] Commit met fix message
- [ ] User Story gemarkeerd als "Klaar"
- [ ] US-21 updated met referentie naar US-22

## Notes

- US-21 was een eerdere poging maar miste deze specifieke `&` in de label
- XML parsing is strict — ALLE special characters moeten geëscaped worden
- Splunk Dashboard Studio zou dit automatisch kunnen doen, maar bij handmatige XML moet je oppassen
