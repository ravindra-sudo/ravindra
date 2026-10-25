# 🏛️ Enterprise Architectural Decision Records (ADRs)

This directory contains key Architectural Decision Records (ADRs) establishing the foundational patterns for the enterprise Azure Landing Zone.

---

## ADR 001: Adoption of Hub-and-Spoke Network Topology with Azure Firewall Premium

* **Status:** Accepted
* **Date:** 2026-10-25
* **Deciders:** Enterprise Cloud Architect, Lead DevOps Engineer, Chief Information Security Officer (CISO)

### Context & Problem Statement
The organization is migrating 100+ workloads across Dev, UAT, and Production from an on-premises datacenter to Azure. We need a network topology that provides centralized inspection, zero-trust perimeter security, zero route duplication, and scalable isolation across multi-tier applications.

### Considered Options
1. **Mesh Network Topology (Direct VNet-to-VNet Peering)**
2. **Central Hub-and-Spoke Topology with Azure Firewall Premium**
3. **Third-Party NVA Appliances (Palo Alto / Fortinet) in Hub**

### Decision Outcome
**Chosen Option:** **Central Hub-and-Spoke Topology with Azure Firewall Premium.**

* **Positive Consequences:**
  * **Zero Overlapping Routing:** All spokes peer strictly to the central Hub VNet. Inter-spoke and Internet egress traffic is centrally inspected via User Defined Routes (`0.0.0.0/0` -> Azure Firewall Private IP).
  * **Deep Packet Inspection & TLS Termination:** Azure Firewall Premium provides native IDPS (Intrusion Detection & Prevention System) and URL filtering without licensing external VM appliances.
  * **Operational Simplicity:** Native cloud service with automatic high availability and horizontal scaling, eliminating NVA HA clustering complexities.
* **Negative Consequences / Trade-offs:**
  * Higher hourly operational cost compared to standard NSGs.
  * Requires strict Private DNS Zone integration linked to Hub VNet.

---

## ADR 002: Management Group Hierarchy and Subscription Isolation

* **Status:** Accepted
* **Date:** 2026-10-25
* **Deciders:** Enterprise Cloud Architect, Compliance Officer

### Context & Problem Statement
How should enterprise Azure subscriptions and security policies be structured to satisfy ISO 27001, CIS Azure Benchmarks, and prevent blast-radius impact between development and production environments?

### Decision Outcome
**Chosen Option:** Follow the **Microsoft Cloud Adoption Framework (CAF)** hierarchy under a single Microsoft Entra ID tenant.

* **Hierarchy:**
  ```
  [ Tenant Root Group ]
           |
  +--------+--------+------------------------+
  |                 |                        |
  [ Platform MG ]   [ Landing Zones MG ]     [ Sandbox & Decom MG ]
    |-- Identity       |-- Corp (Internal)      |-- Sandbox
    |-- Management     |-- Online (DMZ/Public)  `-- Decommissioned
    `-- Connectivity   |-- Dev Subscriptions
                       |-- UAT Subscriptions
                       `-- Prod Subscriptions
  ```
* **Consequences:**
  * Policies (e.g. Allowed Locations, Enforce Tags, Deny Public IPs) applied at Management Group level cascade deterministically.
  * Identity boundary: Production workloads run in isolated subscriptions with zero shared admin credentials to Dev/UAT.
  * Enforces Just-In-Time (JIT) access via Privileged Identity Management (PIM).

---

## ADR 003: Infrastructure as Code (IaC) Architecture & State Management

* **Status:** Accepted
* **Date:** 2026-10-25
* **Deciders:** Lead DevOps Engineer, Infrastructure Team

### Context & Problem Statement
Terraform state files contain sensitive metadata and must be protected against race conditions, accidental overwrites, and unauthorized access.

### Decision Outcome
**Chosen Option:** Remote state in **Azure Blob Storage** utilizing native blob lease locking and Azure Managed Identity.

* **Implementation Rules:**
  * Dedicated `tfstate` storage accounts per environment (`dev`, `uat`, `prod`).
  * Access keys disabled; authentication enforced exclusively via Azure AD Workload Identity / System-Assigned Managed Identity.
  * Blob Versioning and 30-day Soft Delete enabled to prevent accidental destruction.
  * Network rules: Storage account private endpoint bound exclusively to the CI/CD self-hosted runner VNet.
