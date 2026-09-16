# US-15 — Workflow Actions

| Veld | Waarde |
|---|---|
| ID | `US-15` |
| Titel | Workflow Actions voor Ticket Creation |
| Rol | SOC Analyst |
| Afhankelijk van | US-08 (Drilldown actions) |
| Status | Open |

## Verhaal

**Als** SOC Analyst,  
**wil ik** vanuit een alert direct een ticket kunnen aanmaken in ons ticketing systeem (ServiceNow/Jira),  
**zodat** incidenten correct worden getracked en geëscaleerd volgens onze procedures.

## Acceptatiecriteria

- [ ] **Workflow actions** beschikbaar in dashboard drilldowns
- [ ] **ServiceNow integratie** — Ticket creation met alert details
- [ ] **Jira integratie** — Issue creation met alert details
- [ ] **Pre-populated fields** — Alert data automatisch ingevuld in ticket
- [ ] **Ticket link** → Teruglink van ticket naar Splunk alert
- [ ] **Documentatie** voor beide integraties

## Technische Specificaties

### Workflow Action Types

```ini
# workflow_actions.conf
[ticket_servicenow]
label = Create ServiceNow Incident
type = link
uri https://instance.service-now.com/nav_to.do?uri=incident.do?sysparm_action=add&sysparm_query=short_description=$alert_name$&description=$alert_description$
priority = high

[ticket_jira]
label = Create Jira Issue
type = link
uri https://jira.company.com/secure/CreateIssueDetails!init.jspa?pid=10001&issuetype=10001&summary=$alert_name$&description=$alert_description$
priority = high
```

### Alert Data Mapping

| Splunk Field | ServiceNow Field | Jira Field |
|-------------|------------------|------------|
| $result.host$ | affected_ci | environment |
| $result.user$ | caller_id | assignee |
| $result.severity$ | urgency | priority |
| $result._time$ | opened_at | created |
| $result.alert_name$ | short_description | summary |
| $result.description$ | description | description |
| $result.investigation_url$ | work_notes | description (continued) |

### Drilldown Integration

```xml
<!-- In dashboard XML -->
<drilldown>
  <link target="_blank">
    https://splunk.company.com/en-us/app/SOC-Analyst/investigation?form.host=$click.value$
  </link>
  <option name="workflow_action">ticket_servicenow</option>
</drilldown>
```

## Deliverables

1. **default/workflow_actions.conf** — Workflow action definities
2. **default/transforms.conf** — Field mappings voor ticket data
3. **docs/WORKFLOW_INTEGRATIONS.md** — ServiceNow + Jira setup guide
4. **Templates** — Ticket templates voor beide systemen
5. **Test cases** — End-to-end ticket creation testen

## Integratie Opties

### ServiceNow

```
Base URL: https://<instance>.service-now.com
API: REST Table API (incident table)
Auth: Basic Auth of OAuth
Fields: short_description, description, urgency, impact, assigned_to, cmdb_ci
```

### Jira

```
Base URL: https://<company>.atlassian.net
API: REST API v3
Auth: API Token
Fields: summary, description, priority, assignee, labels, issuetype
```

### Alternatieven (Fase 3)

- Microsoft Teams webhook
- Slack webhook
- PagerDuty integration
- Email-to-ticket (via email gateway)

## Test Scenario's

1. **ServiceNow ticket creation** — Klik op alert → ticket aangemaakt
2. **Jira issue creation** — Klik op alert → issue aangemaakt
3. **Field validatie** — Alle alert data correct overgenomen
4. **Link validatie** — Ticket bevat link terug naar Splunk
5. **Permission check** — Alleen geautoriseerde users kunnen tickets maken
6. **Error handling** — Graceful failure als ticketing systeem unavailable

## Dependencies

- ServiceNow of Jira instance toegang
- API credentials (niet in Git!)
- US-08 drilldown actions moeten bestaan
- Splunk user permissions voor workflow actions

## Risico's en Mitigatie

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| Credentials in Git | Kritiek | Gebruik Splunk secrets, environment variables |
| Ticket spam | Medium | Confirmation dialog voor ticket creation |
| Data leakage | Medium | Minimaliseer PII in ticket fields |
| API rate limiting | Laag | Cache credentials, implementeer retry logic |

## Definition of Done

- [ ] workflow_actions.conf aangemaakt met ServiceNow + Jira actions
- [ ] Drilldown integration in alle relevante dashboards
- [ ] Documentatie compleet (WORKFLOW_INTEGRATIONS.md)
- [ ] Test tickets succesvol aangemaakt in beide systemen
- [ ] Credentials veilig opgeslagen (niet in Git)
- [ ] User Story gemarkeerd als "Klaar" in README

## Notes

- Workflow actions vereisen Splunk Enterprise (niet in Free versie)
- Overweeg confirmation modal voor ticket creation (voorkom accidental tickets)
- ServiceNow CMDB mapping voor host → CI requires extra configuratie
- Jira project key en issue type moeten worden geconfigureerd per environment
