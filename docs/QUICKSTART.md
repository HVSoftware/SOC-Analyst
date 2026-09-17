# Quick Start — SOC-Analyst SIEM

## Introductie

**SOC-Analyst** is een Splunk SIEM app voor security monitoring, threat hunting en incident response.

### Splunk als SIEM Oplossing

SOC-Analyst biedt volledige SIEM capabilities:

- **Real-Time Monitoring** — Live dashboards en alerts
- **Historical Analysis** — Patronen zoeken in historische data
- **Threat Hunting** — MITRE ATT&CK mapping en correlaties
- **Incident Response** — Drilldown van alert naar details
- **User Behavior Analytics (UBA)** — Enrichment via lookups

---

## 5-Minute Setup

### 1. Installeer App

```bash
# Via Makefile (lokaal)
make build
make deploy

# Of via Splunk Web
Settings → Manage Apps → Install App from File
Upload: SOC-Analyst.spl
```

### 2. Configureer Data Inputs

Zorg dat de volgende data bronnen beschikbaar zijn:

| Data Source | Sourcetype | Index |
|-------------|-----------|-------|
| Windows Security Events | `WinEventLog:Security` | `windows_security` |
| Sysmon Logs | `xmlwineventlog` | `sysmon` |
| Firewall Logs | `firewall` | `firewall` |
| Proxy Logs | `proxy` | `proxy` |

### 3. Verify Installatie

1. Open **SOC-Analyst → Overview** dashboard
2. Controleer dat "Total Events" data toont
3. Test time range picker (Last 24h, Last 7 days)

### 4. Email Alerts Instellen

Voor High/Critical alerts:

```
Settings → Server settings → Email settings
→ Configureer SMTP server
→ Test email verbinding
```

---

## Basic Searching (SPL)

### Fundamentals

Elke search begint met een basis query die verfijnd kan worden:

```spl
# Alle events (breed)
index=*

# Specifieke index
index=windows_security

# Met zoekterm
index=windows_security "failed login"
```

### Narrow Down Searches

| Methode | Voorbeeld | Beschrijving |
|---------|-----------|--------------|
| **Keywords** | `index=security "failed login"` | Zoek op termen |
| **Boolean** | `EventCode=4625 OR EventCode=4672` | AND, OR, NOT |
| **Comparison** | `severity="high"` | =, !=, <, >, <=, >= |
| **Wildcards** | `user*=admin` | * (meerdere chars), ? (één char) |

### Voorbeelden

```spl
# Brute force detectie (meerdere failed logins)
index=windows_security EventCode=4625 | stats count by src_ip

# Privilege escalation
index=windows_security EventCode=4672 | table _time user src_ip

# Met wildcard
index=sysmon CommandLine="*powershell*"
```

---

## Essentiële SPL Commands

### Field Statistics

Gebruik `fieldsummary` om inzicht te krijgen in je data:

```spl
index=windows_security 
| fieldsummary
```

**Resultaat kolommen:**

| Kolom | Beschrijving | Voorbeeld |
|-------|--------------|-----------|
| `field` | Naam van het veld | `EventCode`, `user`, `src_ip` |
| `count` | Aantal events met dit veld | `1523` |
| `distinct_count` | Aantal unieke waarden | `45` |
| `is_exact` | Count is exact of estimated | `true` / `false` |
| `max` | Maximum waarde | `4672` |
| `mean` | Gemiddelde waarde | `4625.3` |
| `min` | Minimum waarde | `4624` |
| `numeric_count` | Aantal numerieke waarden | `1523` |
| `stdev` | Standaard deviatie | `12.5` |
| `values` | Sample waarden | `["4624", "4625", "4672"]` |

**Use Case:** Data exploration voordat je searches schrijft

```spl
# Bekijk field statistics voor security events
index=windows_security earliest=-24h@d 
| fieldsummary 
| table field count distinct_count values
```

### 1. `lookup` — Data Enrichment

Verrijk search results met externe bronnen (threat intel):

```spl
# Voeg threat intel toe aan events
index=windows_security 
| lookup threat_intel_ips.csv ip_address AS src_ip 
| where is_notnull(threat_type)
| table _time src_ip threat_type severity
```

**Use Case:** Detecteer communicatie met known malicious IPs

### 2. `inputlookup` — Lookup Data Ophalen

Haal data uit lookup files zonder te joinen:

```spl
# Toon alle known malicious IPs
| inputlookup threat_intel_ips.csv 
| table ip_address threat_type confidence

# Gebruik in subsearch
index=* src_ip IN (
    [ | inputlookup threat_intel_ips.csv | fields ip_address ]
)
```

**Use Case:** Quick reference of threat intel zonder grote search

### 3. `earliest` / `latest` — Time Range

Beperk searches tot specifieke tijdperiodes:

