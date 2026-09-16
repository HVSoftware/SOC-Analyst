# US-06 — Lookup tables aanmaken

| Veld | Waarde |
|---|---|
| ID | US-06 |
| Titel | Lookup tables voor asset inventory en threat intel |
| Rol | SOC Analyst |
| Afhankelijk van | US-00 |
| Status | **Klaar** |
| Datum voltooid | 2025-09-16 |
| Prioriteit | **P2 — Medium** |
| Geschatte effort | 1 uur |

## Verhaal

Als SOC Analyst wil ik lookup tables hebben voor asset inventory, user identity mapping en threat intelligence, zodat ik events kan verrijken met context (bijv. "dit is een kritieke server" of "dit IP staat op een blocklist").

## Doel

Maak de volgende lookup tabellen aan:

1. **asset_inventory.csv** — Host info (kritikaliteit, eigenaar, locatie)
2. **user_identity.csv** — User mapping (afdeling, rol, manager)
3. **threat_intel_ips.csv** — Known bad IPs (bron: open source feeds)
4. **threat_intel_domains.csv** — Known bad domains
5. **threat_intel_hashes.csv** — Known malware hashes

## Acceptatiecriteria

- [ ] CSV bestanden aangemaakt in `lookups/` map
- [ ] Lookup definitions in `default/transforms.conf`
- [ ] Lookup automatisch geladen bij app start (`default/collections.conf`)
- [ ] Voorbeelden van lookup usage in dashboards
- [ ] Documentatie hoe lookups te updaten

## File Structuur

### asset_inventory.csv
```csv
host,asset_type,criticality,owner,location,os
DC01,domain_controller,critical,IT Team,Amsterdam,Windows Server 2022
WS001,workstation,medium,HR,Rotterdam,Windows 11
```

### user_identity.csv
```csv
user,department,role,manager,is_privileged
j.doe,IT,Administrator,j.smith,true
a.jansen,HR,Manager,k.piet,false
```

### threat_intel_ips.csv
```csv
ip_address,threat_type,source,last_seen,confidence
185.220.101.1,tor_exit_node,abuse.ch,2025-09-15,high
45.33.32.156,scanner,shodan,2025-09-14,medium
```

## Implementation Stappen

1. Maak CSV bestanden aan in `lookups/`
2. Creëer `default/transforms.conf` met lookup definitions:
   ```ini
   [asset_inventory_lookup]
   filename = asset_inventory.csv
   field_list = host,asset_type,criticality,owner,location,os
   match_type = WILDCARD(host)
   
   [threat_intel_ips_lookup]
   filename = threat_intel_ips.csv
   field_list = ip_address,threat_type,source,last_seen,confidence
   match_type = EXACT(ip_address)
   ```
3. Creëer `default/collections.conf` voor automatische loading:
   ```ini
   [threat_intel_ips]
   external_type = csv
   filename = threat_intel_ips.csv
   ```
4. Voeg lookup usage toe aan dashboards:
   ```spl
   `soc_network` 
   | lookup threat_intel_ips_lookup ip_address AS dest_ip 
   | where isnotnull(threat_type)
   ```
5. Commit met lookup bestanden + configs

## Definition of Done

- [ ] 5 CSV lookup bestanden aangemaakt (met dummy data)
- [ ] `transforms.conf` met lookup definitions
- [ ] `collections.conf` voor automatische loading
- [ ] Voorbeeld usage in tenminste 1 dashboard
- [ ] Documentatie hoe lookups te onderhouden
- [ ] Git commit gemaakt

## Notes

- Lookups kunnen ook extern worden gehost (HTTP lookup)
- Threat intel feeds kunnen geautomatiseerd worden met Python scripts
- Voor production: overweeg Splunk Threat Intelligence framework (TA-CTI)
