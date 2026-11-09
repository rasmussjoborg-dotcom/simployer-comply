import SwiftUI
import Combine

struct DemoStep: Identifiable {
    let id: Int
    let year: CompanyYear
    let nav: String
    let expandedCard: String?
    let duration: Double
    let narrationTitle: String
    let narrationBody: String
}

@MainActor
class AutoplayController: ObservableObject {
    static let shared = AutoplayController()
    
    @Published var isPlaying: Bool = false
    @Published var currentStepIndex: Int = 0
    @Published var currentStep: DemoStep? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private var timerSubscription: AnyCancellable?
    
    var totalSteps: Int { 7 }
    
    func steps(for store: ComplyStore) -> [DemoStep] {
        let l10nSteps = store.l10n.narrationSteps
        let baseSteps: [(year: CompanyYear, nav: String, expandedCard: String?, duration: Double)] = [
            (.y2024, "hub", "contracts", 5.0),
            (.y2024, "hub", "verneombud", 5.5),
            (.y2024, "register", nil, 5.0),
            (.y2025, "hub", "equalPay", 6.0),
            (.y2025, "hub", "sickLeave", 5.0),
            (.y2027, "hub", "defense", 6.0),
            (.y2024, "hub", nil, 4.0)
        ]
        
        return baseSteps.enumerated().map { idx, base in
            let narration = idx < l10nSteps.count ? l10nSteps[idx] : LocalizedNarrationStep(title: "", body: "")
            return DemoStep(
                id: idx,
                year: base.year,
                nav: base.nav,
                expandedCard: base.expandedCard,
                duration: base.duration,
                narrationTitle: narration.title,
                narrationBody: narration.body
            )
        }
    }
    
    func startDemo(store: ComplyStore, onExpandCard: @escaping (String?) -> Void) {
        isPlaying = true
        currentStepIndex = 0
        runStep(at: 0, store: store, onExpandCard: onExpandCard)
    }
    
    func stopDemo(onExpandCard: @escaping (String?) -> Void) {
        isPlaying = false
        timerSubscription?.cancel()
        currentStep = nil
        onExpandCard(nil)
    }
    
    private func runStep(at index: Int, store: ComplyStore, onExpandCard: @escaping (String?) -> Void) {
        let activeSteps = steps(for: store)
        guard isPlaying, index < activeSteps.count else {
            stopDemo(onExpandCard: onExpandCard)
            return
        }
        
        let step = activeSteps[index]
        self.currentStepIndex = index
        self.currentStep = step
        
        // Apply store changes
        withAnimation(.easeInOut(duration: 0.4)) {
            store.setYear(step.year)
            store.activeNav = step.nav
            onExpandCard(step.expandedCard)
        }
        
        timerSubscription?.cancel()
        timerSubscription = Just(())
            .delay(for: .seconds(step.duration), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.runStep(at: index + 1, store: store, onExpandCard: onExpandCard)
            }
    }
}

// MARK: - Autoplay Narration HUD Banner Overlay
struct AutoplayHUDOverlay: View {
    let step: DemoStep
    let stepIndex: Int
    let totalSteps: Int
    var stopLabel: String = "Stopp"
    let onStop: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 16) {
                // Animated pulse badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(SolTokens.lav400)
                        .frame(width: 6, height: 6)
                    Text("DEMO \(stepIndex + 1)/\(totalSteps)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(SolTokens.lav400)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .background(SolTokens.lav100)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(SolTokens.lav600.opacity(0.3), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.narrationTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text(step.narrationBody)
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.ink700)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: onStop) {
                    HStack(spacing: 4) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 8))
                        Text(stopLabel)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(SolTokens.paper300)
                    .foregroundColor(SolTokens.ink900)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(SolTokens.paper400, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(SolTokens.paper50)
                    .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(SolTokens.paper400, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
