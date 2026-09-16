# Lookup Tables — Beheer en Upload Instructies

## Overzicht

SOC-Analyst bevat 5 lookup tabellen voor threat intelligence en asset management. Deze bestanden staan in de `lookups/` map van de Git repository.

## Lookup Bestanden

| Bestand | Doel | Records | Update Frequentie |
|---------|------|---------|-------------------|
| `asset_inventory.csv` | Asset info (criticality, owner, location) | 10 | Maandelijks of bij wijzigingen |
| `user_identity.csv` | User mapping (department, role, privileged) | 10 | Bij user changes |
| `threat_intel_hashes.csv` | Malware hashes (virustotal, mandiant, etc.) | 10 | Wekelijks |
| `threat_intel_ips.csv` | Known bad IPs (tor exit nodes, C2, etc.) | 10 | Dagelijks |
| `threat_intel_domains.csv` | Malicious domains (phishing, C2, etc.) | 10 | Dagelijks |

## Bestandslocaties

### In Git Repository
```
~/Projects/SOC-Analyst/lookups/
├── asset_inventory.csv
├── user_identity.csv
├── threat_intel_hashes.csv
├── threat_intel_ips.csv
└── threat_intel_domains.csv
```

### Op Splunk Server (na upload)
```
/opt/splunk/etc/apps/SOC-Analyst/lookups/
```

---

## Upload Instructies (Splunk Web)

### Stap 1: Lookup Table Files Uploaden

1. Log in op **Splunk Web**
2. Ga naar **Settings** → **Lookups** → **Lookup table files**
3. Klik op **New lookup table file**
4. Upload elk CSV bestand uit de `lookups/` map:
   - `asset_inventory.csv`
   - `user_identity.csv`
   - `threat_intel_hashes.csv`
   - `threat_intel_ips.csv`
   - `threat_intel_domains.csv`
5. Herhaal voor alle 5 bestanden

### Stap 2: Lookup Definitions Controleren

Na upload zouden de lookup definitions automatisch aangemaakt moeten zijn. Controleer:

1. Ga naar **Settings** → **Lookups** → **Lookup definitions**
2. Verifieer dat de volgende definitions bestaan:
   - `asset_inventory_lookup`
   - `user_identity_lookup`
   - `threat_intel_hashes_lookup`
   - `threat_intel_ips_lookup`
   - `threat_intel_domains_lookup`

Als een definition ontbreekt, maak deze handmatig aan:

1. Klik op **New lookup definition**
2. Kies het juiste lookup table file
3. Geef de definition de juiste naam (zie boven)
4. Klik **Save**

### Stap 3: Collections Controleren

De lookup collections moeten automatisch geladen worden uit `default/collections.conf`. Controleer:

1. Ga naar **Settings** → **Lookups** → **Lookup table files**
2. Verifieer dat alle bestanden status **Ready** hebben

---

## Lookup Data Onderhouden

### Optie 1: Handmatig Updaten (Aanbevolen)

1. Download CSV bestand van Splunk server:
   ```bash
   scp splunk@server:/opt/splunk/etc/apps/SOC-Analyst/lookups/threat_intel_ips.csv .
   ```

2. Bewerk lokaal (voeg nieuwe rows toe)

3. Upload naar Git:
   ```bash
   git add lookups/threat_intel_ips.csv
   git commit -m "update: threat intel IPs - 2025-09-16"
   git push
   ```

4. Upload nieuwe versie naar Splunk:
   - Settings → Lookups → Lookup table files
   - Klik op bestandsnaam
   - **Update lookup table file**
   - Upload nieuwe CSV

### Optie 2: Automatiseren met Script

Voor threat intel lookups kun je een script maken dat automatisch feeds ophaalt:

```python
#!/usr/bin/env python3
# scripts/update_threat_intel.py

import csv
import requests
from datetime import datetime

# Voorbeeld: Abuse.ch IP blocklist
url = "https://sslbl.abuse.ch/blacklist/sslblacklist_ip.csv"
response = requests.get(url)
lines = response.text.splitlines()

with open('lookups/threat_intel_ips.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['ip_address', 'threat_type', 'source', 'last_seen', 'confidence', 'description'])
    
    for line in lines[1:]:  # Skip header
        if line and not line.startswith('#'):
            ip = line.strip()
            writer.writerow([
                ip,
                'malware_c2',
                'abuse.ch',
                datetime.now().strftime('%Y-%m-%d'),
                'high',
                'Abuse.ch SSL blocklist'
            ])

print("✓ threat_intel_ips.csv updated")
```

