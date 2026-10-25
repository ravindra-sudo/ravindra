# 🎙️ Senior Cloud Architect & Lead DevOps: Scenario-Based Interview Q&A

This document compiles high-frequency, scenario-based interview questions designed for Lead DevOps, Cloud Solutions Architects, and Principal Infrastructure Engineers, with structured executive responses (STAR format: Situation, Task, Action, Result).

---

## 1. Cloud Migration at Scale (100+ Applications)

### Q: "How would you design and lead the migration of 100+ heterogeneous workloads from on-premises to Azure with minimal business disruption?"
**Executive Response Framework:**
* **Phase 1: Discovery & Dependency Mapping (Weeks 1–4):**
  * Deploy agentless discovery via **Azure Migrate appliance** across VMware/Hyper-V/Physical hosts.
  * Catalog hardware utilization (95th percentile CPU/RAM/IOPS), network port communications, and legacy OS versions.
  * Classify applications using the **6 Rs framework**:
    * *Rehost (IaaS):* Legacy COTS or tightly-coupled Windows/Linux VMs.
    * *Replatform (PaaS):* Web apps to Azure App Service / AKS; SQL databases to Azure SQL Managed Instance.
    * *Refactor:* Strategic microservices.
    * *Retire / Retain:* Redundant non-prod systems.
* **Phase 2: Landing Zone Readiness (Weeks 3–6):**
  * Implement Microsoft Cloud Adoption Framework (CAF) Management Group structure (`Platform` vs `Landing Zones`).
  * Establish Hub-and-Spoke networking with ExpressRoute / Site-to-Site VPN and Azure Firewall inspection.
  * Pre-provision Entra ID synchronization, PIM, and Azure Policy compliance guardrails.
* **Phase 3: Wave-Based Migration Sprints (Weeks 7–20):**
  * Batch workloads into 4–5 waves based on dependency tiers (Tier 3 dev/test first, Tier 2 internal apps, Tier 1 customer-facing).
  * Continuous data replication using Azure Migrate / Azure Site Recovery (ASR) to keep delta syncs under 15 minutes.
* **Phase 4: Cutover & Hypercare:**
  * Cutover executed during off-peak change windows.
  * Lower DNS TTL to 300 seconds 48 hours prior.
  * Validate database replication lag, switch traffic via DNS/Azure Front Door, verify app health telemetry, and initiate 14-day 24x7 war room hypercare.

---

## 2. Networking & Zero-Trust Security

### Q: "How do you handle IP address space exhaustion or overlapping CIDR blocks between on-prem and cloud spoke VNets?"
**Executive Response Framework:**
* **Prevention First:** Enforce central IPAM (IP Address Management) in Azure and cross-reference with corporate network teams. Allocate `/16` blocks per region and subnet down to `/24` or `/26` per workload tier.
* **Remediation for Overlaps:**
  1. **Azure Private Link / Private Endpoints:** If spoke workloads only need to consume APIs or databases from another VNet, avoid full VNet peering. Private Link maps a single non-overlapping private IP.
  2. **Network Address Translation (NAT):** Implement Azure NAT Gateway or NVA (Network Virtual Appliance / Azure Firewall) with Source NAT (SNAT) and Destination NAT (DNAT) translation rules between overlapping subnets.
  3. **Virtual WAN with Multi-Routing Tables:** Segregate routing boundaries so overlapping CIDRs never propagate into the same route table.

---

## 3. Terraform State, Concurrency & Drift Detection

### Q: "How do you guarantee state safety, prevent concurrent corruption, and handle configuration drift in enterprise Terraform setups?"
**Executive Response Framework:**
* **Remote State Architecture:**
  * Store state files in private Azure Storage Accounts with:
    * Blob Lease Locking (native automatic lock during `apply`/`plan`).
    * Versioning and Soft Delete enabled (point-in-time state recovery).
    * Storage firewall restricting access exclusively to self-hosted CI/CD runner subnets.
    * Managed Identity access only (no long-lived account access keys stored in pipelines).
* **Multi-Environment State Isolation:**
  * Strict directory isolation (`environments/prod`, `environments/uat`, `environments/dev`) rather than single workspace state files to limit blast radius.
