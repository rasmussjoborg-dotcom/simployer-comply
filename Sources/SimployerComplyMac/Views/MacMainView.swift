import SwiftUI
import UniformTypeIdentifiers

struct CompletedActionArchiveItem: Identifiable {
    let id: String
    let statute: String
    let title: String
    let resolutionNote: String
}

struct MacMainView: View {
    @EnvironmentObject var store: ComplyStore
    @StateObject private var autoplay = AutoplayController.shared
    @State private var isDropTargeted = false
    @State private var showDemoControls = false
    @State private var showSearchPalette = false
    @State private var vanishedCardIds: Set<String> = []
    @State private var showCompletedArchive = false
    @State private var expandedHubCard: String? = nil
    @State private var selectedDiffEmployee: Employee? = nil
    @State private var expandedEmployeeRowId: String? = nil
    @State private var employeeSearchText: String = ""
    @State private var employeeStatusFilter: String = "all"
    @AppStorage("comply_sidebar_width") private var sidebarWidth: Double = 220.0
    
    // MARK: - Compliance Horizon State (Linear-style Urgency & Temporal Grouping)
    enum ComplianceHorizonFilter: String, CaseIterable {
        case all = "alla"
        case akut = "akut"
        case snart = "snart"
        case planerat = "planerat"
    }
    @State private var selectedHorizonFilter: ComplianceHorizonFilter = .all
    @State private var expandedSecondaryCard: String? = nil
    @State private var showContinuousGuardrailsDetails: Bool = false
    
    // MARK: - Live Ingestion Analysis State
    @State private var isAnalyzingDrop: Bool = false
    @State private var dropProgress: Double = 0.0
    @State private var dropAnalysisStage: Int = 0
    @State private var dropFileName: String = "Anställningsavtal_2024_Standard.docx"
    
    var body: some View {
        ZStack(alignment: .leading) {
            SolTokens.canvasRoot.ignoresSafeArea()
            
            // MARK: - Main Content Split (Linear Sidebar + Framed Canvas)
            HStack(spacing: 0) {
                // Left Sidebar (resizable)
                VStack(alignment: .leading, spacing: 3.5) {
                    // Linear Company Header (Dynamic Badge + Radar Dot + Search + Compose)
                    companyHeaderView
                        
                    // Section 1: Skydd & Oversikt (Primary Executive Focus)
                    HStack(spacing: 4) {
                        Text(store.language == .se ? "SKYDD & ÖVERSIKT" : "PROTECTION & OVERVIEW")
                            .font(.inter(10, .bold))
                            .tracking(0.7)
                            .foregroundColor(SolTokens.ink600)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 6))
                            .foregroundColor(SolTokens.ink450)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 16)
                    .padding(.bottom, 3)
                    
                    SidebarButton(
                        id: "hub",
                        label: store.l10n.navHub,
                        icon: "shield.checkered",
                        badge: store.pendingActionCount > 0 ? "\(store.pendingActionCount)" : nil,
                        badgeStyle: .alert,
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "hub"
                    }
                    
                    SidebarButton(
                        id: "agentLog",
                        label: store.l10n.navAgentLog,
                        icon: "clock.arrow.circlepath",
                        badge: "Live",
                        badgeStyle: .dot,
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "agentLog"
                    }
                    
                    // Section 2: Fordjupning & Register (Quiet Reference)
                    HStack(spacing: 4) {
                        Text(store.language == .se ? "FÖRDJUPNING & REGISTER" : "RECORDS & EXPLORATION")
                            .font(.inter(10, .bold))
                            .tracking(0.7)
                            .foregroundColor(SolTokens.ink600)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 6))
                            .foregroundColor(SolTokens.ink450)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 18)
                    .padding(.bottom, 3)
                        
                    SidebarButton(
                        id: "ingest",
                        label: store.l10n.navIngest,
                        icon: "tray",
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "ingest"
                    }
                    SidebarButton(
                        id: "register",
                        label: store.l10n.navRegister,
                        icon: "person.2",
                        badge: "\(store.currentScenario.headcount)",
                        badgeStyle: .neutral,
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "register"
                    }
                    SidebarButton(
                        id: "handbook",
                        label: store.l10n.navHandbook,
                        icon: "book.closed",
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "handbook"
                    }
                    SidebarButton(
                        id: "radar",
                        label: store.l10n.navRadar,
                        icon: "dot.radiowaves.left.and.right",
                        badgeStyle: .dot,
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "radar"
                    }
                    SidebarButton(
                        id: "expert",
                        label: store.l10n.navExpert,
                        icon: "bubble.left.and.bubble.right",
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "expert"
                    }
                    SidebarButton(
                        id: "auditPack",
                        label: store.l10n.navAuditPack,
                        icon: "shield.lefthalf.filled",
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "auditPack"
                    }
                    SidebarButton(
                        id: "settings",
                        label: store.l10n.navSettings,
                        icon: "gearshape",
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "settings"
                    }
                        
                        Spacer()
                        
