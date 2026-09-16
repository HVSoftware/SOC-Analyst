# Troubleshooting Guide

## Veelvoorkomende Problemen

### 1. Dashboards tonen "No results found"

**Oorzaak:** Macros wijzen naar verkeerde indexes of sourcetypes.

**Oplossing:**
```bash
# Test macro in Search & Reporting
| makeresults 
| eval test=`soc_analyst` 
| head 1
```

Ga naar **Settings → Advanced Search → Search Macros** en pas aan:
- `soc_analyst`: `index=main OR index=security`
- `soc_endpoint`: Jouw Sysmon sourcetype
- `soc_auth`: Jouw Security log sourcetype

---

### 2. Alerts worden niet verzonden

**Oorzaak:** SMTP niet geconfigureerd of alert threshold niet bereikt.

**Oplossing:**

1. **SMTP configureren:**
   - Ga naar **Settings → Server settings → Email settings**
   - Vul SMTP server, port, credentials in
   - Test met **Send test email**

2. **Alert threshold checken:**
   - Open **Settings → Saved searches**
   - Edit de alert
   - Verlaag tijdelijk threshold voor test
   - Forceer test event

3. **Alert history checken:**
   - Ga naar **Settings → Saved searches → Alert manager**
   - Check of alerts triggeren maar niet verzenden

---

### 3. Lookup errors: "Could not find lookup table"

**Oorzaak:** CSV bestanden niet geüpload of permissions incorrect.

**Oplossing:**

```bash
# Upload lookups handmatig
cd ~/Projects/SOC-Analyst/lookups

# Via Splunk web:
# Settings → Lookups → Lookup table files → New lookup table
```

Controleer permissions:
```bash
ls -la /opt/splunk/etc/apps/SOC-Analyst/lookups/
# Moet owned zijn door splunk:splunk
```

---

### 4. XML parse error in dashboard

**Oorzaak:** Syntax error in dashboard XML.

**Oplossing:**

```bash
# Valideer XML
cd ~/Projects/SOC-Analyst
make validate

# Of handmatig met xmllint
xmllint --noout default/data/ui/views/overview.xml
```

Veelvoorkomende errors:
- Vergeet closing tags (`</panel>`, `</row>`)
- Verkeerde token syntax (gebruik `$token$`)
- Invalid characters in search strings

---

### 5. Time range picker werkt niet

**Oorzaak:** Token niet correct geïmplementeerd.

**Oplossing:**

Controleer dashboard XML:
```xml
<!-- Moet aanwezig zijn -->
<fieldset submitButton="false">
  <input type="time" token="time_range" searchWhenChanged="true">
    <label>Tijdvenster:</label>
    <default>
      <earliestTime>-24h@h</earliestTime>
      <latestTime>now</latestTime>
    </default>
  </input>
</fieldset>

<!-- En in searches -->
<earliest>$time_range.earliest$</earliest>
<latest>$time_range.latest$</latest>
```

---

### 6. Detection rule triggerd niet

**Oorzaak:** Data komt niet overeen met search query.

**Oplossing:**

1. **Test search handmatig:**
   ```spl
   | savedsearch "[Detection] Brute Force Login Attempts"
   ```

2. **Check data availability:**
   ```spl
   index=* sourcetype="WinEventLog:Security" EventCode=4625
   | stats count
   ```

3. **Pas search aan:**
   - Verlaag threshold
   - Breid tijdvenster uit
   - Check of EventCode correct is

---

### 7. KPI panels tonen verkeerde waarden

**Oorzaak:** Search query returned geen `count` field.

**Oplossing:**

Controleer dat elke single-value search een `count` field returned:
```spl
# Goed
| stats count

# Ook goed
| stats dc(user) as count

# Fout - geen count field
| stats count by user  # Returned multiple rows
```

---

### 8. App wordt niet getoond in Splunk

**Oorzaak:** App directory niet op juiste plek of permissions incorrect.

**Oplossing:**

```bash
# Check locatie
ls -la /opt/splunk/etc/apps/ | grep SOC

# Verifieer app.conf
cat /opt/splunk/etc/apps/SOC-Analyst/default/app.conf

# Fix permissions
sudo chown -R splunk:splunk /opt/splunk/etc/apps/SOC-Analyst
sudo chmod -R 755 /opt/splunk/etc/apps/SOC-Analyst

# Restart Splunk
/opt/splunk/bin/splunk restart
```

---

### 9. Saved search syntax error

**Oorzaak:** Invalid SPL in savedsearches.conf.

**Oplossing:**

```bash
# Test search in Search & Reporting
# Kopieer search string uit savedsearches.conf

# Veelvoorkomende errors:
# - Vergeet backticks voor macros: `soc_analyst`
# - Verkeerde field names (case-sensitive!)
# - Missing pipe characters
```

---

### 10. Performance issues bij grote datasets

**Oorzaak:** Searches te breed of tijdvenster te groot.

**Oplossing:**

1. **Beperk tijdvenster:**
   - Gebruik `earliest_time = -1h@h` in plaats van `-24h`
   - Voeg time range picker toe aan dashboards

2. **Optimaliseer searches:**
   ```spl
   # Slecht - te breed
   index=* | stats count
   
   # Beter - specifiek
   index=security EventCode=4625 | stats count by user
   ```

3. **Gebruik summary indexing:**
   - Maak summary searches voor historische data
   - Gebruik `tstats` voor versnelde searches

---

## Logs controleren

```bash
# Splunk error logs
tail -f /opt/splunk/var/log/splunk/splunkd.log

# Alleen SOC-Analyst errors
tail -f /opt/splunk/var/log/splunk/splunkd.log | grep -i "SOC-Analyst"

# Via Makefile
make logs
# of
make watch-logs
```

## Handige Commands

```bash
# Build en deploy
make dev-deploy

# Valideer app
make validate

# Test saved searches
make test

# Schoonmaken
make clean

# Restart Splunk
make restart
```

## Support

- **Splunk Docs:** https://docs.splunk.com/
- **Splunk Community:** https://community.splunk.com/
- **MITRE ATT&CK:** https://attack.mitre.org/