```spl
# Laatste 24 uur
index=windows_security 
| stats count by EventCode

# Specifiek time range
index=windows_security 
| stats count by user
| where _time >= relative_time(now(), "-7d@d")
| where _time <= relative_time(now(), "@d")

# Via time picker (in dashboards)
index=windows_security 
earliest=$time_range.earliest$ 
latest=$time_range.latest$
```

**Use Case:** Historical analysis, trend detection

### 4. `transaction` — Events Groeperen

Groepeer gerelateerde events tot transactions:

```spl
# Track user sessie (meerdere events)
index=windows_security 
| transaction user maxspan=1h 
| table _time user duration event_count

# Detect lateral movement (RDP sessies)
index=windows_security EventCode=4624 LogonType=10 
| transaction src_ip user maxspan=30m 
| where event_count > 5
| table _time src_ip user duration
```

**Use Case:** User sessions, attack chains, multi-step attacks

### 5. `subsearch` — Nested Searches

Gebruik results van één search in een andere:

```spl
# Zoek users met failed logins, dan hun successful logins
index=windows_security EventCode=4624 
[ search index=windows_security EventCode=4625 
  | stats count by user 
  | where count > 5 
  | fields user ]
| table _time user src_ip

# Threat intel matching
index=* 
[ | inputlookup threat_intel_ips.csv | fields ip_address ]
| table _time src_ip dest_ip
```

**Use Case:** Correlate events, filter op dynamische criteria

---

## Use Cases (SIEM)

### 1. Brute Force Detection

```spl
index=windows_security EventCode=4625 
| stats count by src_ip user 
| where count > 10
| sort - count
```

**Severity:** High  
**MITRE ATT&CK:** T1110 - Brute Force

### 2. Privilege Escalation

```spl
index=windows_security EventCode=4672 
| stats count by user src_ip 
| where count > 5
```

**Severity:** Critical  
**MITRE ATT&CK:** T1134 - Access Token Manipulation

### 3. Lateral Movement (RDP)

```spl
index=windows_security EventCode=4624 LogonType=10 
| transaction src_ip user maxspan=1h 
| where event_count > 3
| table _time src_ip user duration
```

**Severity:** Medium  
**MITRE ATT&CK:** T1021 - Remote Services

### 4. Threat Intel Matching

```spl
index=* 
| lookup threat_intel_ips.csv ip_address AS src_ip 
| where is_notnull(threat_type)
| table _time src_ip threat_type confidence severity
```

**Severity:** Afhankelijk van threat intel  
**Use Case:** Detecteer C2 communicatie

### 5. Linux Pivot Detection (PowerShell Downloads)

```spl
index=main src_ip=10.0.0.229 sourcetype="WinEventLog:sysmon" 
| stats count by CommandLine
| search CommandLine="*powershell*" OR CommandLine="*download*"
```

**Indicators:**
- PowerShell commando's met download URLs
- Executable files gedownload naar Linux system
- Mogelijke compromise van Linux system

**Follow-up:**
```spl
# Zoek verdere connecties met Sysmon data
index=main 10.0.0.229 sourcetype="WinEventLog:sysmon" 
| stats count by CommandLine EventCode
```

### 6. DCSync Attack Detection

```spl
index=main EventCode=4662 Access_Mask=0x100 Account_Name!="*$"
| table _time Account_Name Object_Type Properties
```

**Waarom deze query werkt:**

| Component | Reden |
|-----------|-------|
| `EventCode=4662` | AD object access (moet enabled zijn op DC) |
| `Access_Mask=0x100` | Control Access - high-level permissions voor DCSync |
| `Account_Name!="$"` | Users (niet machine accounts) - DCSync is alleen legitiem voor machine accounts/SYSTEM |

**GUIDs controleren:**
```spl
# Bekijk Properties field voor GUIDs
index=main EventCode=4662 
| table _time Account_Name Properties
```

**Veelvoorkomende DCSync GUIDs:**
- `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` - DS-Replication-Get-Changes
- `1131f6ad-9c07-11d1-f79f-00c04fc2dcd2` - DS-Replication-Get-Changes-All

**Use Case:** Detecteer password dumping via DCSync

**MITRE ATT&CK:** T1003.006 - OS Credential Dumping: DCSync

---

## Dashboards Overzicht

## Advanced Investigation Workflow

### Scenario: Van Alert naar Incident Response

**Stap 1: Initial Alert**
```spl
# Alert: Verdachte PowerShell activiteit
index=main sourcetype="WinEventLog:sysmon" 
| search CommandLine="*powershell*" 
| stats count by src_ip CommandLine
```

**Stap 2: Pivot Analysis**
```spl
# Zoek connecties met gedownloade IP
index=main src_ip=<verdachte_ip> 
| stats count by dest_ip CommandLine EventCode
```

**Stap 3: DCSync Verificatie**
```spl
# Check op DCSync activiteit
index=main EventCode=4662 Access_Mask=0x100 
| search Account_Name!="*$"
| table _time Account_Name Properties
```

