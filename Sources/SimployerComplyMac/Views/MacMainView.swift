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
    @AppStorage("comply_col_employee_width") private var colEmployeeWidth: Double = 180.0
    @AppStorage("comply_col_role_width") private var colRoleDeptWidth: Double = 210.0
    @AppStorage("comply_col_employment_width") private var colEmploymentWidth: Double = 160.0
    @AppStorage("comply_col_status_width") private var colStatusWidth: Double = 170.0
    
    // MARK: - Handbook State
    @State private var activeHandbookVolume: HandbookVolume = .staff
    @State private var expandedHandbookChapter: String? = nil
    @State private var handbookSearchQuery: String = ""
    @State private var handbookToastText: String? = nil
    
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
    @State private var isHoveredCompany: Bool = false
    
    // MARK: - Live Ingestion Analysis State
    @State private var isAnalyzingDrop: Bool = false
    @State private var dropProgress: Double = 0.0
    @State private var dropAnalysisStage: Int = 0
    @State private var dropFileName: String = "Anställningsavtal_2024_Standard.docx"
    @State private var showResetToast: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            SolTokens.canvasRoot.ignoresSafeArea()
            
            // Global keyboard shortcut for immediate prototype reset (⌘R)
            Button("") {
                resetEntirePrototype()
            }
            .keyboardShortcut("r", modifiers: .command)
            .opacity(0)
            .frame(width: 0, height: 0)
            
            // MARK: - Main Content Split (Linear Sidebar + Framed Canvas)
            HStack(spacing: 0) {
                // Left Sidebar (resizable)
                VStack(alignment: .leading, spacing: 3.5) {
                    // Simployer Comply Brand Header (Aligned with Breadcrumb Bar height)
                    sidebarBrandHeader
                    
                    // Unified Company Header & Overview Nav (Fjord Dynamics = Top-level Overview)
                    companyHeaderView
                    
                    // Section 1: Verksamhet & Bevakning (Live Internal Reality)
                    HStack(spacing: 4) {
                        Text(store.l10n.overviewSection.uppercased())
                            .font(.inter(10, .bold))
                            .tracking(0.7)
                            .foregroundColor(SolTokens.ink600)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 6))
                            .foregroundColor(SolTokens.ink450)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 14)
                    .padding(.bottom, 3)
                    
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
                        id: "ingest",
                        label: store.l10n.navIngest,
                        icon: "folder.badge.gearshape",
                        badge: "4",
                        badgeStyle: .neutral,
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "ingest"
                    }
                    
                    // Section 2: Lag, Revision & Jurist (External Intelligence, Strategy & Legal)
                    HStack(spacing: 4) {
                        Text(store.l10n.complianceSection.uppercased())
                            .font(.inter(10, .bold))
                            .tracking(0.7)
                            .foregroundColor(SolTokens.ink600)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 6))
                            .foregroundColor(SolTokens.ink450)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 14)
                    .padding(.bottom, 3)
                    
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
                    
                    SidebarButton(
                        id: "auditPack",
                        label: store.l10n.navAuditPack,
                        icon: "shield.lefthalf.filled",
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "auditPack"
                    }
                    
                    SidebarButton(
                        id: "expert",
                        label: store.l10n.navExpert,
                        icon: "bubble.left.and.bubble.right",
                        activeNav: store.activeNav
                    ) {
                        store.activeNav = "expert"
                    }
                        
                    Spacer()
                    
                    // Pinned Bottom Settings Row with Border Divider
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(SolTokens.paper300)
                            .frame(height: 1)
                            .padding(.horizontal, 10)
                            .padding(.top, 6)
                        
                        SidebarButton(
                            id: "settings",
                            label: store.l10n.navSettings,
                            icon: "gearshape",
                            activeNav: store.activeNav
                        ) {
                            store.activeNav = "settings"
                        }
                    }
                    .padding(.bottom, 12)
                }
                    .frame(width: CGFloat(sidebarWidth), alignment: .leading)
                    .fixedSize(horizontal: true, vertical: false)
                    .clipped()
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
                        // Canvas Header Bar (Breadcrumb + Actions) - Fixed height eliminates vertical jitter
                        HStack(alignment: .center) {
                            HStack(spacing: 7) {
                                Image(systemName: currentNavIcon)
                                    .font(.system(size: 12))
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(store.activeNav == "hub" ? companyBadgeIconColor : SolTokens.lav400)
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        store.activeNav = "hub"
                                    }
                                } label: {
                                    Text("Fjord Dynamics")
                                        .font(.inter(12.5, .medium))
                                        .foregroundColor(SolTokens.ink600)
                                }
                                .buttonStyle(.plain)
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
                            
                            // Presenter HUD Toggle Button (⌘D)
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    store.showPresenterHUD.toggle()
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "sparkles.tv")
                                        .font(.system(size: 9.5, weight: .semibold))
                                    Text(store.showPresenterHUD ? store.l10n.hudToggleClose : store.l10n.hudToggleOpen)
                                        .font(.inter(11, .medium))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(store.showPresenterHUD ? SolTokens.lav400.opacity(0.18) : SolTokens.paper200)
                                .foregroundColor(store.showPresenterHUD ? SolTokens.plum900 : SolTokens.ink600)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(store.showPresenterHUD ? SolTokens.lav400.opacity(0.5) : SolTokens.paper300, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .help(store.l10n.hudToggleHelp)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 42)
                        .background(SolTokens.paper50)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(SolTokens.paper300),
                            alignment: .bottom
                        )
                        
                        // Framed View Content
                        ZStack(alignment: .topLeading) {
                            SolTokens.paper50.ignoresSafeArea()
                            
                            Group {
                                switch store.activeNav {
                                case "hub":
                                    macActionHubView
                                case "agentLog":
                                    AgentLogView()
                                case "ingest":
                                    macIngestDropView
                                case "register":
                                    macRegisterTableView
                                case "handbook":
                                    macHandbookView
                                case "radar":
                                    macRadarView
                                case "expert":
                                    macExpertView
                                case "auditPack":
                                    InspectionExportView()
                                case "settings":
                                    macSettingsView
                                default:
                                    macActionHubView
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .clipped()
                    .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 10) {
                if showResetToast {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(SolTokens.green800)
                        Text(store.language == .se ? "Prototypen återställd till utgångsläge" : (store.language == .no ? "Prototypen tilbakestilt til startposisjon" : "Prototype reset to default state"))
                            .font(.inter(12, .semibold))
                            .foregroundColor(SolTokens.ink900)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(SolTokens.paper100)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.18), radius: 12, y: 4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.greenBorder, lineWidth: 1))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if let toast = handbookToastText {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(SolTokens.green800)
                        Text(toast)
                            .font(.inter(12, .semibold))
                            .foregroundColor(SolTokens.ink900)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(SolTokens.paper100)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.18), radius: 12, y: 4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.greenBorder, lineWidth: 1))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(24)
        }
        .overlay(alignment: .bottomTrailing) {
            if store.showPresenterHUD {
                presenterHUDOverlay
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
        .onChange(of: store.handbookSignaturesCount) { count in
            if count >= store.demoHeadcountMode && !vanishedCardIds.contains("handbook") {
                scheduleCardVanish(id: "handbook", delay: 1.3)
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
    
    // MARK: - Brand Header (Simployer Comply Brand Area aligning with breadcrumb row)
    private var sidebarBrandHeader: some View {
        HStack(spacing: 8) {
            SimployerLogoView()
                .frame(width: 17, height: 17)
            
            HStack(spacing: 4) {
                Text("Simployer")
                    .font(.inter(13, .bold))
                    .foregroundColor(SolTokens.ink900)
                Text("Comply")
                    .font(.inter(13, .semibold))
                    .foregroundColor(SolTokens.lav400)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 38)
        .padding(.top, 10)
        .padding(.bottom, 24)
    }

    // MARK: - Company Overview Root Item (Unified Fjord Dynamics Navigation Item)
    private var companyHeaderView: some View {
        let active = store.activeNav == "hub"
        let iconName = store.complianceSeverity.iconName
        let shieldColor = store.complianceSeverity.color
        
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                store.activeNav = "hub"
            }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(shieldColor)
                    .frame(width: 18, height: 18, alignment: .center)
                    .layoutPriority(1)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(store.language == .se ? "Handlingscenter" : (store.language == .no ? "Handlingssenter" : "Action Hub"))
                        .font(.inter(12.5, active ? .semibold : .medium))
                        .foregroundColor(active ? Color.white : (isHoveredCompany ? SolTokens.ink900 : SolTokens.ink700))
                    
                    Text("Fjord Dynamics")
                        .font(.inter(10, .regular))
                        .foregroundColor(active ? Color.white.opacity(0.7) : SolTokens.ink450)
                }
                .lineLimit(1)
                .layoutPriority(0)
                
                Spacer(minLength: 4)
                
                if store.pendingActionCount > 0 {
                    Text("\(store.pendingActionCount)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(SolTokens.amber400)
                        .padding(.horizontal, 5.5)
                        .padding(.vertical, 1.5)
                        .background(SolTokens.amber100)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(SolTokens.amberBorder, lineWidth: 1)
                        )
                        .layoutPriority(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6.5)
            .contentShape(Rectangle())
            .background(active ? SolTokens.sidebarActivePill : (isHoveredCompany ? SolTokens.paper200.opacity(0.6) : Color.clear))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.top, 0)
        .padding(.bottom, 2)
        .onHover { isHoveredCompany = $0 }
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
        store.complianceSeverity.color
    }
    
    private var companyBadgeIcon: String {
        store.complianceSeverity.iconName
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
        case "hub": return store.complianceSeverity.iconName
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
    
    // MARK: - Full Prototype Reset Engine (Default 2024 Initial State)
    private func resetEntirePrototype() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            autoplay.stopDemo { _ in }
            autoplay.currentStepIndex = 0
            autoplay.currentStep = nil
            store.resetDemoToMorningBaseline()
            self.vanishedCardIds.removeAll()
            self.showCompletedArchive = false
            self.expandedHubCard = nil
            self.selectedDiffEmployee = nil
            self.expandedEmployeeRowId = nil
            self.employeeSearchText = ""
            self.employeeStatusFilter = "all"
            self.selectedHorizonFilter = .all
            self.expandedSecondaryCard = nil
            self.showContinuousGuardrailsDetails = false
            self.isAnalyzingDrop = false
            self.dropProgress = 0.0
            self.dropAnalysisStage = 0
            self.dropFileName = "Anställningsavtal_2024_Standard.docx"
            self.showDemoControls = false
            self.showSearchPalette = false
            self.isDropTargeted = false
            store.activeNav = "hub"
            self.showResetToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showResetToast = false
            }
        }
    }
    
    // MARK: - Dedicated Presenter HUD Overlay (Unobtrusive Floating Capsule)
    private var presenterHUDOverlay: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles.tv")
                        .foregroundColor(SolTokens.lav500)
                    Text("Presenter HUD")
                        .font(.inter(12, .bold))
                        .foregroundColor(SolTokens.ink900)
                    
                    Text("⌘D")
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink600)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper200)
                        .cornerRadius(3)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        store.showPresenterHUD = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(SolTokens.ink450)
                        .padding(4)
                        .background(SolTokens.paper200)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            Divider().overlay(SolTokens.paper300)
            
            // 1. Headcount Simulator
            VStack(alignment: .leading, spacing: 4) {
                Text(store.l10n.hudHeadcountSection)
                    .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
                
                HStack(spacing: 6) {
                    demoHeadcountButton(count: 8, label: store.l10n.hudHeadcountBase)
                    demoHeadcountButton(count: 10, label: store.l10n.hudHeadcountAmu)
                    demoHeadcountButton(count: 20, label: store.l10n.hudHeadcountScale)
                }
            }
            
            // 2. Quick Action Sequences
            VStack(alignment: .leading, spacing: 4) {
                Text(store.l10n.hudQuickActionsSection)
                    .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
                
                HStack(spacing: 6) {
                    Button {
                        store.simulateHiringTwoEmployees()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 10))
                            Text(store.l10n.hudAddTwoHires)
                                .font(.inter(10.5, .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.lav500)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.lav400.opacity(0.35), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        store.resolveWithLiveSpin()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 10))
                            Text(store.l10n.hudResolveAction)
                                .font(.inter(10.5, .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                        .background(SolTokens.lav400.opacity(0.15))
                        .foregroundColor(SolTokens.lav500)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.lav400.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        store.resetDemoToMorningBaseline()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 10))
                            Text(store.l10n.hudResetAction)
                                .font(.inter(10.5, .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink700)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // 3. Language & Jurist Toggle
            HStack(spacing: 8) {
                Text(store.l10n.hudLanguageLabel)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundColor(SolTokens.ink600)
                
                HStack(spacing: 3) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button {
                            withAnimation {
                                store.language = lang
                            }
                        } label: {
                            Text(lang.rawValue.uppercased())
                                .font(.system(size: 9.5, weight: store.language == lang ? .bold : .medium, design: .monospaced))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .background(store.language == lang ? SolTokens.lav400.opacity(0.2) : SolTokens.paper200)
                                .foregroundColor(store.language == lang ? SolTokens.lav500 : SolTokens.ink600)
                                .cornerRadius(3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        store.juristEscalationPending.toggle()
                    }
                } label: {
                    Text(store.juristEscalationPending ? store.l10n.hudHideJurist : store.l10n.hudShowJurist)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(SolTokens.ink600)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(width: 360)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 14, y: 6)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
        .padding(20)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    private func demoHeadcountButton(count: Int, label: String) -> some View {
        let isSelected = store.demoHeadcountMode == count
        return Button {
            store.setDemoHeadcount(count)
        } label: {
            Text(label)
                .font(.inter(10.5, isSelected ? .bold : .medium))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(isSelected ? SolTokens.lav500 : SolTokens.paper200)
                .foregroundColor(isSelected ? Color.white : SolTokens.ink700)
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(isSelected ? SolTokens.lav500 : SolTokens.paper300, lineWidth: 1))
        }
        .buttonStyle(.plain)
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
        case "handbook":
            return store.handbookSignaturesCount >= store.demoHeadcountMode
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
            return ["contracts", "verneombud", "hms", "handbook"]
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
            if store.handbookSignaturesCount >= store.demoHeadcountMode {
                items.append(CompletedActionArchiveItem(
                    id: "handbook",
                    statute: "AML § 3-2",
                    title: store.l10n.hubPillarHandbookTitle,
                    resolutionNote: store.language == .se ? "8 av 8 medarbetare signerat via BankID" : (store.language == .no ? "8 av 8 ansatte signert via BankID" : "8 of 8 employees signed via BankID")
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

    // MARK: - Action Hub Antivirus Protection Console (CleanMyMac Smart Care Pattern)
    private var macActionHubView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Antivirus Grand Central Hero Stage (Compliance Dial + Visibility Nudge)
                cleanMyMacHeroStage
                
                // 2. Four Grouped Modular Protection Pillars (Contracts, Safety Rep, Hours, Handbook)
                cleanMyMacFourPillars
                
                // Expandable In-Place Contract Redline Diff Viewer (when expandedHubCard == "contracts")
                if expandedHubCard == "contracts" {
                    contractDiffInlineDrawer
                }
                
                // 3. Guarded Sources & Live Integrations Panel (Proof of Active Continuous Monitoring)
                guardedSourcesCockpitSection
                
                // 4. Ticket Section: Simployer Expert Consultation (Camilla Schie-Veslum)
                if store.juristEscalationPending {
                    humanInTheLoopJuristCard
                }
                
                // 5. Growth & Threshold Radar Puff (AML § 7-1: Next statutory requirement horizon)
                contextualGrowthThresholdPuff
                
                // Expandable In-Place AMU Exemption Agreement Preview
                if expandedHubCard == "amu_exemption" {
                    amuExemptionInlineDrawer
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }
    
    // MARK: - CleanMyMac Smart Care Hero Stage (Dual Dials: Compliance + Visibility)
    private var cleanMyMacHeroStage: some View {
        let isCompliant = store.pendingActionCount == 0 && !store.isResolving
        let totalCount = 10
        let pending = store.pendingActionCount
        let secured = store.currentSecuredCount
        let percent = store.currentCompliancePercent
        let dialRatio = CGFloat(store.currentComplianceRatio)
        let isFullySecured = percent >= 100
        
        let headline: String
        let subtitle: String
        
        if store.isResolving {
            headline = store.resolvingStepMessage ?? (store.language == .se ? "Comply åtgärdar lagavvikelser i bakgrunden…" : (store.language == .no ? "Comply løser lovavvik i bakgrunnen…" : "Comply resolving deviations in background…"))
            subtitle = store.language == .se ? "Autonom regelvalidering pågår. Ikonen i menyraden bekräftar certifierat skydd vid slutförande." : (store.language == .no ? "Autonom regelvalidering pågår. Ikonet i menylinjen bekrefter sertifisert vern." : "Autonomous rule validation in progress. Menu bar icon confirms certification.")
        } else if isCompliant {
            headline = store.language == .se ? "Fjord Dynamics är 100% skyddat" : (store.language == .no ? "Fjord Dynamics er 100% sikret" : "Fjord Dynamics is 100% protected")
            subtitle = store.language == .se ? "Alla 10 lagkrav är uppfyllda. 4 datakällor och \(store.currentScenario.headcount) anställningsakter bevakas kontinuerligt i bakgrunden." : (store.language == .no ? "Alle 10 lovkrav er oppfylt. 4 datakilder og \(store.currentScenario.headcount) personalmapper overvåkes kontinuerlig i bakgrunnen." : "All 10 duties are secured. 4 data sources and \(store.currentScenario.headcount) employee records continuously monitored.")
        } else {
            let actionsWord = pending == 1 
                ? (store.language == .se ? "1 åtgärd krävs för fullt lagskydd" : (store.language == .no ? "1 tiltak kreves for fullt lovvern" : "1 action required for full legal protection"))
                : (store.language == .se ? "\(pending) åtgärder krävs för fullt lagskydd" : (store.language == .no ? "\(pending) tiltak kreves for fullt lovvern" : "\(pending) actions required for full legal protection"))
            headline = actionsWord
            subtitle = store.language == .se ? "Comply har förberett färdiga lagklausuler och underlag. Godkänn nedan så uppdateras och arkiveras handlingarna automatiskt." : (store.language == .no ? "Comply har klargjort lovklausuler og grunnlag. Godkjenn nedenfor for automatisk oppdatering og arkivering." : "Comply prepared compliant clauses and documentation. Approve below to update and archive records automatically.")
        }
        
        let ctaTitle: String = store.l10n.hubMacroResolveButton
        
        // Semantic color resolution
        let dialColor: Color
        let subtitleColor: Color
        if isFullySecured || isCompliant {
            dialColor = SolTokens.green800
            subtitleColor = SolTokens.green800
        } else if store.isResolving {
            dialColor = SolTokens.lav500
            subtitleColor = SolTokens.lav500
        } else if store.complianceSeverity == .behind {
            dialColor = SolTokens.red700
            subtitleColor = SolTokens.red700
        } else {
            dialColor = SolTokens.amber400
            subtitleColor = SolTokens.amber400
        }
        
        let badgeColor: Color
        let badgeBg: Color
        if isCompliant {
            badgeColor = SolTokens.green800
            badgeBg = SolTokens.green100
        } else if store.isResolving {
            badgeColor = SolTokens.lav500
            badgeBg = SolTokens.lav100
        } else if store.complianceSeverity == .behind {
            badgeColor = SolTokens.red700
            badgeBg = SolTokens.red100
        } else {
            badgeColor = SolTokens.amber400
            badgeBg = SolTokens.amber100
        }
        
        return VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 28) {
                // Column 1: Single Grand Compliance Dial
                ZStack {
                    Circle()
                        .stroke(SolTokens.paper300, lineWidth: 10)
                        .frame(width: 136, height: 136)
                    
                    Circle()
                        .trim(from: 0.0, to: dialRatio)
                        .stroke(
                            dialColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 136, height: 136)
                        .animation(.linear(duration: 0.035), value: dialRatio)
                    
                    VStack(spacing: 3) {
                        Text("\(percent)%")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor((isFullySecured || isCompliant) ? SolTokens.green800 : SolTokens.ink900)
                            .contentTransition(.numericText())
                        
                        Text(store.l10n.hubMetricComplianceTitle.uppercased())
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(0.6)
                            .foregroundColor(subtitleColor)
                            .lineLimit(1)
                    }
                }
                .frame(width: 140, height: 140)
                
                // Column 2: Status Badges, Headline, Subtitle
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(badgeColor)
                            .frame(width: 6, height: 6)
                        Text(store.isResolving
                             ? (store.language == .se ? "AUTONOM REGELVALIDERING PÅGÅR" : (store.language == .no ? "AUTONOM REGELVALIDERING PÅGÅR" : "AUTONOMOUS VALIDATION IN PROGRESS"))
                             : (isCompliant 
                                ? (store.language == .se ? "100% SÄKRAT MOT LAGAVVIKELSER" : (store.language == .no ? "100% SIKRET MOT LOVAVVIK" : "100% SECURED AGAINST INFRACTIONS"))
                                : (pending == 1
                                   ? (store.language == .se ? "1 AVVIKELSE KRÄVER DITT GODKÄNNANDE" : (store.language == .no ? "1 AVVIK KREVER DITT SAMTYKKE" : "1 VIOLATION REQUIRES APPROVAL"))
                                   : (store.language == .se 
                                      ? "\(pending) AVVIKELSER KRÄVER DITT GODKÄNNANDE"
                                      : (store.language == .no
                                         ? "\(pending) AVVIK KREVER DITT SAMTYKKE"
                                         : "\(pending) VIOLATIONS REQUIRE APPROVAL")))))
                            .font(.inter(10.5, .bold))
                            .foregroundColor(badgeColor)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(badgeBg)
                    .cornerRadius(5)
                    
                    Text(headline)
                        .font(.inter(22, .bold))
                        .foregroundColor(SolTokens.ink900)
                    
                    Text(subtitle)
                        .font(.inter(13, .regular))
                        .foregroundColor(SolTokens.ink600)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 20)
                
                // Column 3: Primary Action / CTA Column with Live Spin
                VStack(alignment: .trailing, spacing: 8) {
                    if store.isResolving {
                        VStack(alignment: .center, spacing: 8) {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .colorInvert()
                                Text(store.language == .se ? "Åtgärdar avvikelser…" : (store.language == .no ? "Løser avvik…" : "Resolving…"))
                                    .font(.inter(13.5, .bold))
                                    .foregroundColor(Color.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(SolTokens.plum900)
                            .clipShape(Capsule())
                            
                            Text(store.language == .se ? "Menyradsikonen snurrar i bakgrunden" : (store.language == .no ? "Menylinje-ikonet snurrer i bakgrunnen" : "Menu bar icon spinning in background"))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                    } else if !isCompliant {
                        VStack(alignment: .center, spacing: 8) {
                            Button {
                                store.resolveWithLiveSpin()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: 14, weight: .bold))
                                    Text(ctaTitle)
                                        .font(.inter(14, .bold))
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(SolTokens.linearIndigo)
                                .foregroundColor(Color.white)
                                .clipShape(Capsule())
                                .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .keyboardShortcut(.return, modifiers: .command)
                            
                            Text(store.language == .se ? "Uppdaterar 7 avtal automatiskt" : (store.language == .no ? "Oppdaterer 7 avtaler automatisk" : "Updates 7 contracts automatically"))
                                .font(.system(size: 10.5, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                    } else {
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(SolTokens.green800)
                                Text(store.language == .se 
                                     ? "Alla lagkrav säkrade" 
                                     : (store.language == .no 
                                        ? "Alle lovkrav sikret" 
                                        : "All duties secured"))
                                    .font(.inter(13.5, .bold))
                                    .foregroundColor(SolTokens.green800)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(SolTokens.green100)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.greenBorder, lineWidth: 1))
                            
                            Text(store.language == .se ? "Kontrolleras i bakgrunden" : (store.language == .no ? "Overvåkes i bakgrunnen" : "Monitored in background"))
                                .font(.system(size: 10.5, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                    }
                }
            }
            
            // Bottom Nudge Banner: Tripletex / Payroll Data Missing (System Visibility)
            Divider().overlay(SolTokens.paper300)
            
            HStack(spacing: 10) {
                // Mini 65% Visibility Ring Icon
                ZStack {
                    Circle()
                        .stroke(SolTokens.paper300, lineWidth: 2.5)
                        .frame(width: 22, height: 22)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(store.dataCoverageScore))
                        .stroke(
                            SolTokens.amber400,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 22, height: 22)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: store.dataCoverageScore)
                }
                
                HStack(spacing: 6) {
                    Text("\(Int(store.dataCoverageScore * 100))% " + store.l10n.hubMetricVisibilityTitle.lowercased())
                        .font(.inter(11.5, .bold))
                        .foregroundColor(SolTokens.amber400)
                    
                    Text("·")
                        .foregroundColor(SolTokens.ink450)
                    
                    Text(store.l10n.hubVisibilityMissingNudge)
                        .font(.inter(11.5, .medium))
                        .foregroundColor(SolTokens.ink800)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        store.activeNav = "ingest"
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(store.l10n.hubConnectSourcePill)
                            .font(.inter(11, .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9.5, weight: .semibold))
                    }
                    .foregroundColor(SolTokens.amber400)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(SolTokens.amber400.opacity(0.14))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.amber400.opacity(0.38), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity)
        .background(SolTokens.paper100)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCompliant ? SolTokens.greenBorder : SolTokens.paper300, lineWidth: 1)
        )
    }

    // MARK: - Contextual Growth & Threshold Radar Puff (AML § 7-1)
    private var contextualGrowthThresholdPuff: some View {
        let isTriggered = store.demoHeadcountMode >= 10
        
        return HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isTriggered ? SolTokens.amber100 : SolTokens.lav100)
                    .frame(width: 44, height: 44)
                Image(systemName: isTriggered ? "exclamationmark.bubble.fill" : "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20))
                    .foregroundColor(isTriggered ? SolTokens.amber400 : SolTokens.lav500)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(store.l10n.hubThresholdPuffTag)
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundColor(isTriggered ? SolTokens.amber400 : SolTokens.lav500)
                    
                    Text("·")
                        .foregroundColor(SolTokens.ink450)
                    
                    Text("\(store.currentScenario.headcount) " + (store.language == .se ? "anställda i bolaget" : (store.language == .no ? "ansatte i selskapet" : "headcount")))
                        .font(.inter(11, .medium))
                        .foregroundColor(SolTokens.ink600)
                }
                
                Text(isTriggered ? store.l10n.hubThresholdPuffTitleTriggered : store.l10n.hubThresholdPuffTitlePending)
                    .font(.inter(13.5, .bold))
                    .foregroundColor(SolTokens.ink900)
                
                Text(isTriggered ? store.l10n.hubThresholdPuffDescTriggered : store.l10n.hubThresholdPuffDescPending)
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink600)
                    .lineSpacing(2)
            }
            
            Spacer(minLength: 16)
            
            if isTriggered {
                Button {
                    _ = NSSound(named: "Glass")?.play()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "signature")
                            .font(.system(size: 11, weight: .bold))
                        Text(store.l10n.hubThresholdPuffAction)
                            .font(.inter(12, .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(SolTokens.amber400)
                    .foregroundColor(SolTokens.paper50)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        if expandedHubCard == "amu_exemption" {
                            expandedHubCard = nil
                        } else {
                            expandedHubCard = "amu_exemption"
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 11, weight: .semibold))
                        Text(store.l10n.hubThresholdPuffPreviewAction)
                            .font(.inter(12, .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9.5, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.indigo)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isTriggered ? SolTokens.amberBorder : SolTokens.paper300, lineWidth: 1)
        )
    }

    private var contractDiffInlineDrawer: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(SolTokens.indigo)
                    Text(store.language == .se ? "Förhandsgranska lagklausuler: Nya EU-villkor (AML § 14-6)" : "Clause Preview: EU Working Terms (AML § 14-6)")
                        .font(.inter(13.5, .bold))
                        .foregroundColor(SolTokens.ink900)
                    
                    Text(store.language == .se ? "7 avtal berörda" : "7 contracts affected")
                        .font(.inter(11, .semibold))
                        .foregroundColor(SolTokens.indigo)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(SolTokens.indigo.opacity(0.12))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        expandedHubCard = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                        Text(store.language == .se ? "Stäng granskning" : "Close preview")
                            .font(.inter(11.5, .medium))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            
            inlineContractsDiffView
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(SolTokens.indigo.opacity(0.4), lineWidth: 1.5)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var amuExemptionInlineDrawer: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.badge.checkmark")
                        .foregroundColor(SolTokens.indigo)
                    Text(store.language == .se ? "Förberett undantagsavtal: Lokal ordning utan AMU (AML § 7-1)" : (store.language == .no ? "Forberedt unntaksavtale: Lokal ordning uten AMU (AML § 7-1)" : "Pre-drafted Exemption: Local Health & Safety Scheme (AML § 7-1)"))
                        .font(.inter(13.5, .bold))
                        .foregroundColor(SolTokens.ink900)
                    
                    Text(store.language == .se ? "Klart för signering vid 10 anställda" : (store.language == .no ? "Klar for signering ved 10 ansatte" : "Ready for signing at 10 employees"))
                        .font(.inter(11, .semibold))
                        .foregroundColor(SolTokens.indigo)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(SolTokens.indigo.opacity(0.12))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        expandedHubCard = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                        Text(store.language == .se ? "Stäng granskning" : (store.language == .no ? "Lukk forhåndsvisning" : "Close preview"))
                            .font(.inter(11.5, .medium))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.ink700)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            
            // Document Preview Box
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.language == .se ? "PARTER I AVTALET" : (store.language == .no ? "PARTER I AVTALEN" : "PARTIES TO THE AGREEMENT"))
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                        Text("Fjord Dynamics AS (Arbeidsgiver) · Sofie Hagen (Valgt verneombud)")
                            .font(.inter(12, .semibold))
                            .foregroundColor(SolTokens.ink800)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 11))
                            .foregroundColor(SolTokens.green800)
                        Text("BankID Validated Template")
                            .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SolTokens.green100)
                    .cornerRadius(5)
                }
                
                Divider().overlay(SolTokens.paper300)
                
                Text(store.language == .se 
                    ? "§ 1. Syfte och lagstöd: I enlighet med arbeidsmiljøloven § 7-1 första stycket avtalar parterna om att inte upprätta formell arbetsmiljökommitté (AMU). Frågor som rör arbetsmiljö handläggs i stället genom kvartalsvisa samrådsmöten mellan daglig ledare och skyddsombud."
                    : (store.language == .no 
                        ? "§ 1. Formål og lovhjemmel: I medhold av arbeidsmiljøloven § 7-1 første ledd avtaler partene at det ikke opprettes arbeidsmiljøutvalg (AMU). Spørsmål vedrørende arbeidsmiljøet behandles i stedet i kvartalsvise faste møter mellom daglig leder og verneombud."
                        : "§ 1. Statutory basis: Pursuant to AML § 7-1 (1), the employer and the safety representative agree in writing that no formal Working Environment Committee (AMU) is established. Health and safety matters shall instead be reviewed in quarterly sessions between the managing director and the elected safety representative."))
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink700)
                    .lineSpacing(3)
                    .padding(12)
                    .background(SolTokens.paper50)
                    .cornerRadius(6)
            }
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(SolTokens.indigo.opacity(0.4), lineWidth: 1.5)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - 4 Grouped Modular Protection Pillars (CleanMyMac Smart Care 4-Column Horizontal Row)
    private var cleanMyMacFourPillars: some View {
        let hasContractGap = store.currentScenario.employees.contains { $0.status == .aml14Gap }
        let voActive = store.verneombudElectionActive
        let hmsDone = store.hmsTrainingEnrolled
        let handbookSigned = store.handbookSignaturesCount == store.demoHeadcountMode
        
        return HStack(alignment: .top, spacing: 14) {
            // Pillar 1: Avtal & Villkor (AML § 14-6)
            cleanMyMacPillarCard(
                title: store.l10n.hubPillarContractsTitle,
                statute: "AML § 14-6",
                icon: "doc.badge.gearshape.fill",
                statusBadge: hasContractGap ? (store.language == .se ? "1 avvikelse" : "1 gap") : (store.language == .se ? "Säkrat" : "Secured"),
                statusColor: hasContractGap ? SolTokens.red700 : SolTokens.green800,
                statusBg: hasContractGap ? SolTokens.red100 : SolTokens.green100,
                headlineOutcome: hasContractGap 
                    ? (store.language == .se ? "7 avtal behöver uppdateras" : (store.language == .no ? "7 avtaler må oppdateres" : "7 contracts need updating"))
                    : (store.language == .se ? "Alla \(store.currentScenario.headcount) avtal lagstadgade" : (store.language == .no ? "Alle \(store.currentScenario.headcount) avtaler lovfestet" : "All \(store.currentScenario.headcount) contracts compliant")),
                description: hasContractGap
                    ? (store.language == .se ? "Standardavtal saknar lagstadgad övertids- och kompetensbestämmelse." : (store.language == .no ? "Standardavtaler mangler lovpålagt overtids- og kompetansebestemmelse." : "Standard contracts lack statutory overtime and competence clauses."))
                    : (store.language == .se ? "Verifierade och signerade med BankID utan öppna tvister." : (store.language == .no ? "Verifisert og signert med BankID uten tvister." : "Verified and signed via BankID with zero open disputes.")),
                actionLabel: hasContractGap ? (store.language == .se ? "Granska 7 avtal →" : (store.language == .no ? "Gjennomgå 7 avtaler →" : "Review 7 contracts →")) : nil,
                action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        if hasContractGap {
                            if expandedHubCard == "contracts" {
                                expandedHubCard = nil
                            } else {
                                expandedHubCard = "contracts"
                                if selectedDiffEmployee == nil || selectedDiffEmployee?.status != .aml14Gap {
                                    selectedDiffEmployee = store.currentScenario.employees.first(where: { $0.status == .aml14Gap })
                                }
                            }
                        } else {
                            store.activeNav = "register"
                        }
                    }
                }
            )
            
            // Pillar 2: Skyddsombud & HMS (AML § 6-1 & § 3-5)
            cleanMyMacPillarCard(
                title: store.l10n.hubPillarSafetyTitle,
                statute: "AML § 6-1 · § 3-5",
                icon: "person.2.badge.gearshape.fill",
                statusBadge: (voActive && hmsDone) ? (store.language == .se ? "Tillsatt & Utbildad" : (store.language == .no ? "Valgt & Opplært" : "Elected & Trained")) : (store.language == .se ? "Åtgärd krävs" : (store.language == .no ? "Tiltak kreves" : "Action needed")),
                statusColor: (voActive && hmsDone) ? SolTokens.green800 : SolTokens.amber400,
                statusBg: (voActive && hmsDone) ? SolTokens.green100 : SolTokens.amber100,
                headlineOutcome: voActive
                    ? (store.language == .se ? "Skyddsombud utsett (8 röster)" : (store.language == .no ? "Verneombud valgt (8 stemmer)" : "Safety rep elected (8 votes)"))
                    : (store.language == .se ? "Obligatoriskt val krävs" : (store.language == .no ? "Lovpålagt valg kreves" : "Mandatory election")),
                description: voActive
                    ? (store.language == .se ? "Digitalt val genomfört med 8 av 8 röster. Valprotokoll arkiverat i Altinn." : (store.language == .no ? "Digitalt valg gjennomført med 8 av 8 stemmer. Protokoll arkivert i Altinn." : "Digital election concluded (8/8 votes). Protocol logged & filed."))
                    : (store.language == .se ? "Bolaget har \(store.currentScenario.headcount) anställda (tröskel: 5). Digitalt valförfarande krävs." : (store.language == .no ? "Selskapet har \(store.currentScenario.headcount) ansatte (terskel: 5). Digital valgprosess kreves." : "Headcount passed 5. Election process required by statute.")),
                actionLabel: voActive ? nil : (store.language == .se ? "Starta digitalt val →" : (store.language == .no ? "Start digitalt valg →" : "Start election →")),
                action: {
                    store.approveSafetyRepElection()
                }
            )
            
            // Pillar 3: Arbetstid & Vila (AML kap. 10)
            let isTripletexConnected = store.dataCoverageScore >= 0.99
            cleanMyMacPillarCard(
                title: store.l10n.hubPillarHoursTitle,
                statute: "AML kap. 10",
                icon: "clock.badge.checkmark.fill",
                statusBadge: isTripletexConnected
                    ? (store.language == .se ? "100% insyn" : (store.language == .no ? "100% innsyn" : "100% visibility"))
                    : (store.language == .se ? "Avtalsenlig arbetstid" : (store.language == .no ? "Avtalt arbeidstid" : "Contract-secured")),
                statusColor: SolTokens.green800,
                statusBg: SolTokens.green100,
                headlineOutcome: isTripletexConnected
                    ? (store.language == .se ? "Tripletex aktiv (11h vila bevakas)" : (store.language == .no ? "Tripletex aktiv (11t hvile overvåkes)" : "Tripletex active (11h rest tracked)"))
                    : (store.language == .se ? "37,5 timmars standardvecka" : (store.language == .no ? "37,5 t standarduke ivaretatt" : "37.5h standard week secured")),
                description: isTripletexConnected
                    ? (store.language == .se ? "Sanntidsströmning av stämplingar och dygnsvila aktiv via API." : "Real-time stream of time entries and rest intervals active via API.")
                    : (store.language == .se 
                        ? "Lagstadgad arbetstid styrs av anställningsavtalen. Anslut Tripletex för realtidsbevakning av 11h dygnsvila."
                        : (store.language == .no 
                            ? "Lovpålagt arbeidstid følger arbeidsavtalene. Koble til Tripletex for sanntidsovervåking av 11t hviletid."
                            : "Statutory hours governed by employment contracts. Connect Tripletex for real-time 11h rest monitoring.")),
                actionLabel: isTripletexConnected ? nil : (store.language == .se ? "Anslut Tripletex (valfritt) →" : (store.language == .no ? "Koble til Tripletex (valgfritt) →" : "Connect Tripletex (optional) →")),
                action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        store.activeNav = "ingest"
                    }
                }
            )
            
            // Pillar 4: Personalhandbok & Rutiner (AML § 3-2 & Likestillingsloven)
            cleanMyMacPillarCard(
                title: store.l10n.hubPillarHandbookTitle,
                statute: "AML § 3-2",
                icon: "book.closed.fill",
                statusBadge: handbookSigned 
                    ? (store.language == .se ? "\(store.demoHeadcountMode)/\(store.demoHeadcountMode) signerat" : (store.language == .no ? "\(store.demoHeadcountMode)/\(store.demoHeadcountMode) signert" : "\(store.demoHeadcountMode)/\(store.demoHeadcountMode) signed"))
                    : "\(store.handbookSignaturesCount)/\(store.demoHeadcountMode) " + (store.language == .se ? "signerat" : (store.language == .no ? "signert" : "signed")),
                statusColor: handbookSigned ? SolTokens.green800 : SolTokens.amber400,
                statusBg: handbookSigned ? SolTokens.green100 : SolTokens.amber100,
                headlineOutcome: handbookSigned
                    ? (store.language == .se ? "Alla \(store.demoHeadcountMode) har signerat via BankID" : (store.language == .no ? "Alle \(store.demoHeadcountMode) har signert via BankID" : "All \(store.demoHeadcountMode) signed via BankID"))
                    : (store.language == .se ? "\(store.handbookSignaturesCount) av \(store.demoHeadcountMode) har signerat" : (store.language == .no ? "\(store.handbookSignaturesCount) av \(store.demoHeadcountMode) har signert" : "\(store.handbookSignaturesCount) of \(store.demoHeadcountMode) signed")),
                description: handbookSigned
                    ? (store.language == .se ? "Varslingsrutiner och personalhandbok kvitterade av samtliga anställda via BankID." : (store.language == .no ? "Varslingsrutiner og personalhåndbok kvittert av samtlige ansatte via BankID." : "Whistleblowing policies and staff handbook acknowledged by all staff via BankID."))
                    : (store.language == .se 
                        ? "Obligatoriska rutiner för varsling och likabehandling distribuerade med BankID. Grön status kräver allas signatur."
                        : (store.language == .no 
                            ? "Obligatoriske rutiner for varsling og likebehandling distribuert med BankID. Grønn status krever alles signatur."
                            : "Mandatory whistleblowing and HSE policies distributed via BankID. Green status requires all staff to sign.")),
                actionLabel: handbookSigned ? nil : (store.language == .se ? "Påminn 4 medarbetare →" : (store.language == .no ? "Purr 4 ansatte →" : "Ping 4 employees →")),
                action: {
                    store.completeAllHandbookSignatures()
                }
            )
        }
    }

    // MARK: - Human-in-the-Loop Escalation Card (Camilla Schie-Veslum · Simployer Jurist)
    private var humanInTheLoopJuristCard: some View {
        HStack(spacing: 16) {
            // Real Person Photo Avatar (Camilla Schie-Veslum · Senior Legal Counsel)
            ZStack(alignment: .bottomTrailing) {
                if let img = SolTokens.camillaAvatar {
                    Image(nsImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(SolTokens.paper300, lineWidth: 1.5))
                } else {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [SolTokens.plum900, SolTokens.plum800],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        Text("CS")
                            .font(.inter(14.5, .bold))
                            .foregroundColor(SolTokens.lav50)
                    }
                    .frame(width: 48, height: 48)
                }
                
                // Active online status dot
                Circle()
                    .fill(SolTokens.green800)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(SolTokens.paper100, lineWidth: 2))
                    .offset(x: 1, y: 1)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 5) {
                // High-Contrast Multi-Color Tag Header (Brand, Ticket ID, and Warm Amber SLA Clock)
                HStack(spacing: 7) {
                    // Simployer Expert Brand Pill
                    HStack(spacing: 4) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 8.5))
                        Text(store.l10n.hubJuristProductTag)
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    }
                    .padding(.horizontal, 6.5)
                    .padding(.vertical, 2.5)
                    .background(SolTokens.plum900)
                    .foregroundColor(SolTokens.lav100)
                    .cornerRadius(4)
                    
                    // Ticket ID Badge
                    Text(store.l10n.hubJuristTicketId)
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5.5)
                        .padding(.vertical, 2.5)
                        .background(SolTokens.paper250)
                        .foregroundColor(SolTokens.ink600)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                    
                    // Warm Amber SLA Status Pill (Breaks purple monochrome with clear SLA expectation)
                    HStack(spacing: 4.5) {
                        Image(systemName: "clock.badge.checkmark.fill")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundColor(SolTokens.amber400)
                        Text(store.l10n.hubJuristEscalationStatus)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(SolTokens.amber400)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2.5)
                    .background(SolTokens.amber100)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(SolTokens.amber400.opacity(0.35), lineWidth: 1)
                    )
                }
                
                Text(store.l10n.hubJuristEscalationTitle)
                    .font(.inter(13.5, .bold))
                    .foregroundColor(SolTokens.ink900)
                
                Text(store.l10n.hubJuristEscalationDesc)
                    .font(.inter(12))
                    .foregroundColor(SolTokens.ink600)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Assigned Expert & SLA metadata row
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 9.5))
                            .foregroundColor(SolTokens.green800)
                        Text(store.l10n.hubJuristAssignedTo)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(SolTokens.ink800)
                    }
                    
                    Text("·")
                        .foregroundColor(SolTokens.ink450)
                    
                    Text(store.l10n.hubJuristAdvisorRole)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.top, 2)
            }
            
            Spacer(minLength: 16)
            
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    store.activeNav = "expert"
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .font(.system(size: 11))
                    Text(store.l10n.hubJuristEscalationAction)
                        .font(.inter(12, .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9.5, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(SolTokens.plum900)
                .foregroundColor(Color.white)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.lav400.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(SolTokens.paper300, lineWidth: 1)
        )
    }

    private func cleanMyMacPillarCard(
        title: String,
        statute: String,
        icon: String,
        statusBadge: String,
        statusColor: Color,
        statusBg: Color,
        headlineOutcome: String,
        description: String,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon & Status Badge Row
            HStack(alignment: .center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(statusBg)
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                // Status Capsule Pill
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 5, height: 5)
                    Text(statusBadge)
                        .font(.inter(10.5, .bold))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .background(statusBg)
                .cornerRadius(5)
            }
            
            // Pillar Title & Statute
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.inter(14, .bold))
                    .foregroundColor(SolTokens.ink900)
                
                Text(statute)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
            }
            
            // Headline Outcome
            Text(headlineOutcome)
                .font(.inter(12.5, .semibold))
                .foregroundColor(SolTokens.ink800)
                .lineLimit(1)
            
            // Body Description
            Text(description)
                .font(.inter(11.5, .regular))
                .foregroundColor(SolTokens.ink600)
                .lineSpacing(2)
                .frame(minHeight: 38, alignment: .topLeading)
            
            Spacer(minLength: 4)
            
            // Action Button at Bottom
            if let actionLabel = actionLabel, let action = action {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text(actionLabel)
                            .font(.inter(11.5, .semibold))
                            .foregroundColor(SolTokens.indigo)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(SolTokens.paper200)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SolTokens.green800)
                    Text(store.language == .se ? "Aktivt skyddat" : "Actively protected")
                        .font(.inter(11, .medium))
                        .foregroundColor(SolTokens.green800)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(SolTokens.paper100)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SolTokens.paper300, lineWidth: 1)
        )
    }


    // MARK: - Active Background Sentinel (Real-Time Proof-of-Work Strip)
    private var guardedSourcesCockpitSection: some View {
        let sourceCount = store.connectedCloudServices.count + store.monitoredLocalFolders.count
        
        return HStack(spacing: 12) {
            // Live Status Pill
            HStack(spacing: 6) {
                Circle()
                    .fill(SolTokens.green800)
                    .frame(width: 6, height: 6)
                Text(store.language == .se ? "Realtidsskydd aktivt" : (store.language == .no ? "Sanntidsvern aktivt" : "Real-time active"))
                    .font(.inter(10.5, .bold))
                    .foregroundColor(SolTokens.green800)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(SolTokens.green100)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.greenBorder, lineWidth: 1))
            
            // Concise Trust Indicator
            Text(store.language == .se 
                ? "Övervakar \(sourceCount) anslutna källor"
                : (store.language == .no 
                    ? "Overvåker \(sourceCount) tilkoblede kilder"
                    : "Monitoring \(sourceCount) connected sources"))
                .font(.inter(12.5, .medium))
                .foregroundColor(SolTokens.ink900)
            
            Spacer()
            
            // Secondary Action: Go to detailed sources view
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    store.activeNav = "ingest"
                }
            } label: {
                HStack(spacing: 5) {
                    Text(store.language == .se ? "Hantera källor" : (store.language == .no ? "Administrer kilder" : "Manage sources"))
                        .font(.inter(11.5, .medium))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9.5, weight: .semibold))
                }
                .foregroundColor(SolTokens.indigo)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(SolTokens.paper200)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
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
                        .contentShape(Capsule())
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
                            isCompliant ? SolTokens.green800 : (store.complianceSeverity == .behind ? SolTokens.red700 : SolTokens.amber400),
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
                        .contentShape(Capsule())
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
    
    // MARK: - Linear Handbook View (Multi-Volume & Strict Color Quarantine)
    private var macHandbookView: some View {
        let chapters = getHandbookChapters(for: activeHandbookVolume, language: store.language, l10n: store.l10n)
        let benefits = getCompanyBenefits(for: store.language)
        let q = handbookSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let filteredChapters = q.isEmpty ? chapters : chapters.filter { ch in
            ch.title.lowercased().contains(q) ||
            ch.statute.lowercased().contains(q) ||
            ch.summary.lowercased().contains(q) ||
            ch.statutoryRule.lowercased().contains(q) ||
            ch.companyPolicy.lowercased().contains(q) ||
            ch.practicalGuideline.lowercased().contains(q)
        }
        let filteredBenefits = q.isEmpty ? benefits : benefits.filter { ben in
            ben.title.lowercased().contains(q) ||
            ben.description.lowercased().contains(q) ||
            ben.highlight.lowercased().contains(q) ||
            ben.tags.contains { $0.lowercased().contains(q) }
        }
        
        return ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // MARK: 1. Executive Cockpit Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 10) {
                            Text(activeHandbookVolume.companyTitle(for: store.language))
                                .font(.inter(18, .bold))
                                .foregroundColor(SolTokens.ink900)
                            
                            Text(activeHandbookVolume.versionBadge(for: store.language))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(SolTokens.paper200)
                                .foregroundColor(SolTokens.lav400)
                                .cornerRadius(4)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                        }
                        
                        Text(activeHandbookVolume.subtitle(for: store.language))
                            .font(.inter(12.5))
                            .foregroundColor(SolTokens.ink600)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                handbookToastText = store.language == .se
                                    ? "📄 \(activeHandbookVolume.title(for: .se)) \(activeHandbookVolume.versionBadge(for: .se)) exporterad som PDF. Sparad i Hämtade filer"
                                    : (store.language == .no ? "📄 \(activeHandbookVolume.title(for: .no)) \(activeHandbookVolume.versionBadge(for: .no)) eksportert som PDF. Lagret i Nedlastinger" : "📄 \(activeHandbookVolume.title(for: .en)) \(activeHandbookVolume.versionBadge(for: .en)) exported as PDF. Saved to Downloads")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    handbookToastText = nil
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.doc.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(store.l10n.handbookDownloadPdf)
                                    .font(.inter(12, .medium))
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6.5)
                            .background(SolTokens.paper200)
                            .foregroundColor(SolTokens.ink800)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper400, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString("https://comply.simployer.com/fjord-dynamics/\(activeHandbookVolume.rawValue)", forType: .string)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                handbookToastText = store.language == .se
                                    ? "🔗 Delningslänk för \(activeHandbookVolume.title(for: .se)) kopierad till urklipp."
                                    : (store.language == .no ? "🔗 Delingslenke for \(activeHandbookVolume.title(for: .no)) kopiert til utklippstavle." : "🔗 Share link for \(activeHandbookVolume.title(for: .en)) copied to clipboard.")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    handbookToastText = nil
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(activeHandbookVolume == .leadership ? (store.language == .se ? "Dela med ledning" : (store.language == .no ? "Del med ledere" : "Share with leaders")) : store.l10n.handbookShareWithStaff)
                                    .font(.inter(12, .semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6.5)
                            .background(SolTokens.plum900)
                            .foregroundColor(SolTokens.lav50)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.lav400.opacity(0.4), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // MARK: 2. BankID Read Receipts & Compliance Cockpit Card
                HStack(spacing: 18) {
                    // Left dial/status
                    ZStack {
                        Circle()
                            .stroke(SolTokens.paper300, lineWidth: 8)
                            .frame(width: 72, height: 72)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(store.handbookSignaturesCount) / CGFloat(store.demoHeadcountMode))
                            .stroke(
                                store.handbookSignaturesCount == store.demoHeadcountMode ? SolTokens.green800 : SolTokens.amber400,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 72, height: 72)
                        
                        VStack(spacing: 0) {
                            Text("\(store.handbookSignaturesCount)/\(store.demoHeadcountMode)")
                                .font(.inter(15, .bold))
                                .foregroundColor(SolTokens.ink900)
                            Text(store.language == .se ? "SIGNERAT" : (store.language == .no ? "SIGNERT" : "SIGNED"))
                                .font(.system(size: 7.5, weight: .bold))
                                .foregroundColor(SolTokens.ink600)
                        }
                    }
                    .frame(width: 76, height: 76)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(store.language == .se ? "BANKID LÄSKVITTENS (AML § 3-2)" : (store.language == .no ? "BANKID LESEBEKREFTELSE (AML § 3-2)" : "BANKID READ RECEIPTS (AML § 3-2)"))
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.amber400)
                            
                            Text("·")
                                .foregroundColor(SolTokens.ink450)
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(SolTokens.amber400)
                                    .frame(width: 5, height: 5)
                                Text(store.language == .se ? "Ingen grön status förrän alla signerat" : (store.language == .no ? "Ingen grønn status før alle har signert" : "No green status until all have signed"))
                                    .font(.system(size: 10.5, weight: .semibold))
                                    .foregroundColor(SolTokens.amber400)
                            }
                        }
                        
                        Text(store.language == .se 
                            ? "4 av 8 medarbetare har bekräftat tagit del av lagstadgade rutiner" 
                            : (store.language == .no 
                                ? "4 av 8 medarbeidere har bekreftet mottak av lovpålagte rutiner" 
                                : "4 of 8 staff have confirmed receipt of statutory policies"))
                            .font(.inter(13.5, .bold))
                            .foregroundColor(SolTokens.ink900)
                        
                        Text(store.language == .se 
                            ? "Väntar på signatur från: Morten Dahl, Kasper Rahman, Sofia Rossi, Freja Holm." 
                            : (store.language == .no 
                                ? "Venter på signatur fra: Morten Dahl, Kasper Rahman, Sofia Rossi, Freja Holm." 
                                : "Awaiting signature from: Morten Dahl, Kasper Rahman, Sofia Rossi, Freja Holm."))
                            .font(.inter(11.5))
                            .foregroundColor(SolTokens.ink600)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            handbookToastText = store.language == .se 
                                ? "📲 BankID-påminnelse skickad till 4 medarbetare via SMS" 
                                : (store.language == .no ? "📲 BankID-påminnelse sendt til 4 medarbeidere via SMS" : "📲 BankID reminder sent to 4 employees via SMS")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                handbookToastText = nil
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 11))
                            Text(store.language == .se ? "Skicka BankID-påminnelse" : (store.language == .no ? "Send BankID-påminnelse" : "Send BankID Reminder"))
                                .font(.inter(11.5, .semibold))
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.indigo)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(SolTokens.paper100)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                
                // MARK: 3. Search Field
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(SolTokens.ink450)
                    TextField(store.l10n.handbookSearchPlaceholder, text: $handbookSearchQuery)
                        .textFieldStyle(.plain)
                        .font(.inter(12.5))
                        .foregroundColor(SolTokens.ink900)
                    if !handbookSearchQuery.isEmpty {
                        Button(action: { handbookSearchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(SolTokens.ink450)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(SolTokens.paper100)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                .frame(maxWidth: .infinity)
                .opacity(expandedHandbookChapter == nil ? 1.0 : 0.25)
                .animation(.spring(response: 0.44, dampingFraction: 0.86), value: expandedHandbookChapter)
                
                // MARK: 4. Chapters Grid (3 Columns)
                if filteredChapters.isEmpty && (activeHandbookVolume != .staff || filteredBenefits.isEmpty) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(SolTokens.ink450)
                        Text(store.language == .se ? "Inga kapitel matchade \"\(handbookSearchQuery)\"" : (store.language == .no ? "Ingen kapitler matchet \"\(handbookSearchQuery)\"" : "No chapters matched \"\(handbookSearchQuery)\""))
                            .font(.inter(13))
                            .foregroundColor(SolTokens.ink600)
                        Button(action: { handbookSearchQuery = "" }) {
                            Text(store.language == .se ? "Rensa sökning" : (store.language == .no ? "Nullstill søk" : "Clear search"))
                                .font(.inter(12, .semibold))
                                .foregroundColor(SolTokens.lav400)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 24)
                } else {
                    let totalCount = filteredChapters.count
                    let rowIndices = Array(stride(from: 0, to: totalCount, by: 3))
                    
                    VStack(alignment: .leading, spacing: 14) {
                        let handbookCardHeight: CGFloat = 214
                        
                        ForEach(rowIndices, id: \.self) { index in
                            let end = min(index + 3, totalCount)
                            let rowChapters = Array(filteredChapters[index..<end])
                            let activeChapterInRow = rowChapters.first(where: { $0.chapterNumber == expandedHandbookChapter })
                            let activeColIndexInRow = rowChapters.firstIndex(where: { $0.chapterNumber == expandedHandbookChapter })
                            
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top, spacing: 14) {
                                    ForEach(Array(rowChapters.enumerated()), id: \.element.id) { colIdx, chapter in
                                        let isThisSelected = expandedHandbookChapter == chapter.chapterNumber
                                        HandbookColumnCard(
                                            chapter: chapter,
                                            isSelected: isThisSelected,
                                            cardHeight: handbookCardHeight,
                                            onSelect: {
                                                withAnimation(.spring(response: 0.44, dampingFraction: 0.86)) {
                                                    if expandedHandbookChapter == chapter.chapterNumber {
                                                        expandedHandbookChapter = nil
                                                    } else {
                                                        expandedHandbookChapter = chapter.chapterNumber
                                                    }
                                                }
                                            }
                                        )
                                        .frame(height: handbookCardHeight)
                                        .opacity(expandedHandbookChapter == nil ? 1.0 : (isThisSelected ? 1.0 : 0.25))
                                        .animation(.spring(response: 0.44, dampingFraction: 0.86), value: expandedHandbookChapter)
                                    }
                                    if min(index + 3, filteredChapters.count) - index < 3 {
                                        ForEach(0..<(3 - (min(index + 3, filteredChapters.count) - index)), id: \.self) { _ in
                                            Color.clear
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                                
                                // Reveal detail box directly beneath this row, seamlessly connected with exact 14pt row margin
                                if let activeChapter = activeChapterInRow, let activeCol = activeColIndexInRow {
                                    Spacer().frame(height: 14)
                                    
                                    HandbookRowDetailBox(
                                        chapter: activeChapter,
                                        activeCol: activeCol,
                                        onClose: {
                                            withAnimation(.spring(response: 0.38, dampingFraction: 0.92)) {
                                                expandedHandbookChapter = nil
                                            }
                                        }
                                    )
                                    .id(activeChapter.chapterNumber)
                                    .transition(.asymmetric(
                                        insertion: .opacity
                                            .animation(.easeInOut(duration: 0.34).delay(0.05))
                                            .combined(with: .scale(scale: 0.985, anchor: .top)),
                                        removal: .opacity
                                            .animation(.easeInOut(duration: 0.22))
                                            .combined(with: .scale(scale: 0.985, anchor: .top))
                                    ))
                                }
                            }
                            .background(
                                Group {
                                    if let activeCol = activeColIndexInRow {
                                        InwardFilletShape(
                                            activeCol: activeCol,
                                            totalCols: 3,
                                            spacing: 14,
                                            cardHeight: handbookCardHeight,
                                            rowMargin: 14,
                                            r: 10,
                                            inwardR: 12
                                        )
                                        .fill(SolTokens.paper100)
                                        .overlay(
                                            InwardFilletShape(
                                                activeCol: activeCol,
                                                totalCols: 3,
                                                spacing: 14,
                                                cardHeight: handbookCardHeight,
                                                rowMargin: 14,
                                                r: 10,
                                                inwardR: 12
                                            )
                                            .stroke(SolTokens.paper300, lineWidth: 1)
                                        )
                                    }
                                }
                            )
                        }
                    }
                    
                    // MARK: 5. Dynamic Volume Footer
                    Group {
                        if activeHandbookVolume == .staff && !filteredBenefits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(store.l10n.handbookBenefitsHeader)
                                    .font(.inter(15, .bold))
                                    .foregroundColor(SolTokens.ink900)
                                Text(store.l10n.handbookBenefitsSub)
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            .padding(.top, 10)
                            
                            HStack(alignment: .top, spacing: 14) {
                                ForEach(filteredBenefits) { benefit in
                                    CompanyBenefitCard(benefit: benefit)
                                }
                            }
                        }
                    } else if activeHandbookVolume == .leadership {
                        // Leadership Callout: Procedural Legal Escort
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(SolTokens.paper200)
                                    .frame(width: 44, height: 44)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                                Image(systemName: "scale.3d")
                                    .font(.system(size: 20))
                                    .foregroundColor(SolTokens.lav400)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(store.language == .se ? "Ledningsstöd: Processuella Riktlinjer & Simployer Jurist-avtal" : (store.language == .no ? "Lederstøtte: Prosessuelle Retningslinjer & Simployer Juristavtale" : "Leadership Support: Procedural Guidelines & Legal Escalation"))
                                    .font(.inter(13.5, .bold))
                                    .foregroundColor(SolTokens.ink900)
                                Text(store.language == .se ? "Samtliga chefsrutiner hålls uppdaterade mot aktuell domstolspraxis i Arbetsdomstolen. Procedurfel vid uppsägning leder till skadestånd oavsett sakgrund." : (store.language == .no ? "Alle lederrutiner kvalitetssikres mot oppdatert rettspraksis i Arbeidsretten. Prosessuelle feil ved oppsigelse (§ 15-1) utløser automatisk erstatningskrav." : "All managerial procedures align with current labor court precedents. Procedural flaws in dismissals trigger damages regardless of substantive merit."))
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                store.activeNav = "expert"
                            }) {
                                HStack(spacing: 6) {
                                    Text(store.language == .se ? "Kontakta Simployer Jurist" : (store.language == .no ? "Kontakt Simployer Jurist" : "Contact Simployer Legal"))
                                        .font(.inter(12, .semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(SolTokens.plum900)
                                .foregroundColor(SolTokens.lav50)
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.lav400.opacity(0.4), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(SolTokens.paper100)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                        .padding(.top, 10)
                    } else if activeHandbookVolume == .hms {
                        // HMS Callout: Inspection Readiness
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(SolTokens.paper200)
                                    .frame(width: 44, height: 44)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(SolTokens.lav400)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(store.language == .se ? "Tillsynsberedskap: Internkontroll & Årlig Handlingsplan" : (store.language == .no ? "Tilsynsberedskap: Internkontroll & Årlig Handlingsplan" : "Inspection Readiness: Statutory HSE Internal Control"))
                                    .font(.inter(13.5, .bold))
                                    .foregroundColor(SolTokens.ink900)
                                Text(store.language == .se ? "Arbetsmiljöverket granskar skriftlig internkontroll, VD:s utbildningsbevis och skyddsombudets valprotokoll vid tillsynsbesök. Allt finns samlat i Comply." : (store.language == .no ? "Arbeidstilsynet etterspør skriftlig internkontroll (§ 3-5), opplæringsbevis og verneombudets valgprotokoll ved tilsyn. Alt er forankret her." : "Labor Inspection Authorities audit written internal control, CEO training certifications, and election minutes during unannounced audits."))
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                store.activeNav = "auditPack"
                            }) {
                                HStack(spacing: 6) {
                                    Text(store.language == .se ? "Exportera Tillsynspaket" : (store.language == .no ? "Eksporter Tilsynspakke" : "Export Inspection Bundle"))
                                        .font(.inter(12, .semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(SolTokens.paper200)
                                .foregroundColor(SolTokens.ink800)
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper400, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(SolTokens.paper100)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                        .padding(.top, 10)
                    }
                    }
                    .opacity(expandedHandbookChapter == nil ? 1.0 : 0.25)
                    .animation(.spring(response: 0.44, dampingFraction: 0.86), value: expandedHandbookChapter)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }

        // MARK: - Linear Radar View
    private var macRadarView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.l10n.radarHeaderTitle)
                        .font(.inter(16, .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text(store.l10n.radarHeaderSubtitle)
                        .font(.inter(12))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.bottom, 2)
                
                // Speedometer & Runway Hero Card
                VStack(alignment: .leading, spacing: 14) {
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
                    
                    // Visual Runway Milestone Track
                    runwayMilestoneBar
                }
                .padding(16)
                .background(SolTokens.paper100)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                
                // Section Title: LAGSTADGADE TILLVÄXTTRÖSKLAR
                HStack(spacing: 8) {
                    Text(store.l10n.runwaySectionTitle)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink600)
                    
                    Text(store.l10n.runwayThresholdCountBadge)
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink600)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .padding(.top, 4)
                .padding(.bottom, 2)
                
                // Card 1: 5 anställda (Passerad)
                RadarThresholdCard(
                    threshold: store.l10n.runwayCard5Threshold,
                    statute: "AML § 6-1",
                    title: store.l10n.runwayCard5Title,
                    statusText: store.l10n.runwayCard5Status,
                    statusColor: SolTokens.green800,
                    description: store.l10n.runwayCard5Desc,
                    isActive: false,
                    footerNotice: store.l10n.runwayCard5Footer,
                    footerIcon: "checkmark.shield.fill"
                )
                
                // Card 2: 8 anställda (Aktiv fas - Fjord Dynamics)
                RadarThresholdCard(
                    threshold: store.l10n.runwayCard8Threshold,
                    statute: "AML § 14-6 & § 10-2",
                    title: store.l10n.runwayCard8Title,
                    statusText: store.l10n.runwayCard8Status,
                    statusColor: SolTokens.amber400,
                    description: store.l10n.runwayCard8Desc,
                    isActive: true,
                    actionTitle: store.l10n.runwayCard8Action,
                    onAction: {
                        withAnimation {
                            store.activeNav = "hub"
                        }
                    }
                )
                
                // Card 3: 10 anställda (Nästa tröskel)
                RadarThresholdCard(
                    threshold: store.l10n.runwayCard10Threshold,
                    statute: "AML § 7-1",
                    title: store.l10n.runwayCard10Title,
                    statusText: store.l10n.radarCard10Status(remaining: max(0, 10 - store.currentScenario.headcount)),
                    statusColor: SolTokens.amber400,
                    description: store.l10n.runwayCard10Desc,
                    isActive: false,
                    footerNotice: store.l10n.runwayCard10Footer,
                    footerIcon: "shield.lefthalf.filled"
                )
                
                // Card 4: 50 anställda (Framtida tillväxtfas)
                RadarThresholdCard(
                    threshold: store.l10n.runwayCard50Threshold,
                    statute: "AML § 8-1 & Likestillingsloven § 26",
                    title: store.l10n.runwayCard50Title,
                    statusText: store.l10n.runwayCard50Status,
                    statusColor: SolTokens.ink600,
                    description: store.l10n.runwayCard50Desc,
                    isActive: false,
                    footerNotice: store.l10n.runwayCard50Footer,
                    footerIcon: "cloud.fill"
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
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
                    
                    // Active Case #2841 (CEO inquiry with Camilla Schie-Veslum)
                    HStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            if let img = SolTokens.camillaAvatar {
                                Image(nsImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(SolTokens.paper300, lineWidth: 1.5))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [SolTokens.plum900, SolTokens.plum800],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                    Text("CS")
                                        .font(.inter(11.5, .bold))
                                        .foregroundColor(SolTokens.lav50)
                                }
                                .frame(width: 36, height: 36)
                            }
                            
                            // Active status dot
                            Circle()
                                .fill(SolTokens.green800)
                                .frame(width: 8.5, height: 8.5)
                                .overlay(Circle().stroke(SolTokens.paper50, lineWidth: 1.5))
                                .offset(x: 1, y: 1)
                        }
                        .frame(width: 36, height: 36)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(store.l10n.hubJuristEscalationTitle)
                                    .font(.inter(12.5, .bold))
                                    .foregroundColor(SolTokens.ink900)
                                
                                Text("#2841")
                                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1.5)
                                    .background(SolTokens.paper250)
                                    .foregroundColor(SolTokens.ink600)
                                    .cornerRadius(3)
                                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(SolTokens.paper300, lineWidth: 0.8))
                            }
                            
                            Text(store.l10n.hubJuristAssignedTo + " · " + (store.language == .se ? "Skickat 09:15" : (store.language == .no ? "Sendt 09:15" : "Submitted 09:15")))
                                .font(.inter(11))
                                .foregroundColor(SolTokens.ink600)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 5) {
                            Image(systemName: "clock.badge.checkmark.fill")
                                .font(.system(size: 9))
                                .foregroundColor(SolTokens.amber400)
                            Text(store.l10n.hubJuristEscalationStatus)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(SolTokens.amber400)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(SolTokens.amber100)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(SolTokens.amber400.opacity(0.35), lineWidth: 1)
                        )
                    }
                    .padding(12)
                    .background(SolTokens.paper50)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))

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
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }
    
    // MARK: - Compliance Runway Helpers
    private enum RunwayNodeStatus {
        case passed
        case current
        case upcoming
        case future
    }
    
    private var runwayMilestoneBar: some View {
        HStack(spacing: 0) {
            runwayNode(
                step: "5",
                label: store.l10n.runwayMilestonePassed,
                status: .passed,
                isCurrent: false
            )
            
            // Connecting line: 5 -> 8 (solid green)
            Rectangle()
                .fill(SolTokens.green800.opacity(0.45))
                .frame(height: 2)
            
            runwayNode(
                step: "8",
                label: store.l10n.runwayMilestoneCurrent,
                status: .current,
                isCurrent: true
            )
            
            // Connecting line: 8 -> 10 (amber dashed)
            dashedLine(color: SolTokens.amber400.opacity(0.65), dashCount: 7)
            
            runwayNode(
                step: "10",
                label: store.l10n.runwayMilestoneNext,
                status: .upcoming,
                isCurrent: false
            )
            
            // Connecting line: 10 -> 50 (neutral dashed)
            dashedLine(color: SolTokens.paper300, dashCount: 11)
            
            runwayNode(
                step: "50+",
                label: store.l10n.runwayMilestoneFuture,
                status: .future,
                isCurrent: false
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SolTokens.paper200)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper250, lineWidth: 1))
    }
    
    private func dashedLine(color: Color, dashCount: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<dashCount, id: \.self) { _ in
                Rectangle()
                    .fill(color)
                    .frame(width: 4, height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func runwayNode(step: String, label: String, status: RunwayNodeStatus, isCurrent: Bool) -> some View {
        VStack(spacing: 5) {
            ZStack {
                switch status {
                case .passed:
                    Circle()
                        .fill(SolTokens.green800.opacity(0.14))
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SolTokens.green800)
                case .current:
                    Circle()
                        .fill(SolTokens.lav400.opacity(0.18))
                        .frame(width: 28, height: 28)
                    Circle()
                        .stroke(SolTokens.lav400, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    Text(step)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.lav400)
                case .upcoming:
                    Circle()
                        .fill(SolTokens.amber400.opacity(0.14))
                        .frame(width: 26, height: 26)
                    Circle()
                        .stroke(SolTokens.amber400.opacity(0.5), lineWidth: 1)
                        .frame(width: 26, height: 26)
                    Text(step)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.amber400)
                case .future:
                    Circle()
                        .fill(SolTokens.paper250)
                        .frame(width: 24, height: 24)
                    Text(step)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                }
            }
            
            HStack(spacing: 3) {
                if isCurrent {
                    Circle()
                        .fill(SolTokens.lav400)
                        .frame(width: 4, height: 4)
                }
                Text(label)
                    .font(.system(size: 10, weight: isCurrent ? .bold : .medium))
                    .foregroundColor(isCurrent ? SolTokens.ink900 : SolTokens.ink600)
            }
            .lineLimit(1)
        }
        .frame(minWidth: 70)
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
                                        text: "v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.1") (Build \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))",
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
                
                // SECTION: SPRÅK & REGION
                VStack(alignment: .leading, spacing: 12) {
                    Text("SPRÅK & REGION")
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
                                Image(systemName: "globe")
                                    .font(.inter(18))
                                    .foregroundColor(SolTokens.ink700)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Gränssnittsspråk & Jurisdiktion")
                                    .font(.inter(14, .bold))
                                    .foregroundColor(SolTokens.ink900)
                                Text("Välj aktivt språk för applikationen, laghänvisningar och avtalsklausuler.")
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                ForEach(AppLanguage.allCases) { lang in
                                    let isSelected = store.language == lang
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            store.setLanguage(lang)
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(lang.flag)
                                                .font(.system(size: 13))
                                            Text(lang.displayName)
                                                .font(.inter(12, isSelected ? .bold : .medium))
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(SolTokens.lav400)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6.5)
                                        .background(isSelected ? SolTokens.lav100 : SolTokens.paper200)
                                        .foregroundColor(isSelected ? SolTokens.lav400 : SolTokens.ink700)
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(isSelected ? SolTokens.lav600.opacity(0.4) : SolTokens.paper300, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(SolTokens.paper100)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                // SECTION: DEMO & PRESENTATION
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("DEMO & PRESENTATION")
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                            .padding(.horizontal, 2)
                        Spacer()
                        Text("Snabbkommando: ⌘D · Autoplay: ⌘P")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                    }
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(SolTokens.paper200)
                                    .frame(width: 40, height: 40)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                                Image(systemName: "slider.horizontal.2.square")
                                    .font(.inter(18))
                                    .foregroundColor(SolTokens.ink700)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text(store.l10n.demoControllerTitle)
                                        .font(.inter(14, .bold))
                                        .foregroundColor(SolTokens.ink900)
                                    
                                    if autoplay.isPlaying {
                                        LinearStatusPill(text: "Autoplay aktiv", dotColor: SolTokens.red700)
                                    }
                                }
                                Text("Styr tidslinjeår (2024–2026), automatiserad demoberättelse och återställning.")
                                    .font(.inter(12))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                // Autoplay button
                                Button {
                                    if autoplay.isPlaying {
                                        autoplay.stopDemo { card in
                                            expandedHubCard = card
                                        }
                                    } else {
                                        store.activeNav = "hub"
                                        autoplay.startDemo(store: store) { card in
                                            expandedHubCard = card
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: autoplay.isPlaying ? "stop.fill" : "play.fill")
                                            .font(.inter(11))
                                        Text(autoplay.isPlaying ? "Stoppa autoplay" : "Starta autoplay (⌘P)")
                                            .font(.inter(12, .semibold))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6.5)
                                    .background(autoplay.isPlaying ? SolTokens.red100 : SolTokens.plum900)
                                    .foregroundColor(autoplay.isPlaying ? SolTokens.red700 : SolTokens.lav50)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(autoplay.isPlaying ? SolTokens.redBorder : SolTokens.lav600.opacity(0.4), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // Direct Reset Demo Button
                                Button {
                                    resetEntirePrototype()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.inter(11))
                                        Text(store.language == .se ? "Återställ demo (⌘R)" : (store.language == .no ? "Tilbakestill demo (⌘R)" : "Reset demo (⌘R)"))
                                            .font(.inter(12, .semibold))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6.5)
                                    .background(SolTokens.paper200)
                                    .foregroundColor(SolTokens.ink700)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(SolTokens.paper300, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // Open Demo Popover Button
                                Button {
                                    showDemoControls.toggle()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "slider.horizontal.2.square")
                                            .font(.inter(11))
                                        Text("Öppna panel (⌘D)")
                                            .font(.inter(12, .semibold))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6.5)
                                    .background(showDemoControls ? SolTokens.lav100 : SolTokens.paper200)
                                    .foregroundColor(showDemoControls ? SolTokens.lav400 : SolTokens.ink700)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(showDemoControls ? SolTokens.lav600.opacity(0.4) : SolTokens.paper300, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .keyboardShortcut("d", modifiers: .command)
                                .popover(isPresented: $showDemoControls, arrowEdge: .bottom) {
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
                                            resetEntirePrototype()
                                        }
                                    )
                                }
                            }
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
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
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
                sourcesThreeColumnsGrid
                heroDropzoneView
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Sources Header
    private var ingestHeaderView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(store.language == .se ? "Källor & Dokumentövervakning" : (store.language == .no ? "Kilder & Dokumentovervåking" : "Sources & Document Sentinel"))
                    .font(.inter(18, .bold))
                    .foregroundColor(SolTokens.ink900)
                Text(store.language == .se 
                    ? "Comply ansluter direkt till företagets befintliga system för att automatiskt bevaka avtal, stämplingar och myndighetskrav i realtid." 
                    : (store.language == .no 
                        ? "Comply kobler seg direkte til bedriftens eksisterende systemer for å overvåke avtaler, stemplinger og myndighetskrav i sanntid." 
                        : "Comply connects directly to your systems to monitor contracts, attendance and statutory regulations in real time."))
                    .font(.inter(12.5))
                    .foregroundColor(SolTokens.ink600)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(SolTokens.green800)
                        .frame(width: 6, height: 6)
                    Text(store.language == .se ? "4 / 4 källor anslutna" : (store.language == .no ? "4 / 4 kilder tilkoblet" : "4 / 4 sources connected"))
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(SolTokens.green800)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(SolTokens.green100)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.greenBorder, lineWidth: 1))
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        store.activeNav = "hub"
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 11))
                        Text(store.language == .se ? "Gå till åtgärder (\(store.pendingActionCount))" : (store.language == .no ? "Gå til handlinger (\(store.pendingActionCount))" : "Go to actions (\(store.pendingActionCount))"))
                            .font(.inter(11.5, .semibold))
                    }
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(SolTokens.sidebarActivePill)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - 4-Column Branded Sources Grid (Matching Overview Pillars)
    private var sourcesThreeColumnsGrid: some View {
        HStack(alignment: .top, spacing: 12) {
            // Column 1: SharePoint & Cloud Docs (Branded Indigo / Blue)
            sourcesColumnCard(
                brandColor: Color.blue,
                brandBg: Color.blue.opacity(0.12),
                icon: "cloud.fill",
                statusPill: store.language == .se ? "Realtidssynk" : (store.language == .no ? "Sanntidssynk" : "Live sync"),
                statusColor: SolTokens.green800,
                statusBg: SolTokens.green100,
                title: "Microsoft 365 / SharePoint",
                subtitle: "simployer.sharepoint.com/sites/hr",
                metric: store.language == .se ? "42 dokument indexerade" : (store.language == .no ? "42 dokumenter indeksert" : "42 documents indexed"),
                description: store.language == .se 
                    ? "8 anställningsavtal & 1 personalhandbok övervakas löpande. Ändrade filer tolkas automatiskt mot arbetsmiljölagen vid sparning." 
                    : (store.language == .no 
                        ? "8 ansettelsesavtaler og personalhåndbok overvåkes løpende. Endringer tolkes automatisk mot AML." 
                        : "8 employment contracts and handbook monitored continuously. Changes parsed automatically against labor law."),
                footerMeta: store.language == .se ? "Lokal kopia på Macen: Dokument/Personalakter" : (store.language == .no ? "Lokal kopi på Macen: Dokumenter/Personalmapper" : "Local folder on Mac: Documents/HR"),
                actionTitle: store.language == .se ? "Konfigurera mapp" : (store.language == .no ? "Konfigurer mappe" : "Configure folder"),
                action: {}
            )
            
            // Column 2: Google Workspace & Drive (Branded Amber / Yellow)
            sourcesColumnCard(
                brandColor: Color(hex: 0xF59E0B),
                brandBg: Color(hex: 0xF59E0B).opacity(0.12),
                icon: "folder.fill.badge.gearshape",
                statusPill: store.language == .se ? "Realtidssynk" : (store.language == .no ? "Sanntidssynk" : "Live sync"),
                statusColor: SolTokens.green800,
                statusBg: SolTokens.green100,
                title: "Google Workspace & Drive",
                subtitle: "drive.google.com/fjord-dynamics",
                metric: store.language == .se ? "14 policyer indexerade" : (store.language == .no ? "14 retningslinjer indeksert" : "14 policies indexed"),
                description: store.language == .se 
                    ? "Övervakar onboarding-dokument, personalpolicyer och HMS-rutiner i delade företagsmappar." 
                    : (store.language == .no 
                        ? "Overvåker onboarding-dokumenter, personalpolicyer og HMS-rutiner i delte mapper." 
                        : "Monitors onboarding docs, policies, and HSE guidelines in shared folders."),
                footerMeta: store.language == .se ? "Drive Webhook aktiv" : (store.language == .no ? "Drive Webhook aktiv" : "Drive Webhook active"),
                actionTitle: store.language == .se ? "Konfigurera mapp" : (store.language == .no ? "Konfigurer mappe" : "Configure folder"),
                action: {}
            )
            
            // Column 3: Fortnox / Tripletex (Branded Emerald / Green)
            sourcesColumnCard(
                brandColor: SolTokens.green800,
                brandBg: SolTokens.green100,
                icon: "clock.badge.checkmark.fill",
                statusPill: store.language == .se ? "Synkad idag 06:00" : (store.language == .no ? "Synkronisert 06:00" : "Synced 06:00"),
                statusColor: SolTokens.green800,
                statusBg: SolTokens.green100,
                title: store.language == .se ? "Fortnox Lön & Tid API" : (store.language == .no ? "Tripletex Lønn & Tid API" : "Payroll & Attendance API"),
                subtitle: "Klient #8921-FD · Kontinuerlig API-synk",
                metric: store.language == .se ? "8 anställda aktiva" : (store.language == .no ? "8 ansatte aktive" : "8 employees active"),
                description: store.language == .se 
                    ? "Matchar stämplingar mot AML kap. 10 för 11h dygnsvila och max övertid. Verifierar löneskillnader inför årlig lönekartläggning." 
                    : (store.language == .no 
                        ? "Matcher stemplinger mot AML kap. 10 for døgnhvile og overtid. Verifiserer lønnsforskjeller." 
                        : "Matches clock-ins against statutory rest & overtime. Verifies wage parity for annual gender pay audits."),
                footerMeta: store.language == .se ? "Nästa körning: Imorgon 06:00" : (store.language == .no ? "Neste kjøring: I morgen 06:00" : "Next run: Tomorrow 06:00"),
                actionTitle: store.language == .se ? "Synka data nu ↻" : (store.language == .no ? "Synk data nå ↻" : "Sync now ↻"),
                action: {}
            )
            
            // Column 4: Government Registry & Radar (Branded Plum / Lavender)
            sourcesColumnCard(
                brandColor: SolTokens.lav500,
                brandBg: SolTokens.lav100,
                icon: "building.columns.fill",
                statusPill: store.language == .se ? "Tröskelradar aktiv" : (store.language == .no ? "Terskelradar aktiv" : "Radar active"),
                statusColor: SolTokens.green800,
                statusBg: SolTokens.green100,
                title: store.language == .se ? "Bolagsverket & Myndigheter" : (store.language == .no ? "Brønnøysund & Arbeidstilsynet" : "Registry & Labour Authority"),
                subtitle: store.language == .se ? "Org.nr 556928-3419 (Fjord Dynamics)" : (store.language == .no ? "Org.nr 928 341 902 (Fjord Dynamics)" : "Org.nr 928 341 902"),
                metric: store.language == .se ? "Tröskel: 5 anställda passerad" : (store.language == .no ? "Terskel: 5 ansatte passert" : "Threshold: 5 employees passed"),
                description: store.language == .se 
                    ? "Känner av när bolaget passerar lagstadgade personalgränser (skyddsombud vid 5, AMU vid 10/50) och hämtar nya föreskrifter i realtid." 
                    : (store.language == .no 
                        ? "Oppdager når bedriften passerer lovfestede grenser (verneombud ved 5, AMU ved 10/50) og henter forskrifter automatisk." 
                        : "Detects statutory headcount triggers (safety rep at 5, committee at 10/50) and updates compliance rules automatically."),
                footerMeta: store.language == .se ? "Aktuellt utdrag: Verifierat idag" : (store.language == .no ? "Gjeldende utskrift: Verifisert" : "Verified today"),
                actionTitle: store.language == .se ? "Kontrollera register" : (store.language == .no ? "Kontroller register" : "Verify registry"),
                action: {}
            )
        }
    }
    
    private func sourcesColumnCard(
        brandColor: Color,
        brandBg: Color,
        icon: String,
        statusPill: String,
        statusColor: Color,
        statusBg: Color,
        title: String,
        subtitle: String,
        metric: String,
        description: String,
        footerMeta: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top: Branded Icon + Status Pill
            HStack(alignment: .center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(brandBg)
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(brandColor)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 5, height: 5)
                    Text(statusPill)
                        .font(.inter(10.5, .bold))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusBg)
                .cornerRadius(5)
            }
            
            // Header & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.inter(14, .bold))
                    .foregroundColor(SolTokens.ink900)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
                    .lineLimit(1)
            }
            
            // Big Metric / Outcome Headline
            Text(metric)
                .font(.inter(13, .semibold))
                .foregroundColor(SolTokens.ink800)
            
            // Description
            Text(description)
                .font(.inter(11.5, .regular))
                .foregroundColor(SolTokens.ink600)
                .lineSpacing(2)
                .frame(minHeight: 52, alignment: .topLeading)
            
            Divider().overlay(SolTokens.paper300.opacity(0.6))
            
            // Footer Metadata
            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundColor(statusColor)
                Text(footerMeta)
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundColor(SolTokens.ink600)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 4)
            
            // Action Button
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(actionTitle)
                        .font(.inter(11.5, .semibold))
                        .foregroundColor(brandColor)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(brandColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(brandBg.opacity(0.5))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(brandColor.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(SolTokens.paper100)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SolTokens.paper300, lineWidth: 1)
        )
    }

    private var heroDropzoneView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    isDropTargeted ? SolTokens.lav400 : (isAnalyzingDrop ? SolTokens.lav400.opacity(0.6) : SolTokens.paper300),
                    style: StrokeStyle(lineWidth: 1, dash: isAnalyzingDrop ? [] : [5, 5])
                )
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isDropTargeted || isAnalyzingDrop ? SolTokens.lav400.opacity(0.06) : SolTokens.paper50.opacity(0.5))
                )
            
            if isAnalyzingDrop {
                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(dropAnalysisStage == 4 ? SolTokens.green100 : SolTokens.lav100)
                                .frame(width: 38, height: 38)
                            Image(systemName: dropAnalysisStage == 4 ? "checkmark.seal.fill" : "doc.text.magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(dropAnalysisStage == 4 ? SolTokens.green800 : SolTokens.lav400)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(dropFileName)
                                    .font(.inter(13, .semibold))
                                    .foregroundColor(SolTokens.ink900)
                                
                                Text("· 8 anställda")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(SolTokens.ink450)
                            }
                            
                            Text(dropStageDescription)
                                .font(.inter(11.5))
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
                                .font(.inter(11.5, .semibold))
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(SolTokens.plum900)
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Progress Bar
                    VStack(alignment: .trailing, spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(SolTokens.paper300)
                                    .frame(height: 5)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(dropAnalysisStage == 4 ? SolTokens.green800 : SolTokens.lav400)
                                    .frame(width: max(0, geo.size.width * dropProgress), height: 5)
                                    .animation(.easeInOut(duration: 0.35), value: dropProgress)
                            }
                        }
                        .frame(height: 5)
                        
                        HStack {
                            Text(dropAnalysisStage == 4 ? "100 % slutfört" : "\(Int(dropProgress * 100)) %")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
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
                .padding(16)
                .transition(.opacity)
            } else {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(SolTokens.lav400.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.system(size: 17))
                            .foregroundColor(SolTokens.lav400)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.language == .se ? "Manuell dokumentimport (Fallback)" : (store.language == .no ? "Manuell dokumentimport (Fallback)" : "Manual Document Ingestion (Fallback)"))
                            .font(.inter(12.5, .semibold))
                            .foregroundColor(SolTokens.ink900)
                        Text(store.language == .se 
                            ? "Har ni avtal som ännu inte sparats i molnet? Släpp PDF- eller Word-filer här för omedelbar granskning." 
                            : (store.language == .no 
                                ? "Har dere avtaler som ikke er i skyen? Slipp PDF- eller Word-filer her for umiddelbar gjennomgang." 
                                : "Have contracts not in cloud storage? Drop PDF or Word files here for instant legal analysis."))
                            .font(.inter(11))
                            .foregroundColor(SolTokens.ink450)
                    }
                    
                    Spacer()
                    
                    Button {
                        #if os(macOS)
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = true
                        panel.canChooseDirectories = true
                        panel.allowsMultipleSelection = false
                        panel.prompt = store.language == .se ? "Välj fil" : "Select file"
                        if panel.runModal() == .OK, let url = panel.url {
                            startSimulatedIngestion(fileName: url.lastPathComponent)
                        }
                        #endif
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "doc.badge.plus")
                            Text(store.language == .se ? "Välj från Mac..." : (store.language == .no ? "Velg fra Mac..." : "Choose from Mac..."))
                        }
                        .font(.inter(11.5, .medium))
                        .foregroundColor(SolTokens.ink800)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(SolTokens.paper200)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .frame(maxWidth: .infinity)
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
        let contractGaps = store.currentScenario.employees.filter { $0.status == .aml14Gap }.count
        let isHmsPending = !store.hmsTrainingEnrolled && store.currentScenario.employees.contains { $0.id == "01" }
        let otherIssues = store.currentScenario.employees.filter { $0.status == .sickD14 || $0.status == .probationSoon }.count
        let issuesCount = contractGaps + (isHmsPending ? 1 : 0) + otherIssues
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
                    
                    if okCount > 0 {
                        Text("·")
                            .foregroundColor(SolTokens.ink450)
                        HStack(spacing: 4) {
                            Circle().fill(SolTokens.green800).frame(width: 5, height: 5)
                            Text("\(okCount) \(store.l10n.directoryCompliantSummary)")
                                .font(.inter(12, .medium))
                                .foregroundColor(SolTokens.ink700)
                        }
                    }
                    
                    if contractGaps > 0 {
                        Text("·")
                            .foregroundColor(SolTokens.ink450)
                        HStack(spacing: 4) {
                            Circle().fill(SolTokens.amber400).frame(width: 5, height: 5)
                            Text(store.language == .se ? "\(contractGaps) kräver avtalsuppdatering" : (store.language == .no ? "\(contractGaps) krever avtaleoppdatering" : "\(contractGaps) require contract update"))
                                .font(.inter(12, .medium))
                                .foregroundColor(SolTokens.amber400)
                        }
                    }
                    
                    if isHmsPending {
                        Text("·")
                            .foregroundColor(SolTokens.ink450)
                        HStack(spacing: 4) {
                            Circle().fill(SolTokens.lav400).frame(width: 5, height: 5)
                            Text(store.language == .se ? "1 utbildningskrav" : (store.language == .no ? "1 opplæringskrav" : "1 training requirement"))
                                .font(.inter(12, .medium))
                                .foregroundColor(SolTokens.lav400)
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                // Autonomous sync status pill
                HStack(spacing: 5) {
                    Circle()
                        .fill(SolTokens.emerald800)
                        .frame(width: 5.5, height: 5.5)
                    Text(store.language == .se ? "Synkad med Fortnox & personalakter" : (store.language == .no ? "Synket med Tripletex & personalmapper" : "Synced with HR & payroll records"))
                        .font(.inter(11.5))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5.5)
                .background(SolTokens.paper100)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                
                if contractGaps > 0 {
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                            store.approveAllContracts()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "signature")
                                .font(.inter(11, .semibold))
                            Text(store.language == .se ? "Uppdatera alla \(contractGaps) avtal (BankID)" : (store.language == .no ? "Oppdater alle \(contractGaps) avtaler (BankID)" : "Update all \(contractGaps) contracts (BankID)"))
                        }
                        .font(.inter(12, .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(SolTokens.plum900)
                        .foregroundColor(Color.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 2)
    }

    private var registerFilterBar: some View {
        let totalCount = store.currentScenario.employees.count
        let contractGaps = store.currentScenario.employees.filter { $0.status == .aml14Gap }.count
        let isHmsPending = !store.hmsTrainingEnrolled && store.currentScenario.employees.contains { $0.id == "01" }
        let otherIssues = store.currentScenario.employees.filter { $0.status == .sickD14 || $0.status == .probationSoon }.count
        let issuesCount = contractGaps + (isHmsPending ? 1 : 0) + otherIssues
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
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 9))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colEmployee)
                Spacer()
            }
            .frame(width: CGFloat(colEmployeeWidth), alignment: .leading)
            
            TableColumnResizeHandle(
                width: $colEmployeeWidth,
                minWidth: 160,
                maxWidth: 360,
                defaultWidth: 220
            )
            
            HStack(spacing: 5) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 8.5))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colRoleDept)
                Spacer()
            }
            .frame(width: CGFloat(colRoleDeptWidth), alignment: .leading)
            
            TableColumnResizeHandle(
                width: $colRoleDeptWidth,
                minWidth: 180,
                maxWidth: 450,
                defaultWidth: 300
            )
            
            HStack(spacing: 5) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 8.5))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colSalary)
                Spacer()
            }
            .frame(width: CGFloat(colEmploymentWidth), alignment: .leading)
            
            TableColumnResizeHandle(
                width: $colEmploymentWidth,
                minWidth: 150,
                maxWidth: 340,
                defaultWidth: 210
            )
            
            HStack(spacing: 5) {
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 8.5))
                    .foregroundColor(SolTokens.ink450)
                Text(store.l10n.colStatus)
                Spacer()
            }
            .frame(width: CGFloat(colStatusWidth), alignment: .leading)
            
            TableColumnResizeHandle(
                width: $colStatusWidth,
                minWidth: 170,
                maxWidth: 400,
                defaultWidth: 240
            )
            
            Spacer()
            
            Text(store.l10n.colAction)
                .frame(width: 98, alignment: .trailing)
        }
        .font(.system(size: 11, weight: .semibold, design: .monospaced))
        .foregroundColor(SolTokens.ink450)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(SolTokens.paper100)
    }

    private func registerEmployeeRow(emp: Employee) -> some View {
        let isHmsIssue = (emp.statusLabel.contains("Mangler") || emp.statusLabel.contains("Saknar") || emp.statusLabel.contains("Missing")) && !store.hmsTrainingEnrolled
        let isEmployeeOk = emp.status == .ok && !isHmsIssue
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
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
                .frame(width: CGFloat(colEmployeeWidth), alignment: .leading)
                
                // Gap matching the divider width (10pt)
                Color.clear.frame(width: 10)
                
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
                .frame(width: CGFloat(colRoleDeptWidth), alignment: .leading)
                
                Color.clear.frame(width: 10)
                
                // Employment Type & Contract Template (replaces raw salary exposure)
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedEmploymentType(emp.type, lang: store.language))
                        .font(.inter(12, .medium))
                        .foregroundColor(SolTokens.ink900)
                    Text(emp.contractVersion)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                }
                .frame(width: CGFloat(colEmploymentWidth), alignment: .leading)
                
                Color.clear.frame(width: 10)
                
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
                .frame(width: CGFloat(colStatusWidth), alignment: .leading)
                
                Spacer()
                
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
        let isHmsDone = store.hmsTrainingEnrolled
        
        return Group {
            if isHmsDone {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(SolTokens.green800)
                        .font(.inter(15))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.language == .se ? "Lagstadgade utbildningar säkrade" : (store.language == .no ? "Lovpålagt opplæring fullført" : "Statutory training verified"))
                            .font(.inter(12, .bold))
                            .foregroundColor(SolTokens.ink900)
                        Text(store.language == .se ? "Godkänt SAM/HMS-kursintyg för VD är arkiverat och kopplat till bolagets revisionsprofil." : (store.language == .no ? "Godkjent HMS-kursbevis for daglig leder er arkivert og koblet til selskapets revisjonsprofil." : "Approved certificate archived."))
                            .font(.inter(11))
                            .foregroundColor(SolTokens.ink600)
                    }
                    Spacer()
                }
                .padding(12)
                .background(SolTokens.green800.opacity(0.08))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.green800.opacity(0.25), lineWidth: 1))
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "graduationcap.fill")
                        .foregroundColor(SolTokens.lav500)
                        .font(.inter(15))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.language == .se ? "Obligatorisk utbildning för VD: SAM-kurs" : (store.language == .no ? "Lovpålagt opplæring: HMS-kurs for daglig leder" : "Mandatory CEO training: OHS Course"))
                            .font(.inter(12.5, .bold))
                            .foregroundColor(SolTokens.ink900)
                        Text(store.language == .se ? "Enligt Arbetsmiljölagen krävs godkänt kursintyg för VD. Kan genomföras digitalt på 4 timmar." : (store.language == .no ? "AML § 3-5 krever at daglig leder har gjennomgått HMS-opplæring. Kan gjennomføres digitalt på 4 timer." : "AML § 3-5 requires approved training. Can be completed digitally."))
                            .font(.inter(11.5))
                            .foregroundColor(SolTokens.ink700)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                            store.enrollHmsCourse()
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "book.closed.fill")
                                .font(.inter(11))
                            Text(store.language == .se ? "Boka via Simployer Learn" : (store.language == .no ? "Meld på via Simployer Learn" : "Enroll via Simployer Learn"))
                        }
                        .font(.inter(11.5, .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(SolTokens.plum900)
                        .foregroundColor(Color.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(13)
                .background(SolTokens.paper100)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.lav500.opacity(0.35), lineWidth: 1))
            }
        }
    }

    private var macRegisterTableView: some View {
        VStack(spacing: 14) {
            registerToastView
            registerHeaderView
            registerFilterBar
            registerTableContent
            registerUpsellBar
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }
}