                        // MARK: - Bottom Section: Utilities (Language + Demo) & Mobile Diffs
                        sidebarBottomSection
                    }
                    .frame(width: CGFloat(sidebarWidth))
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(10)
                    .background(SolTokens.canvasRoot)
                    
                    // Resizable Divider Handle (Linear / macOS Native style)
                    SidebarResizeHandle(
                        sidebarWidth: $sidebarWidth,
                        minWidth: 170,
                        maxWidth: 380,
                        defaultWidth: 220
                    )
                    .layoutPriority(9)
                    
                    // MARK: - Linear Framed Main Content Canvas (Panel with rounded corners and border that sticks out)
                    VStack(spacing: 0) {
                        // Canvas Header Bar (Breadcrumb + Actions)
                        HStack(alignment: .center) {
                            HStack(spacing: 7) {
                                Image(systemName: currentNavIcon)
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.lav400)
                                Text("Fjord Dynamics")
                                    .font(.inter(12.5, .medium))
                                    .foregroundColor(SolTokens.ink600)
                                Text("›")
                                    .font(.inter(12, .regular))
                                    .foregroundColor(SolTokens.ink450)
                                Text(currentNavTitle)
                                    .font(.inter(12.5, .semibold))
                                    .foregroundColor(SolTokens.ink900)
                                
                                if store.activeNav == "hub" && store.pendingActionCount > 0 {
                                    Text(store.l10n.headerIssuesCount(count: store.pendingActionCount))
                                        .font(.inter(10.5, .semibold))
                                        .padding(.horizontal, 5.5)
                                        .padding(.vertical, 1.5)
                                        .background(SolTokens.paper200)
                                        .foregroundColor(SolTokens.ink600)
                                        .cornerRadius(4)
                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(SolTokens.paper50)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(SolTokens.paper300),
                            alignment: .bottom
                        )
                        
                        // Framed View Content
                        ZStack {
                            SolTokens.paper50.ignoresSafeArea()
                            
                            if store.activeNav == "hub" {
                                macActionHubView
                            } else if store.activeNav == "agentLog" {
                                AgentLogView()
                            } else if store.activeNav == "ingest" {
                                macIngestDropView
                            } else if store.activeNav == "register" {
                                macRegisterTableView
                            } else if store.activeNav == "handbook" {
                                macHandbookView
                            } else if store.activeNav == "radar" {
                                macRadarView
                            } else if store.activeNav == "expert" {
                                macExpertView
                            } else if store.activeNav == "auditPack" {
                                InspectionExportView()
                            } else if store.activeNav == "settings" {
                                macSettingsView
                            }
                        }
                    }
                    .background(SolTokens.paper50)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(SolTokens.paper300, lineWidth: 1)
                    )
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
            }
        }
        .overlay {
            if showSearchPalette {
                CommandPaletteModal(
                    store: store,
                    isPresented: $showSearchPalette,
                    onSelectNav: { nav in
                        store.activeNav = nav
                    },
                    onSelectCard: { card in
                        store.activeNav = "hub"
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            expandedHubCard = card
                        }
                    },
                    onSelectYear: { year in
                        store.setYear(year)
                    }
                )
                .transition(.opacity)
            }
        }
        .overlay {
            if autoplay.isPlaying, let step = autoplay.currentStep {
                AutoplayHUDOverlay(
                    step: step,
                    stepIndex: autoplay.currentStepIndex,
                    totalSteps: autoplay.totalSteps,
                    stopLabel: store.l10n.autoplayStop
                ) {
                    autoplay.stopDemo { _ in
                        withAnimation {
                            self.expandedHubCard = nil
                        }
                    }
                }
            }
        }
        .overlay {
            if store.showAuditReportSheet {
                AuditReportModalView(store: store)
                    .transition(.opacity)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if let _ = store.auditReportSavedToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(SolTokens.green800)
                    Text(store.l10n.auditSavedToast)
                        .font(.inter(12, .semibold))
                        .foregroundColor(SolTokens.ink900)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(SolTokens.paper100)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.18), radius: 12, y: 4)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.greenBorder, lineWidth: 1))
                .padding(24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            store.auditReportSavedToast = nil
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if let toast = store.slackTestToast {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(SolTokens.plum900)
                    Text(toast)
                        .font(.inter(12, .semibold))
                        .foregroundColor(SolTokens.ink900)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(SolTokens.paper100)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.18), radius: 12, y: 4)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.lav400, lineWidth: 1))
                .padding(24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: autoplay.currentStepIndex) { _ in
            if let step = autoplay.currentStep {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                    self.expandedHubCard = step.expandedCard
                    if step.expandedCard == "contracts" && (selectedDiffEmployee == nil || selectedDiffEmployee?.status != .aml14Gap) {
                        selectedDiffEmployee = store.currentScenario.employees.first(where: { $0.status == .aml14Gap })
                    }
                }
            }
        }
        .onChange(of: store.currentYear) { _ in
            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                self.expandedHubCard = nil
                self.expandedEmployeeRowId = nil
                self.vanishedCardIds.removeAll()
                self.showCompletedArchive = false
            }
        }
        .onChange(of: store.verneombudElectionActive) { active in
            if active && !vanishedCardIds.contains("verneombud") {
                scheduleCardVanish(id: "verneombud", delay: 1.3)
            }
        }
        .onChange(of: store.hmsTrainingEnrolled) { enrolled in
            if enrolled && !vanishedCardIds.contains("hms") {
                scheduleCardVanish(id: "hms", delay: 1.3)
            }
        }
        .onChange(of: store.equalPayReportGenerated) { done in
            if done && !vanishedCardIds.contains("equalPay") {
                scheduleCardVanish(id: "equalPay", delay: 1.3)
            }
        }
        .onChange(of: store.sickLeavePlanDispatched) { done in
            if done && !vanishedCardIds.contains("sickLeave") {
                scheduleCardVanish(id: "sickLeave", delay: 1.3)
            }
        }
        .onChange(of: store.probationConfirmed) { done in
            if done && !vanishedCardIds.contains("probation") {
                scheduleCardVanish(id: "probation", delay: 1.3)
            }
        }
        .onChange(of: store.juristHandoffCompleted) { done in
            if done && !vanishedCardIds.contains("defense") {
                scheduleCardVanish(id: "defense", delay: 1.3)
            }
        }
        .onChange(of: store.pendingActionCount) { count in
            checkAndScheduleContractVanish()
            if count == 0 {
                scheduleBatchVanishForCurrentYear()
            }
        }
        .onAppear {
            checkExistingResolvedCardsOnAppear()
        }
    }
    
    // MARK: - Company Header (Linear-Style: Dynamic Badge + Radar Dot + Search + Compose)
    private var companyHeaderView: some View {
        HStack(spacing: 7) {
            // Dynamic Compliance Badge with Active Radar Dot
            companyComplianceBadge
            
            HStack(spacing: 4) {
                Text("Fjord Dynamics")
                    .font(.inter(13, .semibold))
                    .foregroundColor(SolTokens.ink900)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 6.5))
                    .foregroundColor(SolTokens.ink450)
            }
            
            Spacer()
            
            // Linear-Style Search Button (clean hover icon)
            Button {
                showSearchPalette.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.inter(12, .medium))
                    .foregroundColor(SolTokens.ink600)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut("k", modifiers: .command)
            .help("Søk eller hopp til... (⌘K)")
            
            // Linear-Style Compose / Quick Action Button
            Button {
                showSearchPalette.toggle()
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.inter(11, .medium))
                    .foregroundColor(SolTokens.ink600)
                    .frame(width: 22, height: 22)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help("Hurtighandling eller opprettelse")
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }
    
    // MARK: - Company Compliance Badge with Active Radar Indicator
    private var companyComplianceBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(companyBadgeBackground)
                .frame(width: 22, height: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(companyBadgeBorder, lineWidth: 1)
                )
            
            SimployerLogoView()
                .frame(width: 13, height: 13)
        }
        .overlay(alignment: .topTrailing) {
            // Active Radar small green dot sitting upon the badge
            ZStack {
                Circle()
                    .fill(SolTokens.green800)
                    .frame(width: 7, height: 7)
                Circle()
                    .stroke(SolTokens.canvasRoot, lineWidth: 1.5)
                    .frame(width: 9, height: 9)
            }
            .offset(x: 2.5, y: -2.5)
        }
        .help("\(store.l10n.activeRadar): \(store.l10n.radarAutomatedWatchNotice)")
    }
    
    private var companyBadgeBackground: Color {
        switch store.complianceSeverity {
        case .compliant:
            return Color(hex: 0x142B1F)
        case .warning:
            return Color(hex: 0x2E2211)
        case .behind:
            return Color(hex: 0x36181B)
        }
    }
    
    private var companyBadgeBorder: Color {
        switch store.complianceSeverity {
        case .compliant:
            return Color(hex: 0x224933)
        case .warning:
            return Color(hex: 0x4E3A1D)
        case .behind:
            return Color(hex: 0x5C262E)
        }
    }
    
    private var companyBadgeIconColor: Color {
        switch store.complianceSeverity {
        case .compliant:
            return SolTokens.green800
        case .warning:
            return SolTokens.amber400
        case .behind:
            return SolTokens.red700
        }
    }
    
    private var companyBadgeIcon: String {
        switch store.complianceSeverity {
        case .compliant:
            return "checkmark.shield.fill"
        case .warning:
            return "shield.checkered"
        case .behind:
            return "exclamationmark.shield.fill"
        }
    }
    
    // MARK: - Sidebar Bottom Section (Language + Demo + Mobile Diffs)
    private var sidebarBottomSection: some View {
        VStack(spacing: 8) {
            // Language & Demo Controls Row
            HStack(spacing: 6) {
                // Language Switcher Dropdown
                LanguageSwitcherView(currentLanguage: $store.language) { lang in
                    store.setLanguage(lang)
                }
                
                Spacer()
                
                // Demo Popover Button
                Button {
                    showDemoControls.toggle()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "slider.horizontal.2.square")
                            .font(.inter(11))
                        Text(store.l10n.demoPillLabel)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(showDemoControls ? SolTokens.lav100 : SolTokens.paper200)
                    .foregroundColor(showDemoControls ? SolTokens.lav400 : SolTokens.ink600)
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(showDemoControls ? SolTokens.lav600.opacity(0.4) : SolTokens.paper300, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .keyboardShortcut("d", modifiers: .command)
                .popover(isPresented: $showDemoControls, arrowEdge: .trailing) {
                    DemoControlsPopover(
                        store: store,
                        autoplay: autoplay,
                        isPresented: $showDemoControls,
                        onExpandCard: { card in
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                self.expandedHubCard = card
                            }
                        },
                        onReset: {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                self.vanishedCardIds.removeAll()
                                self.showCompletedArchive = false
                                self.expandedHubCard = nil
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
            
            // Linear Mobile Diffs Card Style
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "iphone.gen3")
                        .font(.inter(12))
                        .foregroundColor(SolTokens.lav400)
                    Text("Mobile Diffs")
                        .font(.inter(11, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Spacer()
                    Circle()
                        .fill(SolTokens.green800)
                        .frame(width: 5, height: 5)
                }
                Text("iOS Companion Synk · FaceID & BankID")
                    .font(.inter(10))
                    .foregroundColor(SolTokens.ink600)
                    .lineLimit(2)
            }
            .padding(10)
            .background(SolTokens.paper200)
            .cornerRadius(8)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(SolTokens.paper300, lineWidth: 1)
            )
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
    
    // MARK: - Navigation Title & Icon Helpers
    private var currentNavTitle: String {
        switch store.activeNav {
        case "hub": return store.l10n.navHub
        case "agentLog": return store.l10n.navAgentLog
        case "ingest": return store.l10n.navIngest
        case "register": return store.l10n.navRegister
        case "handbook": return store.l10n.navHandbook
        case "radar": return store.l10n.navRadar
        case "expert": return store.l10n.navExpert
        case "auditPack": return store.l10n.navAuditPack
        case "settings": return store.l10n.navSettings
        default: return store.l10n.navRegister
        }
    }
    
    private var currentNavIcon: String {
        switch store.activeNav {
        case "hub": return "shield.checkered"
        case "agentLog": return "clock.arrow.circlepath"
        case "ingest": return "tray"
        case "register": return "person.2"
        case "handbook": return "book.closed"
        case "radar": return "dot.radiowaves.left.and.right"
        case "expert": return "bubble.left.and.bubble.right"
        case "auditPack": return "shield.lefthalf.filled"
        case "settings": return "gearshape"
        default: return "shield.checkered"
        }
    }
    
    // MARK: - Card Resolution & Vanish Logic
    
    private func isCardResolved(_ id: String) -> Bool {
        switch id {
        case "contracts":
            return store.currentScenario.employees.allSatisfy { $0.status != .aml14Gap }
        case "verneombud":
            return store.verneombudElectionActive
        case "hms":
            return store.hmsTrainingEnrolled
        case "equalPay":
            return store.equalPayReportGenerated
        case "sickLeave":
            return store.sickLeavePlanDispatched
        case "probation":
            return store.probationConfirmed
        case "defense":
            return store.juristHandoffCompleted
        default:
            return false
        }
    }
    
    private func shouldShowInActiveList(_ id: String) -> Bool {
        !vanishedCardIds.contains(id)
    }
    
    private func scheduleCardVanish(id: String, delay: Double = 1.3) {
        // If the card was expanded, fold it shut first after a brief feedback moment
        if expandedHubCard == id {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                    if self.expandedHubCard == id {
                        self.expandedHubCard = nil
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                _ = self.vanishedCardIds.insert(id)
            }
        }
    }
    
    private func scheduleBatchVanishForCurrentYear() {
        if expandedHubCard != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                    self.expandedHubCard = nil
                }
            }
        }
        
        let cards = cardIdsForCurrentYear
        var delay = 1.0
        for card in cards {
            if isCardResolved(card) && !vanishedCardIds.contains(card) {
                let cardDelay = delay
                DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                        _ = self.vanishedCardIds.insert(card)
                    }
                }
                delay += 0.25
            }
        }
    }
    
    private func checkAndScheduleContractVanish() {
        let hasUnapproved = store.currentScenario.employees.contains { $0.status == .aml14Gap }
        if !hasUnapproved && !vanishedCardIds.contains("contracts") {
            scheduleCardVanish(id: "contracts", delay: 1.3)
        }
    }
    
    private func checkExistingResolvedCardsOnAppear() {
        for id in cardIdsForCurrentYear {
            if isCardResolved(id) {
                vanishedCardIds.insert(id)
            }
        }
    }
    
    private var cardIdsForCurrentYear: [String] {
        switch store.currentYear {
        case .y2024:
            return ["contracts", "verneombud", "hms"]
        case .y2025:
            return ["equalPay", "sickLeave", "probation"]
        case .y2027:
            return ["defense"]
        }
    }
    
    // MARK: - Temporal Horizon Counts (Akut / Snart / Planerat)
    private var akutCount: Int {
        switch store.currentYear {
        case .y2024:
            return shouldShowInActiveList("contracts") && !isCardResolved("contracts") ? 1 : 0
        case .y2025:
            return shouldShowInActiveList("sickLeave") && !isCardResolved("sickLeave") ? 1 : 0
        case .y2027:
            return shouldShowInActiveList("defense") && !isCardResolved("defense") ? 1 : 0
        }
    }
    
    private var snartCount: Int {
        switch store.currentYear {
        case .y2024:
            return shouldShowInActiveList("verneombud") && !isCardResolved("verneombud") ? 1 : 0
        case .y2025:
            return shouldShowInActiveList("equalPay") && !isCardResolved("equalPay") ? 1 : 0
        case .y2027:
            return 0
        }
    }
    
    private var planeratCount: Int {
        switch store.currentYear {
        case .y2024:
            return shouldShowInActiveList("hms") && !isCardResolved("hms") ? 1 : 0
        case .y2025:
            return shouldShowInActiveList("probation") && !isCardResolved("probation") ? 1 : 0
        case .y2027:
            return 0
        }
    }

    private var completedCountForCurrentYear: Int {
        cardIdsForCurrentYear.filter { isCardResolved($0) }.count
    }
    
    private var completedArchiveTitle: String {
        switch store.language {
        case .se:
            return completedCountForCurrentYear == 1 ? "slutförd åtgärd" : "slutförda åtgärder"
        case .no:
            return completedCountForCurrentYear == 1 ? "fullført handling" : "fullførte handlinger"
        case .en:
            return completedCountForCurrentYear == 1 ? "completed action" : "completed actions"
        }
    }
    
    private var completedCardsForCurrentYear: [CompletedActionArchiveItem] {
        var items: [CompletedActionArchiveItem] = []
        switch store.currentYear {
        case .y2024:
            if store.currentScenario.employees.allSatisfy({ $0.status != .aml14Gap }) {
                items.append(CompletedActionArchiveItem(
                    id: "contracts",
                    statute: store.l10n.hubCardContractsStatute,
                    title: store.l10n.hubCardContractsTitle,
                    resolutionNote: store.l10n.hubCardContractsResolved
                ))
            }
            if store.verneombudElectionActive {
                items.append(CompletedActionArchiveItem(
                    id: "verneombud",
                    statute: store.l10n.hubCardVoStatute,
                    title: store.l10n.hubCardVoTitle,
                    resolutionNote: "\(store.l10n.hubCardVoResolved) (\(store.electionVotesCast)/8 stemmer)"
                ))
            }
            if store.hmsTrainingEnrolled {
                items.append(CompletedActionArchiveItem(
                    id: "hms",
                    statute: store.l10n.hubCardHmsStatute,
                    title: store.l10n.hubCardHmsTitle,
                    resolutionNote: store.l10n.hubCardHmsResolved
                ))
            }
        case .y2025:
            if store.equalPayReportGenerated {
                items.append(CompletedActionArchiveItem(
                    id: "equalPay",
                    statute: store.l10n.hubCardEqualPayStatute,
                    title: store.l10n.hubCardEqualPayTitle,
                    resolutionNote: store.l10n.hubCardEqualPayResolved
                ))
            }
            if store.sickLeavePlanDispatched {
                items.append(CompletedActionArchiveItem(
                    id: "sickLeave",
                    statute: store.l10n.hubCardSickStatute,
                    title: store.l10n.hubCardSickTitle,
                    resolutionNote: store.l10n.hubCardSickResolved
                ))
            }
            if store.probationConfirmed {
                items.append(CompletedActionArchiveItem(
                    id: "probation",
                    statute: store.l10n.hubCardProbationStatute,
                    title: store.l10n.hubCardProbationTitle,
                    resolutionNote: store.l10n.hubCardProbationResolved
                ))
            }
        case .y2027:
            if store.juristHandoffCompleted {
                items.append(CompletedActionArchiveItem(
                    id: "defense",
                    statute: store.l10n.hubCardDefenseStatute,
                    title: store.l10n.hubCardDefenseTitle,
                    resolutionNote: store.l10n.hubCardDefenseResolved
                ))
            }
        }
        return items
    }
    
    // MARK: - Completed Archive Drawer
    private var completedArchiveSection: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    showCompletedArchive.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SolTokens.green800)
                        .font(.inter(13))
                    
                    Text("\(completedCountForCurrentYear) \(completedArchiveTitle)")
                        .font(.inter(12, .semibold))
                        .foregroundColor(SolTokens.ink700)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(store.l10n.hubOpenDetails)
                            .font(.inter(11, .medium))
                        Image(systemName: "chevron.down")
                            .font(.inter(8, .semibold))
                            .rotationEffect(.degrees(showCompletedArchive ? 180 : 0))
                    }
                    .foregroundColor(SolTokens.ink600)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(SolTokens.paper100.opacity(0.8))
                .contentShape(Rectangle())
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(SolTokens.paper300, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            if showCompletedArchive {
                VStack(spacing: 8) {
                    ForEach(completedCardsForCurrentYear) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(SolTokens.green800)
                                .font(.inter(14))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(item.statute)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(SolTokens.paper200)
                                        .foregroundColor(SolTokens.ink700)
                                        .cornerRadius(4)
                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                                    
                                    Text(item.title)
                                        .font(.inter(12.5, .semibold))
                                        .foregroundColor(SolTokens.ink900)
                                }
                                Text(item.resolutionNote)
                                    .font(.inter(11))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            LinearStatusPill(
                                text: store.l10n.hubCompletedBadge,
                                dotColor: SolTokens.green800
                            )
                        }
                        .padding(12)
                        .background(SolTokens.paper100)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(SolTokens.paper300, lineWidth: 1)
                        )
                    }
                }
                .transition(.linearAccordion)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Action Hub View
    // MARK: - Action Hub Cockpit View
    private var macActionHubView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Executive Cockpit Hero Status Bar
                complianceStatusBar
                    .opacity(expandedHubCard != nil ? 0.35 : 1.0)
                    .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
                
                // Linear Horizon Filter Bar & Temporal Overview
                horizonFilterBar
                    .opacity(expandedHubCard != nil ? 0.35 : 1.0)
                    .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
                
                // Horizon 1: 🔴 AKUT — KRÄVER ÅTGÄRD IDAG (Gör bolaget icke-compliant)
                if (selectedHorizonFilter == .all || selectedHorizonFilter == .akut) && akutCount > 0 {
                    horizonAkutSection
                        .opacity(expandedHubCard != nil ? 0.35 : 1.0)
                        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
                }
                
                // Horizon 2: 🟡 SNART — INNAN DET ÄR FÖR SENT (Lagstadgad tidsfrist)
                if (selectedHorizonFilter == .all || selectedHorizonFilter == .snart) && snartCount > 0 {
                    horizonSnartSection
                        .opacity(expandedHubCard != nil ? 0.35 : 1.0)
                        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
                }
                
                // Horizon 3: ⚪️ PLANERAT & HORISONT — BOLAGSRESAN (Kompetens & Trösklar)
                if (selectedHorizonFilter == .all || selectedHorizonFilter == .planerat) && planeratCount > 0 {
                    horizonPlaneratSection
                        .opacity(expandedHubCard != nil ? 0.35 : 1.0)
                        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
                }
                
                // Horizon Specific Resolution Banners (when filtered to a clean horizon)
                if selectedHorizonFilter == .akut && akutCount == 0 {
                    horizonResolvedBanner(
                        title: store.language == .se ? "Inga akuta lagavvikelser" : "No critical violations",
                        subtitle: store.language == .se ? "Alla anställningsavtal och akuta lagkrav är säkrade. Bolaget riskerar inga sanktionsavgifter." : "All employment contracts and immediate statutory requirements are secured.",
                        icon: "checkmark.shield.fill",
                        color: SolTokens.green800
                    )
                } else if selectedHorizonFilter == .snart && snartCount == 0 {
                    horizonResolvedBanner(
                        title: store.language == .se ? "Inga öppna tidsfrister" : "No pending deadlines",
                        subtitle: store.language == .se ? "Inga pågående valprocesser eller förfallande tidsfönster kräver tillsynsåtgärd." : "No active election procedures or expiring statutory windows require action.",
                        icon: "checkmark.circle.fill",
                        color: SolTokens.green800
                    )
                } else if selectedHorizonFilter == .planerat && planeratCount == 0 {
                    horizonResolvedBanner(
                        title: store.language == .se ? "Alla planerade krav säkrade" : "All planned milestones secured",
                        subtitle: store.language == .se ? "Obligatoriska kompetenskrav för företagsledningen är bokade eller uppfyllda." : "Mandated executive competence requirements are booked or satisfied.",
                        icon: "graduationcap.fill",
                        color: SolTokens.green800
                    )
                }
                
                // All Compliant Overall Reassurance Card (when 0 pending total)
                if store.pendingActionCount == 0 && selectedHorizonFilter == .all {
                    allCompliantBanner
                }
                
                // Completed Archive Section (placed directly below active actions, before guardrails)
                if completedCountForCurrentYear > 0 {
                    completedArchiveSection
                        .opacity(expandedHubCard != nil ? 0.35 : 1.0)
                        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
                }
                
                // Tier 2: Continuous Guardrails (SÄKRAT & BEVAKAS I BAKGRUNDEN)
                hubContinuousGuardrailsSection
                    .opacity(expandedHubCard != nil ? 0.35 : 1.0)
                    .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
            }
            .padding(20)
        }
    }
    
    // MARK: - Temporal Horizon Filter Bar
    private var horizonFilterBar: some View {
        HStack(spacing: 8) {
            horizonFilterButton(
                filter: .all,
                title: store.language == .se ? "Alla horisonter" : "All horizons",
                count: store.pendingActionCount,
                color: SolTokens.ink700
            )
            
            if akutCount > 0 {
                horizonFilterButton(
                    filter: .akut,
                    title: store.language == .se ? "Akut (Idag)" : "Critical (Now)",
                    count: akutCount,
                    color: SolTokens.red700
                )
            }
            
            if snartCount > 0 {
                horizonFilterButton(
                    filter: .snart,
                    title: store.language == .se ? "Snart (Inom 30 dgr)" : "Soon (30 days)",
                    count: snartCount,
                    color: SolTokens.amber400
                )
            }
            
            if planeratCount > 0 {
                horizonFilterButton(
                    filter: .planerat,
                    title: store.language == .se ? "Planerat (Horisont)" : "Planned (Horizon)",
                    count: planeratCount,
                    color: SolTokens.lav400
                )
            }
            
            Spacer()
            
            // Reassuring summary pill
            HStack(spacing: 5) {
                Circle()
                    .fill(store.pendingActionCount == 0 ? SolTokens.green800 : SolTokens.red700)
                    .frame(width: 5, height: 5)
                Text(store.pendingActionCount == 0 
                     ? (store.language == .se ? "Full efterlevnad" : "Fully compliant") 
                     : (store.language == .se ? "\(store.pendingActionCount) kräver beslut" : "\(store.pendingActionCount) require decision"))
                    .font(.inter(11, .medium))
                    .foregroundColor(SolTokens.ink600)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 4.5)
            .background(SolTokens.paper100)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
        }
        .padding(.top, 2)
    }

    private func horizonFilterButton(
        filter: ComplianceHorizonFilter,
        title: String,
        count: Int,
        color: Color
    ) -> some View {
        let isSelected = selectedHorizonFilter == filter
        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                selectedHorizonFilter = filter
            }
        } label: {
            HStack(spacing: 6) {
                if filter != .all {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                }
                
                Text(title)
                    .font(.inter(11.5, isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? SolTokens.ink900 : SolTokens.ink600)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5.5)
                        .padding(.vertical, 1.5)
                        .background(isSelected ? color.opacity(0.18) : SolTokens.paper250)
                        .foregroundColor(isSelected ? (filter == .all ? SolTokens.ink900 : color) : SolTokens.ink600)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isSelected ? color.opacity(0.4) : SolTokens.paper300, lineWidth: 1))
                }
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(isSelected ? SolTokens.paper200 : SolTokens.paper100)
            .cornerRadius(7)
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(isSelected ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Horizon 1: Akut Section (HERO FOCUS — Expanded by default)
    @ViewBuilder
    private var horizonAkutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(SolTokens.red700)
                    .frame(width: 7, height: 7)
                
                Text(store.language == .se ? "AKUT — KRÄVER DITT GODKÄNNANDE" : "CRITICAL — REQUIRES APPROVAL")
                    .font(.inter(11, .bold))
                    .tracking(0.8)
                    .foregroundColor(SolTokens.ink900)
                
                Text("\(akutCount) " + (store.language == .se ? (akutCount == 1 ? "olaglig avvikelse" : "olagliga avvikelser") : "violation"))
                    .font(.inter(10.5, .semibold))
                    .foregroundColor(SolTokens.red700)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(SolTokens.red100)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(SolTokens.redBorder, lineWidth: 1))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .font(.system(size: 9.5))
                    Text(store.language == .se ? "Aktiv sanktionsrisk" : "Active penalty exposure")
                        .font(.inter(10.5, .medium))
                }
                .foregroundColor(SolTokens.red700)
            }
            
            switch store.currentYear {
            case .y2024:
                hubCardContracts
            case .y2025:
                hubCardSickLeave
            case .y2027:
                hubCardDefense
            }
        }
    }

    // MARK: - Horizon 2: Snart Section (Collapsed by Default in All View)
    @ViewBuilder
    private var horizonSnartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(SolTokens.amber400)
                    .frame(width: 7, height: 7)
                
                Text(store.language == .se ? "SNART — KOMMANDE DEADLINES" : "SOON — UPCOMING DEADLINES")
                    .font(.inter(11, .bold))
                    .tracking(0.8)
                    .foregroundColor(SolTokens.ink900)
                
                Text(store.language == .se ? "Deadline om 18 dgr" : "Deadline in 18 days")
                    .font(.inter(10.5, .semibold))
                    .foregroundColor(SolTokens.amber400)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(SolTokens.amber100)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(SolTokens.amberBorder, lineWidth: 1))
                
                Spacer()
            }
            
            if selectedHorizonFilter == .snart || expandedSecondaryCard == "verneombud" || expandedSecondaryCard == "equalPay" {
                switch store.currentYear {
                case .y2024:
                    hubCardVerneombud
                case .y2025:
                    hubCardEqualPay
                case .y2027:
                    EmptyView()
                }
            } else {
                switch store.currentYear {
                case .y2024:
                    compactRowVerneombud
                case .y2025:
                    compactRowEqualPay
                case .y2027:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Horizon 3: Planerat Section (Collapsed by Default in All View)
    @ViewBuilder
    private var horizonPlaneratSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(SolTokens.lav500)
                    .frame(width: 7, height: 7)
                
                Text(store.language == .se ? "PLANERAT — BOLAGSRESAN" : "PLANNED — GROWTH MILESTONES")
                    .font(.inter(11, .bold))
                    .tracking(0.8)
                    .foregroundColor(SolTokens.ink900)
                
                Text(store.language == .se ? "Kommande kvartal" : "Upcoming quarter")
                    .font(.inter(10.5, .semibold))
                    .foregroundColor(SolTokens.lav400)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(SolTokens.lav100)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(SolTokens.lavBorder, lineWidth: 1))
                
                Spacer()
            }
            
            if selectedHorizonFilter == .planerat || expandedSecondaryCard == "hms" || expandedSecondaryCard == "probation" {
                switch store.currentYear {
                case .y2024:
                    hubCardHMS
                case .y2025:
                    hubCardProbation
                case .y2027:
                    EmptyView()
                }
            } else {
                switch store.currentYear {
                case .y2024:
                    compactRowHMS
                case .y2025:
                    compactRowProbation
                case .y2027:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Compact Linear Horizon Rows (Restrained Secondary Items)
    private var compactRowVerneombud: some View {
        let voActive = store.verneombudElectionActive
        return HStack(spacing: 12) {
            Circle()
                .fill(voActive ? SolTokens.green800 : SolTokens.amber400)
                .frame(width: 7, height: 7)
            
            Text(store.l10n.hubCardVoStatute)
                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(SolTokens.paper200)
                .foregroundColor(SolTokens.ink700)
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
            
            Text(store.l10n.hubCardVoTitle)
                .font(.inter(13, .semibold))
                .foregroundColor(SolTokens.ink900)
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 9))
                Text(store.language == .se ? "Deadline 18 dgr" : "Deadline 18 days")
                    .font(.inter(11, .medium))
            }
            .foregroundColor(SolTokens.amber400)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(SolTokens.amber100)
            .cornerRadius(4)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.amberBorder, lineWidth: 1))
            
            Spacer()
            
            if !voActive {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        expandedSecondaryCard = "verneombud"
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(store.language == .se ? "Öppna val" : "Open election")
                            .font(.inter(11.5, .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .semibold))
                    }
                    .foregroundColor(SolTokens.ink700)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SolTokens.green800)
                    Text(store.l10n.hubCardVoResolved)
                        .font(.inter(11.5, .medium))
                        .foregroundColor(SolTokens.green800)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(voActive ? SolTokens.green800 : SolTokens.amber400)
                .frame(width: 3)
                .padding(.vertical, 6)
                .padding(.leading, 1)
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }

    private var compactRowHMS: some View {
        let hmsDone = store.hmsTrainingEnrolled
        return HStack(spacing: 12) {
            Circle()
                .fill(hmsDone ? SolTokens.green800 : SolTokens.lav500)
                .frame(width: 7, height: 7)
            
            Text(store.l10n.hubCardHmsStatute)
                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(SolTokens.paper200)
                .foregroundColor(SolTokens.ink700)
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
            
            Text(store.l10n.hubCardHmsTitle)
                .font(.inter(13, .semibold))
                .foregroundColor(SolTokens.ink900)
            
            Text(store.language == .se ? "Kommande kvartal" : "Upcoming quarter")
                .font(.inter(11, .medium))
                .foregroundColor(SolTokens.lav400)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(SolTokens.lav100)
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.lavBorder, lineWidth: 1))
            
            Spacer()
            
            Text(store.l10n.hubHmsPrice)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(SolTokens.ink600)
            
            if !hmsDone {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        expandedSecondaryCard = "hms"
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(store.language == .se ? "Visa kurs" : "View course")
                            .font(.inter(11.5, .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .semibold))
                    }
                    .foregroundColor(SolTokens.ink700)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SolTokens.green800)
                    Text(store.l10n.hubHmsBookedConfirmation)
                        .font(.inter(11.5, .medium))
                        .foregroundColor(SolTokens.green800)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(hmsDone ? SolTokens.green800 : SolTokens.lav500)
                .frame(width: 3)
                .padding(.vertical, 6)
                .padding(.leading, 1)
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }

    private var compactRowEqualPay: some View {
        let epDone = store.equalPayReportGenerated
        return HStack(spacing: 12) {
            Circle()
                .fill(epDone ? SolTokens.green800 : SolTokens.amber400)
                .frame(width: 7, height: 7)
            Text(store.l10n.hubCardEqualPayStatute)
                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(SolTokens.paper200)
                .foregroundColor(SolTokens.ink700)
                .cornerRadius(4)
            Text(store.l10n.hubCardEqualPayTitle)
                .font(.inter(13, .semibold))
                .foregroundColor(SolTokens.ink900)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    expandedSecondaryCard = "equalPay"
                }
            } label: {
                HStack(spacing: 4) {
                    Text(store.l10n.hubOpenDetails)
                        .font(.inter(11.5, .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                }
                .foregroundColor(SolTokens.ink700)
                .padding(.horizontal, 9)
                .padding(.vertical, 4.5)
                .background(SolTokens.paper200)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }

    private var compactRowProbation: some View {
        let probDone = store.probationConfirmed
        return HStack(spacing: 12) {
            Circle()
                .fill(probDone ? SolTokens.green800 : SolTokens.lav500)
                .frame(width: 7, height: 7)
            Text(store.l10n.hubCardProbationStatute)
                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(SolTokens.paper200)
                .foregroundColor(SolTokens.ink700)
                .cornerRadius(4)
            Text(store.l10n.hubCardProbationTitle)
                .font(.inter(13, .semibold))
                .foregroundColor(SolTokens.ink900)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    expandedSecondaryCard = "probation"
                }
            } label: {
                HStack(spacing: 4) {
                    Text(store.l10n.hubOpenDetails)
                        .font(.inter(11.5, .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                }
                .foregroundColor(SolTokens.ink700)
                .padding(.horizontal, 9)
                .padding(.vertical, 4.5)
                .background(SolTokens.paper200)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }

    // MARK: - Reassurance Banner for Filtered Horizon
    private func horizonResolvedBanner(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.inter(12.5, .bold))
                    .foregroundColor(SolTokens.ink900)
                Text(subtitle)
                    .font(.inter(11.5))
                    .foregroundColor(SolTokens.ink600)
            }
            Spacer()
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(9)
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(SolTokens.paper300, lineWidth: 1))
    }

    // MARK: - All Compliant Hero Banner
    private var allCompliantBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundColor(SolTokens.green800)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(store.language == .se ? "Alla lagkrav säkrade och i full efterlevnad" : "All statutory requirements secured")
                    .font(.inter(13.5, .bold))
                    .foregroundColor(SolTokens.ink900)
                Text(store.language == .se ? "Inga öppna avvikelser, sanktionsrisker eller förfallande tidsfrister." : "Zero open violations, financial penalties, or overdue statutory deadlines.")
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink600)
            }
            Spacer()
        }
        .padding(16)
        .background(SolTokens.green100)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.greenBorder, lineWidth: 1))
    }
    
    // MARK: - Permanent Executive Compliance Cockpit Status Bar
    private var complianceStatusBar: some View {
        let isCompliant = store.pendingActionCount == 0
        let totalCount = 10
        let pending = store.pendingActionCount
        let secured = max(0, totalCount - pending)
        let percent = Int(Double(secured) / Double(totalCount) * 100.0)
        
        return VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Segmented Status Ring (Per's lo-fi status ring / Apple Arc)
                ZStack {
                    Circle()
                        .stroke(SolTokens.paper300, lineWidth: 3.5)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(secured) / CGFloat(totalCount))
                        .stroke(
                            isCompliant ? SolTokens.green800 : SolTokens.indigo,
                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 44, height: 44)
                    
                    if isCompliant {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(SolTokens.green800)
                    } else {
                        VStack(spacing: -1) {
                            Text("\(secured)")
                                .font(.inter(12.5, .bold))
                                .foregroundColor(SolTokens.ink900)
                            Text("/\(totalCount)")
                                .font(.inter(8.5, .medium))
                                .foregroundColor(SolTokens.ink450)
                        }
                    }
                }
                .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(isCompliant ? store.l10n.hubAllCompliantTitle : store.l10n.hubExecutiveStatusTitle(securedCount: secured, totalCount: totalCount, percent: percent))
                            .font(.inter(14.5, .bold))
                            .foregroundColor(SolTokens.ink900)
                        
                        // Legal Definitions Heartbeat Stamp
                        HStack(spacing: 4) {
                            Circle()
                                .fill(isCompliant ? SolTokens.green800 : SolTokens.indigo)
                                .frame(width: 5, height: 5)
                            Text("Simployer Legal Cloud v2026.11 · Idag 06:00")
                                .font(.inter(10, .medium))
                                .foregroundColor(SolTokens.ink700)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(SolTokens.paper200)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    
                    Text(store.l10n.hubExecutiveStatusSubtitle(pendingCount: pending))
                        .font(.inter(12, .regular))
                        .foregroundColor(SolTokens.ink600)
                }
                
                Spacer()
                
                // Revisionspaket Button (REP-02)
                Button {
                    store.activeNav = "auditPack"
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 11))
                        Text(store.language == .se ? "Revisionspaket (PDF)" : "Inspection Pack")
                            .font(.inter(11.5, .medium))
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(SolTokens.paper300, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            
            if isCompliant {
                Button {
                    store.activeNav = "register"
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11))
                        Text(store.l10n.hubCompletedBadge)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                    }
                    .font(.inter(12, .semibold))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background(SolTokens.paper100)
                    .foregroundColor(SolTokens.green800)
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(SolTokens.greenBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        store.resolveAllActionHubItems()
                    }
                    scheduleBatchVanishForCurrentYear()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "signature")
                            .font(.system(size: 12, weight: .semibold))
                        Text(store.l10n.hubMacroResolveButton)
                            .font(.inter(12.5, .semibold))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8.5)
                    .background(SolTokens.linearIndigo)
                    .foregroundColor(Color.white)
                    .cornerRadius(7)
                    
                }
                .buttonStyle(.plain)
            }
        }
        
        // Bolagsresan Contextual Headcount Micro-Rail (RAD-01 .. RAD-05)
        HStack(spacing: 8) {
            Image(systemName: "figure.walk.arrival")
                .font(.system(size: 11))
                .foregroundColor(SolTokens.indigo)
            
            Text(store.language == .se ?
                 "Bolagsresan: Fjord Dynamics har 8 anställda · 2 kvar till tröskel 10 (Obligatorisk VD KMA/HMS-kurs, AML § 3-5)" :
                 "Growth Journey: Fjord Dynamics has 8 staff · 2 remaining to threshold 10 (Mandatory CEO HSE Training, AML § 3-5)")
                .font(.inter(11.5))
                .foregroundColor(SolTokens.ink600)
            
            Spacer()
            
            Button {
                store.activeNav = "radar"
            } label: {
                Text(store.language == .se ? "Se trösklar (5/10/20/30/50) →" : "View thresholds (5/10/20/30/50) →")
                    .font(.inter(11, .medium))
                    .foregroundColor(SolTokens.indigo)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(SolTokens.paper200.opacity(0.6))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 0.75))
    }
    .padding(16)
    .background(SolTokens.paper100)
    .cornerRadius(10)
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(isCompliant ? SolTokens.greenBorder : SolTokens.paper300, lineWidth: 1)
    )
}
    
    // MARK: - Continuous Guardrails Section (Restrained Collapsible Drawer)
    private var hubContinuousGuardrailsSection: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    showContinuousGuardrailsDetails.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(SolTokens.green800)
                        .font(.system(size: 13))
                    
                    Text(store.language == .se ? "4 aktiva skydd bevakas autonomt i bakgrunden" : "4 active guardrails monitored autonomously")
                        .font(.inter(12, .semibold))
                        .foregroundColor(SolTokens.ink700)
                    
                    Text("·  Arbetstid, jämställdhet, visselblåsning, semester")
                        .font(.inter(11.5))
                        .foregroundColor(SolTokens.ink450)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(showContinuousGuardrailsDetails ? store.l10n.close : store.l10n.hubOpenDetails)
                            .font(.inter(11, .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .semibold))
                            .rotationEffect(.degrees(showContinuousGuardrailsDetails ? 180 : 0))
                    }
                    .foregroundColor(SolTokens.ink600)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(SolTokens.paper100)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(SolTokens.paper300, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            if showContinuousGuardrailsDetails {
                VStack(spacing: 8) {
                    hubGuardrailRow(
                        title: store.l10n.hubGuardrail1Title,
                        statute: store.l10n.hubGuardrail1Statute,
                        desc: store.l10n.hubGuardrail1Desc,
                        statusText: store.l10n.hubGuardrail1Status
                    )
                    
                    hubGuardrailRow(
                        title: store.l10n.hubGuardrail2Title,
                        statute: store.l10n.hubGuardrail2Statute,
                        desc: store.l10n.hubGuardrail2Desc,
                        statusText: store.l10n.hubGuardrail2Status
                    )
                    
                    hubGuardrailRow(
                        title: store.l10n.hubGuardrail3Title,
                        statute: store.l10n.hubGuardrail3Statute,
                        desc: store.l10n.hubGuardrail3Desc,
                        statusText: store.l10n.hubGuardrail3Status
                    )
                    
                    hubGuardrailRow(
                        title: store.l10n.hubGuardrail4Title,
                        statute: store.l10n.hubGuardrail4Statute,
                        desc: store.l10n.hubGuardrail4Desc,
                        statusText: store.l10n.hubGuardrail4Status
                    )
                }
                .transition(.linearAccordion)
            }
        }
    }
    
    private func hubGuardrailRow(title: String, statute: String, desc: String, statusText: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(SolTokens.green800)
                .font(.system(size: 15))
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.inter(13.5, .semibold))
                        .foregroundColor(SolTokens.ink900)
                    
                    Text(statute)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink600)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                Text(desc)
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink600)
            }
            
            Spacer()
            
            LinearStatusPill(
                text: statusText,
                dotColor: SolTokens.green800
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SolTokens.paper300, lineWidth: 1)
        )
    }
    
    // MARK: - Linear Handbook View
    private var macHandbookView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.l10n.navHandbook)
                        .font(.inter(16, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text(store.l10n.handbookAiUpdateNotice)
                        .font(.inter(12))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.bottom, 4)
                
                HandbookChapterCard(
                    chapterNumber: "1",
                    title: store.l10n.handbookCh1Title,
                    statute: store.l10n.handbookCh1Statute,
                    statusText: store.l10n.handbookCh1Status,
                    statusColor: SolTokens.green800,
                    statusBg: SolTokens.green800.opacity(0.14),
                    summary: store.l10n.handbookCh1Summary
                )
                
                HandbookChapterCard(
                    chapterNumber: "2",
                    title: store.l10n.handbookCh2Title,
                    statute: store.l10n.handbookCh2Statute,
                    statusText: store.l10n.handbookCh2Status,
                    statusColor: SolTokens.lav400,
                    statusBg: SolTokens.lav400.opacity(0.14),
                    summary: store.l10n.handbookCh2Summary
                )
                
                HandbookChapterCard(
                    chapterNumber: "3",
                    title: store.l10n.handbookCh3Title,
                    statute: store.l10n.handbookCh3Statute,
                    statusText: store.l10n.handbookCh3Status,
                    statusColor: SolTokens.green800,
                    statusBg: SolTokens.green800.opacity(0.14),
                    summary: store.l10n.handbookCh3Summary
                )
                
                HandbookChapterCard(
                    chapterNumber: "4",
                    title: store.l10n.handbookCh4Title,
                    statute: store.l10n.handbookCh4Statute,
                    statusText: store.l10n.handbookCh4Status,
                    statusColor: SolTokens.green800,
                    statusBg: SolTokens.green800.opacity(0.14),
                    summary: store.l10n.handbookCh4Summary
                )
                
                // Chapter 5: Workplace AI Policy (Nov 8 Joint Agreement)
                VStack(alignment: .leading, spacing: 10) {
                    HandbookChapterCard(
                        chapterNumber: "5",
                        title: store.l10n.aiHandbookChapterTitle,
                        statute: "AML § 4-1 · EU AI Act Art. 4",
                        statusText: store.l10n.handbookCh5Status,
                        statusColor: SolTokens.lav400,
                        statusBg: SolTokens.lav400.opacity(0.14),
                        summary: store.l10n.aiHandbookSummary
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.l10n.handbookApprovedAiToolsHeader)
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                        
                        HStack(spacing: 8) {
                            AIToolChip(name: "ChatGPT Team", vendor: "OpenAI", status: store.l10n.aiChipTextStatus)
                            AIToolChip(name: "Claude Enterprise", vendor: "Anthropic", status: store.l10n.aiChipDataStatus)
                            AIToolChip(name: "GitHub Copilot", vendor: "Microsoft", status: store.l10n.aiChipCodeStatus)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
                .background(SolTokens.paper100)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
            }
            .padding(20)
        }
    }
    
    // MARK: - Linear Radar View
    private var macRadarView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.l10n.navRadar)
                        .font(.inter(16, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text(store.l10n.radarAutomatedWatchNotice)
                        .font(.inter(12))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.bottom, 4)
                
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(SolTokens.lav400.opacity(0.14))
                            .frame(width: 44, height: 44)
                        Image(systemName: "speedometer")
                            .font(.inter(22))
                            .foregroundColor(SolTokens.lav400)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.l10n.radarHeadcountNotice(count: store.currentScenario.headcount))
                            .font(.inter(14, .bold))
                            .foregroundColor(SolTokens.ink900)
                        Text(store.l10n.radarNextThresholdNotice(remainingCount: max(0, 10 - store.currentScenario.headcount)))
                            .font(.inter(12))
                            .foregroundColor(SolTokens.ink600)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(SolTokens.green800)
                            .frame(width: 6, height: 6)
                        Text(store.l10n.radarActiveStatus)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4.5)
                    .background(SolTokens.green800.opacity(0.12))
                    .cornerRadius(5)
                }
                .padding(16)
                .background(SolTokens.paper100)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                
                // MARK: - Bolagsresan Growth Timeline
                bolagsresanTimelineView
                
                RadarThresholdCard(
                    threshold: store.l10n.radarCard5Threshold,
                    statute: "AML § 6-1",
                    title: store.l10n.radarCard5Title,
                    statusText: store.l10n.radarCard5Status,
                    statusColor: SolTokens.green800,
                    statusBg: SolTokens.green800.opacity(0.14),
                    description: store.l10n.radarCard5Desc
                )
                
                RadarThresholdCard(
                    threshold: store.l10n.radarCard10Threshold,
                    statute: "AML § 7-1",
                    title: store.l10n.radarCard10Title,
                    statusText: store.l10n.radarCard10Status(remaining: max(0, 10 - store.currentScenario.headcount)),
                    statusColor: SolTokens.amber400,
                    statusBg: SolTokens.amber400.opacity(0.14),
                    description: store.l10n.radarCard10Desc
                )
                
                RadarThresholdCard(
                    threshold: store.l10n.radarCard50Threshold,
                    statute: "AML § 8-1 & Likestillingsloven § 26",
                    title: store.l10n.radarCard50Title,
                    statusText: store.l10n.radarCard50Status,
                    statusColor: SolTokens.ink600,
                    statusBg: SolTokens.paper300,
                    description: store.l10n.radarCard50Desc
                )
            }
            .padding(20)
        }
    }
    
    // MARK: - Linear Expert & Sia Calculation View
    private var macExpertView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.l10n.navExpert)
                            .font(.inter(16, .bold))
                            .foregroundColor(SolTokens.ink900)
                        Text(store.l10n.expertSiaSubtitle)
                            .font(.inter(12))
                            .foregroundColor(SolTokens.ink600)
                    }
                    Spacer()
                    // Retainer Status
                    HStack(spacing: 6) {
                        Circle()
                            .fill(SolTokens.green800)
                            .frame(width: 6, height: 6)
                        Text(store.l10n.expertRetainerBadge)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4.5)
                    .background(SolTokens.green800.opacity(0.12))
                    .cornerRadius(5)
                }
                .padding(.bottom, 2)
                
                // Sia Calculation Engine Card (Scoring row 46, top WTP)
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        HStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(SolTokens.lav400.opacity(0.16))
                                    .frame(width: 28, height: 28)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                                    .foregroundColor(SolTokens.lav400)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(store.l10n.expertSiaTitle)
                                    .font(.inter(13.5, .bold))
                                    .foregroundColor(SolTokens.ink900)
                                Text(store.l10n.expertPrecisionNotice)
                                    .font(.inter(11))
                                    .foregroundColor(SolTokens.ink600)
                            }
                        }
                        Spacer()
                        // Mode Selector Pills
                        HStack(spacing: 4) {
                            SiaTabButton(title: store.l10n.feriepengerTab, isSelected: store.selectedCalculationTab == "feriepenger") {
                                store.selectedCalculationTab = "feriepenger"
                            }
                            SiaTabButton(title: store.l10n.sykefravaerTab, isSelected: store.selectedCalculationTab == "sykefravaer") {
                                store.selectedCalculationTab = "sykefravaer"
                            }
                            SiaTabButton(title: store.l10n.egenmeldingTab, isSelected: store.selectedCalculationTab == "egenmelding") {
                                store.selectedCalculationTab = "egenmelding"
                            }
                        }
                    }
                    
                    Divider().overlay(SolTokens.paper300)
                    
                    // Tab Content
                    if store.selectedCalculationTab == "feriepenger" {
                        // Feriepenger Calculator (Ferieloven § 10)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(store.l10n.expertAnnualSalaryCalcHeader)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(SolTokens.ink450)
                                    HStack(spacing: 6) {
                                        Text("\(Int(store.annualSalaryInput).formatted()) \(store.l10n.currencyUnit)")
                                            .font(.inter(16, .bold))
                                            .foregroundColor(SolTokens.ink900)
                                        
                                        HStack(spacing: 4) {
                                            Button("- 50k") {
                                                store.annualSalaryInput = max(400000, store.annualSalaryInput - 50000)
                                            }
                                            .buttonStyle(.plain)
                                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(SolTokens.paper300)
                                            .foregroundColor(SolTokens.ink600)
                                            .cornerRadius(4)
                                            
                                            Button("+ 50k") {
                                                store.annualSalaryInput += 50000
                                            }
                                            .buttonStyle(.plain)
                                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(SolTokens.paper300)
                                            .foregroundColor(SolTokens.ink600)
                                            .cornerRadius(4)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // 5th Week Holiday Toggle
                                Button {
                                    store.fiveWeeksHoliday.toggle()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: store.fiveWeeksHoliday ? "checkmark.square.fill" : "square")
                                            .foregroundColor(store.fiveWeeksHoliday ? SolTokens.lav400 : SolTokens.ink450)
                                        Text(store.l10n.expertFifthWeekToggle)
                                            .font(.inter(12, .medium))
                                            .foregroundColor(SolTokens.ink900)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(SolTokens.paper250)
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Calculation Result Box
                            let rate = store.fiveWeeksHoliday ? 0.12 : 0.102
                            let feriepengerAmount = Int(store.annualSalaryInput * rate)
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(store.l10n.expertCalcResultHeader)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(SolTokens.ink450)
                                    Text("\(feriepengerAmount.formatted()) \(store.l10n.currencyUnit)")
                                        .font(.inter(20, .bold))
                                        .foregroundColor(SolTokens.green800)
                                }
                                
                                Divider().frame(height: 36).overlay(SolTokens.paper300)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(store.l10n.expertCalcRateHeader)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(SolTokens.ink450)
                                    Text(store.fiveWeeksHoliday ? store.l10n.expertCalcRateExtended : store.l10n.expertCalcRateStandard)
                                        .font(.inter(12.5, .semibold))
                                        .foregroundColor(SolTokens.ink900)
                                }
                                
                                Spacer()
                                
                                Text("Ferieloven § 10 nr. 1")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(SolTokens.ink450)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(SolTokens.paper250)
                                    .cornerRadius(4)
                            }
                            .padding(12)
                            .background(SolTokens.paper250)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                        }
                    } else if store.selectedCalculationTab == "sykefravaer" {
                        // Sykefravær 4-ukers Oppfølgingsplan (Folketrygdloven § 8-7)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(store.l10n.expertSickTimelineHeader)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(SolTokens.ink450)
                                    Text(store.l10n.expertSickTimelineStatute)
                                        .font(.inter(12, .semibold))
                                        .foregroundColor(SolTokens.ink900)
                                }
                                Spacer()
                                Text(store.l10n.expertSickTimelineActiveCase)
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(SolTokens.amber400)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(SolTokens.amber400.opacity(0.12))
                                    .cornerRadius(4)
                            }
                            
                            HStack(spacing: 12) {
                                TimelineMilestoneCard(
                                    milestone: store.l10n.expertSickMilestone1Time,
                                    title: store.l10n.expertSickMilestone1Title,
                                    desc: store.l10n.expertSickMilestone1Desc,
                                    isUpcoming: true,
                                    daysRemaining: store.l10n.expertSickMilestone1Remaining
                                )
                                TimelineMilestoneCard(
                                    milestone: store.l10n.expertSickMilestone2Time,
                                    title: store.l10n.expertSickMilestone2Title,
                                    desc: store.l10n.expertSickMilestone2Desc,
                                    isUpcoming: false,
                                    daysRemaining: store.l10n.expertSickMilestone2Remaining
                                )
                            }
                        }
                    } else {
                        // Egenmeldingsdager & Karantene (Folketrygdloven § 8-24)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(store.l10n.expertSelfCertRulesHeader)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(SolTokens.ink450)
                                    Text(store.l10n.expertSelfCertStatute)
                                        .font(.inter(12, .semibold))
                                        .foregroundColor(SolTokens.ink900)
                                }
                                Spacer()
                                Text(store.l10n.expertSelfCertAllApprovedBadge)
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(SolTokens.green800)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(SolTokens.green800.opacity(0.12))
                                    .cornerRadius(4)
                            }
                            
                            Text(store.l10n.expertSelfCertRulesBody)
                                .font(.inter(12))
                                .foregroundColor(SolTokens.ink700)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(16)
                .background(SolTokens.paper100)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                
                // Spør Jurist Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.l10n.expertLegalCounselHeader)
                                .font(.inter(13.5, .bold))
                                .foregroundColor(SolTokens.ink900)
                            Text(store.l10n.expertLegalCounselDesc)
                                .font(.inter(11.5))
                                .foregroundColor(SolTokens.ink600)
                        }
                        Spacer()
                        Button {
                            withAnimation {
                                store.juristInquirySent = true
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "paperplane.fill")
                                Text(store.juristInquirySent ? store.l10n.expertInquirySent : store.l10n.askJuristButton)
                            }
                            .font(.inter(12, .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6.5)
                            .background(store.juristInquirySent ? SolTokens.green800.opacity(0.14) : SolTokens.lav400.opacity(0.16))
                            .foregroundColor(store.juristInquirySent ? SolTokens.green800 : SolTokens.lav400)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(store.juristInquirySent ? SolTokens.green800.opacity(0.4) : SolTokens.lav400.opacity(0.4), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Historical cases log
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.l10n.expertPastCaseTitle)
                                .font(.inter(12.5, .semibold))
                                .foregroundColor(SolTokens.ink900)
                            Text(store.l10n.expertPastCaseDesc)
                                .font(.inter(11.5))
                                .foregroundColor(SolTokens.ink600)
                        }
                        Spacer()
                        Text(store.l10n.expertPastCaseClosed)
                            .font(.inter(10.5, .semibold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(SolTokens.green800.opacity(0.12))
                            .foregroundColor(SolTokens.green800)
                            .cornerRadius(4)
                    }
                    .padding(12)
                    .background(SolTokens.paper100)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .padding(16)
                .background(SolTokens.paper100)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
            }
            .padding(20)
        }
    }
    
    // MARK: - Bolagsresan Growth Timeline
    private var bolagsresanTimelineView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(store.l10n.timelineTrackHeader)
                        .font(.inter(14.5, .bold))
                        .foregroundColor(SolTokens.ink900)
                    
                    Text("5 TILLVÄXTSTEG")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink600)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                }
                Text(store.l10n.timelineTrackSubheader)
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink600)
            }
            
            // 5 Milestone Buttons Horizontal Rail
            HStack(spacing: 8) {
                timelineMilestoneTab(tier: 1, range: "1–4", label: "Grundtrygghet", isCurrent: false)
                timelineMilestoneTab(tier: 2, range: "5–9", label: "Fjord Dynamics (8)", isCurrent: true)
                timelineMilestoneTab(tier: 3, range: "10–29", label: "Krav på SAM", isCurrent: false)
                timelineMilestoneTab(tier: 4, range: "30–49", label: "AMU & Lön", isCurrent: false)
                timelineMilestoneTab(tier: 5, range: "50+", label: "Facklig samverkan", isCurrent: false)
            }
            
            // Detailed breakdown for the selected tier
            timelineTierDetailCard(tier: store.selectedTimelineTier)
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    private func timelineMilestoneTab(tier: Int, range: String, label: String, isCurrent: Bool) -> some View {
        let isSelected = store.selectedTimelineTier == tier
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                store.selectedTimelineTier = tier
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Text("STEG \(tier)")
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundColor(isSelected ? SolTokens.ink900 : (isCurrent ? SolTokens.green800 : SolTokens.ink450))
                    
                    if isCurrent {
                        Circle()
                            .fill(SolTokens.green800)
                            .frame(width: 5, height: 5)
                    }
                    Spacer()
                }
                
                Text(range + " anställda")
                    .font(.inter(12, .bold))
                    .foregroundColor(isSelected ? SolTokens.ink900 : SolTokens.ink700)
                
                Text(label)
                    .font(.inter(10.5, .medium))
                    .foregroundColor(isCurrent ? SolTokens.green800 : SolTokens.ink450)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? SolTokens.paper250 : SolTokens.paper200)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? SolTokens.linearIndigo : (isCurrent ? SolTokens.greenBorder : SolTokens.paper300), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func timelineTierDetailCard(tier: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tier Top Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(tierTitle(tier))
                            .font(.inter(14, .bold))
                            .foregroundColor(SolTokens.ink900)
                        
                        if tier == 2 {
                            HStack(spacing: 4) {
                                Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                                Text("Aktiv fas · Fjord Dynamics (8 anställda)")
                                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                    .foregroundColor(SolTokens.green800)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(SolTokens.paper200)
                            .cornerRadius(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                        } else if tier == 1 {
                            Text("Passerad milstolpe")
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2.5)
                                .background(SolTokens.paper250)
                                .foregroundColor(SolTokens.ink600)
                                .cornerRadius(4)
                        } else {
                            Text("Kommande tillväxtfas")
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2.5)
                                .background(SolTokens.paper200)
                                .foregroundColor(SolTokens.ink600)
                                .cornerRadius(4)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                        }
                    }
                    
                    Text(tierSubtitle(tier))
                        .font(.inter(12))
                        .foregroundColor(SolTokens.ink600)
                }
                Spacer()
            }
            .padding(.bottom, 2)
            
            // Grid of 3 Columns: Statutory Law, Risk/Sanctions, Simployer Solution
            HStack(alignment: .top, spacing: 14) {
                // Column 1: Lagstadgade Skyldigheter
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 8.5))
                            .foregroundColor(SolTokens.ink450)
                        Text("LAGSTADGADE SKYLDIGHETER")
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                    }
                    
                    Text(tierStatutes(tier))
                        .font(.inter(12))
                        .foregroundColor(SolTokens.ink700)
                        .lineSpacing(3)
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(SolTokens.paper200)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                
                // Column 2: Empirisk Risk & Påföljd
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 8.5))
                            .foregroundColor(SolTokens.ink450)
                        Text("RISK & SANKTIONER")
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                    }
                    
                    Text(tierRisk(tier))
                        .font(.inter(12))
                        .foregroundColor(SolTokens.ink700)
                        .lineSpacing(3)
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(SolTokens.paper200)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                
                // Column 3: Simployer-lösning (Upsell)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 8.5))
                            .foregroundColor(SolTokens.ink450)
                        Text("SIMPLOYER-LÖSNING")
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                    }
                    
                    Text(tierProductTitle(tier))
                        .font(.inter(13, .bold))
                        .foregroundColor(SolTokens.ink900)
                    
                    Text(tierProductDesc(tier))
                        .font(.inter(11.5))
                        .foregroundColor(SolTokens.ink600)
                        .lineSpacing(2)
                    
                    Spacer()
                    
                    tierProductActionButton(tier: tier)
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(SolTokens.paper200)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.lav400.opacity(0.3), lineWidth: 1))
            }
        }
        .padding(14)
        .background(SolTokens.paper250)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    private func tierTitle(_ tier: Int) -> String {
        switch tier {
        case 1: return "Steg 1: Grundtrygghet (1–4 anställda)"
        case 2: return "Steg 2: Skyddsombud & Ledarskap (5–9 anställda)"
        case 3: return "Steg 3: Strukturerat SAM & Rutiner (10–29 anställda)"
        case 4: return "Steg 4: Arbetsmiljökommitté & Lönekartläggning (30–49 anställda)"
        default: return "Steg 5: Full MBL & Koncernsamverkan (50+ anställda)"
        }
    }
    
    private func tierSubtitle(_ tier: Int) -> String {
        switch tier {
        case 1: return "Etablering av lagstadgade anställningsvillkor och grundläggande försäkringsskydd."
        case 2: return "Fokus på formellt medinflytande, skyddsombud och obligatorisk VD-kompetens."
        case 3: return "Krav på skriftlig dokumentation, riskbedömningar och visselblåsarrutiner."
        case 4: return "Formaliserad samverkanskommitté (AMU) samt årlig lagstadgad lönekartläggning."
        default: return "Omfattande facklig förhandlingsskyldighet, formella uppsägningsprocesser och CSRD."
        }
    }
    
    private func tierStatutes(_ tier: Int) -> String {
        switch tier {
        case 1: return "• AML § 14-6 / LAS 6 c §: Skriftliga avtal inom 7 dagar.\n• Grundläggande arbetsmiljöansvar.\n• Obligatorisk tjänstepension & arbetsskadeförsäkring."
        case 2: return "• AML § 6-1: Obligatoriskt skyddsombud från 5 anställda.\n• AML § 3-5: Dokumenterad HMS-utbildning för VD.\n• Krav på skriftlig förteckning över arbetstidsavvikelser."
        case 3: return "• Internkontrollforskriften / SAM: Skriftliga rutiner och årlig riskinventering.\n• Visselblåsarlagen: Skriftlig intern rapporteringskanal.\n• Skyddsombud får skriftlig initiativ- och stopprätt."
        case 4: return "• AML § 7-1: Obligatorisk Arbetsmiljökommitté (AMU).\n• Likestillingsloven § 26 / Diskrimineringslagen: Årlig lönekartläggning & ARP-redogörelse.\n• Redovisning i förvaltningsberättelsen."
        default: return "• MBL § 11: Primär förhandlingsskyldighet vid verksamhetsändring.\n• Extern visselblåsarkanal med oberoende mottagning.\n• Formella turordningslistor vid neddragning."
        }
    }
    
    private func tierRisk(_ tier: Int) -> String {
        switch tier {
        case 1: return "• Skadestånd vid otydliga anställningsvillkor (50 000–100 000 kr).\n• Risk för retroaktiv lön och semesterersättning vid felaktig anställningsform."
        case 2: return "• Föreläggande och vite från Arbeidstilsynet / Arbetsmiljöverket.\n• Personligt straffansvar för VD vid allvarlig arbetsplatsolycka utan HMS-kurs."
        case 3: return "• Sanktionsavgift upp till 500 000 kr vid bristande SAM-dokumentation.\n• Tillsynsingripande och vite vid avsaknad av visselblåsarrutin."
        case 4: return "• Diskrimineringsersättning upp till 250 000 kr vid osakliga löneskillnader.\n• Offentlig anmärkning från Jämställdhetsmyndigheten / LDO."
        default: return "• Fackliga MBL-skadestånd (50 000–100 000 kr per tillfälle).\n• Ogiltigförklarade uppsägningar och skadestånd (median 396 000 kr i AD)."
        }
    }
    
    private func tierProductTitle(_ tier: Int) -> String {
        switch tier {
        case 1: return "Simployer Comply Core"
        case 2: return "Simployer Learn (HMS-kurs)"
        case 3: return "Simployer Handbooks"
        case 4: return "Simployer Equal Pay"
        default: return "Simployer One HRM + Expert"
        }
    }
    
    private func tierProductDesc(_ tier: Int) -> String {
        switch tier {
        case 1: return "Automatisk avtalsgranskning och lagradar. Bevakar anställningsavtal dygnet runt."
        case 2: return "Certifierad webbkurs för VD. Uppfyller AML § 3-5 med juridiskt giltigt intyg."
        case 3: return "Digital personalhandbok med färdiga SAM-mallar, policyer och visselblåsarrutin."
        case 4: return "Automatisk lönekartläggning och ARP-rapport direkt från ert lönesystem."
        default: return "Komplett HRM-system kombinerat med obegränsad juridisk rådgivning och ansvarsgaranti."
        }
    }
    
    @ViewBuilder
    private func tierProductActionButton(tier: Int) -> some View {
        switch tier {
        case 1:
            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(SolTokens.green800)
                Text("Aktiv i er plan")
                    .font(.inter(11, .semibold))
                    .foregroundColor(SolTokens.green800)
            }
            .padding(.vertical, 4)
        case 2:
            Button {
                store.activeNav = "hub"
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "graduationcap.fill")
                    Text("Boka VD-kurs (3 900 kr)")
                }
                .font(.inter(11, .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5.5)
                .background(SolTokens.lav400.opacity(0.16))
                .foregroundColor(SolTokens.lav400)
                .cornerRadius(5)
            }
            .buttonStyle(.plain)
        case 3:
            Button {
                store.activeNav = "handbook"
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "book.closed.fill")
                    Text("Öppna Handbok (1 490 kr/m)")
                }
                .font(.inter(11, .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5.5)
                .background(SolTokens.paper300)
                .foregroundColor(SolTokens.ink900)
                .cornerRadius(5)
            }
            .buttonStyle(.plain)
        case 4:
            Button {
                store.showUpsellModal = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Begär Equal Pay Demo")
                }
                .font(.inter(11, .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5.5)
                .background(SolTokens.paper300)
                .foregroundColor(SolTokens.ink900)
                .cornerRadius(5)
            }
            .buttonStyle(.plain)
        default:
            Button {
                store.activeNav = "expert"
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                    Text("Kontakta Simployer Expert")
                }
                .font(.inter(11, .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5.5)
                .background(SolTokens.lav400.opacity(0.16))
                .foregroundColor(SolTokens.lav400)
                .cornerRadius(5)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Linear Settings View
    private var macSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.l10n.settingsTitle)
                        .font(.inter(18, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text(store.l10n.settingsSubtitle)
                        .font(.inter(12.5))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.top, 4)
                
                // SECTION 0: PROTOTYP & AUTOMATISKA UPPDATERINGAR (Sparkle 2)
                VStack(alignment: .leading, spacing: 12) {
                    Text("PROTOTYP & AUTOMATISKA UPPDATERINGAR")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                        .padding(.horizontal, 2)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(SolTokens.paper200)
                                    .frame(width: 40, height: 40)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.inter(17))
                                    .foregroundColor(SolTokens.ink700)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text("Simployer Comply Prototype")
                                        .font(.inter(14, .bold))
                                        .foregroundColor(SolTokens.ink900)
                                    
                                    LinearStatusPill(
                                        text: "v1.0.0 (Build 1)",
                                        dotColor: SolTokens.green800
                                    )
                                }
                                
                                Text("Automatiska bakgrundsuppdateringar via Sparkle 2 · Kanal: GitHub Releases")
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            Button {
                                ComplyUpdater.shared.checkForUpdates()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.inter(11))
                                    Text("Sök efter uppdateringar nu")
                                        .font(.inter(12, .semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6.5)
                                .background(SolTokens.paper200)
                                .foregroundColor(SolTokens.ink700)
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(SolTokens.paper100)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                // SECTION 1: SAMARBETSVERKTYG & HEADLESS NOTIFIERINGAR
                VStack(alignment: .leading, spacing: 12) {
                    Text(store.l10n.settingsSectionIntegrations)
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                        .padding(.horizontal, 2)
                    
                    // Slack Integration Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(SolTokens.lav400.opacity(0.14))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "number.square.fill")
                                    .font(.inter(22))
                                    .foregroundColor(SolTokens.lav400)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text(store.l10n.settingsSlackTitle)
                                        .font(.inter(14, .bold))
                                        .foregroundColor(SolTokens.ink900)
                                    
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(SolTokens.green800)
                                            .frame(width: 6, height: 6)
                                        Text("Ansluten")
                                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                            .foregroundColor(SolTokens.green800)
                                    }
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(SolTokens.green800.opacity(0.12))
                                    .cornerRadius(4)
                                }
                                
                                Text(store.l10n.settingsSlackChannel)
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            Button {
                                store.sendTestSlackAlert()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.inter(11))
                                    Text(store.l10n.settingsSlackTestButton)
                                        .font(.inter(12, .semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(SolTokens.lav400.opacity(0.14))
                                .foregroundColor(SolTokens.lav400)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(SolTokens.lav400.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Divider().overlay(SolTokens.paper300)
                        
                        // Toggles for Slack
                        VStack(spacing: 10) {
                            settingsToggleRow(
                                title: "Omedelbara notiser vid lagavvikelser & anställningsändringar",
                                subtitle: "Skickar direkt varning till #ledningsgrupp-compliance när ett avtal saknar lagklausuler.",
                                isOn: $store.slackInstantAlerts
                            )
                            settingsToggleRow(
                                title: "Veckovis compliance-sammanfattning (Måndagar 08:00)",
                                subtitle: "Kompakt översikt över säkrade avtal, sjukfrånvarostatus och kommande tillsynströsklar.",
                                isOn: $store.slackWeeklyDigest
                            )
                        }
                    }
                    .padding(16)
                    .background(SolTokens.paper100)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                    
                    // Microsoft Teams Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(SolTokens.lav400.opacity(0.14))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "person.3.sequence.fill")
                                    .font(.inter(20))
                                    .foregroundColor(SolTokens.lav400)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text(store.l10n.settingsTeamsTitle)
                                        .font(.inter(14, .bold))
                                        .foregroundColor(SolTokens.ink900)
                                    
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(SolTokens.green800)
                                            .frame(width: 6, height: 6)
                                        Text("Ansluten")
                                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                            .foregroundColor(SolTokens.green800)
                                    }
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(SolTokens.green800.opacity(0.12))
                                    .cornerRadius(4)
                                }
                                
                                Text(store.l10n.settingsTeamsWebhook)
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                        }
                        
                        Divider().overlay(SolTokens.paper300)
                        
                        settingsToggleRow(
                            title: "Interaktiva Adaptive Cards med BankID-knapp",
                            subtitle: "Låter VD godkänna anställningsavtal eller starta skyddsombudsval direkt i Teams utan att öppna Comply-appen.",
                            isOn: $store.teamsAdaptiveCards
                        )
                    }
                    .padding(16)
                    .background(SolTokens.paper100)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                    
                    // Email Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(SolTokens.lav400.opacity(0.14))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "envelope.fill")
                                    .font(.inter(18))
                                    .foregroundColor(SolTokens.lav400)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(store.l10n.settingsEmailTitle)
                                    .font(.inter(14, .bold))
                                    .foregroundColor(SolTokens.ink900)
                                Text(store.l10n.settingsEmailDesc)
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                        }
                        
                        Divider().overlay(SolTokens.paper300)
                        
                        settingsToggleRow(
                            title: "Månatlig VD-rapport & lagändringsbulletin",
                            subtitle: "Juridiskt sammandrag från Simployer Expert rörande ändringar i AML, LAS och semesterlagen.",
                            isOn: $store.emailMonthlySummary
                        )
                    }
                    .padding(16)
                    .background(SolTokens.paper100)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                // SECTION 2: AFFÄRS- OCH LÖNESYSTEM (SYSTEM OF RECORD)
                VStack(alignment: .leading, spacing: 12) {
                    Text(store.l10n.settingsSectionSystems)
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                        .padding(.horizontal, 2)
                    
                    HStack(spacing: 12) {
                        // Fortnox
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "building.2.fill")
                                        .font(.inter(14))
                                        .foregroundColor(SolTokens.lav400)
                                    Text(store.l10n.settingsFortnoxTitle)
                                        .font(.inter(13.5, .bold))
                                        .foregroundColor(SolTokens.ink900)
                                }
                                Spacer()
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(SolTokens.green800)
                                        .frame(width: 5, height: 5)
                                    Text("Live Sync")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(SolTokens.green800)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2.5)
                                .background(SolTokens.green800.opacity(0.12))
                                .cornerRadius(4)
                            }
                            
                            Text(store.l10n.settingsFortnoxSyncStatus)
                                .font(.inter(12))
                                .foregroundColor(SolTokens.ink600)
                            
                            Text("Senaste synk: För 2 minuter sedan · Org: Fjord Dynamics AS (924 812 345)")
                                .font(.system(size: 10.5, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SolTokens.paper100)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                        
                        // Microsoft 365 / SharePoint
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "cloud.fill")
                                        .font(.inter(14))
                                        .foregroundColor(SolTokens.lav400)
                                    Text("Microsoft 365 / SharePoint")
                                        .font(.inter(13.5, .bold))
                                        .foregroundColor(SolTokens.ink900)
                                }
                                Spacer()
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(SolTokens.green800)
                                        .frame(width: 5, height: 5)
                                    Text("Övervakas")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(SolTokens.green800)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2.5)
                                .background(SolTokens.green800.opacity(0.12))
                                .cornerRadius(4)
                            }
                            
                            Text("simployer.sharepoint.com · 42 filer synkroniserade")
                                .font(.inter(12))
                                .foregroundColor(SolTokens.ink600)
                            
                            Text("Bevakar anställningsavtal, policydokument och mötesprotokoll.")
                                .font(.system(size: 10.5, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SolTokens.paper100)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                }
                
                // SECTION 3: SÄKERHET & SIGNERINGSBEHÖRIGHET
                VStack(alignment: .leading, spacing: 12) {
                    Text(store.l10n.settingsSectionSecurity)
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                        .padding(.horizontal, 2)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(SolTokens.green800.opacity(0.14))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "lock.shield.fill")
                                    .font(.inter(20))
                                    .foregroundColor(SolTokens.green800)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text("BankID Signeringsfullmakt & Bevisbörda")
                                        .font(.inter(14, .bold))
                                        .foregroundColor(SolTokens.ink900)
                                    
                                    Text("EU AI Act & AML-säkrad")
                                        .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2.5)
                                        .background(SolTokens.paper250)
                                        .foregroundColor(SolTokens.ink700)
                                        .cornerRadius(4)
                                }
                                
                                Text(store.l10n.settingsBankIdDesc)
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.inter(12))
                                .foregroundColor(SolTokens.green800)
                            Text("Alla ändringar tidsstämplas kryptografiskt i revisionsloggen med fullständig spårbarhet för Arbeidstilsynet / Arbetsmiljöverket.")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(SolTokens.ink600)
                        }
                        .padding(10)
                        .background(SolTokens.paper200)
                        .cornerRadius(6)
                    }
                    .padding(16)
                    .background(SolTokens.paper100)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                }
            }
            .padding(20)
        }
    }
    
    private func settingsToggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.inter(12.5, .semibold))
                    .foregroundColor(SolTokens.ink900)
                Text(subtitle)
                    .font(.inter(11.5))
                    .foregroundColor(SolTokens.ink600)
            }
            Spacer()
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isOn.wrappedValue ? SolTokens.lav400 : SolTokens.ink450)
                        .font(.inter(16))
                    Text(isOn.wrappedValue ? "Aktiv" : "Avstängd")
                        .font(.inter(11.5, .medium))
                        .foregroundColor(isOn.wrappedValue ? SolTokens.ink900 : SolTokens.ink450)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isOn.wrappedValue ? SolTokens.lav400.opacity(0.12) : SolTokens.paper250)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
    }
    // MARK: - 2024 Hub Cards Modular Views
    
    // Card 1: Employment Contracts (AML § 14-6) — AKUT (Olagligt idag)
    @ViewBuilder
    private var hubCardContracts: some View {
        let unapprovedEmployees = store.currentScenario.employees.filter { $0.status == .aml14Gap }
        let hasUnapproved = !unapprovedEmployees.isEmpty
        let contractsDone = !hasUnapproved
        
        if shouldShowInActiveList("contracts") {
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text(store.l10n.hubCardContractsStatute)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                
                Text(store.l10n.hubRiskBadgeContracts)
                    .font(.inter(10.5, .medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink600)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                
                Spacer()
                if !hasUnapproved {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCompletedBadge)
                            .font(.inter(11, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(store.l10n.hubEst45Sec)
                            .font(.inter(11, .medium))
                    }
                    .foregroundColor(SolTokens.ink600)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(4)
                }
            }
            
            Text(hasUnapproved ? store.l10n.hubContractsTitle(unapprovedCount: unapprovedEmployees.count) : store.l10n.hubCardContractsResolved)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(hasUnapproved ? store.l10n.hubCardContractsDesc : store.l10n.hubCardContractsResolved)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
            
            if hasUnapproved {
                HStack(spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                        Text(store.l10n.hubScopeContracts)
                            .font(.inter(11.5))
                    }
                    .foregroundColor(SolTokens.ink600)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(5)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 9.5))
                            .foregroundColor(SolTokens.amber400)
                        Text(store.l10n.hubExposureContracts)
                            .font(.inter(11, .medium))
                            .foregroundColor(SolTokens.ink600)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
                }
            }
            
            HStack(spacing: 10) {
                if hasUnapproved {
                    if expandedHubCard != "contracts" {
                        Button {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                store.approveAllContracts()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "signature")
                                    .font(.inter(12))
                                Text(store.l10n.hubContractsAction(unapprovedCount: unapprovedEmployees.count))
                                    .font(.inter(12.5, .semibold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(SolTokens.linearIndigo)
                            .foregroundColor(Color.white)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(SolTokens.green800)
                            .font(.inter(12))
                        Text(store.l10n.hubCardContractsResolved)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        if expandedHubCard == "contracts" {
                            expandedHubCard = nil
                        } else {
                            expandedHubCard = "contracts"
                            if selectedDiffEmployee == nil || selectedDiffEmployee?.status != .aml14Gap {
                                selectedDiffEmployee = store.currentScenario.employees.first(where: { $0.status == .aml14Gap })
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(store.l10n.hubInspectChanges)
                        Image(systemName: "chevron.down")
                            .font(.inter(9))
                            .rotationEffect(.degrees(expandedHubCard == "contracts" ? 180 : 0))
                    }
                    .font(.inter(12, .medium))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(expandedHubCard == "contracts" ? SolTokens.paper250 : SolTokens.paper200)
                    .foregroundColor(expandedHubCard == "contracts" ? SolTokens.ink900 : SolTokens.ink700)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(expandedHubCard == "contracts" ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("inspect_contracts_button")
            }
            .padding(.top, 4)
            
            // In-place Expandable Redline Diff ("Full-in, full-out")
            if expandedHubCard == "contracts" {
                inlineContractsDiffView
                    .clipped()
                    .transition(.linearAccordion)
            }
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(hasUnapproved ? SolTokens.red700 : SolTokens.green800)
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(hasUnapproved ? SolTokens.redBorder : SolTokens.greenBorder, lineWidth: 1)
        )
        .opacity(expandedHubCard != nil && expandedHubCard != "contracts" ? 0.35 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
        .transition(.cardVanishTransition)
        }
    }
    
    // Card 2: Verneombud Election (AML § 6-1) — SNART (Lagstadgad tidsfrist)
    @ViewBuilder
    private var hubCardVerneombud: some View {
        if shouldShowInActiveList("verneombud") {
            let voActive = store.verneombudElectionActive
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text(store.l10n.hubCardVoStatute)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                
                Text(store.l10n.hubRiskBadgeVo)
                    .font(.inter(10.5, .medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink600)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                
                Spacer()
                if voActive {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text("\(store.electionVotesCast)/8 stemmer")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(SolTokens.green800)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(store.l10n.hubEst1Min)
                            .font(.inter(11, .medium))
                    }
                    .foregroundColor(SolTokens.ink600)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(4)
                }
            }
            
            Text(store.l10n.hubCardVoTitle)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(voActive ? "\(store.l10n.hubCardVoResolved) · \(store.electionVotesCast)/8 stemt." : store.l10n.hubCardVoDesc)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
            
            if !voActive {
                HStack(spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "person.2.crop.square.stack.fill")
                            .font(.system(size: 10))
                        Text(store.l10n.hubScopeVo)
                            .font(.inter(11.5))
                    }
                    .foregroundColor(SolTokens.ink600)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(5)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 9.5))
                            .foregroundColor(SolTokens.amber400)
                        Text(store.l10n.hubExposureVo)
                            .font(.inter(11, .medium))
                            .foregroundColor(SolTokens.ink600)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
                }
            }
            
            HStack(spacing: 10) {
                if !voActive {
                    if expandedHubCard != "verneombud" {
                        Button {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                store.castVerneombudVote()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "person.badge.shield.checkmark.fill")
                                    .font(.inter(12))
                                Text(store.l10n.hubCardVoAction)
                                    .font(.inter(12.5, .semibold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(SolTokens.linearIndigo)
                            .foregroundColor(Color.white)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCardVoResolved)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        expandedHubCard = (expandedHubCard == "verneombud" ? nil : "verneombud")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(store.l10n.hubOpenDetails)
                        Image(systemName: "chevron.down")
                            .font(.inter(9))
                            .rotationEffect(.degrees(expandedHubCard == "verneombud" ? 180 : 0))
                    }
                    .font(.inter(12, .medium))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(expandedHubCard == "verneombud" ? SolTokens.paper250 : SolTokens.paper200)
                    .foregroundColor(expandedHubCard == "verneombud" ? SolTokens.ink900 : SolTokens.ink700)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(expandedHubCard == "verneombud" ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
            
            // In-place Expandable Verneombud Election
            if expandedHubCard == "verneombud" {
                inlineVerneombudView
                    .clipped()
                    .transition(.linearAccordion)
            }
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(voActive ? SolTokens.green800 : SolTokens.amber400)
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(voActive ? SolTokens.greenBorder : SolTokens.amberBorder, lineWidth: 1)
        )
        .opacity(expandedHubCard != nil && expandedHubCard != "verneombud" ? 0.35 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
        .transition(.cardVanishTransition)
        }
    }
    
    // Card 3: Leader HMS (AML § 3-5) — PLANERAT (Bolagsresan & Kompetenskrav)
    @ViewBuilder
    private var hubCardHMS: some View {
        if shouldShowInActiveList("hms") {
            let hmsDone = store.hmsTrainingEnrolled
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text(store.l10n.hubCardHmsStatute)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                
                Text(store.l10n.hubRiskBadgeHms)
                    .font(.inter(10.5, .medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink600)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                
                Spacer()
                if hmsDone {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCompletedBadge)
                            .font(.inter(11, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                } else {
                    HStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(store.l10n.hubEstCourse)
                                .font(.inter(11, .medium))
                        }
                        .foregroundColor(SolTokens.ink600)
                        
                        Text("·")
                            .foregroundColor(SolTokens.ink450)
                        
                        Text(store.l10n.hubHmsPrice)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink700)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(SolTokens.paper200)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                }
            }
            
            Text(store.l10n.hubCardHmsTitle)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(hmsDone ? store.l10n.hubHmsBookedConfirmation : store.l10n.hubCardHmsDesc)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
            
            if !hmsDone {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9.5))
                        .foregroundColor(SolTokens.amber400)
                    Text(store.l10n.hubExposureHms)
                        .font(.inter(11, .medium))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3.5)
                .background(SolTokens.paper200)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
            }
            
            // Order and Billing Context Bar
            if !hmsDone {
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 10.5))
                            .foregroundColor(SolTokens.ink600)
                        Text(store.l10n.hubHmsParticipant)
                            .font(.inter(11.5))
                            .foregroundColor(SolTokens.ink700)
                    }
                    
                    Text("·")
                        .foregroundColor(SolTokens.ink450)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 10.5))
                            .foregroundColor(SolTokens.ink600)
                        Text(store.l10n.hubHmsBillingTerms)
                            .font(.inter(11.5))
                            .foregroundColor(SolTokens.ink700)
                    }
                    
                    Spacer()
                    
                    Text(store.l10n.hubHmsPrice)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink900)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(SolTokens.paper200)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
            }
            
            HStack(spacing: 10) {
                if !hmsDone {
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            store.hmsTrainingEnrolled = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "creditcard.fill")
                                .font(.inter(12))
                            Text(store.l10n.hubHmsBookAction)
                                .font(.inter(12.5, .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.linearIndigo)
                        .foregroundColor(Color.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            expandedHubCard = (expandedHubCard == "hms" ? nil : "hms")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.l10n.hubHmsCurriculumButton)
                            Image(systemName: "chevron.down")
                                .font(.inter(9))
                                .rotationEffect(.degrees(expandedHubCard == "hms" ? 180 : 0))
                        }
                        .font(.inter(12, .medium))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(expandedHubCard == "hms" ? SolTokens.paper250 : SolTokens.paper200)
                        .foregroundColor(expandedHubCard == "hms" ? SolTokens.ink900 : SolTokens.ink700)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(expandedHubCard == "hms" ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubHmsBookedConfirmation)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
            }
            .padding(.top, 4)
            
            // In-place Expandable HMS Curriculum & Booking Drawer
            if expandedHubCard == "hms" {
                inlineHmsBookingView
                    .clipped()
                    .transition(.linearAccordion)
            }
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(hmsDone ? SolTokens.green800 : SolTokens.lav500)
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(hmsDone ? SolTokens.greenBorder : SolTokens.lavBorder, lineWidth: 1)
        )
        .opacity(expandedHubCard != nil && expandedHubCard != "hms" ? 0.35 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
        .transition(.cardVanishTransition)
        }
    }
    
    // MARK: - 2024 Hub Cards Composite
    @ViewBuilder
    private var hub2024Cards: some View {
        hubCardContracts
        hubCardVerneombud
        hubCardHMS
    }
    
    // MARK: - 2025 Hub Cards Modular Views
    
    // Card 1: Equal Pay / ARP Statement (Likestillingsloven § 26) — SNART (Lagstadgad tidsfrist)
    @ViewBuilder
    private var hubCardEqualPay: some View {
        let epDone = store.equalPayReportGenerated
        
        if shouldShowInActiveList("equalPay") {
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(store.l10n.hubCardEqualPayStatute)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                Spacer()
                if epDone {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCompletedBadge)
                            .font(.inter(11, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                }
            }
            
            Text(store.l10n.hubCardEqualPayTitle)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(epDone ? store.l10n.hubCardEqualPayResolved : store.l10n.hubCardEqualPayDesc)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
            
            HStack(spacing: 10) {
                if !epDone {
                    if expandedHubCard != "equalPay" {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                store.equalPayReportGenerated = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.inter(12))
                                Text(store.l10n.hubCardEqualPayAction)
                                    .font(.inter(12.5, .semibold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(SolTokens.linearIndigo)
                            .foregroundColor(Color.white)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCardEqualPayResolved)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        expandedHubCard = (expandedHubCard == "equalPay" ? nil : "equalPay")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(expandedHubCard == "equalPay" ? store.l10n.close : store.l10n.hubOpenDetails)
                        Image(systemName: expandedHubCard == "equalPay" ? "chevron.up" : "chevron.down")
                            .font(.inter(9))
                    }
                    .font(.inter(12, .medium))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(expandedHubCard == "equalPay" ? SolTokens.paper250 : SolTokens.paper200)
                    .foregroundColor(expandedHubCard == "equalPay" ? SolTokens.ink900 : SolTokens.ink700)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(expandedHubCard == "equalPay" ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
            
            // In-place Expandable Equal Pay Audit
            if expandedHubCard == "equalPay" {
                inlineEqualPayView
                    .clipped()
                    .transition(.linearAccordion)
            }
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(epDone ? SolTokens.green800 : SolTokens.amber400)
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(epDone ? SolTokens.greenBorder : SolTokens.amberBorder, lineWidth: 1)
        )
        .opacity(expandedHubCard != nil && expandedHubCard != "equalPay" ? 0.35 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
        .transition(.cardVanishTransition)
        }
    }
    
    // Card 2: Sick Leave Day 14 Follow-Up (AML § 4-6) — AKUT (Förfallen lagfrist)
    @ViewBuilder
    private var hubCardSickLeave: some View {
        if shouldShowInActiveList("sickLeave") {
            let sickDone = store.sickLeavePlanDispatched
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(store.l10n.hubCardSickStatute)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                Spacer()
                if sickDone {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCompletedBadge)
                            .font(.inter(11, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                }
            }
            
            Text(store.l10n.hubCardSickTitle)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(sickDone ? store.l10n.hubCardSickResolved : store.l10n.hubCardSickDesc)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
            
            HStack(spacing: 10) {
                if !sickDone {
                    if expandedHubCard != "sickLeave" {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                store.sickLeavePlanDispatched = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.inter(12))
                                Text(store.l10n.hubCardSickAction)
                                    .font(.inter(12.5, .semibold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(SolTokens.linearIndigo)
                            .foregroundColor(Color.white)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCardSickResolved)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        expandedHubCard = (expandedHubCard == "sickLeave" ? nil : "sickLeave")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(expandedHubCard == "sickLeave" ? store.l10n.close : store.l10n.hubOpenDetails)
                        Image(systemName: expandedHubCard == "sickLeave" ? "chevron.up" : "chevron.down")
                            .font(.inter(9))
                    }
                    .font(.inter(12, .medium))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(expandedHubCard == "sickLeave" ? SolTokens.paper250 : SolTokens.paper200)
                    .foregroundColor(expandedHubCard == "sickLeave" ? SolTokens.ink900 : SolTokens.ink700)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(expandedHubCard == "sickLeave" ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
            
            // In-place Expandable Sick Leave Follow-Up
            if expandedHubCard == "sickLeave" {
                inlineSickLeaveView
                    .clipped()
                    .transition(.linearAccordion)
            }
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(sickDone ? SolTokens.green800 : SolTokens.red700)
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(sickDone ? SolTokens.greenBorder : SolTokens.redBorder, lineWidth: 1)
        )
        .opacity(expandedHubCard != nil && expandedHubCard != "sickLeave" ? 0.35 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
        .transition(.cardVanishTransition)
        }
    }
    
    // Card 3: Probation Expirations (AML § 15-6) — PLANERAT (Bolagsresan)
    @ViewBuilder
    private var hubCardProbation: some View {
        if shouldShowInActiveList("probation") {
            let probDone = store.probationConfirmed
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(store.l10n.hubCardProbationStatute)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                Spacer()
                if probDone {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCompletedBadge)
                            .font(.inter(11, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                }
            }
            
            Text(store.l10n.hubCardProbationTitle)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(probDone ? store.l10n.hubCardProbationResolved : store.l10n.hubCardProbationDesc)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
            
            HStack(spacing: 10) {
                if !probDone {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.probationConfirmed = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.inter(12))
                            Text(store.l10n.hubCardProbationAction)
                                .font(.inter(12.5, .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.linearIndigo)
                        .foregroundColor(Color.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCardProbationResolved)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(probDone ? SolTokens.green800 : SolTokens.lav500)
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(probDone ? SolTokens.greenBorder : SolTokens.lavBorder, lineWidth: 1)
        )
        .opacity(expandedHubCard != nil ? 0.35 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
        .transition(.cardVanishTransition)
        }
    }
    
    // MARK: - 2025 Hub Cards Composite
    @ViewBuilder
    private var hub2025Cards: some View {
        hubCardEqualPay
        hubCardSickLeave
        hubCardProbation
    }
    
    // MARK: - 2027 Hub Cards Modular Views
    
    // Card 1: Dismissal Defense (AML § 15-1) — AKUT (14 dagars lagfrist)
    @ViewBuilder
    private var hubCardDefense: some View {
        let defenseDone = store.juristHandoffCompleted
        
        if shouldShowInActiveList("defense") {
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(store.l10n.hubCardDefenseStatute)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                Spacer()
                if defenseDone {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCompletedBadge)
                            .font(.inter(11, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                }
            }
            
            Text(store.l10n.hubCardDefenseTitle)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(defenseDone ? store.l10n.hubCardDefenseResolved : store.l10n.hubCardDefenseDesc)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
            
            HStack(spacing: 10) {
                if !defenseDone {
                    if expandedHubCard != "defense" {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                store.juristHandoffCompleted = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "scale.3d")
                                    .font(.inter(12))
                                Text(store.l10n.hubCardDefenseAction)
                                    .font(.inter(12.5, .semibold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(SolTokens.linearIndigo)
                            .foregroundColor(Color.white)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubCardDefenseResolved)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        expandedHubCard = (expandedHubCard == "defense" ? nil : "defense")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(expandedHubCard == "defense" ? store.l10n.close : store.l10n.hubOpenDetails)
                        Image(systemName: expandedHubCard == "defense" ? "chevron.up" : "chevron.down")
                            .font(.inter(9))
                    }
                    .font(.inter(12, .medium))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(expandedHubCard == "defense" ? SolTokens.paper250 : SolTokens.paper200)
                    .foregroundColor(expandedHubCard == "defense" ? SolTokens.ink900 : SolTokens.ink700)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(expandedHubCard == "defense" ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
            
            // In-place Expandable Dismissal Defense
            if expandedHubCard == "defense" {
                inlineDismissalDefenseView
                    .clipped()
                    .transition(.linearAccordion)
            }
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(defenseDone ? SolTokens.green800 : SolTokens.red700)
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(defenseDone ? SolTokens.greenBorder : SolTokens.redBorder, lineWidth: 1)
        )
        .opacity(expandedHubCard != nil && expandedHubCard != "defense" ? 0.35 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: expandedHubCard)
        .transition(.cardVanishTransition)
        }
    }
    
    // MARK: - 2027 Hub Cards Composite
    @ViewBuilder
    private var hub2027Cards: some View {
        hubCardDefense
    }
    
    // MARK: - Ingestion Canvas & Cloud Sources Hub (The Apple Standard: Calm, Restrained, One Clear Hero)
    private var macIngestDropView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ingestHeaderView
                heroDropzoneView
                monitoredSourcesListView
                reassuranceBarView
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var ingestHeaderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(store.l10n.ingestSourcesTitle)
                .font(.inter(18, .bold))
                .foregroundColor(SolTokens.ink900)
            Text(store.l10n.ingestSourcesSubtitle)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink600)
        }
        .padding(.top, 4)
    }
    
    private var heroDropzoneView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isDropTargeted ? SolTokens.lav400 : (isAnalyzingDrop ? SolTokens.lav400.opacity(0.6) : SolTokens.paper300),
                    style: StrokeStyle(lineWidth: 1.5, dash: isAnalyzingDrop ? [] : [6, 6])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isDropTargeted || isAnalyzingDrop ? SolTokens.lav400.opacity(0.06) : SolTokens.paper100)
                )
            
            if isAnalyzingDrop {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(dropAnalysisStage == 4 ? SolTokens.green100 : SolTokens.lav100)
                                .frame(width: 44, height: 44)
                            Image(systemName: dropAnalysisStage == 4 ? "checkmark.seal.fill" : "doc.text.magnifyingglass")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(dropAnalysisStage == 4 ? SolTokens.green800 : SolTokens.lav400)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(dropFileName)
                                    .font(.inter(13.5, .semibold))
                                    .foregroundColor(SolTokens.ink900)
                                
                                Text("· 8 anställda")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(SolTokens.ink450)
                            }
                            
                            Text(dropStageDescription)
                                .font(.inter(12))
                                .foregroundColor(dropAnalysisStage == 4 ? SolTokens.green800 : SolTokens.ink600)
                        }
                        
                        Spacer()
                        
                        if dropAnalysisStage == 4 {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    store.activeNav = "hub"
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "bolt.fill")
                                    Text(store.l10n.ingestDropGoToHub)
                                    Image(systemName: "arrow.right")
                                }
                                .font(.inter(12, .semibold))
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(SolTokens.plum900)
                                .cornerRadius(7)
                                
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Progress Bar & Percentage
                    VStack(alignment: .trailing, spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(SolTokens.paper300)
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(dropAnalysisStage == 4 ? SolTokens.green800 : SolTokens.lav400)
                                    .frame(width: max(0, geo.size.width * dropProgress), height: 6)
                                    .animation(.easeInOut(duration: 0.35), value: dropProgress)
                            }
                        }
                        .frame(height: 6)
                        
                        HStack {
                            Text(dropAnalysisStage == 4 ? "100 % slutfört" : "\(Int(dropProgress * 100)) %")
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                            
                            Spacer()
                            
                            if dropAnalysisStage == 4 {
                                Button {
                                    withAnimation {
                                        isAnalyzingDrop = false
                                        dropProgress = 0.0
                                        dropAnalysisStage = 0
                                    }
                                } label: {
                                    Text("Ny inläsning")
                                        .font(.inter(11, .medium))
                                        .foregroundColor(SolTokens.lav400)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 24)
                .transition(.opacity)
            } else {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(SolTokens.lav400.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.system(size: 20))
                            .foregroundColor(SolTokens.lav400)
                    }
                    
                    VStack(spacing: 4) {
                        Text(store.l10n.ingestHeroTitle)
                            .font(.inter(14, .semibold))
                            .foregroundColor(SolTokens.ink900)
                        Text(store.l10n.ingestHeroSubtitle)
                            .font(.inter(12))
                            .foregroundColor(SolTokens.ink450)
                    }
                    
                    HStack(spacing: 10) {
                        Button {
                            #if os(macOS)
                            let panel = NSOpenPanel()
                            panel.canChooseFiles = true
                            panel.canChooseDirectories = true
                            panel.allowsMultipleSelection = false
                            panel.prompt = store.l10n.ingestBrowseButton
                            if panel.runModal() == .OK, let url = panel.url {
                                startSimulatedIngestion(fileName: url.lastPathComponent)
                            }
                            #endif
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.badge.plus")
                                Text(store.l10n.ingestBrowseButton)
                            }
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.ink900)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(SolTokens.paper200)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            startSimulatedIngestion(fileName: "Standardavtal_Fjord_Dynamics_2024.docx")
                        } label: {
                            HStack(spacing: 5) {
                                Text(store.l10n.ingestSimulateButton)
                                Image(systemName: "arrow.right")
                            }
                            .font(.inter(12, .semibold))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 7)
                            .background(SolTokens.sidebarActivePill)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 2)
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 180)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { _ in
            startSimulatedIngestion(fileName: "Mottaget_Anställningsavtal.docx")
            return true
        }
    }
    
    private var dropStageDescription: String {
        switch dropAnalysisStage {
        case 1:
            return store.l10n.ingestDropStage1
        case 2:
            return store.l10n.ingestDropStage2
        case 3:
            return store.l10n.ingestDropStage3
        case 4:
            return store.l10n.ingestDropSuccess
        default:
            return store.l10n.ingestDropAnalyzing
        }
    }
    
    private func startSimulatedIngestion(fileName: String = "Anställningsavtal_2024_Standard.docx") {
        self.dropFileName = fileName
        self.isAnalyzingDrop = true
        self.dropProgress = 0.15
        self.dropAnalysisStage = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.35)) {
                self.dropProgress = 0.52
                self.dropAnalysisStage = 2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            withAnimation(.easeInOut(duration: 0.35)) {
                self.dropProgress = 0.88
                self.dropAnalysisStage = 3
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.65) {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
                self.dropProgress = 1.0
                self.dropAnalysisStage = 4
                store.hasIngestedFiles = true
                store.currentYear = .y2024
            }
        }
    }
    
    private var monitoredSourcesListView: some View {
        let activeSourcesCount = store.monitoredLocalFolders.count + (store.connectedCloudServices.contains("onedrive") ? 1 : 0)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(store.l10n.monitoredSourcesHeader)
                    .font(.inter(13, .semibold))
                    .foregroundColor(SolTokens.ink900)
                
                Text("· \(activeSourcesCount) \(store.l10n.activeSuffix)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
                
                Spacer()
                
                Button {
                    #if os(macOS)
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.prompt = store.l10n.addFolderButton
                    if panel.runModal() == .OK, let url = panel.url {
                        let rawPath = url.path
                        let home = NSHomeDirectory()
                        let displayPath = rawPath.hasPrefix(home) ? rawPath.replacingOccurrences(of: home, with: "~") : rawPath
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if !store.monitoredLocalFolders.contains(displayPath) {
                                store.monitoredLocalFolders.append(displayPath)
                            }
                        }
                    }
                    #endif
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                        Text(store.l10n.addFolderButton)
                    }
                    .font(.inter(11.5, .medium))
                    .foregroundColor(SolTokens.lav400)
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 0) {
                // Microsoft 365 / OneDrive Row
                if store.connectedCloudServices.contains("onedrive") {
                    HStack(spacing: 12) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.blue)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Microsoft 365 / OneDrive")
                                .font(.inter(12.5, .medium))
                                .foregroundColor(SolTokens.ink900)
                            Text("simployer.sharepoint.com · 42 \(store.l10n.filesSyncedSuffix)")
                                .font(.inter(11))
                                .foregroundColor(SolTokens.ink450)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 5) {
                            Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                            Text(store.l10n.connectedBadge)
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(SolTokens.green800)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(SolTokens.green800.opacity(0.1))
                        .cornerRadius(4)
                        
                        Button {
                            withAnimation {
                                _ = store.connectedCloudServices.remove("onedrive")
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(SolTokens.ink450)
                                .padding(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    
                    Divider().overlay(SolTokens.paper300.opacity(0.5))
                }
                
                // Guarded Local Folders
                ForEach(Array(store.monitoredLocalFolders.enumerated()), id: \.element) { index, folderPath in
                    HStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 14))
                            .foregroundColor(SolTokens.lav400)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(folderPath)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(SolTokens.ink900)
                            Text(folderPath.contains("Downloads") ? store.l10n.downloadsFolderDesc : store.l10n.documentsFolderDesc)
                                .font(.inter(11))
                                .foregroundColor(SolTokens.ink450)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 5) {
                            Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                            Text(store.l10n.guardingBadge)
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(SolTokens.green800)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(SolTokens.green800.opacity(0.1))
                        .cornerRadius(4)
                        
                        Button {
                            withAnimation {
                                store.monitoredLocalFolders.removeAll { $0 == folderPath }
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(SolTokens.ink450)
                                .padding(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    
                    if index < store.monitoredLocalFolders.count - 1 {
                        Divider().overlay(SolTokens.paper300.opacity(0.5))
                    }
                }
            }
            .background(SolTokens.paper100)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
            
            // Quiet Integrations Row (connect Google Drive or Dropbox)
            HStack(spacing: 8) {
                Text(store.l10n.connectMoreLabel)
                    .font(.inter(11.5))
                    .foregroundColor(SolTokens.ink450)
                
                Button {
                    withAnimation {
                        if store.connectedCloudServices.contains("onedrive") {
                            _ = store.connectedCloudServices.remove("onedrive")
                        } else {
                            store.connectedCloudServices.insert("onedrive")
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "cloud")
                        Text(store.connectedCloudServices.contains("onedrive") ? "OneDrive (\(store.l10n.connectedBadge))" : "+ OneDrive")
                    }
                    .font(.inter(11, .medium))
                    .foregroundColor(store.connectedCloudServices.contains("onedrive") ? SolTokens.lav400 : SolTokens.ink700)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SolTokens.paper100)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation {
                        if store.connectedCloudServices.contains("gdrive") {
                            _ = store.connectedCloudServices.remove("gdrive")
                        } else {
                            store.connectedCloudServices.insert("gdrive")
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "externaldrive")
                        Text(store.connectedCloudServices.contains("gdrive") ? "Google Drive (\(store.l10n.connectedBadge))" : "+ Google Drive")
                    }
                    .font(.inter(11, .medium))
                    .foregroundColor(store.connectedCloudServices.contains("gdrive") ? SolTokens.green800 : SolTokens.ink700)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SolTokens.paper100)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation {
                        if store.connectedCloudServices.contains("dropbox") {
                            _ = store.connectedCloudServices.remove("dropbox")
                        } else {
                            store.connectedCloudServices.insert("dropbox")
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "shippingbox")
                        Text(store.connectedCloudServices.contains("dropbox") ? "Dropbox (\(store.l10n.connectedBadge))" : "+ Dropbox")
                    }
                    .font(.inter(11, .medium))
                    .foregroundColor(store.connectedCloudServices.contains("dropbox") ? SolTokens.green800 : SolTokens.ink700)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SolTokens.paper100)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var reassuranceBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 16))
                .foregroundColor(SolTokens.green800)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(store.l10n.reassuranceTitle)
                    .font(.inter(12.5, .medium))
                    .foregroundColor(SolTokens.ink900)
                Text(store.l10n.reassuranceBreakdown)
                    .font(.inter(11))
                    .foregroundColor(SolTokens.ink450)
            }
            
            Spacer()
            
            Button {
                store.activeNav = "hub"
            } label: {
                HStack(spacing: 4) {
                    Text(store.l10n.reassuranceButton)
                    Image(systemName: "arrow.right")
                }
                .font(.inter(11.5, .semibold))
                .foregroundColor(SolTokens.lav400)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(SolTokens.paper200)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }

    // MARK: - Register Table View & Filter Helpers
    private var filteredEmployees: [Employee] {
        let all = store.currentScenario.employees
        return all.filter { emp in
            let matchesSearch: Bool
            if employeeSearchText.trimmingCharacters(in: .whitespaces).isEmpty {
                matchesSearch = true
            } else {
                let query = employeeSearchText.lowercased()
                matchesSearch = emp.name.lowercased().contains(query) ||
                    emp.role.lowercased().contains(query) ||
                    emp.department.lowercased().contains(query) ||
                    emp.id.contains(query)
            }
            
            let matchesFilter: Bool
            let hasIssue = (emp.status != .ok || emp.statusLabel.contains("Mangler") || emp.statusLabel.contains("Saknar") || emp.statusLabel.contains("Missing"))
            switch employeeStatusFilter {
            case "issues":
                matchesFilter = hasIssue
            case "ok":
                matchesFilter = !hasIssue
            default:
                matchesFilter = true
            }
            
            return matchesSearch && matchesFilter
        }
    }
    
    private func filterPill(id: String, label: String, count: Int, dotColor: Color?) -> some View {
        let isSelected = employeeStatusFilter == id
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                employeeStatusFilter = id
            }
        } label: {
            HStack(spacing: 5) {
                if let dot = dotColor {
                    Circle()
                        .fill(dot)
                        .frame(width: 5.5, height: 5.5)
                }
                Text(label)
                    .font(.inter(11.5, isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? SolTokens.ink900 : SolTokens.ink600)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(isSelected ? SolTokens.paper200 : Color.clear)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? SolTokens.paper300 : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("filter_\(id)")
    }

    // MARK: - Register Table & Directory Subviews

    @ViewBuilder
    private var registerToastView: some View {
        if let toast = store.rosterUploadToast {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(SolTokens.green800)
                Text(toast)
                    .font(.inter(12.5, .medium))
                    .foregroundColor(SolTokens.ink900)
                Spacer()
                Button {
                    withAnimation { store.rosterUploadToast = nil }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SolTokens.ink600)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(SolTokens.green800.opacity(0.12))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.green800.opacity(0.3), lineWidth: 1))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var registerHeaderView: some View {
        let totalCount = store.currentScenario.employees.count
        let issuesCount = store.currentScenario.employees.filter { $0.status != .ok || $0.statusLabel.contains("Mangler") || $0.statusLabel.contains("Saknar") || $0.statusLabel.contains("Missing") }.count
        let okCount = max(0, totalCount - issuesCount)
        
        return HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(store.l10n.navRegister)
                    .font(.inter(17, .bold))
                    .foregroundColor(SolTokens.ink900)
                
                HStack(spacing: 8) {
                    Text("\(totalCount) \(store.l10n.staffCountLabel)")
                        .font(.inter(12.5, .medium))
                        .foregroundColor(SolTokens.ink600)
                    Text("·")
                        .foregroundColor(SolTokens.ink450)
                    HStack(spacing: 4) {
                        Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                        Text("\(okCount) \(store.l10n.directoryCompliantSummary)")
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.ink700)
                    }
                    if issuesCount > 0 {
                        Text("·")
                            .foregroundColor(SolTokens.ink450)
                        HStack(spacing: 4) {
                            Circle().fill(SolTokens.amber400).frame(width: 5, height: 5)
                            Text("\(issuesCount) \(store.l10n.directoryIssuesSummary)")
                                .font(.inter(12, .medium))
                                .foregroundColor(SolTokens.amber400)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    store.rosterUploadToast = store.l10n.rosterUploadedBanner
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.inter(11))
                    Text(store.l10n.uploadRosterButton)
                }
                .font(.inter(12, .medium))
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(SolTokens.paper100)
                .foregroundColor(SolTokens.ink900)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 2)
    }

    private var registerFilterBar: some View {
        let totalCount = store.currentScenario.employees.count
        let issuesCount = store.currentScenario.employees.filter { $0.status != .ok || $0.statusLabel.contains("Mangler") || $0.statusLabel.contains("Saknar") || $0.statusLabel.contains("Missing") }.count
        let okCount = max(0, totalCount - issuesCount)
        
        return HStack(spacing: 10) {
            HStack(spacing: 4) {
                filterPill(id: "all", label: "\(store.l10n.filterAll) (\(totalCount))", count: totalCount, dotColor: nil)
                filterPill(id: "issues", label: "\(store.l10n.filterIssues) (\(issuesCount))", count: issuesCount, dotColor: SolTokens.amber400)
                filterPill(id: "ok", label: "\(store.l10n.filterCompliant) (\(okCount))", count: okCount, dotColor: SolTokens.green800)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(SolTokens.ink450)
                TextField(store.l10n.searchEmployeePlaceholder, text: $employeeSearchText)
                    .textFieldStyle(.plain)
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink900)
                    .accessibilityIdentifier("search_employee_field")
                if !employeeSearchText.isEmpty {
                    Button {
                        employeeSearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(SolTokens.ink450)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .frame(maxWidth: 240)
            .background(SolTokens.paper100)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
        }
        .padding(.horizontal, 2)
    }

    private var registerTableHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 5) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 9))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colEmployee)
            }
            .frame(width: 200, alignment: .leading)
            
            HStack(spacing: 5) {
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colRoleDept)
            }
            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 5) {
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colSalary)
            }
            .frame(width: 95, alignment: .leading)
            
            HStack(spacing: 5) {
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colStatus)
            }
            .frame(minWidth: 160, maxWidth: 210, alignment: .leading)
            
            Text(store.l10n.colAction)
                .frame(width: 98, alignment: .trailing)
        }
        .font(.system(size: 11, weight: .semibold, design: .monospaced))
        .foregroundColor(SolTokens.ink450)
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(SolTokens.paper100)
    }

    private func registerEmployeeRow(emp: Employee) -> some View {
        let isEmployeeOk = emp.status == .ok && !(emp.statusLabel.contains("Mangler") || emp.statusLabel.contains("Saknar") || emp.statusLabel.contains("Missing"))
        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Name & Linear Multi-Color Avatar Badge
                HStack(spacing: 10) {
                    LinearAvatarBadge(name: emp.name, size: 26)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(emp.name)
                            .font(.inter(13.5, .semibold))
                            .foregroundColor(SolTokens.ink900)
                        Text("\(store.l10n.startedPrefix) \(emp.startDate)")
                            .font(.inter(11))
                            .foregroundColor(SolTokens.ink600)
                    }
                }
                .frame(width: 200, alignment: .leading)
                
                // Role & Department
                HStack(spacing: 6) {
                    Text(store.l10n.localizedRole(emp.role))
                        .font(.inter(12.5))
                        .foregroundColor(SolTokens.ink700)
                        .lineLimit(1)
                    Text(store.l10n.localizedDepartment(emp.department))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper250)
                        .cornerRadius(3)
                }
                .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                
                // Salary
                Text("\(emp.salary) \(store.l10n.currencyUnit)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(SolTokens.ink700)
                    .frame(width: 95, alignment: .leading)
                
                // Status: Linear Capsule Pill with Colored Micro-Dot (Calm Neutral Text)
                HStack {
                    if isEmployeeOk {
                        LinearStatusPill(
                            text: store.l10n.statusCompliantShort,
                            dotColor: SolTokens.emerald800
                        )
                    } else {
                        let isVarsel = emp.statusLabel.contains("Varsel")
                        LinearStatusPill(
                            text: localizedShortStatus(for: emp, l10n: store.l10n),
                            dotColor: isVarsel ? SolTokens.coral700 : SolTokens.amber400
                        )
                    }
                }
                .frame(minWidth: 160, maxWidth: 210, alignment: .leading)
                
                // Inspect Button
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        expandedEmployeeRowId = (expandedEmployeeRowId == emp.id ? nil : emp.id)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(store.l10n.inspectButton)
                            .lineLimit(1)
                        Image(systemName: expandedEmployeeRowId == emp.id ? "chevron.up" : "chevron.down")
                            .font(.inter(9))
                    }
                    .font(.inter(11.5, .medium))
                    .foregroundColor(expandedEmployeeRowId == emp.id ? SolTokens.ink900 : SolTokens.ink700)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4.5)
                    .background(expandedEmployeeRowId == emp.id ? SolTokens.paper250 : SolTokens.paper200)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(expandedEmployeeRowId == emp.id ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .frame(width: 98, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // In-place Expandable Inspection Drawer
            if expandedEmployeeRowId == emp.id {
                inlineRowDiffView(for: emp)
                    .clipped()
                    .transition(.linearAccordion)
            }
            
            Divider()
                .overlay(SolTokens.paper300.opacity(0.5))
        }
    }

    private var registerTableContent: some View {
        VStack(spacing: 0) {
            registerTableHeader
            
            Divider()
                .overlay(SolTokens.paper300)
            
            ScrollView {
                VStack(spacing: 0) {
                    if filteredEmployees.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 24))
                                .foregroundColor(SolTokens.ink450)
                                .padding(.top, 30)
                            Text(store.l10n.noEmployeesMatchFilter)
                                .font(.inter(13, .medium))
                                .foregroundColor(SolTokens.ink700)
                            Button(store.l10n.resetFilterButton) {
                                employeeSearchText = ""
                                employeeStatusFilter = "all"
                            }
                            .font(.inter(11.5, .semibold))
                            .foregroundColor(SolTokens.lav400)
                            .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(filteredEmployees) { emp in
                            registerEmployeeRow(emp: emp)
                        }
                    }
                }
            }
        }
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SolTokens.paper300, lineWidth: 1)
        )
    }

    private var registerUpsellBar: some View {
        let scenario = store.l10n.scenarios[store.currentYear]
        let upsellProduct = scenario?.upsellProduct ?? store.currentScenario.recommendedUpsell.product
        let upsellTitle = scenario?.upsellTitle ?? store.currentScenario.recommendedUpsell.title
        let upsellBenefit = scenario?.upsellBenefit ?? store.currentScenario.recommendedUpsell.benefit
        
        return HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundColor(SolTokens.lav500)
                .font(.inter(15))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(store.l10n.upsellPrefix): \(upsellProduct)")
                    .font(.inter(12.5, .bold))
                    .foregroundColor(SolTokens.lav400)
                Text("\(upsellTitle) · \(upsellBenefit)")
                    .font(.inter(11.5))
                    .foregroundColor(SolTokens.ink700)
            }
            Spacer()
            Button(store.l10n.activateModule) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    store.activeNav = "hub"
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(SolTokens.plum900)
            .font(.inter(12, .semibold))
        }
        .padding(14)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SolTokens.paper300, lineWidth: 1)
        )
    }

    private var macRegisterTableView: some View {
        VStack(spacing: 14) {
            registerToastView
            registerHeaderView
            registerFilterBar
            registerTableContent
            registerUpsellBar
        }
        .padding(16)
    }
}

