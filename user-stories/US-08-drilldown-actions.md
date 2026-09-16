# US-08 — Drilldown actions

| Veld | Waarde |
|---|---|
| ID | US-08 |
| Titel | Drilldown actions voor dashboard panels |
| Rol | SOC Analyst |
| Afhankelijk van | US-02, US-04 |
| Status | Open |
| Prioriteit | **P3 — Advanced** |
| Geschatte effort | 1.5 uur |

## Verhaal

Als SOC Analyst wil ik kunnen klikken op een panel rij of waarde om naar gedetailleerde informatie te gaan, zodat ik snel kan drillen van overzicht naar details zonder handmatig queries aan te passen.

## Doel

Voeg drilldown actions toe aan dashboard panels:
- Klik op user → toon alle events voor die user
- Klik op host → toon events voor die host
- Klik op alert → open investigation dashboard met context
- Klik op IP → toon network activity + threat intel

## Acceptatiecriteria

- [ ] Minimaal 3 dashboards hebben drilldown actions
- [ ] Drilldown opent nieuw dashboard of zelfde dashboard met filters
- [ ] Tokens worden doorgegeven (bijv. `$row.user$`, `$row.host$`)
- [ ] Optioneel: drilldown naar external URL (bijv. VirusTotal voor IPs)
- [ ] Drilldown werkt met time range context

## Implementation Examples

### Voorbeeld 1: Klik op user in Authentication dashboard

```xml
<panel>
  <title>Failed Logins - Top Users</title>
  <table>
    <searchString>`soc_auth` EventCode=4625 | stats count by user | sort - count</searchString>
    <drilldown>
      <set token="selected_user">$row.user$</set>
      <link target="_blank">/app/soc-analyst/authentication?form.user_filter=$row.user$</link>
    </drilldown>
  </table>
</panel>
```

### Voorbeeld 2: Klik op IP in Network dashboard → VirusTotal

```xml
<panel>
  <title>Top Source IPs</title>
  <table>
    <searchString>`soc_network` | stats count by src_ip | sort - count</searchString>
    <drilldown>
      <link target="_blank">https://www.virustotal.com/gui/ip-address/$row.src_ip$</link>
    </drilldown>
  </table>
</panel>
```

### Voorbeeld 3: Klik op alert → Investigation dashboard

```xml
<panel>
  <title>Recent Security Events</title>
  <table>
    <searchString>`soc_analyst` | sort - _time | head 20</searchString>
    <drilldown>
      <set token="selected_event_id">$row._id$</set>
      <set token="selected_host">$row.host$</set>
      <set token="selected_time">$row._time$</set>
      <link target="_self">/app/soc-analyst/investigation</link>
    </drilldown>
  </table>
</panel>
```

## Proposed Investigation Dashboard

Creëer nieuw dashboard `investigation.xml` voor drilldown:

```xml
<dashboard>
  <label>Incident Investigation</label>
  <fieldset>
    <input type="text" token="selected_host" searchWhenChanged="true">
      <label>Host:</label>
    </input>
    <input type="text" token="selected_user" searchWhenChanged="true">
      <label>User:</label>
    </input>
  </fieldset>
  
  <row>
    <panel>
      <title>Timeline for $selected_host$</title>
      <table>
        <searchString>`soc_endpoint` host=$selected_host$ | sort - _time</searchString>
      </table>
    </panel>
  </row>
  
  <row>
    <panel>
      <title>Related Network Activity</title>
      <table>
        <searchString>`soc_network` (src_ip=$selected_host$ OR dest_ip=$selected_host$) | sort - _time</searchString>
      </table>
    </panel>
  </row>
</dashboard>
```

## Definition of Done

- [ ] Drilldown toegevoegd aan minstens 3 dashboards
- [ ] Investigation dashboard aangemaakt
- [ ] External links werken (VirusTotal, etc.)
- [ ] Tokens correct doorgegeven
- [ ] Getest in Splunk
- [ ] Git commit gemaakt

## Notes

- `target="_self"` opent in zelfde tab
- `target="_blank"` opent in nieuwe tab
- Gebruik `$row.<field>$` voor rij-waarden
- Gebruik `$click.value$` voor simpele klikken
- Drilldown kan ook naar external URL (bijv. ticketing systeem)