* **Continuous Drift Detection:**
  * Automated nightly cron pipeline executing:
    ```bash
    terraform plan -detailed-exitcode -no-color
    ```
  * Exit code `0` = No changes; Exit code `2` = Drift detected. Triggers an automated alert to the DevOps on-call Slack/Teams channel with generated diff.

---

## 4. DevSecOps & Shift-Left Pipeline Security

### Q: "Where do you enforce security gates in an Azure DevOps YAML CI/CD pipeline without slowing down developer velocity?"
**Executive Response Framework:**
* **Pre-Commit (Local):** `pre-commit` hooks for `terraform fmt`, `tflint`, and `git-secrets` to prevent accidental credential commits.
* **PR Validation (Shift-Left Gate 1 - Fast, < 3 mins):**
  * Secret scanning: **Gitleaks** / Azure DevOps Advanced Security.
  * Static IaC analysis: **Checkov** or **Trivy** scanning for CIS benchmark violations.
  * Syntax & logic: `terraform validate` and `tflint`.
  * Cost estimation: **Infracost** post comments directly on the PR showing monthly delta spend.
* **Merge to Main (Gate 2):**
  * Automated `terraform plan` generating an encrypted plan artifact.
  * Branch policy requiring minimum 2 senior approvals + CODEOWNERS validation.
* **Deployment Gate (Gate 3):**
  * Azure DevOps Environment approvals requiring manual sign-off for UAT/Production.
  * Post-deployment smoke tests and automated canary / rollback triggers.

---

## 5. FinOps & Cost Optimization

### Q: "A company's cloud bill increased by 40% in one quarter. Walk me through your FinOps audit and remediation plan."
**Executive Response Framework:**
* **Step 1: Immediate Triage & Leak Plugging (48 Hours):**
  * Run automated queries to identify orphaned resources:
    * Unattached Managed Disks (Azure Resource Graph query).
    * Idle Public IPs and unused ExpressRoute circuits.
    * Orphaned snapshots older than retention policies.
* **Step 2: Utilization Analysis & Rightsizing (Week 1):**
  * Review Azure Advisor and Azure Monitor compute metrics (P95 CPU < 20%, Memory < 30%).
  * Downsize VM SKUs; convert older generation VMs (e.g., Dv3 to Dv5) for higher price-performance ratio.
  * Configure auto-shutdown schedules on all Dev/UAT environments (saving ~65% compute cost per non-prod VM).
* **Step 3: Financial Engineering (Week 2):**
  * Analyze steady-state compute baseline over the past 90 days.
  * Purchase **Azure Savings Plans** or **1-year/3-year Reserved Instances (RI)** for predictable baseline workloads (up to 72% discount).
* **Step 4: Observability & Governance Enforcement (Week 3+):**
  * Establish Data Collection Rules (DCR) to filter noisy diagnostic and security event logs before entering Log Analytics.
  * Enforce mandatory resource tagging policy (`CostCenter`, `Owner`, `Environment`, `ApplicationID`) via Azure Policy "Deny" effect.
  * Configure Cost Management automated budget alerts at 50%, 75%, 90%, and 100% of threshold.

---

## 6. Vendor & SOW Governance

### Q: "How do you manage an external systems integrator (SI) delivering cloud migration milestones when deliverables fall behind schedule?"
**Executive Response Framework:**
* **Contractual Clarity (SOW & RACI):**
  * Ensure the Statement of Work has unambiguous Acceptance Criteria tied to financial milestones, not just time-and-materials hours.
* **Early Warning Indicators:**
  * Weekly velocity tracking, burn-down charts, and code quality PR review metrics.
* **Intervention Protocol:**
  1. Review RACI matrix to verify whether blockers are caused by internal client dependencies (e.g., firewall rule delays) or vendor execution.
  2. Issue formal Cure Notice referencing SOW milestone dates if vendor delinquency is established.
  3. Convene steering committee (Technical Lead, Delivery Manager, Vendor Account Executive) to enforce recovery plan with daily checkpoint standups.
