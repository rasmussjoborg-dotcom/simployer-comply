import SwiftUI

// MARK: - 1. Verneombud Digital Election Sheet (AML § 6-1)
struct MacVerneombudElectionSheet: View {
    @ObservedObject var store: ComplyStore
    @Environment(\.dismiss) var dismiss
    @State private var hasDispatchedBallot = false
    @State private var electionCompleted = false
    
    var body: some View {
        let l10n = store.l10n
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("AML § 6-1")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SolTokens.paper200)
                            .foregroundColor(SolTokens.ink700)
                            .cornerRadius(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                        Text(l10n.voTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(SolTokens.ink900)
                    }
                    Text(l10n.voSubtitle)
                        .font(.system(size: 12))
                        .foregroundColor(SolTokens.ink600)
                }
                Spacer()
                Button(l10n.close) { dismiss() }
                    .buttonStyle(.borderless)
            }
            .padding(20)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 18) {
                // Info Box
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 24))
                        .foregroundColor(SolTokens.lav500)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(l10n.voBoxTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(SolTokens.ink900)
                        Text(l10n.voBoxSubtitle)
                            .font(.system(size: 11))
                            .foregroundColor(SolTokens.ink700)
                            .lineSpacing(2)
                    }
                }
                .padding(14)
                .background(SolTokens.paper50)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(SolTokens.paper300, lineWidth: 1)
                )
                
                // Candidate Cards
                VStack(alignment: .leading, spacing: 10) {
                    Text(l10n.voCandidatesHeader)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SolTokens.ink450)
                    
                    CandidateRow(
                        name: "Sofie Hagen",
                        role: "Lead Designer & UX",
                        votes: hasDispatchedBallot ? 6 : 0,
                        totalVotes: 8,
                        isLeading: true,
                        l10n: l10n
                    )
                    
                    CandidateRow(
                        name: "Magnus Teig",
                        role: "Frontend Ingeniør",
                        votes: hasDispatchedBallot ? 2 : 0,
                        totalVotes: 8,
                        isLeading: false,
                        l10n: l10n
                    )
                }
                
                // Status feedback
                if electionCompleted {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                            .font(.system(size: 18))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(l10n.voSuccessTitle)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(SolTokens.green800)
                            Text(l10n.voSuccessSubtitle)
                                .font(.system(size: 10))
                                .foregroundColor(SolTokens.green800)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SolTokens.green100)
                    .cornerRadius(8)
                }
            }
            .padding(20)
            
            Spacer()
            
            // Footer Action Bar
            HStack {
                Text(l10n.voFooter)
                    .font(.system(size: 10))
                    .foregroundColor(SolTokens.ink600)
                Spacer()
                
                if !hasDispatchedBallot {
                    Button {
                        withAnimation {
                            hasDispatchedBallot = true
                            store.castVerneombudVote()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "envelope.badge.fill")
                            Text(l10n.voSendBallots)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(SolTokens.plum900)
                        .foregroundColor(SolTokens.lav50)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                } else if !electionCompleted {
                    Button {
                        withAnimation {
                            electionCompleted = true
                            store.castVerneombudVote()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "signature")
                            Text(l10n.voSignBankId)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(SolTokens.green800)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(l10n.voCloseAndInspect) {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SolTokens.plum900)
                }
            }
            .padding(16)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .top
            )
        }
        .frame(width: 620, height: 490)
        .background(SolTokens.paper100)
    }
}

private struct CandidateRow: View {
    let name: String
    let role: String
    let votes: Int
    let totalVotes: Int
    let isLeading: Bool
    let l10n: LocalizedStrings
    