**Stap 4: Impact Assessment**
```spl
# Bepaal welke hosts zijn aangetast
index=main 
| search src_ip=<compromised_ip> OR dest_ip=<compromised_ip>
| stats count by host EventCode
```

### Veelvoorkomende GUIDs bij DCSync

| GUID | Naam | Risico |
|------|------|--------|
| `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` | DS-Replication-Get-Changes | 🔴 Critical |
| `1131f6ad-9c07-11d1-f79f-00c04fc2dcd2` | DS-Replication-Get-Changes-All | 🔴 Critical |
| `1131f6ae-9c07-11d1-f79f-00c04fc2dcd2` | DS-Replication-Get-Changes-In-Filtered-Set | 🟠 High |

**Actie bij DCSync detectie:**
1. Isoleer affected hosts
2. Reset compromised credentials
3. Review audit logs voor verdere activiteit
4. Documenteer bevindingen in incident ticket
5. **Overweeg krbtgt rotation** (golden ticket risico)

### 7. LSASS Credential Dumping Detection

```spl
# Sysmon EventCode 10 - Process Access
index=main EventCode=10 lsass 
| stats count by SourceImage
| sort - count
```

**Waarom sorteren op count:**
- Frequente activiteiten = waarschijnlijk normaal
- Zeldzame activiteiten (1-5 events) = makkelijker te detecteren als anomalie
- Focus op "conspicuous strange" process access

**Vervolgstap - Verdachte Processen:**
```spl
# Bijv. notepad.exe die LSASS opent (absurd!)
index=main EventCode=10 lsass SourceImage="C:\\Windows\\System32\\notepad.exe"
| table _time SourceImage TargetImage CallStack
```

**Call Stack Analyse:**
```spl
# Zoek naar UNKNOWN memory regions (shellcode indicator)
index=main EventCode=10 lsass 
| search CallStack="*UNKNOWN*"
| table _time SourceImage CallStack
```

**Indicators van LSASS Dumping:**

| Indicator | Betekenis | Risico |
|-----------|-----------|--------|
| `notepad.exe` opent LSASS | Absurd - notepad heeft geen reden om LSASS te accessen | 🔴 Critical |
| `rundll32.exe` (low frequency) | Vaak gebruikt voor DLL side-loading | 🟠 High |
| `CallStack=UNKNOWN` | Shellcode in unbacked memory region | 🔴 Critical |
| `ntdll.dll` vanuit UNKNOWN | API calls vanuit arbitrary memory (niet van disk) | 🔴 Critical |

**Waarom UNKNOWN in CallStack belangrijk is:**
- Shellcode leeft in **unbacked memory regions**
- API calls komen niet van identifiable files op disk
- Komt van arbitrary/UNKNOWN memory regions
- **False positives:** JIT processen (kunnen gefilterd worden)

**Veelvoorkomende LSASS Dumping Tools:**
- Mimikatz (`sekurlsa::logonpasswords`)
- Procdump (`procdump -ma lsass.exe`)
- Task Manager (Create Dump File)
- Custom PowerShell scripts

**Use Case:** Detecteer credential harvesting na initial access

**MITRE ATT&CK:** T1003.001 - OS Credential Dumping: LSASS Memory

### 8. Misspelled Binary Detection (Masquerading)

```spl
index=main sourcetype="WinEventLog:Sysmon" EventCode=1 
(
  CommandLine="*psexe*.exe" NOT (CommandLine="*PSEXESVC.exe" OR CommandLine="*PsExec64.exe")
) OR 
(
  ParentCommandLine="*psexe*.exe" NOT (ParentCommandLine="*PSEXESVC.exe" OR ParentCommandLine="*PsExec64.exe")
) OR 
(
  ParentImage="*psexe*.exe" NOT (ParentImage="*PSEXESVC.exe" OR ParentImage="*PsExec64.exe")
) OR 
(
  Image="*psexe*.exe" NOT (Image="*PSEXESVC.exe" OR Image="*PsExec64.exe")
)
| table Image, CommandLine, ParentImage, ParentCommandLine
```

**Waarom deze query werkt:**
- Zoekt naar variaties van `psexe` (case-insensitive)
- Sluit legitieme binaries uit: `PSEXESVC.exe`, `PsExec64.exe`
- Checkt multiple fields: Image, CommandLine, ParentImage, ParentCommandLine

**Attack Technique:**
- Attackers misspellen legitieme binaries om detectie te ontwijken
- Voorbeelden: `psexec.exe`, `PSEXESV.exe`, `psexe.exe`, `psexecsvc.exe`
- Doel: Blend in met normale systeemactiviteit

**MITRE ATT&CK:** T1036.003 - Masquerading: Rename System Utilities

### 9. Non-Standard Port Detection

```spl
index=main EventCode=3 
NOT (
  DestinationPort=80 OR 
  DestinationPort=443 OR 
  DestinationPort=22 OR 
  DestinationPort=21
)
| stats count by SourceIp, DestinationIp, DestinationPort 
| sort - count
```

