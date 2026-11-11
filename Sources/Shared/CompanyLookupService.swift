import Foundation

public struct RegisteredCompany: Identifiable, Codable, Hashable, Sendable {
    public var id: String { orgNumber }
    public let orgNumber: String
    public let name: String
    public let legalForm: String
    public let ceoName: String
    public let employeeCount: Int
    public let naceCode: String
    public let naceDescription: String
    public let municipality: String
    public let hasTariffAgreement: Bool?
    
    public init(
        orgNumber: String,
        name: String,
        legalForm: String = "Aksjeselskap (AS)",
        ceoName: String = "Jonas Berg",
        employeeCount: Int = 8,
        naceCode: String = "62.010",
        naceDescription: String = "Dataprogrammering",
        municipality: String = "Oslo",
        hasTariffAgreement: Bool? = false
    ) {
        self.orgNumber = orgNumber
        self.name = name
        self.legalForm = legalForm
        self.ceoName = ceoName
        self.employeeCount = employeeCount
        self.naceCode = naceCode
        self.naceDescription = naceDescription
        self.municipality = municipality
        self.hasTariffAgreement = hasTariffAgreement
    }
}

public struct StatutoryObligation: Identifiable, Hashable, Sendable {
    public var id: String { code }
    public let code: String
    public let title: String
    public let statute: String
    public let explanation: String
    public let isMandatory: Bool
    public let severity: String // red, amber, blue
}