fileprivate func localizedEmploymentType(_ raw: String, lang: AppLanguage) -> String {
    if lang == .se {
        return raw
            .replacingOccurrences(of: "Fast", with: "Tillsvidare")
            .replacingOccurrences(of: "Prøvetid", with: "Provanställning")
    } else if lang == .en {
        return raw
            .replacingOccurrences(of: "Fast", with: "Permanent")
            .replacingOccurrences(of: "Prøvetid", with: "Probation")
    }
    return raw
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
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                action()
            }
        } label: {
            let active = activeNav == id
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(active ? Color.white : (isHovered ? SolTokens.ink900 : SolTokens.ink450))
                    .frame(width: 18, height: 18, alignment: .center)
                    .layoutPriority(1)
                
                Text(label)
                    .font(.inter(13, active ? .semibold : .medium))
                    .foregroundColor(active ? Color.white : (isHovered ? SolTokens.ink900 : SolTokens.ink700))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(0)
                
                Spacer(minLength: 4)
                
                if badgeStyle == .dot {
                    Circle()
                        .fill(SolTokens.green800)
                        .frame(width: 5.5, height: 5.5)
                        .padding(.trailing, 2)
                        .layoutPriority(1)
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
                        .layoutPriority(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6.5)
            .contentShape(Rectangle())
            .background(active ? SolTokens.sidebarActivePill : (isHovered ? SolTokens.paper200.opacity(0.6) : Color.clear))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    sidebarWidth = min(max(newWidth, minWidth), maxWidth).rounded()
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

// MARK: - Draggable Table Column Divider (macOS Native Tactile Column Resizer)
struct TableColumnResizeHandle: View {
    @Binding var width: Double
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
            // Invisible wider hit-testing zone (10pt)
            Rectangle()
                .fill(Color.clear)
                .frame(width: 10, height: 26)
                .contentShape(Rectangle())
            
            // Tactile 1px divider, glows lavender on hover/drag
            Rectangle()
                .fill(
                    isDragging
                        ? SolTokens.lav500
                        : (isHovering ? SolTokens.lav400 : SolTokens.paper300.opacity(0.8))
                )
                .frame(width: isDragging || isHovering ? 2 : 1, height: 16)
                .cornerRadius(1)
                .animation(.easeOut(duration: 0.15), value: isHovering)
                .animation(.easeOut(duration: 0.15), value: isDragging)
        }
        .frame(width: 10)
        .onHover { hovering in
            isHovering = hovering
            updateCursor(active: hovering || isDragging)
        }
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .global)
                .onChanged { gesture in
                    if dragInitialWidth == nil {
                        dragInitialWidth = width
                        isDragging = true
                        updateCursor(active: true)
                    }
                    let newWidth = (dragInitialWidth ?? defaultWidth) + Double(gesture.translation.width)
                    width = min(max(newWidth, minWidth), maxWidth)
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
                    width = defaultWidth
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
                    isPresented = false
                    onReset?()
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

// MARK: - Linear Craft Helper Cards & Multi-Handbook System

public enum HandbookVolume: String, CaseIterable, Identifiable, Sendable {
    case staff = "staff"
    case leadership = "leadership"
    case hms = "hms"
    
    public var id: String { rawValue }
    
    public func title(for lang: AppLanguage) -> String {
        switch lang {
        case .se:
            switch self {
            case .staff: return "Personalhandbok"
            case .leadership: return "Ledarhandbok"
            case .hms: return "HMS & Arbetsmiljö"
            }
        case .no:
            switch self {
            case .staff: return "Personalhåndbok"
            case .leadership: return "Lederhåndbok"
            case .hms: return "HMS & Sikkerhet"
            }
        case .en:
            switch self {
            case .staff: return "Employee Handbook"
            case .leadership: return "Manager Handbook"
            case .hms: return "HSE & Safety"
            }
        }
    }
    
    public var icon: String {
        switch self {
        case .staff: return "book.closed.fill"
        case .leadership: return "briefcase.fill"
        case .hms: return "shield.checkered"
        }
    }
    
    public func companyTitle(for lang: AppLanguage) -> String {
        switch lang {
        case .se:
            switch self {
            case .staff: return "Fjord Dynamics Personalhandbok"
            case .leadership: return "Fjord Dynamics Ledarhandbok"
            case .hms: return "Fjord Dynamics HMS & Arbetsmiljöhandbok"
            }
        case .no:
            switch self {
            case .staff: return "Fjord Dynamics Personalhåndbok"
            case .leadership: return "Fjord Dynamics Lederhåndbok"
            case .hms: return "Fjord Dynamics HMS- & Sikkerhetshåndbok"
            }
        case .en:
            switch self {
            case .staff: return "Fjord Dynamics Employee Handbook"
            case .leadership: return "Fjord Dynamics Manager Handbook"
            case .hms: return "Fjord Dynamics HSE & Safety Handbook"
            }
        }
    }
    
    public func versionBadge(for lang: AppLanguage) -> String {
        switch self {
        case .staff: return "v2024.2"
        case .leadership: return "v2024.1"
        case .hms: return "v2024.3"
        }
    }
    
    public func subtitle(for lang: AppLanguage) -> String {
        switch lang {
        case .se:
            switch self {
            case .staff: return "Gällande version 2024.2 · Alla 8 medarbetare har signerat med BankID · Uppdateras automatiskt mot arbetsrätt"
            case .leadership: return "Konfidentiellt chefsstöd v2024.1 · 2 av 2 ledare har bekräftat · AML § 15-1 & MBL-rutiner"
            case .hms: return "Lagstadgad internkontroll v2024.3 · Medsignerat av skyddsombud · Revideras årligen"
            }
        case .no:
            switch self {
            case .staff: return "Gjeldende versjon 2024.2 · Alle 8 ansatte har signert med BankID · Holdes automatisk oppdatert mot arbeidsmiljøloven"
            case .leadership: return "Konfidensiell lederstøtte v2024.1 · 2 av 2 ledere har bekreftet · AML § 15-1 drøftelsesrutiner"
            case .hms: return "Lovfestet internkontroll v2024.3 · Medsignert av verneombud · Revideres årlig"
            }
        case .en:
            switch self {
            case .staff: return "Active version 2024.2 · All 8 staff members confirmed via BankID · Kept continuously compliant with labor law"
            case .leadership: return "Confidential leadership playbook v2024.1 · 2 of 2 leaders confirmed · WEA/AML dismissal protocols"
            case .hms: return "Statutory HSE internal control v2024.3 · Co-signed with Safety Representative · Annual audit"
            }
        }
    }
    
    public func audienceBadge(for lang: AppLanguage) -> String {
        switch lang {
        case .se:
            switch self {
            case .staff: return "Alla 8 anställda · BankID-signerat"
            case .leadership: return "Endast ledning (2 behöriga · Jonas B, Silje O)"
            case .hms: return "Lagkrav · Skyddsombud Kasper R medsignerad"
            }
        case .no:
            switch self {
            case .staff: return "Alle 8 ansatte · BankID-signert"
            case .leadership: return "Kun ledere (2 med tilgang · Jonas B, Silje O)"
            case .hms: return "Lovkrav · Verneombud Kasper R medsignert"
            }
        case .en:
            switch self {
            case .staff: return "All 8 employees · BankID signed"
            case .leadership: return "Leadership only (2 authorized · Jonas B, Silje O)"
            case .hms: return "Statutory requirement · Safety Rep Kasper R co-signed"
            }
        }
    }
}

public struct HandbookChapterItem: Identifiable, Sendable {
    public let id: String
    public let chapterNumber: String
    public let title: String
    public let statute: String
    public let icon: String
    public var iconColor: Color = SolTokens.lav400
    public var iconBg: Color = SolTokens.paper200
    public let statusText: String
    public var statusColor: Color = SolTokens.ink600
    public var statusBg: Color = SolTokens.paper200
    public let summary: String
    public let statutoryRule: String
    public let companyPolicy: String
    public let practicalGuideline: String
    public let revisionDate: String
    public let confirmedCount: String
    public var isAiChapter: Bool = false
    public var isAuditLog: Bool = false
    
    public init(
        id: String,
        chapterNumber: String,
        title: String,
        statute: String,
        icon: String,
        iconColor: Color = SolTokens.lav400,
        iconBg: Color = SolTokens.paper200,
        statusText: String,
        statusColor: Color = SolTokens.ink600,
        statusBg: Color = SolTokens.paper200,
        summary: String,
        statutoryRule: String,
        companyPolicy: String,
        practicalGuideline: String,
        revisionDate: String,
        confirmedCount: String,
        isAiChapter: Bool = false,
        isAuditLog: Bool = false
    ) {
        self.id = id
        self.chapterNumber = chapterNumber
        self.title = title
        self.statute = statute
        self.icon = icon
        self.iconColor = iconColor
        self.iconBg = iconBg
        self.statusText = statusText
        self.statusColor = statusColor
        self.statusBg = statusBg
        self.summary = summary
        self.statutoryRule = statutoryRule
        self.companyPolicy = companyPolicy
        self.practicalGuideline = practicalGuideline
        self.revisionDate = revisionDate
        self.confirmedCount = confirmedCount
        self.isAiChapter = isAiChapter
        self.isAuditLog = isAuditLog
    }
}

public struct AuditRecordItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let role: String
    public let date: String
    
    public init(id: String, name: String, role: String, date: String) {
        self.id = id
        self.name = name
        self.role = role
        self.date = date
    }
}

public let auditRecords: [AuditRecordItem] = [
    AuditRecordItem(id: "1", name: "Jonas Berg", role: "VD & Grundare", date: "02.01.24 · BankID"),
    AuditRecordItem(id: "2", name: "Silje Olsen", role: "Kontorschef", date: "04.01.24 · BankID"),
    AuditRecordItem(id: "3", name: "Morten Dahl", role: "Seniorkonsult", date: "05.01.24 · BankID"),
    AuditRecordItem(id: "4", name: "Kasper Rahman", role: "Skyddsombud", date: "08.01.24 · BankID"),
    AuditRecordItem(id: "5", name: "Sofia Rossi", role: "UX Designer", date: "09.01.24 · BankID"),
    AuditRecordItem(id: "6", name: "Henrik Myhre", role: "Backend Dev", date: "11.01.24 · BankID"),
    AuditRecordItem(id: "7", name: "Freja Holm", role: "Frontend Dev", date: "12.01.24 · BankID"),
    AuditRecordItem(id: "8", name: "Erlend Nakamura", role: "Head of Sales", date: "15.01.24 · BankID")
]

public struct CompanyBenefitItem: Identifiable, Sendable {
    public let id: String
    public let icon: String
    public var iconColor: Color = SolTokens.lav400
    public var iconBg: Color = SolTokens.paper200
    public let title: String
    public let highlight: String
    public let description: String
    public let tags: [String]
    
    public init(
        id: String,
        icon: String,
        iconColor: Color = SolTokens.lav400,
        iconBg: Color = SolTokens.paper200,
        title: String,
        highlight: String,
        description: String,
        tags: [String]
    ) {
        self.id = id
        self.icon = icon
        self.iconColor = iconColor
        self.iconBg = iconBg
        self.title = title
        self.highlight = highlight
        self.description = description
        self.tags = tags
    }
}

// MARK: - Multi-Handbook Chapter Provider
public func getHandbookChapters(
    for volume: HandbookVolume = .staff,
    language: AppLanguage,
    l10n: LocalizedStrings
) -> [HandbookChapterItem] {
    switch volume {
    case .staff:
        return getStaffHandbookChapters(language: language, l10n: l10n)
    case .leadership:
        return getLeadershipHandbookChapters(language: language, l10n: l10n)
    case .hms:
        return getHmsHandbookChapters(language: language, l10n: l10n)
    }
}

// Backwards-compatible overload
public func getHandbookChapters(for language: AppLanguage, l10n: LocalizedStrings) -> [HandbookChapterItem] {
    getHandbookChapters(for: .staff, language: language, l10n: l10n)
}

// 1. Staff Chapters (All Employees)
private func getStaffHandbookChapters(language: AppLanguage, l10n: LocalizedStrings) -> [HandbookChapterItem] {
    switch language {
    case .se:
        return [
            HandbookChapterItem(
                id: "ch1",
                chapterNumber: "1",
                title: l10n.handbookCh1Title,
                statute: l10n.handbookCh1Statute,
                icon: "doc.text.fill",
                statusText: "Reviderad 1 juli 2024",
                summary: l10n.handbookCh1Summary,
                statutoryRule: "Skriftligt anställningsavtal ska upprättas inom 7 dagar från första arbetsdagen. Avtalet måste specificera arbetstidsmått, lön, semestervillkor, uppsägningstider och rätt till kompetensutveckling (direktiv om tydliga arbetsvillkor).",
                companyPolicy: "Samtliga medarbetare hos Fjord Dynamics signerar digitalt med BankID via Comply innan första arbetsdagen. Standardiserade mallar uppdateras automatiskt mot gällande lagstiftning. Generella klausuler om att övertid ingår i fast lön är otillåtna.",
                practicalGuideline: "Vid förändrad tjänstegrad eller befordran upprättas ett tilläggsavtal inom 5 arbetsdagar. Provanställning utvärderas formellt senast månad 5.",
                revisionDate: "1 juli 2024",
                confirmedCount: "8 av 8 bekräftade"
            ),
            HandbookChapterItem(
                id: "ch2",
                chapterNumber: "2",
                title: l10n.handbookCh2Title,
                statute: l10n.handbookCh2Statute,
                icon: "person.2.fill",
                statusText: "Mandat 5+ anställda",
                summary: l10n.handbookCh2Summary,
                statutoryRule: "Från 1 januari 2024 är alla verksamheter med minst 5 medarbetare lagstadgade att ha ett utsett skyddsombud. Lagundantag för mindre verksamheter har avskaffats.",
                companyPolicy: "Skyddsombud utses genom hemligt val bland medarbetarna vartannat år. Kasper Rahman är ordinarie skyddsombud för Fjord Dynamics för perioden 2024–2025.",
                practicalGuideline: "Skyddsombudet har lagstadgad rätt till betald utbildning (genomförd via Simployer Learn) och deltar vid kvartalsvisa skyddsronder och riskanalyser.",
                revisionDate: "1 januari 2024",
                confirmedCount: "8 av 8 deltagit i valet"
            ),
            HandbookChapterItem(
                id: "ch3",
                chapterNumber: "3",
                title: l10n.handbookCh3Title,
                statute: l10n.handbookCh3Statute,
                icon: "clock.fill",
                statusText: "Gällande standard",
                summary: l10n.handbookCh3Summary,
                statutoryRule: "Ordinarie arbetstid får uppgå till högst 40 timmar per vecka i genomsnitt. Övertid måste beordras av arbetsgivaren och ersättas med minst 40 % tillägg per timme.",
                companyPolicy: "Normal arbetstid är 08:30–17:00 (40 h/vecka). Kärnarbetstid gäller mellan 09:00 och 15:00 med flextid 07:30–18:30 för god balans mellan arbete och privatliv.",
                practicalGuideline: "Övertid ska godkännas i förväg av VD/närmaste chef. Ersättning utgår antingen som kontant lönstillägg (140 %) eller kompensationsledighet (1,5 h per arbetad timme).",
                revisionDate: "1 juli 2024",
                confirmedCount: "8 av 8 kvitterat rutinen"
            ),
            HandbookChapterItem(
                id: "ch4",
                chapterNumber: "4",
                title: l10n.handbookCh4Title,
                statute: l10n.handbookCh4Statute,
                icon: "shield.lefthalf.filled",
                statusText: "Krypterad kanal",
                summary: l10n.handbookCh4Summary,
                statutoryRule: "Verksamheten ska erbjuda en oberoende och skyddad rapporteringskanal för visselblåsning. Arbetsgivaren har absolut förbud mot repressalier mot den som slår larm.",
                companyPolicy: "Rapportering sker antingen anonymt via Simployer Complys krypterade kanal eller direkt till extern oberoende part. Ärenden bekräftas formellt inom 7 dagar.",
                practicalGuideline: "Alla ärenden utreds objektivt inom 90 dagar. Medarbetaren garanteras fullt sekretesskydd och skydd mot omplacering eller disciplinära åtgärder.",
                revisionDate: "15 februari 2024",
                confirmedCount: "8 av 8 informerade"
            ),
            HandbookChapterItem(
                id: "ch5",
                chapterNumber: "5",
                title: "Användning av Generativ AI i Arbetet",
                statute: "AML § 4-1 · EU AI Act Art. 4",
                icon: "sparkles",
                statusText: "Aktiv policy",
                summary: "Företagspolicy för medarbetarnas användning av generativa AI-verktyg (ChatGPT, Claude, Copilot). Skydd för företagshemligheter och GDPR.",
                statutoryRule: "EU AI Act ställer krav på AI-kompetens (Art. 4) och transparens vid användning av maskininlärningsmodeller som hanterar personuppgifter eller företagshemligheter.",
                companyPolicy: "Medarbetare uppmuntras att använda godkända företagslicenser (ChatGPT Team, Claude Enterprise, GitHub Copilot). Det är förbjudet att klistra in personuppgifter, kundkällkod eller känslig affärsdata i publika/omodellerade AI-verktyg.",
                practicalGuideline: "All AI-genererad kod eller text ska granskas kritiskt av en människa innan den sätts i produktion eller skickas till kund. Företagskonton är centralt konfigurerade med opt-out från modellträning.",
                revisionDate: "1 augusti 2024",
                confirmedCount: "8 av 8 godkänt AI-policyn",
                isAiChapter: true
            ),
            HandbookChapterItem(
                id: "ch6",
                chapterNumber: "6",
                title: "BankID-kvittenser & Revisionslogg",
                statute: "v2024.2 · BankID Verifierad",
                icon: "checkmark.seal.fill",
                statusText: "Juridiskt bevis",
                summary: "Samtliga 8 medarbetare har signerat personalhandboken med BankID. Revisionscertifikat arkiverat för facklig tillsyn.",
                statutoryRule: "Lagstadgad bevisbörda för att medarbetare tagit del av gällande ordningsregler, skyddsföreskrifter och anställningsvillkor vid tvist.",
                companyPolicy: "Alla nyanställda kvitterar mottagande och genomgång av personalhandboken med BankID under introduktionsveckan. Loggen arkiveras med kryptografisk tidsstämpel.",
                practicalGuideline: "Revisionsloggen uppdateras automatiskt i Comply och exporteras med ett klick vid intern revision eller facklig förhandling.",
                revisionDate: "15 januari 2024",
                confirmedCount: "8 av 8 signaturer verifierade",
                isAuditLog: true
            )
        ]
    case .no:
        return [
            HandbookChapterItem(
                id: "ch1",
                chapterNumber: "1",
                title: l10n.handbookCh1Title,
                statute: l10n.handbookCh1Statute,
                icon: "doc.text.fill",
                statusText: "Revidert 1. juli 2024",
                summary: l10n.handbookCh1Summary,
                statutoryRule: "Skriftlig arbeidsavtale skal foreligge snarest mulig og senest 7 dager etter at arbeidsforholdet startet. Avtalen må angi arbeidstid, lønn, ferie, oppsigelsesfrister og rett til kompetanseutvikling.",
                companyPolicy: "Samtlige medarbeidere i Fjord Dynamics signerer digitalt med BankID via Comply før første arbeidsdag. Standardmaler oppdateres fortløpende mot gjeldende lovverk. Generelle klausuler om at overtid inngår i fastlønn er forbudt.",
                practicalGuideline: "Ved endret stilling eller forfremmelse lages et tillegg til avtalen innen 5 virkedager. Prøvetid evalueres formelt innen måned 5.",
                revisionDate: "1. juli 2024",
                confirmedCount: "8 av 8 bekreftet"
            ),
            HandbookChapterItem(
                id: "ch2",
                chapterNumber: "2",
                title: l10n.handbookCh2Title,
                statute: l10n.handbookCh2Statute,
                icon: "person.2.fill",
                statusText: "Påbudt fra 5 ansatte",
                summary: l10n.handbookCh2Summary,
                statutoryRule: "Fra 1. januar 2024 er alle virksomheter med 5 eller flere ansatte lovpålagt å ha verneombud. Unntaket for virksomheter under 10 ansatte er opphevet.",
                companyPolicy: "Verneombud velges ved hemmelig valg blant de ansatte for 2 år om gangen. Kasper Rahman er ordinært verneombud for Fjord Dynamics for 2024–2025.",
                practicalGuideline: "Verneombudet har lovfestet rett til betalt opplæring (gjennomført via Simployer Learn) og deltar på kvartalsvise vernerunder og risikovurderinger.",
                revisionDate: "1. januar 2024",
                confirmedCount: "8 av 8 deltok i valget"
            ),
            HandbookChapterItem(
                id: "ch3",
                chapterNumber: "3",
                title: l10n.handbookCh3Title,
                statute: l10n.handbookCh3Statute,
                icon: "clock.fill",
                statusText: "Gjeldende standard",
                summary: l10n.handbookCh3Summary,
                statutoryRule: "Alminnelig arbeidstid må ikke overstige 40 timer per uke i snitt. Overtid må være pålagt og godtgjøres med et tillegg på minst 40 %.",
                companyPolicy: "Normal arbeidstid er 08:30–17:00 (40 t/uke). Kjernetid er 09:00–15:00 med fleksitid mellom 07:30 og 18:30 for god balanse mellom jobb og fritid.",
                practicalGuideline: "Overtid skal alltid forhåndsgodkjennes av daglig leder. Tillegg utbetales som enten 140 % lønn eller avspasering time-for-time med 40 % kontanttillegg.",
                revisionDate: "1. juli 2024",
                confirmedCount: "8 av 8 kvittert rutinen"
            ),
            HandbookChapterItem(
                id: "ch4",
                chapterNumber: "4",
                title: l10n.handbookCh4Title,
                statute: l10n.handbookCh4Statute,
                icon: "shield.lefthalf.filled",
                statusText: "Kryptert kanal",
                summary: l10n.handbookCh4Summary,
                statutoryRule: "Virksomheten skal ha skriftlige rutiner for varsling og en uavhengig varslingskanal. Gjengjeldelse mot arbeidstaker som varsler er strengt forbudt.",
                companyPolicy: "Varsling kan sendes anonymt via Simployer Complys krypterte portal eller direkte til ekstern advokat. Varsler bekreftes mottatt innen 7 dager.",
                practicalGuideline: "Alle varsler saksbehandles objektivt innen 90 dager. Varsleren er sikret fullt vern mot endring i arbeidsoppgaver eller andre sanksjoner.",
                revisionDate: "15. februar 2024",
                confirmedCount: "8 av 8 informert"
            ),
            HandbookChapterItem(
                id: "ch5",
                chapterNumber: "5",
                title: "Användning av Generativ AI i Arbetet",
                statute: "AML § 4-1 · EU AI Act Art. 4",
                icon: "sparkles",
                statusText: "Aktiv policy",
                summary: "Företagspolicy för medarbetarnas användning av generativa AI-verktyg (ChatGPT, Claude, Copilot). Skydd för företagshemligheter och GDPR.",
                statutoryRule: "EU AI Act krever AI-kompetanse (Art. 4) og åpenhet ved bruk av maskinlæring som behandler forretningshemmeligheter eller persondata.",
                companyPolicy: "Ansatte oppfordres til å bruke godkjente bedriftslisenser (ChatGPT Team, Claude Enterprise, GitHub Copilot). Innliming av personopplysninger, kundedata eller sensitiv kode i offentlige AI-tjenester er forbudt.",
                practicalGuideline: "All AI-generert kode og tekst skal kvalitetssikres av et menneske før produksjon. Bedriftskontoer har sentral opt-out fra modelltrening.",
                revisionDate: "1. august 2024",
                confirmedCount: "8 av 8 bekreftet AI-policyen",
                isAiChapter: true
            ),
            HandbookChapterItem(
                id: "ch6",
                chapterNumber: "6",
                title: "BankID-kvitteringer & Revisjonslogg",
                statute: "v2024.2 · BankID Verifierad",
                icon: "checkmark.seal.fill",
                statusText: "Juridisk bevis",
                summary: "Alle 8 ansatte har signert personalhåndboken med BankID. Revisjonssertifikat arkivert for Arbeidstilsynets kontroll.",
                statutoryRule: "Arbeidsgiver har bevisbyrden for at arbeidstaker er gjort kjent med gjeldende instrukser og arbeidsvilkår ved en eventuell tvist.",
                companyPolicy: "Alle nyansatte kvitterer for mottatt og lest personalhåndbok med BankID under opplæringsuken. Loggen lagres med tidsstempel.",
                practicalGuideline: "Revisjonsloggen holdes automatisk oppdatert i Comply og kan eksporteres med ett klikk ved Arbeidstilsynets tilsyn.",
                revisionDate: "15. januar 2024",
                confirmedCount: "8 av 8 signaturer verifisert",
                isAuditLog: true
            )
        ]
    case .en:
        return [
            HandbookChapterItem(
                id: "ch1",
                chapterNumber: "1",
                title: l10n.handbookCh1Title,
                statute: l10n.handbookCh1Statute,
                icon: "doc.text.fill",
                statusText: "Revised July 1, 2024",
                summary: l10n.handbookCh1Summary,
                statutoryRule: "Written employment agreements must be finalized within 7 days of commencement. The contract must specify working hours, probation terms, training rights, and overtime entitlements.",
                companyPolicy: "All Fjord Dynamics staff sign digitally via BankID in Comply prior to day one. Standard templates are automatically audited against Nordic labor statutes. Blanket overtime waivers are prohibited.",
                practicalGuideline: "Role changes or salary reviews require an addendum within 5 business days. Probation is formally evaluated before month 5.",
                revisionDate: "July 1, 2024",
                confirmedCount: "8 of 8 confirmed"
            ),
            HandbookChapterItem(
                id: "ch2",
                chapterNumber: "2",
                title: l10n.handbookCh2Title,
                statute: l10n.handbookCh2Statute,
                icon: "person.2.fill",
                statusText: "Mandatory from 5 staff",
                summary: l10n.handbookCh2Summary,
                statutoryRule: "As of January 1, 2024, all enterprises with 5 or more employees are legally required to establish an elected safety representative. The exemption for under 10 staff was repealed.",
                companyPolicy: "Safety representatives are elected by secret ballot among employees for 2-year terms. Kasper Rahman is Fjord Dynamics' elected safety representative for 2024–2025.",
                practicalGuideline: "The safety rep has a statutory right to paid training (completed via Simployer Learn) and participates in quarterly safety inspections.",
                revisionDate: "January 1, 2024",
                confirmedCount: "8 of 8 participated in election"
            ),
            HandbookChapterItem(
                id: "ch3",
                chapterNumber: "3",
                title: l10n.handbookCh3Title,
                statute: l10n.handbookCh3Statute,
                icon: "clock.fill",
                statusText: "Active standard",
                summary: l10n.handbookCh3Summary,
                statutoryRule: "Standard working hours cannot exceed 40 hours per week on average. Overtime must be ordered or approved by management and compensated with minimum 40% premium.",
                companyPolicy: "Normal hours are 08:30–17:00 (40h/week). Core working hours are 09:00–15:00 with flexible bands from 07:30 to 18:30.",
                practicalGuideline: "Overtime must be pre-approved by the CEO/manager. Compensated either as cash premium (140%) or 1:1 time off in lieu plus a 40% cash differential.",
                revisionDate: "July 1, 2024",
                confirmedCount: "8 of 8 routine confirmed"
            ),
            HandbookChapterItem(
                id: "ch4",
                chapterNumber: "4",
                title: l10n.handbookCh4Title,
                statute: l10n.handbookCh4Statute,
                icon: "shield.lefthalf.filled",
                statusText: "Encrypted channel",
                summary: l10n.handbookCh4Summary,
                statutoryRule: "Enterprises must maintain an independent whistleblowing channel. Employers are under an absolute statutory prohibition against retaliation against reporters.",
                companyPolicy: "Reporting is available anonymously via Simployer Comply's encrypted channel or directly to external legal counsel. Submissions are acknowledged within 7 days.",
                practicalGuideline: "All inquiries are investigated objectively within 90 days. The whistleblower is legally protected against role changes or disciplinary actions.",
                revisionDate: "February 15, 2024",
                confirmedCount: "8 of 8 informed"
            ),
            HandbookChapterItem(
                id: "ch5",
                chapterNumber: "5",
                title: "Workplace Use of Artificial Intelligence (AI)",
                statute: "AML § 4-1 · EU AI Act Art. 4",
                icon: "sparkles",
                statusText: "Active policy",
                summary: "Internal policy for employee use of generative AI tools (ChatGPT, Claude, Copilot). Safeguarding trade secrets and GDPR.",
                statutoryRule: "EU AI Act Art. 4 mandates AI literacy and organizational transparency when deploying machine learning models processing business data or intellectual property.",
                companyPolicy: "Employees are encouraged to utilize approved corporate workspaces (ChatGPT Team, Claude Enterprise, GitHub Copilot). Pasting personal data, customer code, or confidential files into public tools is forbidden.",
                practicalGuideline: "All AI-assisted outputs must undergo human-in-the-loop review before production deployment. Corporate seats are centrally configured to opt-out of model training.",
                revisionDate: "August 1, 2024",
                confirmedCount: "8 of 8 confirmed AI policy",
                isAiChapter: true
            ),
            HandbookChapterItem(
                id: "ch6",
                chapterNumber: "6",
                title: "BankID Signatures & Audit Trail",
                statute: "v2024.2 · BankID Verified",
                icon: "checkmark.seal.fill",
                statusText: "Audit proof",
                summary: "All 8 staff members have signed the employee handbook via BankID. Digital audit certificate archived for labor inspections.",
                statutoryRule: "Statutory burden of proof rests on the employer to demonstrate that staff were duly notified of binding internal policies and working conditions.",
                companyPolicy: "All new hires acknowledge receipt of the employee handbook via BankID during onboarding week. Audit log entries are permanently archived with digital signatures.",
                practicalGuideline: "The audit trail is maintained automatically in Comply and can be exported with 1-click for labor inspection or board reviews.",
                revisionDate: "January 15, 2024",
                confirmedCount: "8 of 8 signatures verified",
                isAuditLog: true
            )
        ]
    }
}

// 2. Leadership Chapters (Managers & HR Only)
private func getLeadershipHandbookChapters(language: AppLanguage, l10n: LocalizedStrings) -> [HandbookChapterItem] {
    switch language {
    case .se:
        return [
            HandbookChapterItem(
                id: "lead1",
                chapterNumber: "1",
                title: "Anställning, Kravprofil & Provanställning",
                statute: "AML § 15-6 & LAS § 6",
                icon: "person.badge.plus",
                statusText: "Chefsrutin",
                summary: "Strukturerad uppföljning under provanställningsperioden. Obligatorisk formell avstämning senast månad 5 för att förhindra automatisk fast anställning.",
                statutoryRule: "Provanställning kan sägas upp vid bristande lämplighet, men kräver saklig dokumentation och skriftligt besked minst 14 dagar i förväg.",
                companyPolicy: "Närmaste chef genomför strukturerade avstämningar månad 1, 3 och 5. Comply skickar automatiska notiser med färdiga utvärderingsmallar.",
                practicalGuideline: "Dokumentera alltid konkreta avvikelser i personalakten. Om avslut övervägs ska Simployer Jurist kontaktas minst 10 dagar innan tidsfristen.",
                revisionDate: "1 mars 2024",
                confirmedCount: "2 av 2 chefer kvitterat"
            ),
            HandbookChapterItem(
                id: "lead2",
                chapterNumber: "2",
                title: "Sjukfrånvaro, Rehab & Myndighetsfrister",
                statute: "Folketrygdloven § 8-4 / SFB",
                icon: "cross.case.fill",
                statusText: "Lagstadgade tidslinjer",
                summary: "Chefens lagstadgade aktivitetsplikt vid kort- och långtidssjukskrivning. Tidslinjer för dialogmöten, uppföljningsplan och rehabiliteringsåtgärder.",
                statutoryRule: "Uppföljningsplan ska upprättas inom 4 veckor vid 100 % sjukfrånvaro. Dialogmöte 1 senast vecka 7, Dialogmöte 2 senast vecka 26.",
                companyPolicy: "Fjord Dynamics tillämpar tidig omtanke. Närmaste chef tar telefonkontakt dag 3 för att höra hur medarbetaren mår och erbjuda stöd.",
                practicalGuideline: "Comply förbereder automatiskt den lagstadgade uppföljningsplanen med ifyllda anställningsdata, redo för digital signering med BankID.",
                revisionDate: "15 januari 2024",
                confirmedCount: "2 av 2 chefer kvitterat"
            ),
            HandbookChapterItem(
                id: "lead3",
                chapterNumber: "3",
                title: "Varningar, Drøftelsesmøte (§ 15-1) & Uppsägning",
                statute: "AML § 15-1 & LAS § 7",
                icon: "exclamationmark.shield.fill",
                statusText: "Kräver juristgranskning",
                summary: "Processuella krav före beslut om uppsägning. Procedurfel utlöser skadestånd och ogiltigförklaring oavsett sakskäl (snittskadestånd 396 000 kr).",
                statutoryRule: "Arbetsgivaren är lagstadgad att hålla ett formellt drøftelsesmøte (§ 15-1) innan beslut om uppsägning fattas. Medarbetaren har rätt till fackligt eller juridiskt biträde.",
                companyPolicy: "Inget uppsägningsbeslut får meddelas muntligt eller utan skriftlig kallelse och protokollfört möte. Kallelse genereras via Comply.",
                practicalGuideline: "Klicka på 'Koppla till Simployer Jurist' vid minsta tveksamhet. Våra arbetsrättsjurister granskar kallelsen och protokollet inom 2 timmar.",
                revisionDate: "1 juli 2024",
                confirmedCount: "2 av 2 chefer kvitterat"
            ),
            HandbookChapterItem(
                id: "lead4",
                chapterNumber: "4",
                title: "Lönerevision, Bonus & Lönekartläggning",
                statute: "Likestillingsloven § 26 / Diskrimineringslagen",
                icon: "chart.line.uptrend.xyaxis",
                statusText: "Årlig revision",
                summary: "Principer för objektiv lönesättning, årlig lönerevision och lagstadgad kartläggning av osakliga löneskillnader mellan könen.",
                statutoryRule: "Verksamheter ska regelbundet kartlägga löneförhållanden och säkerställa att likvärdiga roller ersätts utan könsdiskriminering.",
                companyPolicy: "Fjord Dynamics tillämpar transparenta lönenivåer baserade på rollmatris och marknadsdata från Simployer Lönestatistik.",
                practicalGuideline: "Vid nyanställning kontrollerar Comply automatiskt att den överenskomna lönen inte skapar en otillåten löneklyfta inom avdelningen.",
                revisionDate: "1 februari 2024",
                confirmedCount: "2 av 2 chefer kvitterat"
            ),
            HandbookChapterItem(
                id: "lead5",
                chapterNumber: "5",
                title: "Konflikthantering & Kränkande Särbehandling",
                statute: "AML § 4-3 & Arbetsmiljölagen 2 kap.",
                icon: "person.3.sequence.fill",
                statusText: "Aktivitetsplikt",
                summary: "Chefens utredningsplikt vid klagomål, trakasserier eller psykosociala samarbetssvårigheter i teamet.",
                statutoryRule: "Arbetsgivaren har absolut lagstadgad skyldighet att omgående undersöka påståenden om trakasserier eller repressalier och vidta nödvändiga åtgärder.",
                companyPolicy: "Chefen ska hålla enskilda samtal med berörda parter inom 48 timmar från mottagen signal och upprätta en skriftlig incidentrapport i Comply.",
                practicalGuideline: "Om konflikten involverar chefen själv eskaleras ärendet automatiskt till styrelseordförande eller extern jurist via Complys krypterade kanal.",
                revisionDate: "15 mars 2024",
                confirmedCount: "2 av 2 chefer kvitterat"
            ),
            HandbookChapterItem(
                id: "lead6",
                chapterNumber: "6",
                title: "Ledarskapets Behörigheter & BankID-Arkiv",
                statute: "GDPR Art. 9 & AML § 15",
                icon: "lock.badge.clock.fill",
                statusText: "BankID-arkiv",
                summary: "Formella delegationsordningar, godkända chefssignaturer och kryptografisk revisionslogg för ledningsbeslut.",
                statutoryRule: "Behandling av personakter, disciplinära åtgärder och rehabiliteringsdata kräver strikt rollbaserad behörighetskontroll.",
                companyPolicy: "Endast Jonas Berg (VD) och Silje Olsen (Kontorschef) har administrativ chefsbehörighet. Revisionsloggen granskas årligen i januari.",
                practicalGuideline: "Samtliga ledningsbeslut (avtal, varningar, uppföljningsplaner) signeras digitalt med BankID och tidsstämplas.",
                revisionDate: "1 januari 2024",
                confirmedCount: "2 av 2 chefer signerat",
                isAuditLog: true
            )
        ]
    case .no:
        return [
            HandbookChapterItem(
                id: "lead1",
                chapterNumber: "1",
                title: "Ansettelse, Stillingsinstruks & Prøvetid",
                statute: "AML § 15-6 & § 14-6",
                icon: "person.badge.plus",
                statusText: "Lederrutine",
                summary: "Strukturert oppfølging i prøvetiden. Obligatorisk formell evaluering innen måned 5 for å unngå automatisk fast ansettelse ved manglende egnethet.",
                statutoryRule: "Oppsigelse i prøvetid krever saklig begrunnelse i arbeidstakers tilpasning eller pålitelighet, samt skriftlig varsel med 14 dagers frist.",
                companyPolicy: "Nærmeste leder gjennomfører formelle samtaler i måned 1, 3 og 5. Comply varsler automatisk med ferdige evalueringsmaler.",
                practicalGuideline: "Dokumenter konkrete avvik skriftlig i personalmappen. Kontakt Simployer-jurist minst 10 dager før fristen dersom oppsigelse vurderes.",
                revisionDate: "1. mars 2024",
                confirmedCount: "2 av 2 ledere kvittert"
            ),
            HandbookChapterItem(
                id: "lead2",
                chapterNumber: "2",
                title: "Sykefraværsoppfølging & NAV-tidslinjer",
                statute: "Folketrygdloven § 8-4 & AML § 4-6",
                icon: "cross.case.fill",
                statusText: "Lovpålagte frister",
                summary: "Lederens lovfestede oppfølgingsplikt ved sykefravær. Tidslinjer for dialogmøter, oppfølgingsplan og rapportering til NAV.",
                statutoryRule: "Oppfølgingsplan skal lages i samarbeid med den ansatte innen 4 uker. Dialogmøte 1 innen uke 7, Dialogmøte 2 innen uke 26.",
                companyPolicy: "Fjord Dynamics praktiserer tidlig omsorg. Nærmeste leder ringer dag 3 for å høre hvordan det går og avklare eventuell tilrettelegging.",
                practicalGuideline: "Comply klargjør den lovpålagte oppfølgingsplanen med ferdig utfylte personaldata, klar for BankID-signering.",
                revisionDate: "15. januar 2024",
                confirmedCount: "2 av 2 ledere kvittert"
            ),
            HandbookChapterItem(
                id: "lead3",
                chapterNumber: "3",
                title: "Advarsler, Drøftelsesmøte (§ 15-1) & Oppsigelse",
                statute: "AML § 15-1 & § 15-7",
                icon: "exclamationmark.shield.fill",
                statusText: "Krever juristbistand",
                summary: "Prosessuelle krav før beslutning om oppsigelse. Saksbehandlingsfeil utløser erstatning uavhengig av saklig grunn (snittkrav 396 000 kr).",
                statutoryRule: "Arbeidsgiver plikter å gjennomføre formelt drøftelsesmøte (§ 15-1) før oppsigelse besluttes. Den ansatte har rett til rådgiver/tillitsvalgt.",
                companyPolicy: "Ingen oppsigelse kan gis muntlig eller uten skriftlig innkalling og protokollført drøftelsesmøte. Innkalling lages i Comply.",
                practicalGuideline: "Bruk 'Koble til Simployer Jurist' ved minste tvil. Våre arbeidsrettsadvokater kvalitetssikrer innkalling og protokoll innen 2 timer.",
                revisionDate: "1. juli 2024",
                confirmedCount: "2 av 2 ledere kvittert"
            ),
            HandbookChapterItem(
                id: "lead4",
                chapterNumber: "4",
                title: "Lønnsforhandlinger & Likestillingsredegjørelse",
                statute: "Likestillingsloven § 26",
                icon: "chart.line.uptrend.xyaxis",
                statusText: "Årlig revisjon",
                summary: "Retningslinjer for objektiv lønnsfastsettelse, årlig lønnssamtale og lovpålagt kartlegging av ufrivillige lønnsforskjeller mellom kjønn.",
                statutoryRule: "Virksomheter skal kartlegge lønnsforhold etter kjønn og sikre at arbeid av lik verdi lønnes likt uten usaklig forskjellsbehandling.",
                companyPolicy: "Fjord Dynamics har transparente lønnsbånd basert på stillingsmatrise og markedsstatistikk fra Simployer.",
                practicalGuideline: "Comply varsler dersom en nyansettelse eller lønnsjustering skaper en ubegrunnet lønnsforskjell innad i avdelingen.",
                revisionDate: "1. februar 2024",
                confirmedCount: "2 av 2 ledere kvittert"
            ),
            HandbookChapterItem(
                id: "lead5",
                chapterNumber: "5",
                title: "Konflikthåndtering & Psykososialt Arbeidsmiljø",
                statute: "AML § 4-3",
                icon: "person.3.sequence.fill",
                statusText: "Aktivitetsplikt",
                summary: "Lederens undersøkelsesplikt ved klager, mobbing eller samarbeidskonflikter i teamet.",
                statutoryRule: "Arbeidsgiver har ubetinget plikt til å undersøke påstander om trakassering eller utilbørlig opptreden og iverksette tiltak.",
                companyPolicy: "Leder skal gjennomføre fortrolige enkeltsamtaler innen 48 timer etter mottatt bekymring og loggføre saken i Comply.",
                practicalGuideline: "Hvis konflikten gjelder lederen selv, eskalerer Comply saken automatisk til styreleder eller ekstern advokat via kryptert kanal.",
                revisionDate: "15. mars 2024",
                confirmedCount: "2 av 2 ledere kvittert"
            ),
            HandbookChapterItem(
                id: "lead6",
                chapterNumber: "6",
                title: "Ledelsens Tilganger & BankID-Arkiv",
                statute: "GDPR Art. 9 & AML § 15",
                icon: "lock.badge.clock.fill",
                statusText: "BankID-arkiv",
                summary: "Formelle fullmaktsmatriser, godkjente ledersignaturer og kryptografisk revisjonslogg for personalvedtak.",
                statutoryRule: "Håndtering av helseopplysninger og disiplinærsaker krever streng rollebasert tilgangskontroll.",
                companyPolicy: "Kun Jonas Berg (daglig leder) og Silje Olsen (kontorleder) har lederadgang. Tilgangsloggen revideres årlig.",
                practicalGuideline: "Alle ledelsesvedtak (kontrakter, advarsler, oppfølgingsplaner) signeres digitalt med BankID og arkiveres sikkert.",
                revisionDate: "1. januar 2024",
                confirmedCount: "2 av 2 ledere signert",
                isAuditLog: true
            )
        ]
    case .en:
        return [
            HandbookChapterItem(
                id: "lead1",
                chapterNumber: "1",
                title: "Hiring, Role Profiles & Probation Reviews",
                statute: "AML § 15-6 & § 14-6",
                icon: "person.badge.plus",
                statusText: "Management routine",
                summary: "Structured probation management. Mandatory formal reviews by month 5 to prevent automatic conversion into permanent tenure if suitability is lacking.",
                statutoryRule: "Dismissal during probation requires objective grounds related to role adaptation or reliability, and a written notice with 14 days' statutory notice.",
                companyPolicy: "Managers conduct formal 1-on-1 reviews at months 1, 3, and 5. Comply dispatches automated alerts with pre-filled evaluation templates.",
                practicalGuideline: "Document specific performance gaps in writing. Consult Simployer Legal counsel at least 10 business days prior to deadline if termination is considered.",
                revisionDate: "March 1, 2024",
                confirmedCount: "2 of 2 managers confirmed"
            ),
            HandbookChapterItem(
                id: "lead2",
                chapterNumber: "2",
                title: "Sick Leave Follow-up & Statutory Deadlines",
                statute: "National Insurance Act § 8-4",
                icon: "cross.case.fill",
                statusText: "Statutory deadlines",
                summary: "Managerial duty of care during sickness absence. Strict statutory timelines for follow-up plans, NAV dialogue meetings, and workplace adjustments.",
                statutoryRule: "An agreed follow-up plan must be registered within 4 weeks. Dialogue meeting 1 by week 7; Dialogue meeting 2 by week 26.",
                companyPolicy: "Fjord Dynamics practices proactive outreach. Managers check in on day 3 to offer support and plan potential ergonomic accommodations.",
                practicalGuideline: "Comply auto-populates the official follow-up plan with employee records, ready for bilateral BankID signing.",
                revisionDate: "January 15, 2024",
                confirmedCount: "2 of 2 managers confirmed"
            ),
            HandbookChapterItem(
                id: "lead3",
                chapterNumber: "3",
                title: "Warnings, Consultation (§ 15-1) & Dismissals",
                statute: "AML § 15-1 & § 15-7",
                icon: "exclamationmark.shield.fill",
                statusText: "Legal review mandatory",
                summary: "Procedural requirements prior to dismissals. Formal errors trigger statutory damages regardless of substantive grounds (average claim: NOK 396,000).",
                statutoryRule: "Employers are legally mandated to conduct a pre-dismissal consultation meeting (§ 15-1). The employee has the right to union/legal counsel.",
                companyPolicy: "No termination may be communicated orally or without prior written summons and filed minutes. Notices are generated directly in Comply.",
                practicalGuideline: "Trigger 'Connect Simployer Attorney' immediately. Our labor attorneys review summonses and minutes within 2 business hours.",
                revisionDate: "July 1, 2024",
                confirmedCount: "2 of 2 managers confirmed"
            ),
            HandbookChapterItem(
                id: "lead4",
                chapterNumber: "4",
                title: "Salary Reviews & Equal Pay Audits",
                statute: "Equality & Anti-Discrimination Act § 26",
                icon: "chart.line.uptrend.xyaxis",
                statusText: "Annual audit",
                summary: "Objective compensation principles, annual reviews, and statutory audits to eliminate unjustified gender wage disparities.",
                statutoryRule: "Enterprises must audit pay structures biennially to ensure work of equal value receives equal pay without direct or indirect discrimination.",
                companyPolicy: "Fjord Dynamics maintains transparent pay bands referenced against Simployer Nordic market salary benchmark datasets.",
                practicalGuideline: "Comply alerts leadership if a planned hire or increment creates an unjustified wage differential within the department.",
                revisionDate: "February 1, 2024",
                confirmedCount: "2 of 2 managers confirmed"
            ),
            HandbookChapterItem(
                id: "lead5",
                chapterNumber: "5",
                title: "Conflict Resolution & Psychosocial Climate",
                statute: "AML § 4-3",
                icon: "person.3.sequence.fill",
                statusText: "Duty to act",
                summary: "Mandatory investigation procedures for employee grievances, workplace harassment, or toxic team dynamics.",
                statutoryRule: "Employers possess an absolute statutory duty to promptly investigate allegations of harassment or retaliation and enforce corrective measures.",
                companyPolicy: "Managers hold confidential 1-on-1 interviews within 48 hours of notification and file a structured incident record in Comply.",
                practicalGuideline: "If a complaint implicates the manager, Comply automatically reroutes the case to the Board Chair or external legal counsel.",
                revisionDate: "March 15, 2024",
                confirmedCount: "2 of 2 managers confirmed"
            ),
            HandbookChapterItem(
                id: "lead6",
                chapterNumber: "6",
                title: "Leadership Access & BankID Audit Vault",
                statute: "GDPR Art. 9 & AML § 15",
                icon: "lock.badge.clock.fill",
                statusText: "BankID archive",
                summary: "Delegation matrices, approved manager signatures, and cryptographic audit logging for confidential personnel actions.",
                statutoryRule: "Handling employee health records and disciplinary measures requires strict role-based access control and tamper-proof logs.",
                companyPolicy: "Only Jonas Berg (CEO) and Silje Olsen (Office Manager) hold leadership credentials. Access permissions are audited annually in January.",
                practicalGuideline: "All leadership actions (contracts, warnings, follow-up plans) are digitally countersigned via BankID and timestamped.",
                revisionDate: "January 1, 2024",
                confirmedCount: "2 of 2 managers signed",
                isAuditLog: true
            )
        ]
    }
}

// 3. HMS & Safety Chapters (Occupational Health & Statutory Inspection)
private func getHmsHandbookChapters(language: AppLanguage, l10n: LocalizedStrings) -> [HandbookChapterItem] {
    switch language {
    case .se:
        return [
            HandbookChapterItem(
                id: "hms1",
                chapterNumber: "1",
                title: "Arbetsmiljöansvar, Mål & SAM-Certifiering",
                statute: "AML kap. 3 & § 3-5",
                icon: "building.columns.fill",
                statusText: "SAM-certifierad",
                summary: "VD:s lagstadgade ansvar för det systematiska arbetsmiljöarbetet (SAM) samt krav på dokumenterad arbetsmiljöutbildning för chefer.",
                statutoryRule: "Arbetsgivaren har huvudansvaret för att arbetsmiljön är fullt försvarlig och att chefer genomgått föreskriven SAM-utbildning.",
                companyPolicy: "Fjord Dynamics har som mål noll arbetsskador och en trygg psykosocial arbetsplats. Jonas Berg har godkänd SAM-kurs via Simployer Learn.",
                practicalGuideline: "Kursintyg och delegationsbeslut för arbetsmiljöuppgifter finns arkiverade i Complys revisionspaket för uppvisande vid tillsyn.",
                revisionDate: "1 januari 2024",
                confirmedCount: "VD & Skyddsombud godkänt"
            ),
            HandbookChapterItem(
                id: "hms2",
                chapterNumber: "2",
                title: "Riskbedömning & Årlig Skyddsrond",
                statute: "Internkontroll § 5 / AFS 2001:1",
                icon: "checklist.checked",
                statusText: "Genomförd 2024",
                summary: "Årlig kartläggning och skriftlig riskbedömning av fysiska, ergonomiska och psykosociala risker i samarbete med skyddsombudet.",
                statutoryRule: "Verksamheten ska regelbundet undersöka arbetsförhållandena, bedöma risker för ohälsa och upprätta en tidsatt handlingsplan.",
                companyPolicy: "Skyddsrond genomförs årligen varje november av VD, skyddsombud och kontorschef. Handlingsplanen följs upp kvartalsvis.",
                practicalGuideline: "Digital skyddsrondsmall i Comply genererar automatiskt åtgärdspunkter med tilldelad ansvarig person och deadline.",
                revisionDate: "15 november 2024",
                confirmedCount: "Skyddsrondsprotokoll signerat"
            ),
            HandbookChapterItem(
                id: "hms3",
                chapterNumber: "3",
                title: "Tillbud, Olycksfall & Myndighetsanmälan",
                statute: "AML § 5-1 & § 5-2",
                icon: "bell.badge.fill",
                statusText: "Akutrutin",
                summary: "Skyldighet att utreda tillbud och omedelbart anmäla allvarliga arbetsolyckor till Arbetsmiljöverket/Arbeidstilsynet och polisen.",
                statutoryRule: "Vid allvarlig personskada eller dödsfall ska arbetsgivaren anmäla händelsen omedelbart via telefon och webb till tillsynsmyndigheten.",
                companyPolicy: "Alla tillbud (nestenulykker) ska anmälas inom 24 timmar via Comply. Skyddsombudet får automatiskt en kopia.",
                practicalGuideline: "Comply har ett integrerat 1-klicksformulär för anmälan till Arbetsmiljöverket med förhandsifyllda företagsdata.",
                revisionDate: "1 februari 2024",
                confirmedCount: "Akutrutin aktiv"
            ),
            HandbookChapterItem(
                id: "hms4",
                chapterNumber: "4",
                title: "Brandskydd (SBA), Utrymning & Första Hjälpen",
                statute: "LSO kap. 2 / Internkontroll",
                icon: "flame.fill",
                statusText: "Övad årligen",
                summary: "Systematiskt brandskyddsarbete (SBA), kvartalsvis kontroll av släckutrustning samt årlig praktisk utrymningsövning.",
                statutoryRule: "Lokaler ska hålla fria utrymningsvägar, fungerande nödbelysning och brandsläckare. Personal ska instrueras om utrymning.",
                companyPolicy: "Silje Olsen är utsedd brandskyddskontrollant. Första hjälpen-station finns i pentryt och vid konferensrummet.",
                practicalGuideline: "Samlingsplats vid utrymning är Kajen 4 (östra parkeringen). Utrymningsplan finns anslagen vid samtliga nödutgångar.",
                revisionDate: "15 april 2024",
                confirmedCount: "SBA-protokoll arkiverat"
            ),
            HandbookChapterItem(
                id: "hms5",
                chapterNumber: "5",
                title: "Skärmergonomi & Bildskärmsglasögon",
                statute: "AFS 1998:5 / Forskrift om dataskjerm",
                icon: "eyeglasses",
                statusText: "Fri synundersökning",
                summary: "Lagstadgad rätt till arbetsgivarbetald synundersökning och specialanpassade terminalglasögon vid regelbundet datorarbete.",
                statutoryRule: "Arbetstagare som arbetar vid bildskärm mer än 1 timme per dag har lagstadgad rätt till synundersökning bekostad av arbetsgivaren.",
                companyPolicy: "Fjord Dynamics bekostar full undersökning och båge/glas via Synsam upp till 4 500 kr vartannat år.",
                practicalGuideline: "Medarbetaren bokar tid hos Synsam och anger Fjord Dynamics företagsavtal. Fakturan attesteras direkt i Comply.",
                revisionDate: "1 januari 2024",
                confirmedCount: "Avtal aktivt hos optiker"
            ),
            HandbookChapterItem(
                id: "hms6",
                chapterNumber: "6",
                title: "Skyddsombudets Mandat & Valprotokoll",
                statute: "AML § 6-1 & § 6-2",
                icon: "person.badge.shield.checkmark.fill",
                statusText: "Valprotokoll arkiverat",
                summary: "Det formella valprotokollet för skyddsombudet Kasper Rahman samt skyddsombudets lagstadgade befogenheter och stoppningsrätt.",
                statutoryRule: "Skyddsombudet har lagstadgad rätt till betald ledighet för uppdraget, rätt till utbildning och rätt att avbryta farligt arbete.",
                companyPolicy: "Kasper Rahman deltar i samtliga ledningsmöten som rör arbetsmiljön och har oinskränkt tillgång till skyddsronder i Comply.",
                practicalGuideline: "Valprotokollet är signerat med BankID av samtliga anställda och finns permanent tillgängligt för Arbetsmiljöverket vid tillsyn.",
                revisionDate: "12 januari 2024",
                confirmedCount: "8 av 8 BankID-röster verifierade",
                isAuditLog: true
            )
        ]
    case .no:
        return [
            HandbookChapterItem(
                id: "hms1",
                chapterNumber: "1",
                title: "HMS-ansvar, Mål & Lederkurs (§ 3-5)",
                statute: "AML kap. 3 & § 3-5",
                icon: "building.columns.fill",
                statusText: "HMS-sertifisert",
                summary: "Daglig leders lovfestede plikt til å gjennomgå HMS-opplæring og sikre systematisk helse-, miljø- og sikkerhetsarbeid i virksomheten.",
                statutoryRule: "Arbeidsgiver plikter å gjennomgå opplæring i helse-, miljø- og sikkerhetsarbeid (§ 3-5) og dokumentere internkontrollen skriftlig.",
                companyPolicy: "Fjord Dynamics har som mål et fullt forsvarlig arbeidsmiljø med null skader. Jonas Berg har fullført godkjent lederkurs via Simployer Learn.",
                practicalGuideline: "Kursbevis og skriftlig HMS-målsetting er arkivert i Comply for umiddelbar fremvisning ved Arbeidstilsynets tilsyn.",
                revisionDate: "1. januar 2024",
                confirmedCount: "Lederkurs § 3-5 verifisert"
            ),
            HandbookChapterItem(
                id: "hms2",
                chapterNumber: "2",
                title: "Risikovurdering & Årlig Vernerunde",
                statute: "Internkontrollforskriften § 5",
                icon: "checklist.checked",
                statusText: "Gjennomført 2024",
                summary: "Årlig kartlegging og skriftlig risikovurdering av fysiske, ergonomiske og psykososiale risikofaktorer sammen med verneombudet.",
                statutoryRule: "Virksomheten skal regelmessig kartlegge farer og problemer, vurdere risiko og utarbeide en handlingsplan med tidsfrister.",
                companyPolicy: "Vernerunde gjennomføres årlig hver november av daglig leder, verneombud og kontorleder. Handlingsplanen følges opp kvartalsvis.",
                practicalGuideline: "Complys digitale vernerundeskjema genererer automatisk tiltakspunkter med tildelt ansvarlig og frist for utbedring.",
                revisionDate: "15. november 2024",
                confirmedCount: "Vernerundeprotokoll signert"
            ),
            HandbookChapterItem(
                id: "hms3",
                chapterNumber: "3",
                title: "Ulykker, Avvik & Meldeplikt til Arbeidstilsynet",
                statute: "AML § 5-1 & § 5-2",
                icon: "bell.badge.fill",
                statusText: "Akuttrutine",
                summary: "Plikt til å registrere avvik og ulykker, samt varsle Arbeidstilsynet og nærmeste politimyndighet straks ved alvorlig skade.",
                statutoryRule: "Ved alvorlig eller livstruende skade skal arbeidsgiver varsle Arbeidstilsynet og politi umiddelbart via telefon og digital melding.",
                companyPolicy: "Alle avvik og nestenulykker meldes inn innen 24 timer via Comply. Verneombudet mottar automatisk varsel på e-post.",
                practicalGuideline: "Comply har et 1-klikks integrert meldeskjema til Arbeidstilsynet med forhåndsutfylte virksomhetsdata.",
                revisionDate: "1. februar 2024",
                confirmedCount: "Melderutine aktiv"
            ),
            HandbookChapterItem(
                id: "hms4",
                chapterNumber: "4",
                title: "Brannvern (SBA), Rømningsveier & Førstehjelp",
                statute: "Brannvernforskriften / Internkontroll",
                icon: "flame.fill",
                statusText: "Øvd årlig",
                summary: "Systematisk brannforebyggende arbeid, halvårlig kontroll av slokkeutstyr og årlig praktisk evakueringsøvelse for alle ansatte.",
                statutoryRule: "Lokalene skal ha frie rømningsveier, nødlys og godkjente slokkemidler. Alle ansatte skal kjenne samlingsplassen.",
                companyPolicy: "Silje Olsen er brannvernleder. Førstehjelpsutstyr og hjertestarter er plassert i kjøkkenområdet og kontrolleres kvartalsvis.",
                practicalGuideline: "Samlingsplass ved evakuering er Bryggen 4 (østre parkeringsplass). Rømningsplan er hengt opp ved alle nødutganger.",
                revisionDate: "15. april 2024",
                confirmedCount: "Brannvernlogg godkjent"
            ),
            HandbookChapterItem(
                id: "hms5",
                chapterNumber: "5",
                title: "Skjermergonomi & Synsundersøkelse",
                statute: "Forskrift om arbeid ved dataskjerm § 14",
                icon: "eyeglasses",
                statusText: "Fri synsundersøkelse",
                summary: "Lovfestet rett til arbeidsgiverbetalt synsundersøkelse og databriller ved regelmessig arbeid foran dataskjerm.",
                statutoryRule: "Arbeidstakere som jevnlig arbeider ved dataskjerm har rett til synsprøve betalt av arbeidsgiver og spesialtilpassede databriller.",
                companyPolicy: "Fjord Dynamics dekker full undersøkelse og innfatning/glass hos optiker opptil 4 500 kr annethvert år.",
                practicalGuideline: "Den ansatte bestiller time hos Synsam eller Brilleland og oppgir Fjord Dynamics bedriftsavtale.",
                revisionDate: "1. januar 2024",
                confirmedCount: "Optikeravtale aktiv"
            ),
            HandbookChapterItem(
                id: "hms6",
                chapterNumber: "6",
                title: "Verneombudets Mandat & Valgprotokoll",
                statute: "AML § 6-1 & § 6-2",
                icon: "person.badge.shield.checkmark.fill",
                statusText: "Valgprotokoll arkivert",
                summary: "Formelt valgprotokoll for verneombud Kasper Rahman for 2024–2025, samt verneombudets lovfestede stansingsrett ved fare.",
                statutoryRule: "Verneombudet har lovfestet rett til betalt fri for vervet, rett til opplæring og rett til å stanse farlig arbeid (§ 6-3).",
                companyPolicy: "Kasper Rahman har fri tilgang til alle HMS-saker i Comply og deltar i alle planleggingsmøter som berører arbeidsmiljøet.",
                practicalGuideline: "Valgprotokollen er signert med BankID av samtlige 8 ansatte og oppbevares permanent i Complys tilsynsarkiv.",
                revisionDate: "12. januar 2024",
                confirmedCount: "8 av 8 BankID-stemmer arkivert",
                isAuditLog: true
            )
        ]
    case .en:
        return [
            HandbookChapterItem(
                id: "hms1",
                chapterNumber: "1",
                title: "HSE Liability, Goals & Management Course (§ 3-5)",
                statute: "AML ch. 3 & § 3-5",
                icon: "building.columns.fill",
                statusText: "HSE certified",
                summary: "CEO's statutory duty to complete formal HSE training and maintain written internal control documentation for the enterprise.",
                statutoryRule: "The employer must complete certified HSE training (§ 3-5) and maintain structured internal control records under law.",
                companyPolicy: "Fjord Dynamics targets zero workplace injuries and an empowering psychological environment. Jonas Berg completed the CEO HSE curriculum via Simployer Learn.",
                practicalGuideline: "Course certificates and executive delegation records are permanently archived in Comply for instant inspector presentation.",
                revisionDate: "January 1, 2024",
                confirmedCount: "HSE § 3-5 certified"
            ),
            HandbookChapterItem(
                id: "hms2",
                chapterNumber: "2",
                title: "Risk Assessments & Annual Safety Inspection",
                statute: "Internal Control Regulations § 5",
                icon: "checklist.checked",
                statusText: "Completed 2024",
                summary: "Annual mapping and written risk assessment of ergonomic, physical, and psychosocial factors in collaboration with the safety representative.",
                statutoryRule: "Enterprises must systematically examine risks, evaluate likelihood/severity, and maintain a dated remediation action plan.",
                companyPolicy: "Safety walkthroughs are conducted annually every November by the CEO, Safety Rep, and Office Manager. Plans are tracked quarterly.",
                practicalGuideline: "Comply's digital inspection templates generate action points with assigned owners and hard compliance completion dates.",
                revisionDate: "November 15, 2024",
                confirmedCount: "Inspection protocol signed"
            ),
            HandbookChapterItem(
                id: "hms3",
                chapterNumber: "3",
                title: "Incidents, Near-Misses & Inspection Reporting",
                statute: "AML § 5-1 & § 5-2",
                icon: "bell.badge.fill",
                statusText: "Emergency routine",
                summary: "Statutory duty to log near-misses and immediately notify the Labor Inspection Authority and Police in the event of serious injury.",
                statutoryRule: "Severe or life-threatening injuries must be reported immediately by phone and digital submission to the inspectorate.",
                companyPolicy: "All incidents and near-misses must be filed within 24 hours in Comply. The Safety Representative receives instant notification.",
                practicalGuideline: "Comply features a 1-click official notification dispatch workflow with pre-filled company registration metadata.",
                revisionDate: "February 1, 2024",
                confirmedCount: "Emergency workflow active"
            ),
            HandbookChapterItem(
                id: "hms4",
                chapterNumber: "4",
                title: "Fire Safety, Evacuation & First Aid",
                statute: "Fire Protection Regulations / Internal Control",
                icon: "flame.fill",
                statusText: "Practiced annually",
                summary: "Systematic fire prevention routines, bi-annual inspection of extinguishing gear, and mandatory annual drill for all staff.",
                statutoryRule: "Premises must provide unobstructed emergency exits, illuminated signage, and certified extinguishers. All staff must know muster points.",
                companyPolicy: "Silje Olsen is designated Fire Marshal. Defibrillator and first-aid kits are centrally located in the kitchenette area.",
                practicalGuideline: "Evacuation muster point is Dock 4 (East parking perimeter). Escape plans are posted adjacent to every emergency door.",
                revisionDate: "April 15, 2024",
                confirmedCount: "Fire audit log verified"
            ),
            HandbookChapterItem(
                id: "hms5",
                chapterNumber: "5",
                title: "VDU Ergonomics & Computer Eyewear",
                statute: "VDU Regulations § 14",
                icon: "eyeglasses",
                statusText: "Free eye exam",
                summary: "Statutory employee entitlement to employer-funded eye examinations and specialized computer glasses for regular screen workers.",
                statutoryRule: "Staff working with display screen equipment for more than 1 hour daily are legally entitled to employer-covered eye examinations and glasses.",
                companyPolicy: "Fjord Dynamics covers comprehensive eye exams and frames/lenses at partner opticians up to NOK 4,500 biennially.",
                practicalGuideline: "Employees book appointments directly with Synsam or partner opticians referencing Fjord Dynamics corporate billing account.",
                revisionDate: "January 1, 2024",
                confirmedCount: "Optician corporate contract active"
            ),
            HandbookChapterItem(
                id: "hms6",
                chapterNumber: "6",
                title: "Safety Representative Mandate & Minutes",
                statute: "AML § 6-1 & § 6-2",
                icon: "person.badge.shield.checkmark.fill",
                statusText: "Minutes archived",
                summary: "Official election protocol for Safety Representative Kasper Rahman (2024–2025) and statutory work stoppage authority during imminent danger.",
                statutoryRule: "The safety rep has a statutory right to paid release time, formal training, and the legal power to halt dangerous work (§ 6-3).",
                companyPolicy: "Kasper Rahman possesses unrestricted visibility into all HSE incidents in Comply and participates in quarterly planning sessions.",
                practicalGuideline: "The election minutes are signed via BankID by all 8 employees and permanently retained in Comply's inspection directory.",
                revisionDate: "January 12, 2024",
                confirmedCount: "8 of 8 BankID ballots archived",
                isAuditLog: true
            )
        ]
    }
}

// MARK: - Company Benefits Provider
public func getCompanyBenefits(for language: AppLanguage) -> [CompanyBenefitItem] {
    switch language {
    case .se:
        return [
            CompanyBenefitItem(
                id: "benefit_wellness",
                icon: "figure.run",
                title: "Friskvård & Hälsa",
                highlight: "5 000 kr / år",
                description: "Skattefritt friskvårdsbidrag för gym, simning, padel eller massage. Kvitto registreras enkelt via lönemodulen. Dessutom gemensam fredagsträning kl 15:00 samt privat sjukvårdsförsäkring via Euro Accident.",
                tags: ["Skattefritt", "Euro Accident", "Fredagsträning"]
            ),
            CompanyBenefitItem(
                id: "benefit_hybrid",
                icon: "laptopcomputer.and.iphone",
                title: "Hybrid & Hemarbete",
                highlight: "Upp till 2 dgr / v",
                description: "Frihet under ansvar med flexibla arbetstider. Kärnarbetstid 09:00–15:00. Fjord Dynamics bekostar ett komplett ergonomiskt hemmakontor (skärm, höj-/sänkbart bord, stol) upp till 10 000 kr.",
                tags: ["Frihet under ansvar", "10 000 kr hemutrustning", "Kärntid 09-15"]
            ),
            CompanyBenefitItem(
                id: "benefit_it",
                icon: "desktopcomputer",
                title: "IT, Hårdvara & Mobil",
                highlight: "Valfri Mac / PC",
                description: "Valfri MacBook Pro (M3/M4) eller ThinkPad vid start. Mobilabonnemang med obegränsad surf och fria samtal inom EU/EES. 1Password och FileVault obligatoriskt på samtliga enheter.",
                tags: ["Apple Silicon / PC", "Fri surf EU/EES", "1Password Enterprise"]
            )
        ]
    case .no:
        return [
            CompanyBenefitItem(
                id: "benefit_wellness",
                icon: "figure.run",
                title: "Trening & Helse",
                highlight: "5 000 kr / år",
                description: "Skattefritt treningsbidrag til treningssenter, svømming eller massasje. Kvittering registreres via Tripletex. Felles fredagstrening kl 15:00 samt privat helseforsikring via Euro Accident.",
                tags: ["Skattefritt", "Euro Accident", "Fredagstrening"]
            ),
            CompanyBenefitItem(
                id: "benefit_hybrid",
                icon: "laptopcomputer.and.iphone",
                title: "Hybrid & Hjemmekontor",
                highlight: "Opptil 2 dager / uke",
                description: "Frihet under ansvar med fleksibel arbeidstid. Kjernetid 09:00–15:00. Fjord Dynamics dekker komplett ergonomisk hjemmekontor (skjerm, hev/senk-pult, stol) opptil 10 000 kr.",
                tags: ["Frihet under ansvar", "10 000 kr hjemmekontor", "Kjernetid 09-15"]
            ),
            CompanyBenefitItem(
                id: "benefit_it",
                icon: "desktopcomputer",
                title: "IT, Maskinvare & Mobil",
                highlight: "Valgfri Mac / PC",
                description: "Valgfri MacBook Pro (M3/M4) eller ThinkPad ved oppstart. Fri mobil med ubegrenset data i EU/EØS. 1Password og FileVault aktivert på samtlige enheter.",
                tags: ["Apple Silicon / PC", "Fri data EU/EØS", "1Password Enterprise"]
            )
        ]
    case .en:
        return [
            CompanyBenefitItem(
                id: "benefit_wellness",
                icon: "figure.run",
                title: "Wellness & Health",
                highlight: "€500 / year",
                description: "Tax-free wellness subsidy for gym memberships, swimming, padel, or massage. Receipts filed directly in payroll. Joint Friday workout at 15:00 plus comprehensive private healthcare.",
                tags: ["Tax-Free", "Private Healthcare", "Friday Workout"]
            ),
            CompanyBenefitItem(
                id: "benefit_hybrid",
                icon: "laptopcomputer.and.iphone",
                title: "Hybrid & Remote Work",
                highlight: "Up to 2 days / wk",
                description: "Freedom with responsibility and flexible hours. Core hours 09:00–15:00. Fjord Dynamics subsidizes an ergonomic home office setup (monitor, standing desk, chair) up to €1,000.",
                tags: ["Flexible Hours", "€1,000 Home Setup", "Core 09-15"]
            ),
            CompanyBenefitItem(
                id: "benefit_it",
                icon: "desktopcomputer",
                title: "IT, Hardware & Mobile",
                highlight: "Choice of Mac / PC",
                description: "Choice of MacBook Pro (M3/M4) or ThinkPad on day one. Unlimited corporate mobile plan with 5G data across EU/EEA. 1Password and FileVault enforced on all endpoints.",
                tags: ["Apple Silicon / PC", "Unlimited EU Data", "1Password Enterprise"]
            )
        ]
    }
}

public struct AuditRowView: View {
    public let rec: AuditRecordItem
    
    public init(rec: AuditRecordItem) {
        self.rec = rec
    }
    
    public var body: some View {
        HStack {
            Circle()
                .fill(SolTokens.lav400)
                .frame(width: 5, height: 5)
            Text(rec.name)
                .font(.inter(11, .medium))
                .foregroundColor(SolTokens.ink900)
            Text("(\(rec.role))")
                .font(.inter(10))
                .foregroundColor(SolTokens.ink450)
            Spacer()
            Text(rec.date)
                .font(.system(size: 9.5, design: .monospaced))
                .foregroundColor(SolTokens.ink600)
        }
        .padding(.vertical, 2)
    }
}

public struct AuditRecordsListView: View {
    public let records: [AuditRecordItem]
    
    public init(records: [AuditRecordItem]) {
        self.records = records
    }
    
    public var body: some View {
        VStack(spacing: 6) {
            ForEach(records) { rec in
                AuditRowView(rec: rec)
            }
        }
        .padding(10)
        .background(SolTokens.paper200)
        .cornerRadius(6)
    }
}

// MARK: - Calm, Apple-Grade Card Views (Unified Inward Fillet Geometry)

public struct InwardFilletShape: Shape {
    public let activeCol: Int
    public var totalCols: Int = 3
    public var spacing: CGFloat = 14
    public var cardHeight: CGFloat = 214
    public var rowMargin: CGFloat = 14
    public var r: CGFloat = 10
    public var inwardR: CGFloat = 12
    
    public init(activeCol: Int, totalCols: Int = 3, spacing: CGFloat = 14, cardHeight: CGFloat = 214, rowMargin: CGFloat = 14, r: CGFloat = 10, inwardR: CGFloat = 12) {
        self.activeCol = activeCol
        self.totalCols = totalCols
        self.spacing = spacing
        self.cardHeight = cardHeight
        self.rowMargin = rowMargin
        self.r = r
        self.inwardR = inwardR
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let totalW = rect.width
        let colW = (totalW - CGFloat(totalCols - 1) * spacing) / CGFloat(totalCols)
        let cardX = CGFloat(activeCol) * (colW + spacing)
        let cardRight = cardX + colW
        let drawerTop = cardHeight + rowMargin
        let bottom = rect.height
        
        path.move(to: CGPoint(x: r, y: bottom))
        path.addLine(to: CGPoint(x: totalW - r, y: bottom))
        path.addArc(center: CGPoint(x: totalW - r, y: bottom - r), radius: r, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)
        
        if activeCol == 2 {
            path.addLine(to: CGPoint(x: totalW, y: r))
            path.addArc(center: CGPoint(x: totalW - r, y: r), radius: r, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: cardX + r, y: 0))
            path.addArc(center: CGPoint(x: cardX + r, y: r), radius: r, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: cardX, y: drawerTop - inwardR))
            path.addArc(center: CGPoint(x: cardX - inwardR, y: drawerTop - inwardR), radius: inwardR, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: r, y: drawerTop))
            path.addArc(center: CGPoint(x: r, y: drawerTop + r), radius: r, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: bottom - r))
            path.addArc(center: CGPoint(x: r, y: bottom - r), radius: r, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
        } else if activeCol == 0 {
            path.addLine(to: CGPoint(x: totalW, y: drawerTop + r))
            path.addArc(center: CGPoint(x: totalW - r, y: drawerTop + r), radius: r, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: cardRight + inwardR, y: drawerTop))
            path.addArc(center: CGPoint(x: cardRight + inwardR, y: drawerTop - inwardR), radius: inwardR, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: cardRight, y: r))
            path.addArc(center: CGPoint(x: cardRight - r, y: r), radius: r, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: r, y: 0))
            path.addArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: bottom - r))
            path.addArc(center: CGPoint(x: r, y: bottom - r), radius: r, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: totalW, y: drawerTop + r))
            path.addArc(center: CGPoint(x: totalW - r, y: drawerTop + r), radius: r, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: cardRight + inwardR, y: drawerTop))
            path.addArc(center: CGPoint(x: cardRight + inwardR, y: drawerTop - inwardR), radius: inwardR, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: cardRight, y: r))
            path.addArc(center: CGPoint(x: cardRight - r, y: r), radius: r, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: cardX + r, y: 0))
            path.addArc(center: CGPoint(x: cardX + r, y: r), radius: r, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: cardX, y: drawerTop - inwardR))
            path.addArc(center: CGPoint(x: cardX - inwardR, y: drawerTop - inwardR), radius: inwardR, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: r, y: drawerTop))
            path.addArc(center: CGPoint(x: r, y: drawerTop + r), radius: r, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: bottom - r))
            path.addArc(center: CGPoint(x: r, y: bottom - r), radius: r, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
        }
        
        path.closeSubpath()
        return path
    }
}

