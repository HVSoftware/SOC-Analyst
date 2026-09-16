# SOC-Analyst

SOC Analyst toolbox for Splunk: threat hunting, monitoring and investigations.

## What is in the app

- Dashboards: Overview, Security Alerts, Authentication Monitoring, Endpoint Monitoring, Network Monitoring
- Saved searches and alerts
- Macros: `soc_analyst`, `soc_endpoint`, `soc_auth`, `soc_network`
- Lookups and lookup definitions

## Macros

Adjust the macros to your environment:

| Macro | Default | Purpose |
| ----- | ------- | ------- |
| `soc_analyst` | `index=*` | Base search for all data |
| `soc_endpoint` | Windows Sysmon sourcetypes | Endpoint/process data |
| `soc_auth` | `index=windows_security` | Authentication events |
| `soc_network` | netflow/proxy/firewall indexes | Network data |

## Setup

1. Deploy the app to your Splunk Search Head or Heavy Forwarder.
2. Go to Settings -> Advanced Search -> Search Macros to configure macros for your environment.
3. Configure lookups in Settings -> Lookups -> Lookup table files / Lookup definitions.

## Structure

- `default/` - Contains default configuration (app.conf, macros, saved searches, dashboards)
- `local/` - Local overrides, not for distribution
- `metadata/` - Ownership and export settings
- `static/` - Static assets (images, CSS, JS)
- `bin/` - Custom Python scripts / search commands
- `lookups/` - Lookup table files (CSV)