    var body: some View {
        HStack(spacing: 12) {
            LinearAvatarBadge(name: name, size: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SolTokens.ink900)
                Text(role)
                    .font(.system(size: 10))
                    .foregroundColor(SolTokens.ink600)
            }
            
            Spacer()
            
            if votes > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(votes) \(l10n.voVotesOf) \(totalVotes) \(l10n.voVotesUnit) (\(Int(Double(votes)/Double(totalVotes)*100)) %)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(isLeading ? SolTokens.plum900 : SolTokens.ink600)
                    ProgressView(value: Double(votes), total: Double(totalVotes))
                        .frame(width: 100)
                        .tint(isLeading ? SolTokens.plum900 : SolTokens.ink450)
                }
            } else {
                Text(l10n.voAwaitingVotes)
                    .font(.system(size: 10))
                    .foregroundColor(SolTokens.ink450)
            }
        }
        .padding(12)
        .background(SolTokens.paper200)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isLeading && votes > 0 ? SolTokens.lav500 : SolTokens.paper300, lineWidth: 1)
        )
    }
}

// MARK: - 2. Simployer Ecosystem Upsell Modal
struct MacUpsellSheet: View {
    @ObservedObject var store: ComplyStore
    @Environment(\.dismiss) var dismiss
    @State private var activated = false
    
    var body: some View {
        let scenario = store.l10n.scenarios[store.currentYear]
        let product = scenario?.upsellProduct ?? store.currentScenario.recommendedUpsell.product
        let title = scenario?.upsellTitle ?? store.currentScenario.recommendedUpsell.title
        let price = scenario?.upsellPrice ?? store.currentScenario.recommendedUpsell.price
        let benefit = scenario?.upsellBenefit ?? store.currentScenario.recommendedUpsell.benefit
        let l10n = store.l10n
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(SolTokens.paper200)
                            .frame(width: 26, height: 26)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.paper300, lineWidth: 1))
                        Image(systemName: "sparkles")
                            .foregroundColor(SolTokens.ink600)
                            .font(.system(size: 13, weight: .bold))
                    }
                    Text("\(l10n.upsellSheetTitlePrefix)\(product)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(SolTokens.ink900)
                }
                Spacer()
                Button(l10n.close) { dismiss() }
                    .buttonStyle(.borderless)
            }
            .padding(20)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .bottom
            )
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text("\(l10n.upsellPricePrefix)\(price)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SolTokens.plum900)
                }
                
                Text(benefit)
                    .font(.system(size: 12))
                    .foregroundColor(SolTokens.ink700)
                    .lineSpacing(2)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.upsellBenefitHeader)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SolTokens.ink450)
                    
                    BenefitBullet(text: l10n.upsellBullet1)
                    BenefitBullet(text: l10n.upsellBullet2)
                    BenefitBullet(text: l10n.upsellBullet3)
                }
                
                if activated {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(l10n.upsellActivatedMessage)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SolTokens.green100)
                    .cornerRadius(8)
                }
            }
            .padding(20)
            
            Spacer()
            
            HStack {
                Text(l10n.upsellMonthlyBilling)
                    .font(.system(size: 10))
                    .foregroundColor(SolTokens.ink600)
                Spacer()
                
                if activated {
                    Button(l10n.done) { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(SolTokens.plum900)
                } else {
                    Button(l10n.upsellActivateNow) {
                        withAnimation {
                            activated = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SolTokens.plum900)
                }
            }
            .padding(16)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .top
            )
        }
        .frame(width: 540, height: 420)
        .background(SolTokens.paper100)
    }
}

private struct BenefitBullet: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundColor(SolTokens.green800)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(SolTokens.ink700)
        }
    }
}

// MARK: - 3. Sick Leave Day 14 Dialog Meeting Sheet (2025 · AML § 4-6)
struct MacSickLeaveSheet: View {
    @ObservedObject var store: ComplyStore
    @Environment(\.dismiss) var dismiss
    @State private var inviteSent = false
    
