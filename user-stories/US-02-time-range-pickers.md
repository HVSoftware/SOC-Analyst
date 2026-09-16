# US-02 — Time range pickers toevoegen

| Veld | Waarde |
|---|---|
| ID | US-02 |
| Titel | Time range pickers toevoegen aan alle dashboards |
| Rol | SOC Analyst |
| Afhankelijk van | US-00 |
| Status | **Klaar** |
| Datum voltooid | 2025-09-16 |
| Prioriteit | **P1 — High** |
| Geschatte effort | 30 minuten |

## Verhaal

Als SOC Analyst wil ik het tijdvenster kunnen aanpassen van dashboards (1h, 4h, 24h, 7d, 30d, custom), zodat ik zowel recente incidenten als langere trends kan analyseren zonder de XML aan te passen.

## Huidige Situatie

**Alle dashboards** hebben hardcoded time ranges:

```xml
<earliestTime>-24h@h</earliestTime>
<latestTime>now</latestTime>
```

**Probleem:**
- Geen flexibiliteit voor short-term analysis (last hour)
- Geen long-term trend analysis (last week/month)
- Gebruiker moet XML editen om tijdvenster te wijzigen
- Niet gebruikelijk voor Splunk dashboards (verwacht wordt time input)

## Doel

Voeg Splunk time input tokens toe aan alle 5 dashboards zodat gebruikers het tijdvenster dynamisch kunnen kiezen.

## Acceptatiecriteria

- [ ] Elk dashboard heeft een time range picker bovenaan
- [ ] Standaardopties: Last hour, 4h, 24h, 7d, 30d, All time
- [ ] Custom time range mogelijk
- [ ] Default blijft 24h (bestaande gedrag behouden)
- [ ] Alle panels in dashboard gebruiken dezelfde time token
- [ ] Time picker is "sticky" (keuze blijft behouden bij navigatie)

## Proposed Solution

Voeg `<fieldset>` met `<input type="time">` toe aan elk dashboard:

```xml
<dashboard>
  <label>Security Alerts</label>
  
  <!-- Time range input -->
  <fieldset submitButton="false">
    <input type="time" token="time_range" searchWhenChanged="true">
      <label>Tijdvenster:</label>
      <default>
        <earliestTime>-24h@h</earliestTime>
        <latestTime>now</latestTime>
      </default>
    </input>
  </fieldset>
  
  <row>
    <panel>
      <title>Top Security Alerts</title>
      <chart>
        <!-- Gebruik token in plaats van hardcoded waarden -->
        <searchString>`soc_analyst` | stats count by severity</searchString>
        <earliest>$time_range.earliest$</earliest>
        <latest>$time_range.latest$</latest>
      </chart>
    </panel>
    <!-- ... andere panels ... -->
  </row>
</dashboard>
```

## Implementatie Stappen

Voor elk dashboard (`overview.xml`, `security_alerts.xml`, `authentication.xml`, `endpoint.xml`, `network.xml`):

1. Voeg `<fieldset>` met time input toe na `<label>`
2. Vervang hardcoded `<earliestTime>` en `<latestTime>` met token references:
   - `<earliest>$time_range.earliest$</earliest>`
   - `<latest>$time_range.latest$</latest>`
3. Test in Splunk
4. Commit per dashboard of batch

## Files to Modify

```
default/data/ui/views/
├── overview.xml
├── security_alerts.xml
├── authentication.xml
├── endpoint.xml
└── network.xml
```

## Test

Na implementatie:
1. Open elk dashboard in Splunk
2. Verander time range naar "Last hour"
3. Verifieer dat data ververst met nieuwe tijdvenster
4. Verander naar "Last 7 days"
5. Verifieer dat alle panels updaten
6. Navigeer naar ander dashboard en terug — keuze blijft behouden

## Definition of Done

- [x] Alle 5 dashboards hebben time range picker
- [x] Time tokens correct geïmplementeerd in alle panels
- [x] Default is 24h (bestaande gedrag)
- [x] Getest in Splunk (geen errors)
- [x] Git commits gemaakt (conventional commits)

## Notes

- Time input is standaard Splunk functionaliteit — geen custom JS nodig
- `searchWhenChanged="true"` zorgt voor auto-refresh bij wijziging
- Token naam `time_range` is arbitrair, kan ook `timerange` of `timepicker` zijn
