import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case no = "no"
    case se = "se"
    case en = "en"
    
    public var id: String { rawValue }
    
    public var flag: String {
        switch self {
        case .no: return "🇳🇴"
        case .se: return "🇸🇪"
        case .en: return "🇬🇧"
        }
    }
    
    public var displayName: String {
        switch self {
        case .no: return "Norsk"
        case .se: return "Svenska"
        case .en: return "English"
        }
    }
    
    public var code: String {
        switch self {
        case .no: return "NO"
        case .se: return "SE"
        case .en: return "EN"
        }
    }
}

public struct LocalizedNarrationStep: Sendable {
    public let title: String
    public let body: String
}

public struct LocalizedScenarioContent: Sendable {
    public let stageName: String
    public let tagline: String
    public let primaryRisk: String
    public let triggerTitle: String
    public let triggerStatute: String
    public let triggerDescription: String
    public let triggerConsequence: String
    public let triggerActionLabel: String
    public let upsellProduct: String
    public let upsellTitle: String
    public let upsellPrice: String
    public let upsellBenefit: String
}

public struct LocalizedStrings: Sendable {
    public let languageCode: String
    
    // Brand & Header
    public let slogan: String
    public let activeRadar: String
    public let autoplayStart: String
    public let autoplayStop: String
    public let chapterPrefix: String
    public let close: String
    public let done: String
    public let menuOpenControlRoom: String
    public let menuQuit: String
    public let menuStatusLabel: String
    
    // Growth Timeline
    public let year1Label: String
    public let year2Label: String
    public let year4Label: String
    public let staff8: String
    public let staff38: String
    public let staff124: String
    
    // Sidebar & Navigation
    public let overviewSection: String
    public let navHub: String
    public let navAgentLog: String
    public let complianceSection: String
    public let navIngest: String
    public let navRegister: String
    public let navContracts: String
    public let navHandbook: String
    public let navRadar: String
    public let navExpert: String
    public let navAuditPack: String
    public let oneReadyTitle: String
    public let oneReadySubtitle: String
    
    // Action Hub
    public let hubTitle: String
    public let hubPendingSubtitle: String
    public let hubAllCompliantTitle: String
    public let hubAllCompliantSubtitle: String
    public let hubResolveAllButton: String
    public let hubCompletedBadge: String
    public let hubCardContractsStatute: String
    public let hubCardContractsTitle: String
    public let hubCardContractsDesc: String
    public let hubCardContractsAction: String
    public let hubCardContractsResolved: String
    public let hubCardVoStatute: String
    public let hubCardVoTitle: String
    public let hubCardVoDesc: String
    public let hubCardVoAction: String
    public let hubCardVoResolved: String
    public let hubCardEqualPayStatute: String
    public let hubCardEqualPayTitle: String
    public let hubCardEqualPayDesc: String
    public let hubCardEqualPayAction: String
    public let hubCardEqualPayResolved: String
    public let hubCardSickStatute: String
    public let hubCardSickTitle: String
    public let hubCardSickDesc: String
    public let hubCardSickAction: String
    public let hubCardSickResolved: String
    public let hubCardDefenseStatute: String
    public let hubCardDefenseTitle: String
    public let hubCardDefenseDesc: String
    public let hubCardDefenseAction: String
    public let hubCardDefenseResolved: String
    public let hubInspectChanges: String
    public let hubOpenDetails: String
    public let hubAuditLiveStatus: String
    
    // Ingestion Drop Zone
    public let dropTitle: String
    public let dropSubtitle: String
    public let dropBoxTitle: String
    public let dropBoxSubtitle: String
    public let dropSimulateButton: String
    
    // Table Header
    public let colEmployee: String
    public let colRoleDept: String
    public let colSalary: String
    public let colStatus: String
    public let colAction: String
    public let startedPrefix: String
    public let inspectButton: String
    public let currencyUnit: String
    public let registerCountSuffix: String
    public let filterAll: String
    public let filterIssues: String
    public let filterCompliant: String
    public let searchEmployeePlaceholder: String
    
    // Upsell Banner
    public let upsellPrefix: String
    public let activateModule: String
    
    // Statuses
    public let statusCompliant: String
    public let statusIllegalOvertime: String
    public let statusMissingCompetence: String
    public let statusSickDay14: String
    public let statusProbationExpiring: String
    public let statusDismissalDefenseNeeded: String
    public let statusAmuProtocol: String
    public let statusHmsNeeded: String
    public let statusOk: String
    
    // Directory Calm UX Additions
    public let staffCountLabel: String
    public let directoryCompliantSummary: String
    public let directoryIssuesSummary: String
    public let statusCompliantShort: String
    public let statusUpdateContract: String
    public let statusMissingHmsShort: String
    public let statusCompetenceShort: String
    public let closeButton: String
    public let diffHmsMissingHeader: String
    public let diffHmsNotice: String
    
    // iOS Companion
    public let pushAlertHeader: String
    public let timeJustNow: String
    public let actionReadyHeader: String
    public let actionCardTitle: String
    public let actionCardSubtitle: String
    public let approveWithFaceId: String
    public let approvedFaceId: String
    public let approvedAuditLog: String
    public let consultJuristTitle: String
    public let consultJuristName: String
    public let penaltyOnPassivity: String
    
    // Verneombud Election Sheet
    public let voTitle: String
    public let voSubtitle: String
    public let voBoxTitle: String
    public let voBoxSubtitle: String
    public let voCandidatesHeader: String
    public let voVotesOf: String
    public let voVotesUnit: String
    public let voAwaitingVotes: String
    public let voSuccessTitle: String
    public let voSuccessSubtitle: String
    public let voFooter: String
    public let voSendBallots: String
    public let voSignBankId: String
    public let voCloseAndInspect: String
    
    // Upsell Modal
    public let upsellSheetTitlePrefix: String
    public let upsellPricePrefix: String
    public let upsellBenefitHeader: String
    public let upsellBullet1: String
    public let upsellBullet2: String
    public let upsellBullet3: String
    public let upsellActivatedMessage: String
    public let upsellMonthlyBilling: String
    public let upsellActivateNow: String
    
    // Sick Leave Sheet (AML § 4-6)
    public let sickTitle: String
    public let sickSubtitle: String
    public let sickDeadlinesHeader: String
    public let sickMilestone1Title: String
    public let sickMilestone1Sub: String
    public let sickMilestone2Title: String
    public let sickMilestone2Sub: String
    public let sickMilestone3Title: String
    public let sickMilestone3Sub: String
    public let sickDocsHeader: String
    public let sickDocsBody: String
    public let sickSuccessNotice: String
    public let sickSanctionNotice: String
    public let sickSendInvite: String
    
    // Dismissal Defense Sheet (AML § 15-1)
    public let defenseTitle: String
    public let defenseSubtitle: String
    public let defenseRiskHeader: String
    public let defenseRiskBody: String
    public let defenseChecklistHeader: String
    public let defenseCheck1: String
    public let defenseCheck2: String
    public let defenseCheck3: String
    public let defenseExpertDeskTitle: String
    public let defenseExpertDeskDesc: String
    public let defenseSuccessNotice: String
    public let defenseFooter: String
    public let defenseHandoffButton: String
    
    // Equal Pay Modal (ARP § 26)
    public let equalPayTitle: String
    public let equalPayBoxHeader: String
    public let equalPayBoxDesc: String
    public let equalPayCat1: String
    public let equalPayCat2: String
    public let equalPayCat3: String
    public let equalPayRatio1: String
    public let equalPayRatio2: String
    public let equalPayRatio3: String
    public let equalPayStatusOkVariance: String
    public let equalPayStatusOk: String
    public let equalPayStatusAlert: String
    public let equalPaySuccessNotice: String
    public let equalPayFooter: String
    public let equalPayGenerateButton: String
    
    // Contract Redline Diff Sheet
    public let diffTitlePrefix: String
    public let diffSubtitle: String
    public let diffCurrentLabel: String
    public let diffCurrentClause: String
    public let diffCurrentWarning: String
    public let diffCompliantLabel: String
    public let diffCompliantClause: String
    public let diffCompliantFootnote: String
    public let diffAuditNotice: String
    public let diffApproveButton: String
    public let diffApprovedBadge: String
    
    // Demo & Presenter Controls (Hidden scaffolding)
    public let demoPillLabel: String
    public let demoControllerTitle: String
    public let demoControllerSubtitle: String
    public let demoInternalBadge: String
    public let demoTimelineHeader: String
    public let demoAutoplayHeader: String
    public let demoAutoplayDesc: String
    public let demoResetButton: String
    public let demoSyncActive: String
    public let searchPlaceholder: String
    
    // Nov 8 Joint Features
    public let expertSiaTitle: String
    public let expertSiaSubtitle: String
    public let feriepengerTab: String
    public let sykefravaerTab: String
    public let egenmeldingTab: String
    public let askJuristButton: String
    public let uploadRosterButton: String
    public let rosterUploadedBanner: String
    public let aiHandbookChapterTitle: String
    public let aiHandbookSummary: String
    
    // Ingestion & Cloud Sources
    public let ingestSourcesTitle: String
    public let ingestSourcesSubtitle: String
    public let ingestHeroTitle: String
    public let ingestHeroSubtitle: String
    public let ingestBrowseButton: String
    public let ingestSimulateButton: String
    public let monitoredSourcesHeader: String
    public let activeSuffix: String
    public let addFolderButton: String
    public let connectedBadge: String
    public let guardingBadge: String
    public let downloadsFolderDesc: String
    public let documentsFolderDesc: String
    public let connectMoreLabel: String
    public let filesSyncedSuffix: String
    public let reassuranceTitle: String
    public let reassuranceBreakdown: String
    public let reassuranceButton: String
    public let cloudSourcesHeader: String
    public let localFoldersHeader: String
    public let documentMapHeader: String
    public let connectButton: String
    public let scanNowButton: String
    
    // Global Header & Filters
    public let noEmployeesMatchFilter: String
    public let resetFilterButton: String
    
    // Action Hub Extra Cards (HMS & Probation)
    public let hubCardHmsStatute: String
    public let hubCardHmsTitle: String
    public let hubCardHmsDesc: String
    public let hubCardHmsAction: String
    public let hubCardHmsResolved: String
    public let hubCardProbationStatute: String
    public let hubCardProbationTitle: String
    public let hubCardProbationDesc: String
    public let hubCardProbationAction: String
    public let hubCardProbationResolved: String
    
    // Handbook & Radar & Expert Details
    public let handbookAiUpdateNotice: String
    public let handbookApprovedAiToolsHeader: String
    public let radarAutomatedWatchNotice: String
    public let expertPrecisionNotice: String
    public let expertAnnualSalaryHeader: String
    public let expertTimelineHeader: String
    public let expertFolketrygdNotice: String
    public let expertSelfCertNotice: String
    public let expertSelfCertRulesBody: String
    public let expertLegalCounselHeader: String
    public let expertLegalCounselDesc: String
    
    // Inline Diff Drawers
    public let diffGapHeader: String
    public let diffGapSubline: String
    public let diffStatuteBadge: String
    public let diffCompliantHeader: String
    public let diffSickHeader: String
    public let diffDismissalHeader: String
    public let diffDismissalNotice: String
    public let diffCompliantNotice: String
    
    // Handbook Chapters
    public let handbookCh1Title: String
    public let handbookCh1Statute: String
    public let handbookCh1Status: String
    public let handbookCh1Summary: String
    public let handbookCh2Title: String
    public let handbookCh2Statute: String
    public let handbookCh2Status: String
    public let handbookCh2Summary: String
    public let handbookCh3Title: String
    public let handbookCh3Statute: String
    public let handbookCh3Status: String
    public let handbookCh3Summary: String
    public let handbookCh4Title: String
    public let handbookCh4Statute: String
    public let handbookCh4Status: String
    public let handbookCh4Summary: String
    public let handbookCh5Status: String
    public let aiChipTextStatus: String
    public let aiChipDataStatus: String
    public let aiChipCodeStatus: String
    
    // Radar Cards
    public let radarActiveStatus: String
    public let radarCard5Threshold: String
    public let radarCard5Title: String
    public let radarCard5Status: String
    public let radarCard5Desc: String
    public let radarCard10Threshold: String
    public let radarCard10Title: String
    public let radarCard10Desc: String
    public let radarCard50Threshold: String
    public let radarCard50Title: String
    public let radarCard50Status: String
    public let radarCard50Desc: String
    
    // Expert Sia & Counsel Details
    public let expertRetainerBadge: String
    public let expertAnnualSalaryCalcHeader: String
    public let expertFifthWeekToggle: String
    public let expertCalcResultHeader: String
    public let expertCalcRateHeader: String
    public let expertCalcRateStandard: String
    public let expertCalcRateExtended: String
    public let expertSickTimelineHeader: String
    public let expertSickTimelineStatute: String
    public let expertSickTimelineActiveCase: String
    public let expertSickMilestone1Time: String
    public let expertSickMilestone1Title: String
    public let expertSickMilestone1Desc: String
    public let expertSickMilestone1Remaining: String
    public let expertSickMilestone2Time: String
    public let expertSickMilestone2Title: String
    public let expertSickMilestone2Desc: String
    public let expertSickMilestone2Remaining: String
    public let expertSelfCertRulesHeader: String
    public let expertSelfCertStatute: String
    public let expertSelfCertAllApprovedBadge: String
    public let expertInquirySent: String
    public let expertPastCaseTitle: String
    public let expertPastCaseDesc: String
    public let expertPastCaseClosed: String
    
    // Command Palette Sections
    public let paletteSectionNav: String
    public let paletteSectionActions: String
    public let paletteSectionEmployees: String
    public let paletteSectionYears: String
    
    // Autoplay Narration Steps (0-6)
    public let narrationSteps: [LocalizedNarrationStep]
    
    // Scenario data per year
    public let scenarios: [CompanyYear: LocalizedScenarioContent]
    
    public func hubContractsTitle(unapprovedCount: Int) -> String {
        switch languageCode {
        case "se":
            return unapprovedCount == 1 ? "1 anställningsavtal saknar lagstadgade klausuler" : "\(unapprovedCount) anställningsavtal saknar lagstadgade klausuler"
        case "en":
            return unapprovedCount == 1 ? "1 employment contract lacks statutory clauses" : "\(unapprovedCount) employment contracts lack statutory clauses"
        default:
            return unapprovedCount == 1 ? "1 arbeidsavtale mangler lovpålagte klausuler" : "\(unapprovedCount) arbeidsavtaler mangler lovpålagte klausuler"
        }
    }
    
    public func hubContractsAction(unapprovedCount: Int) -> String {
        switch languageCode {
        case "se":
            return "Godkänn alla (\(unapprovedCount))"
        case "en":
            return "Approve all (\(unapprovedCount))"
        default:
            return "Godkjenn alle (\(unapprovedCount))"
        }
    }
    
    public func hubAttentionTitle(count: Int) -> String {
        switch languageCode {
        case "se":
            return count == 1 ? "1 avvikelse kräver åtgärd" : "\(count) avvikelser kräver åtgärd"
        case "en":
            return count == 1 ? "1 item requires action" : "\(count) items require action"
        default:
            return count == 1 ? "1 avvik krever godkjenning" : "\(count) avvik krever godkjenning"
        }
    }
    
    public func hubAttentionSubtitle(count: Int) -> String {
        switch languageCode {
        case "se":
            return count == 1 ? "1 uppgift kräver åtgärd." : "\(count) uppgifter kräver åtgärd."
        case "en":
            return count == 1 ? "1 item requires attention." : "\(count) items require attention."
        default:
            return count == 1 ? "1 oppgave krever handling." : "\(count) oppgaver krever handling."
        }
    }
    
    // MARK: - Executive Cockpit Hub Helpers
    public func hubExecutiveStatusTitle(securedCount: Int, totalCount: Int, percent: Int) -> String {
        switch languageCode {
        case "se":
            return "\(securedCount) av \(totalCount) lagkrav säkrade (\(percent) %)"
        case "en":
            return "\(securedCount) of \(totalCount) statutory requirements met (\(percent)%)"
        default:
            return "\(securedCount) av \(totalCount) lovkrav oppfylt (\(percent) %)"
        }
    }
    
    public func hubExecutiveStatusSubtitle(pendingCount: Int) -> String {
        switch languageCode {
        case "se":
            return pendingCount == 0
                ? "Kontinuerlig regelefterlevnad aktiv · 3 anslutna system övervakas"
                : (pendingCount == 1 
                    ? "1 punkt kräver beslut · Uppskattad tid: ca 45 sekunder"
                    : "\(pendingCount) punkter kräver vd-beslut · Uppskattad tid: ca 2 minuter")
        case "en":
            return pendingCount == 0
                ? "Continuous statutory compliance radar active · 3 connected sources monitored"
                : (pendingCount == 1
                    ? "1 item requires decision · Estimated time: ~45 seconds"
                    : "\(pendingCount) items require executive decision · Estimated time: ~2 minutes")
        default:
            return pendingCount == 0
                ? "Kontinuerlig regeletterlevelse aktiv · 3 tilknyttede systemer overvåkes"
                : (pendingCount == 1
                    ? "1 punkt krever beslutning · Estimert tidsbruk: ca. 45 sekunder"
                    : "\(pendingCount) punkter krever daglig leder-beslutning · Estimert tidsbruk: ca. 2 minutter")
        }
    }