**Cron job voor dagelijkse update:**
```bash
# Crontab
0 6 * * * cd ~/Projects/SOC-Analyst && ./scripts/update_threat_intel_ips.py && git add . && git commit -m "auto: daily threat intel update" && git push
```

---

## Lookup Usage Voorbeelden

### Voorbeeld 1: Verrijk events met asset info

```spl
`soc_endpoint`
| lookup asset_inventory_lookup host AS host OUTPUT asset_type, criticality, owner
| table _time host asset_type criticality owner ProcessName
```

### Voorbeeld 2: Detecteer known bad IPs

```spl
`soc_network`
| lookup threat_intel_ips_lookup ip_address AS dest_ip OUTPUT threat_type, source
| where isnotnull(threat_type)
| table _time src_ip dest_ip threat_type source
```

### Voorbeeld 3: Check user privileges

```spl
`soc_auth` EventCode=4672
| lookup user_identity_lookup user AS user OUTPUT is_privileged, department
| where is_privileged="true"
| table _time user department is_privileged
```

### Voorbeeld 4: Threat intel enrichment dashboard

```spl
`soc_network`
| lookup threat_intel_ips_lookup ip_address AS src_ip OUTPUT threat_type AS src_threat
| lookup threat_intel_ips_lookup ip_address AS dest_ip OUTPUT threat_type AS dest_threat
| where isnotnull(src_threat) OR isnotnull(dest_threat)
| stats count by src_threat, dest_threat
```

---

## Veelvoorkomende Problemen

### 1. "Lookup file not found"

**Oorzaak:** Bestand is niet geüpload naar Splunk.

**Oplossing:**
```bash
# Check of bestand bestaat op server
ls -la /opt/splunk/etc/apps/SOC-Analyst/lookups/

# Upload via Splunk Web
Settings → Lookups → Lookup table files → New
```

### 2. "Could not find field"

**Oorzaak:** Field namen in CSV komen niet overeen met search.

**Oplossing:**
- Check header row in CSV bestand
- Gebruik exact dezelfde field namen in je search
- Voorbeeld: CSV heeft `ip_address`, search moet `ip_address` gebruiken (niet `ip` of `dest`)

### 3. Lookup returned geen resultaten

**Oorzaak:** Match type komt niet overeen of data komt niet overeen.

**Oplossing:**
- Check match type in `transforms.conf`:
  - `EXACT(ip_address)` = exacte match
  - `WILDCARD(host)` = wildcard match
- Verifieer dat data formaat overeenkomt (geen trailing spaces, correcte case)

### 4. Lookup vertraagt searches

**Oorzaak:** Grote lookup tabellen of inefficiënt match type.

**Oplossing:**
- Gebruik `EXACT` in plaats van `WILDCARD` waar mogelijk
- Voeg `max_matches` toe aan transforms.conf:
  ```ini
  [threat_intel_ips_lookup]
  max_matches = 1
  ```
- Overweeg summary indexing voor historische lookups

---

## CSV Formaat Specificaties

Alle CSV bestanden moeten voldoen aan:

- **Encoding:** UTF-8
- **Delimiter:** Comma (`,`)
- **Header row:** Vereist (eerste regel)
- **Line endings:** Unix (`\n`) of Windows (`\r\n`)
- **Quoting:** Double quotes voor velden met commas

**Voorbeeld:**
```csv
ip_address,threat_type,source,last_seen,confidence,description
185.220.101.1,tor_exit_node,abuse.ch,2025-09-15,high,Known Tor exit node
```

---

## Security Overwegingen

### Lookups met Gevoelige Data

- **asset_inventory.csv** en **user_identity.csv** kunnen gevoelige info bevatten
- Overweeg deze bestanden **niet** in een public GitHub repo te zetten
- Gebruik `.gitignore` om gevoelige lookups uit te sluiten:
  ```
  lookups/asset_inventory.csv
  lookups/user_identity.csv
  ```

### Threat Intel Lookups

- Publiek beschikbare feeds (zoals Abuse.ch) zijn veilig om te delen
- Commerciële feeds (CrowdStrike, Mandiant) mogen **niet** gedeeld worden
- Check license voorwaarden van elke feed

---

## Resources

- [Splunk Docs: Lookup manual](https://docs.splunk.com/Documentation/Splunk/latest/Admin/Lookupsmanual)
- [Splunk Docs: transforms.conf](https://docs.splunk.com/Documentation/Splunk/latest/Admin/Transformsconf)
- [Abuse.ch Threat Intel](https://abuse.ch/)
- [MITRE ATT&CK](https://attack.mitre.org/)