**Waarom deze query werkt:**
- Exclude standaard poorten (80, 443, 22, 21)
- Focus op ongebruikelijke communicatie
- Sorteer op count → meest frequente eerst

**Non-Standard Ports om op te letten:**
| Port | Vaak Gebruikt Voor | Risico |
|------|-------------------|--------|
| 4444 | Metasploit default | 🔴 Critical |
| 5555 | Android Debug Bridge | 🟠 High |
| 8080 | Alternative HTTP | 🟡 Medium |
| 1337 | Leet/Backdoors | 🔴 Critical |
| 31337 | Back Orifice | 🔴 Critical |
| 6666-6669 | IRC (C2) | 🟠 High |

**Use Case:** Detecteer C2 communicatie, data exfiltration, lateral movement

**MITRE ATT&CK:** T1571 - Non-Standard Port

### 10. PsExec Password Discovery (Credential Hunting)

**Scenario:** Vind het wachtwoord dat is gebruikt tijdens PsExec activiteit.

**Approach 1: Directe CommandLine Search (Jouw Oplossing)**

```spl
index=main sourcetype="WinEventLog:Sysmon" EventCode=1 
(
  CommandLine="*psexe*.exe" OR 
  ParentCommandLine="*psexe*.exe" OR 
  ParentImage="*psexe*.exe" OR 
  Image="*psexe*.exe"
)
| table Image, CommandLine, ParentImage, ParentCommandLine
```

**Waarom dit werkt:**
- Checkt alle 4 de relevante fields
- `*psexe*.exe` vangt zowel legitieme als misspelled varianten
- EventCode 1 = Process Creation (Sysmon)
- Password staat in plaintext in CommandLine na `-p` flag

**Voorbeeld Output:**
```
CommandLine: psexec \\TARGET -u Administrator -p SUPERSECRETPASSWORD cmd.exe
                                                              ^
                                                              Dit is het wachtwoord!
```

---

**Approach 2: Met Rex Extractie (Automatisches Password Extraheren)**

```spl
index=main sourcetype="WinEventLog:Sysmon" EventCode=1 
| search CommandLine="*psexec*" OR Image="*psexec*"
| rex field=CommandLine "(?i)-p\s+(?<password>[^\s]+)"
| where isnotnull(password)
| table _time ComputerName User CommandLine password
```

**Regex Uitleg:**
- `(?i)` = Case-insensitive
- `-p\s+` = Match "-p" gevolgd door whitespace
- `(?<password>[^\s]+)` = Capture everything tot volgende spatie als "password" field

**Voorbeeld Output:**
```
| password             | CommandLine                                    |
|----------------------|------------------------------------------------|
| SUPERSECRETPASSWORD  | psexec \\TARGET -u Admin -p SUPERSECRETPASSWORD |
```

---

**Approach 3: Security Event Logs (EventCode 4688)**

```spl
index=main sourcetype="WinEventLog:Security" EventCode=4688 
| search ProcessName="*psexec*" OR CommandLine="*psexec*"
| rex field=CommandLine "(?i)-p\s+(?<password>[^\s]+)"
| where isnotnull(password)
| table _time AccountName ProcessName CommandLine password
```

**Wanneer gebruiken:**
- Als Sysmon niet geïnstalleerd is
- Security logs wel enabled zijn
- Process auditing aan staat op DC

---

**Approach 4: Brede Search (Alle Data Sources)**

```spl
index=main 
| search "*psexec*" 
| search CommandLine="*-p*"
| rex field=CommandLine "(?i)-p\s+(?<password>[^\s]+)"
| where isnotnull(password)
| table _time source sourcetype ComputerName User password
```

**Wanneer gebruiken:**
- Je weet niet welk sourcetype het bevat
- Quick search across alle data
- HTB CTF challenges

---

**Approach 5: Lateral Movement Context (Meerdere Hosts)**

```spl
index=main sourcetype="WinEventLog:Sysmon" EventCode=1 
| search CommandLine="*psexec*"
| rex field=CommandLine "(?i)-p\s+(?<password>[^\s]+)"
| rex field=CommandLine "\\\\(?<target_host>[^\s]+)"
| stats count by password target_host User
| sort - count
```

**Voordeel:**
- Toont welke hosts zijn benaderd
- Groepeert by wachtwoord (misschien zelfde password voor meerdere hosts?)
- Identificeert pattern in lateral movement

---

**Veelvoorkomende PsExec Password Patterns:**

| Pattern | Voorbeeld | Waar te Vinden |
|---------|-----------|----------------|
| `-p PASSWORD` | `-p Secret123!` | CommandLine |
| `-password PASSWORD` | `-password Secret123!` | CommandLine |
| Encrypted | `-p <encrypted_blob>` | Moeilijker te cracken |
| Hash | `-p <NTLM_hash>` | Pass-the-Hash attack |

---

**Tips voor Password Discovery:**

