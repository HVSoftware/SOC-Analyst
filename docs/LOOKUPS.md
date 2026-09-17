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

## Common Issues

### 1. "Lookup file not found"

**Cause:** File not uploaded to Splunk.

**Solution:**
```bash
# Check if file exists on server
ls -la /opt/splunk/etc/apps/SOC-Analyst/lookups/

# Upload via Splunk Web
Settings → Lookups → Lookup table files → New
```

### 2. "Could not find field"

**Cause:** Field names in CSV do not match search.

**Solution:**
- Check header row in CSV file
- Use exact same field names in your search
- Example: CSV has `ip_address`, search must use `ip_address` (not `ip` or `dest`)

### 3. Lookup returned no results

**Cause:** Match type does not match or data does not match.

**Solution:**
- Check match type in `transforms.conf`:
  - `EXACT(ip_address)` = exact match
  - `WILDCARD(host)` = wildcard match
- Verify data format matches (no trailing spaces, correct case)

### 4. Lookup slows down searches

**Cause:** Large lookup tables or inefficient match type.

**Solution:**
- Use `EXACT` instead of `WILDCARD` where possible
- Add `max_matches` to transforms.conf:
  ```ini
  [threat_intel_ips_lookup]
  max_matches = 1
  ```
- Consider summary indexing for historical lookups

---

## CSV Format Specifications

All CSV files must comply with:

- **Encoding:** UTF-8
- **Delimiter:** Comma (`,`)
- **Header row:** Required (first line)
- **Line endings:** Unix (`\n`) or Windows (`\r\n`)
- **Quoting:** Double quotes for fields with commas

**Example:**
```csv
ip_address,threat_type,source,last_seen,confidence,description
185.220.101.1,tor_exit_node,abuse.ch,2025-09-15,high,Known Tor exit node
```

---

## Security Considerations

### Lookups with Sensitive Data

- **asset_inventory.csv** and **user_identity.csv** may contain sensitive info
- Consider **not** committing these files to a public GitHub repo
- Use `.gitignore` to exclude sensitive lookups:
  ```
  lookups/asset_inventory.csv
  lookups/user_identity.csv
  ```

### Threat Intel Lookups

- Publicly available feeds (like Abuse.ch) are safe to share
- Commercial feeds (CrowdStrike, Mandiant) must **not** be shared
- Check license terms of each feed

---

## Resources

- [Splunk Docs: Lookup manual](https://docs.splunk.com/Documentation/Splunk/latest/Admin/Lookupsmanual)
- [Splunk Docs: transforms.conf](https://docs.splunk.com/Documentation/Splunk/latest/Admin/Transformsconf)
- [Abuse.ch Threat Intel](https://abuse.ch/)
- [MITRE ATT&CK](https://attack.mitre.org/)