    public var hubSectionPendingTitle: String {
        switch languageCode {
        case "se": return "Kräver ditt godkännande"
        case "en": return "Requires your approval"
        default: return "Krever din godkjenning"
        }
    }

    public var hubSectionSecuredTitle: String {
        switch languageCode {
        case "se": return "Säkrat & bevakas i bakgrunden"
        case "en": return "Secured & monitored in background"
        default: return "Sikret & overvåkes i bakgrunnen"
        }
    }

    public var hubSecuredBadge: String {
        switch languageCode {
        case "se": return "4 aktiva skydd"
        case "en": return "4 active protections"
        default: return "4 aktive vern"
        }
    }

    public var hubEst45Sec: String {
        switch languageCode {
        case "se": return "Ca 45 sek"
        case "en": return "~45 sec"
        default: return "Ca. 45 sek"
        }
    }

    public var hubEst1Min: String {
        switch languageCode {
        case "se": return "Ca 1 min"
        case "en": return "~1 min"
        default: return "Ca. 1 min"
        }
    }

    public var hubEstCourse: String {
        switch languageCode {
        case "se": return "Självstudier (ca 2 tim)"
        case "en": return "Self-paced (~2 hrs)"
        default: return "Selvstudium (ca. 2 timer)"
        }
    }

    public var hubRiskBadgeContracts: String {
        switch languageCode {
        case "se": return "Lagändring 1 juli 2024"
        case "en": return "July 2024 Amendment"
        default: return "Lovendring 1. juli 2024"
        }
    }

    public var hubRiskBadgeVo: String {
        switch languageCode {
        case "se": return "Obligatoriskt val"
        case "en": return "Statutory Election"
        default: return "Lovpålagt valg"
        }
    }

    public var hubRiskBadgeHms: String {
        switch languageCode {
        case "se": return "Personligt vd-ansvar"
        case "en": return "Executive Mandate"
        default: return "Personlig lederansvar"
        }
    }

    public var hubExposureContracts: String {
        switch languageCode {
        case "se": return "Risk: Formfel vid tvist · Sanktionsavgift upp till 50 000 SEK (LAS/AML)"
        case "en": return "Exposure: Defective clause in dispute · Statutory fines up to €5,000"
        default: return "Risiko: Formfeil ved tvist · Overtredelsesgebyr opp til kr 50 000"
        }
    }

    public var hubExposureVo: String {
        switch languageCode {
        case "se": return "Risk: Skyddsstopp och pålägg vid tillsyn från Arbetsmiljöverket"
        case "en": return "Exposure: Mandatory operational stop order upon labor inspection"
        default: return "Risiko: Arbeidstilsynet kan stanse driften ved tilsyn (AML § 18-6)"
        }
    }

    public var hubExposureHms: String {
        switch languageCode {
        case "se": return "Ansvar: Personligt straffansvar och företagsbot för VD vid olycka"
        case "en": return "Liability: Personal criminal liability and company fines for CEO"
        default: return "Ansvar: Personlig straffansvar og foretaksstraff for daglig leder"
        }
    }

    public var ingestDropAnalyzing: String {
        switch languageCode {
        case "se": return "Analyserar inlästa avtal mot gällande lagstiftning..."
        case "en": return "Analyzing imported contracts against labor laws..."
        default: return "Analyserer innleste avtaler mot gjeldende lovverk..."
        }
    }

    public var ingestDropStage1: String {
        switch languageCode {
        case "se": return "Läser in dokument och identifierar personalgrupp..."
        case "en": return "Ingesting documents and identifying employee group..."
        default: return "Leser inn dokumenter og identifiserer ansattgruppe..."
        }
    }

    public var ingestDropStage2: String {
        switch languageCode {
        case "se": return "Matchar klausuler mot Arbetsmiljölagen § 14-6..."
        case "en": return "Matching clauses against Working Environment Act § 14-6..."
        default: return "Matcher klausuler mot Arbeidsmiljøloven § 14-6..."
        }
    }

    public var ingestDropStage3: String {
        switch languageCode {
        case "se": return "Identifierade 7 saknade klausuler · Skapar redline-ändringar..."
        case "en": return "Identified 7 missing clauses · Generating redline proposals..."
        default: return "Identifiserte 7 manglende klausuler · Genererer endringsforslag..."
        }
    }

    public var ingestDropSuccess: String {
        switch languageCode {
        case "se": return "Analys slutförd! 2 avvikelser kräver vd-beslut"
        case "en": return "Analysis complete! 2 actions require executive sign-off"
        default: return "Analyse fullført! 2 avvik krever lederbeslutning"
        }
    }

    public var ingestDropGoToHub: String {
        switch languageCode {
        case "se": return "Granska och signera i Åtgärder"
        case "en": return "Review and sign in Action Hub"
        default: return "Gjennomgå og signer i Handlinger"
        }
    }

    public var auditCertificateButton: String {
        switch languageCode {
        case "se": return "Revisionsrapport (PDF)"
        case "en": return "Audit Certificate (PDF)"
        default: return "Tilsynsbevis (PDF)"
        }
    }

    public var auditCertificateTitle: String {
        switch languageCode {
        case "se": return "Officiellt Tilsynsbevis & Revisionsrapport"
        case "en": return "Official Compliance Certificate & Audit Log"
        default: return "Offisielt Tilsynsbevis & Revisjonsrapport"
        }
    }

    public var auditCertificateSubtitle: String {
        switch languageCode {
        case "se": return "Utfärdad av Simployer Legal Engine · Juridisk air cover för Fjord Dynamics AS"
        case "en": return "Issued by Simployer Legal Engine · Certified legal air cover for Fjord Dynamics AS"
        default: return "Utstedt av Simployer Legal Engine · Juridisk air cover for Fjord Dynamics AS"
        }
    }

    public var auditSavePdfAction: String {
        switch languageCode {
        case "se": return "Spara PDF till Hämtade filer (~/Downloads)"
        case "en": return "Save PDF to Downloads (~/Downloads)"
        default: return "Lagre PDF til Nedlastinger (~/Downloads)"
        }
    }

    public var auditSavedToast: String {
        switch languageCode {
        case "se": return "Revisionsrapport sparad i Hämtade filer!"
        case "en": return "Audit certificate saved to Downloads!"
        default: return "Tilsynsbevis lagret i Nedlastinger!"
        }
    }

    public var auditLegalAirCoverText: String {
        switch languageCode {
        case "se": return "Detta certifikat intygar att bolagets HR-processer och anställningsavtal granskats mot gällande arbetsmiljö- och arbetsrättslig lagstiftning. Simployer Expert garanterar juridisk giltighet för tillämpade regelmallar."
        case "en": return "This certificate verifies that the company's HR processes and employment agreements have been audited against statutory labor law. Simployer Expert certifies the legal validity of approved templates."
        default: return "Dette beviset bekrefter at selskapets HR-prosesser og ansettelsesavtaler er revidert mot gjeldende arbeidsmiljølovgivning. Simployer Expert garanterer juridisk gyldighet for godkjente regelmaler."
        }
    }

    // MARK: - Headless Integrations & Settings
    public var navSettings: String {
        switch languageCode {
        case "se": return "Inställningar"
        case "en": return "Settings"
        default: return "Innstillinger"
        }
    }

    public var settingsTitle: String {
        switch languageCode {
        case "se": return "Inställningar & Anslutna System"
        case "en": return "Settings & Connected Systems"
        default: return "Innstillinger & Tilkoblede Systemer"
        }
    }

    public var settingsSubtitle: String {
        switch languageCode {
        case "se": return "Comply arbetar i bakgrunden. Styr hur händelser och godkännanden skickas till Slack, Teams och Fortnox."
        case "en": return "Comply operates in the background. Manage how alerts and approvals dispatch to Slack, Teams, and HR systems."
        default: return "Comply arbeider i bakgrunnen. Styr hvordan hendelser og godkjenninger sendes til Slack, Teams og HR-systemer."
        }
    }

    public var settingsSectionIntegrations: String {
        switch languageCode {
        case "se": return "SAMARBETSVERKTYG & HEADLESS NOTIFIERINGAR"
        case "en": return "COLLABORATION TOOLS & HEADLESS DISPATCH"
        default: return "SAMARBEIDSVERKTØY & HEADLESS VARSLER"
        }
    }

    public var settingsSlackTitle: String {
        switch languageCode {
        case "se": return "Slack Workspace: Fjord Dynamics"
        case "en": return "Slack Workspace: Fjord Dynamics"
        default: return "Slack Workspace: Fjord Dynamics"
        }
    }

    public var settingsSlackChannel: String {
        switch languageCode {
        case "se": return "Kanal: #ledningsgrupp-compliance"
        case "en": return "Channel: #management-compliance"
        default: return "Kanal: #ledergruppe-compliance"
        }
    }

    public var settingsSlackTestButton: String {
        switch languageCode {
        case "se": return "Skicka testnotis till Slack"
        case "en": return "Send test alert to Slack"
        default: return "Send testvarsel til Slack"
        }
    }

    public var settingsSlackTestToast: String {
        switch languageCode {
        case "se": return "Testnotis levererad till #ledningsgrupp-compliance i Slack!"
        case "en": return "Test alert delivered to #management-compliance in Slack!"
        default: return "Testvarsel levert til #ledergruppe-compliance i Slack!"
        }
    }

    public var settingsTeamsTitle: String {
        switch languageCode {
        case "se": return "Microsoft Teams: Ledningskanalen"
        case "en": return "Microsoft Teams: Executive Team"
        default: return "Microsoft Teams: Lederkanalen"
        }
    }

    public var settingsTeamsWebhook: String {
        switch languageCode {
        case "se": return "Webhook ansluten · Adaptive Cards med BankID-knapp aktiverat"
        case "en": return "Webhook connected · Adaptive Cards with BankID action enabled"
        default: return "Webhook tilkoblet · Adaptive Cards med BankID-handling aktivert"
        }
    }

    public var settingsEmailTitle: String {
        switch languageCode {
        case "se": return "E-postrapportering till VD"
        case "en": return "Executive Email Digest"
        default: return "E-postrapportering til daglig leder"
        }
    }

    public var settingsEmailDesc: String {
        switch languageCode {
        case "se": return "jonas.berg@fjorddynamics.no · Månadssammanfattning och akuta lagkrav"
        case "en": return "jonas.berg@fjorddynamics.no · Monthly summary and urgent statutory changes"
        default: return "jonas.berg@fjorddynamics.no · Månedsoppsummering og akutte lovendringer"
        }
    }

    public var settingsSectionSystems: String {
        switch languageCode {
        case "se": return "AFFÄRS- OCH LÖNESYSTEM (SYSTEM OF RECORD)"
        case "en": return "BUSINESS & PAYROLL (SYSTEM OF RECORD)"
        default: return "FORRETNINGS- OG LØNNSSYSTEMER (SYSTEM OF RECORD)"
        }
    }

    public var settingsFortnoxTitle: String {
        switch languageCode {
        case "se": return "Fortnox Lön & Personal"
        case "en": return "Fortnox Payroll & HR"
        default: return "Fortnox Lønn & Personal"
        }
    }

    public var settingsFortnoxSyncStatus: String {
        switch languageCode {
        case "se": return "8 anställda synkroniserade · Live API-telemetri aktiv"
        case "en": return "8 employees synchronized · Live API telemetry active"
        default: return "8 ansatte synkronisert · Live API-telemetri aktiv"
        }
    }

    public var settingsSectionSecurity: String {
        switch languageCode {
        case "se": return "SÄKERHET & SIGNERINGSBEHÖRIGHET"
        case "en": return "SECURITY & SIGNING DELEGATION"
        default: return "SIKKERHET & SIGNERINGSFULLMAKT"
        }
    }

    public var settingsBankIdDesc: String {
        switch languageCode {
        case "se": return "Jonas Berg (VD) har full signeringsrätt med BankID för alla avtalsändringar och val."
        case "en": return "Jonas Berg (CEO) holds full signing authority with BankID for contract and ballot mutations."
        default: return "Jonas Berg (Daglig leder) har full signeringsfullmakt med BankID for alle avtaleendringer og valg."
        }
    }

    // MARK: - Bolagsresan / Growth Timeline
    public var timelineTrackHeader: String {
        switch languageCode {
        case "se": return "Bolagsresan · Lagstadgade trösklar vid tillväxt"
        case "en": return "Company Journey · Statutory Growth Thresholds"
        default: return "Selskapsreisen · Lovpålagte terskler ved vekst"
        }
    }

    public var timelineTrackSubheader: String {
        switch languageCode {
        case "se": return "Lagkraven förändras radikalt beroende på antal anställda. Se vad som gäller nu och vad som träder i kraft vid nästa rekrytering."
        case "en": return "Statutory obligations transform as your headcount grows. Review your current baseline and upcoming triggers."
        default: return "Lovkravene endres radikalt basert på antall ansatte. Se hva som gjelder nå og hva som utløses ved neste ansettelse."
        }
    }

    public var hubScopeContracts: String {
        switch languageCode {
        case "se": return "Berör: 6 anställda med standardavtal"
        case "en": return "Affects: 6 staff with standard contracts"
        default: return "Berører: 6 ansatte med standardavtaler"
        }
    }

    public var hubScopeVo: String {
        switch languageCode {
        case "se": return "Valberättigade: 8 anställda · Digital valsedel färdig"
        case "en": return "Eligible voters: 8 staff · Digital ballot ready"
        default: return "Stemmeberettigede: 8 ansatte · Digital stemmeseddel klar"
        }
    }

    public var hubScopeHms: String {
        switch languageCode {
        case "se": return "Certifierad webbkurs via Simployer Learn"
        case "en": return "Certified online course via Simployer Learn"
        default: return "Sertifisert nettkurs via Simployer Learn"
        }
    }

    // HMS Course Booking & Commercial Details
    public var hubHmsPrice: String {
        switch languageCode {
        case "se": return "3 900 SEK"
        case "en": return "€390"
        default: return "3 900 NOK"
        }
    }

    public var hubHmsParticipant: String {
        switch languageCode {
        case "se": return "Deltagare: Jonas Berg (VD)"
        case "en": return "Participant: Jonas Berg (CEO)"
        default: return "Deltaker: Jonas Berg (Daglig leder)"
        }
    }

    public var hubHmsBillingTerms: String {
        switch languageCode {
        case "se": return "Företagsfaktura · Simployer Learn"
        case "en": return "Company Invoice · Simployer Learn"
        default: return "Bedriftsfaktura · Simployer Learn"
        }
    }

    public var hubHmsBookAction: String {
        switch languageCode {
        case "se": return "Boka utbildning (3 900 SEK)"
        case "en": return "Book Course (€390)"
        default: return "Bestill kurs (3 900 NOK)"
        }
    }

    public var hubHmsCurriculumButton: String {
        switch languageCode {
        case "se": return "Kursplan & intyg"
        case "en": return "Curriculum & certificate"
        default: return "Kursplan & kursbevis"
        }
    }

    public var hubHmsBookedConfirmation: String {
        switch languageCode {
        case "se": return "Kursplats bokad för Jonas Berg · Faktureras 3 900 SEK"
        case "en": return "Course booked for Jonas Berg · Billed €390"
        default: return "Kursplass bestilt for Jonas Berg · Faktureres 3 900 NOK"
        }
    }

    public var hubHmsCurriculumHeader: String {
        switch languageCode {
        case "se": return "KURSINNEHÅLL · GODKÄND HMS-UTBILDNING FÖR CHEFER"
        case "en": return "COURSE SYLLABUS · ACCREDITED EHS TRAINING FOR EXECUTIVES"
        default: return "KURSINNHOLD · GODKJENT HMS-OPPLÆRING FOR LEDERE"
        }
    }

    public var hubHmsModule1: String {
        switch languageCode {
        case "se": return "Modul 1: Arbetsmiljöansvar & regelverk (AML § 3-5, AFS)"
        case "en": return "Module 1: Statutory EHS liability & frameworks (WEA § 3-5)"
        default: return "Modul 1: Arbeidsmiljøansvar & lovkrav (AML § 3-5)"
        }
    }

    public var hubHmsModule2: String {
        switch languageCode {
        case "se": return "Modul 2: Systematiskt arbetsmiljöarbete (SAM) & riskbedömning"
        case "en": return "Module 2: Systematic safety management & risk audits"
        default: return "Modul 2: Systematisk HMS-arbeid & risikovurdering"
        }
    }