1. **Zoek naar flags:** `-p`, `-password`, `-u` (geeft user)
2. **Check ParentImage:** Waar kwam PsExec vandaan? (cmd.exe, PowerShell, etc.)
3. **Kijk naar timing:** Wanneer werd PsExec gebruikt?
4. **Correlate met EventCode 4624:** Logon events na PsExec execution
5. **Gebruik `table` command:** Voor snelle visualisatie

---

**Complete Investigation Workflow:**

```spl
/* Stap 1: Vind alle PsExec activiteit */
index=main sourcetype="WinEventLog:Sysmon" EventCode=1 
| search CommandLine="*psexec*" OR Image="*psexec*"
| stats count by ComputerName User

/* Stap 2: Extraheer passwords */
| rex field=CommandLine "(?i)-p\s+(?<password>[^\s]+)"
| where isnotnull(password)
| table _time ComputerName User password

/* Stap 3: Check welke hosts zijn benaderd */
| rex field=CommandLine "\\\\(?<target>[^\s\\]+)"
| stats count by target password

/* Stap 4: Zoek bijbehorende logon events */
index=main sourcetype="WinEventLog:Security" EventCode=4624 
| search LogonType=3 OR LogonType=10
| join ComputerName [search sourcetype="WinEventLog:Sysmon" EventCode=1 "*psexec*"]
| table _time AccountName IpAddress LogonType
```

---

**MITRE ATT&CK Mapping:**

| Technique | ID | Description |
|-----------|----|-------------|
| **Remote Services** | T1021 | PsExec voor lateral movement |
| **Command & Scripting** | T1059 | CommandLine execution |
| **OS Credential Dumping** | T1003 | Passwords extraheren |
| **Brute Force** | T1110 | Als password wordt geraden |

---

**Use Case:** Password discovery na detectie van PsExec activiteit

**HTB Challenge Solution:** Gebruik Approach 1 voor snelle find, Approach 2 voor automatische extractie

### 11. Anomaly Detection — Statistical Analysis Based on TTPs

**Introductie: Analytics-Based Detection**

Naast TTP-based detection (Layer 1) is **anomaly detection** (Layer 2) essentieel voor het vinden van onbekende threats. Door **normal behavior** te profileren en **deviations** te identificeren, kunnen we suspicious activities vinden die niet matchen met bekende TTPs.

**Principe:**
```
Normal Behavior → Baseline Profiling → Anomaly Detection → Alert
```

**Sterktes:**
- ✅ Detecteert **onbekende threats** (zero-day, nieuwe TTPs)
- ✅ **Data-driven** — gebaseerd op feitelijke patronen
- ✅ **Adaptief** — baseline evolueert mee met environment
- ✅ **Proactief** — niet afhankelijk van bekende signatures

**Limitaties:**
- ⚠️ **False positives** — niet alle anomalies zijn malicious
- ⚠️ **Calibratie nodig** — threshold aanpassen per environment
- ⚠️ **Baseline period** — heeft tijd nodig om "normaal" te leren
- ⚠️ **Context vereist** — investigation nodig om malicious te bevestigen

---

## 📊 Anomaly Detection Techniques

### Technique 1: Network Connections per Process (streamstats)

**Detecteer abnormale netwerkactiviteit per proces:**

```spl
index=main sourcetype="WinEventLog:Sysmon" EventCode=3 
| bin _time span=1h 
| stats count as NetworkConnections by _time, Image 
| streamstats time_window=24h avg(NetworkConnections) as avg stdev(NetworkConnections) as stdev by Image 
| eval isOutlier=if(NetworkConnections > (avg + (0.5*stdev)), 1, 0) 
| search isOutlier=1
| table _time Image NetworkConnections avg stdev
```

**Hoe het werkt:**

| Stap | Command | Doel |
|------|---------|------|
| 1 | `EventCode=3` | Filter op network connection events |
| 2 | `bin _time span=1h` | Groepeer events per uur |
| 3 | `stats count by Image` | Tel netwerkconnecties per proces per uur |
| 4 | `streamstats time_window=24h` | Bereken rolling average + stdev over 24u |
| 5 | `eval isOutlier` | Markeer als > 0.5 standaarddeviaties van gemiddelde |
| 6 | `search isOutlier=1` | Filter alleen outliers |

**Waarom 0.5 * stdev?**
- **Lage threshold** (0.5) = meer detecties, meer false positives
- **Hoge threshold** (2.0+) = minder detecties, minder false positives
- **Aanbeveling:** Start met 0.5, kalibreer op basis van environment

**Use Case:**
- Detecteer C2 communicatie
- Data exfiltration attempts
- Malware die netwerkconnecties maakt

**MITRE ATT&CK:** T1071 - Application Layer Protocol, T1041 - Exfiltration Over C2 Channel

---

### Technique 2: Abnormally Long Commands

**Detecteer unusually lange command lines (vaak obfuscation):**

```spl
index=main sourcetype="WinEventLog:Sysmon" Image=*cmd.exe 
| eval len=len(CommandLine) 
| table User, len, CommandLine 
| sort - len
```

