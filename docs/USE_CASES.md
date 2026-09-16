# Use Cases — Detection Rules

## 1. Brute Force Login Attempts

**MITRE ATT&CK:** T1110 - Brute Force  
**Severity:** High  
**Data Source:** Windows Security Logs (Event ID 4625)

### Beschrijving

Detecteert meerdere failed login pogingen (>5) binnen 1 uur vanaf dezelfde source IP of tegen dezelfde user.

### Query

```spl
`soc_auth` EventCode=4625 
| stats count by user, src_ip 
| where count > 5
```

### Response Acties

1. Identificeer betrokken user accounts
2. Check of account gelocked is (Event ID 4740)
3. Blokkeer source IP als external
4. Reset user password als compromised
5. Documenteer incident

### False Positives

- Vergeetachtige gebruikers
- Application service accounts met verkeerde credentials
- Automated scanning tools

### Tuning

Verhoog threshold van 5 naar 10 voor drukke environments.

---

## 2. Privilege Escalation - Token Elevation

**MITRE ATT&CK:** T1134 - Token Impersonation  
**Severity:** Critical  
**Data Source:** Windows Security Logs (Event ID 4672)

### Beschrijving

Detecteert privilege escalation via token elevation (SeDebugPrivilege). Indicator van mogelijke compromise.

### Query

```spl
`soc_auth` EventCode=4672 
| stats count by user, logon_id
```

### Response Acties

1. Identificeer user en proces
2. Check of elevation expected was
3. Isoleer host bij verdachte activity
4. Forensische analyse

### False Positives

- Legitieme admin tools
- Software installatie

---

## 3. Suspicious Process - PowerShell Encoded Command

**MITRE ATT&CK:** T1059.001 - Command and Scripting Interpreter  
**Severity:** High  
**Data Source:** Sysmon (Event ID 1)

### Beschrijving

Detecteert PowerShell met encoded commands. Vaak gebruikt door malware voor obfuscation.

### Query

```spl
`soc_endpoint` EventCode=1 
(ProcessName="powershell.exe" OR ProcessName="pwsh.exe") 
(CommandLine="* -enc*" OR CommandLine="* -EncodedCommand*")
```

### Response Acties

1. Analyseer command (decodeer indien mogelijk)
2. Check parent process
3. Isoleer host bij malware indicatie
4. Verzamel forensisch bewijs

### False Positives

- Legitieme scripts met encoding
- DevOps automation tools

---

## 4. Lateral Movement - RDP to Multiple Hosts

**MITRE ATT&CK:** T1021 - Remote Services  
**Severity:** Medium  
**Data Source:** Windows Security Logs (Event ID 4624, LogonType=10)

### Beschrijving

Gebruiker maakt RDP verbinding met >3 hosts binnen 1 uur. Mogelijke lateral movement.

### Query

```spl
`soc_auth` EventCode=4624 LogonType=10 
| stats dc(host) as host_count by user 
| where host_count > 3
```

### Response Acties

1. Verifieer user identity
2. Check of RDP sessions legitiem zijn
3. Monitor op verdere lateral movement
4. Documenteer pattern

### False Positives

- IT administrators
- Support personnel

---

## 5. Data Exfiltration - Large Outbound Transfer

**MITRE ATT&CK:** T1041 - Exfiltration Over C2 Channel  
**Severity:** Critical  
**Data Source:** Network logs (netflow, proxy)

### Beschrijving

Detecteert grote outbound data transfers (>500MB). Mogelijke data exfiltration.

### Query

```spl
`soc_network` 
| stats sum(bytes_out) as total_bytes by src_ip, dest_ip 
| where total_bytes > 500000000
```

### Response Acties

1. Identificeer betrokken host en user
2. Analyseer destination IP/domain
3. Blokkeer outbound verbinding
4. Start incident response
5. Verzamel network forensics

### False Positives

- Legitieme backups
- Software updates
- Cloud sync

---

## 6. Account Lockout Events

**MITRE ATT&CK:** T1110 - Brute Force  
**Severity:** Medium  
**Data Source:** Windows Security Logs (Event ID 4740)

### Beschrijving

Gebruikersaccount is locked out. Vaak indicator van brute force of compromised account.

### Query

```spl
`soc_auth` EventCode=4740 
| table _time user src_ip caller_computer_name
```

### Response Acties

1. Unlock account (indien legitiem)
2. Reset password
3. Check op brute force pattern
4. Informeer user

### False Positives

- Vergeten wachtwoorden
- Sync issues met mobile devices

---

## 7. Process Injection Detected

**MITRE ATT&CK:** T1055 - Process Injection  
**Severity:** Critical  
**Data Source:** Sysmon (Event ID 8)

### Beschrijving

Process injection gedetecteerd. Vaak malware techniek voor persistence en evasion.

### Query

```spl
`soc_endpoint` EventCode=8 
| table _time host user source_image target_image
```

### Response Acties

1. Isoleer host onmiddellijk
2. Verzamel memory dump
3. Analyseer injected code
4. Start incident response
5. Zoek naar patient zero

### False Positives

- Legitieme debugging tools
- Security software

---

## 8. Unusual Login Time

**Severity:** Low  
**Data Source:** Windows Security Logs (Event ID 4624)

### Beschrijving

Login buiten kantoortijden (voor 6:00 of na 22:00). Mogelijk ongeautoriseerde access.

### Query

```spl
`soc_auth` EventCode=4624 
| eval hour=strftime(_time,"%H") 
| where hour < 6 OR hour > 22 
| stats count by user, hour
```

### Response Acties

1. Verifieer met user
2. Check of overtime expected was
3. Monitor op verdere suspicious activity

### False Positives

- Overtime werk
- Verschillende tijdzones
- Shift workers

---

## 9. New Service Installation

**MITRE ATT&CK:** T1547 - Boot or Logon Autostart Execution  
**Severity:** Medium  
**Data Source:** Sysmon (Event ID 7)

### Beschrijving

Nieuwe image geladen in procesruimte. Mogelijke malware installatie of persistence.

### Query

```spl
`soc_endpoint` EventCode=7 
| table _time host user image signature
```

### Response Acties

1. Verifieer image signature
2. Check of installatie geautoriseerd was
3. Monitor op suspicious behavior

### False Positives

- Legitieme software installatie
- Windows updates

---

## 10. Scheduled Task Creation

**MITRE ATT&CK:** T1053 - Scheduled Task/Job  
**Severity:** Medium  
**Data Source:** Sysmon (Event ID 12)

### Beschrijving

Nieuwe scheduled task aangemaakt. Vaak gebruikt voor persistence door attackers.

### Query

```spl
`soc_endpoint` EventCode=12 
| table _time host user TargetObject
```

### Response Acties

1. Analyseer task command
2. Check of task geautoriseerd was
3. Disable task bij suspicious activity

### False Positives

- Legitieme maintenance tasks
- Software updaters
