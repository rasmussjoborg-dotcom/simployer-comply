import Foundation

public enum CompanyYear: String, CaseIterable, Identifiable, Sendable {
    case y2024 = "2024"
    case y2025 = "2025"
    case y2027 = "2027"
    
    public var id: String { rawValue }
    
    public var label: String {
        switch self {
        case .y2024: return "2024 · År 1"
        case .y2025: return "2025 · År 2"
        case .y2027: return "2027 · År 4"
        }
    }
    
    public var staffCount: String {
        switch self {
        case .y2024: return "8 ansatte"
        case .y2025: return "38 ansatte"
        case .y2027: return "124 ansatte"
        }
    }
    
    public var stageTitle: String {
        switch self {
        case .y2024: return "Oppstart & 5-VO pålegg"
        case .y2025: return "Vekst & Likestilling"
        case .y2027: return "Etablert & Jurist"
        }
    }
}

public enum ContractStatus: String, CaseIterable, Sendable {
    case ok = "ok"
    case aml14Gap = "aml14_gap"
    case probationSoon = "probation_soon"
    case sickD14 = "sick_d14"
}

public struct Employee: Identifiable, Sendable {
    public let id: String
    public var name: String
    public var role: String
    public var department: String
    public var salary: Int
    public var type: String
    public var startDate: String
    public var contractVersion: String
    public var status: ContractStatus
    public var statusLabel: String
    public var overtimeExempt: Bool
    
    public init(
        id: String,
        name: String,
        role: String,
        department: String,
        salary: Int,
        type: String,
        startDate: String,
        contractVersion: String,
        status: ContractStatus,
        statusLabel: String,
        overtimeExempt: Bool
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.department = department
        self.salary = salary
        self.type = type
        self.startDate = startDate
        self.contractVersion = contractVersion
        self.status = status
        self.statusLabel = statusLabel
        self.overtimeExempt = overtimeExempt
    }
}

public struct StatutoryTrigger: Sendable {
    public let title: String
    public let statute: String
    public let description: String
    public let consequence: String
    public let actionLabel: String
}

public struct RecommendedUpsell: Sendable {
    public let product: String
    public let title: String
    public let price: String
    public let benefit: String
}

public struct YearScenarioData: Sendable {
    public let year: CompanyYear
    public let stageName: String
    public let tagline: String
    public let headcount: Int
    public let revenue: String
    public let hrOwner: String
    public let systemOfRecord: String
    public let primaryRisk: String
    public let activeTrigger: StatutoryTrigger
    public let recommendedUpsell: RecommendedUpsell
    public var employees: [Employee]
}

public struct SyncPayload: Codable, Sendable {
    public var year: String
    public var activeNav: String
    public var approvedEmployeeIds: [String]
    public var verneombudElectionActive: Bool
    public var electionVotesCast: Int
    public var hmsTrainingEnrolled: Bool?
    public var lastUpdated: Double
    public var sender: String
    public var language: String
    public var selectedTimelineTier: Int?
    public var slackTestToastActive: Bool?
    
    public init(
        year: String,
        activeNav: String,
        approvedEmployeeIds: [String],
        verneombudElectionActive: Bool,
        electionVotesCast: Int,
        hmsTrainingEnrolled: Bool? = nil,
        lastUpdated: Double,
        sender: String,
        language: String = "no",
        selectedTimelineTier: Int? = nil,
        slackTestToastActive: Bool? = nil
    ) {
        self.year = year
        self.activeNav = activeNav
        self.approvedEmployeeIds = approvedEmployeeIds
        self.verneombudElectionActive = verneombudElectionActive
        self.electionVotesCast = electionVotesCast
        self.hmsTrainingEnrolled = hmsTrainingEnrolled
        self.lastUpdated = lastUpdated
        self.sender = sender
        self.language = language
        self.selectedTimelineTier = selectedTimelineTier
        self.slackTestToastActive = slackTestToastActive
    }
}

// MARK: - Agent Activity Log & Compliance Timeline Models (REP-03 / Master Plan)
public enum AgentEventCategory: String, CaseIterable, Sendable {
    case sweep = "sweep"
    case definitions = "definitions"
    case ingestion = "ingestion"
    case guardrail = "guardrail"
    case signature = "signature"
    
    public var icon: String {
        switch self {
        case .sweep: return "shield.lefthalf.filled"
        case .definitions: return "arrow.triangle.2.circlepath"
        case .ingestion: return "doc.viewfinder"
        case .guardrail: return "checkmark.seal.fill"
        case .signature: return "signature"
        }
    }
}

public struct AgentEvent: Identifiable, Sendable {
    public let id: String
    public let timestampString: String
    public let category: AgentEventCategory
    public let title: String
    public let description: String
    public let statute: String?
    public let affectedEntity: String?
    public let statusBadge: String
    public let auditHash: String?
    public let isAutonomous: Bool
    
    public init(
        id: String = UUID().uuidString,
        timestampString: String,
        category: AgentEventCategory,
        title: String,
        description: String,
        statute: String? = nil,
        affectedEntity: String? = nil,
        statusBadge: String,
        auditHash: String? = nil,
        isAutonomous: Bool = true
    ) {
        self.id = id
        self.timestampString = timestampString
        self.category = category
        self.title = title
        self.description = description
        self.statute = statute
        self.affectedEntity = affectedEntity
        self.statusBadge = statusBadge
        self.auditHash = auditHash
        self.isAutonomous = isAutonomous
    }
}

// MARK: - Statutory Headcount Thresholds (RAD-01 .. RAD-05)
public struct HeadcountDuty: Identifiable, Sendable {
    public let id: String
    public let threshold: Int
    public let title: String
    public let statute: String
    public let description: String
    public let penaltyRisk: String
    public let actionLabel: String
    
    public init(
        id: String,
        threshold: Int,
        title: String,
        statute: String,
        description: String,
        penaltyRisk: String,
        actionLabel: String
    ) {
        self.id = id
        self.threshold = threshold
        self.title = title
        self.statute = statute
        self.description = description
        self.penaltyRisk = penaltyRisk
        self.actionLabel = actionLabel
    }
}

// MARK: - Inspection & Due Diligence Packs (REP-02)
public enum InspectionPackType: String, CaseIterable, Identifiable, Sendable {
    case laborAuthority = "labor_authority"
    case dueDiligence = "due_diligence"
    
    public var id: String { rawValue }
    
    public var titleSE: String {
        switch self {
        case .laborAuthority: return "Tillsynspaket · Arbetsmiljöverket"
        case .dueDiligence: return "Due Diligence-rapport · Investor & M&A"
        }
    }
    
    public var titleNO: String {
        switch self {
        case .laborAuthority: return "Tilsynspakke · Arbeidstilsynet"
        case .dueDiligence: return "Due Diligence-rapport · Investor & M&A"
        }
    }
}