**Met Filtering (Reduce Noise):**

```spl
index=main sourcetype="WinEventLog:Sysmon" Image=*cmd.exe 
ParentImage!="*msiexec.exe" 
ParentImage!="*explorer.exe"
| eval len=len(CommandLine) 
| table User, len, CommandLine 
| sort - len
```

**Waarom filteren?**
- `msiexec.exe` → Vaak lange installatie commands (benign)
- `explorer.exe` → User interactie (vaak benign)
- **Focus op:** `winword.exe`, `excel.exe`, `outlook.exe` (verdacht!)

**Veelvoorkomende Oorzaken van Lange Commands:**

| Oorzaak | Voorbeeld | Risico |
|---------|-----------|--------|
| **Encoded PowerShell** | `-enc JABjAGwAaQBlAG4AdAA9...` | 🔴 Critical |
| **Download & Execute** | `certutil -urlcache -split -f http://...` | 🔴 Critical |
| **Obfuscated Script** | `^p^o^w^e^r^s^h^e^l^l -c ...` | 🟠 High |
| **Benign Install** | `msiexec /i package.msi /qn` | 🟢 Low |

**Threshold Advies:**
```spl
| where len > 500  /* Verdacht */
| where len > 1000 /* Zeer verdacht */
| where len > 2000 /* Bijna altijd malicious */
```

**MITRE ATT&CK:** T1059.001 - PowerShell, T1059.003 - Windows Command Shell

---

### Technique 3: Abnormal cmd.exe Activity (Time-Based)

**Detecteer ongebruikelijke hoeveelheid cmd.exe executies:**

```spl
index=main EventCode=1 CommandLine="*cmd.exe*" 
| bucket _time span=1h 
| stats count as cmdCount by _time User CommandLine 
| eventstats avg(cmdCount) as avg stdev(cmdCount) as stdev 
| eval isOutlier=if(cmdCount > avg + (1.5*stdev), 1, 0) 
| search isOutlier=1
| table _time User CommandLine cmdCount avg stdev
```

**Verschil met Technique 1:**
| `streamstats` | `eventstats` |
|---------------|--------------|
| Rolling window (24h) | Global average over gehele search |
| Per Image | Per User/CommandLine |
| Dynamische baseline | Statische baseline |

**Wanneer gebruiken:**
- **streamstats** → Langere periode, trend analyse
- **eventstats** → Snapshot, specifieke tijdvenster

**Use Case:**
- Brute force scripts (vele cmd.exe calls)
- Automated attack tools
- Lateral movement scripts

**MITRE ATT&CK:** T1059.003 - Windows Command Shell

---

### Technique 4: High DLL Loading Rate

**Detecteer processen die verdacht veel DLLs laden (malware indicator):**

```spl
index=main EventCode=7 
NOT (Image="C:\\Windows\\System32*") 
NOT (Image="C:\\Program Files (x86)*") 
NOT (Image="C:\\Program Files*") 
NOT (Image="C:\\ProgramData*") 
NOT (Image="C:\\Users\\*\\AppData*")
| bucket _time span=1h 
| stats dc(ImageLoaded) as unique_dlls_loaded by _time, Image 
| where unique_dlls_loaded > 3 
| stats count by Image, unique_dlls_loaded 
| sort - unique_dlls_loaded
```

**Waarom deze filters?**

| Path | Reden voor Exclude |
|------|-------------------|
| `System32` | Windows systeemprocessen (veel DLLs normaal) |
| `Program Files` | Geïnstalleerde software (benign) |
| `ProgramData` | Vaak legitimate applicaties |
| `AppData` | User-specific apps (kan zowel benign als malicious) |

**Focus op:**
- `C:\\Users\\Public\\` → Vaak malware staging
- `C:\\Temp\\` → Verdachte locatie
- `C:\\PerfLogs\\` → Vaak over het hoofd gezien

**Hoe het werkt:**
1. `EventCode=7` → Sysmon DLL Load events
2. `NOT Image=...` → Exclude bekende benign paths
3. `dc(ImageLoaded)` → Count unique DLLs per proces
4. `where > 3` → Filter op >3 unique DLLs per uur
5. `sort` → Meest verdachte bovenaan

**Use Case:**
- Malware die meerdere DLLs laadt in korte tijd
- Process injection voorbereiding
- Reflective DLL injection

**MITRE ATT&CK:** T1055 - Process Injection, T1574 - Hijack Execution Flow

---

### Technique 5: Repeated Process Execution (Transaction)

**Detecteer dezelfde process die meerdere keren start op dezelfde host:**

```spl
index=main sourcetype="WinEventLog:Sysmon" EventCode=1 
| transaction ComputerName, Image 
| where mvcount(ProcessGuid) > 1 
| stats count by Image, ParentImage
| sort - count
```

**Hoe het werkt:**