public actor CompanyLookupService {
    public static let shared = CompanyLookupService()
    
    // Default demo profile for Friday presentation
    public static let demoCompany = RegisteredCompany(
        orgNumber: "923456789",
        name: "Fjord Dynamics AS",
        legalForm: "Aksjeselskap (AS)",
        ceoName: "Jonas Berg",
        employeeCount: 8,
        naceCode: "62.010",
        naceDescription: "Dataprogrammering & systemutvikling",
        municipality: "Oslo",
        hasTariffAgreement: false
    )
    
    // Offline pre-cached profiles
    private let offlinePresets: [String: RegisteredCompany] = [
        "923456789": demoCompany,
        "986419454": RegisteredCompany(
            orgNumber: "986419454",
            name: "SIMPLOYER AS",
            legalForm: "Aksjeselskap (AS)",
            ceoName: "Vigleik Takle",
            employeeCount: 111,
            naceCode: "58.290",
            naceDescription: "Utgivelse av programvare",
            municipality: "Oslo",
            hasTariffAgreement: true
        ),
        "921829205": RegisteredCompany(
            orgNumber: "921829205",
            name: "SIMPLOYER AB",
            legalForm: "Utenlandsk enhet",
            ceoName: "Carl-Johan Hamilton",
            employeeCount: 35,
            naceCode: "62.020",
            naceDescription: "Konsulentvirksomhet innen IT",
            municipality: "Sarpsborg",
            hasTariffAgreement: true
        )
    ]
    
    /// Queries the Norwegian Government Brønnøysund Open Data API
    public func lookup(query: String) async -> [RegisteredCompany] {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
        guard !clean.isEmpty else { return [Self.demoCompany] }
        
        // Check offline presets first
        if let preset = offlinePresets[clean] {
            return [preset]
        }
        
        // If clean is exactly 9 digits, query direct enhet endpoint
        let isOrgNr = clean.count == 9 && clean.allSatisfy { $0.isNumber }
        let urlString: String
        if isOrgNr {
            urlString = "https://data.brreg.no/enhetsregisteret/api/enheter/\(clean)"
        } else {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            urlString = "https://data.brreg.no/enhetsregisteret/api/enheter?navn=\(encoded)&size=5"
        }
        
        guard let url = URL(string: urlString) else {
            return searchLocalFallback(query: query)
        }
        
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 3.5
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return searchLocalFallback(query: query)
            }
            
            if isOrgNr {
                if let parsed = try? parseSingleEnhet(data: data) {
                    return [parsed]
                }
            } else {
                let parsedList = parseEnhetList(data: data)
                if !parsedList.isEmpty {
                    return parsedList
                }
            }
        } catch {
            // Silently fall back to local mock
        }
        
        return searchLocalFallback(query: query)
    }
    
    private func searchLocalFallback(query: String) -> [RegisteredCompany] {
        let q = query.lowercased()
        let matches = offlinePresets.values.filter {
            $0.orgNumber.contains(q) || $0.name.lowercased().contains(q)
        }
        return matches.isEmpty ? [Self.demoCompany] : Array(matches)
    }
    
    private func parseSingleEnhet(data: Data) throws -> RegisteredCompany? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let orgNr = json["organisasjonsnummer"] as? String ?? ""
        let navn = json["navn"] as? String ?? "Ukjent Selskap"
        let orgForm = (json["organisasjonsform"] as? [String: Any])?["beskrivelse"] as? String ?? "Aksjeselskap (AS)"
        let ansatte = json["antallAnsatte"] as? Int ?? 8
        let nace = json["naeringskode1"] as? [String: Any]
        let naceKode = nace?["kode"] as? String ?? "62.010"
        let naceBeskrivelse = nace?["beskrivelse"] as? String ?? "Bedriftsvirksomhet"
        let poststed = (json["forretningsadresse"] as? [String: Any])?["poststed"] as? String ?? "Oslo"
        
        return RegisteredCompany(
            orgNumber: orgNr,
            name: navn,
            legalForm: orgForm,
            ceoName: "Jonas Berg",
            employeeCount: ansatte,
            naceCode: naceKode,
            naceDescription: naceBeskrivelse,
            municipality: poststed,
            hasTariffAgreement: false
        )
    }
    
    private func parseEnhetList(data: Data) -> [RegisteredCompany] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let embedded = json["_embedded"] as? [String: Any],
              let enheter = embedded["enheter"] as? [[String: Any]] else {
            return []
        }
        
        return enheter.compactMap { item -> RegisteredCompany? in
            guard let orgNr = item["organisasjonsnummer"] as? String,
                  let navn = item["navn"] as? String else { return nil }
            let orgForm = (item["organisasjonsform"] as? [String: Any])?["beskrivelse"] as? String ?? "AS"
            let ansatte = item["antallAnsatte"] as? Int ?? 5
            let nace = item["naeringskode1"] as? [String: Any]
            let naceKode = nace?["kode"] as? String ?? "62.010"
            let naceBeskrivelse = nace?["beskrivelse"] as? String ?? "Bedriftstjenester"
            let poststed = (item["forretningsadresse"] as? [String: Any])?["poststed"] as? String ?? "Norge"
            
            return RegisteredCompany(
                orgNumber: orgNr,
                name: navn,
                legalForm: orgForm,
                ceoName: "Leder",
                employeeCount: ansatte,
                naceCode: naceKode,
                naceDescription: naceBeskrivelse,
                municipality: poststed,
                hasTariffAgreement: false
            )
        }
    }
    
    /// Derives active statutory rules from headcount and industry with full localization
    public static func deriveStatutoryObligations(
        for company: RegisteredCompany,
        language: AppLanguage = .no,
        hasTariffAgreement: Bool = false
    ) -> [StatutoryObligation] {
        var rules: [StatutoryObligation] = []
        let headcount = company.employeeCount
        
        switch language {
        case .no:
            // Universal 1: Standard Written Contracts (AML § 14-6)
            let contractExplanation = hasTariffAgreement
                ? "Tariffavtale fordrer 37,5t normalarbeidsuke, 5 ferieuker og henvisning til tariffpartene for alle \(headcount) ansatte."
                : "Oppdaterte EU-krav til 40t standarduke, lovbestemt overtid og kompetanserettigheter for alle \(headcount) ansatte."
            rules.append(StatutoryObligation(
                code: "contracts",
                title: "Lovpålagte ansettelsesavtaler",
                statute: "AML § 14-6",
                explanation: contractExplanation,
                isMandatory: true,
                severity: "red"
            ))
            
            // Universal 2: Whistleblowing Routine (AML § 2 A-6)
            rules.append(StatutoryObligation(
                code: "whistleblowing",
                title: "Varslingsrutine & Retningslinjer",
                statute: "AML § 2 A-6",
                explanation: "Obligatoriske varslingskanaler og skriftlig bekreftelse fra ansatte ved mottak av personalhåndbok.",
                isMandatory: true,
                severity: "amber"
            ))
            
            // Headcount >= 5: Mandatory Safety Representative (AML § 6-1)
            if headcount >= 5 {
                rules.append(StatutoryObligation(
                    code: "verneombud",
                    title: "Obligatorisk valg av verneombud",
                    statute: "AML § 6-1",
                    explanation: "Lovfestet terskel ble senket til 5 ansatte. Hemmelig valg blant ansatte er påkrevd.",
                    isMandatory: true,
                    severity: "red"
                ))
            }
            
            // Headcount >= 10: Mandatory CEO HSE Training (AML § 3-5)
            if headcount >= 10 {
                rules.append(StatutoryObligation(
                    code: "ceo_hse",
                    title: "Lovpålagt HMS-kurs for daglig leder",
                    statute: "AML § 3-5",
                    explanation: "Personlig plikt for \(company.ceoName) til å dokumentere fullført opplæring i helse-, miljø- og sikkerhetsarbeid.",
                    isMandatory: true,
                    severity: "amber"
                ))
            }
            
            // Headcount >= 30: Working Environment Committee / AMU (AML § 7-1)
            if headcount >= 30 {
                rules.append(StatutoryObligation(
                    code: "amu",
                    title: "Arbeidsmiljøutvalg (AMU)",
                    statute: "AML § 7-1",
                    explanation: "Terskel senket til 30 ansatte. Krav om formelt utvalg med like mange representanter fra ledelse og ansatte.",
                    isMandatory: true,
                    severity: "amber"
                ))
            }
            
            // Headcount >= 50: Equality & Gender Pay Audit (Likestillingsloven § 26)
            if headcount >= 50 {
                rules.append(StatutoryObligation(
                    code: "equal_pay",
                    title: "Lovpålagt lønnskartlegging (ARP)",
                    statute: "Likestillingsloven § 26",
                    explanation: "Plikt til å kartlegge og offentliggjøre lønnsforskjeller mellom kvinner og menn annethvert år.",
                    isMandatory: true,
                    severity: "blue"
                ))
            }
            
        case .se:
            let contractExplanation = hasTariffAgreement
                ? "Kollektivavtal kräver 37.5h veckoarbetstid, 25-30 semesterdagar och avtalsvillkor för alla \(headcount) anställda."
                : "Uppdaterade EU-krav gällande övertidskompensation, 40h standardvecka och kompetensrättigheter för samtliga \(headcount) anställda."
            rules.append(StatutoryObligation(
                code: "contracts",
                title: "Lagstadgade anställningsavtal",
                statute: "AML § 14-6 / LAS",
                explanation: contractExplanation,
                isMandatory: true,
                severity: "red"
            ))
            rules.append(StatutoryObligation(
                code: "whistleblowing",
                title: "Visselblåsarrutin & Riktlinjer",
                statute: "AML kap. 2 A / Lag (2021:890)",
                explanation: "Obligatoriska rapporteringskanaler och skriftlig bekräftelse från medarbetare vid mottagande av personalhandbok.",
                isMandatory: true,
                severity: "amber"
            ))
            if headcount >= 5 {
                rules.append(StatutoryObligation(
                    code: "verneombud",
                    title: "Obligatoriskt val av skyddsombud",
                    statute: "AML § 6-1 / AML kap. 6",
                    explanation: "Lagstadgad tröskel sänkt till 5 anställda. Hemligt val bland anställda krävs.",
                    isMandatory: true,
                    severity: "red"
                ))
            }
            if headcount >= 10 {
                rules.append(StatutoryObligation(
                    code: "ceo_hse",
                    title: "Lagstadgad arbetsmiljöutbildning för VD",
                    statute: "AML § 3-5 / SAM",
                    explanation: "Personligt ansvar för \(company.ceoName) att dokumentera genomförd utbildning i systematiskt arbetsmiljöarbete.",
                    isMandatory: true,
                    severity: "amber"
                ))
            }
            if headcount >= 30 {
                rules.append(StatutoryObligation(
                    code: "amu",
                    title: "Skyddskommitté / Arbetsmiljöutskott (AMU)",
                    statute: "AML § 7-1",
                    explanation: "Tröskel sänkt till 30 anställda. Krav på formellt utskott med representanter från företagsledning och personal.",
                    isMandatory: true,
                    severity: "amber"
                ))
            }
            if headcount >= 50 {
                rules.append(StatutoryObligation(
                    code: "equal_pay",
                    title: "Lagstadgad lönekartläggning (Diskrimineringslagen)",
                    statute: "Diskrimineringslagen 3 kap. § 8",
                    explanation: "Årlig lagstadgad plikt att kartlägga och analysera osakliga löneskillnader mellan kvinnor och män.",
                    isMandatory: true,
                    severity: "blue"
                ))
            }
            
        case .en:
            let contractExplanation = hasTariffAgreement
                ? "Collective bargaining agreement mandates 37.5h standard workweek, 5 weeks vacation, and union clauses for all \(headcount) employees."
                : "Updated EU directive clauses on 40h standard workweek, statutory overtime terms, and probation rules across all \(headcount) employees."
            rules.append(StatutoryObligation(
                code: "contracts",
                title: "Mandatory Employment Contracts",
                statute: "AML § 14-6 / EU Directive",
                explanation: contractExplanation,
                isMandatory: true,
                severity: "red"
            ))
            rules.append(StatutoryObligation(
                code: "whistleblowing",
                title: "Whistleblowing Procedures & Policies",
                statute: "AML ch. 2 A / Whistleblower Dir.",
                explanation: "Mandatory confidential reporting channels and written employee acknowledgement upon handbook distribution.",
                isMandatory: true,
                severity: "amber"
            ))
            if headcount >= 5 {
                rules.append(StatutoryObligation(
                    code: "verneombud",
                    title: "Mandatory Safety Representative Election",
                    statute: "AML § 6-1",
                    explanation: "Statutory threshold lowered to 5 employees. Secret ballot election among staff is legally required.",
                    isMandatory: true,
                    severity: "red"
                ))
            }
            if headcount >= 10 {
                rules.append(StatutoryObligation(
                    code: "ceo_hse",
                    title: "Mandatory CEO HSE Certification",
                    statute: "AML § 3-5",
                    explanation: "Personal statutory duty for \(company.ceoName) to hold verified training in occupational health and safety.",
                    isMandatory: true,
                    severity: "amber"
                ))
            }
            if headcount >= 30 {
                rules.append(StatutoryObligation(
                    code: "amu",
                    title: "Working Environment Committee (AMU)",
                    statute: "AML § 7-1",
                    explanation: "Threshold lowered to 30 staff. Formally mandated joint employer-employee committee.",
                    isMandatory: true,
                    severity: "amber"
                ))
            }
            if headcount >= 50 {
                rules.append(StatutoryObligation(
                    code: "equal_pay",
                    title: "Mandatory Gender Pay Gap Audit (ARP)",
                    statute: "Equality Act § 26",
                    explanation: "Statutory duty to audit, document, and publish gender pay disparity metrics biennially.",
                    isMandatory: true,
                    severity: "blue"
                ))
            }
        }
        
        return rules
    }
}