fileprivate func localizedStatus(for emp: Employee, l10n: LocalizedStrings) -> String {
    switch emp.status {
    case .ok:
        if emp.statusLabel.contains("BankID") {
            return l10n.statusCompliant
        } else if emp.statusLabel.contains("AMU") {
            return l10n.statusAmuProtocol
        } else if emp.statusLabel.contains("Mangler") || emp.statusLabel.contains("Saknar") || emp.statusLabel.contains("Missing") {
            return l10n.statusHmsNeeded
        }
        return l10n.statusOk
    case .aml14Gap:
        if emp.statusLabel.contains("provisjon") || emp.statusLabel.contains("kompetanse") {
            return l10n.statusMissingCompetence
        } else if emp.id == "35" {
            return l10n.statusDismissalDefenseNeeded
        }
        return l10n.statusIllegalOvertime
    case .sickD14:
        return l10n.statusSickDay14
    case .probationSoon:
        return l10n.statusProbationExpiring
    }
}

fileprivate func localizedShortStatus(for emp: Employee, l10n: LocalizedStrings) -> String {
    switch emp.status {
    case .ok:
        if emp.statusLabel.contains("Mangler") || emp.statusLabel.contains("Saknar") || emp.statusLabel.contains("Missing") {
            return l10n.statusMissingHmsShort
        }
        return l10n.statusCompliantShort
    case .aml14Gap:
        if emp.statusLabel.contains("provisjon") || emp.statusLabel.contains("kompetanse") {
            return l10n.statusCompetenceShort
        } else if emp.id == "35" {
            return l10n.statusDismissalDefenseNeeded
        }
        return l10n.statusUpdateContract
    case .sickD14:
        return l10n.statusSickDay14
    case .probationSoon:
        return l10n.statusProbationExpiring
    }
}

