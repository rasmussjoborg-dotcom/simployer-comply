import SwiftUI

public struct OnboardingWizardView: View {
    @ObservedObject var store: ComplyStore
    
    // Step navigation: 1 = OrgNr, 2 = Statutory Gap, 3 = Connect Source, 4 = Menu Bar Hand-off
    @State private var currentStep: Int = 1
    
    // Step 1 State: Company Search & OrgNr
    @State private var searchQuery: String = "923 456 789"
    @State private var hasSearched: Bool = false
    @State private var isSearching: Bool = false
    @State private var searchResults: [RegisteredCompany] = [CompanyLookupService.demoCompany]
    @State private var selectedCompany: RegisteredCompany = CompanyLookupService.demoCompany
    @State private var hasTariff: String = "no" // "no", "yes", "unsure"
    
    // Step 2 State: Statutory Audit
    @State private var derivedRules: [StatutoryObligation] = []
    
    // Step 3 State: Connect Source
    @State private var selectedSource: String = "" // "tripletex", "folder", "sample"
    @State private var isConnectingSource: Bool = false
    @State private var connectProgress: Double = 0.0
    @State private var connectStatusMessage: String = ""
    
    private var lang: AppLanguage {
        store.language
    }
    
    public init(store: ComplyStore) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Full-window background canvas
            SolTokens.canvasRoot
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Full-Window Wizard Navigation Bar
                fullWizardHeader
                
                Divider()
                    .overlay(SolTokens.paper300)
                
