# US-04 — Input fields voor filtering

| Veld | Waarde |
|---|---|
| ID | US-04 |
| Titel | Input fields voor filtering toevoegen aan dashboards |
| Rol | SOC Analyst |
| Afhankelijk van | US-02 |
| Status | **Klaar** |
| Datum voltooid | 2025-09-16 |
| Prioriteit | **P2 — Medium** |
| Geschatte effort | 1 uur |

## Verhaal

Als SOC Analyst wil ik kunnen filteren op specifieke gebruikers, hosts en IP-adressen via dropdowns en search boxes, zodat ik snel incidenten kan isoleren zonder handmatig SPL queries aan te passen.

## Doel

Voeg input fields toe aan dashboards voor:
- **User filter** (dropdown of text input)
- **Host filter** (dropdown van bekende hosts)
- **IP filter** (text input voor IP address search)
- **Severity filter** (dropdown: All, Low, Medium, High, Critical)

## Acceptatiecriteria

- [ ] Security Alerts dashboard heeft severity filter
- [ ] Authentication dashboard heeft user filter
- [ ] Endpoint dashboard heeft host filter
- [ ] Network dashboard heeft IP filter (src en dest)
- [ ] Filters zijn optioneel (toon alles als leeg)
- [ ] Filters combineren met time range picker
- [ ] Input fields bovenaan dashboard in `<fieldset>`

## Implementation Notes

Gebruik Splunk `<input type="dropdown">` of `<input type="text">`:

```xml
<fieldset submitButton="false">
  <input type="time" token="time_range">
    <label>Tijdvenster:</label>
  </input>
  
  <input type="dropdown" token="user_filter" searchWhenChanged="true">
    <label>Gebruiker:</label>
    <choice value="*">Alle gebruikers</choice>
    <searchString>`soc_auth` | stats count by user | sort - count | head 20</searchString>
    <fieldForLabel>user</fieldForLabel>
    <fieldForValue>user</fieldForValue>
  </input>
</fieldset>
```

## Definition of Done

- [ ] Minimaal 3 dashboards hebben input filters
- [ ] Filters werken correct met time range tokens
- [ ] Getest in Splunk
- [ ] Git commit gemaakt
