# US-00 — Projectstructuur + Splunk app basis

| Veld | Waarde |
|---|---|
| ID | US-00 |
| Titel | Projectstructuur + Splunk app basis |
| Rol | Developer |
| Afhankelijk van | — |
| Status | **Klaar** |
| Datum voltooid | 2025-09-15 |

## Verhaal

Als developer wil ik een werkende Splunk app structuur zodat ik dashboards, saved searches en macros kan ontwikkelen volgens Splunk best practices.

## Acceptatiecriteria

- [x] App mapstructuur volgt Splunk standaard (`default/`, `metadata/`, `bin/`, `lookups/`, `static/`)
- [x] `app.conf` bevat juiste metadata (naam, versie, beschrijving)
- [x] `macros.conf` definieert basis macros (`soc_analyst`, `soc_endpoint`, `soc_auth`, `soc_network`)
- [x] `savedsearches.conf` heeft minimaal 1 voorbeeld search
- [x] 5 dashboards aanwezig: overview, security_alerts, authentication, endpoint, network
- [x] `default.meta` configureert lees/schrijf permissions
- [x] Git repository geïnitieerd

## Review Resultaten

### ✅ Wat goed is

1. **Mapstructuur** — Volledig conform Splunk app requirements
2. **app.conf** — Correct geconfigureerd met versie 1.0, auteur, beschrijving
3. **Macros** — 4 goed gedefinieerde macros voor verschillende datatypes:
   - `soc_analyst`: Base search (index=*)
   - `soc_endpoint`: Sysmon/endpoint data
   - `soc_auth`: Windows Security logs
   - `soc_network`: Netflow/proxy/firewall
4. **Dashboards** — 5 functionele XML dashboards aanwezig
5. **Metadata** — Permissions correct ingesteld (read: *, write: admin)

### ⚠️ Knelpunten geïdentificeerd

1. **Navigation menu** — Alleen `overview` is zichtbaar, andere 4 dashboards niet bereikbaar
2. **Saved searches** — Slechts 1 voorbeeld, geen detection rules of alerts
3. **Macros** — `soc_analyst = index=*` is te breed voor production
4. **Lookups** — Leeg, geen asset inventory of threat intel
5. **Bin/** — Geen custom scripts voor enrichment
6. **Documentatie** — Alleen basis README, geen deployment guide

### 📊 Dashboard Review Summary

| Dashboard | Panels | Tijdvenster | Interactiviteit | Score |
|-----------|--------|-------------|-----------------|-------|
| Overview | 1 tabel | 24h | Geen filters | 4/10 |
| Security Alerts | 3 panels | 24h | Geen drilldown | 6/10 |
| Authentication | 3 panels | 24h | Trend chart | 7/10 |
| Endpoint | 2 panels | 24h | Geen details | 5/10 |
| Network | 2 panels | 24h | Geen enrichment | 5/10 |

**Overall Score: 6/10** — MVP ready, niet production-ready

## Vervolgstappen

Deze story is **afgerond**. Vervolgstories:

- **US-01**: Navigation menu fixen (P0 — critical)
- **US-02**: Time range pickers toevoegen (P1)
- **US-03**: Saved searches uitbreiden met alerts (P1)
- **US-06**: Lookup tables aanmaken (P2)
- **US-09**: Documentatie uitbreiden (P3)
- **US-10**: Makefile voor development workflow (P2)

## Bestanden

```
SOC-Analyst/
├── default/
│   ├── app.conf              # ✅
│   ├── macros.conf           # ✅
│   ├── savedsearches.conf    # ⚠️ 1 sample
│   └── data/ui/
│       ├── nav/default.xml   # ⚠️ incomplete
│       └── views/            # ✅ 5 dashboards
├── metadata/
│   └── default.meta          # ✅
├── bin/                      # ⚠️ leeg
├── lookups/                  # ⚠️ leeg
└── static/                   # ⚠️ leeg
```