public struct HandbookColumnCard: View {
    public let chapter: HandbookChapterItem
    public let isSelected: Bool
    public var cardHeight: CGFloat = 214
    public let onSelect: () -> Void
    @State private var isHovered: Bool = false
    
    public init(chapter: HandbookChapterItem, isSelected: Bool, cardHeight: CGFloat = 214, onSelect: @escaping () -> Void) {
        self.chapter = chapter
        self.isSelected = isSelected
        self.cardHeight = cardHeight
        self.onSelect = onSelect
    }
    
    private var sectionTag: String {
        if chapter.isAuditLog {
            switch ComplyStore.shared.language {
            case .se: return "JURIDISKT BEVIS"
            case .no: return "JURIDISK BEVIS"
            case .en: return "LEGAL AUDIT PROOF"
            }
        } else {
            return "\(ComplyStore.shared.l10n.chapterPrefix.uppercased()) \(chapter.chapterNumber)"
        }
    }
    
    private var actionLinkLabel: String {
        if chapter.isAuditLog {
            switch ComplyStore.shared.language {
            case .se: return "Visa certifikat & signaturer"
            case .no: return "Vis sertifikater & signaturer"
            case .en: return "View certificates & signatures"
            }
        } else {
            switch ComplyStore.shared.language {
            case .se: return "Se regler & policy"
            case .no: return "Se retningslinjer & praksis"
            case .en: return "View policy & guidelines"
            }
        }
    }
    
    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                // Top: 36x36 Calm Sol Badge + Quiet Neutral Revision Pill + Chevron
                HStack(alignment: .center) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(SolTokens.paper200)
                            .frame(width: 36, height: 36)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                        Image(systemName: chapter.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(SolTokens.lav400)
                    }
                    
