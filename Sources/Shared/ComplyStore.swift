import SwiftUI
import Combine

#if os(macOS)
private let currentPlatform = "mac"
#else
private let currentPlatform = "ios"
#endif

private let syncFilePath = "/tmp/simployer_comply_sync.json"

@MainActor
public class ComplyStore: ObservableObject {
    public static let shared = ComplyStore()
    
    @Published public var currentYear: CompanyYear = .y2024
    @Published public var language: AppLanguage = {
        if let saved = UserDefaults.standard.string(forKey: "comply_app_language"),
           let lang = AppLanguage(rawValue: saved) {
            return lang
        }
        return .no
    }()
    @Published public var activeNav: String = "hub"
    @Published public var hasIngestedFiles: Bool = false
    @Published public var selectedDiffEmployee: Employee? = nil
    @Published public var verneombudElectionActive: Bool = false
    @Published public var electionVotesCast: Int = 0
    @Published public var equalPayReportGenerated: Bool = false
    @Published public var sickLeavePlanDispatched: Bool = false
    @Published public var juristHandoffCompleted: Bool = false
    @Published public var hmsTrainingEnrolled: Bool = false
    @Published public var probationConfirmed: Bool = false
    @Published public var isAutoplayRunning: Bool = false
    @Published public var lastSyncTimestamp: Date = Date()
    @Published public var showUpsellModal: Bool = false
    @Published public var showElectionModal: Bool = false
    @Published public var showDialogMeetingModal: Bool = false
    @Published public var showDismissalDefenseModal: Bool = false
    @Published public var showAuditReportSheet: Bool = false
    @Published public var auditReportSavedToast: String? = nil
    
    // MARK: - Headless Integrations & Settings State
    @Published public var slackInstantAlerts: Bool = true
    @Published public var slackWeeklyDigest: Bool = true
    @Published public var teamsAdaptiveCards: Bool = true
    @Published public var emailMonthlySummary: Bool = true
    @Published public var slackTestToast: String? = nil
    
    // MARK: - Bolagsresan Growth Timeline
    @Published public var selectedTimelineTier: Int = 2 // 1: 1-4, 2: 5-9, 3: 10-29, 4: 30-49, 5: 50+
    
