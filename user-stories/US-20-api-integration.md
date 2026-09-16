# US-20 — API Integrationen (Threat Intelligence)

| Veld | Waarde |
|---|---|
| ID | `US-20` |
| Titel | Externe Threat Intelligence API Integrationen |
| Rol | Threat Hunter / SOC Analyst |
| Afhankelijk van | US-06 (Lookup tables), US-19 (Risk-based alerting) |
| Status | Open |

## Verhaal

**Als** Threat Hunter,  
**wil ik** realtime threat intelligence van externe APIs (VirusTotal, AbuseIPDB, Shodan),  
**zodat** ik IPs, domains en hashes direct kan verifiëren tijdens incident response.

## Acceptatiecriteria

- [ ] **VirusTotal API** — Hash en IP reputation checks
- [ ] **AbuseIPDB API** — IP abuse score en reports
- [ ] **Shodan API** — Host information en vulnerabilities
- [ ] **API lookup tool** — Splunk custom command voor API queries
- [ ] **Caching mechanism** — Voorkom API rate limiting
- [ ] **Documentation** — API setup en usage guide

## Technische Specificaties

### VirusTotal API Integration

```
Base URL: https://www.virustotal.com/api/v3/
Endpoints:
- /files/{hash} — File hash analysis
- /ip_addresses/{ip} — IP reputation
- /domains/{domain} — Domain analysis
- /urls/{url} — URL scanning

Auth: API Key (X-ApiKey header)
Rate Limits:
- Free: 4 requests/min, 500 requests/day
- Premium: variërend

Response Fields:
- malicious: Aantal vendors die malware detecteren
- suspicious: Aantal suspicious vendors
- harmless: Aantal harmless vendors
- reputation: Reputation score (-100 tot +100)
```

### AbuseIPDB API Integration

```
Base URL: https://api.abuseipdb.com/api/v2/
Endpoints:
- /check — Check single IP
- /bulk — Check multiple IPs (max 10,000)
- /report — Report abusive IP

Auth: API Key (Key header)
Rate Limits:
- Free: 1,000 requests/day
- Premium: Onbeperkt

Response Fields:
- abuseConfidenceScore: 0-100%
- totalReports: Aantal reports
- lastReportedAt: Laatste report timestamp
- usageType: Commercial, ISP, Data Center, etc.
```

### Shodan API Integration

```
Base URL: https://api.shodan.io/
Endpoints:
- /host/{ip} — Host information
- /shodan/host/count — Host count query
- /dns/lookup — DNS lookup

Auth: API Key (query parameter)
Rate Limits:
- Free: 1 query/sec, 100 queries total
- Premium: Variërend

Response Fields:
- ports: Open poorten
- vulns: Bekende vulnerabilities (CVEs)
- org: Organization/ISP
- os: Operating system
- last_update: Laatste scan timestamp
```

### Splunk Custom Command (Python)

```python
# bin/threat_intel_lookup.py
#!/usr/bin/env python

import splunk.Intersplunk as splunk
import requests
import json

VIRUSTOTAL_API = "https://www.virustotal.com/api/v3"
ABUSEIPDB_API = "https://api.abuseipdb.com/api/v2"
SHODAN_API = "https://api.shodan.io"

def lookup_virustotal(ip_or_hash):
    headers = {"X-ApiKey": VIRUSTOTAL_KEY}
    response = requests.get(f"{VIRUSTOTAL_API}/ip_addresses/{ip_or_hash}", headers=headers)
    return response.json()

def lookup_abuseipdb(ip):
    headers = {"Key": ABUSEIPDB_KEY}
    response = requests.get(f"{ABUSEIPDB_API}/check", headers=headers, params={"ipAddress": ip})
    return response.json()

def lookup_shodan(ip):
    response = requests.get(f"{SHODAN_API}/host/{ip}", params={"key": SHODAN_KEY})
    return response.json()

if __name__ == "__main__":
    results, dummyresults, settings = splunk.getOrganizedResults()
    for result in results:
        ip = result.get("src_ip")
        if ip:
            vt_data = lookup_virustotal(ip)
            abuse_data = lookup_abuseipdb(ip)
            shodan_data = lookup_shodan(ip)
            # Add fields to result
            result["vt_malicious"] = vt_data.get("data", {}).get("attributes", {}).get("last_analysis_stats", {}).get("malicious", 0)
            result["abuse_score"] = abuse_data.get("data", {}).get("abuseConfidenceScore", 0)
            result["shodan_ports"] = len(shodan_data.get("ports", []))
    splunk.outputResults(results)
```