                    Spacer()
                    
                    // Quiet, low-contrast neutral pill (ZERO false alarm colors)
                    HStack(spacing: 5) {
                        Circle()
                            .fill(isSelected ? SolTokens.lav400 : SolTokens.ink450)
                            .frame(width: 4, height: 4)
                        Text(chapter.statusText)
                            .font(.inter(11, .medium))
                            .foregroundColor(isSelected ? Color.white : SolTokens.ink600)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 7.5)
                    .padding(.vertical, 3.5)
                    .background(isSelected ? SolTokens.paper300 : SolTokens.paper200)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(isSelected ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1))
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? Color.white : SolTokens.ink450)
                        .padding(.leading, 4)
                }
                
                // Title & Statute
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(sectionTag)
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(isSelected ? SolTokens.ink600 : SolTokens.ink450)
                            .tracking(0.4)
                        
                        Text("•")
                            .font(.system(size: 8))
                            .foregroundColor(isSelected ? SolTokens.ink600 : SolTokens.ink450)
                        
                        Text(chapter.statute)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(isSelected ? SolTokens.lav400 : SolTokens.ink450)
                    }
                    
                    Text(chapter.title)
                        .font(.inter(14, .bold))
                        .foregroundColor(Color.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Summary description
                Text(chapter.summary)
                    .font(.inter(12))
                    .foregroundColor(isSelected ? Color.white.opacity(0.92) : SolTokens.ink700)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 8)
                
                if !isSelected {
                    HStack(spacing: 4) {
                        Text(actionLinkLabel)
                            .font(.inter(11, .semibold))
                            .foregroundColor(chapter.isAuditLog ? SolTokens.lav400 : SolTokens.ink600)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(chapter.isAuditLog ? SolTokens.lav400 : SolTokens.ink600)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
            .background(
                Group {
                    if isSelected {
                        Color.clear
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isHovered ? SolTokens.paper200 : SolTokens.paper100)
                    }
                }
            )
            .overlay(
                Group {
                    if isSelected {
                        Color.clear
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isHovered ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1)
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hover in
            isHovered = hover
        }
    }
}

