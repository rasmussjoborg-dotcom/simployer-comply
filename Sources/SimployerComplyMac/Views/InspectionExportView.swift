import SwiftUI

struct InspectionExportView: View {
    @EnvironmentObject var store: ComplyStore
    @State private var selectedPack: InspectionPackType = .laborAuthority
    @State private var isGenerating: Bool = false
    @State private var downloadCompleted: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header
                headerView
                
                // Pack Selection Cards
                packSelectionCards
                
                // Pack Manifest & Contents
                packManifestView
                
                // Export & Download Bar
                exportActionBar
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 48)
        }
        .background(SolTokens.paper50)
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(store.language == .se ? "Revisions- & Tillsynspaket" : "Inspection & Audit Packages")
                    .font(.inter(18, .bold))
                    .foregroundColor(SolTokens.ink900)
                
                Text("REP-02 / CON-05")
                    .font(.inter(10, .semibold))
                    .foregroundColor(SolTokens.ink600)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(SolTokens.paper200)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
            }
            
            Text(store.language == .se ? 
                 "Generera kompletta, revisionssäkrade dokumentationspaket vid myndighetstillsyn eller investerargranskning med 1 klick." : 
                 "Generate complete, audit-proof compliance packages for labor authority inspections or investor due diligence with 1 click.")
                .font(.inter(12.5))
                .foregroundColor(SolTokens.ink600)
        }
    }
    
    // MARK: - Pack Selection Cards
    private var packSelectionCards: some View {
        HStack(spacing: 14) {
            packCard(
                type: .laborAuthority,
                title: store.language == .se ? "Arbetsmiljöverket / Arbeidstilsynet" : "Labor Authority Inspection",
                badge: store.language == .se ? "Lagstadgad tillsyn" : "Statutory Inspection",
                description: store.language == .se ? 
                    "Komplett tillsynspaket innehållande skyddsombudsprotokoll, anställningsavtal, KMA/HMS-intyg och dygnsvilologgar." :
                    "Complete audit pack including safety representative minutes, contracts, HSE certifications, and working hours logs.",
                icon: "shield.lefthalf.filled"
            )
            
            packCard(
                type: .dueDiligence,
                title: store.language == .se ? "Due Diligence (M&A & Investor)" : "Due Diligence (M&A & Investor)",
                badge: store.language == .se ? "Transaktionsklar" : "Transaction Ready",
                description: store.language == .se ? 
                    "Juridiskt underlag för förvärv, styrelse eller investerare: standardavtal, personallistor, jämställdhetskartläggning och riskbedömning." :
                    "Legal package for acquisitions, board or investors: employment templates, employee rosters, equal-pay audits, and risk logs.",
                icon: "briefcase.fill"
            )
        }
    }
    
    private func packCard(type: InspectionPackType, title: String, badge: String, description: String, icon: String) -> some View {
        let isSelected = selectedPack == type
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedPack = type
                downloadCompleted = false
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? SolTokens.indigo.opacity(0.15) : SolTokens.paper200)
                            .frame(width: 32, height: 32)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(isSelected ? SolTokens.indigo : SolTokens.paper300, lineWidth: 1))
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isSelected ? SolTokens.indigo : SolTokens.ink700)
                    }
                    
                    Spacer()
                    
                    Text(badge)
                        .font(.inter(10, .semibold))
                        .foregroundColor(isSelected ? SolTokens.indigo : SolTokens.ink600)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(isSelected ? SolTokens.indigo.opacity(0.12) : SolTokens.paper200)
                        .clipShape(Capsule())
                }
                
                Text(title)
                    .font(.inter(14, .bold))
                    .foregroundColor(SolTokens.ink900)
                
                Text(description)
                    .font(.inter(11.5))
                    .foregroundColor(SolTokens.ink600)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? SolTokens.paper100 : SolTokens.paper100.opacity(0.6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? SolTokens.indigo : SolTokens.paper300, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Pack Manifest & Contents
    private var packManifestView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.language == .se ? "PAKETETS INNEHÅLL (AUTONOMT SAMMANSTÄLLT)" : "PACKAGE MANIFEST (AUTONOMOUSLY COMPILED)")
                .font(.inter(11, .bold))
                .tracking(0.7)
                .foregroundColor(SolTokens.ink600)
            
            VStack(spacing: 8) {
                manifestRow(
                    docTitle: store.language == .se ? "1. Anställningsavtal & Tidslogg (8 medarbetare)" : "1. Employment Contracts & Timesheets (8 staff)",
                    statute: "AML § 14-6",
                    status: store.language == .se ? "✓ 100% säkrat med BankID-certifikat" : "✓ 100% secured with BankID cert",
                    pages: "16 sidor"
                )
                
                manifestRow(
                    docTitle: store.language == .se ? "2. Skyddsombudsprotokoll & Valresultat" : "2. Safety Representative Election Protocol",
                    statute: "AML § 6-1",
                    status: store.language == .se ? "✓ Protokollförd röstlängd och intyg" : "✓ Verified ballot & certificate",
                    pages: "3 sidor"
                )
                
                manifestRow(
                    docTitle: store.language == .se ? "3. VD Arbetsmiljöutbildning (KMA/HMS Intyg)" : "3. CEO HSE Training Certification",
                    statute: "AML § 3-5",
                    status: store.language == .se ? "✓ Genomförd via Simployer Learn" : "✓ Completed via Simployer Learn",
                    pages: "2 sidor"
                )
                
                manifestRow(
                    docTitle: store.language == .se ? "4. Dygnsvila, Veckovila & Övertidsjournal" : "4. Daily Rest & Overtime Registry",
                    statute: "AML kap. 10",
                    status: store.language == .se ? "✓ Senaste 90 dagarna utan avvikelser" : "✓ Past 90 days zero breaches",
                    pages: "8 sidor"
                )
                
                if selectedPack == .dueDiligence {
                    manifestRow(
                        docTitle: store.language == .se ? "5. Lönekartläggning & Jämställdhetsrapport" : "5. Equal Pay Audit & Gender Ratio",
                        statute: "Likestillingsloven § 26",
                        status: store.language == .se ? "✓ Löneanalys godkänd utan osakliga skillnader" : "✓ Pay equity verified",
                        pages: "5 sidor"
                    )
                }
            }
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    private func manifestRow(docTitle: String, statute: String, status: String, pages: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .foregroundColor(SolTokens.indigo)
                .font(.system(size: 13))
            
            Text(docTitle)
                .font(.inter(12.5, .medium))
                .foregroundColor(SolTokens.ink900)
            
            Text(statute)
                .font(.inter(10, .medium))
                .foregroundColor(SolTokens.ink600)
                .padding(.horizontal, 6)
                .padding(.vertical, 1.5)
                .background(SolTokens.paper200)
                .cornerRadius(4)
            
            Spacer()
            
            Text(status)
                .font(.inter(11, .medium))
                .foregroundColor(SolTokens.green800)
            
            Text(pages)
                .font(.inter(11))
                .foregroundColor(SolTokens.ink450)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(SolTokens.paper200.opacity(0.4))
        .cornerRadius(6)
    }
    
    // MARK: - Export Action Bar
    private var exportActionBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.language == .se ? "Digitalt förseglad export" : "Digitally Sealed Export")
                    .font(.inter(12, .semibold))
                    .foregroundColor(SolTokens.ink900)
                Text(store.language == .se ? "Inkluderar officiell 'Checked by Simployer'-stämpel och kryptografisk tidsstämpel." : "Includes official 'Checked by Simployer' seal and cryptographic timestamp.")
                    .font(.inter(11))
                    .foregroundColor(SolTokens.ink450)
            }
            
            Spacer()
            
            Button {
                isGenerating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isGenerating = false
                    downloadCompleted = true
                }
            } label: {
                HStack(spacing: 7) {
                    if isGenerating {
                        ProgressView()
                            .controlSize(.small)
                    } else if downloadCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    
                    Text(downloadCompleted ? 
                         (store.language == .se ? "Paket exporterat (PDF / ZIP)" : "Package Exported (PDF / ZIP)") :
                         (store.language == .se ? "Ladda ned revisionspaket" : "Download Inspection Package"))
                        .font(.inter(12.5, .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(downloadCompleted ? SolTokens.green800 : SolTokens.indigo)
                .cornerRadius(7)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
    }
}