// MARK: - Native Sidebar Button Helper (Linear-Style Pill, Soft Outlines & Colored Framed Chips)
struct SidebarButton: View {
    enum BadgeStyle {
        case neutral
        case alert
        case dot
    }
    
    let id: String
    let label: String
    let icon: String
    var badge: String? = nil
    var badgeStyle: BadgeStyle = .neutral
    let activeNav: String
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            let active = activeNav == id
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(active ? Color.white : (isHovered ? SolTokens.ink900 : SolTokens.ink450))
                    .frame(width: 18, alignment: .center)
                Text(label)
                    .font(.inter(13, active ? .semibold : .medium))
                    .foregroundColor(active ? Color.white : (isHovered ? SolTokens.ink900 : SolTokens.ink700))
                    .lineLimit(1)
                Spacer()
                if badgeStyle == .dot {
                    Circle()
                        .fill(SolTokens.green800)
                        .frame(width: 5.5, height: 5.5)
                        .padding(.trailing, 2)
                } else if let b = badge {
                    Text(b)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(badgeStyle == .alert ? SolTokens.amber400 : (active ? SolTokens.ink700 : SolTokens.ink600))
                        .padding(.horizontal, 5.5)
                        .padding(.vertical, 1.5)
                        .background(badgeStyle == .alert ? SolTokens.amber100 : (active ? SolTokens.paper250 : SolTokens.paper200))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(badgeStyle == .alert ? SolTokens.amberBorder : SolTokens.paper300, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6.5)
            .background(active ? SolTokens.sidebarActivePill : (isHovered ? SolTokens.paper200.opacity(0.6) : Color.clear))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Resizable Sidebar Handle (Linear / macOS Native Style)

struct SidebarResizeHandle: View {
    @Binding var sidebarWidth: Double
    let minWidth: Double
    let maxWidth: Double
    let defaultWidth: Double
    
    @State private var isHovering: Bool = false
    @State private var isDragging: Bool = false
    @State private var hasPushedCursor: Bool = false
    @State private var dragInitialWidth: Double? = nil
    
    private func updateCursor(active: Bool) {
        if active && !hasPushedCursor {
            NSCursor.resizeLeftRight.push()
            hasPushedCursor = true
        } else if !active && hasPushedCursor {
            NSCursor.pop()
            hasPushedCursor = false
        }
    }
    
    var body: some View {
        ZStack {
            // Invisible wider hit-testing zone (8pt)
            Rectangle()
                .fill(Color.clear)
                .frame(width: 8)
                .contentShape(Rectangle())
            
            // Linear 1.5px tactile highlight line
            Rectangle()
                .fill(
                    isDragging
                        ? SolTokens.lav500
                        : (isHovering ? SolTokens.lav400.opacity(0.85) : Color.clear)
                )
                .frame(width: 1.5)
                .animation(.easeOut(duration: 0.15), value: isHovering)
                .animation(.easeOut(duration: 0.15), value: isDragging)
        }
        .frame(width: 8)
        .onHover { hovering in
            isHovering = hovering
            updateCursor(active: hovering || isDragging)
        }
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .global)
                .onChanged { gesture in
                    if dragInitialWidth == nil {
                        dragInitialWidth = sidebarWidth
                        isDragging = true
                        updateCursor(active: true)
                    }
                    let newWidth = (dragInitialWidth ?? defaultWidth) + Double(gesture.translation.width)
                    sidebarWidth = min(max(newWidth, minWidth), maxWidth)
                }
                .onEnded { _ in
                    dragInitialWidth = nil
                    isDragging = false
                    if !isHovering {
                        updateCursor(active: false)
                    }
                }
        )
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    sidebarWidth = defaultWidth
                }
            }
        )
        .onDisappear {
            updateCursor(active: false)
        }
    }
}