public struct HandbookRowDetailBox: View {
    public let chapter: HandbookChapterItem
    public let activeCol: Int
    public let onClose: () -> Void
    @State private var isHoveredClose: Bool = false
    
    public init(chapter: HandbookChapterItem, activeCol: Int = 0, onClose: @escaping () -> Void) {
        self.chapter = chapter
        self.activeCol = activeCol
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Streamlined Section Heading & Close Button
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SolTokens.lav400)
                    Text(ComplyStore.shared.language == .se 
                         ? "LAGSTADGADE KRAV VS. FÖRETAGSPOLICY" 
                         : (ComplyStore.shared.language == .no 
                            ? "LOVPÅLAGTE KRAV VS. BEDRIFTSRETNINGSLINJER" 
                            : "STATUTORY REQUIREMENTS VS. COMPANY POLICY"))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    HStack(spacing: 5) {
                        Text(ComplyStore.shared.language == .se ? "Stäng" : (ComplyStore.shared.language == .no ? "Lukk" : "Close"))
                            .font(.inter(11, .medium))
                            .foregroundColor(isHoveredClose ? SolTokens.ink900 : SolTokens.ink600)
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isHoveredClose ? SolTokens.ink900 : SolTokens.ink600)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isHoveredClose ? SolTokens.paper300 : SolTokens.paper200)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper400, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .onHover { hover in
                    isHoveredClose = hover
                }
            }
            
            Divider()
                .background(SolTokens.paper300)
            
            // Middle: If Audit Log, show signatures. Otherwise show 3-column statutory breakdown
            if chapter.isAuditLog {
                VStack(alignment: .leading, spacing: 10) {
                    Text(ComplyStore.shared.language == .se ? "DIGITALA BANKID-KVITTERINGAR (8 AV 8 MEDARBETARE)" : (ComplyStore.shared.language == .no ? "DIGITALE BANKID-KVITTERINGER (8 AV 8 MEDARBEIDERE)" : "DIGITAL BANKID ACKNOWLEDGEMENTS (8 OF 8 EMPLOYEES)"))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.ink450)
                    
                    HStack(alignment: .top, spacing: 14) {
                        AuditRecordsListView(records: Array(auditRecords.prefix(4)))
                            .frame(maxWidth: .infinity)
                        AuditRecordsListView(records: Array(auditRecords.suffix(4)))
                            .frame(maxWidth: .infinity)
                    }
                }
            } else {
                // 3 Column Grid for Content
                HStack(alignment: .top, spacing: 16) {
                    // Column 1: Statutory Law
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: "scale.3d")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SolTokens.indigo)
                            Text(ComplyStore.shared.language == .se ? "LAGKRAV (\(chapter.statute))" : (ComplyStore.shared.language == .no ? "LOVKRAV (\(chapter.statute))" : "STATUTORY LAW (\(chapter.statute))"))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        Text(chapter.statutoryRule)
                            .font(.inter(12))
                            .foregroundColor(Color.white.opacity(0.92))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(12)
                    .background(SolTokens.paper200.opacity(0.6))
                    .cornerRadius(8)
                    
                    // Column 2: Company Policy
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SolTokens.lav400)
                            Text(ComplyStore.shared.language == .se ? "FÖRETAGETS POLICY" : (ComplyStore.shared.language == .no ? "BEDRIFTENS RETNINGSLINJER" : "COMPANY POLICY"))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        Text(chapter.companyPolicy)
                            .font(.inter(12))
                            .foregroundColor(Color.white.opacity(0.92))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(12)
                    .background(SolTokens.paper200.opacity(0.6))
                    .cornerRadius(8)
                    
                    // Column 3: Day-to-Day Guidelines
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SolTokens.ink600)
                            Text(ComplyStore.shared.language == .se ? "I VARDAGEN" : (ComplyStore.shared.language == .no ? "I HVERDAGEN" : "DAY-TO-DAY"))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        Text(chapter.practicalGuideline)
                            .font(.inter(12))
                            .foregroundColor(Color.white.opacity(0.92))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(12)
                    .background(SolTokens.paper200.opacity(0.6))
                    .cornerRadius(8)
                }
                
                if chapter.isAiChapter {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ComplyStore.shared.l10n.handbookApprovedAiToolsHeader)
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                            .padding(.top, 4)
                        
                        HStack(spacing: 10) {
                            AIToolChip(name: "ChatGPT Team", vendor: "OpenAI", status: ComplyStore.shared.l10n.aiChipTextStatus)
                            AIToolChip(name: "Claude Enterprise", vendor: "Anthropic", status: ComplyStore.shared.l10n.aiChipDataStatus)
                            AIToolChip(name: "GitHub Copilot", vendor: "Microsoft", status: ComplyStore.shared.l10n.aiChipCodeStatus)
                        }
                    }
                }
            }
            
            // Footer: Verification & Date
            HStack(spacing: 12) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.lav400)
                    Text(chapter.confirmedCount)
                        .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                        .foregroundColor(SolTokens.ink600)
                }
                
                Spacer()
                
                Text(chapter.revisionDate)
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundColor(SolTokens.ink450)
            }
            .padding(.top, 2)
        }
        .padding(18)
        .background(Color.clear)
    }
}

