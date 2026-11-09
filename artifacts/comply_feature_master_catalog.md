# Simployer Comply: Master Feature Catalog & Functional Specification

> **Purpose:** The definitive feature inventory for Simployer Comply.  
> **Status:** Working Draft (For Rasmus & Per Alignment)  
> **Scoping Matrix:**
> - `[P]` = In-Scope for Friday Prototype (13 Nov 2026)
> - `[V1]` = Minimum Viable Product (Commercial Launch)
> - `[V2]` = Future Vision & Enterprise Tier

---

## 1. Zero-Friction Ingestion & Triage ("Tidy Up")

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **ING-01** | **Local Drag-and-Drop Ingestion** | Users drag messy folders containing PDF contracts, Word files, and Excel payroll into the native macOS app. | `[P]` |
| **ING-02** | **Cloud Drive Connector** | 1-click authorization to crawl Google Drive, Microsoft OneDrive, and SharePoint without moving files. | `[V1]` |
| **ING-03** | **Payroll Export Ingestion** | Parser for standard Norwegian payroll CSV/Excel files (Tripletex, Fiken, Visma, 24SevenOffice) to extract salaries and roles. | `[P]` |
| **ING-04** | **Automated Entity Discovery** | Automatically resolves Org.nr, legal name, registered NACE industry code, and Brønnøysund status to determine legal duties. | `[P]` |
| **ING-05** | **OCR & Clause Segmentation** | Extracts text from scanned PDFs and legacy scanned image agreements, segmenting clauses into structured data. | `[V1]` |

---

## 2. The Living Personnel Register

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **REG-01** | **Auto-Populated Employee Roster** | Structured tabular directory of all discovered employees (name, title, department, wage, FTE %, start date). | `[P]` |
| **REG-02** | **Contract Health Status Badges** | Visual status indicators per employee: `🟢 Lovlig`, `🔴 Avvik AML § 14-6`, `🟡 Prøvetid utgår snart`, `⚠️ Mangler avtale`. | `[P]` |
| **REG-03** | **Missing Metadata Highlighter** | Flags gaps in personnel files: missing social security numbers, unstated trial periods, or absent job descriptions. | `[P]` |
| **REG-04** | **FTE & Working Time Mapping** | Tracks part-time vs. full-time ratios and flags involuntary part-time rights under AML § 14-4 a. | `[V1]` |
| **REG-05** | **One-Click Manual Add/Edit** | Instant modal to add new hires or edit employee parameters before generating contracts. | `[P]` |

---

## 3. Autonomous Contract Audit & Redline Engine

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **CON-01** | **AML § 14-6 Compliance Audit** | Scans agreements against July 1, 2024 mandates (overtime compensation, right to paid competence, trial period limits). | `[P]` |
| **CON-02** | **Side-by-Side Redline Diff Viewer** | High-craft visual comparison showing deprecated legacy text in red vs. compliant statutory language in green. | `[P]` |
| **CON-03** | **1-Click Standard Addendum Generator** | Automatically drafts a formal legal addendum (*Tilleggsavtale til arbeidsavtale*) pre-populated with company & employee data. | `[P]` |
| **CON-04** | **Digital Signing Dispatcher (BankID)** | Dispatches compliant addenda to employees for legally binding digital signature via BankID / Signicat. | `[P]` *(Simulated)* |
| **CON-05** | **Immutable Cryptographic Audit Trail** | Timestamped ledger recording who approved the change, statutory justification, and employee signing confirmation. | `[V1]` |
| **CON-06** | **Batch Contract Normalization** | 1-click batch fix for common systematic errors across the whole company (e.g. updating 14 contracts simultaneously). | `[P]` |

---

## 4. The Slim Living Handbook

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **HNB-01** | **14-Chapter Statutory Baseline Handbook** | Pre-composed compliant handbook based on Norwegian statutory minimums (leave, sickness, core hours, holidays). | `[P]` |
| **HNB-02** | **Company Rule Customizer** | Tailors internal policies (e.g. self-certification days 3 vs. 8, home office subsidies, travel expense rules). | `[P]` |
| **HNB-03** | **Autonomous Regulatory Sync** | When national statutes or decrees change, Comply drafts updated handbook text and prompts admin for 1-click publish. | `[P]` |
| **HNB-04** | **Employee Chatbot Integration (Sia)** | Employees query their company handbook directly in Slack, Teams, or Copilot and receive verified answers with citations. | `[V1]` |
| **HNB-05** | **Inspection-Ready PDF Export** | Generates an official, dated handbook PDF ready to submit during Arbeidstilsynet audits. | `[V1]` |

---