    var body: some View {
        let l10n = store.l10n
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("AML § 4-6")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SolTokens.red100)
                            .foregroundColor(SolTokens.red700)
                            .cornerRadius(4)
                        Text(l10n.sickTitle)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(SolTokens.ink900)
                    }
                    Text(l10n.sickSubtitle)
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.ink600)
                }
                Spacer()
                Button(l10n.close) { dismiss() }
                    .buttonStyle(.borderless)
            }
            .padding(20)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .bottom
            )
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.sickDeadlinesHeader)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SolTokens.ink450)
                    
                    HStack(spacing: 12) {
                        MilestonePill(title: l10n.sickMilestone1Title, subtitle: l10n.sickMilestone1Sub, active: true)
                        MilestonePill(title: l10n.sickMilestone2Title, subtitle: l10n.sickMilestone2Sub, active: false)
                        MilestonePill(title: l10n.sickMilestone3Title, subtitle: l10n.sickMilestone3Sub, active: false)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(l10n.sickDocsHeader)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SolTokens.ink450)
                    
                    Text(l10n.sickDocsBody)
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.ink700)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SolTokens.paper50)
                        .cornerRadius(8)
                }
                
                if inviteSent {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(l10n.sickSuccessNotice)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SolTokens.green100)
                    .cornerRadius(8)
                }
            }
            .padding(20)
            
            Spacer()
            
            HStack {
                Text(l10n.sickSanctionNotice)
                    .font(.system(size: 10))
                    .foregroundColor(SolTokens.red700)
                Spacer()
                
                if inviteSent {
                    Button(l10n.close) { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(SolTokens.plum900)
                } else {
                    Button(l10n.sickSendInvite) {
                        withAnimation {
                            inviteSent = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SolTokens.plum900)
                }
            }
            .padding(16)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .top
            )
        }
        .frame(width: 580, height: 430)
        .background(SolTokens.paper100)
    }
}

private struct MilestonePill: View {
    let title: String
    let subtitle: String
    let active: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(active ? SolTokens.plum900 : SolTokens.ink600)
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundColor(SolTokens.ink600)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(active ? SolTokens.lav100 : SolTokens.paper50)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(active ? SolTokens.lav500 : SolTokens.paper300, lineWidth: 1)
        )
    }
}

// MARK: - 4. Dismissal Defense & Expert Jurist Handoff Sheet (2027 · AML § 15-1)
struct MacDismissalDefenseSheet: View {
    @ObservedObject var store: ComplyStore
    @Environment(\.dismiss) var dismiss
    @State private var handedOff = false
    
    var body: some View {
        let l10n = store.l10n
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("AML § 15-1")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SolTokens.red100)
                            .foregroundColor(SolTokens.red700)
                            .cornerRadius(4)
                        Text(l10n.defenseTitle)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(SolTokens.ink900)
                    }
                    Text(l10n.defenseSubtitle)
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.ink600)
                }
                Spacer()
                Button(l10n.close) { dismiss() }
                    .buttonStyle(.borderless)
            }
            .padding(20)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .bottom
            )
            
            VStack(alignment: .leading, spacing: 16) {
                // Risk Callout
                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.defenseRiskHeader)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SolTokens.red700)
                    Text(l10n.defenseRiskBody)
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.ink900)
                        .lineSpacing(2)
                }
                .padding(12)
                .background(SolTokens.red100.opacity(0.5))
                .cornerRadius(8)
                
                // Checklist
                VStack(alignment: .leading, spacing: 6) {
                    Text(l10n.defenseChecklistHeader)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SolTokens.ink450)
                    
                    DefenseCheckItem(text: l10n.defenseCheck1)
                    DefenseCheckItem(text: l10n.defenseCheck2)
                    DefenseCheckItem(text: l10n.defenseCheck3)
                }
                
                // Expert Jurist Guarantee
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(SolTokens.plum900)
                            .frame(width: 36, height: 36)
                        Text("⚖️")
                            .font(.system(size: 15))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.defenseExpertDeskTitle)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SolTokens.plum900)
                        Text(l10n.defenseExpertDeskDesc)
                            .font(.system(size: 10))
                            .foregroundColor(SolTokens.ink600)
                    }
                }
                .padding(12)
                .background(SolTokens.paper50)
                .cornerRadius(8)
                
                if handedOff {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(l10n.defenseSuccessNotice)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SolTokens.green100)
                    .cornerRadius(8)
                }
            }
            .padding(20)
            
            Spacer()
            
            HStack {
                Text(l10n.defenseFooter)
                    .font(.system(size: 10))
                    .foregroundColor(SolTokens.ink600)
                Spacer()
                
                if handedOff {
                    Button(l10n.close) { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(SolTokens.plum900)
                } else {
                    Button(l10n.defenseHandoffButton) {
                        withAnimation {
                            handedOff = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SolTokens.plum900)
                }
            }
            .padding(16)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .top
            )
        }
        .frame(width: 600, height: 490)
        .background(SolTokens.paper100)
    }
}

