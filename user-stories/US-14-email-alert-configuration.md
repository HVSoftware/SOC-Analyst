# US-14 — Email Alert Configuratie

| Veld | Waarde |
|---|---|
| ID | `US-14` |
| Titel | Email Alert Configuratie |
| Rol | SOC Analyst |
| Afhankelijk van | US-03 (Saved searches + alerts) |
| Status | Open |

## Verhaal

**Als** SOC Analyst,  
**wil ik** dat High en Critical severity alerts automatisch een email sturen naar het SOC team,  
**zodat** we direct kunnen reageren op serieuze security incidenten.

## Acceptatiecriteria

- [ ] **Email actions geconfigureerd** in savedsearches.conf voor alle High/Critical alerts
- [ ] **Email templates** met duidelijke subject lines en body inhoud
- [ ] **Alert details** in email: timestamp, severity, affected host/user, description
- [ ] **Escalatie matrix** in documentatie (wie ontvangt welke alerts)
- [ ] **Test procedure** voor email delivery
- [ ] **Troubleshooting** sectie voor email delivery issues

## Technische Specificaties

### Email Action Configuraties

```ini
# Voorbeeld: Brute Force Detection (High severity)
action.email = 1
action.email.to = soc-team@company.com
action.email.subject = [SOC-ALERT] Brute Force Attack Detected - $result.host$
action.email.body = Security Alert: Brute force attack detected...
action.email.priority = high
action.email.inline = 1
action.email.format = table
```

### Alert Routing

| Severity | Ontvangers | Response Time |
|----------|-----------|---------------|
| Critical | SOC Lead + CISO | < 15 minuten |
| High | SOC Team | < 1 uur |
| Medium | SOC Team (batch) | < 4 uur |
| Low | Daily digest | 24 uur |

### Email Template Structuur

```
Subject: [SOC-ALERT] $alert_name$ - $result.host$

Body:
═══════════════════════════════════════
SECURITY ALERT NOTIFICATION
═══════════════════════════════════════

Alert Name: $result.alert_name$
Severity: $result.severity$
Time: $result._time$
Host: $result.host$
User: $result.user$
Source: $result.source$

Description:
$result.description$

Recommended Actions:
1. $result.recommended_action_1$
2. $result.recommended_action_2$

Investigation Dashboard:
https://splunk.company.com/en-us/app/SOC-Analyst/investigation?form.host=$result.host$

═══════════════════════════════════════
SOC-Analyst App v1.2.0
```

## Deliverables

1. **savedsearches.conf bijwerken** — Email actions toevoegen aan bestaande alerts
2. **alert_actions.conf** — Globale email instellingen
3. **docs/EMAIL_ALERTS.md** — Configuratie en beheer documentatie
4. **Escalatie matrix template** — CSV bestand voor alert routing

## Test Scenario's

1. **Trigger High severity alert** → Verifieer email aankomst binnen 1 minuut
2. **Trigger Critical alert** → Verifieer email naar meerdere ontvangers
3. **Email format check** → HTML vs plain text rendering
4. **Link validatie** → Alle dashboard links werken correct
5. **Rate limiting** → Max 1 email per alert per 5 minuten (voorkom spam)

## Dependencies

- Splunk email server configuratie (Settings → Server settings → Email settings)
- SMTP server toegang
- US-03 saved searches moeten bestaan

## Risico's en Mitigatie

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| Email spam bij veel alerts | Hoog | Rate limiting, batch alerts voor Low severity |
| Email komt niet aan | Kritiek | Test procedure, alternate notification channel |
| Sensitieve data in email | Medium | Geen PII in subject, minimale data in body |

## Definition of Done

- [ ] Alle High/Critical alerts hebben email actions
- [ ] Email templates getest in Splunk
- [ ] Documentatie compleet (EMAIL_ALERTS.md)
- [ ] Escalatie matrix template beschikbaar
- [ ] Test emails succesvol verzonden
- [ ] Rate limiting geconfigureerd
- [ ] User Story gemarkeerd als "Klaar" in README

## Notes

- Email configuratie vereist Splunk admin toegang
- SMTP credentials niet in Git commiten (gebruik environment variables)
- Overweeg alternatieve notification channels (Slack, Teams, PagerDuty) voor Fase 3