// MARK: - In-Place Full-in, Full-Out Inline Compliance Views
extension MacMainView {
    // 1. Contracts Redline Diff View (AML § 14-6)
    var inlineContractsDiffView: some View {
        let unapprovedEmployees = store.currentScenario.employees.filter { $0.status == .aml14Gap }
        let currentEmp = selectedDiffEmployee ?? unapprovedEmployees.first ?? store.currentScenario.employees[0]
        
        return VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(SolTokens.paper300)
            
            // Header with Employee name and role
            HStack(spacing: 8) {
                Text(currentEmp.name)
                    .font(.inter(14.5, .bold))
                    .foregroundColor(SolTokens.ink900)
                Text("•")
                    .foregroundColor(SolTokens.ink450)
                Text(currentEmp.role)
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink600)
                Spacer()
            }
            
            // Employee Selector Chips (Multi-employee browsing)
            if !unapprovedEmployees.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(unapprovedEmployees) { emp in
                            let isSelected = currentEmp.id == emp.id
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    selectedDiffEmployee = emp
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(isSelected ? SolTokens.lav400 : SolTokens.paper400)
                                        .frame(width: 5, height: 5)
                                    Text(emp.name)
                                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? SolTokens.ink900 : SolTokens.ink700)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(isSelected ? SolTokens.paper200 : SolTokens.paper100)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isSelected ? SolTokens.lav600.opacity(0.5) : SolTokens.paper300, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Side-by-Side Redline Diff
            HStack(alignment: .top, spacing: 14) {
                // Outdated (Current)
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.l10n.diffCurrentLabel)
                        .font(.inter(12, .bold))
                        .foregroundColor(SolTokens.red700)
                    