| Command | Doel |
|---------|------|
| `transaction ComputerName, Image` | Groepeer events met zelfde proces op zelfde host |
| `mvcount(ProcessGuid) > 1` | Alleen als proces >1x is gestart |
| `stats count by Image, ParentImage` | Tel hoe vaak per proces/parent combinatie |

**Vervolgstap - Deep Dive:**

```spl
index=main sourcetype="WinEventLog:Sysmon" EventCode=1 
| transaction ComputerName, Image 
| where mvcount(ProcessGuid) > 1 
| search Image="C:\\Windows\\System32\\rundll32.exe" ParentImage="C:\\Windows\\System32\\svchost.exe" 
| table CommandLine, ParentCommandLine, _time
```

**Verdachte Combinaties:**

| Parent → Child | Risico | Reden |
|----------------|--------|-------|
| `svchost.exe` → `rundll32.exe` | 🟠 High | Vaak gebruikt voor DLL side-loading |
| `winword.exe` → `cmd.exe` | 🔴 Critical | Macro malware |
| `excel.exe` → `powershell.exe` | 🔴 Critical | Excel4Macro / XLM |
| `outlook.exe` → `cmd.exe` | 🟠 High | Attachment malware |

**Use Case:**
- Persistentie mechanismen
- Scheduled tasks die malware herstarten
- Cron jobs van attackers

**MITRE ATT&CK:** T1053 - Scheduled Task/Job, T1547 - Boot or Logon Autostart

---

## 🎯 Calibration Guide

### Threshold Aanpassingen

| Environment | Threshold | Reden |
|-------------|-----------|-------|
| **Corporate** | 0.5-1.0 * stdev | Veel users, variabele activity |
| **Server** | 1.5-2.0 * stdev | Stabiele workload, minder variatie |
| **Critical Systems** | 0.3-0.5 * stdev | Zeer sensitief, alles alerten |
| **Development** | 2.0+ * stdev | Veel variatie, minder false positives |

### False Positive Reduction

**Voeg filters toe voor bekende benign activity:**

```spl
/* Exclude bekende benign processes */
NOT Image="*antivirus*"
NOT Image="*backup*"
NOT Image="*windowsupdate*"
NOT ParentImage="*msiexec.exe"
NOT ParentImage="*explorer.exe"

/* Exclude bekende benign users */
NOT User="*backup_service*"
NOT User="*system*"

/* Exclude bekende benign tijden */
NOT _time=*maintenance_window*
```

### Best Practices

1. **Start breed, verfijn dan**
   ```spl
   /* Eerst alle data zien */
   index=main EventCode=3 | stats count by Image
   
   /* Dan filteren op anomalies */
   | streamstats ... | where isOutlier=1
   ```

2. **Gebruik multiple techniques samen**
   ```spl
   /* Combineer network + process anomalies */
   (network_anomaly_query) OR (process_anomaly_query)
   | stats count by Source
   ```

3. **Baseline period minstens 7 dagen**
   ```spl
   streamstats time_window=7d ... /* Niet te kort! */
   ```

4. **Review false positives wekelijks**
   - Update filters op basis van bevindingen
   - Pas thresholds aan per environment

---

## 📋 Complete Anomaly Detection Workflow

```
Stap 1: Baseline Profiling
→ index=main EventCode=3 | stats count by Image over 7d
→ Wat is "normaal" in deze environment?

Stap 2: Anomaly Detection
→ streamstats met rolling window
→ Markeer outliers (isOutlier=1)

Stap 3: Filter False Positives
→ Exclude bekende benign activity
→ Focus op onbekende/verdachte patterns

Stap 4: Investigation
→ Handmatige review van outliers
→ Correlate met andere data sources

Stap 5: Tuning
→ Pas thresholds aan op basis van findings
→ Update filters voor next run
```

---

**Use Case:** Detecteer onbekende threats via statistical analysis

**Layer:** 2 — Anomaly Detection (van 4-layer model)

**Belangrijke Notitie:**
> "Relying solely on anomaly detection is inadequate. Combine with TTP-based detection (Layer 1), threat intelligence (Layer 3), and hypothesis-driven hunting (Layer 4) for comprehensive security."

---

## ⚠️ Belangrijke Detectie Strategie

### TTP-Based Detection: Sterktes & Limitaties

**✅ Sterktes:**
- Gebaseerd op bekende attacker gedragspatronen
- Goed gedocumenteerd (MITRE ATT&CK)
- Werkt voor bekende threat actors
- Makkelijk te communiceren aan stakeholders

**⚠️ Limitaties:**
- Adversaries evolueren continu
- Nieuwe/obscure TTPs worden niet gedetecteerd
- False negatives bij onbekende techniques
- Reactief (gebaseerd op wat al bekend is)

**🎯 Best Practice: Gelaagde Detectie**

