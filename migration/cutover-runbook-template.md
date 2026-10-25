# ⏱️ Production Cutover Runbook & War Room Protocol

* **Application Name:** Customer Portal & Billing Engine (Tier 1 Workload)
* **Target Migration Window:** Saturday 22:00 UTC – Sunday 02:00 UTC (4 Hours)
* **Incident Bridge / War Room:** Microsoft Teams Channel `#war-room-wave3-cutover`

---

## 1. Governance & RACI Roles

| Role | Name / Title | Contact | Responsibility |
| :--- | :--- | :--- | :--- |
| **Incident Commander** | Lead Cloud Architect | Phone / PagerDuty | Final GO / NO-GO authority & timeline execution |
| **Database Lead** | Principal DBA | Teams / Chat | Delta DB sync, replication validation, connection strings |
| **Network & Security**| Network Engineer | Teams / Chat | DNS TTL change, firewall route verification, cert bindings |
| **DevOps Engineer** | Lead DevOps | Teams / Chat | IaC pipeline execution, VM cutover, smoke tests |
| **Business Owner** | Product Manager | Phone / Teams | Business sanity sign-off & acceptance |

---

## 2. Minute-by-Minute Cutover Execution Steps

| Time (UTC) | Step # | Action Item | Owner | Status | Backout Trigger? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **21:30** | 0.1 | Open War Room Bridge; verify all key stakeholders present. | Commander | [ ] | If quorum not met by 21:45 -> Postpone |
| **21:45** | 0.2 | Verify DNS TTL was reduced to 300s (T-48h verification). | Network Lead | [ ] | If TTL > 300s -> Postpone cutover |
| **22:00** | 1.0 | **Formal GO Decision:** Announce maintenance mode window. | Commander | [ ] | Maintenance page displayed to users |
| **22:05** | 1.1 | Quiesce source on-premises database write operations. | DBA Lead | [ ] | Read-only mode verified |
| **22:15** | 1.2 | Execute final transaction log / storage delta sync. | DBA Lead | [ ] | Lag must equal 0 ms |
| **22:35** | 1.3 | Power off source on-prem VMs (DO NOT delete). | DevOps Lead | [ ] | VMware state: Powered Off |
| **22:45** | 2.0 | Power up Azure Target VMs / start Azure App Services. | DevOps Lead | [ ] | Azure health telemetry: Green |
| **23:00** | 2.1 | Run automated smoke tests (API health check, DB queries). | QA / DevOps | [ ] | If tests fail -> Trigger triage (30m max) |
| **23:30** | 3.0 | Flip Public & Private DNS records to Azure IP / Front Door. | Network Lead | [ ] | Dig/nslookup returns Azure VIP |
| **00:00** | 3.1 | Business Owner conducts real-world transactional tests. | Business Lead | [ ] | User workflows validated |
| **00:45** | 4.0 | **Final Sign-Off:** Commander approves window closure. | Commander | [ ] | Maintenance mode removed |
| **01:00** | 4.1 | Initiate 14-day Hypercare 24x7 monitoring rotation. | DevOps Lead | [ ] | PagerDuty rotation live |

---

## 3. Rollback (ABORT) Protocol

* **Hard Abort Cutoff Time:** 23:30 UTC. If business tests or critical smoke tests fail and cannot be resolved by 23:30 UTC:
  1. **Rollback Command Issued:** Incident Commander broadcasts `ABORT CUTOVER`.
  2. **Revert DNS:** Change DNS records back to On-Premises VIP immediately.
  3. **Power On Source:** Power on original on-prem VMs.
  4. **Resume Writes:** Remove read-only lock on primary on-premises database.
  5. **Post-Mortem:** Schedule root cause analysis (RCA) meeting within 24 hours.