    public func sendTestSlackAlert() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.slackTestToast = l10n.settingsSlackTestToast
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.slackTestToast = nil
            }
        }
    }
    
    // MARK: - Nov 8 Per & Rasmus Alignment State
    @Published public var selectedCalculationTab: String = "feriepenger"
    @Published public var annualSalaryInput: Double = 650000
    @Published public var fiveWeeksHoliday: Bool = true
    @Published public var sickLeaveDurationWeeks: Int = 4
    @Published public var selfCertUsedDays: Int = 3
    @Published public var isUploadingRoster: Bool = false
    @Published public var rosterUploadToast: String? = nil
    @Published public var showAskJuristSheet: Bool = false
    @Published public var juristInquirySent: Bool = false
    
    // MARK: - Ingestion Sources & Local Monitored Guard State
    @Published public var connectedCloudServices: Set<String> = ["onedrive"]
    @Published public var monitoredLocalFolders: [String] = ["~/Downloads", "~/Documents/HR"]
    @Published public var isScanningSources: Bool = false
    @Published public var selectedConnectModal: String? = nil
    @Published public var activeFileViewTab: String = "overview"
    
    // In-memory scenario datasets
    @Published public var scenarios: [CompanyYear: YearScenarioData] = [:]
    
    private var syncTimer: AnyCancellable?
    private var lastReceivedSyncTime: Double = 0
    
    public init() {
        self.scenarios = Self.loadDefaultScenarios()
        setupSyncObserver()
        broadcastSync()
    }
    
    private func setupSyncObserver() {
        readSyncFile()
        syncTimer = Timer.publish(every: 0.4, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.readSyncFile()
            }
    }
    
    private func readSyncFile() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: syncFilePath)),
              let payload = try? JSONDecoder().decode(SyncPayload.self, from: data) else {
            return
        }
        
        guard payload.sender != currentPlatform else { return }
        guard payload.lastUpdated > self.lastReceivedSyncTime else { return }
        
        self.lastReceivedSyncTime = payload.lastUpdated
        
        if let year = CompanyYear(rawValue: payload.year), self.currentYear != year {
            self.currentYear = year
        }
        
        if let lang = AppLanguage(rawValue: payload.language), self.language != lang {
            self.language = lang
        }
        
        self.activeNav = payload.activeNav
        self.verneombudElectionActive = payload.verneombudElectionActive
        self.electionVotesCast = payload.electionVotesCast
        
        if let tier = payload.selectedTimelineTier {
            self.selectedTimelineTier = tier
        }
        if let toast = payload.slackTestToastActive, toast {
            self.sendTestSlackAlert()
        }
        
        for empId in payload.approvedEmployeeIds {
            for (yearKey, var scenario) in self.scenarios {
                if let idx = scenario.employees.firstIndex(where: { $0.id == empId }) {
                    if scenario.employees[idx].status != .ok {
                        scenario.employees[idx].status = .ok
                        scenario.employees[idx].statusLabel = "Lovlig (AML § 14-6 BankID signert)"
                        self.scenarios[yearKey] = scenario
                    }
                }
            }
        }
        
        self.lastSyncTimestamp = Date()
    }
    
    public func broadcastSync() {
        let approvedIds = scenarios.values.flatMap { $0.employees }
            .filter { $0.status == .ok }
            .map { $0.id }
        
        let now = Date().timeIntervalSince1970
        self.lastReceivedSyncTime = now
        
        let payload = SyncPayload(
            year: currentYear.rawValue,
            activeNav: activeNav,
            approvedEmployeeIds: Array(Set(approvedIds)),
            verneombudElectionActive: verneombudElectionActive,
            electionVotesCast: electionVotesCast,
            lastUpdated: now,
            sender: currentPlatform,
            language: language.rawValue
        )
        
        if let data = try? JSONEncoder().encode(payload) {
            try? data.write(to: URL(fileURLWithPath: syncFilePath))
        }
    }
    
    public var currentScenario: YearScenarioData {
        guard let base = scenarios[currentYear] else {
            return Self.loadDefaultScenarios()[.y2024]!
        }
        
        let locContent = l10n.scenarios[currentYear]
        
        return YearScenarioData(
            year: base.year,
            stageName: locContent?.stageName ?? base.stageName,
            tagline: locContent?.tagline ?? base.tagline,
            headcount: base.headcount,
            revenue: base.revenue,
            hrOwner: base.hrOwner,
            systemOfRecord: base.systemOfRecord,
            primaryRisk: locContent?.primaryRisk ?? base.primaryRisk,
            activeTrigger: StatutoryTrigger(
                title: locContent?.triggerTitle ?? base.activeTrigger.title,
                statute: locContent?.triggerStatute ?? base.activeTrigger.statute,
                description: locContent?.triggerDescription ?? base.activeTrigger.description,
                consequence: locContent?.triggerConsequence ?? base.activeTrigger.consequence,
                actionLabel: locContent?.triggerActionLabel ?? base.activeTrigger.actionLabel
            ),
            recommendedUpsell: RecommendedUpsell(
                product: locContent?.upsellProduct ?? base.recommendedUpsell.product,
                title: locContent?.upsellTitle ?? base.recommendedUpsell.title,
                price: locContent?.upsellPrice ?? base.recommendedUpsell.price,
                benefit: locContent?.upsellBenefit ?? base.recommendedUpsell.benefit
            ),
            employees: base.employees
        )
    }
    
    public var l10n: LocalizedStrings {
        L10n.strings(for: language)
    }
    
    public func setLanguage(_ lang: AppLanguage) {
        self.language = lang
        UserDefaults.standard.set(lang.rawValue, forKey: "comply_app_language")
        broadcastSync()
    }
    
    public func setYear(_ year: CompanyYear) {
        self.currentYear = year
        self.activeNav = "hub"
        self.hasIngestedFiles = true
        broadcastSync()
    }
    
    public func approveContract(for empId: String) {
        guard var scenario = scenarios[currentYear] else { return }
        if let idx = scenario.employees.firstIndex(where: { $0.id == empId }) {
            scenario.employees[idx].status = .ok
            scenario.employees[idx].statusLabel = "Lovlig (AML § 14-6 BankID signert)"
            scenarios[currentYear] = scenario
            lastSyncTimestamp = Date()
            broadcastSync()
        }
    }
    
    public func castVerneombudVote() {
        self.verneombudElectionActive = true
        self.electionVotesCast += 1
        lastSyncTimestamp = Date()
        broadcastSync()
    }
    
    public func enrollHmsCourse() {
        self.hmsTrainingEnrolled = true
        if var scenario = scenarios[.y2024] {
            for i in 0..<scenario.employees.count {
                if scenario.employees[i].id == "01" {
                    scenario.employees[i].statusLabel = "I orden (HMS godkjent)"
                }
            }
            scenarios[.y2024] = scenario
        }
        lastSyncTimestamp = Date()
        broadcastSync()
    }
    
    public enum ComplianceSeverity: String, Sendable {
        case compliant // Green: All required compliance tasks satisfied
        case warning   // Orange/Yellow: Actions required, but within window
        case behind    // Red: Behind on submitting statutory requirement
    }
    
    public var complianceSeverity: ComplianceSeverity {
        if pendingActionCount == 0 {
            return .compliant
        }
        
        switch currentYear {
        case .y2024:
            // July 1 2024 deadline passed: missing mandatory clauses is an active violation
            let hasUnapproved = currentScenario.employees.contains { $0.status == .aml14Gap }
            if hasUnapproved {
                return .behind
            }
            // Verneombud election required, within setup grace period
            return .warning
            
        case .y2025:
            // ARP Equal Pay analysis & Sick leave follow-up within timeline
            return .warning
            
        case .y2027:
            // Procedural dismissal breach (§ 15-1) without drøftelsesmøte
            if !juristHandoffCompleted {
                return .behind
            }
            return .warning
        }
    }
    
    public var pendingActionCount: Int {
        var count = 0
        switch currentYear {
        case .y2024:
            let hasUnapproved = currentScenario.employees.contains { $0.status == .aml14Gap }
            if hasUnapproved { count += 1 }
            if !verneombudElectionActive { count += 1 }
            if !hmsTrainingEnrolled { count += 1 }
        case .y2025:
            if !equalPayReportGenerated { count += 1 }
            if !sickLeavePlanDispatched { count += 1 }
            let probationSoon = currentScenario.employees.contains { $0.status == .probationSoon }
            if probationSoon { count += 1 }
        case .y2027:
            if !juristHandoffCompleted { count += 1 }
        }
        return count
    }
    
    public func approveAllContracts() {
        guard var scenario = scenarios[currentYear] else { return }
        for i in 0..<scenario.employees.count {
            if scenario.employees[i].status == .aml14Gap {
                scenario.employees[i].status = .ok
                scenario.employees[i].statusLabel = "Lovlig (AML § 14-6 BankID signert)"
            }
        }
        scenarios[currentYear] = scenario
        lastSyncTimestamp = Date()
        broadcastSync()
    }
    
    public func resolveAllActionHubItems() {
        switch currentYear {
        case .y2024:
            approveAllContracts()
            self.verneombudElectionActive = true
            self.electionVotesCast = 8
            self.hmsTrainingEnrolled = true
            if var scenario = scenarios[.y2024] {
                for i in 0..<scenario.employees.count {
                    if scenario.employees[i].id == "01" {
                        scenario.employees[i].statusLabel = "I orden (HMS godkjent)"
                    }
                }
                scenarios[.y2024] = scenario
            }
        case .y2025:
            self.equalPayReportGenerated = true
            self.sickLeavePlanDispatched = true
            self.probationConfirmed = true
            if var scenario = scenarios[.y2025] {
                for i in 0..<scenario.employees.count {
                    if scenario.employees[i].status == .probationSoon || scenario.employees[i].status == .sickD14 {
                        scenario.employees[i].status = .ok
                        scenario.employees[i].statusLabel = "I orden (HMS godkjent)"
                    }
                }
                scenarios[.y2025] = scenario
            }
        case .y2027:
            self.juristHandoffCompleted = true
            if var scenario = scenarios[.y2027] {
                for i in 0..<scenario.employees.count {
                    if scenario.employees[i].id == "35" {
                        scenario.employees[i].status = .ok
                        scenario.employees[i].statusLabel = "I orden (Simployer Jurist godkjent)"
                    }
                }
                scenarios[.y2027] = scenario
            }
        }
        lastSyncTimestamp = Date()
        broadcastSync()
    }
    
    public func resetDemoState() {
        self.scenarios = Self.loadDefaultScenarios()
        self.verneombudElectionActive = false
        self.electionVotesCast = 0
        self.equalPayReportGenerated = false
        self.sickLeavePlanDispatched = false
        self.juristHandoffCompleted = false
        self.hmsTrainingEnrolled = false
        self.probationConfirmed = false
        self.hasIngestedFiles = false
        self.activeNav = "hub"
        self.currentYear = .y2024
        lastSyncTimestamp = Date()
        broadcastSync()
    }
    
    private static func loadDefaultScenarios() -> [CompanyYear: YearScenarioData] {
        return [
            .y2024: YearScenarioData(
                year: .y2024,
                stageName: "The Seedling (Oppstart & Kaos)",
                tagline: "8 ansatte · Google Drive-kaos · Daglig leder gjør alt",
                headcount: 8,
                revenue: "11 MNOK",
                hrOwner: "Jonas Berg (Daglig leder)",
                systemOfRecord: "Google Drive & lokale Mac-mapper",
                primaryRisk: "Mangler verneombud (AML § 6-1 senket til 5) + 8 ulovlige avtaler (AML § 14-6)",
                activeTrigger: StatutoryTrigger(
                    title: "🚨 Lovpålagt Verneombud mangler",
                    statute: "AML § 6-1 (Krav fra 1. jan 2024)",
                    description: "Kravet til verneombud ble senket fra 10 til 5 ansatte. Fjord Dynamics har 8 ansatte og intet verneombud.",
                    consequence: "Arbeidstilsynet gir pålegg om stans eller tvangsmulkt ved tilsyn.",
                    actionLabel: "Start digitalt verneombudsvalg"
                ),
                recommendedUpsell: RecommendedUpsell(
                    product: "Simployer Learn",
                    title: "Lovpålagt HMS-kurs for daglig leder + 40t Verneombudskurs",
                    price: "1 490 kr per kurs",
                    benefit: "Sikrer godkjent kursbevis for oppbevaring i Comply."
                ),
                employees: [
                    Employee(id: "01", name: "Jonas Berg", role: "Daglig leder & Gründer", department: "Ledelse", salary: 95000, type: "Fast (100%)", startDate: "01.01.2021", contractVersion: "Standard 2021", status: .ok, statusLabel: "Mangler HMS-kurs (AML § 3-5)", overtimeExempt: true),
                    Employee(id: "02", name: "Silje Olsen", role: "Kontorleder & Koordinator", department: "Admin", salary: 48000, type: "Fast (80%)", startDate: "01.03.2021", contractVersion: "Standard 2021", status: .aml14Gap, statusLabel: "Ulovlig overtidsklausul (§ 14-6)", overtimeExempt: false),
                    Employee(id: "03", name: "Morten Dahl", role: "Seniorkonsulent Cloud", department: "Konsulent", salary: 75000, type: "Fast (100%)", startDate: "15.05.2021", contractVersion: "Standard 2021", status: .aml14Gap, statusLabel: "Mangler overtid & kompetanse (§ 14-6)", overtimeExempt: false),
                    Employee(id: "04", name: "Kasper Rahman", role: "Tech Lead & Arkitekt", department: "Utvikling", salary: 82000, type: "Fast (100%)", startDate: "01.08.2021", contractVersion: "Standard 2021", status: .aml14Gap, statusLabel: "Ulovlig overtidsklausul (§ 14-6)", overtimeExempt: false),
                    Employee(id: "05", name: "Sofia Rossi", role: "Senior UX Designer", department: "Design", salary: 68000, type: "Fast (100%)", startDate: "01.10.2021", contractVersion: "Standard 2021", status: .aml14Gap, statusLabel: "Mangler kompetansebestemmelse (§ 14-6)", overtimeExempt: false),
                    Employee(id: "06", name: "Henrik Myhre", role: "Backend-utvikler", department: "Utvikling", salary: 62000, type: "Fast (100%)", startDate: "01.01.2022", contractVersion: "Standard 2021", status: .aml14Gap, statusLabel: "Ulovlig overtidsklausul (§ 14-6)", overtimeExempt: false),
                    Employee(id: "07", name: "Freja Holm", role: "Frontend-utvikler", department: "Utvikling", salary: 58000, type: "Fast (100%)", startDate: "01.04.2022", contractVersion: "Standard 2021", status: .aml14Gap, statusLabel: "Ulovlig overtidsklausul (§ 14-6)", overtimeExempt: false),
                    Employee(id: "08", name: "Erlend Nakamura", role: "Salgssjef B2B", department: "Salg", salary: 65000, type: "Fast (100%)", startDate: "01.06.2022", contractVersion: "Standard 2021", status: .aml14Gap, statusLabel: "Ulovlig provisjonsbestemmelse (§ 14-6)", overtimeExempt: false)
                ]
            ),
            .y2025: YearScenarioData(
                year: .y2025,
                stageName: "The Scale-Up (Vekst & Terskelradar)",
                tagline: "38 ansatte · Camilla ansatt som solo HR · Tripletex-synk",
                headcount: 38,
                revenue: "46 MNOK",
                hrOwner: "Camilla Sunde (HR Lead)",
                systemOfRecord: "Tripletex Lønn + SharePoint",
                primaryRisk: "Krav om likestillingsrapport (ARP § 26) + Sykefravær dag 14 (AML § 4-6)",
                activeTrigger: StatutoryTrigger(
                    title: "⚖️ Lønnskartlegging (ARP) påkrevd ved 20+ ansatte",
                    statute: "Likestillings- og diskrimineringsloven § 26",
                    description: "Med 38 ansatte plikter bedriften å kartlegge lønnsforskjeller mellom kvinner og menn i samme stillingskategori.",
                    consequence: "Rapporteringsbrudd i årsberetningen kan medføre tilsyn fra Diskrimineringsnemnda.",
                    actionLabel: "Kjør automatisk lønnsgap-analyse"
                ),
                recommendedUpsell: RecommendedUpsell(
                    product: "Simployer Equal Pay + One Core",
                    title: "Automatisk ARP-rapport & Fullt HRM-system",
                    price: "79 kr / ansatt / mnd",
                    benefit: "Oppgraderer personalregisteret til full fraværs- og feriehåndtering uten manuell datamigrering."
                ),
                employees: [
                    Employee(id: "01", name: "Jonas Berg", role: "CEO & Co-founder", department: "Ledelse", salary: 110000, type: "Fast (100%)", startDate: "01.01.2021", contractVersion: "Sol Vetted 2024", status: .ok, statusLabel: "I orden (HMS godkjent)", overtimeExempt: true),
                    Employee(id: "03", name: "Morten Dahl", role: "Principal Cloud Engineer", department: "Konsulent", salary: 86000, type: "Fast (100%)", startDate: "15.05.2021", contractVersion: "Sol Vetted 2024", status: .sickD14, statusLabel: "Sykmeldt dag 14 (Dialogmøte kreves)", overtimeExempt: false),
                    Employee(id: "19", name: "Camilla Sunde", role: "Head of People & Culture", department: "People", salary: 72000, type: "Fast (100%)", startDate: "01.01.2025", contractVersion: "Sol Vetted 2024", status: .ok, statusLabel: "I orden", overtimeExempt: true),
                    Employee(id: "18", name: "Arvid Borg", role: "Juniorutvikler", department: "Utvikling", salary: 49000, type: "Prøvetid (6m)", startDate: "01.06.2024", contractVersion: "Sol Vetted 2024", status: .probationSoon, statusLabel: "Prøvetid utgår om 21 dager", overtimeExempt: false)
                ]
            ),
            .y2027: YearScenarioData(
                year: .y2027,
                stageName: "The Established Force (Etablert & Jurist)",
                tagline: "124 ansatte · Simployer One operativt · Lovpålagt Varslingskanal",
                headcount: 124,
                revenue: "165 MNOK",
                hrOwner: "Camilla Sunde (HR Director) + 2 koordinatorer",
                systemOfRecord: "Simployer One Core HRM",
                primaryRisk: "Desentraliserte linjeledere håndterer oppsigelser (Fare for 396k formfel)",
                activeTrigger: StatutoryTrigger(
                    title: "🛡️ Formfeil i oppsigelsessak (AML § 15-1)",
                    statute: "Arbeidsmiljøloven kapittel 15",
                    description: "Avdelingsleder i Bergen ønsker å si opp en ansatt for manglende leveranse. Ingen drøftelsesmøte er avholdt.",
                    consequence: "Norske domstoler kjenner oppsigelser ugyldige ved formfeil (median tap 396 000 kr + 250 000 kr saksomkostninger).",
                    actionLabel: "Aktiver Simployer Jurist før møte"
                ),
                recommendedUpsell: RecommendedUpsell(
                    product: "Simployer Expert Retainer",
                    title: "Ubegrenset skriftlig advokatbistand & Ansvarsdekning",
                    price: "3 990 kr / mnd",
                    benefit: "Sertifiserte arbeidsrettsjurister kvalitetssikrer drøftelser og oppsigelser med full ansvarsforsikring."
                ),
                employees: [
                    Employee(id: "01", name: "Jonas Berg", role: "CEO & Co-founder", department: "Ledelse", salary: 135000, type: "Fast (100%)", startDate: "01.01.2021", contractVersion: "Simployer One Sync", status: .ok, statusLabel: "I orden", overtimeExempt: true),
                    Employee(id: "03", name: "Morten Dahl", role: "VP of Engineering", department: "Ledelse", salary: 115000, type: "Fast (100%)", startDate: "15.05.2021", contractVersion: "Simployer One Sync", status: .ok, statusLabel: "I orden", overtimeExempt: true),
                    Employee(id: "19", name: "Camilla Sunde", role: "VP People & Culture", department: "People", salary: 95000, type: "Fast (100%)", startDate: "01.01.2025", contractVersion: "Simployer One Sync", status: .ok, statusLabel: "I orden", overtimeExempt: true),
                    Employee(id: "35", name: "Lars Viken", role: "Regionsjef Vest (Bergen)", department: "Drift", salary: 88000, type: "Fast (100%)", startDate: "01.02.2026", contractVersion: "Simployer One Sync", status: .aml14Gap, statusLabel: "Varsel: Krever AML § 15-1 bistand", overtimeExempt: true),
                    Employee(id: "52", name: "Kristin Mo", role: "Hovedverneombud (Valgt)", department: "HMS", salary: 76000, type: "Fast (100%)", startDate: "01.08.2025", contractVersion: "Simployer One Sync", status: .ok, statusLabel: "AMU-protokoll publisert", overtimeExempt: false)
                ]
            )
        ]
    }
    
    #if os(macOS)
    @discardableResult
    public func exportAuditReportPdf() -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let target = home.appendingPathComponent("Downloads/Simployer_Comply_Tilsynsbevis_Fjord_Dynamics.pdf")
        var mediaBox = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 standard
        
        guard let consumer = CGDataConsumer(url: target as CFURL),
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return nil
        }
        
        context.beginPDFPage(nil)
        
        // Background canvas
        context.setFillColor(CGColor(red: 246/255, green: 245/255, blue: 242/255, alpha: 1.0))
        context.fill(mediaBox)
        
        // Obsidian Executive Banner Header
        let headerRect = CGRect(x: 36, y: 730, width: 523.2, height: 80)
        context.setFillColor(CGColor(red: 16/255, green: 17/255, blue: 21/255, alpha: 1.0))
        let path = CGPath(roundedRect: headerRect, cornerWidth: 10, cornerHeight: 10, transform: nil)
        context.addPath(path)
        context.fillPath()
        
        // Brand Kicker
        let brandKicker = "SIMPLOYER COMPLY · REVISJONSRAPPORT & TILSYNSBEVIS" as NSString
        brandKicker.draw(at: CGPoint(x: 56, y: 780), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 9.5),
            .foregroundColor: NSColor(red: 151/255, green: 115/255, blue: 255/255, alpha: 1.0)
        ])
        
        let reportTitle = "Offisielt Tilsynsbevis for Arbeidsrettslig Etterlevelse" as NSString
        reportTitle.draw(at: CGPoint(x: 56, y: 757), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 14.5),
            .foregroundColor: NSColor.white
        ])
        
        let subTitle = "Fjord Dynamics AS · Org.nr 923 456 789 · 8 ansatte · BankID SHA-256 Verifisert" as NSString
        subTitle.draw(at: CGPoint(x: 56, y: 742), withAttributes: [
            .font: NSFont.systemFont(ofSize: 9.0),
            .foregroundColor: NSColor(white: 0.75, alpha: 1.0)
        ])
        
        // Metadata Table
        var currY: CGFloat = 695
        func drawLine(_ label: String, _ value: String, isGreen: Bool = false) {
            (label as NSString).draw(at: CGPoint(x: 56, y: currY), withAttributes: [
                .font: NSFont.systemFont(ofSize: 9.5),
                .foregroundColor: NSColor(white: 0.40, alpha: 1.0)
            ])
            (value as NSString).draw(at: CGPoint(x: 210, y: currY), withAttributes: [
                .font: isGreen ? NSFont.boldSystemFont(ofSize: 9.5) : NSFont.systemFont(ofSize: 9.5),
                .foregroundColor: isGreen ? NSColor(red: 25/255, green: 115/255, blue: 55/255, alpha: 1.0) : NSColor(white: 0.15, alpha: 1.0)
            ])
            currY -= 18
        }
        
        drawLine("Selskap & Organisasjon:", "Fjord Dynamics AS (Org.nr: 923 456 789)")
        drawLine("Gjeldende Jurisdiksjon:", "Norge & Sverige (Arbeidsmiljøloven, Ferieloven, Likestillingsloven)")
        drawLine("Total Revisionsstatus:", "10 av 10 lagkrav sikret (100 %) — Kontinuerlig overvåket", isGreen: true)
        drawLine("Revisjonstidspunkt:", "\(Date().formatted(date: .complete, time: .shortened))")
        drawLine("Digital Revisionsnøkkel:", "BankID SHA-256: 8f94-c012-e5b7-9941-20261108")
        drawLine("Ansvarlig Tilsynsinstans:", "Simployer Continuous Legal Compliance Engine v4.2")
        
        currY -= 16
        
        // Checklist Section
        let checklistTitle = "REVIDERTE OG DOKUMENTERTE LAGKRAV" as NSString
        checklistTitle.draw(at: CGPoint(x: 56, y: currY), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 10.5),
            .foregroundColor: NSColor(red: 45/255, green: 12/255, blue: 105/255, alpha: 1.0)
        ])
        currY -= 22
        
        let items: [(String, String, String)] = [
            ("✓ AML § 14-6", "Ansettelsesavtaler oppdatert", "8 av 8 avtaler revidert med lovpålagte vilkår for arbeidstid & oppsigelse"),
            ("✓ AML § 6-1", "Verneombud lovpålagt valg", "Digitalt verneombudsvalg gjennomført og protokollfart"),
            ("✓ AML § 3-5", "HMS-opplæring for daglig leder", "Påmeldt Simployer Learn akkreditert lederkurs"),
            ("✓ AML kap. 10", "Arbeidstid og døgnhvile", "Kontinuerlig overvåket mot timeregistrering uten avvik"),
            ("✓ Likestillingsloven § 26", "Lønnskartlegging (ARP)", "Lønnsanalyse gjennomført uten usaklige kjønnsforskjeller"),
            ("✓ AML kap. 2 A", "Varslingsrutiner og kanal", "Kryptert og uavhengig varslingskanal aktiv for alle ansatte"),
            ("✓ Ferieloven", "Feriepenger og opptjening", "Lønnsgrunnlag kontinuerlig synkronisert mot gjeldende satser")
        ]
        
        for item in items {
            let rowRect = CGRect(x: 50, y: currY - 4, width: 495, height: 24)
            context.setFillColor(CGColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0))
            let rPath = CGPath(roundedRect: rowRect, cornerWidth: 4, cornerHeight: 4, transform: nil)
            context.addPath(rPath)
            context.fillPath()
            
            (item.0 as NSString).draw(at: CGPoint(x: 60, y: currY + 3), withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 9.0),
                .foregroundColor: NSColor(red: 25/255, green: 120/255, blue: 50/255, alpha: 1.0)
            ])
            (item.1 as NSString).draw(at: CGPoint(x: 185, y: currY + 3), withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 9.0),
                .foregroundColor: NSColor(white: 0.15, alpha: 1.0)
            ])
            (item.2 as NSString).draw(at: CGPoint(x: 330, y: currY + 3), withAttributes: [
                .font: NSFont.systemFont(ofSize: 8.5),
                .foregroundColor: NSColor(white: 0.45, alpha: 1.0)
            ])
            currY -= 28
        }
        
        currY -= 12
        
        // Legal Air Cover Box
        let boxRect = CGRect(x: 50, y: currY - 48, width: 495, height: 56)
        context.setFillColor(CGColor(red: 243/255, green: 240/255, blue: 252/255, alpha: 1.0))
        let bPath = CGPath(roundedRect: boxRect, cornerWidth: 6, cornerHeight: 6, transform: nil)
        context.addPath(bPath)
        context.fillPath()
        
        ("JURIDISK AIR COVER & REVISJONSGARANTI" as NSString).draw(at: CGPoint(x: 64, y: currY - 3), withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 8.5),
            .foregroundColor: NSColor(red: 45/255, green: 12/255, blue: 105/255, alpha: 1.0)
        ])
        
        let guaranteeText = "Dette beviset bekrefter at selskapets HR-dokumenter og rutiner er revidert mot gjeldende lovkrav. Simployer Expert garanterer juridisk holdbarhet for anvendte maler og redline-klausuler ved eventuelt tilsyn fra Arbeidstilsynet eller tvist." as NSString
        guaranteeText.draw(in: CGRect(x: 64, y: currY - 42, width: 467, height: 35), withAttributes: [
            .font: NSFont.systemFont(ofSize: 8.0),
            .foregroundColor: NSColor(white: 0.25, alpha: 1.0)
        ])
        
        context.endPDFPage()
        context.closePDF()
        
        self.auditReportSavedToast = target.path
        return target
    }
    #endif
}
