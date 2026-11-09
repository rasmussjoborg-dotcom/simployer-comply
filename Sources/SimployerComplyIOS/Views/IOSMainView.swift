import SwiftUI
import LocalAuthentication

struct IOSMainView: View {
    @EnvironmentObject var store: ComplyStore
    @State private var biometricSuccess = false
    @State private var isAuthenticating = false
    
    var body: some View {
        ZStack {
            SolTokens.paper100.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top App Chrome
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(SolTokens.lav500)
                            .font(.system(size: 16, weight: .semibold))
                        Text("Simployer Comply")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(SolTokens.ink900)
                    }
                    Spacer()
                    LanguageSwitcherView(currentLanguage: $store.language) { lang in
                        store.setLanguage(lang)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 8)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Current Company Banner
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Fjord Dynamics AS")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(SolTokens.ink900)
                                Text("\(store.currentScenario.headcount) \(store.l10n.staff8.components(separatedBy: " ").dropFirst().joined(separator: " "))")
                                    .font(.caption)
                                    .foregroundColor(SolTokens.ink600)
                            }
                            Spacer()
                            Text(store.currentScenario.year.rawValue)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(SolTokens.lav100)
                                .foregroundColor(SolTokens.lav400)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(SolTokens.lav600.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        
                        // Permanent Compliance Status Bar
                        let isCompliant = store.pendingActionCount == 0
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(isCompliant ? SolTokens.green100 : SolTokens.amber100)
                                    .frame(width: 32, height: 32)
                                Image(systemName: isCompliant ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(isCompliant ? SolTokens.green800 : SolTokens.amber400)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isCompliant ? store.l10n.hubAllCompliantTitle : store.l10n.hubAttentionTitle(count: store.pendingActionCount))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(isCompliant ? SolTokens.green800 : SolTokens.ink900)
                                Text(isCompliant ? store.l10n.hubAuditLiveStatus : store.l10n.hubAttentionSubtitle(count: store.pendingActionCount))
                                    .font(.system(size: 10.5))
                                    .foregroundColor(SolTokens.ink600)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(SolTokens.paper50)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isCompliant ? SolTokens.greenBorder : SolTokens.amberBorder.opacity(0.85), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Push Alert Card
                        let trigger = store.currentScenario.activeTrigger
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                HStack(spacing: 5) {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundColor(SolTokens.lav500)
                                    Text(store.l10n.pushAlertHeader)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(SolTokens.lav400)
                                }
                                Spacer()
                                Text(store.l10n.timeJustNow)
                                    .font(.caption2)
                                    .foregroundColor(SolTokens.ink450)
                            }
                            
                            Text(trigger.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(SolTokens.ink900)
                            
                            Text(trigger.description)
                                .font(.system(size: 12))
                                .foregroundColor(SolTokens.ink700)
                                .lineSpacing(2)
                            
                            Divider()
                                .overlay(SolTokens.paper300)
                            
                            HStack {
                                Text(trigger.statute)
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(SolTokens.ink600)
                                Spacer()
                                Text(store.l10n.penaltyOnPassivity)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(SolTokens.red700)
                            }
                        }
                        .padding(16)
                        .background(SolTokens.paper50)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SolTokens.paper300, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Action & FaceID Approval Drawer Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text(store.l10n.actionReadyHeader)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(SolTokens.ink450)
                            
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "doc.badge.arrow.up")
                                    .font(.system(size: 18))
                                    .foregroundColor(SolTokens.lav500)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(store.l10n.actionCardTitle)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(SolTokens.ink900)
                                    Text(store.l10n.actionCardSubtitle)
                                        .font(.system(size: 11))
                                        .foregroundColor(SolTokens.ink600)
                                }
                            }
                            .padding(12)
                            .background(SolTokens.paper200)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(SolTokens.paper300, lineWidth: 1)
                            )
                            
                            if biometricSuccess {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(SolTokens.green800)
                                        .font(.system(size: 18))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(store.l10n.approvedFaceId)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(SolTokens.green800)
                                        Text(store.l10n.approvedAuditLog)
                                            .font(.system(size: 10))
                                            .foregroundColor(SolTokens.green800)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(SolTokens.green100)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(SolTokens.greenBorder, lineWidth: 1)
                                )
                            } else {
                                Button {
                                    triggerFaceID()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "faceid")
                                            .font(.system(size: 18))
                                            .foregroundColor(SolTokens.lav50)
                                        Text(store.l10n.approveWithFaceId)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [SolTokens.plum800, SolTokens.plum900],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .foregroundColor(SolTokens.lav50)
                                    .cornerRadius(8)
                                    .shadow(color: SolTokens.plum900.opacity(0.35), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                        .background(SolTokens.paper50)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SolTokens.paper300, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Attorney Fast-Line
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(SolTokens.paper300)
                                    .frame(width: 36, height: 36)
                                Text("⚖️")
                                    .font(.system(size: 16))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.l10n.consultJuristTitle)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(SolTokens.lav400)
                                Text(store.l10n.consultJuristName)
                                    .font(.system(size: 11))
                                    .foregroundColor(SolTokens.ink600)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(SolTokens.ink450)
                        }
                        .padding(14)
                        .background(SolTokens.paper50)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SolTokens.paper300, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    private func triggerFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Godkjenn utsendelse av lovpålagt tilleggsavtale") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            self.biometricSuccess = true
                            // Update store
                            if let first = store.currentScenario.employees.first(where: { $0.status != .ok }) {
                                store.approveContract(for: first.id)
                            }
                        }
                    }
                }
            }
        } else {
            // Simulator fallback if biometrics not enrolled
            withAnimation {
                self.biometricSuccess = true
                if let first = store.currentScenario.employees.first(where: { $0.status != .ok }) {
                    store.approveContract(for: first.id)
                }
            }
        }
    }
}
