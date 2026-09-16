# Deployment Guide

## Requirements

- **Splunk Enterprise** 8.x of **Splunk Cloud**
- **Admin access** voor app installatie
- **Data sources**:
  - Windows Event Logs (Security, System)
  - Sysmon (Event IDs: 1, 7, 8, 12)
  - Network logs (netflow, proxy, firewall)

## Installatie

### Optie 1: Via Makefile (Aanbevolen)

```bash
cd ~/Projects/SOC-Analyst

# Build en deploy
make dev-deploy

# Of handmatig:
make build
make deploy
make restart
```

### Optie 2: Via Splunk Web

1. Build het package:
   ```bash
   make build
   ```

2. Ga naar **Settings → Manage Apps → Install App from File**

3. Upload `SOC-Analyst.splunk`

4. Restart Splunk

### Optie 3: Handmatig

```bash
# Kopieer app naar Splunk apps directory
sudo cp -r ~/Projects/SOC-Analyst/default \
           ~/Projects/SOC-Analyst/metadata \
           ~/Projects/SOC-Analyst/lookups \
           /opt/splunk/etc/apps/SOC-Analyst/

# Set permissions
sudo chown -R splunk:splunk /opt/splunk/etc/apps/SOC-Analyst
sudo chmod -R 755 /opt/splunk/etc/apps/SOC-Analyst

# Restart Splunk
/opt/splunk/bin/splunk restart
```

## Configuratie

### 1. Macros aanpassen

Ga naar **Settings → Advanced Search → Search Macros** en pas aan:

| Macro | Default | Aanpassen naar |
|-------|---------|----------------|
| `soc_analyst` | `index=*` | `index=main OR index=security` |
| `soc_endpoint` | `sourcetype="WinEventLog:Sysmon"` | Jouw Sysmon sourcetype |
| `soc_auth` | `sourcetype="WinEventLog:Security"` | Jouw Security log sourcetype |
| `soc_network` | `index=netflow OR index=proxy` | Jouw network indexes |

### 2. Lookups uploaden

Ga naar **Settings → Lookups → Lookup table files**:

1. Upload de volgende CSV bestanden uit `lookups/`:
   - `asset_inventory.csv`
   - `user_identity.csv`
   - `threat_intel_hashes.csv`
   - `threat_intel_ips.csv`
   - `threat_intel_domains.csv`

2. Ga naar **Settings → Lookups → Lookup definitions** en controleer of de definitions automatisch zijn aangemaakt.

### 3. Alerts configureren

Ga naar **Settings → Saved Searches**:

1. Enable alle detection rules (staan op `disabled = 0`)
2. Configureer email alerts (vereist SMTP setup):
   - Ga naar **Settings → Server settings → Email settings**
   - Configureer SMTP server
   - Test met **Settings → Saved Searches → Edit → Alert actions**

## Verificatie

1. Open **SOC-Analyst** app
2. Controleer of alle 5 dashboards laden:
   - Overview
   - Security Alerts
   - Authentication Monitoring
   - Endpoint Monitoring
   - Network Monitoring
3. Test time range picker op elk dashboard
4. Verifieer dat searches resultaten tonen
5. Test een detection rule (bijv. genereer failed login)

## Troubleshooting

### Dashboards tonen geen data

- Controleer of macros correct zijn geconfigureerd
- Verifieer dat data binnen het tijdvenster valt
- Test search handmatig in **Search & Reporting**

### Alerts worden niet verzonden

- Controleer SMTP configuratie
- Verifieer dat alert threshold wordt bereikt
- Check **Settings → Saved Searches → Alert manager**

### Lookup errors

- Upload CSV bestanden via **Settings → Lookups**
- Controleer file permissions
- Verifieer CSV formaat (comma-separated, UTF-8)

## Next Steps

- Configureer threat intel lookups (US-06)
- Pas detection rules aan voor jouw environment
- Stel email notifications in voor critical alerts
- Overweeg MITRE ATT&CK dashboard (US-07)
