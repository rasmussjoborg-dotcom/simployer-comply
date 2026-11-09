# Simployer Comply: Commercial MVP Feature Specification (V1)

> **Document Mandate:** The definitive, standalone scope for the commercial Minimum Viable Product (V1) of Simployer Comply.  
> **Target Audience:** Nordic SMEs (10–70 employees) with no in-house HR or legal counsel.  
> **Customer Promise:** *"Alltid i tråd med loven. Uten å lese den."*

---

## 1. Executive Summary & MVP Value Proposition

The Comply MVP is not an "all-in-one" HR platform. It is an **autonomous compliance guardian** designed through radical subtraction. It replaces the anxiety of unread labor laws, messy contract folders, and missed statutory deadlines with a quiet, headless service that runs 24/7 in the background.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ THE MVP VALUE EQUATION                                                                 │
├───────────────────────────────────┬────────────────────────────────────────────────────┤
│ What the Customer Experiences     │ How Comply Delivers It                             │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ **1. Instant Legal Baseline**     │ Ingests existing Drive/SharePoint files and payroll│
│    (No empty-state setup)         │ CSV to auto-build an employee register in 60 sec.  │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ **2. Contract Defensibility**     │ Automatically finds outdated clauses under AML     │
│    (Zero fear of Arbeidstilsynet) │ § 14-6 and drafts 1-click BankID addenda.          │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ **3. Proactive Threshold Alerts** │ Alerts management before crossing statutory lines  │
│    (Never miss a statutory duty)  │ (5-staff Verneombud, Day 14 sick leave meeting).   │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ **4. Legal Air Cover**            │ When an ambiguous or high-risk firing arises, 1 tap│
│    (Proof when it matters)        │ connects a named Simployer labor attorney.         │
└───────────────────────────────────┴────────────────────────────────────────────────────┘
```

---

## 2. The MVP Feature Scope (The Non-Negotiable Core)

### Module 1: Ingestion & Profiling ("Tidy Up")
* **MVP-01: Local & Cloud Folder Ingestion**
  * *Functionality:* Admin drags a local folder or connects Google Drive / Microsoft OneDrive.
  * *Acceptance Criteria:* Ingests Word/PDF contracts and parses employee names, start dates, and compensation terms without manual data entry.
* **MVP-02: Payroll CSV/Excel Ingestion**
  * *Functionality:* Reads standard exports from Tripletex, Fiken, and Visma.
  * *Acceptance Criteria:* Automatically extracts employee rosters, salaries, full-time equivalence (FTE), and department structures.
* **MVP-03: Entity Auto-Mapping**
  * *Functionality:* Resolves legal entity name and NACE code via Brønnøysund Register Centre to determine industry-specific regulations.

---

### Module 2: The Living Personnel Register
* **MVP-04: Structured Employee Directory**
  * *Functionality:* Single tabular view of all staff with live contract health indicators.
  * *Acceptance Criteria:* Each employee displays one of four statuses: `🟢 Lovlig`, `🔴 Avvik AML § 14-6`, `🟡 Prøvetid utgår snart`, or `⚠️ Mangler avtale`.
* **MVP-05: Missing Information Detector**
  * *Functionality:* Highlights records with missing social security numbers, missing signatures, or undefined working hours.

---

### Module 3: Autonomous Contract Audit & Redline Engine
* **MVP-06: AML § 14-6 Gap Detection**
  * *Functionality:* Audits contracts against the mandatory July 1, 2024 transparent working conditions directive.
  * *Acceptance Criteria:* Explicitly flags illegal blanket overtime clauses, missing paid competence rights, and non-compliant probation terms.
* **MVP-07: Side-by-Side Redline Diff Viewer**
  * *Functionality:* Displays the deprecated clause in red alongside Simployer’s vetted statutory replacement in green.
* **MVP-08: 1-Click BankID Addendum Dispatcher**
  * *Functionality:* Generates a formal legal addendum (*Tilleggsavtale til arbeidsavtale*) and dispatches it for digital signature via BankID / Signicat.
* **MVP-09: Batch Contract Remediation**
  * *Functionality:* Allows the CEO to approve a standardized overtime addendum across all affected employees simultaneously.

---

### Module 4: The Slim Living Handbook
* **MVP-10: 14-Chapter Norwegian Baseline Handbook**
  * *Functionality:* Instant, pre-populated handbook covering statutory leave, sick days, working hours, and workplace rules.
* **MVP-11: Company Customization Engine**
  * *Functionality:* Simple editing for company-specific policies (e.g. 3 vs. 8 self-certification days, remote work subsidies).
* **MVP-12: Background Statutory Update Sync**
  * *Functionality:* When national laws change, Comply generates a redline diff for the relevant chapter and notifies the admin for 1-click publishing.

---

### Module 5: The Dynamic Compliance Radar
* **MVP-13: 5-Employee Verneombud Trigger (AML § 6-1)**
  * *Functionality:* Detects headcount crossing 5 employees; generates digital election notice, voting ballots, and meeting protocols.
* **MVP-14: 10-Employee CEO HMS Training Alert (AML § 3-5)**
  * *Functionality:* Flags missing mandatory top executive HSE training; offers 1-click enrollment into Simployer Learn.
* **MVP-15: 20-Employee ARP Salary Mapping (Likestillingsloven § 26)**
  * *Functionality:* Alerts management when approaching 20 staff, pulling payroll data to run the mandatory gender pay gap analysis.
* **MVP-16: Sick-Leave Day 14 Follow-up Alert (AML § 4-6)**
  * *Functionality:* Tracks active sick leave and dispatches auto-drafted meeting invites for the statutory dialogue meeting.
* **MVP-17: 30-Day Probation Expiry Warning**
  * *Functionality:* Alerts line managers 30 days before trial periods end, providing evaluation templates.

---

### Module 6: Headless Omnichannel Execution ("No Front Door")
* **MVP-18: Native macOS Desktop Shell**
  * *Functionality:* Frameless macOS window with Sol Paper theme (`#F1EFE9`), Menu Bar status pill, and local drag-and-drop.