```
Layer 1: TTP-Based Detection
→ Known bad behavior (MITRE ATT&CK)
→ Signature-based, IOCs

Layer 2: Anomaly Detection
→ Baseline van normaal gedrag
→ Detecteer afwijkingen (statistics, ML)

Layer 3: Intelligence-Driven
→ Threat intel feeds
→ Industry-specific threats

Layer 4: Hypothesis-Driven Hunting
→ "What if" scenario's
→ Proactief zoeken naar onbekende threats
```

**Voorbeeld Gelaagde Aanpak:**

| Layer | Query Type | Voorbeeld |
|-------|-----------|-----------|
| 1. TTP | Known bad | `EventCode=4662 Access_Mask=0x100` (DCSync) |
| 2. Anomaly | Statistical | `| rare CommandLine` (ongebruikelijke commands) |
| 3. Intel | Threat feed | `| lookup threat_intel.csv` (known malicious IPs) |
| 4. Hypothesis | Exploratory | "Hoe zou ik onopgemerkt data kunnen exfiltreren?" |

**Aanbeveling:**
- Begin met **TTP-based** (bekende threats)
- Bouw **anomaly detection** op (baseline gedrag)
- Integreer **threat intelligence** (external feeds)
- Doe **proactief threat hunting** (hypothesis-driven)

---

## Complete Attack Chain Voorbeeld

**Scenario: Van Initial Access tot Domain Compromise**

```
1. Initial Access → Phishing email met malicious attachment
2. Execution → PowerShell downloadt payload
3. Credential Dumping → LSASS memory access (EventCode 10)
4. Privilege Escalation → Domain Admin rechten verkregen
5. Lateral Movement → RDP naar andere hosts
6. Collection → DCSync attack (EventCode 4662)
7. Impact → Full domain compromise, golden ticket mogelijk
```

**Detection Queries per Stap:**

| Stap | Query | EventCode |
|------|-------|-----------|
| 1. Execution | `CommandLine="*powershell* -enc*"` | 1, 4688 |
| 2. LSASS Dump | `EventCode=10 lsass CallStack="*UNKNOWN*"` | 10 |
| 3. Lateral Move | `EventCode=4624 LogonType=10` | 4624 |
| 4. DCSync | `EventCode=4662 Access_Mask=0x100` | 4662 |

---

## Dashboards Overzicht

| Dashboard | Doel | Key Metrics |
|-----------|------|-------------|
| **Overview** | KPIs en index overzicht | Total events, unique indexes, data volume |
| **Security Alerts** | Alert monitoring | Severity breakdown, alert count |
| **Authentication** | User/host monitoring | Failed logins, privilege changes |
| **Endpoint** | Process monitoring | Suspicious processes, command lines |
| **Network** | Network traffic | Top IPs, ports, protocols |
| **MITRE ATT&CK** | Threat hunting | Techniques detected, tactics |
| **Investigation** | Incident response | Drilldown, timeline |

---

## Tips & Best Practices

### Performance

```spl
# ✓ Goed - specifiek
index=windows_security EventCode=4625

# ✗ Slecht - te breed
index=* | search EventCode=4625

# ✓ Gebruik earliest/latest
index=security earliest=-7d@d latest=@d

# ✣ Vermijd lange time ranges zonder filter
index=* earliest=-30d@d
```

### Detection Rules

- Begin met **brede detectie**, verfijn dan (tune false positives)
- Gebruik **lookups** voor enrichment (threat intel, asset inventory)
- Documenteer **MITRE ATT&CK mapping** voor elke rule
- Test rules in **ontwikkelomgeving** voordat je naar productie gaat

### Incident Response

1. **Alert** → Open Security Alerts dashboard
2. **Filter** → Op severity, time range, user/host
3. **Drilldown** → Klik op alert voor details
4. **Investigate** → Gebruik Investigation dashboard
5. **Document** → Noteer bevindingen in ticketing systeem

---

## Resources

### Official Splunk Documentation

- **[Splunk Search Reference](https://docs.splunk.com/Documentation/SCS/current/SearchReference/Introduction)** — Complete SPL command reference
- **[Splunk Cloud Search Reference](https://docs.splunk.com/Documentation/SplunkCloud/latest/SearchReference/)** — Cloud-specific search commands
- **[Splunk Search Tutorial](https://docs.splunk.com/Documentation/SplunkCloud/latest/Search/)** — Interactive search tutorials and guides

### Security & Threat Intelligence

- **[MITRE ATT&CK Framework](https://attack.mitre.org/)** — Adversary tactics, techniques, and procedures
- **[SOC-Analyst GitHub](https://github.com/HVSoftware/SOC-Analyst)** — Source code, issues, and releases
- **[Documentation Site](https://hvsoftware.github.io/SOC-Analyst/)** — Online documentation (GitHub Pages)

### Community & Learning

- **[Splunk Community](https://community.splunk.com/)** — Q&A, discussions, and best practices
- **[Splunk Security Essentials](https://www.splunk.com/en_us/software/splunk-security-essentials.html)** — Free security content and use cases

---

**Versie:** 1.0  
**Laatst bijgewerkt:** 2025-09-17