### Commands.conf

```ini
[threat_intel_lookup]
filename = threat_intel_lookup.py
enableheader = true
outputheader = true
passauth = true
```

## Deliverables

1. **bin/threat_intel_lookup.py** — Python script voor API integration
2. **default/commands.conf** — Custom command definitie
3. **default/app.conf** — Script permissions
4. **lookups/api_cache.csv** — API response caching
5. **docs/API_INTEGRATION.md** — Setup en usage guide
6. **Makefile target** — `make api-test` voor API validatie
7. **Dashboard panel** — Threat intel lookup tool

## API Key Management

```
⚠️ BELANGRIJK: API keys NOOIT in Git commiten!

Opties:
1. Splunk Secrets (aanbevolen)
   - Settings → Server settings → Secrets
   - Referentie in script via $SPLUNK_HOME/etc/apps/SOC-Analyst/local/secrets.conf

2. Environment variables
   - Set in $SPLUNK_HOME/etc/splunk-launch.conf
   - VIRUSTOTAL_API_KEY=xxx
   - ABUSEIPDB_API_KEY=xxx
   - SHODAN_API_KEY=xxx

3. Local configuration (development only)
   - local/api_keys.conf (in .gitignore)
   - [threat_intel]
   - virustotal_key = xxx
   - abuseipdb_key = xxx
   - shodan_key = xxx
```

## Caching Strategy

```python
# Cache API responses om rate limiting te voorkomen
CACHE_TTL = 3600  # 1 uur

def get_cached_lookup(ip, api_type):
    cache_key = f"{api_type}:{ip}"
    cached = lookup_cache.get(cache_key)
    
    if cached and (time.time() - cached["timestamp"]) < CACHE_TTL:
        return cached["data"]
    
    # API call
    data = call_api(ip, api_type)
    
    # Cache result
    lookup_cache[cache_key] = {
        "timestamp": time.time(),
        "data": data
    }
    
    return data
```

## Test Scenario's

1. **VirusTotal lookup** — IP/hash reputation correct opgehaald
2. **AbuseIPDB lookup** — Abuse score correct opgehaald
3. **Shodan lookup** — Host info correct opgehaald
4. **Rate limiting** — Caching werkt, API limits niet overschreden
5. **Error handling** — Graceful failure bij API errors
6. **API key security** — Keys niet zichtbaar in logs of Git

## Dependencies

- US-06 lookup tables (voor caching)
- Python 3.x in Splunk environment
- Requests library (`pip install requests`)
- API keys voor VirusTotal, AbuseIPDB, Shodan

## Risico's en Mitigatie

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| API keys leaked | Kritiek | Gebruik Splunk secrets, nooit in Git |
| API rate limiting | Hoog | Implementeer caching, respecteer limits |
| API unavailable | Medium | Timeout handling, fallback naar cached data |
| Cost overrun | Medium | Monitor API usage, set daily limits |
| False positives | Medium | Cross-reference multiple APIs, manual review |

## Definition of Done

- [ ] threat_intel_lookup.py script werkt voor alle 3 APIs
- [ ] commands.conf geconfigureerd
- [ ] API caching geïmplementeerd
- [ ] API keys veilig opgeslagen (niet in Git)
- [ ] API_INTEGRATION.md documentatie compleet
- [ ] Test cases succesvol uitgevoerd
- [ ] Rate limiting getest en geverifieerd
- [ ] User Story gemarkeerd als "Klaar" in README

## Notes

- VirusTotal free tier: 500 requests/day (voldoende voor kleine SOC)
- AbuseIPDB free tier: 1,000 requests/day
- Shodan free tier: Beperkt, overweeg subscription voor production
- Overweeg additional APIs: IBM X-Force, AlienVault OTX, Cisco Talos (Fase 3)
- API responses moeten worden gelogd voor auditing
- Implementeer alerting bij API failures of unusual usage patterns