* **MVP-19: iOS Companion App**
  * *Functionality:* Native mobile app for push notifications, 20-second summary diffs, and biometric/FaceID approvals.
* **MVP-20: Slack & Microsoft Teams Action Cards**
  * *Functionality:* Interactive cards delivered to `#admin` or managers with `[Godkjenn]`, `[Se endring]`, and `[Spør jurist]` buttons.

---

### Module 7: Simployer Premium (The Human Bridge)
* **MVP-21: 1-Click Labor Attorney Escalation**
  * *Functionality:* Connects the user to a named Simployer labor lawyer (e.g. Ragnhild Hansen) for high-stakes or ambiguous issues.
* **MVP-22: Automated Case Dossier Assembly**
  * *Functionality:* Pre-packages employee contract, handbook excerpts, and timeline into an audit-ready legal packet for the lawyer.
* **MVP-23: Procedural Dismissal Sequence (AML § 15-1)**
  * *Functionality:* Step-by-step guidance through performance warnings and drøftelsesmøter to prevent costly court losses (*formfel*).

---

### Module 8: Executive Governance & Reporting
* **MVP-24: Monthly CEO Peace-of-Mind Report**
  * *Functionality:* Automated 1-page monthly executive email summarizing compliance status, items resolved, and active risks.
* **MVP-25: 1-Click Arbeidstilsynet Tilsynspakke**
  * *Functionality:* Instant export of an inspection-ready ZIP/PDF containing verneombud protocols, employee contracts, and HMS logs.

---

## 3. Explicit Non-Goals: What is OUT of Scope for MVP

To ensure high velocity and product focus, the following are strictly **OUT of MVP scope**:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ EXPLICIT NON-GOALS FOR COMPLY MVP (DEFERRED OR OWNED BY OTHER PRODUCTS)               │
├───────────────────────────────────┬────────────────────────────────────────────────────┤
│ Excluded Capability               │ Where It Belongs / Why It Is Excluded              │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ ❌ Time tracking & clock-in/out   │ Owned by Simployer One / dedicated time systems.   │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ ❌ Vacation calendar & booking    │ Owned by Simployer One. Comply only monitors law.  │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ ❌ Deep payroll gross/net engine  │ Comply reads payroll CSV; does not run calculations│
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ ❌ ATS & recruitment pipelines    │ Comply starts when an agreement is signed.         │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ ❌ Swedish collective agreements  │ Deferred to V2 (MVP is 100% Norwegian AML).        │
└───────────────────────────────────┴────────────────────────────────────────────────────┘
```

---

## 4. MVP Commercial Packaging & Pricing Hypothesis

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ COMPLY COMMERCIAL PACKAGING (HEADCOUNT-BASED PRICING)                                  │
├───────────────────────────────┬───────────────────────────────┬────────────────────────┤
│ TIER 1: COMPLY BASE           │ TIER 2: COMPLY SHIELD (PRO)   │ EXPANSION ADD-ONS      │
│ (Autonomous Autopilot)        │ (+ Human Expert Retainer)     │ (Contextual 1-Click)   │
├───────────────────────────────┼───────────────────────────────┼────────────────────────┤
│ **49 kr / employee / month**  │ **89 kr / employee / month**  │ • Simployer Learn      │
│ (Minimum 490 kr/month)        │ (Minimum 890 kr/month)        │   HMS Course: 1 490 kr │
├───────────────────────────────┼───────────────────────────────┼────────────────────────┤
│ • Ingestion & Living Register │ • Everything in Base          │ • Simployer Equal Pay  │
│ • AML § 14-6 Contract Auditing│ • Direct written jurist chat  │   ARP Report: 490 kr/mo│
│ • Slim Living Handbook        │ • Pre-assembled case reviews  │ • Simployer One Core   │
│ • Dynamic Radar (5, 10, 20 VO)│ • Certified dismissal advice  │   Full HRM: 79 kr/emp  │
│ • macOS, iOS & Slack/Teams    │ • Simployer liability cover   │ • Simployer Omsorg     │
│ • Monthly CEO Digest          │   (*"Vi står inne for rådet"*)|   Sick leave: 29 kr/emp│
└───────────────────────────────┴───────────────────────────────┴────────────────────────┘
```

---

## 5. Technical & Security MVP Requirements

1. **European Data Sovereignty:** All document processing and vector stores reside in Norway / EU.
2. **Zero Public Model Training:** Customer employment contracts and payroll spreadsheets are strictly isolated and never used for LLM fine-tuning.
3. **Audit Trail Immutability:** All approval actions, BankID signatures, and handbook diffs are cryptographically logged with user identity and timestamps.
4. **Resilient Local Sync:** The native macOS app operates cleanly with local Finder folder synchronization (SharePoint / Google Drive desktop sync).