    public var hubHmsModule3: String {
        switch languageCode {
        case "se": return "Modul 3: Samverkan med skyddsombud och medarbetare"
        case "en": return "Module 3: Cooperation with safety reps and staff"
        default: return "Modul 3: Samarbeid med verneombud og tillitsvalgte"
        }
    }

    public var hubHmsModule4: String {
        switch languageCode {
        case "se": return "Modul 4: Psykosocial och organisatorisk arbetsmiljö"
        case "en": return "Module 4: Psychosocial & organizational workplace health"
        default: return "Modul 4: Psykososialt og organisatorisk arbeidsmiljø"
        }
    }

    public var hubHmsDeliveryNotice: String {
        switch languageCode {
        case "se": return "Direktåtkomst via Simployer Learn · Kursintyg arkiveras automatiskt för Arbetsmiljöverket"
        case "en": return "Instant access via Simployer Learn · Certificate automatically archived for labor authorities"
        default: return "Direktetilgang via Simployer Learn · Kursbevis arkiveres automatisk for Arbeidstilsynet"
        }
    }

    public var hubHmsConfirmOrderAction: String {
        switch languageCode {
        case "se": return "Bekräfta köp & boka kursplats (3 900 SEK)"
        case "en": return "Confirm Purchase & Book Seat (€390)"
        default: return "Bekreft kjøp & bestill kursplass (3 900 NOK)"
        }
    }

    public var hubMacroResolveButton: String {
        switch languageCode {
        case "se": return "Åtgärda allt"
        case "en": return "Resolve all"
        default: return "Løs alt"
        }
    }

    // Baselines guardrails
    public var hubGuardrail1Title: String {
        switch languageCode {
        case "se": return "Arbetstidsregler & dygnsvila"
        case "en": return "Working hours & mandatory rest"
        default: return "Arbeidstidsregler & døgnhvile"
        }
    }
    public var hubGuardrail1Statute: String {
        switch languageCode {
        case "se": return "AML kap. 10"
        case "en": return "WEA ch. 10"
        default: return "AML kap. 10"
        }
    }
    public var hubGuardrail1Desc: String {
        switch languageCode {
        case "se": return "Inga avvikelser i stämplingar eller övertidsgränser senaste 30 dagarna."
        case "en": return "Zero violations in time logs or overtime limits over past 30 days."
        default: return "Ingen avvik i stemplinger eller overtidsgrenser siste 30 dager."
        }
    }
    public var hubGuardrail1Status: String {
        switch languageCode {
        case "se": return "Aktiv bevakning"
        case "en": return "Active monitoring"
        default: return "Aktiv overvåking"
        }
    }

    public var hubGuardrail2Title: String {
        switch languageCode {
        case "se": return "Lönekartläggning & jämställdhet"
        case "en": return "Equal pay & gender pay gap audit"
        default: return "Lønnskartlegging & likestilling"
        }
    }
    public var hubGuardrail2Statute: String {
        switch languageCode {
        case "se": return "Likestillingsloven § 26"
        case "en": return "Equality Act § 26"
        default: return "Likestillingsloven § 26"
        }
    }
    public var hubGuardrail2Desc: String {
        switch languageCode {
        case "se": return "Löneanalys genomförd utan osakliga löneskillnader mellan könen."
        case "en": return "Payroll audit complete with zero unadjusted gender wage gaps."
        default: return "Lønnsanalyse gjennomført uten usaklige lønnsforskjeller."
        }
    }
    public var hubGuardrail2Status: String {
        switch languageCode {
        case "se": return "Uppfyllt"
        case "en": return "Compliant"
        default: return "Oppfylt"
        }
    }

    public var hubGuardrail3Title: String {
        switch languageCode {
        case "se": return "Rutiner för visselblåsning"
        case "en": return "Whistleblower protection framework"
        default: return "Varslingsrutiner"
        }
    }
    public var hubGuardrail3Statute: String {
        switch languageCode {
        case "se": return "AML kap. 2 A"
        case "en": return "WEA ch. 2 A"
        default: return "AML kap. 2 A"
        }
    }
    public var hubGuardrail3Desc: String {
        switch languageCode {
        case "se": return "Krypterad och oberoende rapporteringskanal upprättad för personalen."
        case "en": return "Encrypted and independent reporting channel active for staff."
        default: return "Kryptert og uavhengig varslingskanal etablert for ansatte."
        }
    }
    public var hubGuardrail3Status: String {
        switch languageCode {
        case "se": return "Säkrat"
        case "en": return "Secured"
        default: return "Sikret"
        }
    }

    public var hubGuardrail4Title: String {
        switch languageCode {
        case "se": return "Semesterersättning & intjänande"
        case "en": return "Holiday pay & vacation entitlement"
        default: return "Feriepenger & opptjening"
        }
    }
    public var hubGuardrail4Statute: String {
        switch languageCode {
        case "se": return "Feriereglerna"
        case "en": return "Holiday Act"
        default: return "Ferieloven"
        }
    }
    public var hubGuardrail4Desc: String {
        switch languageCode {
        case "se": return "Löneunderlag och intjänad semester synkroniseras automatiskt mot Fortnox."
        case "en": return "Payroll data continuously reconciled against statutory accrual rates."
        default: return "Lønnsunderlag synkroniseres automatisk mot gjeldende prosentsatser."
        }
    }
    public var hubGuardrail4Status: String {
        switch languageCode {
        case "se": return "Synkroniserad"
        case "en": return "Reconciled"
        default: return "Synkronisert"
        }
    }
    
    public func headerIssuesCount(count: Int) -> String {
        switch languageCode {
        case "se":
            return count == 1 ? "1 avvikelse" : "\(count) avvikelser"
        case "en":
            return count == 1 ? "1 issue" : "\(count) issues"
        default:
            return count == 1 ? "1 avvik" : "\(count) avvik"
        }
    }
    
    public func radarNextThresholdNotice(remainingCount: Int) -> String {
        switch languageCode {
        case "se":
            return remainingCount <= 0 ? "Tröskel uppnådd." : "Nästa lagstadgade tröskel infaller vid 10 anställda (\(remainingCount) anställda kvar)."
        case "en":
            return remainingCount <= 0 ? "Threshold reached." : "Next statutory threshold occurs at 10 employees (\(remainingCount) employees to go)."
        default:
            return remainingCount <= 0 ? "Terskel nådd." : "Neste juridiske terskel inntreffer ved 10 ansatte (\(remainingCount) ansatte gjenstår)."
        }
    }
    
    public func radarHeadcountNotice(count: Int) -> String {
        switch languageCode {
        case "se":
            return "Fjord Dynamics: \(count) anställda"
        case "en":
            return "Fjord Dynamics: \(count) employees"
        default:
            return "Fjord Dynamics: \(count) ansatte"
        }
    }
    
    public func radarCard10Status(remaining: Int) -> String {
        switch languageCode {
        case "se":
            return "Nästa tröskel (\(remaining) anställda kvar)"
        case "en":
            return "Next threshold (\(remaining) employees to go)"
        default:
            return "Neste terskel (\(remaining) ansatte gjenstår)"
        }
    }
    
    public func diffSickNotice(name: String) -> String {
        switch languageCode {
        case "se":
            return "Lagstadgad uppföljningsplan för \(name) inom dag 14 enl. Försäkringskassan / AML § 4-6."
        case "en":
            return "Statutory follow-up plan for \(name) within day 14 pursuant to National Insurance Act § 8-4."
        default:
            return "Statutisk oppfølgingsplan for \(name) innen dag 14 jf. Folketrygdloven § 8-4."
        }
    }
    
    public func localizedRole(_ role: String) -> String {
        switch languageCode {
        case "se":
            switch role {
            case "Daglig leder & Gründer": return "VD & Grundare"
            case "CEO & Co-founder": return "VD & Medgrundare"
            case "Kontorleder & Koordinator": return "Kontorschef & Koordinator"
            case "Tech Lead & Arkitekt": return "Teknisk Ledare & Arkitekt"
            case "Senior UX Designer": return "Senior UX-designer"
            case "Frontend-utvikler": return "Frontend-utvecklare"
            case "Backend-utvikler": return "Backend-utvecklare"
            case "Juniorutvikler": return "Juniorutvecklare"
            case "Hovedverneombud (Valgt)": return "Huvudskyddsombud (Vald)"
            case "Principal Cloud Engineer": return "Principal Cloud Engineer"
            case "Salgssjef B2B": return "Försäljningschef B2B"
            case "Head of People & Culture": return "Head of People & Culture"
            case "VP People & Culture": return "VP People & Culture"
            case "VP of Engineering": return "VP of Engineering"
            case "Regionsjef Vest (Bergen)": return "Regionchef Väst (Bergen)"
            case "Seniorkonsulent Cloud": return "Seniorkonsult Cloud"
            default: return role
            }
        case "en":
            switch role {
            case "Daglig leder & Gründer": return "CEO & Founder"
            case "CEO & Co-founder": return "CEO & Co-founder"
            case "Kontorleder & Koordinator": return "Office Manager & Coordinator"
            case "Tech Lead & Arkitekt": return "Tech Lead & Architect"
            case "Senior UX Designer": return "Senior UX Designer"
            case "Frontend-utvikler": return "Frontend Developer"
            case "Backend-utvikler": return "Backend Developer"
            case "Juniorutvikler": return "Junior Developer"
            case "Hovedverneombud (Valgt)": return "Chief Safety Representative (Elected)"
            case "Principal Cloud Engineer": return "Principal Cloud Engineer"
            case "Salgssjef B2B": return "Head of Sales B2B"
            case "Head of People & Culture": return "Head of People & Culture"
            case "VP People & Culture": return "VP People & Culture"
            case "VP of Engineering": return "VP of Engineering"
            case "Regionsjef Vest (Bergen)": return "Regional Director West (Bergen)"
            case "Seniorkonsulent Cloud": return "Senior Cloud Consultant"
            default: return role
            }
        default:
            return role
        }
    }
    
    public func localizedDepartment(_ dept: String) -> String {
        switch languageCode {
        case "se":
            switch dept {
            case "Ledelse": return "Ledning"
            case "Utvikling": return "Utveckling"
            case "Design": return "Design"
            case "Admin": return "Admin"
            case "HMS": return "Arbetsmiljö"
            case "People": return "People & HR"
            case "Salg": return "Försäljning"
            case "Konsulent": return "Konsult"
            case "Drift": return "Drift / Ops"
            default: return dept
            }
        case "en":
            switch dept {
            case "Ledelse": return "Leadership"
            case "Utvikling": return "Engineering"
            case "Design": return "Design"
            case "Admin": return "Administration"
            case "HMS": return "EHS / Safety"
            case "People": return "People & HR"
            case "Salg": return "Sales"
            case "Konsulent": return "Consulting"
            case "Drift": return "Operations"
            default: return dept
            }
        default:
            return dept
        }
    }
}

