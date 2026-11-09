import SwiftUI

struct AgentLogView: View {
    @EnvironmentObject var store: ComplyStore
    @State private var selectedCategory: String = "all"
    @State private var expandedEventId: String? = nil
    
    private var filteredEvents: [AgentEvent] {
        if selectedCategory == "all" {
            return store.agentEvents
        }
        return store.agentEvents.filter { $0.category.rawValue == selectedCategory }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header & ROI Pulse Counter
                agentLogHeader
                
                // Executive 3-Stat Counter
                executiveRoiSummaryCards
                
                // Category Filter Bar
                categoryFilterBar
                
                // Event Stream List
                eventStreamList
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .background(SolTokens.paper50)
    }
    
    // MARK: - Header & Definitions Heartbeat
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
            
            // Simployer Legal Cloud Definition Stamp
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11))
                    .foregroundColor(SolTokens.indigo)
                Text(store.language == .se ? "Regelverk v2026.11 · Uppdaterat idag 06:00" : "Ruleset v2026.11 · Updated today 06:00")
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
    
    // MARK: - Executive 3-Stat Counter
    private var executiveRoiSummaryCards: some View {
        HStack(spacing: 12) {
            roiStatCard(
                title: store.language == .se ? "Autonoma kontroller" : "Autonomous Sweeps",
                value: "38",
                subtitle: store.language == .se ? "Senaste idag kl. 06:00" : "Latest today at 06:00",
                icon: "shield.checkered",
                iconColor: SolTokens.indigo
            )
            
            roiStatCard(
                title: store.language == .se ? "Sanktionsrisker" : "Statutory Fines Avoided",
                value: "0 kr",
                subtitle: store.language == .se ? "Förhindrade i bakgrunden" : "Prevented autonomously",
                icon: "checkmark.shield.fill",
                iconColor: SolTokens.green800
            )
            
            roiStatCard(
                title: store.language == .se ? "Mänskliga beslut" : "Decisions Required",
                value: "\(store.pendingActionCount)",
                subtitle: store.language == .se ? "Kräver BankID-signering" : "Requires BankID authorization",
                icon: "signature",
                iconColor: store.pendingActionCount > 0 ? SolTokens.red700 : SolTokens.green800
            )
        }
    }
    
    private func roiStatCard(title: String, value: String, subtitle: String, icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.inter(11, .medium))
                    .foregroundColor(SolTokens.ink600)
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(iconColor)
            }
            
            Text(value)
                .font(.inter(22, .bold))
                .foregroundColor(SolTokens.ink900)
            
            Text(subtitle)
                .font(.inter(11))
                .foregroundColor(SolTokens.ink450)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SolTokens.paper100)
        .cornerRadius(9)
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    // MARK: - Category Filter Bar
    private var categoryFilterBar: some View {
        HStack(spacing: 8) {
            filterPill(id: "all", label: store.language == .se ? "Alla händelser" : "All events", count: store.agentEvents.count)
            filterPill(id: "sweep", label: store.language == .se ? "Autonoma svep" : "Routine sweeps", count: store.agentEvents.filter { $0.category == .sweep }.count)
            filterPill(id: "definitions", label: store.language == .se ? "Regeluppdateringar" : "Rule updates", count: store.agentEvents.filter { $0.category == .definitions }.count)
            filterPill(id: "ingestion", label: store.language == .se ? "Filinläsningar" : "File ingestion", count: store.agentEvents.filter { $0.category == .ingestion }.count)
            filterPill(id: "signature", label: store.language == .se ? "BankID-signeringar" : "BankID approvals", count: store.agentEvents.filter { $0.category == .signature }.count)
            
            Spacer()
        }
    }
    
    private func filterPill(id: String, label: String, count: Int) -> some View {
        let isSelected = selectedCategory == id
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedCategory = id
            }
        } label: {
            HStack(spacing: 6) {
                Text(label)
                    .font(.inter(11.5, isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? SolTokens.ink900 : SolTokens.ink600)
                
                Text("\(count)")
                    .font(.inter(10, .semibold))
                    .foregroundColor(isSelected ? SolTokens.indigo : SolTokens.ink450)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isSelected ? SolTokens.indigo.opacity(0.15) : SolTokens.paper200)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 5.5)
            .background(isSelected ? SolTokens.paper200 : SolTokens.paper100)
            .cornerRadius(7)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(isSelected ? SolTokens.paper300.opacity(1.5) : SolTokens.paper300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Event Stream List
    private var eventStreamList: some View {
        VStack(spacing: 8) {
            ForEach(filteredEvents) { event in
                agentEventRow(event)
            }
        }
    }
    
    private func agentEventRow(_ event: AgentEvent) -> some View {
        let isExpanded = expandedEventId == event.id
        
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    if expandedEventId == event.id {
                        expandedEventId = nil
                    } else {
                        expandedEventId = event.id
                    }
                }
            } label: {
                HStack(alignment: .center, spacing: 14) {
                    // Category Icon Capsule
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(SolTokens.paper200)
                            .frame(width: 30, height: 30)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                        
                        Image(systemName: event.category.icon)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(iconColorForCategory(event.category))
                    }
                    
                    // Title & Description
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(event.title)
                                .font(.inter(13, .semibold))
                                .foregroundColor(SolTokens.ink900)
                            
                            if let statute = event.statute {
                                Text(statute)
                                    .font(.inter(10, .medium))
                                    .foregroundColor(SolTokens.ink600)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 1.5)
                                    .background(SolTokens.paper200)
                                    .cornerRadius(4)
                                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 0.75))
                            }
                            
                            if event.isAutonomous {
                                Text("Autonom")
                                    .font(.inter(9.5, .semibold))
                                    .foregroundColor(SolTokens.green800)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(SolTokens.green100)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(SolTokens.greenBorder, lineWidth: 0.5))
                            }
                        }
                        
                        Text(event.description)
                            .font(.inter(12))
                            .foregroundColor(SolTokens.ink600)
                            .lineLimit(isExpanded ? nil : 1)
                    }
                    
                    Spacer()
                    
                    // Status Badge & Timestamp
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(event.statusBadge)
                            .font(.inter(10.5, .medium))
                            .foregroundColor(SolTokens.ink700)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(SolTokens.paper200)
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(SolTokens.paper300, lineWidth: 0.75))
                        
                        Text(event.timestampString)
                            .font(.inter(10.5))
                            .foregroundColor(SolTokens.ink450)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(SolTokens.ink450)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
            }
            .buttonStyle(.plain)
            
            // Expanded Detail Drawer (Audit Hash & Payload Verification)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().background(SolTokens.paper300)
                    
                    HStack(spacing: 16) {
                        if let entity = event.affectedEntity {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.language == .se ? "MÅL / ENHET" : "TARGET ENTITY")
                                    .font(.inter(9.5, .semibold))
                                    .foregroundColor(SolTokens.ink450)
                                Text(entity)
                                    .font(.inter(11.5, .medium))
                                    .foregroundColor(SolTokens.ink800)
                            }
                        }
                        
                        if let hash = event.auditHash {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.language == .se ? "REVISIONSHASH" : "AUDIT HASH")
                                    .font(.inter(9.5, .semibold))
                                    .foregroundColor(SolTokens.ink450)
                                Text(hash)
                                    .font(.inter(11, .regular))
                                    .foregroundColor(SolTokens.indigo)
                            }
                        }
                        
                        Spacer()
                        
                        Text("Verifierad av Simployer Legal Engine")
                            .font(.inter(10.5, .medium))
                            .foregroundColor(SolTokens.ink600)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
                .background(SolTokens.paper100)
            }
        }
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    private func iconColorForCategory(_ category: AgentEventCategory) -> Color {
        switch category {
        case .sweep: return SolTokens.indigo
        case .definitions: return SolTokens.amber400
        case .ingestion: return SolTokens.ink700
        case .guardrail: return SolTokens.green800
        case .signature: return SolTokens.indigo
        }
    }
}