## 5. Two-Way Dynamic Radar (The Compliance Watchdog)

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **RAD-01** | **5-Staff Verneombud Trigger (AML § 6-1)** | Detects when headcount crosses 5 employees and launches automated digital election ballots and voting links. | `[P]` |
| **RAD-02** | **10-Staff CEO HMS Obligation (AML § 3-5)** | Detects lack of mandatory top executive HSE training and provides 1-click enrollment in Simployer Learn course. | `[P]` |
| **RAD-03** | **20-Staff ARP Equal Pay Trigger** | Flags mandatory gender pay gap audit under Likestillingsloven § 26 and auto-generates the salary distribution matrix. | `[P]` |
| **RAD-04** | **30-Staff AMU Committee Trigger (AML § 7-1)** | Alerts when company reaches 30 staff, drafting committee constitution papers and agendas. | `[P]` |
| **RAD-05** | **50-Staff Whistleblower Channel (AML § 2 A-6)** | Provisions encrypted, confidential whistleblowing intake portal required for 50+ staff. | `[P]` |
| **RAD-06** | **Probation Period Expiry Monitor** | Alerts managers 30 days before 6-month trial periods expire, generating the statutory assessment dialogue notice. | `[P]` |
| **RAD-07** | **Sick-Leave Day 14 Follow-up (AML § 4-6)** | Tracks statutory sickness timeline, generating the Day 14 dialogmøte invitation and statutory follow-up plan. | `[P]` |
| **RAD-08** | **Contractor Misclassification Detector** | Analyzes long-running independent contractor invoices against AML § 1-8 employee tests to prevent retroactive tax shock. | `[V2]` |

---

## 6. Headless Omnichannel Execution ("No Front Door")

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **OMN-01** | **macOS Native Desktop Shell** | Frameless Sol paper window, Menu Bar status pill, Finder drag-and-drop, and full-screen redline diffing canvas. | `[P]` |
| **OMN-02** | **iOS Companion App** | Thumb-driven mobile app for on-the-go push notifications, 20-second summary diffs, and FaceID/BankID approvals. | `[P]` |
| **OMN-03** | **Slack Interactive Action Cards** | Formatted Slack message cards with embedded `[Approve]`, `[View Diff]`, and `[Ask Attorney]` action buttons. | `[P]` *(Simulation)* |
| **OMN-04** | **Microsoft Teams Adaptive Cards** | Native Teams approval cards for managers, synchronized in real-time with the central engine. | `[P]` *(Simulation)* |
| **OMN-05** | **1-Click Transactional Approval Email** | Secure magic-link emails allowing busy CEOs to sign off on urgent compliance tasks with a single tap. | `[V1]` |

---

## 7. Simployer Premium: The Human Bridge (Expert On-Demand)

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **EXP-01** | **1-Click Attorney Handoff** | Directly connects user to a named Simployer labor attorney (e.g. Ragnhild Hansen) for high-stakes or ambiguous issues. | `[P]` |
| **EXP-02** | **Automated Case Dossier Assembly** | Pre-assembles relevant contracts, handbook policies, employee timeline, and notes into an audit file for the lawyer. | `[P]` |
| **EXP-03** | **Certified Written Opinion & Liability Shield** | Delivers written legal counsel backed by Simployer professional indemnity (*"JEG MÅ KUNNE STÅ INNE FOR SVARET"*). | `[P]` *(Scripted)* |
| **EXP-04** | **Procedural Dismissal Flow (AML § 15-1)** | Step-by-step guidance through performance warnings and drøftelsesmøter to prevent the 396k median loss in court. | `[P]` |

---

## 8. Reporting & Inspection-Readiness

| Feature Code | Feature Name | Description & Legal Rationale | Scope |
| :--- | :--- | :--- | :--- |
| **REP-01** | **Monthly CEO Peace-of-Mind Report** | A concise 1-page executive brief: what's in order, what was updated, open risks, and value protected. | `[P]` |
| **REP-02** | **Arbeidstilsynet 1-Click Tilsynspakke** | Bundled ZIP/PDF containing all statutory documentation (VO election protocol, contracts, HMS certificates) for inspectors. | `[V1]` |
| **REP-03** | **Immutable Compliance Timeline** | Historical chronological log of every legislative update, contract addendum, and approval event. | `[P]` |

---

## 9. Simployer Ecosystem Expansion (The Add-On Engine)

| Feature Code | Feature Name | Description & Commercial Impact | Scope |
| :--- | :--- | :--- | :--- |
| **UPS-01** | **Simployer Learn 1-Click Enrollment** | Instant purchase of mandatory CEO HMS course (AML § 3-5) and 40h Verneombud training. | `[P]` |
| **UPS-02** | **Simployer Equal Pay 1-Click Unlock** | Unlocks deep gender pay gap reporting when headcount approaches 20 staff, pulling from already-ingested data. | `[P]` |
| **UPS-03** | **Simployer One (Core HRM) Upgrade** | 1-click migration to full HRM suite (absence calendar, 1:1 reviews, leave approvals) with zero data entry. | `[P]` |
| **UPS-04** | **Simployer Omsorg Manager Coaching** | Unlocks guided line-manager workflows for sick leave and NAV rehabilitation plans. | `[P]` |
| **UPS-05** | **Simployer Surveys Unlock** | Activates annual psychosocial and work environment surveys to meet SAM/HMS requirements. | `[V1]` |

---

## 10. Presentation & Demo Controls

| Feature Code | Feature Name | Description & Utility | Scope |
| :--- | :--- | :--- | :--- |
| **DEM-01** | **Timeline Growth Slider** | Interactive scrubber (`2024: 8 staff` ──> `2025: 38 staff` ──> `2027: 124 staff`) showing company evolution. | `[P]` |
| **DEM-02** | **Self-Running Autoplay Mode** | 1-click presentation button that autonomously drives the walkthrough with camera choreography and narration cards. | `[P]` |
| **DEM-03** | **Channel Viewport Switcher** | 1-click toggle between macOS Desktop window, iOS Companion frame, and Slack/Teams cards. | `[P]` |
