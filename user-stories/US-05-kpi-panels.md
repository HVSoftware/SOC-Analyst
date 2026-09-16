# US-05 — KPI single-value panels

| Veld | Waarde |
|---|---|
| ID | US-05 |
| Titel | KPI single-value panels toevoegen aan dashboards |
| Rol | SOC Analyst |
| Afhankelijk van | US-02 |
| Status | **Klaar** |
| Datum voltooid | 2025-09-16 |
| Prioriteit | **P2 — Medium** |
| Geschatte effort | 45 minuten |

## Verhaal

Als SOC Analyst wil ik bovenaan elk dashboard key metrics zien in single-value panels (zoals een dashboard), zodat ik in één oogopslag de status zie zonder door tabellen te scrollen.

## Doel

Voeg KPI panels toe aan de bovenste rij van elk dashboard:

| Dashboard | KPI 1 | KPI 2 | KPI 3 | KPI 4 |
|-----------|-------|-------|-------|-------|
| Overview | Total Events (24h) | Unique Indexes | Active Hosts | Data Volume (MB) |
| Security Alerts | Total Alerts | Critical Alerts | High Alerts | Unique Sources |
| Authentication | Total Logins | Failed Logins | Unique Users | Locked Accounts |
| Endpoint | Total Events | Unique Processes | Suspicious Count | Active Hosts |
| Network | Total Connections | Unique Src IPs | Unique Dest IPs | Bytes Transferred |

## Acceptatiecriteria

- [ ] Elk dashboard heeft een bovenste rij met 3-4 single-value panels
- [ ] Elke KPI toont een groot getal met label
- [ ] Optioneel: trend indicator (groen/rood pijltje vs vorige periode)
- [ ] KPI's updaten met time range picker
- [ ] Kleurcodering bij thresholds (bijv. rood bij >10 critical alerts)

## Implementation Notes

```xml
<row>
  <panel>
    <title>Total Events (24h)</title>
    <single>
      <searchString>`soc_analyst` | stats count</searchString>
      <earliest>$time_range.earliest$</earliest>
      <latest>$time_range.latest$</latest>
      <option name="colorMode">block</option>
      <option name="numberPrecision">0</option>
    </single>
  </panel>
  <panel>
    <title>Critical Alerts</title>
    <single>
      <searchString>`soc_analyst` severity=critical | stats count</searchString>
      <earliest>$time_range.earliest$</earliest>
      <latest>$time_range.latest$</latest>
      <option name="colorMode">block</option>
      <option name="colorRanges">0,5,10</option>
    </single>
  </panel>
</row>
```

## Definition of Done

- [x] Alle 5 dashboards hebben KPI rij bovenaan
- [x] Single-value panels werken met time tokens
- [x] Kleurcodering ingesteld waar relevant (critical/high alerts, failed logins, locked accounts)
- [x] Getest in Splunk (XML syntax correct)
- [x] Git commit gemaakt
- [x] 20 KPI panels totaal toegevoegd (4 per dashboard)
