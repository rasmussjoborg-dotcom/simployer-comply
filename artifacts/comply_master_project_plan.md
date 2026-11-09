# Simployer Comply: Master Project Plan & Sprint Milestones

> **Role of this Document:** The single source of truth, Project Manager (PM), and execution narrator for Simployer Comply.  
> **Deadline:** Friday, 13 November 2026  
> **Rule of Execution:** One task at a time. Build → Review → Iterate → Agree → Proceed.

---

## 1. Executive Scope & Objective

Deliver an executive-ready, interactive prototype of **Simployer Comply** along with supporting legal content, multi-tier datasets, business case documentation, and a self-running presentation demo link for Simployer leadership.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ MASTER SPRINT ROADMAP (7-DAY CADENCE TO FRIDAY DELIVERY)                               │
├─────────┬───────────────────────────────────────┬──────────────────────┬───────────────┤
│ Phase   │ Focus Area                            │ Primary Agent        │ Status        │
├─────────┼───────────────────────────────────────┼──────────────────────┼───────────────┤
│ Phase 0 │ Strategy, Dataset & Agent Roster Setup│ Lead Orchestrator    │ 🟢 DONE       │
│ Phase 1 │ Project Scaffolding & Sol Design Tokens│ `comply-ui-craft`   │ 🟢 DONE       │
│ Phase 2 │ Scenario 1: Small Biz (8 staff, Chaos)│ `comply-ui-craft`    │ 🟢 DONE       │
│ Phase 3 │ Scenario 2 & 3: Scale-Up & Mid-Market │ `comply-legal-engine`│ 🟢 DONE       │
│ Phase 4 │ Headless Omnichannel Dispatcher       │ `comply-ui-craft`    │ 🟢 DONE       │
│ Phase 5 │ Autoplay Presentation & Demo Mode     │ `comply-demo-narrator`│ ⏳ ACTIVE     │
│ Phase 6 │ QA Audit & Executive Deliverables     │ `comply-qa-audit`    │ ⏹️ Queued     │
└─────────┴───────────────────────────────────────┴──────────────────────┴───────────────┘
```

---

## 2. Decision Forks & Strategic Architecture

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ ARCHITECTURAL FORKS & RECOMMENDED DEFAULTS                                             │
├─────────────────────┬────────────────────────────────┬─────────────────────────────────┤
│ Decision Fork       │ Options Considered             │ Chosen Native Architecture      │
├─────────────────────┼────────────────────────────────┼─────────────────────────────────┤
│ **1. Runtime**      │ A. Web browser mockup (Chrome) │ **B. Native macOS App (.app)**  │
│                     │ B. Native macOS & iOS App      │ **+ Native iOS Companion App**  │
│                     │                                │ *Real Apple OS environments.*   │
├─────────────────────┼────────────────────────────────┼─────────────────────────────────┤
│ **2. Tech Stack**   │ A. Electron / Web wrapper      │ **B. Swift 6.2 + SwiftUI**      │
│                     │ B. Swift / SwiftUI (Multiplat) │ *Native window materials, Menu  │
│                     │ C. React Native / Expo         │ Bar, Finder drag-drop, FaceID.* │
├─────────────────────┼────────────────────────────────┼─────────────────────────────────┤
│ **3. Distribution** │ A. Live Screen Studio demo     │ **D. Multi-Channel:**           │
│                     │ B. Local Xcode build only      │ 1. Live native apps in demo     │
│                     │ C. Notarized macOS DMG         │ 2. Signed/notarized macOS DMG   │
│                     │ D. All of the above            │ 3. 4K Screen Studio walkthrough │
└─────────────────────┴────────────────────────────────┴─────────────────────────────────┘
```

---

## 3. Detailed Phase Breakdown & Milestones

### Phase 0: Grounding, Dataset & Agent Roster Setup
- [x] **Milestone 0.1:** Ingest prior workshop findings, CEO prototype briefs, and legal research (`aec2a90a-3cbc-484a-b223-65bd6c93c9a0`).
- [x] **Milestone 0.2:** Extract live Simployer "Sol" design tokens (`#F1EFE9`, `#2D0C69`, `#9773FF`, Fraunces, Hanken Grotesk).
- [x] **Milestone 0.3:** Register specialized subagents (`comply-ui-craft`, `comply-legal-engine`, `comply-demo-narrator`, `comply-qa-audit`) and generate `AGENTS.md`.
- [x] **Milestone 0.4:** Define multi-scenario matrix across the 4-year Fjord Dynamics growth arc (8, 38, 124 staff).

---

### Phase 1: Native Swift & SwiftUI Project Scaffolding (COMPLETED)
* **Goal:** A clean, compilable multiplatform Swift/SwiftUI Xcode project containing a native macOS App target and an iOS Companion App target, styled with Simployer Sol tokens.
* **Assigned Agent:** `comply-ui-craft` · Tier: `[3.8 Flash]` · Skill: `swiftui-animation`, `impeccable`
* **Tasks:**
  - [x] **Milestone 1.1:** Scaffold multiplatform Swift project (`Simployer Comply`) targeting macOS 15+ and iOS 18+.
  - [x] **Milestone 1.2:** Implement `SolTokens.swift` (Color constants `#F1EFE9`, `#2D0C69`, `#9773FF`, custom font loaders for Fraunces & Hanken Grotesk, elevation drop shadows).
  - [x] **Milestone 1.3:** Build native **macOS App Shell**:
    - `MenuBarExtra` status item (`🛡️ Comply · Alt i orden`).
    - Native `NSWindow` / `WindowGroup` with sidebar, Sol paper background, and native traffic lights.
    - Native macOS `onDrop(of: [.fileURL])` handling for Finder drag-and-drop.
  - [x] **Milestone 1.4:** Build native **iOS Companion App Shell**:
    - Runs in iOS Simulator (e.g. iPhone 17 Pro / 16e).
    - Dynamic Island & native `UNUserNotificationCenter` local push banner simulation.
    - Bottom sheet review card with native biometric FaceID (`LocalAuthentication`).
  - [x] **Milestone 1.5:** Implement native **Timeline Growth Scrubber** (`2024: 8 staff` ──> `2025: 38 staff` ──> `2027: 124 staff`) feeding shared in-memory mock data.