private struct DefenseCheckItem: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle")
                .foregroundColor(SolTokens.lav600)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(SolTokens.ink700)
        }
    }
}

// MARK: - 5. Equal Pay (Likestillingsredegjørelse & ARP-analyse) Modal
struct MacEqualPayModal: View {
    @ObservedObject var store: ComplyStore
    @Environment(\.dismiss) var dismiss
    @State private var reportGenerated = false
    
    var body: some View {
        let l10n = store.l10n
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text("ARP § 26")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(SolTokens.paper200)
                        .foregroundColor(SolTokens.ink700)
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(SolTokens.paper300, lineWidth: 1))
                    Text(l10n.equalPayTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(SolTokens.ink900)
                }
                Spacer()
                Button(l10n.close) { dismiss() }
                    .buttonStyle(.borderless)
            }
            .padding(20)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .bottom
            )
            
            VStack(alignment: .leading, spacing: 16) {
                // Regulatory Notice
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 22))
                        .foregroundColor(SolTokens.lav500)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.equalPayBoxHeader)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SolTokens.ink900)
                        Text(l10n.equalPayBoxDesc)
                            .font(.system(size: 11))
                            .foregroundColor(SolTokens.ink600)
                    }
                }
                .padding(12)
                .background(SolTokens.paper50)
                .cornerRadius(10)
                
                // Categories
                VStack(spacing: 10) {
                    ARPRow(category: l10n.equalPayCat1, femaleRatio: l10n.equalPayRatio1, status: l10n.equalPayStatusOkVariance, ok: true)
                    ARPRow(category: l10n.equalPayCat2, femaleRatio: l10n.equalPayRatio2, status: l10n.equalPayStatusOk, ok: true)
                    ARPRow(category: l10n.equalPayCat3, femaleRatio: l10n.equalPayRatio3, status: l10n.equalPayStatusAlert, ok: false)
                }
                
                if reportGenerated {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(SolTokens.green800)
                        Text(l10n.equalPaySuccessNotice)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SolTokens.green800)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SolTokens.green100)
                    .cornerRadius(8)
                }
            }
            .padding(20)
            
            Spacer()
            
            HStack {
                Text(l10n.equalPayFooter)
                    .font(.system(size: 10))
                    .foregroundColor(SolTokens.ink600)
                Spacer()
                
                if reportGenerated {
                    Button(l10n.done) { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(SolTokens.plum900)
                } else {
                    Button(l10n.equalPayGenerateButton) {
                        withAnimation {
                            reportGenerated = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SolTokens.plum900)
                }
            }
            .padding(16)
            .background(SolTokens.paper50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SolTokens.paper300),
                alignment: .top
            )
        }
        .frame(width: 620, height: 460)
        .background(SolTokens.paper100)
    }
}

private struct ARPRow: View {
    let category: String
    let femaleRatio: String
    let status: String
    let ok: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(category)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SolTokens.ink900)
                Text(femaleRatio)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(SolTokens.ink600)
            }
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(ok ? SolTokens.green800 : SolTokens.red700)
                    .frame(width: 6, height: 6)
                Text(status)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(ok ? SolTokens.green800 : SolTokens.red700)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ok ? SolTokens.green100 : SolTokens.red100)
            .cornerRadius(6)
        }
        .padding(10)
        .background(SolTokens.paper200)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SolTokens.paper300, lineWidth: 1)
        )
    }
}