                    Text(store.l10n.diffCurrentClause)
                        .font(.system(size: 11.5, design: .monospaced))
                        .foregroundColor(SolTokens.ink700)
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(SolTokens.red100.opacity(0.4))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.redBorder, lineWidth: 1))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(12)
                .background(SolTokens.paper100)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                
                // Compliant (AML § 14-6)
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.l10n.diffCompliantLabel)
                        .font(.inter(12, .bold))
                        .foregroundColor(SolTokens.green800)
                    
                    Text(store.l10n.diffCompliantClause)
                        .font(.system(size: 11.5, design: .monospaced))
                        .foregroundColor(SolTokens.ink700)
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(SolTokens.green100.opacity(0.4))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.greenBorder, lineWidth: 1))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(12)
                .background(SolTokens.paper100)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
            }
            .fixedSize(horizontal: false, vertical: true)
            
            // Footer Action Bar
            HStack {
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        store.approveContract(for: currentEmp.id)
                        let remaining = store.currentScenario.employees.filter { $0.status == .aml14Gap }
                        if let next = remaining.first {
                            selectedDiffEmployee = next
                        } else {
                            expandedHubCard = nil
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "signature")
                            .font(.inter(11))
                        Text(store.l10n.diffApproveButton)
                            .font(.inter(12, .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(SolTokens.plum900)
                    .foregroundColor(SolTokens.lav50)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }
    
    // 2. Verneombud In-Place View (AML § 6-1)
    var inlineVerneombudView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(SolTokens.paper300)
            
            // Candidates
            VStack(spacing: 8) {
                CandidateRowInline(name: "Sofie Hagen", role: "Lead Designer & UX", votes: store.verneombudElectionActive ? 6 : 0, total: 8, isLeading: true, l10n: store.l10n)
                CandidateRowInline(name: "Magnus Teig", role: "Frontend Ingeniør", votes: store.verneombudElectionActive ? 2 : 0, total: 8, isLeading: false, l10n: store.l10n)
            }
            
            // Footer
            HStack {
                if !store.verneombudElectionActive {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.castVerneombudVote()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            if expandedHubCard == "verneombud" {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                    expandedHubCard = nil
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "envelope.badge.fill")
                            Text(store.l10n.voSendBallots)
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.plum900)
                        .foregroundColor(SolTokens.lav50)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.voSuccessTitle)
                            .font(.inter(12, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            expandedHubCard = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.l10n.close)
                            Image(systemName: "chevron.up")
                                .font(.inter(9))
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink900)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }
    
    // In-Place HMS Curriculum & Course Booking Drawer
    private var inlineHmsBookingView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(SolTokens.paper300)
            
            // Syllabus Section
            VStack(alignment: .leading, spacing: 8) {
                Text(store.l10n.hubHmsCurriculumHeader)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundColor(SolTokens.ink600)
                    .tracking(0.5)
                
                VStack(spacing: 6) {
                    hmsModuleRow(number: "1", title: store.l10n.hubHmsModule1)
                    hmsModuleRow(number: "2", title: store.l10n.hubHmsModule2)
                    hmsModuleRow(number: "3", title: store.l10n.hubHmsModule3)
                    hmsModuleRow(number: "4", title: store.l10n.hubHmsModule4)
                }
            }
            
            // Order & Invoice Summary Box
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 13))
                            .foregroundColor(SolTokens.lav400)
                        Text(store.l10n.hubHmsDeliveryNotice)
                            .font(.inter(11.5, .medium))
                            .foregroundColor(SolTokens.ink700)
                    }
                    Text(store.l10n.hubHmsBillingTerms)
                        .font(.inter(11))
                        .foregroundColor(SolTokens.ink600)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(store.l10n.hubHmsPrice)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink900)
                    Text(store.l10n.hubHmsBillingTerms)
                        .font(.inter(10))
                        .foregroundColor(SolTokens.ink600)
                }
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        store.hmsTrainingEnrolled = true
                        expandedHubCard = nil
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .font(.inter(11))
                        Text(store.l10n.hubHmsConfirmOrderAction)
                            .font(.inter(12, .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(SolTokens.plum900)
                    .foregroundColor(SolTokens.lav50)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(SolTokens.paper200)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
        }
        .padding(.top, 4)
    }
    
    private func hmsModuleRow(number: String, title: String) -> some View {
        HStack(spacing: 9) {
            ZStack {
                Circle()
                    .fill(SolTokens.lav400.opacity(0.15))
                    .frame(width: 18, height: 18)
                Text(number)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(SolTokens.lav400)
            }
            Text(title)
                .font(.inter(12, .medium))
                .foregroundColor(SolTokens.ink700)
            Spacer()
            Text("E-learning")
                .font(.inter(10.5))
                .foregroundColor(SolTokens.ink450)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(SolTokens.paper100)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    // 3. Equal Pay Audit In-Place View
    var inlineEqualPayView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(SolTokens.paper300)
            
            // Categories breakdown
            VStack(spacing: 6) {
                HStack {
                    Text(store.l10n.equalPayCat1)
                        .font(.inter(11.5, .medium))
                        .foregroundColor(SolTokens.ink900)
                    Spacer()
                    Text(store.l10n.equalPayRatio1)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(SolTokens.ink700)
                    Text(store.l10n.equalPayStatusOk)
                        .font(.inter(9.5, .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(SolTokens.green100)
                        .foregroundColor(SolTokens.green800)
                        .cornerRadius(3)
                }
                .padding(8)
                .background(SolTokens.paper100)
                .cornerRadius(6)
                
                HStack {
                    Text(store.l10n.equalPayCat2)
                        .font(.inter(11.5, .medium))
                        .foregroundColor(SolTokens.ink900)
                    Spacer()
                    Text(store.l10n.equalPayRatio2)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(SolTokens.ink700)
                    Text(store.l10n.equalPayStatusOk)
                        .font(.inter(9.5, .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(SolTokens.green100)
                        .foregroundColor(SolTokens.green800)
                        .cornerRadius(3)
                }
                .padding(8)
                .background(SolTokens.paper100)
                .cornerRadius(6)
                
                HStack {
                    Text(store.l10n.equalPayCat3)
                        .font(.inter(11.5, .medium))
                        .foregroundColor(SolTokens.ink900)
                    Spacer()
                    Text(store.l10n.equalPayRatio3)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(SolTokens.red700)
                    Text(store.l10n.equalPayStatusAlert)
                        .font(.inter(9.5, .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(SolTokens.red100)
                        .foregroundColor(SolTokens.red700)
                        .cornerRadius(3)
                }
                .padding(8)
                .background(SolTokens.paper100)
                .cornerRadius(6)
            }
            
            // Footer
            HStack {
                if !store.equalPayReportGenerated {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.equalPayReportGenerated = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            if expandedHubCard == "equalPay" {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                    expandedHubCard = nil
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                            Text(store.l10n.equalPayGenerateButton)
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.plum900)
                        .foregroundColor(SolTokens.lav50)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.equalPaySuccessNotice)
                            .font(.inter(12, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            expandedHubCard = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.l10n.close)
                            Image(systemName: "chevron.up")
                                .font(.inter(9))
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink900)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }
    
    // 4. Sick Leave In-Place View
    var inlineSickLeaveView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(SolTokens.paper300)
            
            // 3-step Timeline
            VStack(spacing: 8) {
                TimelineStepRow(number: "1", title: store.l10n.sickMilestone1Title, time: store.l10n.sickMilestone1Sub, done: store.sickLeavePlanDispatched)
                TimelineStepRow(number: "2", title: store.l10n.sickMilestone2Title, time: store.l10n.sickMilestone2Sub, done: false)
                TimelineStepRow(number: "3", title: store.l10n.sickMilestone3Title, time: store.l10n.sickMilestone3Sub, done: false)
            }
            .padding(12)
            .background(SolTokens.paper100)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
            
            // Footer
            HStack {
                if !store.sickLeavePlanDispatched {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.sickLeavePlanDispatched = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            if expandedHubCard == "sickLeave" {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                    expandedHubCard = nil
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.plus")
                            Text(store.l10n.sickSendInvite)
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.plum900)
                        .foregroundColor(SolTokens.lav50)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.sickSuccessNotice)
                            .font(.inter(12, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            expandedHubCard = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.l10n.close)
                            Image(systemName: "chevron.up")
                                .font(.inter(9))
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink900)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }
    
    // 5. Dismissal Defense In-Place View
    var inlineDismissalDefenseView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(SolTokens.paper300)
            
            // Procedural Checklist
            VStack(spacing: 6) {
                DefenseStepRow(num: 1, title: store.l10n.defenseCheck1, done: true)
                DefenseStepRow(num: 2, title: store.l10n.defenseCheck2, done: true)
                DefenseStepRow(num: 3, title: store.l10n.defenseCheck3, done: store.juristHandoffCompleted)
            }
            .padding(12)
            .background(SolTokens.paper100)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
            
            // Footer
            HStack {
                if !store.juristHandoffCompleted {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.juristHandoffCompleted = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            if expandedHubCard == "defense" {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                    expandedHubCard = nil
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "scale.3d")
                            Text(store.l10n.defenseHandoffButton)
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.plum900)
                        .foregroundColor(SolTokens.lav50)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.defenseSuccessNotice)
                            .font(.inter(12, .semibold))
                            .foregroundColor(SolTokens.green800)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            expandedHubCard = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.l10n.close)
                            Image(systemName: "chevron.up")
                                .font(.inter(9))
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink900)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }
    
    // 6. In-Place Row Drawer for Employee Register
    @ViewBuilder
    func inlineRowDiffView(for emp: Employee) -> some View {
        let isHmsIssue = (emp.statusLabel.contains("Mangler") || emp.statusLabel.contains("Saknar") || emp.statusLabel.contains("Missing")) && (emp.statusLabel.contains("HMS") || emp.statusLabel.contains("SAM") || emp.statusLabel.contains("HSE") || emp.statusLabel.contains("OHS") || emp.id == "01")
        let isFullyCompliant = emp.status == .ok && !isHmsIssue
        
        VStack(alignment: .leading, spacing: 10) {
            if emp.status == .aml14Gap {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.badge.arrow.up")
                            .foregroundColor(SolTokens.ink600)
                            .font(.system(size: 13, weight: .semibold))
                        
                        Text(store.l10n.diffGapHeader)
                            .font(.inter(12.5, .bold))
                            .foregroundColor(SolTokens.ink900)
                        
                        Text(store.l10n.diffStatuteBadge)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink600)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SolTokens.paper200)
                            .cornerRadius(3)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(SolTokens.paper300, lineWidth: 1))
                        
                        Spacer()
                    }
                    
                    Text(store.l10n.diffGapSubline)
                        .font(.inter(11.5))
                        .foregroundColor(SolTokens.ink600)
                }
            } else if isFullyCompliant {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SolTokens.green800)
                    Text(store.l10n.diffCompliantHeader)
                        .font(.inter(12, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Spacer()
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(emp.status == .sickD14 ? SolTokens.amber400 : (isHmsIssue ? SolTokens.amber400 : SolTokens.red700))
                    Text(isHmsIssue ? store.l10n.diffHmsMissingHeader : (emp.status == .sickD14 ? store.l10n.diffSickHeader : store.l10n.diffDismissalHeader))
                        .font(.inter(12, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Spacer()
                }
            }
            
            if isHmsIssue {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(store.l10n.hubCardHmsStatute)
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink600)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(SolTokens.paper200)
                                .cornerRadius(3)
                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(SolTokens.paper300, lineWidth: 1))
                            Text(store.l10n.hubCardHmsTitle)
                                .font(.inter(12, .bold))
                                .foregroundColor(SolTokens.ink900)
                        }
                        
                        Text(store.l10n.diffHmsNotice)
                            .font(.inter(11.5))
                            .foregroundColor(SolTokens.ink700)
                            .lineSpacing(3)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SolTokens.paper100)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(SolTokens.amberBorder.opacity(0.8), lineWidth: 1)
                    )
                    
                    // Action Bar
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                store.enrollHmsCourse()
                                expandedEmployeeRowId = nil
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "graduationcap.fill")
                                Text(store.l10n.hubCardHmsAction)
                            }
                            .font(.inter(11.5, .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(SolTokens.plum900)
                            .foregroundColor(SolTokens.lav50)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else if emp.status == .aml14Gap {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.l10n.diffCurrentLabel)
                            .font(.inter(11, .bold))
                            .foregroundColor(SolTokens.red700)
                        Text(store.l10n.diffCurrentClause)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(SolTokens.ink700)
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .background(SolTokens.red100.opacity(0.4))
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.redBorder, lineWidth: 1))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                    .background(SolTokens.paper100)
                    .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.l10n.diffCompliantLabel)
                            .font(.inter(11, .bold))
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.diffCompliantClause)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(SolTokens.ink700)
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .background(SolTokens.green100.opacity(0.4))
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.greenBorder, lineWidth: 1))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                    .background(SolTokens.paper100)
                    .cornerRadius(6)
                }
                .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            store.approveContract(for: emp.id)
                            expandedEmployeeRowId = nil
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "signature")
                            Text(store.l10n.diffApproveButton)
                        }
                        .font(.inter(11.5, .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(SolTokens.plum900)
                        .foregroundColor(SolTokens.lav50)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            } else if emp.status == .sickD14 {
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.l10n.diffSickNotice(name: emp.name))
                        .font(.inter(11.5))
                        .foregroundColor(SolTokens.ink700)
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                store.sickLeavePlanDispatched = true
                                expandedEmployeeRowId = nil
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "calendar.badge.plus")
                                Text(store.l10n.sickSendInvite)
                            }
                            .font(.inter(11.5, .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(SolTokens.plum900)
                            .foregroundColor(SolTokens.lav50)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(SolTokens.paper200)
                .cornerRadius(6)
            } else if emp.id == "35" {
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.l10n.diffDismissalNotice)
                        .font(.inter(11.5))
                        .foregroundColor(SolTokens.ink700)
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                                store.juristHandoffCompleted = true
                                expandedEmployeeRowId = nil
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "scale.3d")
                                Text(store.l10n.defenseHandoffButton)
                            }
                            .font(.inter(11.5, .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(SolTokens.plum900)
                            .foregroundColor(SolTokens.lav50)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(SolTokens.paper200)
                .cornerRadius(6)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(SolTokens.green800)
                        .font(.inter(12))
                    Text(store.l10n.diffCompliantNotice)
                        .font(.inter(11.5))
                        .foregroundColor(SolTokens.green800)
                    Spacer()
                }
                .padding(10)
                .background(SolTokens.green100)
                .cornerRadius(6)
            }
        }
        .padding(12)
        .background(SolTokens.paper100)
        .overlay(Rectangle().frame(height: 1).foregroundColor(SolTokens.paper300), alignment: .top)
    }
}

