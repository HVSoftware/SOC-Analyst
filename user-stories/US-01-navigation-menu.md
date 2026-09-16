# US-01 — Navigation menu compleet maken

| Veld | Waarde |
|---|---|
| ID | US-01 |
| Titel | Navigation menu compleet maken |
| Rol | SOC Analyst |
| Afhankelijk van | US-00 |
| Status | Open |
| Prioriteit | **P0 — Critical** |
| Geschatte effort | 5 minuten |

## Verhaal

Als SOC Analyst wil ik alle dashboards kunnen bereiken via het Splunk navigation menu, zodat ik niet handmatig URLs hoef te gebruiken of verdwaal in de app.

## Huidige Situatie

**Bestand:** `default/data/ui/nav/default.xml`

```xml
<nav>
  <view name="overview" default="true" />
</nav>
```

**Probleem:** Alleen het `overview` dashboard is zichtbaar. De andere 4 dashboards (`security_alerts`, `authentication`, `endpoint`, `network`) zijn **niet bereikbaar** via de UI!

## Doel

Maak alle 5 dashboards zichtbaar in het navigation menu, gegroepeerd per categorie.

## Acceptatiecriteria

- [ ] Alle 5 dashboards zijn zichtbaar in navigation menu
- [ ] Overzichtelijk gegroepeerd (bijv. "Monitoring", "Investigations")
- [ ] `overview` blijft default
- [ ] Saved searches accessible onder "Investigations"
- [ ] XML valideert zonder errors

## Proposed Solution

```xml
<nav>
  <view name="overview" default="true" />
  
  <collection label="Monitoring">
    <view name="security_alerts" />
    <view name="authentication" />
    <view name="endpoint" />
    <view name="network" />
  </collection>
  
  <collection label="Investigations">
    <savedSearch name="incident - sample search" />
  </collection>
</nav>
```

## Implementatie Stappen

1. Lees huidige `default/data/ui/nav/default.xml`
2. Vervang content met bovenstaande XML
3. Test in Splunk (handmatig of via make splunk-test)
4. Commit met bericht: `feat(nav): voeg alle dashboards toe aan navigation menu`

## Test

Na implementatie:
- Open SOC-Analyst app in Splunk
- Controleer navigation menu links
- Klik op elk dashboard om te verifiëren dat het laadt

## Definition of Done

- [ ] Navigation menu bevat alle 5 dashboards
- [ ] Groepering is logisch (Monitoring vs Investigations)
- [ ] XML syntax correct (geen parse errors in Splunk)
- [ ] Git commit gemaakt
- [ ] US-00 README bijgewerkt met status "Klaar"
