import SwiftUI
import AppKit

struct AgentLogView: View {
    @EnvironmentObject var store: ComplyStore
    @State private var selectedCategory: String = "all"
    @State private var searchQuery: String = ""
    @State private var expandedEventId: String? = nil
    @State private var showExportToast: Bool = false
    @State private var copiedHashEventId: String? = nil
    
    // MARK: - Filtered Events
    private var filteredEvents: [AgentEvent] {
        let events: [AgentEvent]
        switch selectedCategory {
        case "all":
            events = store.agentEvents
        case "guardrail":
            events = store.agentEvents.filter { $0.category == .guardrail || $0.category == .sweep }
        case "definitions":
            events = store.agentEvents.filter { $0.category == .definitions }
        case "signature":
            events = store.agentEvents.filter { $0.category == .signature }
        case "ingestion":
            events = store.agentEvents.filter { $0.category == .ingestion }
        default:
            events = store.agentEvents
        }
        
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return events }
        
        return events.filter { event in
            event.title.localizedCaseInsensitiveContains(query) ||
            event.description.localizedCaseInsensitiveContains(query) ||
            (event.statute?.localizedCaseInsensitiveContains(query) ?? false) ||
            (event.affectedEntity?.localizedCaseInsensitiveContains(query) ?? false) ||
            (event.auditHash?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    // MARK: - Chronological Grouping
    struct EventDateGroup: Identifiable {
        let id: String
        let title: String
        let events: [AgentEvent]
    }
    
    private var groupedEvents: [EventDateGroup] {
        var today: [AgentEvent] = []
        var yesterday: [AgentEvent] = []
        var earlierThisMonth: [AgentEvent] = []
        var older: [AgentEvent] = []
        
        for event in filteredEvents {
            let ts = event.timestampString.lowercased()
            if ts.contains("idag") || ts.contains("today") || ts.contains("i dag") {
                today.append(event)
            } else if ts.contains("igår") || ts.contains("yesterday") || ts.contains("i går") {
                yesterday.append(event)
            } else if ts.contains("nov") {
                earlierThisMonth.append(event)
            } else {
                older.append(event)
            }
        }
        
        var groups: [EventDateGroup] = []
        if !today.isEmpty {
            groups.append(EventDateGroup(
                id: "today",
                title: store.language == .se ? "IDAG" : (store.language == .no ? "I DAG" : "TODAY"),
                events: today
            ))
        }
        if !yesterday.isEmpty {
            groups.append(EventDateGroup(
                id: "yesterday",
                title: store.language == .se ? "IGÅR" : (store.language == .no ? "I GÅR" : "YESTERDAY"),
                events: yesterday
            ))
        }
        if !earlierThisMonth.isEmpty {
            groups.append(EventDateGroup(
                id: "earlier",
                title: store.language == .se ? "TIDIGARE I NOVEMBER" : (store.language == .no ? "TIDLIGERE I NOVEMBER" : "EARLIER THIS MONTH"),
                events: earlierThisMonth
            ))
        }
        if !older.isEmpty {
            groups.append(EventDateGroup(
                id: "older",
                title: store.language == .se ? "OKTOBER 2026" : (store.language == .no ? "OKTOBER 2026" : "OCTOBER 2026"),
                events: older
            ))
        }
        return groups
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header & Export Actions
                agentLogHeader
                
                // Export confirmation banner (transient toast)
                if showExportToast {
                    exportConfirmationBanner
                }
                
                // Search & Category Filter Toolbar
                filterAndSearchToolbar
                
                // Chronological Event Groups (Unified Ledger Containers)
                if groupedEvents.isEmpty {
                    emptyLogStateView
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(groupedEvents) { group in
                            eventGroupSection(group)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .background(SolTokens.paper50)
    }
    
    // MARK: - Header & Definitions Stamp
    private var agentLogHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(store.language == .se ? "Aktivitet & Skyddslogg" : (store.language == .no ? "Aktivitet & Beskyttelseslogg" : "Activity & Protection Log"))
                        .font(.inter(18, .bold))
                        .foregroundColor(SolTokens.ink900)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(SolTokens.green800)
                            .frame(width: 6, height: 6)
                        Text(store.language == .se ? "Aktivt realtidsskydd" : (store.language == .no ? "Aktiv sanntidsbeskyttelse" : "Active Real-Time Protection"))
                            .font(.inter(11, .medium))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(SolTokens.green100)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(SolTokens.greenBorder, lineWidth: 1))
                }
                
                Text(store.language == .se ? 
                     "Simployer Comply arbetar autonomt i bakgrunden. Här loggas alla regelvalideringar, källändringar och skyddsåtgärder med kryptografisk spårbarhet." : 
                     (store.language == .no 
                      ? "Simployer Comply arbeider autonomt i bakgrunnen. Her logges alle regelvalideringer, kildeendringer og beskyttelsestiltak med kryptografisk sporbarhet."
                      : "Simployer Comply operates autonomously in the background. Every rule validation, file sweep, and remediation is logged with cryptographic audit trails."))
                    .font(.inter(12.5))
                    .foregroundColor(SolTokens.ink600)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // Regulatory Audit Export Button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showExportToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        withAnimation {
                            showExportToast = false
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 11, weight: .medium))
                        Text(store.language == .se ? "Exportera tillsynslogg (PDF)" : (store.language == .no ? "Eksporter tilsynslogg (PDF)" : "Export Regulatory Audit Log (PDF)"))
                            .font(.inter(11, .medium))
                    }
                    .foregroundColor(SolTokens.ink800)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .background(SolTokens.paper100)
                    .cornerRadius(7)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
                
                // Simployer Legal Cloud Definition Stamp
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.indigo)
                    Text(store.language == .se ? "Regelverk v2026.11 · Uppdaterat idag 06:00" : (store.language == .no ? "Regelverk v2026.11 · Oppdatert i dag 06:00" : "Ruleset v2026.11 · Updated today 06:00"))
                        .font(.inter(11, .medium))
                        .foregroundColor(SolTokens.ink700)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(SolTokens.paper100)
                .cornerRadius(7)
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(SolTokens.paper300, lineWidth: 1))
            }
        }
    }
    
    // MARK: - Export Confirmation Banner
    private var exportConfirmationBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(SolTokens.green800)
                .font(.system(size: 13))
            
            Text(store.language == .se ? 
                 "Kryptografiskt signerad tillsynslogg (SHA-256) genererad för Arbeidstilsynet · Sparad i Dokument" : 
                 (store.language == .no ? 
                  "Kryptografisk signert tilsynslogg (SHA-256) generert for Arbeidstilsynet · Lagret i Dokumenter" : 
                  "Cryptographically signed audit log (SHA-256) generated for regulatory review · Saved to Documents"))
                .font(.inter(12, .medium))
                .foregroundColor(SolTokens.ink800)
            
            Spacer()
            
            Button {
                withAnimation { showExportToast = false }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(SolTokens.ink450)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(SolTokens.green100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.greenBorder, lineWidth: 1))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Search & Category Filter Toolbar
    private var filterAndSearchToolbar: some View {
        HStack(spacing: 12) {
            // Category Filter Pills
            HStack(spacing: 6) {
                filterPill(
                    id: "all", 
                    label: store.language == .se ? "Alla" : (store.language == .no ? "Alle" : "All"), 
                    count: store.agentEvents.count
                )
                filterPill(
                    id: "guardrail", 
                    label: store.language == .se ? "Lagkontroller" : (store.language == .no ? "Lovkontroller" : "Statutory checks"), 
                    count: store.agentEvents.filter { $0.category == .guardrail || $0.category == .sweep }.count
                )
                filterPill(
                    id: "definitions", 
                    label: store.language == .se ? "Regeluppdateringar" : (store.language == .no ? "Regeloppdateringer" : "Rule updates"), 
                    count: store.agentEvents.filter { $0.category == .definitions }.count
                )
                filterPill(
                    id: "ingestion", 
                    label: store.language == .se ? "Källsynk" : (store.language == .no ? "Kildesynk" : "Source sync"), 
                    count: store.agentEvents.filter { $0.category == .ingestion }.count
                )
                filterPill(
                    id: "signature", 
                    label: store.language == .se ? "BankID & Avtal" : (store.language == .no ? "BankID & Avtaler" : "BankID approvals"), 
                    count: store.agentEvents.filter { $0.category == .signature }.count
                )
            }
            
            Spacer()
            
            // Search Input
            HStack(spacing: 7) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(SolTokens.ink450)
                
                TextField(
                    store.language == .se ? "Sök i loggen..." : (store.language == .no ? "Søk i loggen..." : "Search log..."),
                    text: $searchQuery
                )
                .textFieldStyle(.plain)
                .font(.inter(11.5))
                .foregroundColor(SolTokens.ink900)
                
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
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
            .frame(width: 210)
            .background(SolTokens.paper100)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
        }
    }
    
    private func filterPill(id: String, label: String, count: Int) -> some View {
        let isSelected = selectedCategory == id
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedCategory = id
            }
        } label: {
            HStack(spacing: 5) {
                Text(label)
                    .font(.inter(11.5, isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? SolTokens.ink900 : SolTokens.ink600)
                
                Text("\(count)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? SolTokens.indigo : SolTokens.ink450)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isSelected ? SolTokens.indigo.opacity(0.14) : SolTokens.paper200)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
            .background(isSelected ? SolTokens.paper200 : SolTokens.paper100)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? SolTokens.paper400 : SolTokens.paper300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Event Group Section (Date-Grouped Ledger Container)
    private func eventGroupSection(_ group: EventDateGroup) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(group.title)
                .font(.inter(10, .bold))
                .tracking(0.7)
                .foregroundColor(SolTokens.ink450)
                .padding(.horizontal, 2)
            
            // Unified Ledger Container
            VStack(spacing: 0) {
                ForEach(Array(group.events.enumerated()), id: \.element.id) { index, event in
                    eventRow(event)
                    
                    if index < group.events.count - 1 {
                        Divider()
                            .overlay(SolTokens.paper300.opacity(0.6))
                    }
                }
            }
            .background(SolTokens.paper100)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
        }
    }
    
    // MARK: - Event Row (Authentic Activity Log Entry)
    private func eventRow(_ event: AgentEvent) -> some View {
        let isExpanded = expandedEventId == event.id
        let timeInfo = formattedTime(from: event.timestampString)
        
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    expandedEventId = (isExpanded ? nil : event.id)
                }
            } label: {
                HStack(alignment: .center, spacing: 14) {
                    // 1. Leading Timestamp & Date Hint Column
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(timeInfo.time)
                            .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(SolTokens.ink700)
                        
                        if let dateHint = timeInfo.dateHint {
                            Text(dateHint)
                                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                    }
                    .frame(width: 52, alignment: .trailing)
                    
                    // 2. Subtle Category Indicator Dot
                    Circle()
                        .fill(categoryColor(event.category))
                        .frame(width: 6.5, height: 6.5)
                        .padding(.horizontal, 2)
                    
                    // 3. Event Description & Meta
                    VStack(alignment: .leading, spacing: 2.5) {
                        HStack(spacing: 7) {
                            Text(event.title)
                                .font(.inter(12.5, .semibold))
                                .foregroundColor(SolTokens.ink900)
                            
                            if let statute = event.statute {
                                Text(statute)
                                    .font(.inter(10, .medium))
                                    .foregroundColor(SolTokens.ink600)
                                    .padding(.horizontal, 5.5)
                                    .padding(.vertical, 1)
                                    .background(SolTokens.paper200)
                                    .cornerRadius(4)
                                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 0.75))
                            }
                            
                            if event.isAutonomous {
                                Text(store.language == .se ? "Autonom" : (store.language == .no ? "Autonom" : "Autonomous"))
                                    .font(.inter(9.5, .medium))
                                    .foregroundColor(SolTokens.green800)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(SolTokens.green100)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text(event.description)
                            .font(.inter(11.5))
                            .foregroundColor(SolTokens.ink600)
                            .lineLimit(isExpanded ? nil : 1)
                    }
                    
                    Spacer(minLength: 16)
                    
                    // 4. Quiet Outcome Text & Cryptographic Hash Hint
                    HStack(spacing: 12) {
                        statusOutcomeLabel(for: event)
                        
                        if let hash = event.auditHash {
                            Text(shortHash(hash))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(SolTokens.ink450)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8.5, weight: .semibold))
                            .foregroundColor(SolTokens.ink450)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // 5. In-Place Forensic Inspection Drawer
            if isExpanded {
                forensicInspectionDrawer(for: event)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Quiet Status Outcome Label (Replaces Heavy Bordered Pills)
    private func statusOutcomeLabel(for event: AgentEvent) -> some View {
        let isTransferred = event.statusBadge.contains("Överfört") || event.statusBadge.contains("Overført") || event.statusBadge.contains("Transferred") || event.statusBadge.contains("signering")
        let isSigned = event.statusBadge.contains("Signerat") || event.statusBadge.contains("Signert") || event.statusBadge.contains("Signed")
        let isRule = event.statusBadge.contains("Regelverk") || event.statusBadge.contains("Uppdaterat") || event.statusBadge.contains("Ruleset") || event.statusBadge.contains("Synkroniserat")
        
        let text: String
        let color: Color
        let icon: String?
        
        if isSigned {
            text = store.language == .se ? "Signerat" : (store.language == .no ? "Signert" : "Signed")
            color = SolTokens.plum900
            icon = "checkmark.seal.fill"
        } else if isTransferred {
            text = store.language == .se ? "Överfört" : (store.language == .no ? "Overført" : "Transferred")
            color = SolTokens.indigo
            icon = "arrow.right.circle"
        } else if isRule {
            text = store.language == .se ? "Aktivt" : (store.language == .no ? "Aktivt" : "Active")
            color = SolTokens.amber400
            icon = "sparkles"
        } else {
            text = store.language == .se ? "Verifierat" : (store.language == .no ? "Verifisert" : "Verified")
            color = SolTokens.green800
            icon = "checkmark"
        }
        
        return HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 8.5, weight: .bold))
            }
            Text(text)
                .font(.inter(11, .medium))
        }
        .foregroundColor(color)
    }
    
    // MARK: - In-Place Forensic Inspection Drawer
    private func forensicInspectionDrawer(for event: AgentEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()
                .overlay(SolTokens.paper300)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 24) {
                    // Column 1: Aktor & Metod
                    VStack(alignment: .leading, spacing: 2.5) {
                        Text(store.language == .se ? "AKTOR / MOTOR" : (store.language == .no ? "AKTOR / MOTOR" : "ACTOR / ENGINE"))
                            .font(.inter(9, .bold))
                            .tracking(0.5)
                            .foregroundColor(SolTokens.ink450)
                        
                        Text(event.isAutonomous ? "Simployer Autonomous Engine" : "Simployer Legal Engine")
                            .font(.inter(11, .medium))
                            .foregroundColor(SolTokens.ink800)
                    }
                    
                    // Column 2: Target Entity
                    if let entity = event.affectedEntity {
                        VStack(alignment: .leading, spacing: 2.5) {
                            Text(store.language == .se ? "MÅL / ENHET" : (store.language == .no ? "MÅL / ENHET" : "TARGET ENTITY"))
                                .font(.inter(9, .bold))
                                .tracking(0.5)
                                .foregroundColor(SolTokens.ink450)
                            
                            Text(entity)
                                .font(.inter(11, .medium))
                                .foregroundColor(SolTokens.ink800)
                        }
                    }
                    
                    // Column 3: Cryptographic Audit Hash
                    if let hash = event.auditHash {
                        VStack(alignment: .leading, spacing: 2.5) {
                            Text(store.language == .se ? "REVISIONS-HASH (SHA-256)" : (store.language == .no ? "REVISJONS-HASH (SHA-256)" : "AUDIT TRAIL HASH"))
                                .font(.inter(9, .bold))
                                .tracking(0.5)
                                .foregroundColor(SolTokens.ink450)
                            
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(hash, forType: .string)
                                withAnimation {
                                    copiedHashEventId = event.id
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        if copiedHashEventId == event.id {
                                            copiedHashEventId = nil
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(hash)
                                        .font(.system(size: 10.5, design: .monospaced))
                                        .foregroundColor(SolTokens.indigo)
                                    
                                    Image(systemName: copiedHashEventId == event.id ? "checkmark" : "doc.on.doc")
                                        .font(.system(size: 9))
                                        .foregroundColor(copiedHashEventId == event.id ? SolTokens.green800 : SolTokens.ink450)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Spacer()
                    
                    // Direct navigation link if transferred to Action Hub
                    let isTransferred = event.statusBadge.contains("Överfört") || event.statusBadge.contains("Overført") || event.statusBadge.contains("Transferred") || event.statusBadge.contains("signering")
                    if isTransferred && store.pendingActionCount > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                store.activeNav = "hub"
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(store.language == .se ? "Öppna i Handlingscenter" : (store.language == .no ? "Åpne i Handlingssenter" : "Open in Action Hub"))
                                    .font(.inter(11, .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(SolTokens.plum900)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(SolTokens.paper200)
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 4)
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .background(SolTokens.paper200.opacity(0.35))
    }
    
    // MARK: - Empty State
    private var emptyLogStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 26))
                .foregroundColor(SolTokens.ink450)
                .padding(.top, 40)
            
            Text(store.language == .se ? "Inga logghändelser matchar sökningen" : (store.language == .no ? "Ingen hendelser samsvarer med søket" : "No log events match search"))
                .font(.inter(13, .medium))
                .foregroundColor(SolTokens.ink700)
            
            Button {
                selectedCategory = "all"
                searchQuery = ""
            } label: {
                Text(store.language == .se ? "Återställ filter" : (store.language == .no ? "Tilbakestill filter" : "Reset filter"))
                    .font(.inter(11.5, .semibold))
                    .foregroundColor(SolTokens.lav400)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    // MARK: - Helpers
    private func formattedTime(from timestamp: String) -> (time: String, dateHint: String?) {
        if timestamp.contains("kl. ") {
            let parts = timestamp.components(separatedBy: "kl. ")
            let timePart = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : timestamp
            let leading = parts[0].trimmingCharacters(in: .whitespaces)
            let lower = leading.lowercased()
            if lower.contains("idag") || lower.contains("igår") || lower.contains("today") || lower.contains("yesterday") || lower.contains("i dag") || lower.contains("i går") {
                return (timePart, nil)
            } else {
                return (timePart, leading.isEmpty ? nil : leading)
            }
        }
        return (timestamp, nil)
    }
    
    private func shortHash(_ hash: String) -> String {
        if hash.hasPrefix("SHA-256: ") {
            return String(hash.dropFirst(9))
        }
        return hash
    }
    
    private func categoryColor(_ category: AgentEventCategory) -> Color {
        switch category {
        case .sweep: return SolTokens.indigo
        case .definitions: return SolTokens.amber400
        case .ingestion: return SolTokens.ink600
        case .guardrail: return SolTokens.green800
        case .signature: return SolTokens.plum900
        }
    }
}