// MARK: - Supporting Row Types
private struct CandidateRowInline: View {
    let name: String
    let role: String
    let votes: Int
    let total: Int
    let isLeading: Bool
    let l10n: LocalizedStrings
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(SolTokens.paper300)
                .frame(width: 28, height: 28)
                .overlay(Text(String(name.prefix(1))).font(.inter(12, .bold)).foregroundColor(SolTokens.lav400))
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.inter(12.5, .semibold))
                    .foregroundColor(SolTokens.ink900)
                Text(role)
                    .font(.inter(10.5))
                    .foregroundColor(SolTokens.ink600)
            }
            Spacer()
            if votes > 0 {
                HStack(spacing: 6) {
                    Text("\(votes)/\(total)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(isLeading ? SolTokens.green800 : SolTokens.ink700)
                    if isLeading {
                        Text("Flertall")
                            .font(.inter(9.5, .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(SolTokens.green100)
                            .foregroundColor(SolTokens.green800)
                            .cornerRadius(3)
                    }
                }
            }
        }
        .padding(10)
        .background(SolTokens.paper100)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
    }
}

private struct TimelineStepRow: View {
    let number: String
    let title: String
    let time: String
    let done: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(done ? SolTokens.green100 : SolTokens.paper300)
                    .frame(width: 22, height: 22)
                if done {
                    Image(systemName: "checkmark")
                        .font(.inter(10, .bold))
                        .foregroundColor(SolTokens.green800)
                } else {
                    Text(number)
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink700)
                }
            }
            Text(title)
                .font(.inter(12, .medium))
                .foregroundColor(done ? SolTokens.ink600 : SolTokens.ink900)
            Spacer()
            Text(time)
                .font(.system(size: 10.5, design: .monospaced))
                .foregroundColor(SolTokens.ink450)
        }
        .padding(.vertical, 4)
    }
}

private struct DefenseStepRow: View {
    let num: Int
    let title: String
    let done: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundColor(done ? SolTokens.green800 : SolTokens.ink450)
                .font(.inter(13))
            Text("\(num). \(title)")
                .font(.inter(12, .medium))
                .foregroundColor(done ? SolTokens.ink900 : SolTokens.ink600)
            Spacer()
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Dedicated Demo Controls Popover (Behind-the-Scenes Scaffolding)
struct DemoControlsPopover: View {
    @ObservedObject var store: ComplyStore
    @ObservedObject var autoplay: AutoplayController
    @Binding var isPresented: Bool
    var onExpandCard: ((String?) -> Void)? = nil
    var onReset: (() -> Void)? = nil
    
    var body: some View {
        let l10n = store.l10n
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.2.square")
                        .foregroundColor(SolTokens.lav400)
                        .font(.inter(11, .semibold))
                    Text(l10n.demoControllerTitle)
                        .font(.inter(11, .bold))
                        .foregroundColor(SolTokens.ink900)
                }
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.inter(9, .bold))
                        .foregroundColor(SolTokens.ink450)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .overlay(SolTokens.paper300)
            