public struct CompanyBenefitCard: View {
    public let benefit: CompanyBenefitItem
    @State private var isHovered: Bool = false
    
    public init(benefit: CompanyBenefitItem) {
        self.benefit = benefit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SolTokens.paper200)
                        .frame(width: 36, height: 36)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                    Image(systemName: benefit.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(SolTokens.lav400)
                }
                
                Spacer()
                
                // Calm, neutral highlight badge (ZERO compliance green)
                Text(benefit.highlight)
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 7.5)
                    .padding(.vertical, 3.5)
                    .background(SolTokens.paper200)
                    .foregroundColor(SolTokens.lav400)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(benefit.title)
                    .font(.inter(14, .bold))
                    .foregroundColor(SolTokens.ink900)
            }
            
            Text(benefit.description)
                .font(.inter(12))
                .foregroundColor(SolTokens.ink700)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                ForEach(benefit.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink600)
                        .cornerRadius(3)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHovered ? SolTokens.paper200 : SolTokens.paper100)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isHovered ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1)
        )
        .onHover { hover in
            isHovered = hover
        }
    }
}


struct RadarThresholdCard: View {
    let threshold: String
    let statute: String
    let title: String
    let statusText: String
    let statusColor: Color
    var statusBg: Color? = nil
    let description: String
    var isActive: Bool = false
    var footerNotice: String? = nil
    var footerIcon: String? = nil
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                HStack(spacing: 8) {
                    Text(threshold)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(isActive ? SolTokens.lav400.opacity(0.14) : SolTokens.paper200)
                        .foregroundColor(isActive ? SolTokens.lav400 : SolTokens.ink700)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(isActive ? SolTokens.lav400.opacity(0.3) : SolTokens.paper300, lineWidth: 1))
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
            
            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    HStack(spacing: 6) {
                        Text(actionTitle)
                            .font(.inter(12, .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(SolTokens.lav400)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(SolTokens.lav400.opacity(0.12))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.lav400.opacity(0.28), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            
            if let footerNotice = footerNotice {
                HStack(spacing: 6) {
                    if let footerIcon = footerIcon {
                        Image(systemName: footerIcon)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(footerIcon.contains("checkmark") ? SolTokens.green800 : SolTokens.ink600)
                    }
                    Text(footerNotice)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(SolTokens.ink600)
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(isActive ? SolTokens.paper200 : SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isActive ? SolTokens.lav400.opacity(0.35) : SolTokens.paper300, lineWidth: 1))
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
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                action()
            }
        } label: {
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
