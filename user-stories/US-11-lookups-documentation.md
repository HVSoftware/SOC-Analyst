# US-11 — LOOKUPS.md documentatie

| Veld | Waarde |
|---|---|
| ID | US-11 |
| Titel | LOOKUPS.md met upload instructies |
| Rol | SOC Analyst / Admin |
| Afhankelijk van | US-06 |
| Status | **Klaar** |
| Datum voltooid | 2025-09-16 |
| Prioriteit | **P2 — Medium** |
| Geschatte effort | 30 minuten |

## Verhaal

Als SOC Analyst wil ik duidelijke instructies hebben over hoe lookup tables te uploaden en beheren in Splunk, zodat ik threat intel en asset data correct kan configureren zonder hand te zoeken in documentatie.

## Doel

Maak `docs/LOOKUPS.md` met:
1. Uitleg over lookup bestanden in de repo
2. Stap-voor-stap upload instructies
3. Hoe lookups te onderhouden/updaten
4. Veelvoorkomende problemen en oplossingen

## Acceptatiecriteria

- [ ] LOOKUPS.md aangemaakt in `docs/`
- [ ] Alle 5 lookup bestanden beschreven
- [ ] Upload instructies voor Splunk Web
- [ ] Instructies voor het updaten van lookup data
- [ ] Voorbeelden van lookup usage in searches
- [ ] Git commit gemaakt

## Lookup Bestanden

| Bestand | Doel | Aantal Records |
|---------|------|----------------|
| `asset_inventory.csv` | Asset info (criticality, owner, location) | 10 |
| `user_identity.csv` | User mapping (department, role, privileged) | 10 |
| `threat_intel_hashes.csv` | Malware hashes (virustotal, mandiant, etc.) | 10 |
| `threat_intel_ips.csv` | Known bad IPs (tor exit nodes, C2, etc.) | 10 |
| `threat_intel_domains.csv` | Malicious domains (phishing, C2, etc.) | 10 |

## Definition of Done

- [ ] LOOKUPS.md compleet
- [ ] Alle lookup bestanden gedocumenteerd
- [ ] Upload workflow beschreven
- [ ] Git commit gemaakt