            // Section 1: Timeline Episodes
            VStack(alignment: .leading, spacing: 6) {
                Text(l10n.demoTimelineHeader)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
                
                VStack(spacing: 4) {
                    ForEach(CompanyYear.allCases) { yr in
                        let active = store.currentYear == yr
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                store.setYear(yr)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(active ? SolTokens.lav500 : SolTokens.paper400)
                                    .frame(width: 5, height: 5)
                                
                                Text(yr == .y2024 ? l10n.year1Label : (yr == .y2025 ? l10n.year2Label : l10n.year4Label))
                                    .font(.system(size: 11, weight: active ? .semibold : .medium))
                                    .foregroundColor(active ? SolTokens.ink900 : SolTokens.ink700)
                                
                                Text(yr == .y2024 ? l10n.staff8 : (yr == .y2025 ? l10n.staff38 : l10n.staff124))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(active ? SolTokens.lav400 : SolTokens.ink450)
                                
                                Spacer()
                                
                                if active {
                                    Image(systemName: "checkmark")
                                        .font(.inter(9, .bold))
                                        .foregroundColor(SolTokens.lav400)
                                }
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(active ? SolTokens.paper200 : Color.clear)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(active ? SolTokens.lav600.opacity(0.4) : SolTokens.paper300, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Divider()
                .overlay(SolTokens.paper300)
            
            // Section 2: Autoplay
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(l10n.demoAutoplayHeader)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                    Spacer()
                    Text("⌘P")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                }
                
                Button {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if autoplay.isPlaying {
                            autoplay.stopDemo { card in
                                onExpandCard?(card)
                            }
                        } else {
                            autoplay.startDemo(store: store) { card in
                                onExpandCard?(card)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: autoplay.isPlaying ? "stop.fill" : "play.fill")
                            .font(.inter(9))
                        Text(autoplay.isPlaying ? "\(l10n.autoplayStop) (\(autoplay.currentStepIndex + 1)/\(autoplay.totalSteps))" : l10n.autoplayStart)
                            .font(.inter(11, .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(autoplay.isPlaying ? SolTokens.red100 : SolTokens.plum900)
                    .foregroundColor(autoplay.isPlaying ? SolTokens.red700 : SolTokens.lav50)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(autoplay.isPlaying ? SolTokens.redBorder : SolTokens.lav600.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .overlay(SolTokens.paper300)
            
            // Section 3: Sync & Reset
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(SolTokens.green800)
                        .frame(width: 5, height: 5)
                    Text(l10n.demoSyncActive)
                        .font(.inter(9))
                        .foregroundColor(SolTokens.ink600)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                        store.resetDemoState()
                        onReset?()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.inter(8))
                        Text(l10n.demoResetButton)
                            .font(.inter(9, .medium))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3.5)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(SolTokens.paper300, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(width: 250)
        .background(SolTokens.paper50)
    }
}

// MARK: - Linear Craft Helper Cards
struct HandbookChapterCard: View {
    let chapterNumber: String
    let title: String
    let statute: String
    let statusText: String
    let statusColor: Color
    let statusBg: Color
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Text("\(ComplyStore.shared.l10n.chapterPrefix) \(chapterNumber)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink600)
                        .cornerRadius(4)
                    
                    Text(statute)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                }
                
                Spacer()
                
                LinearStatusPill(
                    text: statusText,
                    dotColor: statusColor,
                    bgColor: statusBg,
                    borderColor: statusColor.opacity(0.3),
                    textColor: statusColor
                )
            }
            
            Text(title)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(summary)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2.5)
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
}

struct RadarThresholdCard: View {
    let threshold: String
    let statute: String
    let title: String
    let statusText: String
    let statusColor: Color
    let statusBg: Color
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Text(threshold)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink700)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                    Text(statute)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                }
                Spacer()
                LinearStatusPill(
                    text: statusText,
                    dotColor: statusColor
                )
            }
            Text(title)
                .font(.inter(14.5, .bold))
                .foregroundColor(SolTokens.ink900)
            Text(description)
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2.5)
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
}

struct AIToolChip: View {
    let name: String
    let vendor: String
    let status: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                Text(name)
                    .font(.inter(11, .semibold))
                    .foregroundColor(SolTokens.ink900)
            }
            Text("\(vendor) · \(status)")
                .font(.inter(10))
                .foregroundColor(SolTokens.ink600)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(SolTokens.paper250)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
    }
}

struct SiaTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.inter(11.5, isSelected ? .bold : .medium))
                .padding(.horizontal, 9)
                .padding(.vertical, 4.5)
                .background(isSelected ? SolTokens.sidebarActivePill : Color.clear)
                .foregroundColor(isSelected ? Color.white : SolTokens.ink600)
                .cornerRadius(5)
        }
        .buttonStyle(.plain)
    }
}

struct TimelineMilestoneCard: View {
    let milestone: String
    let title: String
    let desc: String
    let isUpcoming: Bool
    let daysRemaining: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(milestone)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundColor(SolTokens.lav400)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(SolTokens.lav400.opacity(0.12))
                    .cornerRadius(4)
                Spacer()
                Text(daysRemaining)
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundColor(isUpcoming ? SolTokens.amber400 : SolTokens.ink600)
            }
            Text(title)
                .font(.inter(12.5, .bold))
                .foregroundColor(SolTokens.ink900)
            Text(desc)
                .font(.inter(11))
                .foregroundColor(SolTokens.ink700)
                .lineLimit(2)
        }
        .padding(10)
        .background(SolTokens.paper250)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
}


// MARK: - Linear-Grade Accordion Transitions

extension AnyTransition {
    /// Linear-grade accordion disclosure transition:
    /// - On expand (insertion): Container expands downward first; content waits with 60ms delay
    ///   before smoothly fading in over 220ms and settling down 8pt.
    /// - On collapse (removal): Content immediately fades out over 120ms with a gentle 4pt upward drift,
    ///   allowing the container to smoothly fold shut without clipping or squishing visible text.
    static var linearAccordion: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .animation(.easeInOut(duration: 0.22).delay(0.06))
                .combined(with: .offset(y: -8))
                .combined(with: .scale(scale: 0.995, anchor: .top)),
            removal: .opacity
                .animation(.easeOut(duration: 0.12))
                .combined(with: .offset(y: -4))
                .combined(with: .scale(scale: 0.995, anchor: .top))
        )
    }
    
    /// Linear / Apple-grade card completion and vanish transition:
    /// Smoothly fades out and scales slightly while the container collapses.
    static var cardVanishTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
            removal: .opacity
                .animation(.easeOut(duration: 0.25))
                .combined(with: .scale(scale: 0.98, anchor: .top))
                .combined(with: .offset(y: -6))
        )
    }
}

struct CloudConnectorCard: View {
    let name: String
    let domain: String
    let folderScope: String
    let iconName: String
    let accentColor: Color
    let isConnected: Bool
    let fileCountText: String
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(accentColor.opacity(0.14))
                        .frame(width: 30, height: 30)
                    Image(systemName: iconName)
                        .font(.system(size: 14))
                        .foregroundColor(accentColor)
                }
                
                Spacer()
                
                Button(action: onToggle) {
                    HStack(spacing: 4) {
                        if isConnected {
                            Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                            Text("Tilkoblet")
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(SolTokens.green800)
                        } else {
                            Text("Koble til")
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(SolTokens.lav400)
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3.5)
                    .background(isConnected ? SolTokens.green800.opacity(0.12) : SolTokens.lav400.opacity(0.12))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.inter(13, .bold))
                    .foregroundColor(SolTokens.ink900)
                Text(isConnected ? fileCountText : domain)
                    .font(.inter(11))
                    .foregroundColor(SolTokens.ink600)
            }
            
            HStack(spacing: 4) {
                Text("Mappe:")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
                Text(folderScope)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(SolTokens.ink700)
            }
        }
        .padding(12)
        .background(SolTokens.paper200)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isConnected ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
    }
}

struct LocalGuardedFolderRow: View {
    let path: String
    let description: String
    let fileCount: Int
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(SolTokens.paper300)
                    .frame(width: 32, height: 32)
                Image(systemName: "folder.fill")
                    .font(.system(size: 14))
                    .foregroundColor(SolTokens.lav400)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(path)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink900)
                    Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                    Text("Aktiv vakt")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(SolTokens.green800)
                }
                Text(description)
                    .font(.inter(11))
                    .foregroundColor(SolTokens.ink600)
            }
            
            Spacer()
            
            Text("\(fileCount) filer")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(SolTokens.ink600)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(SolTokens.paper250)
                .cornerRadius(4)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(SolTokens.ink450)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(SolTokens.paper200)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
}

struct DocumentVaultCategoryCard: View {
    let icon: String
    let title: String
    let countText: String
    let status: String
    let statusColor: Color
    let statusBg: Color
    let actionLabel: String
    let onAction: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(statusBg)
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.inter(13, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text("· \(countText)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                }
                Text(status)
                    .font(.inter(11.5))
                    .foregroundColor(SolTokens.ink700)
            }
            
            Spacer()
            
            Button(action: onAction) {
                HStack(spacing: 4) {
                    Text(actionLabel)
                    Image(systemName: "arrow.up.right")
                }
                .font(.inter(11.5, .medium))
                .foregroundColor(SolTokens.lav400)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(SolTokens.paper250)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(SolTokens.paper200)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
}

// MARK: - Official Compliance Audit Certificate Modal (Tilsynsbevis)

struct AuditReportModalView: View {
    @ObservedObject var store: ComplyStore
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.70)
                .ignoresSafeArea()
                .onTapGesture {
                    store.showAuditReportSheet = false
                }
            
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(SolTokens.green100)
                            .frame(width: 42, height: 42)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundColor(SolTokens.green800)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.l10n.auditCertificateTitle)
                            .font(.inter(15, .bold))
                            .foregroundColor(SolTokens.ink900)
                        Text(store.l10n.auditCertificateSubtitle)
                            .font(.inter(12))
                            .foregroundColor(SolTokens.ink600)
                    }
                    
                    Spacer()
                    
                    Button {
                        store.showAuditReportSheet = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(SolTokens.ink450)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                
                Divider()
                    .background(SolTokens.paper300)
                
                // Body Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Metadata Box
                        VStack(spacing: 8) {
                            auditMetaRow(label: "Företag / Org:", value: "Fjord Dynamics AS (923 456 789)")
                            auditMetaRow(label: "Jurisdiktion:", value: "Norge & Sverige (Arbeidsmiljøloven / LAS)")
                            auditMetaRow(label: "Status:", value: "10 av 10 lagkrav säkrade (100 %) · Aktiv Radar", isHighlight: true)
                            auditMetaRow(label: "BankID Stämpel:", value: "BankID SHA-256: 8f94-c012-e5b7-9941")
                            auditMetaRow(label: "Utfärdat av:", value: "Simployer Continuous Legal Engine v4.2")
                        }
                        .padding(14)
                        .background(SolTokens.paper100)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                        
                        // Audited Requirements Checklist
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REVIDERADE OCH SKYDDADE OMRÅDEN")
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                            
                            VStack(spacing: 6) {
                                auditChecklistItem(statute: "AML § 14-6", title: "Anställningsavtal reviderade", detail: "8 av 8 avtal säkrade med lagstadgade klausuler")
                                auditChecklistItem(statute: "AML § 6-1", title: "Skyddsombudsval genomfört", detail: "Digital omröstning klar och protokollförd")
                                auditChecklistItem(statute: "AML § 3-5", title: "KMA/HMS-utbildning för VD", detail: "Kursplats bokad via Simployer Learn")
                                auditChecklistItem(statute: "AML kap. 10", title: "Arbetstidsregler & dygnsvila", detail: "Kontinuerligt övervakad mot stämplingar")
                                auditChecklistItem(statute: "Likestillingsl. § 26", title: "Lönekartläggning (ARP)", detail: "Genomförd utan osakliga löneskillnader")
                                auditChecklistItem(statute: "AML kap. 2 A", title: "Varslingsrutiner & kanal", detail: "Krypterad och oberoende kanal upprättad")
                                auditChecklistItem(statute: "Feriereglerna", title: "Semesterersättning", detail: "Synkroniserad mot lön och Fortnox")
                            }
                        }
                        
                        // Legal Air Cover Box
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 16))
                                .foregroundColor(SolTokens.ink600)
                                .padding(.top, 1)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("JURIDISK AIR COVER & REVISIONSGARANTI")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(SolTokens.ink450)
                                Text(store.l10n.auditLegalAirCoverText)
                                    .font(.inter(11))
                                    .foregroundColor(SolTokens.ink700)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(12)
                        .background(SolTokens.paper200)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .padding(20)
                }
                .frame(maxHeight: 380)
                
                Divider()
                    .background(SolTokens.paper300)
                
                // Footer Actions
                HStack(spacing: 12) {
                    Button {
                        store.showAuditReportSheet = false
                    } label: {
                        Text(store.l10n.close)
                            .font(.inter(12, .medium))
                            .foregroundColor(SolTokens.ink700)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(SolTokens.paper200)
                            .cornerRadius(7)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button {
                        #if os(macOS)
                        if let path = store.exportAuditReportPdf() {
                            NSWorkspace.shared.activateFileViewerSelecting([path])
                        }
                        #endif
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.doc.fill")
                            Text(store.l10n.auditSavePdfAction)
                        }
                        .font(.inter(12, .semibold))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8.5)
                        .background(SolTokens.plum900)
                        .cornerRadius(7)
                        
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(SolTokens.paper100)
            }
            .frame(width: 550)
            .background(SolTokens.canvasRoot)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.4), radius: 24, y: 10)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(SolTokens.paper300, lineWidth: 1))
        }
    }
    
    private func auditMetaRow(label: String, value: String, isHighlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.inter(11.5))
                .foregroundColor(SolTokens.ink600)
            Spacer()
            Text(value)
                .font(isHighlight ? .inter(11.5, .semibold) : .system(size: 11.5, design: .monospaced))
                .foregroundColor(isHighlight ? SolTokens.green800 : SolTokens.ink900)
        }
    }
    
    private func auditChecklistItem(statute: String, title: String, detail: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(SolTokens.green800)
                .font(.system(size: 12))
            
            Text(statute)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(SolTokens.green100)
                .foregroundColor(SolTokens.green800)
                .cornerRadius(4)
            
            Text(title)
                .font(.inter(11.5, .medium))
                .foregroundColor(SolTokens.ink900)
            
            Spacer()
            
            Text(detail)
                .font(.inter(10.5))
                .foregroundColor(SolTokens.ink450)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(SolTokens.paper100)
        .cornerRadius(6)
    }
}


// MARK: - Linear-Grade Command Palette & Quick Search Modal

struct CommandPaletteModal: View {
    @ObservedObject var store: ComplyStore
    @Binding var isPresented: Bool
    var onSelectNav: (String) -> Void
    var onSelectCard: (String) -> Void
    var onSelectYear: (CompanyYear) -> Void
    
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                // Header with search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.inter(14, .medium))
                        .foregroundColor(SolTokens.lav400)
                    
                    TextField(store.l10n.searchPlaceholder, text: $query)
                        .font(.inter(13.5))
                        .textFieldStyle(.plain)
                        .foregroundColor(SolTokens.ink900)
                        .focused($isSearchFocused)
                    
                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.inter(12))
                                .foregroundColor(SolTokens.ink450)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        isPresented = false
                    } label: {
                        Text("ESC")
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(SolTokens.paper300)
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                }
                .padding(14)
                .background(SolTokens.paper100)
                
                Divider()
                    .overlay(SolTokens.paper300)
                
                // Scrollable results
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        // Navigasjon
                        let navItems = filteredNavItems
                        if !navItems.isEmpty {
                            sectionHeader(store.l10n.paletteSectionNav)
                            ForEach(navItems, id: \.id) { item in
                                paletteRow(
                                    icon: item.icon,
                                    iconColor: SolTokens.lav400,
                                    title: item.title,
                                    subtitle: nil,
                                    badge: nil
                                ) {
                                    onSelectNav(item.id)
                                    isPresented = false
                                }
                            }
                        }
                        
                        // Handlinger / Lovkrav
                        let actionItems = filteredActionItems
                        if !actionItems.isEmpty {
                            sectionHeader(store.l10n.paletteSectionActions)
                            ForEach(actionItems, id: \.id) { item in
                                paletteRow(
                                    icon: item.icon,
                                    iconColor: SolTokens.amber400,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    badge: item.statute
                                ) {
                                    onSelectCard(item.id)
                                    isPresented = false
                                }
                            }
                        }
                        
                        // Ansatte
                        let empItems = filteredEmployees
                        if !empItems.isEmpty {
                            sectionHeader(store.l10n.paletteSectionEmployees)
                            ForEach(empItems, id: \.id) { emp in
                                paletteRow(
                                    icon: "person.fill",
                                    iconColor: SolTokens.ink600,
                                    title: emp.name,
                                    subtitle: "\(store.l10n.localizedRole(emp.role)) · \(store.l10n.localizedDepartment(emp.department))",
                                    badge: localizedStatus(for: emp, l10n: store.l10n)
                                ) {
                                    onSelectNav("register")
                                    isPresented = false
                                }
                            }
                        }
                        
                        // Tidshopp
                        let yearItems = filteredYears
                        if !yearItems.isEmpty {
                            sectionHeader(store.l10n.paletteSectionYears)
                            ForEach(yearItems, id: \.id) { yr in
                                paletteRow(
                                    icon: "clock.arrow.circlepath",
                                    iconColor: yr == store.currentYear ? SolTokens.lav400 : SolTokens.ink450,
                                    title: yr.label,
                                    subtitle: "\(yr.staffCount) · \(yr.stageTitle)",
                                    badge: yr == store.currentYear ? store.l10n.activeSuffix : nil
                                ) {
                                    onSelectYear(yr)
                                    isPresented = false
                                }
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(maxHeight: 360)
            }
            .frame(width: 540)
            .background(SolTokens.paper100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(SolTokens.paper300, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
        }
        .onAppear {
            isSearchFocused = true
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.inter(9.5, .bold))
            .foregroundColor(SolTokens.ink450)
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 2)
    }
    
    private func paletteRow(icon: String, iconColor: Color, title: String, subtitle: String?, badge: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.inter(12))
                    .frame(width: 18)
                
                VStack(alignment: .leading, spacing: 1.5) {
                    Text(title)
                        .font(.inter(12.5, .medium))
                        .foregroundColor(SolTokens.ink900)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.inter(11))
                            .foregroundColor(SolTokens.ink600)
                    }
                }
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink600)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(SolTokens.paper100.opacity(0.5))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
    
    struct PaletteNavItem: Identifiable {
        let id: String
        let title: String
        let icon: String
    }
    
    struct PaletteActionItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let statute: String
        let icon: String
    }
    
    private var filteredNavItems: [PaletteNavItem] {
        let all = [
            PaletteNavItem(id: "hub", title: store.l10n.navHub, icon: "bolt.shield.fill"),
            PaletteNavItem(id: "ingest", title: store.l10n.navIngest, icon: "folder.badge.plus"),
            PaletteNavItem(id: "register", title: store.l10n.navRegister, icon: "person.2.fill"),
            PaletteNavItem(id: "handbook", title: store.l10n.navHandbook, icon: "book.fill"),
            PaletteNavItem(id: "radar", title: store.l10n.navRadar, icon: "scope"),
            PaletteNavItem(id: "expert", title: store.l10n.navExpert, icon: "scale.3d")
        ]
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return all
        }
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    private var filteredActionItems: [PaletteActionItem] {
        let all = [
            PaletteActionItem(id: "contracts", title: store.l10n.hubCardContractsTitle, subtitle: store.l10n.hubCardContractsDesc, statute: store.l10n.hubCardContractsStatute, icon: "doc.text.fill"),
            PaletteActionItem(id: "verneombud", title: store.l10n.hubCardVoTitle, subtitle: store.l10n.hubCardVoDesc, statute: store.l10n.hubCardVoStatute, icon: "person.badge.shield.checkmark.fill"),
            PaletteActionItem(id: "hms", title: store.l10n.hubCardHmsTitle, subtitle: store.l10n.hubCardHmsDesc, statute: store.l10n.hubCardHmsStatute, icon: "graduationcap.fill"),
            PaletteActionItem(id: "equalPay", title: store.l10n.hubCardEqualPayTitle, subtitle: store.l10n.hubCardEqualPayDesc, statute: store.l10n.hubCardEqualPayStatute, icon: "chart.bar.xaxis"),
            PaletteActionItem(id: "sickLeave", title: store.l10n.hubCardSickTitle, subtitle: store.l10n.hubCardSickDesc, statute: store.l10n.hubCardSickStatute, icon: "heart.text.square.fill")
        ]
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return Array(all.prefix(3))
        }
        return all.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.subtitle.localizedCaseInsensitiveContains(query) ||
            $0.statute.localizedCaseInsensitiveContains(query)
        }
    }
    
    private var filteredEmployees: [Employee] {
        let emps = store.currentScenario.employees
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return Array(emps.prefix(3))
        }
        return emps.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.role.localizedCaseInsensitiveContains(query) ||
            $0.department.localizedCaseInsensitiveContains(query)
        }
    }
    
    private var filteredYears: [CompanyYear] {
        let all = CompanyYear.allCases
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return all
        }
        return all.filter {
            $0.label.localizedCaseInsensitiveContains(query) ||
            $0.staffCount.localizedCaseInsensitiveContains(query) ||
            $0.stageTitle.localizedCaseInsensitiveContains(query)
        }
    }
}
