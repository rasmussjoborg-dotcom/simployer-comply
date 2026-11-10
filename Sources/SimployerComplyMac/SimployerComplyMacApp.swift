import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        updateDockIcon()
        
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDockIcon()
        }
    }
    
    func updateDockIcon() {
        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let iconName = isDark ? "AppIcon-Dark-1024" : "AppIcon-1024"
        
        if let iconUrl = Bundle.main.url(forResource: iconName, withExtension: "png"),
           let img = NSImage(contentsOf: iconUrl) {
            NSApp.applicationIconImage = img
        } else if let iconUrl = Bundle.main.url(forResource: "AppIcon-1024", withExtension: "png"),
                  let img = NSImage(contentsOf: iconUrl) {
            NSApp.applicationIconImage = img
        } else if let iconUrl = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
                  let img = NSImage(contentsOf: iconUrl) {
            NSApp.applicationIconImage = img
        } else if let img = NSImage(named: "AppIcon") {
            NSApp.applicationIconImage = img
        }
    }
}

@main
struct SimployerComplyMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = ComplyStore.shared
    @StateObject private var updater = ComplyUpdater.shared
    
    init() {
        SolTypography.registerFonts()
    }
    
    var body: some Scene {
        // MARK: - Main Native Window (Placed first so it opens on launch)
        WindowGroup(id: "main") {
            MacMainView()
                .environmentObject(store)
                .frame(minWidth: 1100, minHeight: 740)
                .background(SolTokens.canvasRoot)
                .preferredColorScheme(.dark)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(after: .appInfo) {
                Button(store.language == .se ? "Sök efter uppdateringar…" : (store.language == .no ? "Se etter oppdateringer…" : "Check for Updates…")) {
                    updater.checkForUpdates()
                }
                .disabled(!updater.canCheckForUpdates)
            }
            
            CommandMenu("Demo") {
                Button(store.language == .se ? "Simulera +2 anställda (Tröskel 10)" : "Simulate +2 employees (AMU Threshold)") {
                    store.simulateHiringTwoEmployees()
                }
                .keyboardShortcut("2", modifiers: [.command, .option])
                
                Button(store.language == .se ? "Återställ till morgonläge (08:00)" : (store.language == .no ? "Tilbakestill til morgenmodus (08:00)" : "Reset to morning baseline (08:00)")) {
                    store.resetDemoToMorningBaseline()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                Button(store.showPresenterHUD ? store.l10n.hudToggleClose : store.l10n.hudToggleOpen) {
                    withAnimation {
                        store.showPresenterHUD.toggle()
                    }
                }
                .keyboardShortcut("d", modifiers: .command)
                
                Divider()
                
                Button(store.language == .se ? "8 anställda (Utgångsläge · Fjord Dynamics)" : (store.language == .no ? "8 ansatte (Utgangspunkt · Fjord Dynamics)" : "8 employees (Baseline · Fjord Dynamics)")) {
                    store.setDemoHeadcount(8)
                }
                Button(store.language == .se ? "10 anställda (AMU-krav utlöst)" : (store.language == .no ? "10 ansatte (AMU-krav utløst)" : "10 employees (AMU threshold triggered)")) {
                    store.setDemoHeadcount(10)
                }
                Button(store.language == .se ? "20 anställda (Scale-up fas)" : (store.language == .no ? "20 ansatte (Scale-up fase)" : "20 employees (Scale-up phase)")) {
                    store.setDemoHeadcount(20)
                }
            }
        }
        
        // MARK: - Native macOS Menu Bar Item (Simployer Logo with Teams-style status dot)
        MenuBarExtra {
            MenuBarActionHubView(store: store, updater: updater)
                .preferredColorScheme(.dark)
        } label: {
            if store.isResolving {
                if #available(macOS 15.0, *) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .symbolEffect(.rotate, isActive: true)
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            } else if let icon = SimployerLogoAsset.menuBarStatusIcon(severity: store.complianceSeverity) {
                Image(nsImage: icon)
            } else if let icon = SimployerLogoAsset.menuBarIcon {
                Image(nsImage: icon)
            } else {
                Image(systemName: "shield.checkered")
            }
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - Native macOS Menu Bar Popover Window Appearance Configurator
struct WindowAppearanceConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            configure(view: view)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(view: nsView)
        }
    }
    
    private func configure(view: NSView) {
        guard let window = view.window else { return }
        window.appearance = NSAppearance(named: .darkAqua)
        window.backgroundColor = NSColor(SolTokens.canvasRoot)
        window.isOpaque = false
    }
}

// MARK: - Executive Mini Action Hub Popover for Menu Bar
struct MenuBarActionHubView: View {
    @ObservedObject var store: ComplyStore
    @ObservedObject var updater: ComplyUpdater
    @Environment(\.openWindow) private var openWindow
    