                // Vertically and Horizontally Centered Content
                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 32)
                            
                            ZStack {
                                switch currentStep {
                                case 1:
                                    fullStep1OrgSearch
                                        .transition(.asymmetric(
                                            insertion: .opacity.animation(.easeInOut(duration: 0.15)),
                                            removal: .identity
                                        ))
                                case 2:
                                    fullStep2StatutoryGap
                                        .transition(.asymmetric(
                                            insertion: .opacity.animation(.easeInOut(duration: 0.15)),
                                            removal: .identity
                                        ))
                                case 3:
                                    fullStep3ConnectSource
                                        .transition(.asymmetric(
                                            insertion: .opacity.animation(.easeInOut(duration: 0.15)),
                                            removal: .identity
                                        ))
                                case 4:
                                    fullStep4MenuBarHandOff
                                        .transition(.asymmetric(
                                            insertion: .opacity.animation(.easeInOut(duration: 0.15)),
                                            removal: .identity
                                        ))
                                default:
                                    fullStep1OrgSearch
                                        .transition(.identity)
                                }
                            }
                            .frame(maxWidth: 720)
                            .padding(.horizontal, 24)
                            
                            Spacer(minLength: 32)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geo.size.height)
                    }
                }
                
                Divider()
                    .overlay(SolTokens.paper300)
                
                // Full-Window Footer Navigation
                fullWizardFooter
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            performInitialSearch()
        }
        .onChange(of: store.language) { _ in
            updateDerivedRules()
        }
    }
    
    // MARK: - Full Wizard Header
    private var fullWizardHeader: some View {
        HStack {
            // Brand Logo & Title
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SolTokens.plum900)
                        .frame(width: 32, height: 32)
                    SimployerLogoView(tint: SolTokens.lav400)
                        .frame(width: 18, height: 18)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Simployer Comply")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(wizardSubtitle)
                        .font(.system(size: 11))
                        .foregroundColor(SolTokens.ink450)
                }
            }
            
            Spacer()
            
            // 4-Step Progress Indicators
            HStack(spacing: 8) {
                stepIndicatorPill(step: 1, label: stepLabel(for: 1))
                stepDivider
                stepIndicatorPill(step: 2, label: stepLabel(for: 2))
                stepDivider
                stepIndicatorPill(step: 3, label: stepLabel(for: 3))
                stepDivider
                stepIndicatorPill(step: 4, label: stepLabel(for: 4))
            }
            
            Spacer()
            
            // Presenter HUD Toggle Button (⌘D)
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    store.showPresenterHUD.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles.tv")
                        .font(.system(size: 9.5, weight: .semibold))
                    Text(store.showPresenterHUD ? store.l10n.hudToggleClose : store.l10n.hudToggleOpen)
                        .font(.inter(11, .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(store.showPresenterHUD ? SolTokens.lav400.opacity(0.18) : SolTokens.paper200)
                .foregroundColor(store.showPresenterHUD ? SolTokens.plum900 : SolTokens.ink600)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(store.showPresenterHUD ? SolTokens.lav400.opacity(0.5) : SolTokens.paper300, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .help(store.l10n.hudToggleHelp)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(SolTokens.canvasRoot)
    }
    
    private func stepIndicatorPill(step: Int, label: String) -> some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(step == currentStep ? SolTokens.lav500 : (step < currentStep ? SolTokens.green800 : SolTokens.paper200))
                    .frame(width: 16, height: 16)
                
                if step < currentStep {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                } else {
                    Text("\(step)")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(step == currentStep ? .white : SolTokens.ink600)
                }
            }
            
            Text(label)
                .font(.system(size: 11, weight: step == currentStep ? .bold : .medium))
                .foregroundColor(step == currentStep ? .white : (step < currentStep ? SolTokens.ink700 : SolTokens.ink600))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(step == currentStep ? SolTokens.plum900.opacity(0.3) : Color.clear)
        .cornerRadius(6)
    }
    
    private var stepDivider: some View {
        Rectangle()
            .fill(SolTokens.paper300)
            .frame(width: 12, height: 1)
    }
    
    // MARK: - Step 1: Org Search & Identity (Full Width)
    private var fullStep1OrgSearch: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(step1Title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(step1Subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(SolTokens.ink450)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity)
            
            // Search field
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(SolTokens.ink600)
                    
                    TextField(searchPlaceholder, text: $searchQuery)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .onSubmit {
                            triggerLookup()
                        }
                    
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Button {
                        triggerLookup()
                    } label: {
                        HStack(spacing: 6) {
                            Text(searchButtonLabel)
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 12.5, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SolTokens.plum900)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(SolTokens.paper100)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
            }
            
            // Selected Company Badge (Rich Card) - only shown after search
            if hasSearched {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 10) {
                                Text(selectedCompany.name)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Org.nr \(selectedCompany.orgNumber)")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(SolTokens.lav400)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(SolTokens.plum900.opacity(0.3))
                                    .cornerRadius(4)
                            }
                            Text("\(selectedCompany.legalForm) · \(selectedCompany.municipality)")
                                .font(.system(size: 13))
                                .foregroundColor(SolTokens.ink450)
                        }
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(SolTokens.green800)
                                .font(.system(size: 14))
                            Text(officialDataBadge)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(SolTokens.green800)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(SolTokens.green800.opacity(0.12))
                        .cornerRadius(6)
                    }
                    
                    Divider()
                        .overlay(SolTokens.paper300)
                    
                    // Key metadata grid
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(headcountLabel)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink600)
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(SolTokens.lav400)
                                Text(employeesCountString(selectedCompany.employeeCount))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ceoLabel)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink600)
                            HStack(spacing: 6) {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(SolTokens.lav400)
                                Text(selectedCompany.ceoName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(naceLabel)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(SolTokens.ink600)
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(SolTokens.lav400)
                                Text("\(selectedCompany.naceCode) · \(selectedCompany.naceDescription)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(SolTokens.lav400)
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .background(SolTokens.paper100)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.98)),
                    removal: .opacity
                ))
            }
        }
    }
    
    // MARK: - Step 2: Statutory Gap Analysis (Full Width)
    private var fullStep2StatutoryGap: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(step2Title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(step2Subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(SolTokens.ink450)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 12) {
                ForEach(derivedRules) { rule in
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: rule.severity == "red" ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(rule.severity == "red" ? SolTokens.red700 : SolTokens.amber400)
                            .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 10) {
                                Text(rule.title)
                                    .font(.system(size: 14.5, weight: .bold))
                                    .foregroundColor(.white)
                                Text(rule.statute)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(SolTokens.lav400)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(SolTokens.plum900)
                                    .cornerRadius(4)
                            }
                            
                            Text(rule.explanation)
                                .font(.system(size: 12.5))
                                .foregroundColor(SolTokens.ink450)
                                .lineSpacing(2)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(SolTokens.amber400)
                                .frame(width: 5, height: 5)
                            Text(mustVerifyPill)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(SolTokens.amber400)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4.5)
                        .background(SolTokens.amber400.opacity(0.12))
                        .cornerRadius(5)
                    }
                    .padding(16)
                    .background(SolTokens.paper100)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
                }
                
                // Tariff Agreement Question (Contextual legal refinement)
                fullTariffSection
                
                // Baseline callout
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(SolTokens.lav400)
                        .font(.system(size: 16))
                    Text(step2BannerText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SolTokens.lav400)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SolTokens.plum900.opacity(0.35))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.lav500.opacity(0.3), lineWidth: 1))
            }
        }
    }
    
    // MARK: - Tariff Question Section (Moved to Step 2)
    private var fullTariffSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tariffQuestionTitle)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundColor(.white)
                Text(tariffQuestionSubtitle)
                    .font(.system(size: 12))
                    .foregroundColor(SolTokens.ink450)
            }
            
            HStack(spacing: 12) {
                fullTariffOptionButton(id: "no", title: tariffNoTitle, desc: tariffNoDesc)
                fullTariffOptionButton(id: "yes", title: tariffYesTitle, desc: tariffYesDesc)
                fullTariffOptionButton(id: "unsure", title: tariffUnsureTitle, desc: tariffUnsureDesc)
            }
        }
        .padding(16)
        .background(SolTokens.paper100)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(SolTokens.paper300, lineWidth: 1))
    }
    
    private func fullTariffOptionButton(id: String, title: String, desc: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                hasTariff = id
                updateDerivedRules()
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Circle()
                        .stroke(hasTariff == id ? SolTokens.lav400 : SolTokens.ink600, lineWidth: 1.5)
                        .background(Circle().fill(hasTariff == id ? SolTokens.lav500 : Color.clear))
                        .frame(width: 12, height: 12)
                    Text(title)
                        .font(.system(size: 12.5, weight: hasTariff == id ? .bold : .medium))
                        .foregroundColor(hasTariff == id ? .white : SolTokens.ink700)
                }
                Text(desc)
                    .font(.system(size: 10.5))
                    .foregroundColor(SolTokens.ink600)
                    .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(hasTariff == id ? SolTokens.plum900.opacity(0.4) : SolTokens.paper200)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasTariff == id ? SolTokens.lav500 : SolTokens.paper300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Step 3: Connect 1 Source (Full Width)
    private var fullStep3ConnectSource: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(step3Title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(step3Subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(SolTokens.ink450)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 14) {
                fullSourceOptionTile(
                    id: "tripletex",
                    icon: "bolt.horizontal.fill",
                    title: "Tripletex / Simployer One",
                    badge: tripletexBadge,
                    desc: tripletexDesc
                )
                
                fullSourceOptionTile(
                    id: "folder",
                    icon: "folder.badge.gearshape",
                    title: folderTileTitle,
                    badge: folderTileBadge,
                    desc: folderTileDesc
                )
                
                fullSourceOptionTile(
                    id: "sample",
                    icon: "sparkles.rectangle.stack",
                    title: sampleTileTitle,
                    badge: sampleTileBadge,
                    desc: sampleTileDesc
                )
            }
            
            if isConnectingSource {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: connectProgress, total: 1.0)
                        .tint(SolTokens.lav500)
                    HStack {
                        Text(connectStatusMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SolTokens.lav400)
                        Spacer()
                        Text("\(Int(connectProgress * 100))%")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(SolTokens.ink450)
                    }
                }
                .padding(14)
                .background(SolTokens.paper200)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
            }
        }
    }
    
    private func fullSourceOptionTile(id: String, icon: String, title: String, badge: String, desc: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedSource = id
            }
        } label: {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedSource == id ? SolTokens.lav500 : SolTokens.paper200)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(selectedSource == id ? .white : SolTokens.lav400)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 10) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text(badge)
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(SolTokens.lav400)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(SolTokens.plum900)
                            .cornerRadius(4)
                    }
                    Text(desc)
                        .font(.system(size: 12.5))
                        .foregroundColor(SolTokens.ink450)
                        .lineSpacing(2)
                }
                
                Spacer()
                
                Circle()
                    .stroke(selectedSource == id ? SolTokens.lav400 : SolTokens.ink600, lineWidth: 2)
                    .background(Circle().fill(selectedSource == id ? SolTokens.lav500 : Color.clear))
                    .frame(width: 16, height: 16)
                    .padding(.top, 4)
            }
            .padding(16)
            .background(selectedSource == id ? SolTokens.plum900.opacity(0.35) : SolTokens.paper100)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedSource == id ? SolTokens.lav500 : SolTokens.paper300, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Step 4: Menu Bar Hand-off (Full Width)
    private var fullStep4MenuBarHandOff: some View {
        VStack(spacing: 28) {
            // Native macOS Menu Bar Visual
            VStack(spacing: 14) {
                HStack(spacing: 16) {
                    Image(systemName: "apple.logo")
                        .foregroundColor(SolTokens.ink450)
                    Text("Finder")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Text("File  Edit  View  Go  Window  Help")
                        .font(.system(size: 12))
                        .foregroundColor(SolTokens.ink600)
                    Spacer()
                    
                    // The glowing Comply Status item
                    HStack(spacing: 6) {
                        SimployerLogoView(tint: SolTokens.lav400)
                            .frame(width: 14, height: 14)
                        Circle()
                            .fill(SolTokens.amber400)
                            .frame(width: 5.5, height: 5.5)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(SolTokens.plum900)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(SolTokens.lav400, lineWidth: 1)
                    )
                    
                    Text("17:15")
                        .font(.system(size: 12))
                        .foregroundColor(SolTokens.ink450)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(SolTokens.paper200)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
                
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(SolTokens.lav400)
                        .padding(.trailing, 65)
                }
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 8) {
                Text(step4Title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text(step4Subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(SolTokens.ink450)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(3)
            }
            
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SolTokens.green800)
                        .font(.system(size: 15))
                    Text(contractsAuditedBadge)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SolTokens.green800)
                        .font(.system(size: 15))
                    Text(gapsReadyBadge)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SolTokens.green800)
                        .font(.system(size: 15))
                    Text(auditTrailBadge)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(14)
            .background(SolTokens.paper100)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SolTokens.paper300, lineWidth: 1))
        }
    }
    
    // MARK: - Full Wizard Footer
    private var fullWizardFooter: some View {
        HStack {
            if currentStep > 1 && currentStep < 4 {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                        Text(backButtonTitle)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8.5)
                    .background(SolTokens.paper100)
                    .foregroundColor(SolTokens.ink600)
                    .cornerRadius(7)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(SolTokens.paper300, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            if currentStep == 1 {
                if hasSearched {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep = 2
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(analyzeButtonTitle)
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 13.5, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(SolTokens.plum900)
                        .foregroundColor(.white)
                        .cornerRadius(7)
                        .shadow(color: SolTokens.plum900.opacity(0.35), radius: 8, y: 2)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            } else if currentStep == 2 {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentStep = 3
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(connectSourcesButtonTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 13.5, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(SolTokens.plum900)
                    .foregroundColor(.white)
                    .cornerRadius(7)
                    .shadow(color: SolTokens.plum900.opacity(0.35), radius: 8, y: 2)
                }
                .buttonStyle(.plain)
            } else if currentStep == 3 {
                Button {
                    runSourceConnectSequence()
                } label: {
                    HStack(spacing: 8) {
                        Text(startAuditButtonTitle)
                        Image(systemName: "checkmark")
                    }
                    .font(.system(size: 13.5, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(selectedSource.isEmpty ? SolTokens.paper300 : SolTokens.plum900)
                    .foregroundColor(selectedSource.isEmpty ? SolTokens.ink600 : .white)
                    .cornerRadius(7)
                    .shadow(color: selectedSource.isEmpty ? Color.clear : SolTokens.plum900.opacity(0.35), radius: 8, y: 2)
                }
                .buttonStyle(.plain)
                .disabled(isConnectingSource || selectedSource.isEmpty)
            } else if currentStep == 4 {
                Button {
                    finishOnboarding()
                } label: {
                    HStack(spacing: 8) {
                        Text(openControlRoomButtonTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 11)
                    .background(SolTokens.plum900)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(color: SolTokens.plum900.opacity(0.4), radius: 10, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 18)
        .background(SolTokens.canvasRoot)
    }
    
    // MARK: - Actions
    private func performInitialSearch() {
        updateDerivedRules()
    }
    
    private func updateDerivedRules() {
        derivedRules = CompanyLookupService.deriveStatutoryObligations(
            for: selectedCompany,
            language: store.language,
            hasTariffAgreement: hasTariff == "yes"
        )
    }
    
    private func triggerLookup() {
        guard !isSearching else { return }
        isSearching = true
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let effectiveQuery = query.isEmpty ? "923 456 789" : query
        
        Task {
            let results = await CompanyLookupService.shared.lookup(query: effectiveQuery)
            await MainActor.run {
                self.isSearching = false
                if let first = results.first {
                    self.selectedCompany = first
                    self.updateDerivedRules()
                }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    self.hasSearched = true
                }
            }
        }
    }
    
    
    private func runSourceConnectSequence() {
        isConnectingSource = true
        connectProgress = 0.1
        
        let sourceName: String
        switch selectedSource {
        case "tripletex":
            sourceName = "Tripletex / Simployer One"
        case "folder":
            sourceName = lang == .se ? "lokal avtalsmapp" : (lang == .en ? "local contract folder" : "lokal kontraktmappe")
        default:
            sourceName = lang == .se ? "förifyllt demoarkiv" : (lang == .en ? "pre-calibrated demo archive" : "forhåndsutfylt demoarkiv")
        }
        
        switch lang {
        case .no:
            connectStatusMessage = "Kobler til \(sourceName)..."
        case .se:
            connectStatusMessage = "Ansluter till \(sourceName)..."
        case .en:
            connectStatusMessage = "Connecting to \(sourceName)..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.connectProgress = 0.45
            switch self.lang {
            case .no:
                self.connectStatusMessage = "Henter \(self.selectedCompany.employeeCount) aktive ansettelsesforhold..."
            case .se:
                self.connectStatusMessage = "Läser in \(self.selectedCompany.employeeCount) aktiva anställningsavtal..."
            case .en:
                self.connectStatusMessage = "Ingesting \(self.selectedCompany.employeeCount) active employee records..."
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.connectProgress = 0.85
            switch self.lang {
            case .no:
                self.connectStatusMessage = "Analyserer klausuler mot AML § 14-6 & § 6-1..."
            case .se:
                self.connectStatusMessage = "Analyserar avtalsklausuler mot gällande lagkrav..."
            case .en:
                self.connectStatusMessage = "Auditing clauses against statutory rules..."
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.connectProgress = 1.0
            switch self.lang {
            case .no:
                self.connectStatusMessage = "Revisjon fullført. 3 lovavvik oppdaget."
            case .se:
                self.connectStatusMessage = "Revision slutförd. 3 lagavvikelser identifierade."
            case .en:
                self.connectStatusMessage = "Audit complete. 3 compliance violations identified."
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.isConnectingSource = false
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    self.currentStep = 4
                }
            }
        }
    }
    
    private func finishOnboarding() {
        store.completeOnboarding(with: selectedCompany, source: selectedSource)
    }
    
    // MARK: - Localized Strings Helpers
    private var wizardSubtitle: String {
        switch lang {
        case .no: return "Oppstartsveiviser · Autonom regelefterlevelse"
        case .se: return "Uppstartsguide · Autonom lagefterlevnad"
        case .en: return "Setup Wizard · Autonomous Continuous Compliance"
        }
    }
    
    private func stepLabel(for step: Int) -> String {
        switch step {
        case 1:
            switch lang {
            case .no: return "Virksomhet"
            case .se: return "Företag"
            case .en: return "Company"
            }
        case 2:
            switch lang {
            case .no: return "Lovkrav"
            case .se: return "Lagkrav"
            case .en: return "Legal Baseline"
            }
        case 3:
            switch lang {
            case .no: return "Kilde"
            case .se: return "Datakälla"
            case .en: return "Data Source"
            }
        case 4:
            switch lang {
            case .no: return "Menylinje"
            case .se: return "Menyrad"
            case .en: return "Menu Bar"
            }
        default:
            return ""
        }
    }
    

    // Step 1
    private var step1Title: String {
        switch lang {
        case .no: return "Hvilket selskap vil du sikre?"
        case .se: return "Vilket bolag vill du säkra?"
        case .en: return "Which company do you want to secure?"
        }
    }
    
    private var step1Subtitle: String {
        switch lang {
        case .no: return "Oppgi organisasjonsnummer eller firmanavn. Vi henter selskapsform, ansatte og gjeldende lovkrav direkte fra Enhetsregisteret i Brønnøysund."
        case .se: return "Ange organisationsnummer eller företagsnamn. Vi hämtar bolagsform, anställda och gällande lagkrav direkt från bolagsregistret."
        case .en: return "Enter 9-digit company registration number or name. We pull legal form, headcount, and statutory obligations directly from the public registry."
        }
    }
    
    private var searchPlaceholder: String {
        switch lang {
        case .no: return "Skriv inn 9-sifret org.nr eller selskapsnavn..."
        case .se: return "Skriv in 9-siffrigt org.nr eller företagsnamn..."
        case .en: return "Enter 9-digit org. number or company name..."
        }
    }
    
    private var searchButtonLabel: String {
        switch lang {
        case .no: return "Søk i Brønnøysund"
        case .se: return "Sök i bolagsregister"
        case .en: return "Search Registry"
        }
    }
    
    private var officialDataBadge: String {
        switch lang {
        case .no: return "Offentlig registerdata"
        case .se: return "Offentlig registerdata"
        case .en: return "Official Registry Data"
        }
    }
    
    private var headcountLabel: String {
        switch lang {
        case .no: return "REGISTRERTE ANSATTE"
        case .se: return "REGISTRERADE ANSTÄLLDA"
        case .en: return "REGISTERED HEADCOUNT"
        }
    }
    
    private func employeesCountString(_ count: Int) -> String {
        switch lang {
        case .no: return "\(count) ansatte"
        case .se: return "\(count) anställda"
        case .en: return "\(count) employees"
        }
    }
    
    private var ceoLabel: String {
        switch lang {
        case .no: return "DAGLIG LEDER"
        case .se: return "VD / FIRMATECKNARE"
        case .en: return "MANAGING DIRECTOR / CEO"
        }
    }
    
    private var naceLabel: String {
        switch lang {
        case .no: return "BRANSJEKODE (NACE)"
        case .se: return "BRANSCHKOD (SNI/NACE)"
        case .en: return "INDUSTRY CODE (NACE)"
        }
    }
    
    private var tariffQuestionTitle: String {
        switch lang {
        case .no: return "Er selskapet bundet av tariffavtale?"
        case .se: return "Omfattas bolaget av kollektivavtal?"
        case .en: return "Is the company bound by a collective bargaining agreement?"
        }
    }
    
    private var tariffQuestionSubtitle: String {
        switch lang {
        case .no: return "Tariffavtaler påvirker normalarbeidstid (37,5t vs 40t), feriedager og overtidstillegg."
        case .se: return "Kollektivavtal påverkar ordinarie arbetstid (37,5h vs 40h), semesterdagar och övertidskompensation."
        case .en: return "Collective agreements govern standard working hours (37.5h vs 40h), vacation allowance, and overtime premiums."
        }
    }
    
    private var tariffNoTitle: String {
        switch lang {
        case .no: return "Nei (Standard lovverk)"
        case .se: return "Nej (Standard lagregler)"
        case .en: return "No (Standard statutory law)"
        }
    }
    
    private var tariffNoDesc: String {
        switch lang {
        case .no: return "Følger arbeidsmiljølovens standardregler"
        case .se: return "Följer arbetsmiljölagens minimikrav"
        case .en: return "Follows statutory labor act standards"
        }
    }
    
    private var tariffYesTitle: String {
        switch lang {
        case .no: return "Ja (Tariffbundet)"
        case .se: return "Ja (Kollektivavtal)"
        case .en: return "Yes (CBA covered)"
        }
    }
    
    private var tariffYesDesc: String {
        switch lang {
        case .no: return "NHO, Virke eller direkte fagforeningsavtale"
        case .se: return "Svenskt Näringsliv, Almega eller fackavtal"
        case .en: return "NHO, Virke, or direct union agreement"
        }
    }
    
    private var tariffUnsureTitle: String {
        switch lang {
        case .no: return "Vet ikke"
        case .se: return "Vet ej"
        case .en: return "Unsure"
        }
    }
    
    private var tariffUnsureDesc: String {
        switch lang {
        case .no: return "Avklarer i neste revisjonssyklus"
        case .se: return "Klargörs i nästa revisionscykel"
        case .en: return "Clarify during next audit cycle"
        }
    }
    
    private var analyzeButtonTitle: String {
        switch lang {
        case .no: return "Analyser lovkrav for selskapet"
        case .se: return "Analysera lagkrav för bolaget"
        case .en: return "Analyze Statutory Obligations"
        }
    }
    
    private var backButtonTitle: String {
        switch lang {
        case .no: return "Tilbake"
        case .se: return "Tillbaka"
        case .en: return "Back"
        }
    }
    
    // Step 2
    private var step2Title: String {
        switch lang {
        case .no: return "Ditt lovpålagte regelsett"
        case .se: return "Dina lagstadgade skyldigheter"
        case .en: return "Your Statutory Legal Baseline"
        }
    }
    
    private var step2Subtitle: String {
        switch lang {
        case .no: return "Basert på \(selectedCompany.employeeCount) ansatte og bransjekode \(selectedCompany.naceCode) utløser arbeidsmiljøloven følgende aktive plikter for \(selectedCompany.name):"
        case .se: return "Baserat på \(selectedCompany.employeeCount) anställda och branschkod \(selectedCompany.naceCode) aktiverar arbetsrätten följande obligatoriska krav för \(selectedCompany.name):"
        case .en: return "Based on \(selectedCompany.employeeCount) employees and NACE code \(selectedCompany.naceCode), labor law triggers the following active duties for \(selectedCompany.name):"
        }
    }
    
    private var scanningStatutesLabel: String {
        switch lang {
        case .no: return "Analyserer arbeidsmiljøloven, forskrifter og lovfestede terskler..."
        case .se: return "Analyserar arbetsmiljölagen, föreskrifter och lagstadgade trösklar..."
        case .en: return "Analyzing labor laws, regulations, and statutory thresholds..."
        }
    }
    
    private var mustVerifyPill: String {
        switch lang {
        case .no: return "Må verifiseres"
        case .se: return "Måste verifieras"
        case .en: return "Verification Required"
        }
    }
    
    private var step2BannerText: String {
        switch lang {
        case .no: return "Foreløpig status: Uverifisert. Koble til 1 kilde i neste steg for å se om avtalene oppfyller kravene."
        case .se: return "Preliminär status: Overifierad. Anslut 1 datakälla i nästa steg för att kontrollera om avtalen uppfyller kraven."
        case .en: return "Preliminary status: Unverified. Connect 1 telemetry source in the next step to audit compliance."
        }
    }
    
    private var connectSourcesButtonTitle: String {
        switch lang {
        case .no: return "Koble til kilder for revisjon"
        case .se: return "Anslut datakällor för revision"
        case .en: return "Connect Sources for Audit"
        }
    }
    
    // Step 3
    private var step3Title: String {
        switch lang {
        case .no: return "Koble til 1 kilde for umiddelbar status"
        case .se: return "Anslut 1 källa för omedelbar status"
        case .en: return "Connect 1 Source for Instant Status"
        }
    }
    
    private var step3Subtitle: String {
        switch lang {
        case .no: return "Velg hvordan Comply skal lese inn dataene for \(selectedCompany.name). Én kilde er nok for å gi deg et komplett bilde:"
        case .se: return "Välj hur Comply ska läsa in uppgifterna för \(selectedCompany.name). En källa räcker för att ge en heltäckande bild:"
        case .en: return "Choose how Comply should ingest data for \(selectedCompany.name). A single source is sufficient for a complete picture:"
        }
    }
    
    private var tripletexBadge: String {
        switch lang {
        case .no: return "Anbefalt · 1-klikk OAuth"
        case .se: return "Rekommenderat · 1-klicks OAuth"
        case .en: return "Recommended · 1-click OAuth"
        }
    }
    
    private var tripletexDesc: String {
        switch lang {
        case .no: return "Henter automatisk alle \(selectedCompany.employeeCount) ansatte, stillingskategorier, hire dates og arbeidstidsavtaler direkte via sikker integrasjon."
        case .se: return "Hämtar automatiskt samtliga \(selectedCompany.employeeCount) anställda, befattningar, anställningsdatum och arbetstidsavtal via säker integration."
        case .en: return "Automatically ingests all \(selectedCompany.employeeCount) registered employees, job titles, start dates, and work hour terms via secure API."
        }
    }
    
    private var folderTileTitle: String {
        switch lang {
        case .no: return "Dra og slipp kontraktmappe"
        case .se: return "Dra och släpp avtalsmapp"
        case .en: return "Drag & Drop Contract Folder"
        }
    }
    
    private var folderTileBadge: String {
        switch lang {
        case .no: return "Lokal PDF / Word"
        case .se: return "Lokal PDF / Word"
        case .en: return "Local PDF / Word"
        }
    }
    
    private var folderTileDesc: String {
        switch lang {
        case .no: return "Slipp standardavtaler eller personalhåndbok rett inn for direkte lokal parsing mot de nye AML § 14-6 kravene."
        case .se: return "Släpp standardavtal eller personalhandbok direkt för lokal granskning mot de nya lagkraven."
        case .en: return "Drop standard contracts or staff handbook directly for client-side statutory clause parsing."
        }
    }
    
    private var sampleTileTitle: String {
        switch lang {
        case .no: return "Bruk forhåndsutfylt arkiv (Demo)"
        case .se: return "Använd förifyllt arkiv (Demo)"
        case .en: return "Use Pre-calibrated Archive (Demo)"
        }
    }
    
    private var sampleTileBadge: String {
        switch lang {
        case .no: return "Umiddelbar test"
        case .se: return "Omedelbar test"
        case .en: return "Instant test"
        }
    }
    
    private var sampleTileDesc: String {
        switch lang {
        case .no: return "Ferdig kalibrert datasett for Fjord Dynamics AS med 7 ansettelsesavtaler og personalhåndbok for fredagsdemonstrasjon."
        case .se: return "Färdigkalibrerat dataset för Fjord Dynamics AS med 7 anställningsavtal och personalhandbok för ledningspresentation."
        case .en: return "Pre-loaded dataset for Fjord Dynamics AS with 7 contracts and staff handbook for leadership presentation."
        }
    }
    
    private var startAuditButtonTitle: String {
        switch lang {
        case .no: return "Start revisjon og fullfør"
        case .se: return "Starta revision och slutför"
        case .en: return "Run Audit & Complete Setup"
        }
    }
    
    // Step 4
    private var step4Title: String {
        switch lang {
        case .no: return "Comply er nå aktiv i menylinjen"
        case .se: return "Comply är nu aktiv i menyraden"
        case .en: return "Comply is now active in your menu bar"
        }
    }
    
    private var step4Subtitle: String {
        switch lang {
        case .no: return "\(selectedCompany.name) overvåkes kontinuerlig. Du blir kun varslet når nye lovendringer eller frister krever lederhandling. Ingen unødvendig administrasjon."
        case .se: return "\(selectedCompany.name) övervakas kontinuerligt. Du notifieras endast när nya lagändringar eller tidsfrister kräver ledningsåtgärd. Ingen onödig administration."
        case .en: return "\(selectedCompany.name) is continuously monitored. You will only be alerted when legal changes or statutory deadlines require leadership action. Zero manual overhead."
        }
    }
    
    private var contractsAuditedBadge: String {
        switch lang {
        case .no: return "7 kontrakter analysert"
        case .se: return "7 avtal analyserade"
        case .en: return "7 contracts audited"
        }
    }
    
    private var gapsReadyBadge: String {
        switch lang {
        case .no: return "3 lovavvik klare for løsning"
        case .se: return "3 lagavvikelser klara för åtgärd"
        case .en: return "3 violations ready to resolve"
        }
    }
    
    private var auditTrailBadge: String {
        switch lang {
        case .no: return "100% juridisk sporbarhet"
        case .se: return "100% juridisk spårbarhet"
        case .en: return "100% legal audit trail"
        }
    }
    
    private var openControlRoomButtonTitle: String {
        switch lang {
        case .no: return "Åpne Comply Control Room"
        case .se: return "Öppna Comply Control Room"
        case .en: return "Open Comply Control Room"
        }
    }
}