public enum L10n {
    public static func strings(for lang: AppLanguage) -> LocalizedStrings {
        switch lang {
        case .no:
            return LocalizedStrings(
                languageCode: "no",
                slogan: "Alltid i tråd med loven. Uten å lese den.",
                activeRadar: "Aktiv Radar",
                autoplayStart: "Autoplay Demo",
                autoplayStop: "Stopp",
                chapterPrefix: "Kapittel",
                close: "Lukk",
                done: "Fullfør",
                menuOpenControlRoom: "Åpne Comply Kontrollrom",
                menuQuit: "Avslutt",
                menuStatusLabel: "Status: Alltid i tråd med loven",
                year1Label: "2024 · År 1",
                year2Label: "2025 · År 2",
                year4Label: "2027 · År 4",
                staff8: "8 ansatte",
                staff38: "38 ansatte",
                staff124: "124 ansatte",
                overviewSection: "Virksomhet & Overvåking",
                navHub: "Oversikt",
                navAgentLog: "Beskyttelseslogg",
                complianceSection: "Lov, Revisjon & Jurist",
                navIngest: "Overvåkede kilder",
                navRegister: "Personal & Avtaler",
                navContracts: "Arbeidsavtaler",
                navHandbook: "Personalhåndbok",
                navRadar: "Lovradar & trinn",
                navExpert: "Simployer Jurist",
                navAuditPack: "Revisjonspakke",
                oneReadyTitle: "Simployer One Ready",
                oneReadySubtitle: "Data oppdateres strukturert i bakgrunnen uten migreringsbehov.",
                hubTitle: "Handlingssenter",
                hubPendingSubtitle: "lovpålagte avvik krever godkjenning for full etterlevelse",
                hubAllCompliantTitle: "Alt er i tråd med loven",
                hubAllCompliantSubtitle: "Fjord Dynamics etterlever alle gjeldende regler. Ingen utestående pålegg.",
                hubResolveAllButton: "Løs alle",
                hubCompletedBadge: "Fullført",
                hubCardContractsStatute: "AML § 14-6",
                hubCardContractsTitle: "7 arbeidsavtaler mangler lovpålagte klausuler",
                hubCardContractsDesc: "Standardavtalene mangler lovpålagte vilkår for arbeidstid og overtid.",
                hubCardContractsAction: "Godkjenn alle (7)",
                hubCardContractsResolved: "7 avtaler oppdatert og signert",
                hubCardVoStatute: "AML § 6-1",
                hubCardVoTitle: "Obligatorisk verneombud må velges",
                hubCardVoDesc: "Fjord Dynamics har 8 ansatte og må velge verneombud.",
                hubCardVoAction: "Start valg",
                hubCardVoResolved: "Verneombudsvalg gjennomført",
                hubCardEqualPayStatute: "Likestillingsloven § 26",
                hubCardEqualPayTitle: "Obligatorisk lønnskartlegging",
                hubCardEqualPayDesc: "Fjord Dynamics har 38 ansatte og må kartlegge lønnsforskjeller.",
                hubCardEqualPayAction: "Generer rapport",
                hubCardEqualPayResolved: "Lønnskartlegging godkjent",
                hubCardSickStatute: "AML § 4-6",
                hubCardSickTitle: "Lovpålagt oppfølgingsplan for Sofia Berg",
                hubCardSickDesc: "Sofia Berg har nådd 14 dagers sykefravær. Oppfølgingsplan kreves innen 4 uker.",
                hubCardSickAction: "Send innkalling",
                hubCardSickResolved: "Møteinnkalling utsendt",
                hubCardDefenseStatute: "AML § 15-1",
                hubCardDefenseTitle: "Sak FJD-35: Formkrav før oppsigelse",
                hubCardDefenseDesc: "Saksbehandlingen må kvalitetssikres før drøftelsesmøte.",
                hubCardDefenseAction: "Koble på jurist",
                hubCardDefenseResolved: "Overført til jurist",
                hubInspectChanges: "Forhåndsvis",
                hubOpenDetails: "Detaljer",
                hubAuditLiveStatus: "0 aktive avvik · Automatisert tilsynsradar aktiv",
                dropTitle: "Få full dokumentkontroll på 30 sekunder",
                dropSubtitle: "Dra inn mappen med gamle ansettelseskontrakter fra Macen eller koble til Google Drive.",
                dropBoxTitle: "Dra og slipp mapper eller filer her",
                dropBoxSubtitle: "Støtter PDF-avtaler, Word-dokumenter og Tripletex CSV",
                dropSimulateButton: "Simuler fullført import (8 ansatte)",
                colEmployee: "ANSATT",
                colRoleDept: "STILLING & AVDELING",
                colSalary: "ANSETTELSE & FORM",
                colStatus: "AVTALSSTATUS",
                colAction: "HANDLING",
                startedPrefix: "Startet",
                inspectButton: "Gransk",
                currencyUnit: "kr",
                registerCountSuffix: "ansatte i personalregisteret",
                filterAll: "Alle",
                filterIssues: "Avvik",
                filterCompliant: "I orden",
                searchEmployeePlaceholder: "Søk etter ansatt eller rolle...",
                upsellPrefix: "Anbefalt utvidelse",
                activateModule: "Aktiver modul",
                statusCompliant: "Lovlig (AML § 14-6 BankID signert)",
                statusIllegalOvertime: "Ulovlig overtidsklausul (§ 14-6)",
                statusMissingCompetence: "Mangler kompetansebestemmelse (§ 14-6)",
                statusSickDay14: "Sykmeldt dag 14 (Dialogmøte kreves)",
                statusProbationExpiring: "Prøvetid utgår om 21 dager",
                statusDismissalDefenseNeeded: "Varsel: Krever AML § 15-1 bistand",
                statusAmuProtocol: "AMU-protokoll publisert",
                statusHmsNeeded: "Mangler HMS-kurs (AML § 3-5)",
                statusOk: "I orden (HMS godkjent)",
                staffCountLabel: "ansatte",
                directoryCompliantSummary: "i orden",
                directoryIssuesSummary: "krever oppdatering",
                statusCompliantShort: "I orden · BankID",
                statusUpdateContract: "Avtale må oppdateres",
                statusMissingHmsShort: "Mangler HMS-kurs",
                statusCompetenceShort: "Mangler kompetansekrav",
                closeButton: "Lukk",
                diffHmsMissingHeader: "Avvik: Mangler lovpålagt HMS-kurs (AML § 3-5)",
                diffHmsNotice: "Som daglig leder plikter Jonas Berg å gjennomføre opplæring i helse-, miljø- og sikkerhetsarbeid. Intet godkjent kursbevis er registrert i Comply.",
                pushAlertHeader: "LOVVARSEL (NÅ)",
                timeJustNow: "Nettopp",
                actionReadyHeader: "Handling klar til godkjenning",
                actionCardTitle: "Utsendelse av AML § 14-6 tillegg",
                actionCardSubtitle: "Genererer automatisk BankID-signeringslenke for alle berørte ansatte.",
                approveWithFaceId: "Godkjenn med FaceID",
                approvedFaceId: "Godkjent med FaceID",
                approvedAuditLog: "Utsendt via BankID · Revisjonslogg oppdatert",
                consultJuristTitle: "Rådfør med Simployer Jurist",
                consultJuristName: "Ragnhild Hansen, Fagansvarlig Arbeidsrett",
                penaltyOnPassivity: "Pålegg ved passivitet",
                voTitle: "Lovpålagt Verneombud",
                voSubtitle: "Terskelen for påbudt verneombud ble senket fra 10 til 5 ansatte (1. jan 2024).",
                voBoxTitle: "Automatisert digital valggjennomføring",
                voBoxSubtitle: "Simployer Comply genererer nøytrale digitale stemmesedler til alle 8 ansatte og oppretter lovpålagt valgprotokoll for oppbevaring i HMS-permen.",
                voCandidatesHeader: "KANDIDATER NOMINERT AV DE ANSATTE",
                voVotesOf: "av",
                voVotesUnit: "stemmer",
                voAwaitingVotes: "Venter på stemmer",
                voSuccessTitle: "Valg fullført: Sofie Hagen er registrert som verneombud",
                voSuccessSubtitle: "Protokoll arkivert · Neste steg: 40-timers lovpålagt verneombudskurs (Simployer Learn)",
                voFooter: "AML § 6-1, 1. ledd krever skriftlig valgprotokoll",
                voSendBallots: "Send digitale stemmesedler til alle 8",
                voSignBankId: "Signer valgprotokoll med BankID",
                voCloseAndInspect: "Lukk og se oppdatert register",
                upsellSheetTitlePrefix: "Utvidelse: ",
                upsellPricePrefix: "Pris: ",
                upsellBenefitHeader: "KOMMERSIELL FORDELSMODELL",
                upsellBullet1: "Null manuell migrasjon: eksisterende personalliste synkes direkte",
                upsellBullet2: "Juridisk godkjent etter norske standarder (AML / Diskrimineringsnemnda)",
                upsellBullet3: "Ubegrenset tilgang til Simployer rådgivernettverk ved tvil",
                upsellActivatedMessage: "Modul aktivert! Synkroniserer med Fjord Dynamics AS...",
                upsellMonthlyBilling: "Faktureres månedlig · Ingen bindingstid",
                upsellActivateNow: "Aktiver modul nå",
                sickTitle: "Sykefraværsoppfølging: Morten Dahl (Dag 14)",
                sickSubtitle: "Lovpålagt oppfølgingsplan skal utarbeides i samarbeid med arbeidstaker innen 4 uker.",
                sickDeadlinesHeader: "STATUS OG LOVPÅLAGTE FRISTER",
                sickMilestone1Title: "Dag 14 (NÅ)",
                sickMilestone1Sub: "Første kontakt & kartlegging",
                sickMilestone2Title: "Uke 4",
                sickMilestone2Sub: "Oppfølgingsplan til NAV",
                sickMilestone3Title: "Uke 7",
                sickMilestone3Sub: "Dialogmøte 1",
                sickDocsHeader: "FORSLAG TIL DOKUMENTER (SIMPLOYER MAL)",
                sickDocsBody: "• Forhåndsutfylt oppfølgingsplan med tilretteleggingsforslag for Cloud-konsulenter.\n• Nøytral møteinnkalling med referanse til folketrygdloven § 8-4.",
                sickSuccessNotice: "Innkalling og plan sendt til Morten Dahl · Notert i personallogg",
                sickSanctionNotice: "Sanksjon ved mislighold: Tap av sykepengerefusjon fra NAV",
                sickSendInvite: "Send innkalling til dialogmøte",
                defenseTitle: "Formfeilsikring: Drøftelsesmøte før oppsigelse",
                defenseSubtitle: "Gjelder: Sak om manglende leveranse v/ Lars Viken (Regionsjef Vest)",
                defenseRiskHeader: "🚨 KRITISK RISIKO FOR ERSTATNINGSKRAV",
                defenseRiskBody: "Norske domstoler underkjenner oppsigelser automatisk dersom § 15-1 drøftelse ikke er korrekt dokumentert. Median erstatningsbeløp ved ugyldig oppsigelse er 396 000 kr pluss saksomkostninger (ca. 250 000 kr).",
                defenseChecklistHeader: "OBLIGATORISKE FORMALIA",
                defenseCheck1: "Skriftlig innkalling sendt med rimelig frist (anbefalt min. 3 dager)",
                defenseCheck2: "Arbeidstaker informert om rett til å bistås av tillitsvalgt",
                defenseCheck3: "Protokoll fra drøftelsesmøte skal undertegnes av begge parter",
                defenseExpertDeskTitle: "Simployer Juridisk Desk",
                defenseExpertDeskDesc: "Ragnhild Hansen, Senior Arbeidsrettsjurist. Saksmappen overleveres kryptert for umiddelbar kvalitetssikring.",
                defenseSuccessNotice: "Saksmappe overlevert til Ragnhild Hansen. Juridisk notat foreligger innen 2 timer.",
                defenseFooter: "Simployer Expert garanterer juridisk ansvarsdekning",
                defenseHandoffButton: "Overfør sak til Simployer Jurist nå",
                equalPayTitle: "Lovpålagt Lønnskartlegging (Fjord Dynamics 2025)",
                equalPayBoxHeader: "Aktivitets- og redegjørelsesplikten (ARP)",
                equalPayBoxDesc: "Med 38 ansatte må Fjord Dynamics annethvert år kartlegge lønnsforskjeller fordelt på kjønn og stillingskategori. Kartleggingen hentes direkte fra Tripletex Lønn.",
                equalPayCat1: "Utvikling & Ingeniører (16 ansatte)",
                equalPayCat2: "Produkt & Design (8 ansatte)",
                equalPayCat3: "Salg & Kommersielt (10 ansatte)",
                equalPayRatio1: "97.4 % av menns lønn",
                equalPayRatio2: "102.1 % av menns lønn",
                equalPayRatio3: "91.2 % av menns lønn",
                equalPayStatusOkVariance: "Godkjent (< 5 % avvik)",
                equalPayStatusOk: "Godkjent",
                equalPayStatusAlert: "Avvik: Krever redegjørelse",
                equalPaySuccessNotice: "Lovpålagt ARP-rapport generert og eksportert til årsberetningen!",
                equalPayFooter: "Kilde: Tripletex Lønn integrasjon · Likestillingsloven § 26",
                equalPayGenerateButton: "Generer lovpålagt ARP-rapport",
                diffTitlePrefix: "",
                diffSubtitle: "",
                diffCurrentLabel: "Gjeldende avtale",
                diffCurrentClause: "§ 6. ARBEIDSTID OG OVERTID\nDen alminnelige arbeidstid er 37,5 timer per uke.\n\n❌ 'Overtidskompensasjon anses inkludert i fast månedslønn.'",
                diffCurrentWarning: "",
                diffCompliantLabel: "Oppdatert avtale",
                diffCompliantClause: "§ 6. ARBEIDSTID OG OVERTID (OPPDATERT)\n\n🟢 'Ved pålagt overtid utbetales minimum 40 % overtidstillegg iht. arbeidsmiljøloven § 10-6 (11).'\n\n§ 11. Rett til kompetanseutvikling dekkes av arbeidsgiver.",
                diffCompliantFootnote: "",
                diffAuditNotice: "",
                diffApproveButton: "Godkjenn & signer",
                diffApprovedBadge: "Utsendt via BankID!",
                demoPillLabel: "Demo",
                demoControllerTitle: "Demo Kontroller",
                demoControllerSubtitle: "",
                demoInternalBadge: "Demo",
                demoTimelineHeader: "TIDSHÅPP",
                demoAutoplayHeader: "AUTOPLAY",
                demoAutoplayDesc: "",
                demoResetButton: "Tilbakestill",
                demoSyncActive: "iOS-synk aktiv",
                searchPlaceholder: "Søk eller hopp til... (⌘K)",
                expertSiaTitle: "Sia Juridisk & Lønns-kalkulator",
                expertSiaSubtitle: "Øyeblikkelige juridiske beregninger iht. norsk lov og Simployer-praksis",
                feriepengerTab: "Feriepenger",
                sykefravaerTab: "Sykefravær",
                egenmeldingTab: "Egenmelding",
                askJuristButton: "Spør jurist",
                uploadRosterButton: "Last opp ansattliste (CSV)",
                rosterUploadedBanner: "8 ansatte importert fra personalliste.csv · NACE 62.01",
                aiHandbookChapterTitle: "Bruk av Kunstig Intelligens (AI) på Arbeidsplassen",
                aiHandbookSummary: "Retningslinjer for ansattes bruk av generative AI-verktøy (ChatGPT, Claude, Copilot). Sikring av forretningshemmeligheter og GDPR.",
                ingestSourcesTitle: "Kilder & Dokumentovervåking",
                ingestSourcesSubtitle: "Comply samler og overvåker dokumenter automatisk fra tilkoblede skylagre og lokale mapper.",
                ingestHeroTitle: "Slipp ansettelsesavtaler eller mapper her",
                ingestHeroSubtitle: "PDF, Word (.docx) eller Tripletex / Fiken CSV",
                ingestBrowseButton: "Velg fra Mac...",
                ingestSimulateButton: "Simuler import (8 ansatte)",
                monitoredSourcesHeader: "Overvåkede kilder",
                activeSuffix: "aktive",
                addFolderButton: "Legg til mappe...",
                connectedBadge: "Tilkoblet",
                guardingBadge: "Aktiv vakt",
                downloadsFolderDesc: "Fanger automatisk opp nedlastede kontrakter",
                documentsFolderDesc: "Lokal arkivmappe for ansettelser",
                connectMoreLabel: "Koble til:",
                filesSyncedSuffix: "filer synkronisert",
                reassuranceTitle: "21 dokumenter er analysert og beskyttet",
                reassuranceBreakdown: "8 ansettelsesavtaler · 1 personalhåndbok · 8 lønnsposter fra Tripletex",
                reassuranceButton: "Gå til Handlinger (2)",
                cloudSourcesHeader: "SKYLAGRE & SAMHANDLING",
                localFoldersHeader: "OVERVÅKEDE LOKALE MAPPER PÅ MACEN",
                documentMapHeader: "STRUKTURERT DOKUMENTOVERSIKT",
                connectButton: "Koble til",
                scanNowButton: "Skann kilder nå",
                noEmployeesMatchFilter: "Ingen ansatte matcher søket",
                resetFilterButton: "Nullstill filter",
                hubCardHmsStatute: "AML § 3-5",
                hubCardHmsTitle: "HMS-kurs for daglig leder",
                hubCardHmsDesc: "Daglig leder plikter å gjennomføre opplæring i helse-, miljø- og sikkerhetsarbeid.",
                hubCardHmsAction: "Start kurs (Simployer Learn)",
                hubCardHmsResolved: "Daglig leder er påmeldt godkjent HMS-kurs.",
                hubCardProbationStatute: "AML § 15-6 · Prøvetid",
                hubCardProbationTitle: "Prøvetid utløper for 2 nyansatte om 18 dager",
                hubCardProbationDesc: "Evaluering og oppfølgingssamtale må gjennomføres innen 6 måneder for å opprettholde lovlig ansettelsesvern.",
                hubCardProbationAction: "Bekreft evaluering",
                hubCardProbationResolved: "Prøvetidsevalueringer registrert fullført. Fast ansettelse bekreftet.",
                handbookAiUpdateNotice: "Automatisert oppdatering iht. endringer i AML 2024 & EU AI Act · Simployer Fagredaksjon",
                handbookApprovedAiToolsHeader: "GODKJENTE GENERATIVE AI-VERKTØY I VIRKSOMHETEN",
                radarAutomatedWatchNotice: "Automatisert overvåking av juridiske terskler basert på selskapets vekst",
                expertPrecisionNotice: "Automatisert presisjonsberegning basert på gjeldende norsk lov og tariff",
                expertAnnualSalaryHeader: "ÅRSLØNN FOR BEREGNING",
                expertTimelineHeader: "LOVPÅLAGT TIDSLINJE FOR SYKEFRAVÆR",
                expertFolketrygdNotice: "Folketrygdloven § 8-7 & Arbeidsmiljøloven § 4-6",
                expertSelfCertNotice: "Folketrygdloven § 8-24 · Opptjeningstid: 2 måneder",
                expertSelfCertRulesBody: "En arbeidstaker har rett til å benytte egenmelding i inntil 3 sammenhengende kalenderdager per fraværstilfelle, med opptil 4 fraværstilfeller i løpet av en 12-måneders periode. Ved overskridelse kreves legemeldt sykmelding for å bevare rett til sykepenger i arbeidsgiverperioden (16 dager).",
                expertLegalCounselHeader: "Rådgivning fra Arbeidsrettsjurist",
                expertLegalCounselDesc: "Simployers jurister bistår ved drøftelsesmøter, oppsigelser og omstillinger",
                diffGapHeader: "Avtalen mangler lovkrav fra 1. juli 2024",
                diffGapSubline: "Vilkår for overtidskompensasjon og rett til opplæring må spesifiseres skriftlig.",
                diffStatuteBadge: "AML § 14-6",
                diffCompliantHeader: "Avtalen er i tråd med loven",
                diffSickHeader: "Sykemelding Dag 14: Lovpålagt oppfølgingsplan",
                diffDismissalHeader: "Stillingsvern og oppsigelsesgrunnlag",
                diffDismissalNotice: "AML § 15-1 saksbehandlingsregler må etterleves før drøftelsesmøte.",
                diffCompliantNotice: "Alle ansettelsesvilkår og klausuler er i henhold til gjeldende lovverk.",
                handbookCh1Title: "Arbeidsavtaler & Midlertidige Ansettelser",
                handbookCh1Statute: "AML § 14-6 & § 14-9",
                handbookCh1Status: "Lovrevidert 1. juli 2024",
                handbookCh1Summary: "Krav til skriftlige avtaler innen 7 dager, presisering av arbeidstid, og forbud mot generelle overtidsklausuler.",
                handbookCh2Title: "Verneombud & HMS-organisering",
                handbookCh2Statute: "AML § 6-1",
                handbookCh2Status: "Påbudt fra 5 ansatte (1. jan 2024)",
                handbookCh2Summary: "Obligatorisk hemmelig valg av verneombud for alle virksomheter med 5 eller flere ansatte. Valgprotokoll arkiveres i HMS-permen.",
                handbookCh3Title: "Arbeidstid, Overtid & Kompensasjon",
                handbookCh3Statute: "AML § 10-6",
                handbookCh3Status: "Minimum 40 % overtidstillegg",
                handbookCh3Summary: "Lovfestet rett til overtidsbetaling. Kompensasjon kan ikke bakes inn i fast månedslønn for ordinære stillinger.",
                handbookCh4Title: "Varsling & Psykososialt Arbeidsmiljø",
                handbookCh4Statute: "AML § 2 A-1 til § 2 A-3",
                handbookCh4Status: "Varslingskanal etablert",
                handbookCh4Summary: "Lovfestet varslingsrutine for kritikkverdige forhold, objektiv undersøkelsesplikt og forbud mot gjengjeldelse.",
                handbookCh5Status: "Aktiv retningslinje · 8/8 bekreftet",
                aiChipTextStatus: "Godkjent tekstutkast",
                aiChipDataStatus: "Godkjent dataanalyse",
                aiChipCodeStatus: "Godkjent kildekode",
                radarActiveStatus: "Radar Aktiv",
                radarCard5Threshold: "5 ansatte",
                radarCard5Title: "Obligatorisk verneombud",
                radarCard5Status: "Utløst (8 ansatte)",
                radarCard5Desc: "Terskel senket fra 10 til 5 ansatte. Lovunntak gjelder ikke lenger. Valg må gjennomføres med protokoll.",
                radarCard10Threshold: "10 ansatte",
                radarCard10Title: "Arbeidsmiljøutvalg (AMU) & Verneombudsavtale",
                radarCard10Desc: "Partene kan avtale annen ordning dersom under 10 ansatte. Ved passering av 10 ansatte kreves AMU dersom en part krever det.",
                radarCard50Threshold: "50 ansatte",
                radarCard50Title: "Drøftelsesplikt & Årlig Likestillingsredegjørelse",
                radarCard50Status: "Fremtidig vekstterskel",
                radarCard50Desc: "Lovpålagt regelmessig drøfting med tillitsvalgte og årlig lønnsgap-analyse for kjønnslikestilling (ARP).",
                expertRetainerBadge: "Retainer Aktiv · 5 000 000 kr dekning",
                expertAnnualSalaryCalcHeader: "ÅRSLØNN FOR BEREGNING",
                expertFifthWeekToggle: "5. avtalefestet ferieuke (12.0 %)",
                expertCalcResultHeader: "BEREGNET FERIEPENGER",
                expertCalcRateHeader: "SATS",
                expertCalcRateStandard: "10,2 % (Ferieloven § 10)",
                expertCalcRateExtended: "12,0 % (Tariff / Avtale)",
                expertSickTimelineHeader: "LOVPÅLAGT TIDSLINJE FOR SYKEFRAVÆR",
                expertSickTimelineStatute: "Folketrygdloven § 8-7 & Arbeidsmiljøloven § 4-6",
                expertSickTimelineActiveCase: "Aktiv sak: Magnus Teig (14 dager)",
                expertSickMilestone1Time: "Uke 4 (Dag 28)",
                expertSickMilestone1Title: "Oppfølgingsplan",
                expertSickMilestone1Desc: "Skal utarbeides i samråd med ansatt og sendes sykmelder.",
                expertSickMilestone1Remaining: "14 dager gjenstår",
                expertSickMilestone2Time: "Uke 7 (Dag 49)",
                expertSickMilestone2Title: "Dialogmøte 1",
                expertSickMilestone2Desc: "Obligatorisk møte med leder, ansatt og bedriftshelsetjeneste.",
                expertSickMilestone2Remaining: "35 dager til frist",
                expertSelfCertRulesHeader: "EGENMELDING & KARANTENEREGLER",
                expertSelfCertStatute: "Folketrygdloven § 8-24 · Opptjeningstid: 2 måneder",
                expertSelfCertAllApprovedBadge: "Alle 8 ansatte godkjent",
                expertInquirySent: "Henvendelse sendt",
                expertPastCaseTitle: "Sak #JUR-2024-89 · AML § 14-6 Avtalerevisjon",
                expertPastCaseDesc: "Kvalitetssikret tilleggsavtale for 7 ansatte. BankID-signatur forankret i juridisk revisjonslogg.",
                expertPastCaseClosed: "Lukket & Arkivert",
                paletteSectionNav: "NAVIGASJON",
                paletteSectionActions: "LOVER & HANDLINGER",
                paletteSectionEmployees: "ANSATTE",
                paletteSectionYears: "TIDSHOPP (SCENARIO)",
                narrationSteps: [
                    LocalizedNarrationStep(
                        title: "Kapittel 1: Oppstart & Filslipp (2024 · 8 ansatte)",
                        body: "Fjord Dynamics lagrer kontrakter i mapper på Macen. Comply rydder opp på 30 sekunder via direkte dra-og-slipp."
                    ),
                    LocalizedNarrationStep(
                        title: "Automatisert avviksanalyse (AML § 14-6)",
                        body: "Comply oppdager at 7 av 8 kontrakter har ulovlige overtidsklausuler iht. nye lovkrav fra 1. juli 2024."
                    ),
                    LocalizedNarrationStep(
                        title: "Lovpålagt Verneombud (AML § 6-1)",
                        body: "Terskelen ble senket fra 10 til 5 ansatte. Comply gjennomfører nøytralt digitalt valg og oppretter protokoll."
                    ),
                    LocalizedNarrationStep(
                        title: "Kapittel 2: Skalering & Lønnskartlegging (2025 · 38 ansatte)",
                        body: "Ved 20+ ansatte krever likestillingsloven § 26 en 2-årlig ARP-analyse. Comply analyserer Tripletex-data automatisk."
                    ),
                    LocalizedNarrationStep(
                        title: "Sykefravær dag 14: Forberedelse til Dialogmøte 1",
                        body: "Comply forhindrer tap av sykepengerefusjon ved å generere oppfølgingsplan for Morten Dahl."
                    ),
                    LocalizedNarrationStep(
                        title: "Kapittel 3: Etablert selskap (2027 · 124 ansatte)",
                        body: "Unngår 396 000 kr formfeil under oppsigelse (AML § 15-1). Handoff til Simployer Expert-advokat med ett klikk."
                    ),
                    LocalizedNarrationStep(
                        title: "Simployer Comply: Alltid i tråd med loven. Uten å lese den.",
                        body: "Proaktiv etterlevelse integrert rett i macOS-hverdagen. Ingen manuell overvåking, ingen juridiske overraskelser."
                    )
                ],
                scenarios: [
                    .y2024: LocalizedScenarioContent(
                        stageName: "The Seedling (Oppstart & Kaos)",
                        tagline: "8 ansatte · Google Drive-kaos · Daglig leder gjør alt",
                        primaryRisk: "Mangler verneombud (AML § 6-1 senket til 5) + 8 ulovlige avtaler (AML § 14-6)",
                        triggerTitle: "Lovpålagt Verneombud mangler",
                        triggerStatute: "AML § 6-1 (Krav fra 1. jan 2024)",
                        triggerDescription: "Kravet til verneombud ble senket fra 10 til 5 ansatte. Fjord Dynamics har 8 ansatte og intet verneombud.",
                        triggerConsequence: "Arbeidstilsynet gir pålegg om stans eller tvangsmulkt ved tilsyn.",
                        triggerActionLabel: "Start digitalt verneombudsvalg",
                        upsellProduct: "Simployer Learn",
                        upsellTitle: "Lovpålagt HMS-kurs for daglig leder + 40t Verneombudskurs",
                        upsellPrice: "1 490 kr per kurs",
                        upsellBenefit: "Sikrer godkjent kursbevis for oppbevaring i Comply."
                    ),
                    .y2025: LocalizedScenarioContent(
                        stageName: "The Scale-Up (Vekst & Terskelradar)",
                        tagline: "38 ansatte · Camilla ansatt som solo HR · Tripletex-synk",
                        primaryRisk: "Krav om likestillingsrapport (ARP § 26) + Sykefravær dag 14 (AML § 4-6)",
                        triggerTitle: "Lønnskartlegging (ARP) påkrevd ved 20+ ansatte",
                        triggerStatute: "Likestillings- og diskrimineringsloven § 26",
                        triggerDescription: "Med 38 ansatte plikter bedriften å kartlegge lønnsforskjeller mellom kvinner og menn i samme stillingskategori.",
                        triggerConsequence: "Rapporteringsbrudd i årsberetningen kan medføre tilsyn fra Diskrimineringsnemnda.",
                        triggerActionLabel: "Kjør automatisk lønnsgap-analyse",
                        upsellProduct: "Simployer Equal Pay + One Core",
                        upsellTitle: "Automatisk ARP-rapport & Fullt HRM-system",
                        upsellPrice: "79 kr / ansatt / mnd",
                        upsellBenefit: "Oppgraderer personalregisteret til full fraværs- og feriehåndtering uten manuell datamigrering."
                    ),
                    .y2027: LocalizedScenarioContent(
                        stageName: "The Established Force (Etablert & Jurist)",
                        tagline: "124 ansatte · Simployer One operativt · Lovpålagt Varslingskanal",
                        primaryRisk: "Desentraliserte linjeledere håndterer oppsigelser (Fare for 396k formfeil)",
                        triggerTitle: "Formfeil i oppsigelsessak (AML § 15-1)",
                        triggerStatute: "Arbeidsmiljøloven kapittel 15",
                        triggerDescription: "Avdelingsleder i Bergen ønsker å si opp en ansatt for manglende leveranse. Ingen drøftelsesmøte er avholdt.",
                        triggerConsequence: "Norske domstoler kjenner oppsigelser ugyldige ved formfeil (median tap 396 000 kr + 250 000 kr saksomkostninger).",
                        triggerActionLabel: "Aktiver Simployer Jurist før møte",
                        upsellProduct: "Simployer Expert Retainer",
                        upsellTitle: "Ubegrenset skriftlig advokatbistand & Ansvarsdekning",
                        upsellPrice: "3 990 kr / mnd",
                        upsellBenefit: "Sertifiserte arbeidsrettsjurister kvalitetssikrer drøftelser og oppsigelser med full ansvarsforsikring."
                    )
                ]
            )
            
        case .se:
            return LocalizedStrings(
                languageCode: "se",
                slogan: "Alltid i enlighet med lagen. Utan att läsa den.",
                activeRadar: "Aktiv Radar",
                autoplayStart: "Autoplay Demo",
                autoplayStop: "Stopp",
                chapterPrefix: "Kapitel",
                close: "Stäng",
                done: "Slutför",
                menuOpenControlRoom: "Öppna Comply Kontrollrum",
                menuQuit: "Avsluta",
                menuStatusLabel: "Status: Alltid i enlighet med lagen",
                year1Label: "2024 · År 1",
                year2Label: "2025 · År 2",
                year4Label: "2027 · År 4",
                staff8: "8 anställda",
                staff38: "38 anställda",
                staff124: "124 anställda",
                overviewSection: "Verksamhet & Bevakning",
                navHub: "Översikt",
                navAgentLog: "Skyddslogg",
                complianceSection: "Lag, Revision & Jurist",
                navIngest: "Bevakade källor",
                navRegister: "Personal & Avtal",
                navContracts: "Anställningsavtal",
                navHandbook: "Personalhandbok",
                navRadar: "Lagradar & trösklar",
                navExpert: "Simployer Jurist",
                navAuditPack: "Revisionspaket",
                oneReadyTitle: "Simployer One Redo",
                oneReadySubtitle: "Data uppdateras strukturerat i bakgrunden utan behov av migrering.",
                hubTitle: "Åtgärdscenter",
                hubPendingSubtitle: "lagstadgade avvikelser kräver godkännande för full efterlevnad",
                hubAllCompliantTitle: "Allt är i enlighet med lagen",
                hubAllCompliantSubtitle: "Fjord Dynamics efterlever alla gällande regler. Inga utestående förelägganden.",
                hubResolveAllButton: "Åtgärda alla",
                hubCompletedBadge: "Slutförd",
                hubCardContractsStatute: "AML § 14-6",
                hubCardContractsTitle: "7 anställningsavtal saknar lagstadgade klausuler",
                hubCardContractsDesc: "Standardavtalen saknar lagstadgade villkor för arbetstid och övertid.",
                hubCardContractsAction: "Godkänn alla (7)",
                hubCardContractsResolved: "7 avtal uppdaterade och signerade",
                hubCardVoStatute: "AML § 6-1",
                hubCardVoTitle: "Obligatoriskt skyddsombud måste väljas",
                hubCardVoDesc: "Fjord Dynamics har 8 anställda och måste välja skyddsombud.",
                hubCardVoAction: "Starta val",
                hubCardVoResolved: "Skyddsombudsval slutfört",
                hubCardEqualPayStatute: "Diskrimineringslagen",
                hubCardEqualPayTitle: "Obligatorisk lönekartläggning",
                hubCardEqualPayDesc: "Fjord Dynamics har 38 anställda och måste kartlägga löneskillnader.",
                hubCardEqualPayAction: "Generera rapport",
                hubCardEqualPayResolved: "Lönekartläggning godkänd",
                hubCardSickStatute: "AML § 4-6",
                hubCardSickTitle: "Lagstadgad uppföljningsplan för Sofia Berg",
                hubCardSickDesc: "Sofia Berg har nått 14 dagars sjukfrånvaro. Uppföljningsplan krävs inom 4 veckor.",
                hubCardSickAction: "Skicka kallelse",
                hubCardSickResolved: "Möteskallelse utskickad",
                hubCardDefenseStatute: "AML § 15-1",
                hubCardDefenseTitle: "Ärende FJD-35: Formkrav före uppsägning",
                hubCardDefenseDesc: "Handläggningen måste kvalitetssäkras före överläggningsmöte.",
                hubCardDefenseAction: "Koppla på jurist",
                hubCardDefenseResolved: "Överfört till jurist",
                hubInspectChanges: "Förhandsgranska",
                hubOpenDetails: "Detaljer",
                hubAuditLiveStatus: "0 aktiva avvikelser · Automatiserad tillsynsradar aktiv",
                dropTitle: "Få full dokumentkoll på 30 sekunder",
                dropSubtitle: "Dra in mappen med gamla anställningsavtal från Macen eller anslut Google Drive.",
                dropBoxTitle: "Dra och släpp mappar eller filer här",
                dropBoxSubtitle: "Stödjer PDF-avtal, Word-dokument och Fortnox/Tripletex CSV",
                dropSimulateButton: "Simulera slutförd import (8 anställda)",
                colEmployee: "ANSTÄLLD",
                colRoleDept: "ROLL & AVDELNING",
                colSalary: "ANSTÄLLNING & FORM",
                colStatus: "AVTALSSTATUS",
                colAction: "ÅTGÄRD",
                startedPrefix: "Startade",
                inspectButton: "Granska",
                currencyUnit: "SEK",
                registerCountSuffix: "anställda i personalregistret",
                filterAll: "Alla",
                filterIssues: "Avvikelser",
                filterCompliant: "I ordning",
                searchEmployeePlaceholder: "Sök efter anställd eller roll...",
                upsellPrefix: "Rekommenderad tilläggsmodul",
                activateModule: "Aktivera modul",
                statusCompliant: "Giltigt (BankID-signerat avtal)",
                statusIllegalOvertime: "Otillåten övertidsklausul (§ 14-6)",
                statusMissingCompetence: "Saknar kompetensbestämmelse (§ 14-6)",
                statusSickDay14: "Sjukskriven dag 14 (Rehabmöte krävs)",
                statusProbationExpiring: "Provanställning upphör om 21 dagar",
                statusDismissalDefenseNeeded: "Varning: Kräver LAS/dröftelse-granskning",
                statusAmuProtocol: "Skyddskommitté-protokoll publicerat",
                statusHmsNeeded: "Saknar obligatorisk SAM/HMS-utbildning",
                statusOk: "Allt i ordning",
                staffCountLabel: "anställda",
                directoryCompliantSummary: "i ordning",
                directoryIssuesSummary: "kräver uppdatering",
                statusCompliantShort: "I ordning · BankID",
                statusUpdateContract: "Avtal måste uppdateras",
                statusMissingHmsShort: "Saknar SAM-kurs",
                statusCompetenceShort: "Saknar kompetensvillkor",
                closeButton: "Stäng",
                diffHmsMissingHeader: "Avvikelse: Saknar lagstadgad SAM-utbildning (Arbetsmiljölagen)",
                diffHmsNotice: "Som VD är Jonas Berg enligt lag skyldig att genomgå utbildning i systematiskt arbetsmiljöarbete (SAM). Inget godkänt kursintyg finns registrerat i Comply.",
                pushAlertHeader: "LAGVARNING (JUST NU)",
                timeJustNow: "Just nu",
                actionReadyHeader: "Åtgärd redo för godkännande",
                actionCardTitle: "Utskick av lagstadgat avtalstillägg",
                actionCardSubtitle: "Genererar automatiskt BankID-signeringslänk för alla berörda anställda.",
                approveWithFaceId: "Godkänn med FaceID",
                approvedFaceId: "Godkänt med FaceID",
                approvedAuditLog: "Skickat via BankID · Revisionslogg uppdaterad",
                consultJuristTitle: "Rådgör med Simployer Jurist",
                consultJuristName: "Ragnhild Hansen, Arbetsrättsjurist",
                penaltyOnPassivity: "Vite vid passivitet",
                voTitle: "Lagstadgat Skyddsombud",
                voSubtitle: "Tröskeln för obligatoriskt skyddsombud har sänkts till 5 anställda.",
                voBoxTitle: "Automatiserat digitalt valgenomförande",
                voBoxSubtitle: "Simployer Comply genererar neutrala digitala röstsedlar till alla 8 anställda och upprättar lagstadgat valprotokoll för arkivering i SAM/HMS-pärmen.",
                voCandidatesHeader: "KANDIDATER NOMINERADE AV DE ANSTÄLLDA",
                voVotesOf: "av",
                voVotesUnit: "röster",
                voAwaitingVotes: "Väntar på röster",
                voSuccessTitle: "Val slutfört: Sofie Hagen är registrerad som skyddsombud",
                voSuccessSubtitle: "Protokoll arkiverat · Nästa steg: Obligatorisk skyddsombudskurs (Simployer Learn)",
                voFooter: "Arbetsmiljölagen kräver skriftligt valprotokoll",
                voSendBallots: "Skicka digitala röstsedlar till alla 8",
                voSignBankId: "Signera valprotokoll med BankID",
                voCloseAndInspect: "Stäng och se uppdaterat register",
                upsellSheetTitlePrefix: "Tillägg: ",
                upsellPricePrefix: "Pris: ",
                upsellBenefitHeader: "KOMMERSIELL FÖRDELSMODELL",
                upsellBullet1: "Noll manuell migrering: befintlig personallista synkas direkt",
                upsellBullet2: "Juridiskt granskad enligt gällande nordisk arbetsrätt",
                upsellBullet3: "Obegränsad tillgång till Simployers juristnätverk vid tvivel",
                upsellActivatedMessage: "Modul aktiverad! Synkroniserar med Fjord Dynamics AS...",
                upsellMonthlyBilling: "Faktureras månadsvis · Ingen bindningstid",
                upsellActivateNow: "Aktivera modul nu",
                sickTitle: "Sjukfrånvarouppföljning: Morten Dahl (Dag 14)",
                sickSubtitle: "Lagstadgad rehabiliterings- och uppföljningsplan ska upprättas i samråd med arbetstagaren inom 4 veckor.",
                sickDeadlinesHeader: "STATUS OCH LAGSTADGADE TIDSFRISTER",
                sickMilestone1Title: "Dag 14 (NU)",
                sickMilestone1Sub: "Första kontakt & kartläggning",
                sickMilestone2Title: "Vecka 4",
                sickMilestone2Sub: "Rehabplan till Försäkringskassan",
                sickMilestone3Title: "Vecka 7",
                sickMilestone3Sub: "Avstämningsmöte 1",
                sickDocsHeader: "FÖRSLAG PÅ DOKUMENT (SIMPLOYER-MALL)",
                sickDocsBody: "• Förifylld rehabiliteringsplan med anpassningsförslag för Cloud-konsulter.\n• Neutral möteskallelse med lagstadgad referens.",
                sickSuccessNotice: "Kallelse och plan skickad till Morten Dahl · Noterat i personalloggen",
                sickSanctionNotice: "Sanktion vid försummelse: Förlust av sjuklöneersättning",
                sickSendInvite: "Skicka kallelse till avstämningsmöte",
                defenseTitle: "Formfelsäkring: MBL/Dröftelsemöte före uppsägning",
                defenseSubtitle: "Gäller: Ärende om bristande prestation v/ Lars Viken (Regionchef Väst)",
                defenseRiskHeader: "🚨 KRITISK RISK FÖR SKADESTÅNDSKRAV",
                defenseRiskBody: "Arbetsdomstolen ogiltigförklarar uppsägningar om formella samråd inte dokumenterats korrekt. Medianbelopp för skadestånd vid ogiltig uppsägning är 396 000 kr plus rättegångskostnader.",
                defenseChecklistHeader: "OBLIGATORISKA FORMALIA",
                defenseCheck1: "Skriftlig kallelse skickad med skälig frist (minst 3 dagar)",
                defenseCheck2: "Arbetstagaren informerad om rätt till fackligt biträde",
                defenseCheck3: "Protokoll från mötet ska undertecknas av båda parter",
                defenseExpertDeskTitle: "Simployer Juridiska Desk",
                defenseExpertDeskDesc: "Ragnhild Hansen, Senior Arbetsrättsjurist. Ärendet överlämnas krypterat för omedelbar granskning.",
                defenseSuccessNotice: "Ärende överlämnat till Ragnhild Hansen. Juridiskt PM klart inom 2 timmar.",
                defenseFooter: "Simployer Expert garanterar full ansvarsförsäkring",
                defenseHandoffButton: "Överför ärende till Simployer Jurist nu",
                equalPayTitle: "Lagstadgad Lönekartläggning (Fjord Dynamics 2025)",
                equalPayBoxHeader: "Aktiva åtgärder & lönekartläggning",
                equalPayBoxDesc: "Med 38 anställda måste Fjord Dynamics genomföra lönekartläggning mellan könen i samma befattningskategori. Hämtas direkt från Tripletex/Fortnox Lön.",
                equalPayCat1: "Utveckling & Ingenjörer (16 anställda)",
                equalPayCat2: "Produkt & Design (8 anställda)",
                equalPayCat3: "Försäljning & Kommersiellt (10 anställda)",
                equalPayRatio1: "97.4 % av männens lön",
                equalPayRatio2: "102.1 % av männens lön",
                equalPayRatio3: "91.2 % av männens lön",
                equalPayStatusOkVariance: "Godkänd (< 5 % avvikelse)",
                equalPayStatusOk: "Godkänd",
                equalPayStatusAlert: "Avvikelse: Kräver åtgärdsplan",
                equalPaySuccessNotice: "Lagstadgad lönekartläggningsrapport genererad och exporterad till årsredovisningen!",
                equalPayFooter: "Källa: Tripletex Lön · Diskrimineringslagen",
                equalPayGenerateButton: "Generera lagstadgad lönekartläggningsrapport",
                diffTitlePrefix: "",
                diffSubtitle: "",
                diffCurrentLabel: "Nuvarande avtal",
                diffCurrentClause: "§ 6. ARBETSTID OCH ÖVERTID\nOrdinarie arbetstid är 37,5 timmar per vecka.\n\n❌ 'Övertidskompensation anses ingå i fast månadslön.'",
                diffCurrentWarning: "",
                diffCompliantLabel: "Uppdaterat avtal",
                diffCompliantClause: "§ 6. ARBETSTID OCH ÖVERTID (UPPDATERAD)\n\n🟢 'Vid beordrad övertid utgår minst 40 % övertidstillägg.'\n\n§ 11. Rätt till kompetensutveckling bekostas av arbetsgivaren.",
                diffCompliantFootnote: "",
                diffAuditNotice: "",
                diffApproveButton: "Godkänn & signera",
                diffApprovedBadge: "Skickat via BankID!",
                demoPillLabel: "Demo",
                demoControllerTitle: "Demo Kontroller",
                demoControllerSubtitle: "",
                demoInternalBadge: "Demo",
                demoTimelineHeader: "TIDSHOPP",
                demoAutoplayHeader: "AUTOPLAY",
                demoAutoplayDesc: "",
                demoResetButton: "Återställ",
                demoSyncActive: "iOS-synk aktiv",
                searchPlaceholder: "Sök eller hoppa till... (⌘K)",
                expertSiaTitle: "Sia Juridisk & Lönekalkylator",
                expertSiaSubtitle: "Omedelbara juridiska beräkningar enligt norsk lag och Simployer-praxis",
                feriepengerTab: "Semesterersättning",
                sykefravaerTab: "Sjukfrånvaro",
                egenmeldingTab: "Sjukanmälan",
                askJuristButton: "Fråga jurist",
                uploadRosterButton: "Ladda upp anställdlista (CSV)",
                rosterUploadedBanner: "8 anställda importerade från personallista.csv · NACE 62.01",
                aiHandbookChapterTitle: "Användning av Artificiell Intelligens (AI) på Arbetsplatsen",
                aiHandbookSummary: "Riktlinjer för anställdas användning av generativa AI-verktyg (ChatGPT, Claude, Copilot). Skydd av företagshemligheter och GDPR.",
                ingestSourcesTitle: "Källor & Dokumentövervakning",
                ingestSourcesSubtitle: "Comply samlar och övervakar dokument automatiskt från anslutna molnlagringar och lokala mappar.",
                ingestHeroTitle: "Släpp anställningsavtal eller mappar här",
                ingestHeroSubtitle: "PDF, Word (.docx) eller Fortnox / Visma CSV",
                ingestBrowseButton: "Välj från Mac...",
                ingestSimulateButton: "Simulera import (8 anställda)",
                monitoredSourcesHeader: "Övervakade källor",
                activeSuffix: "aktiva",
                addFolderButton: "Lägg till mapp...",
                connectedBadge: "Ansluten",
                guardingBadge: "Aktiv bevakning",
                downloadsFolderDesc: "Fångar automatiskt upp nedladdade avtal",
                documentsFolderDesc: "Lokal arkivmapp för anställningshandlingar",
                connectMoreLabel: "Anslut:",
                filesSyncedSuffix: "filer synkroniserade",
                reassuranceTitle: "21 dokument har analyserats och skyddas",
                reassuranceBreakdown: "8 anställningsavtal · 1 personalhandbok · 8 löneposter från Fortnox",
                reassuranceButton: "Gå till Åtgärder (2)",
                cloudSourcesHeader: "MOLNLAGRING & SAMARBETE",
                localFoldersHeader: "ÖVERVAKADE LOKALA MAPPAR PÅ MACEN",
                documentMapHeader: "STRUKTURERAD DOKUMENTÖVERSIKT",
                connectButton: "Anslut",
                scanNowButton: "Skanna källor nu",
                noEmployeesMatchFilter: "Inga anställda matchar sökningen",
                resetFilterButton: "Återställ filter",
                hubCardHmsStatute: "AML § 3-5",
                hubCardHmsTitle: "KMA/HMS-kurs för VD",
                hubCardHmsDesc: "Verkställande direktör är enligt lag skyldig att genomgå utbildning i hälsa, miljö och säkerhet.",
                hubCardHmsAction: "Starta kurs (Simployer Learn)",
                hubCardHmsResolved: "VD anmäld till godkänd KMA-utbildning.",
                hubCardProbationStatute: "AML § 15-6 · Provanställning",
                hubCardProbationTitle: "Provanställning löper ut för 2 nyanställda om 18 dagar",
                hubCardProbationDesc: "Utvärdering och uppföljningssamtal måste genomföras inom 6 månader för att upprätthålla lagligt anställningsskydd.",
                hubCardProbationAction: "Bekräfta utvärdering",
                hubCardProbationResolved: "Provanställningsutvärderingar slutförda. Tillsvidareanställning bekräftad.",
                handbookAiUpdateNotice: "Automatiserad uppdatering enl. ändringar i AML 2024 & EU AI Act · Simployer Redaktion",
                handbookApprovedAiToolsHeader: "GODKÄNDA GENERATIVA AI-VERKTYG I VERKSAMHETEN",
                radarAutomatedWatchNotice: "Automatiserad övervakning av lagstadgade trösklar baserat på bolagets tillväxt",
                expertPrecisionNotice: "Automatiserad precisionsberäkning baserad på gällande lag och kollektivavtal",
                expertAnnualSalaryHeader: "ÅRSLÖN FÖR BERÄKNING",
                expertTimelineHeader: "LAGSTADGAD TIDSLINJE FÖR SJUKFRÅNVARO",
                expertFolketrygdNotice: "Socialförsäkringsbalken & Arbetsmiljölagen",
                expertSelfCertNotice: "Socialförsäkringsbalken · Intjänandetid: 2 månader",
                expertSelfCertRulesBody: "En anställd har rätt att använda sjukanmälan i upp till 7 sammanhängande kalenderdagar per frånvarotillfälle. Därefter krävs läkarintyg för att behålla rätten till sjuklön under sjuklöneperioden (14 dagar).",
                expertLegalCounselHeader: "Rådgivning från Arbetsrättsjurist",
                expertLegalCounselDesc: "Simployers jurister biträder vid mbl-förhandlingar, uppsägningar och omorganisation",
                diffGapHeader: "Avtalet saknar lagkrav från 1 juli 2024",
                diffGapSubline: "Villkor för övertidsersättning och utbildning måste framgå skriftligt.",
                diffStatuteBadge: "AML § 14-6 / LAS",
                diffCompliantHeader: "Avtalet är i linje med lagen",
                diffSickHeader: "Sjukskrivning Dag 14: Lagstadgad uppföljningsplan",
                diffDismissalHeader: "Anställningsskydd och uppsägningsgrund",
                diffDismissalNotice: "Formella förhandlingsregler enligt AML § 15-1 måste följas före mötet.",
                diffCompliantNotice: "Alla anställningsvillkor och klausuler uppfyller gällande lagstiftning.",
                handbookCh1Title: "Anställningsavtal & Tidsbegränsade Anställningar",
                handbookCh1Statute: "AML § 14-6 & § 14-9 / LAS",
                handbookCh1Status: "Lagreviderad 1 juli 2024",
                handbookCh1Summary: "Krav på skriftliga avtal inom 7 dagar, precisering av arbetstid och förbud mot generella övertidsklausuler.",
                handbookCh2Title: "Skyddsombud & Arbetsmiljöorganisation",
                handbookCh2Statute: "AML § 6-1 / AML kap 6",
                handbookCh2Status: "Obligatoriskt från 5 anställda (1 jan 2024)",
                handbookCh2Summary: "Obligatoriskt val av skyddsombud för alla verksamheter med 5 eller fler anställda. Valprotokoll arkiveras i arbetsmiljöakten.",
                handbookCh3Title: "Arbetstid, Övertid & Kompensation",
                handbookCh3Statute: "AML § 10-6 / Arbetstidslagen",
                handbookCh3Status: "Minst 40 % övertidstillägg",
                handbookCh3Summary: "Lagstadgad rätt till övertidsersättning. Kompensation kan inte inkluderas i fast månadslön för ordinarie tjänster.",
                handbookCh4Title: "Visselblåsning & Psykosocial Arbetsmiljö",
                handbookCh4Statute: "AML § 2 A-1 till § 2 A-3 / Visselblåsarlagen",
                handbookCh4Status: "Visselblåsarkanal etablerad",
                handbookCh4Summary: "Lagstadgad rutin för missförhållanden, objektiv utredningsplikt och förbud mot repressalier.",
                handbookCh5Status: "Aktiv policy · 8/8 bekräftade",
                aiChipTextStatus: "Godkänt textutkast",
                aiChipDataStatus: "Godkänd dataanalys",
                aiChipCodeStatus: "Godkänd källkod",
                radarActiveStatus: "Radar Aktiv",
                radarCard5Threshold: "5 anställda",
                radarCard5Title: "Obligatoriskt skyddsombud",
                radarCard5Status: "Utlöst (8 anställda)",
                radarCard5Desc: "Tröskeln sänkt från 10 till 5 anställda. Lagundantag gäller inte längre. Val måste genomföras med protokoll.",
                radarCard10Threshold: "10 anställda",
                radarCard10Title: "Skyddskommitté & Skyddsombudsavtal",
                radarCard10Desc: "Parterna kan avtala om annan ordning vid under 10 anställda. Vid fler än 10 anställda krävs skyddskommitté om part begär det.",
                radarCard50Threshold: "50 anställda",
                radarCard50Title: "Förhandlingsskyldighet & Årlig Lönekartläggning",
                radarCard50Status: "Framtida tillväxttröskel",
                radarCard50Desc: "Lagstadgad regelbunden samverkan med fackliga företrädare samt årlig lönegapsanalys för jämställdhet.",
                expertRetainerBadge: "Retainer Aktiv · 5 000 000 kr skydd",
                expertAnnualSalaryCalcHeader: "ÅRSLÖN FÖR BERÄKNING",
                expertFifthWeekToggle: "5:e avtalade semesterveckan (12,0 %)",
                expertCalcResultHeader: "BERÄKNAD SEMESTERERSÄTTNING",
                expertCalcRateHeader: "PROCENTSATS",
                expertCalcRateStandard: "10,2 % (Semesterlagen § 10)",
                expertCalcRateExtended: "12,0 % (Kollektivavtal)",
                expertSickTimelineHeader: "LAGSTADGAD TIDSLINJE FÖR SJUKFRÅNVARO",
                expertSickTimelineStatute: "Folketrygdloven § 8-7 & Arbetsmiljölagen § 4-6",
                expertSickTimelineActiveCase: "Aktivt ärende: Magnus Teig (14 dagar)",
                expertSickMilestone1Time: "Vecka 4 (Dag 28)",
                expertSickMilestone1Title: "Uppföljningsplan",
                expertSickMilestone1Desc: "Ska upprättas i samråd med anställd och skickas till läkare.",
                expertSickMilestone1Remaining: "14 dagar kvar",
                expertSickMilestone2Time: "Vecka 7 (Dag 49)",
                expertSickMilestone2Title: "Dialogmöte 1",
                expertSickMilestone2Desc: "Obligatoriskt möte med chef, medarbetare och företagshälsovård.",
                expertSickMilestone2Remaining: "35 dagar till tidsfrist",
                expertSelfCertRulesHeader: "SJUKANMÄLAN & KARENSREGLER",
                expertSelfCertStatute: "Folketrygdloven § 8-24 · Kvalificeringstid: 2 månader",
                expertSelfCertAllApprovedBadge: "Alla 8 anställda godkända",
                expertInquirySent: "Förfrågan skickad",
                expertPastCaseTitle: "Ärende #JUR-2024-89 · AML § 14-6 Avtalsrevision",
                expertPastCaseDesc: "Kvalitetssäkrat tilläggsavtal för 7 anställda. BankID-signatur förankrad i juridisk revisionslogg.",
                expertPastCaseClosed: "Stängt & Arkiverat",
                paletteSectionNav: "NAVIGERING",
                paletteSectionActions: "LAGAR & ÅTGÄRDER",
                paletteSectionEmployees: "ANSTÄLLDA",
                paletteSectionYears: "TIDSHOPP (SCENARIO)",
                narrationSteps: [
                    LocalizedNarrationStep(
                        title: "Kapitel 1: Uppstart & Filsläpp (2024 · 8 anställda)",
                        body: "Fjord Dynamics sparar avtal i lokala mappar. Comply städar upp kaoset på 30 sekunder via direkt drag-och-släpp."
                    ),
                    LocalizedNarrationStep(
                        title: "Automatiserad avvikelseanalys (§ 14-6)",
                        body: "Comply upptäcker att 7 av 8 avtal innehåller otillåtna övertidsklausuler enligt lagkrav från 1 juli 2024."
                    ),
                    LocalizedNarrationStep(
                        title: "Lagstadgat Skyddsombud (§ 6-1)",
                        body: "Tröskeln har sänkts till 5 anställda. Comply genomför ett neutralt digitalt val och upprättar formellt protokoll."
                    ),
                    LocalizedNarrationStep(
                        title: "Kapitel 2: Skalning & Lönekartläggning (2025 · 38 anställda)",
                        body: "Vid 20+ anställda krävs 2-årlig lönekartläggning. Comply analyserar lönedata helt automatiskt."
                    ),
                    LocalizedNarrationStep(
                        title: "Sjukfrånvaro dag 14: Förberedelse för avstämningsmöte",
                        body: "Comply förhindrar förlust av sjuklöneersättning genom att automatiskt skapa en rehabiliteringsplan för Morten Dahl."
                    ),
                    LocalizedNarrationStep(
                        title: "Kapitel 3: Etablerat bolag (2027 · 124 anställda)",
                        body: "Undviker 396 000 kr i formfel vid uppsägning. Smidig överlämning till Simployer Expert-jurist med ett klick."
                    ),
                    LocalizedNarrationStep(
                        title: "Simployer Comply: Alltid i enlighet med lagen. Utan att läsa den.",
                        body: "Proaktiv efterlevnad integrerad direkt i macOS-vardagen. Ingen manuell övervakning, inga juridiska överraskningar."
                    )
                ],
                scenarios: [
                    .y2024: LocalizedScenarioContent(
                        stageName: "The Seedling (Uppstart & Kaos)",
                        tagline: "8 anställda · Google Drive-kaos · VD gör allt",
                        primaryRisk: "Saknar skyddsombud (tröskel sänkt till 5) + 8 ogiltiga avtal (§ 14-6)",
                        triggerTitle: "Lagstadgat Skyddsombud saknas",
                        triggerStatute: "AML § 6-1 (Krav från 1 jan 2024)",
                        triggerDescription: "Kravet på skyddsombud har sänkts till 5 anställda. Fjord Dynamics har 8 anställda och inget skyddsombud.",
                        triggerConsequence: "Arbetsmiljöverket utfärdar vitesföreläggande vid tillsyn.",
                        triggerActionLabel: "Starta digitalt skyddsombudsval",
                        upsellProduct: "Simployer Learn",
                        upsellTitle: "Lagstadgad SAM/HMS-utbildning för VD + Skyddsombudskurs",
                        upsellPrice: "1 490 SEK per kurs",
                        upsellBenefit: "Säkerställer godkänt kursintyg för arkivering i Comply."
                    ),
                    .y2025: LocalizedScenarioContent(
                        stageName: "The Scale-Up (Tillväxt & Tröskelradar)",
                        tagline: "38 anställda · Camilla anställd som solo HR · Tripletex/Fortnox-synk",
                        primaryRisk: "Krav på lönekartläggning + Sjukfrånvaro dag 14",
                        triggerTitle: "Lönekartläggning obligatorisk vid 20+ anställda",
                        triggerStatute: "Diskrimineringslagen / Likestillingsloven § 26",
                        triggerDescription: "Med 38 anställda är bolaget skyldigt att kartlägga löneskillnader mellan kvinnor och män.",
                        triggerConsequence: "Rapporteringsbrist i årsredovisningen kan medföra tillsyn och sanktioner.",
                        triggerActionLabel: "Kör automatisk lönegapsanalys",
                        upsellProduct: "Simployer Equal Pay + One Core",
                        upsellTitle: "Automatisk lönekartläggning & Komplett HRM-system",
                        upsellPrice: "79 SEK / anställd / mån",
                        upsellBenefit: "Uppgraderar personalregistret till komplett frånvaro- och semesterhantering utan manuell migrering."
                    ),
                    .y2027: LocalizedScenarioContent(
                        stageName: "The Established Force (Etablerat & Jurist)",
                        tagline: "124 anställda · Simployer One operativt · Lagstadgad visselblåsarkanal",
                        primaryRisk: "Decentraliserade linjechefer hanterar uppsägningar (Risk för 396k formfel)",
                        triggerTitle: "Formfel vid uppsägningsärende (§ 15-1)",
                        triggerStatute: "Arbetsmiljölagen kapitel 15 / MBL",
                        triggerDescription: "Avdelningschef vill säga upp en anställd för bristande leverans. Inget formellt dröftelsemöte har hållits.",
                        triggerConsequence: "Domstolen ogiltigförklarar uppsägningar vid formfel (medianförlust 396 000 SEK + rättegångskostnader).",
                        triggerActionLabel: "Aktivera Simployer Jurist före möte",
                        upsellProduct: "Simployer Expert Retainer",
                        upsellTitle: "Obegränsad skriftlig advokatrådgivning & Ansvarsförsäkring",
                        upsellPrice: "3 990 SEK / mån",
                        upsellBenefit: "Certifierade arbetsrättsjurister kvalitetssäkrar samråd och uppsägningar med full ansvarsförsäkring."
                    )
                ]
            )
            
        case .en:
            return LocalizedStrings(
                languageCode: "en",
                slogan: "Always legally compliant. Without reading the law.",
                activeRadar: "Active Radar",
                autoplayStart: "Autoplay Demo",
                autoplayStop: "Stop",
                chapterPrefix: "Chapter",
                close: "Close",
                done: "Done",
                menuOpenControlRoom: "Open Comply Control Room",
                menuQuit: "Quit",
                menuStatusLabel: "Status: Always legally compliant",
                year1Label: "2024 · Year 1",
                year2Label: "2025 · Year 2",
                year4Label: "2027 · Year 4",
                staff8: "8 employees",
                staff38: "38 employees",
                staff124: "124 employees",
                overviewSection: "Operations & Monitoring",
                navHub: "Overview",
                navAgentLog: "Protection Log",
                complianceSection: "Law, Audit & Legal",
                navIngest: "Guarded Sources",
                navRegister: "Personnel & Contracts",
                navContracts: "Employment Contracts",
                navHandbook: "Employee Handbook",
                navRadar: "Statutory Radar & Thresholds",
                navExpert: "Simployer Legal Desk",
                navAuditPack: "Audit Packages",
                oneReadyTitle: "Simployer One Ready",
                oneReadySubtitle: "Records are continuously structured in the background with zero migration.",
                hubTitle: "Action Hub",
                hubPendingSubtitle: "statutory compliance items require your sign-off",
                hubAllCompliantTitle: "Fully Compliant",
                hubAllCompliantSubtitle: "Fjord Dynamics complies with all active statutory rules. No pending notices.",
                hubResolveAllButton: "Resolve all",
                hubCompletedBadge: "Resolved",
                hubCardContractsStatute: "AML § 14-6",
                hubCardContractsTitle: "7 employment contracts miss statutory clauses",
                hubCardContractsDesc: "Standard contracts lack statutory clauses for working hours and overtime.",
                hubCardContractsAction: "Approve all (7)",
                hubCardContractsResolved: "7 contracts updated and signed",
                hubCardVoStatute: "AML § 6-1",
                hubCardVoTitle: "Mandatory safety representative must be elected",
                hubCardVoDesc: "Fjord Dynamics has 8 employees and must elect a safety representative.",
                hubCardVoAction: "Start election",
                hubCardVoResolved: "Safety election completed",
                hubCardEqualPayStatute: "Equality Act § 26",
                hubCardEqualPayTitle: "Mandatory equal pay audit",
                hubCardEqualPayDesc: "Fjord Dynamics has 38 employees and must conduct an equal pay audit.",
                hubCardEqualPayAction: "Generate report",
                hubCardEqualPayResolved: "Equal pay audit approved",
                hubCardSickStatute: "AML § 4-6",
                hubCardSickTitle: "Statutory follow-up plan for Sofia Berg",
                hubCardSickDesc: "Sofia Berg reached day 14 of sick leave. Follow-up plan required within 4 weeks.",
                hubCardSickAction: "Send invite",
                hubCardSickResolved: "Meeting invite dispatched",
                hubCardDefenseStatute: "AML § 15-1",
                hubCardDefenseTitle: "Case FJD-35: Formal review before dismissal",
                hubCardDefenseDesc: "Case handling must be vetted before the formal dismissal meeting.",
                hubCardDefenseAction: "Connect legal counsel",
                hubCardDefenseResolved: "Transferred to legal counsel",
                hubInspectChanges: "Preview",
                hubOpenDetails: "Details",
                hubAuditLiveStatus: "0 active issues · Automated compliance radar active",
                dropTitle: "Structure and guard in 30 seconds",
                dropSubtitle: "Drag in legacy employment contracts from your Mac or sync Google Drive.",
                dropBoxTitle: "Drag and drop folders or files here",
                dropBoxSubtitle: "Supports PDF contracts, Word documents, and Tripletex CSV exports",
                dropSimulateButton: "Simulate finished import (8 staff)",
                colEmployee: "EMPLOYEE",
                colRoleDept: "ROLE & DEPARTMENT",
                colSalary: "EMPLOYMENT & FORM",
                colStatus: "CONTRACT STATUS",
                colAction: "ACTION",
                startedPrefix: "Started",
                inspectButton: "Review",
                currencyUnit: "NOK",
                registerCountSuffix: "employees in directory",
                filterAll: "All",
                filterIssues: "Issues",
                filterCompliant: "Compliant",
                searchEmployeePlaceholder: "Search employee or role...",
                upsellPrefix: "Recommended Add-On",
                activateModule: "Activate Module",
                statusCompliant: "Compliant (AML § 14-6 BankID Signed)",
                statusIllegalOvertime: "Unlawful overtime clause (§ 14-6)",
                statusMissingCompetence: "Missing training rights (§ 14-6)",
                statusSickDay14: "Day 14 sick leave (Meeting required)",
                statusProbationExpiring: "Probation expires in 21 days",
                statusDismissalDefenseNeeded: "Alert: Mandatory dismissal protocol required",
                statusAmuProtocol: "Safety committee protocol published",
                statusHmsNeeded: "Missing statutory OHS certification",
                statusOk: "In order (OHS certified)",
                staffCountLabel: "employees",
                directoryCompliantSummary: "in order",
                directoryIssuesSummary: "need update",
                statusCompliantShort: "In order · BankID",
                statusUpdateContract: "Update contract",
                statusMissingHmsShort: "Missing HSE course",
                statusCompetenceShort: "Missing competence clause",
                closeButton: "Close",
                diffHmsMissingHeader: "Gap: Missing mandatory HSE course (AML § 3-5)",
                diffHmsNotice: "As Managing Director / CEO, Jonas Berg is legally required to complete certified health, safety and environment training. No valid training certificate is filed in Comply.",
                pushAlertHeader: "LEGAL ALERT (NOW)",
                timeJustNow: "Just now",
                actionReadyHeader: "Action ready for approval",
                actionCardTitle: "Dispatch AML § 14-6 Contract Addendum",
                actionCardSubtitle: "Automatically generates BankID signing links for all affected employees.",
                approveWithFaceId: "Approve with FaceID",
                approvedFaceId: "Approved with FaceID",
                approvedAuditLog: "Dispatched via BankID · Audit trail updated",
                consultJuristTitle: "Consult Simployer Legal Counsel",
                consultJuristName: "Ragnhild Hansen, Senior Employment Attorney",
                penaltyOnPassivity: "Injunction upon inaction",
                voTitle: "Statutory Safety Representative",
                voSubtitle: "The statutory threshold for a safety representative was lowered from 10 to 5 employees (Jan 1, 2024).",
                voBoxTitle: "Automated digital election process",
                voBoxSubtitle: "Simployer Comply generates neutral digital ballots for all 8 employees and produces the statutory election minutes for HSE filing.",
                voCandidatesHeader: "CANDIDATES NOMINATED BY EMPLOYEES",
                voVotesOf: "of",
                voVotesUnit: "votes",
                voAwaitingVotes: "Awaiting votes",
                voSuccessTitle: "Election complete: Sofie Hagen is registered as safety representative",
                voSuccessSubtitle: "Protocol archived · Next step: Mandatory 40-hour safety rep course (Simployer Learn)",
                voFooter: "Working Environment Act § 6-1 requires formal written election minutes",
                voSendBallots: "Send digital ballots to all 8",
                voSignBankId: "Sign election minutes with BankID",
                voCloseAndInspect: "Close and view updated directory",
                upsellSheetTitlePrefix: "Add-On: ",
                upsellPricePrefix: "Price: ",
                upsellBenefitHeader: "COMMERCIAL BENEFIT MODEL",
                upsellBullet1: "Zero manual migration: existing personnel records sync directly",
                upsellBullet2: "Legally vetted according to Nordic statutory labor regulations",
                upsellBullet3: "Unlimited access to Simployer expert legal network on demand",
                upsellActivatedMessage: "Module activated! Syncing with Fjord Dynamics AS...",
                upsellMonthlyBilling: "Billed monthly · No lock-in period",
                upsellActivateNow: "Activate module now",
                sickTitle: "Sick Leave Follow-Up: Morten Dahl (Day 14)",
                sickSubtitle: "Statutory follow-up plan must be prepared in consultation with employee within 4 weeks.",
                sickDeadlinesHeader: "STATUS & STATUTORY DEADLINES",
                sickMilestone1Title: "Day 14 (NOW)",
                sickMilestone1Sub: "Initial contact & assessment",
                sickMilestone2Title: "Week 4",
                sickMilestone2Sub: "Follow-up plan submitted",
                sickMilestone3Title: "Week 7",
                sickMilestone3Sub: "Dialog meeting 1",
                sickDocsHeader: "PROPOSED DOCUMENTS (SIMPLOYER TEMPLATE)",
                sickDocsBody: "• Pre-filled follow-up plan with accommodation proposals for Cloud consultants.\n• Neutral meeting invitation referencing social security statutory regulations.",
                sickSuccessNotice: "Invitation and plan sent to Morten Dahl · Recorded in personnel log",
                sickSanctionNotice: "Sanction upon default: Loss of sickness benefit reimbursement",
                sickSendInvite: "Send invitation to dialog meeting",
                defenseTitle: "Procedure Safeguard: Pre-Dismissal Consultation",
                defenseSubtitle: "Regarding: Performance deficiency case re Lars Viken (Regional Director West)",
                defenseRiskHeader: "🚨 CRITICAL DAMAGES RISK",
                defenseRiskBody: "Labor courts invalidate dismissals if formal consultation is not properly documented. Median damages for unlawful dismissal are 396,000 NOK plus legal fees (~250,000 NOK).",
                defenseChecklistHeader: "MANDATORY PROCEDURAL CHECKS",
                defenseCheck1: "Written notice sent with reasonable advance notice (min. 3 days)",
                defenseCheck2: "Employee informed of right to union / legal representative",
                defenseCheck3: "Consultation minutes must be signed by both parties",
                defenseExpertDeskTitle: "Simployer Legal Desk",
                defenseExpertDeskDesc: "Ragnhild Hansen, Senior Employment Attorney. Case file transferred encrypted for immediate legal review.",
                defenseSuccessNotice: "Case file delivered to Ragnhild Hansen. Legal brief ready within 2 hours.",
                defenseFooter: "Simployer Expert guarantees legal liability coverage",
                defenseHandoffButton: "Transfer case to Simployer Legal Counsel now",
                equalPayTitle: "Statutory Equal Pay Audit (Fjord Dynamics 2025)",
                equalPayBoxHeader: "Pay Transparency & Statutory Equal Pay Audit",
                equalPayBoxDesc: "With 38 employees, Fjord Dynamics must conduct an equal pay audit across genders and job roles. Synchronized directly with Tripletex Payroll.",
                equalPayCat1: "Engineering & Tech (16 employees)",
                equalPayCat2: "Product & Design (8 employees)",
                equalPayCat3: "Sales & Commercial (10 employees)",
                equalPayRatio1: "97.4% of male salary",
                equalPayRatio2: "102.1% of male salary",
                equalPayRatio3: "91.2% of male salary",
                equalPayStatusOkVariance: "Approved (< 5% variance)",
                equalPayStatusOk: "Approved",
                equalPayStatusAlert: "Variance: Action plan required",
                equalPaySuccessNotice: "Statutory pay audit report generated and exported to annual accounts!",
                equalPayFooter: "Source: Tripletex Payroll integration · Equality and Anti-Discrimination Act § 26",
                equalPayGenerateButton: "Generate Statutory Equal Pay Report",
                diffTitlePrefix: "",
                diffSubtitle: "",
                diffCurrentLabel: "Current agreement",
                diffCurrentClause: "§ 6. WORKING HOURS & OVERTIME\nStandard working hours are 37.5 hours per week.\n\n❌ 'Overtime compensation is deemed included in fixed base salary.'",
                diffCurrentWarning: "",
                diffCompliantLabel: "Updated agreement",
                diffCompliantClause: "§ 6. WORKING HOURS & OVERTIME (UPDATED)\n\n🟢 'Overtime work is compensated with a minimum 40% premium pursuant to Working Environment Act § 10-6 (11).'\n\n§ 11. Right to employer-funded training and skills development.",
                diffCompliantFootnote: "",
                diffAuditNotice: "",
                diffApproveButton: "Approve & sign",
                diffApprovedBadge: "Dispatched via BankID!",
                demoPillLabel: "Demo",
                demoControllerTitle: "Demo Controls",
                demoControllerSubtitle: "",
                demoInternalBadge: "Demo",
                demoTimelineHeader: "TIMELINE",
                demoAutoplayHeader: "AUTOPLAY",
                demoAutoplayDesc: "",
                demoResetButton: "Reset",
                demoSyncActive: "iOS sync active",
                searchPlaceholder: "Search or jump to... (⌘K)",
                expertSiaTitle: "Sia Legal & Payroll Calculator",
                expertSiaSubtitle: "Instant statutory calculations according to Norwegian labor law and Simployer precedent",
                feriepengerTab: "Holiday Pay",
                sykefravaerTab: "Sick Leave",
                egenmeldingTab: "Self-Certification",
                askJuristButton: "Ask a legal adviser",
                uploadRosterButton: "Upload Employee List (CSV)",
                rosterUploadedBanner: "8 employees imported from employee_list.csv · NACE 62.01",
                aiHandbookChapterTitle: "Workplace Use of Artificial Intelligence (AI)",
                aiHandbookSummary: "Internal policy for employee use of generative AI tools (ChatGPT, Claude, Copilot). Safeguarding trade secrets and GDPR.",
                ingestSourcesTitle: "Sources & File Guard",
                ingestSourcesSubtitle: "Comply automatically collects and guards documents from connected cloud storage and local folders.",
                ingestHeroTitle: "Drop employment agreements or folders here",
                ingestHeroSubtitle: "PDF, Word (.docx), or Tripletex / payroll CSV",
                ingestBrowseButton: "Choose from Mac...",
                ingestSimulateButton: "Simulate import (8 employees)",
                monitoredSourcesHeader: "Guarded sources",
                activeSuffix: "active",
                addFolderButton: "Add folder...",
                connectedBadge: "Connected",
                guardingBadge: "Guarding",
                downloadsFolderDesc: "Automatically captures downloaded agreements",
                documentsFolderDesc: "Local archive for employment records",
                connectMoreLabel: "Connect:",
                filesSyncedSuffix: "files synced",
                reassuranceTitle: "21 documents analysed and guarded",
                reassuranceBreakdown: "8 employment agreements · 1 handbook · 8 payroll entries from Tripletex",
                reassuranceButton: "Go to Actions (2)",
                cloudSourcesHeader: "CLOUD STORAGE & COLLABORATION",
                localFoldersHeader: "GUARDED LOCAL FOLDERS ON MAC",
                documentMapHeader: "STRUCTURED DOCUMENT MAP",
                connectButton: "Connect",
                scanNowButton: "Scan sources now",
                noEmployeesMatchFilter: "No employees match search query",
                resetFilterButton: "Reset filters",
                hubCardHmsStatute: "AML § 3-5",
                hubCardHmsTitle: "Mandatory EHS training for CEO",
                hubCardHmsDesc: "The managing director is legally required to complete certified training in environment, health, and workplace safety.",
                hubCardHmsAction: "Start course (Simployer Learn)",
                hubCardHmsResolved: "CEO enrolled in certified EHS course.",
                hubCardProbationStatute: "AML § 15-6 · Probation Period",
                hubCardProbationTitle: "Probation period expires for 2 staff in 18 days",
                hubCardProbationDesc: "Evaluation and formal review must be completed within 6 months to maintain statutory employment protections.",
                hubCardProbationAction: "Confirm evaluation",
                hubCardProbationResolved: "Probation evaluations registered complete. Permanent tenure confirmed.",
                handbookAiUpdateNotice: "Automated update reflecting AML 2024 & EU AI Act · Simployer Legal Editorial",
                handbookApprovedAiToolsHeader: "APPROVED GENERATIVE AI TOOLS IN COMPANY WORKSPACE",
                radarAutomatedWatchNotice: "Automated statutory threshold monitoring based on company headcount trajectory",
                expertPrecisionNotice: "Automated precision calculation grounded in active statutory law and collective frameworks",
                expertAnnualSalaryHeader: "ANNUAL SALARY BASE",
                expertTimelineHeader: "STATUTORY SICK LEAVE TIMELINE",
                expertFolketrygdNotice: "National Insurance Act § 8-7 & Working Environment Act § 4-6",
                expertSelfCertNotice: "National Insurance Act § 8-24 · Qualifying period: 2 months",
                expertSelfCertRulesBody: "An employee has the statutory right to use self-certification for up to 3 consecutive calendar days per instance, capped at 4 instances per 12-month window. Exceeding this requires certified medical leave to maintain sick pay rights during the employer liability window (16 days).",
                expertLegalCounselHeader: "Consultation with Employment Law Counsel",
                expertLegalCounselDesc: "Simployer employment attorneys assist with formal dismissal hearings, terminations, and restructurings",
                diffGapHeader: "Agreement missing terms from July 2024 rules",
                diffGapSubline: "Terms for overtime compensation and training rights must be specified in writing.",
                diffStatuteBadge: "WEA § 14-6",
                diffCompliantHeader: "Agreement meets all legal requirements",
                diffSickHeader: "Sick Leave Day 14: Mandatory follow-up plan",
                diffDismissalHeader: "Employment protection & dismissal justification",
                diffDismissalNotice: "WEA § 15-1 procedural consultation rules must be observed prior to meeting.",
                diffCompliantNotice: "All employment terms and clauses comply with current labor statutes.",
                handbookCh1Title: "Employment Contracts & Temporary Hires",
                handbookCh1Statute: "WEA § 14-6 & § 14-9",
                handbookCh1Status: "Amended July 1, 2024",
                handbookCh1Summary: "Requirement for written contracts within 7 days, explicit working hour definitions, and prohibition of blanket overtime waivers.",
                handbookCh2Title: "Safety Representatives & HSE Organization",
                handbookCh2Statute: "WEA § 6-1",
                handbookCh2Status: "Mandatory from 5 employees (Jan 1, 2024)",
                handbookCh2Summary: "Mandatory secret election of safety representative for all companies with 5+ employees. Protocol filed in HSE archive.",
                handbookCh3Title: "Working Hours, Overtime & Compensation",
                handbookCh3Statute: "WEA § 10-6",
                handbookCh3Status: "Minimum 40% overtime premium",
                handbookCh3Summary: "Statutory entitlement to overtime pay. Overtime compensation cannot be bundled into fixed base salary for ordinary roles.",
                handbookCh4Title: "Whistleblowing & Psychosocial Workplace",
                handbookCh4Statute: "WEA § 2 A-1 to § 2 A-3",
                handbookCh4Status: "Whistleblowing channel live",
                handbookCh4Summary: "Mandatory reporting procedures for misconduct, objective duty to investigate, and strict prohibition of retaliation.",
                handbookCh5Status: "Active policy · 8/8 confirmed",
                aiChipTextStatus: "Approved text drafting",
                aiChipDataStatus: "Approved data analysis",
                aiChipCodeStatus: "Approved source code",
                radarActiveStatus: "Radar Active",
                radarCard5Threshold: "5 employees",
                radarCard5Title: "Mandatory Safety Representative",
                radarCard5Status: "Triggered (8 employees)",
                radarCard5Desc: "Threshold lowered from 10 to 5 employees. Statutory exemptions no longer apply. Election must be executed with protocol.",
                radarCard10Threshold: "10 employees",
                radarCard10Title: "Working Environment Committee (AMU) & Agreement",
                radarCard10Desc: "Parties may agree alternative arrangements under 10 employees. Crossing 10 employees mandates AMU if requested by either party.",
                radarCard50Threshold: "50 employees",
                radarCard50Title: "Consultation Duty & Annual Equal Pay Audit",
                radarCard50Status: "Future growth milestone",
                radarCard50Desc: "Mandatory regular consultations with union reps and annual gender pay gap reporting (ARP).",
                expertRetainerBadge: "Retainer Active · NOK 5,000,000 legal coverage",
                expertAnnualSalaryCalcHeader: "ANNUAL SALARY BASE",
                expertFifthWeekToggle: "5th contractual holiday week (12.0%)",
                expertCalcResultHeader: "CALCULATED HOLIDAY PAY",
                expertCalcRateHeader: "RATE",
                expertCalcRateStandard: "10.2% (Holiday Act § 10)",
                expertCalcRateExtended: "12.0% (Tariff / Agreement)",
                expertSickTimelineHeader: "STATUTORY SICK LEAVE TIMELINE",
                expertSickTimelineStatute: "National Insurance Act § 8-7 & Working Environment Act § 4-6",
                expertSickTimelineActiveCase: "Active case: Magnus Teig (14 days)",
                expertSickMilestone1Time: "Week 4 (Day 28)",
                expertSickMilestone1Title: "Follow-up Plan",
                expertSickMilestone1Desc: "Must be prepared collaboratively with employee and sent to physician.",
                expertSickMilestone1Remaining: "14 days remaining",
                expertSickMilestone2Time: "Week 7 (Day 49)",
                expertSickMilestone2Title: "Dialogue Meeting 1",
                expertSickMilestone2Desc: "Mandatory meeting with manager, employee, and occupational health service.",
                expertSickMilestone2Remaining: "35 days until deadline",
                expertSelfCertRulesHeader: "SELF-CERTIFICATION & QUARANTINE RULES",
                expertSelfCertStatute: "National Insurance Act § 8-24 · Qualifying period: 2 months",
                expertSelfCertAllApprovedBadge: "All 8 employees eligible",
                expertInquirySent: "Inquiry submitted",
                expertPastCaseTitle: "Case #JUR-2024-89 · WEA § 14-6 Contract Audit",
                expertPastCaseDesc: "Verified addendum for 7 employees. BankID signature anchored in legal audit trail.",
                expertPastCaseClosed: "Closed & Archived",
                paletteSectionNav: "NAVIGATION",
                paletteSectionActions: "STATUTES & ACTIONS",
                paletteSectionEmployees: "EMPLOYEES",
                paletteSectionYears: "TIME TRAVEL (SCENARIO)",
                narrationSteps: [
                    LocalizedNarrationStep(
                        title: "Chapter 1: Kickoff & File Ingest (2024 · 8 employees)",
                        body: "Fjord Dynamics keeps contracts in Mac folders. Comply cleans up the mess in 30 seconds via drag-and-drop."
                    ),
                    LocalizedNarrationStep(
                        title: "Automated Non-Compliance Audit (WEA § 14-6)",
                        body: "Comply detects that 7 of 8 contracts contain unlawful overtime clauses under new legislation effective July 1, 2024."
                    ),
                    LocalizedNarrationStep(
                        title: "Mandatory Safety Representative (WEA § 6-1)",
                        body: "The threshold was lowered to 5 employees. Comply runs a neutral digital election and files the statutory minutes."
                    ),
                    LocalizedNarrationStep(
                        title: "Chapter 2: Scaling & Equal Pay Audit (2025 · 38 employees)",
                        body: "At 20+ employees, § 26 requires a biennial pay transparency audit. Comply processes payroll data automatically."
                    ),
                    LocalizedNarrationStep(
                        title: "Day 14 Sick Leave: Follow-Up & Dialog Meeting",
                        body: "Comply prevents forfeiture of sickness benefit reimbursement by generating an accommodation plan for Morten Dahl."
                    ),
                    LocalizedNarrationStep(
                        title: "Chapter 3: Established Company (2027 · 124 employees)",
                        body: "Eliminates 396k procedural risks in dismissals (WEA § 15-1). 1-click encrypted handoff to Simployer Expert attorneys."
                    ),
                    LocalizedNarrationStep(
                        title: "Simployer Comply: Always legally compliant. Without reading the law.",
                        body: "Proactive compliance integrated natively into everyday macOS workflows. Zero manual monitoring, zero legal surprises."
                    )
                ],
                scenarios: [
                    .y2024: LocalizedScenarioContent(
                        stageName: "The Seedling (Kickoff & Chaos)",
                        tagline: "8 employees · Google Drive chaos · CEO handles everything",
                        primaryRisk: "Missing safety representative (threshold lowered to 5) + 8 non-compliant contracts (§ 14-6)",
                        triggerTitle: "Statutory Safety Representative Missing",
                        triggerStatute: "WEA § 6-1 (Requirement from Jan 1, 2024)",
                        triggerDescription: "Safety representative requirement was lowered from 10 to 5 employees. Fjord Dynamics has 8 staff and no safety rep.",
                        triggerConsequence: "Labor Inspection Authority issues remediation order or daily coercive fines.",
                        triggerActionLabel: "Start digital safety representative election",
                        upsellProduct: "Simployer Learn",
                        upsellTitle: "Mandatory HSE course for Managing Director + 40h Safety Rep training",
                        upsellPrice: "1,490 NOK per course",
                        upsellBenefit: "Ensures certified training diploma filed directly in Comply."
                    ),
                    .y2025: LocalizedScenarioContent(
                        stageName: "The Scale-Up (Growth & Threshold Radar)",
                        tagline: "38 employees · Camilla hired as solo HR · Tripletex sync",
                        primaryRisk: "Equal pay audit requirement (§ 26) + Day 14 Sick leave follow-up",
                        triggerTitle: "Equal Pay Audit required at 20+ employees",
                        triggerStatute: "Equality and Anti-Discrimination Act § 26",
                        triggerDescription: "With 38 employees, the company is required to map gender wage differentials within role categories.",
                        triggerConsequence: "Reporting deficiencies in annual report trigger investigation by Anti-Discrimination Tribunal.",
                        triggerActionLabel: "Run automated wage gap analysis",
                        upsellProduct: "Simployer Equal Pay + One Core",
                        upsellTitle: "Automated Equal Pay Report & Full HRM System",
                        upsellPrice: "79 NOK / employee / mo",
                        upsellBenefit: "Upgrades directory to full absence and vacation management without manual migration."
                    ),
                    .y2027: LocalizedScenarioContent(
                        stageName: "The Established Force (Scale & Legal Desk)",
                        tagline: "124 employees · Simployer One operational · Statutory Whistleblowing Channel",
                        primaryRisk: "Decentralized managers handle dismissals (High risk of 396k procedural invalidation)",
                        triggerTitle: "Procedural defect in dismissal case (§ 15-1)",
                        triggerStatute: "Working Environment Act Chapter 15",
                        triggerDescription: "Bergen branch manager seeks to terminate an employee for performance deficiency without formal consultation.",
                        triggerConsequence: "Norwegian courts routinely void dismissals with procedural defects (median loss 396,000 NOK + legal fees).",
                        triggerActionLabel: "Activate Simployer Legal Counsel before meeting",
                        upsellProduct: "Simployer Expert Retainer",
                        upsellTitle: "Unlimited employment attorney advisory & liability indemnity",
                        upsellPrice: "3,990 NOK / mo",
                        upsellBenefit: "Certified labor attorneys review pre-dismissal consultations with full professional indemnity."
                    )
                ]
            )
        }
    }
}

// MARK: - Reusable Language Switcher Dropdown Menu
public struct LanguageSwitcherView: View {
    @Binding var currentLanguage: AppLanguage
    var onChange: ((AppLanguage) -> Void)? = nil
    
    public init(currentLanguage: Binding<AppLanguage>, onChange: ((AppLanguage) -> Void)? = nil) {
        self._currentLanguage = currentLanguage
        self.onChange = onChange
    }
    
    public var body: some View {
        Menu {
            ForEach(AppLanguage.allCases) { lang in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentLanguage = lang
                        onChange?(lang)
                    }
                } label: {
                    HStack {
                        Text("\(lang.code) — \(lang.displayName)")
                        if currentLanguage == lang {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "globe")
                    .font(.inter(11))
                Text(currentLanguage.code)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.inter(7))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(SolTokens.paper200)
            .foregroundColor(SolTokens.ink600)
            .cornerRadius(7)
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(SolTokens.paper300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
    }
}
