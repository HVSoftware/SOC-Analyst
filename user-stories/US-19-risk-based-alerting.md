# US-19 — Risk-Based Alerting

| Veld | Waarde |
|---|---|
| ID | `US-19` |
| Titel | Risk Scoring Framework voor Incident Prioritization |
| Rol | SOC Analyst / Threat Hunter |
| Afhankelijk van | US-03 (Saved searches), US-06 (Lookup tables) |
| Status | Open |

## Verhaal

**Als** SOC Analyst,  
**wil ik** risk scores voor alerts gebaseerd op asset criticality en threat context,  
**zodat** ik weet welke incidenten het eerst moeten worden onderzocht.

## Acceptatiecriteria

- [ ] **Risk scoring framework** — Algorithm voor risk calculation
- [ ] **Asset criticality** — Risk vermenigvuldigd met asset waarde
- [ ] **Threat intel enrichment** — Risk boost voor bekende threats
- [ ] **User risk scoring** — Risk gebaseerd op user role/privileges
- [ ] **Risk dashboard** — Overzicht van hoogste risk incidents
- [ ] **Documentation** — Risk framework uitleg en tuning guide

## Technische Specificaties

### Risk Calculation Formula

```
Final Risk Score = Base Severity Score × Asset Multiplier × Threat Intel Multiplier × User Role Multiplier

Where:
- Base Severity Score: Low=25, Medium=50, High=75, Critical=100
- Asset Multiplier: Standard=1.0, Important=1.5, Critical=2.0
- Threat Intel Multiplier: Unknown=1.0, Suspicious=1.5, Known Malicious=2.0
- User Role Multiplier: Standard=1.0, Privileged=1.5, Admin=2.0
```

### Risk Scoring Matrix

| Base Severity | Asset (Standard) | Asset (Critical) | + Threat Intel | + Privileged User | Max Score |
|---------------|------------------|------------------|----------------|-------------------|-----------|
| Low (25) | 25 | 50 | 75 | 112 | 150 |
| Medium (50) | 50 | 100 | 150 | 225 | 300 |
| High (75) | 75 | 150 | 225 | 337 | 450 |
| Critical (100) | 100 | 200 | 300 | 450 | 600 |

### Risk Tiers

| Risk Score | Tier | Response Time | Action |
|------------|------|---------------|--------|
| 0-100 | Low | 24 uur | Monitor, batch review |
| 101-200 | Medium | 4 uur | Investigate |
| 201-400 | High | 1 uur | Immediate response |
| 401-600 | Critical | 15 minuten | Emergency response |

### Lookup Integration

```spl
# Risk calculation search met lookups
index=security 
| lookup asset_inventory.csv dest_ip AS src_ip OUTPUT asset_criticality
| lookup user_identity.csv user_name OUTPUT user_role
| lookup threat_intel_ips.csv src_ip OUTPUT threat_confidence
| eval asset_multiplier = case(asset_criticality="Critical", 2.0, asset_criticality="Important", 1.5, 1.0)
| eval threat_multiplier = case(threat_confidence="Malicious", 2.0, threat_confidence="Suspicious", 1.5, 1.0)
| eval user_multiplier = case(user_role="Admin", 2.0, user_role="Privileged", 1.5, 1.0)
| eval base_score = case(severity="Critical", 100, severity="High", 75, severity="Medium", 50, 25)
| eval risk_score = round(base_score * asset_multiplier * threat_multiplier * user_multiplier, 0)
| eval risk_tier = case(risk_score > 400, "Critical", risk_score > 200, "High", risk_score > 100, "Medium", "Low")
```

## Deliverables

1. **default/transforms.conf** — Risk calculation transforms
2. **default/collections.conf** — Risk score collections
3. **views/risk_dashboard.xml** — Risk overview dashboard
4. **views/risk_analysis.xml** — Detailed risk analysis dashboard
5. **docs/RISK_FRAMEWORK.md** — Risk scoring methodology
6. **Makefile target** — `make risk-calculate` voor batch scoring

## Risk Dashboard Layout

```
═══════════════════════════════════════════════════════
SOC-ANALYST RISK OVERVIEW
═══════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────┐
│ TOTAL RISK SCORE: 2,450  |  CRITICAL: 3 | HIGH: 12  │
└─────────────────────────────────────────────────────┘

┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  BY ASSET    │ │  BY USER     │ │  BY THREAT   │
│  Critical: 5 │ │  Admin: 2    │ │  Known: 3    │
│  Important: 8│ │  Priv: 5     │ │  Suspicious:8│
│  Standard: 12│ │  Standard: 8 │ │  Unknown: 4  │
└──────────────┘ └──────────────┘ └──────────────┘

┌─────────────────────────────────────────────────────┐
│ TOP 10 HIGHEST RISK INCIDENTS                       │
│ [Table: Risk Score, Alert, Asset, User, Time]       │
└─────────────────────────────────────────────────────┘

┌──────────────┐ ┌──────────────┐
│  RISK TREND  │ │  BY TIER     │
│  [Line chart]│ │  [Pie chart] │
└──────────────┘ └──────────────┘
```

## Test Scenario's

1. **Risk calculation** — Scores correct berekend volgens formula
2. **Lookup integration** — Asset, user, threat intel correct toegepast
3. **Dashboard accuracy** — Risk overview toont correcte data
4. **Tier classification** — Incidents correct geclassificeerd
5. **Performance** — Risk calculation < 10 seconden voor grote datasets

## Dependencies

- US-03 saved searches moeten bestaan
- US-06 lookup tables moeten bestaan (asset_inventory, user_identity, threat_intel)
- US-18 custom fields (voor consistente veldnamen)

## Risico's en Mitigatie

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| Risk scores incorrect | Hoog | Validate met sample data, peer review |
| Performance issues | Medium | Use data models, optimize lookups |
| Over-alerting | Medium | Tune thresholds, implementeer baselines |
| False positives | Medium | Feedback loop, adjust multipliers |

## Definition of Done

- [ ] Risk calculation transforms geïmplementeerd
- [ ] Risk dashboard aangemaakt en getest
- [ ] Lookup integration werkt correct
- [ ] Risk tiers correct geclassificeerd
- [ ] RISK_FRAMEWORK.md documentatie compleet
- [ ] Test cases gevalideerd met sample data
- [ ] User Story gemarkeerd als "Klaar" in README

## Notes

- Risk multipliers kunnen worden aangepast per environment
- Overweeg machine learning voor anomaly-based risk scoring (Fase 3)
- Risk scores moeten worden gelogd voor auditing
- Implementeer feedback mechanism voor false positive reporting
- Risk dashboard kan worden geëxporteerd naar PDF voor management reporting