    @State private var dismissedContracts: Bool = false
    @State private var dismissedSafetyRep: Bool = false
    @State private var dismissedHandbook: Bool = false
    @State private var dismissedAllCaughtUp: Bool = false
    
    private var isCompliant: Bool {
        store.currentCompliancePercent >= 100
    }
    
    private var isBehind: Bool {
        store.complianceSeverity == .behind
    }
    
    private var contractsResolved: Bool {
        !store.currentScenario.employees.contains { $0.status == .aml14Gap }
    }
    
    private var safetyRepResolved: Bool {
        store.verneombudElectionActive
    }
    
    private var handbookResolved: Bool {
        store.handbookSignaturesCount >= 8
    }
    
    private var allTasksDismissed: Bool {
        dismissedContracts && dismissedSafetyRep && dismissedHandbook
    }
    
    private func scheduleDismissal(contracts: Bool, safetyRep: Bool, handbook: Bool) {
        if contracts && !dismissedContracts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    dismissedContracts = true
                }
            }
        }
        if safetyRep && !dismissedSafetyRep {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    dismissedSafetyRep = true
                }
            }
        }
        if handbook && !dismissedHandbook {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    dismissedHandbook = true
                }
            }
        }
        // At the very end, also dismiss the 'All caught up' card so the view settles into pure calm
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                dismissedAllCaughtUp = true
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            headerView
            heroStatusView
            
            if !dismissedAllCaughtUp {
                if !allTasksDismissed {
                    checklistView
                    primaryExecuteSection
                } else {
                    allCaughtUpView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.98)),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                }
            }
            
            Divider()
                .background(SolTokens.paper300)
            footerView
        }
        .padding(14)
        .frame(width: 380)
        .background(SolTokens.canvasRoot)
        .background(WindowAppearanceConfigurator())
        .preferredColorScheme(.dark)
        .onAppear {
            if isCompliant {
                dismissedContracts = true
                dismissedSafetyRep = true
                dismissedHandbook = true
                dismissedAllCaughtUp = true
            } else {
                dismissedContracts = contractsResolved
                dismissedSafetyRep = safetyRepResolved
                dismissedHandbook = handbookResolved
                dismissedAllCaughtUp = false
            }
        }
        .onChange(of: store.isResolving) { resolving in
            if !resolving && isCompliant {
                scheduleDismissal(contracts: true, safetyRep: true, handbook: true)
            }
        }
        .onChange(of: allTasksDismissed) { allDismissed in
            if allDismissed && !dismissedAllCaughtUp {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        dismissedAllCaughtUp = true
                    }
                }
            }
        }
        .onChange(of: store.pendingActionCount) { count in
            if count > 0 {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if !contractsResolved { dismissedContracts = false }
                    if !safetyRepResolved { dismissedSafetyRep = false }
                    if !handbookResolved { dismissedHandbook = false }
                    dismissedAllCaughtUp = false
                }
            }
        }
    }
    
    // MARK: - Top Header
    private var headerView: some View {
        let l10n = store.l10n
        return HStack(alignment: .center, spacing: 8) {
            if let badge = SimployerLogoAsset.plumBadgeIcon {
                Image(nsImage: badge)
                    .frame(width: 20, height: 20)
            } else {
                SimployerLogoView()
                    .frame(width: 18, height: 18)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Simployer Comply")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SolTokens.ink900)
                Text("Fjord Dynamics AS")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(SolTokens.ink600)
            }
            
            Spacer()
            
            // Status Pill
            HStack(spacing: 5) {
                Circle()
                    .fill(isCompliant ? SolTokens.green800 : (isBehind ? SolTokens.red700 : SolTokens.amber400))
                    .frame(width: 6, height: 6)
                
                Text(statusPillText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isCompliant ? SolTokens.green800 : (isBehind ? SolTokens.red700 : SolTokens.amber400))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(isCompliant ? SolTokens.green100 : (isBehind ? SolTokens.red100 : SolTokens.amber100))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isCompliant ? SolTokens.greenBorder : (isBehind ? SolTokens.redBorder : SolTokens.amberBorder), lineWidth: 1)
            )
        }
    }
    
    private var statusPillText: String {
        if isCompliant {
            return store.language == .se ? "100% Lagligt" : (store.language == .no ? "100% Lovlig" : "100% Compliant")
        } else if isBehind {
            return store.language == .se ? "\(store.pendingActionCount) åtgärder" : (store.language == .no ? "\(store.pendingActionCount) tiltak" : "\(store.pendingActionCount) actions")
        } else {
            return store.language == .se ? "Uppföljning" : (store.language == .no ? "Oppfølging" : "Attention")
        }
    }
            
    // MARK: - Hero Compliance Status Card (Calm status, no buttons)
    private var heroStatusView: some View {
        HStack(spacing: 12) {
            // Mini Compliance Ring (44x44)
            ZStack {
                Circle()
                    .stroke(SolTokens.paper300, lineWidth: 4.5)
                
                Circle()
                    .trim(from: 0, to: CGFloat(store.currentComplianceRatio))
                    .stroke(
                        isCompliant ? SolTokens.green800 : (isBehind ? SolTokens.red700 : SolTokens.amber400),
                        style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.75), value: store.currentComplianceRatio)
                
                if isCompliant && !store.isResolving {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(SolTokens.green800)
                } else {
                    Text("\(store.currentCompliancePercent)%")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(SolTokens.ink900)
                }
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                if store.isResolving {
                    Text(store.resolvingStepMessage ?? (store.language == .se ? "Autonomt regelarbete pågår…" : (store.language == .no ? "Autonomt lovarbeid pågår…" : "Autonomous validation in progress…")))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(SolTokens.lav400)
                        .lineLimit(1)
                    Text("Comply Legal Cloud · BankID")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(SolTokens.ink600)
                } else if isCompliant {
                    Text(store.language == .se ? "Alltid i enlighet med lagen" : (store.language == .no ? "Alltid i tråd med loven" : "Fully legally compliant"))
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(SolTokens.green800)
                    Text(store.language == .se ? "Inga utestående lagavvikelser under AML" : (store.language == .no ? "Ingen utestående lovavvik under AML" : "Zero statutory gaps under AML"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(SolTokens.ink600)
                } else {
                    let count = store.pendingActionCount
                    let actionText = store.language == .se 
                        ? (count == 1 ? "1 lagkrav kräver åtgärd" : "\(count) lagkrav kräver åtgärd")
                        : (store.language == .no 
                            ? (count == 1 ? "1 lovkrav krever tiltak" : "\(count) lovkrav krever tiltak")
                            : (count == 1 ? "1 action for full legal protection" : "\(count) actions for full legal protection"))
                    Text(actionText)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(SolTokens.ink900)
                    Text(store.language == .se ? "Möt de nya lagkraven för fullständigt skydd" : (store.language == .no ? "Møt de nye lovkravene for full trygghet" : "Meet statutory AML rules for complete protection"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(SolTokens.ink600)
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(SolTokens.paper100)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
    }
            
    // MARK: - Executive Checklist View (No buttons, no legal citations)
    @ViewBuilder
    private var checklistView: some View {
        VStack(spacing: 5) {
            // Item 1: Contracts
            if !dismissedContracts {
                MiniActionRow(
                    icon: "doc.text.fill",
                    iconColor: contractsResolved ? SolTokens.green800 : SolTokens.red700,
                    title: contractsResolved 
                        ? (store.language == .se ? "7 anställningsavtal uppdaterade" : (store.language == .no ? "7 arbeidsavtaler oppdatert" : "7 employment contracts updated"))
                        : (store.language == .se ? "7 avtal saknar övertidsvillkor" : (store.language == .no ? "7 avtaler mangler overtidsvilkår" : "7 contracts need overtime clauses")),
                    subtitle: contractsResolved 
                        ? (store.language == .se ? "Lagstadgade villkor införda" : (store.language == .no ? "Lovfestede vilkår innført" : "Statutory terms applied"))
                        : (store.language == .se ? "Standardavtal saknar lagstadgad skrivning" : (store.language == .no ? "Standardavtaler mangler lovpålagt tekst" : "Standard contracts lack statutory terms")),
                    isResolved: contractsResolved
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
            
            // Item 2: Verneombud
            if !dismissedSafetyRep {
                MiniActionRow(
                    icon: "person.2.fill",
                    iconColor: safetyRepResolved ? SolTokens.green800 : SolTokens.amber400,
                    title: safetyRepResolved 
                        ? (store.language == .se ? "Digitalt skyddsombudsval utlyst" : (store.language == .no ? "Digitalt verneombudsvalg åpnet" : "Safety rep election opened"))
                        : (store.language == .se ? "Val av skyddsombud måste utlysas" : (store.language == .no ? "Valg av verneombud må åpnes" : "Safety rep election required")),
                    subtitle: safetyRepResolved 
                        ? (store.language == .se ? "Röstning distribuerad till personalen" : (store.language == .no ? "Avstemning sendt til ansatte" : "Ballot distributed to staff"))
                        : (store.language == .se ? "Teamet har passerat 5 anställda" : (store.language == .no ? "Teamet har passert 5 ansatte" : "Headcount passed 5 employees")),
                    isResolved: safetyRepResolved
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
            
            // Item 3: Handbook
            if !dismissedHandbook {
                MiniActionRow(
                    icon: "book.closed.fill",
                    iconColor: handbookResolved ? SolTokens.green800 : SolTokens.amber400,
                    title: handbookResolved 
                        ? (store.language == .se ? "Personalhandbok kvitterad av alla" : (store.language == .no ? "Personalhåndbok signert av alle" : "Handbook acknowledged by all staff"))
                        : (store.language == .se ? "4 medarbetare saknar signatur" : (store.language == .no ? "4 ansatte mangler signatur" : "4 staff pending signature")),
                    subtitle: handbookResolved 
                        ? (store.language == .se ? "Samtliga har signerat via BankID" : (store.language == .no ? "Alle har signert via BankID" : "All staff signed via BankID"))
                        : (store.language == .se ? "Varslingsrutin kräver BankID-kvittens" : (store.language == .no ? "Varslingsrutine krever BankID-signatur" : "Whistleblowing policy requires BankID")),
                    isResolved: handbookResolved
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
    }
    
    // MARK: - Single Executive Action (Resolve All)
    @ViewBuilder
    private var primaryExecuteSection: some View {
        if !isCompliant && !store.isResolving {
            VStack(spacing: 5) {
                Button {
                    store.resolveWithLiveSpin()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(store.l10n.hubMacroResolveButton)
                            .font(.system(size: 12.5, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8.5)
                    .background(SolTokens.plum900)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(color: SolTokens.plum900.opacity(0.4), radius: 6, y: 2)
                }
                .buttonStyle(.plain)
                
                Text(store.language == .se 
                    ? "Uppdaterar 7 avtal, startar röstning & påminner 4 anställda" 
                    : (store.language == .no 
                        ? "Oppdaterer 7 avtaler, åpner valg & varsler 4 ansatte" 
                        : "Updates 7 contracts, opens election & pings 4 staff"))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(SolTokens.ink600)
                    .lineLimit(1)
            }
            .padding(.top, 2)
        } else if store.isResolving {
            VStack(spacing: 4) {
                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(SolTokens.lav500)
                
                Text(store.resolvingStepMessage ?? (store.language == .se ? "Åtgärdar brister…" : (store.language == .no ? "Løser avvik…" : "Resolving items…")))
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundColor(SolTokens.lav400)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - All Caught Up (Calm Empty State)
    private var allCaughtUpView: some View {
        HStack(spacing: 9) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(SolTokens.green800)
                .frame(width: 18)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(store.language == .se ? "Alla lagkrav är åtgärdade" : (store.language == .no ? "Alle lovkrav er utbedret" : "All statutory duties fulfilled"))
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(SolTokens.ink900)
                
                Text(store.language == .se ? "Inga utestående åtgärder · Comply bevakar i bakgrunden" : (store.language == .no ? "Ingen utestående tiltak · Comply overvåker i bakgrunnen" : "Zero pending actions · Comply guarding continuously"))
                    .font(.system(size: 9.5))
                    .foregroundColor(SolTokens.ink600)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(SolTokens.green100.opacity(0.45))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(SolTokens.greenBorder.opacity(0.7), lineWidth: 1))
    }
    
    // MARK: - Footer Actions
    private var footerView: some View {
        let l10n = store.l10n
        return HStack(spacing: 8) {
            Button {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "main")
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "macwindow")
                        .font(.system(size: 10))
                    Text(l10n.menuOpenControlRoom)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(SolTokens.ink700)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(store.language == .se ? "Uppdateringar" : (store.language == .no ? "Oppdateringer" : "Updates")) {
                updater.checkForUpdates()
            }
            .font(.system(size: 10.5))
            .foregroundColor(SolTokens.ink600)
            .buttonStyle(.plain)
            .disabled(!updater.canCheckForUpdates)
            
            Text("·")
                .foregroundColor(SolTokens.ink600)
            
            Button(l10n.menuQuit) {
                NSApp.terminate(nil)
            }
            .font(.system(size: 10.5))
            .foregroundColor(SolTokens.ink600)
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Mini Action Item Row (Clean Checklist, no individual buttons)
struct MiniActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isResolved: Bool
    
    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: isResolved ? "checkmark.circle.fill" : icon)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(isResolved ? SolTokens.green800 : iconColor)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 1.5) {
                Text(title)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(isResolved ? SolTokens.ink700 : SolTokens.ink900)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 9.5))
                    .foregroundColor(isResolved ? SolTokens.green800.opacity(0.85) : SolTokens.ink600)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 4)
            
            if isResolved {
                Image(systemName: "checkmark")
                    .font(.system(size: 8.5, weight: .black))
                    .foregroundColor(SolTokens.green800)
                    .padding(3.5)
                    .background(SolTokens.green100)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6.5)
        .background(isResolved ? SolTokens.green100.opacity(0.3) : SolTokens.paper100.opacity(0.85))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(isResolved ? SolTokens.greenBorder.opacity(0.7) : SolTokens.paper200, lineWidth: 1))
    }
}
