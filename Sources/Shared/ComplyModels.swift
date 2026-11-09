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
        self.lastUpdated = lastUpdated
        self.sender = sender
        self.language = language
        self.selectedTimelineTier = selectedTimelineTier
        self.slackTestToastActive = slackTestToastActive
    }
}