* **Verification:** `xcodebuild` succeeds cleanly for both macOS and iOS Simulator destinations; apps launch natively on macOS and in the iOS Simulator.

---

### Phase 2: Chapter 1 — Fjord Dynamics 2024 (8 Staff, "The Seedling") (COMPLETED)
* **Goal:** Real native drag-and-drop of local files from Finder into the macOS app, parsing into the Living Register, AML § 14-6 contract redline diff, and triggering the Verneombud election.
* **Assigned Agent:** `comply-ui-craft` & `comply-legal-engine` · Tier: `[3.8 Flash]`
* **Tasks:**
  - [x] **Milestone 2.1:** Create a sample local folder `Fjord_Dynamics_Filer_2024` on macOS with real sample files (`Personalliste_2024.csv`, contracts, HMS notes).
  - [x] **Milestone 2.2:** Wire native Finder drop target (`.onDrop`) to animate file ingestion into the 8-person Living Register.
  - [x] **Milestone 2.3:** Build the native macOS **Contract Redline Diff Sheet** showing side-by-side legacy text vs. July 2024 AML § 14-6 terms.
  - [x] **Milestone 2.4:** Build the **AML § 6-1 Verneombud Alert** with auto-generated election notice and live ballot voting.
  - [x] **Milestone 2.5:** Connect the **Native iOS Push & Approval Flow**: Phone receives simulated notification, opens review sheet, approves with FaceID.
  - [x] **Milestone 2.6:** Wire the **Simployer Learn Add-On Sheet** (CEO & VO HMS training courses).
* **Verification:** Dragging a folder from Finder into the running Mac app populates the table and dispatches an alert to the running iOS Simulator.

---

### Phase 3: Chapters 2 & 3 — Fjord Dynamics 2025 & 2027 (38 & 124 Staff) (COMPLETED)
* **Goal:** Demonstrate that the native Mac app scales to mid-market companies with Simployer One, stopping dismissal *formfel* and handling whistleblowing.
* **Assigned Agent:** `comply-legal-engine` & `comply-ui-craft` · Tier: `[3.8 Flash]`
* **Tasks:**
  - [x] **Milestone 3.1:** Implement **Chapter 2 (2025 · 38 staff)**: Tripletex connection state, Likestillingsloven § 26 ARP pay gap audit modal, Day 14 sick leave meeting invite for Morten Dahl, Simployer Equal Pay/One upsell.
  - [x] **Milestone 3.2:** Implement **Chapter 3 (2027 · 124 staff)**: HRM One connected state, AML § 2 A-6 Whistleblower Channel, procedural dismissal defense (stopping the 396k *formfel*), and 1-click Simployer Expert jurist handoff.
* **Verification:** Scrubbing the timeline slider smoothly evolves Fjord Dynamics between 2024, 2025, and 2027 with matching datasets and legal triggers.

---

### Phase 4: Headless Omnichannel & State Synchronization (COMPLETED)
* **Goal:** Prove Comply is headless by synchronizing approvals between the native Mac app, the iOS Simulator, and Slack/Teams message previews.
* **Assigned Agent:** `comply-ui-craft` · Tier: `[3.8 Flash]`
* **Tasks:**
  - [x] **Milestone 4.1:** Shared local state store (via `/tmp/simployer_comply_sync.json` and Swift Observable) so actions on the iPhone Simulator immediately update the native Mac window in real-time, and scrubbing the Mac slider updates the iPhone Simulator.
  - [x] **Milestone 4.2:** Native Slack / Teams action card integration preview.

---

### Phase 5: Self-Running Presentation Engine & Video Recording (ACTIVE)
* **Goal:** A seamless presentation experience: both an automated self-running mode in the native apps and a high-end video recording.
* **Assigned Agent:** `comply-demo-narrator` · Tier: `[3.8 Flash]` · Skill: `studio-vibe`
* **Tasks:**
  - [ ] **Milestone 5.1:** Programmatic Autoplay controller inside the native macOS app: plays the 3-minute scripted demo with timed view transitions and highlighted clicks.
  - [ ] **Milestone 5.2:** Subtitle / narration HUD overlay during autoplay.
  - [ ] **Milestone 5.3:** Produce a 4K Screen Studio / video recording of the native Mac app and iOS simulator running side-by-side.

---

### Phase 6: Code Signing, Notarization & Executive Handover
* **Goal:** Distribute a genuine macOS `.dmg` and presentation assets to leadership.
* **Assigned Agent:** `comply-qa-audit` & Lead Orchestrator
* **Tasks:**
  - [ ] **Milestone 6.1:** Deep code signing with hardened runtime using `Developer ID Application: RASMUS PER SEBASTIAN SJÖBORG (D89525F228)`.
  - [ ] **Milestone 6.2:** Submit to Apple Notary Service via `xcrun notarytool` and staple notarization ticket (`xcrun stapler staple`).
  - [ ] **Milestone 6.3:** Assemble executive presentation deck, spoken script, and business viability one-pager.

---

## 4. Immediate Next Step
Upon Rasmus's approval, we will begin **Phase 1: Project Scaffolding & Sol Design Foundation (Milestones 1.1 – 1.5)**.
