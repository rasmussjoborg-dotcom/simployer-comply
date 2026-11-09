import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Explicitly set dock icon to eliminate macOS LaunchServices icon caching issues
        if let iconUrl = Bundle.main.url(forResource: "AppIcon-1024", withExtension: "png"),
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
        }
        
        // MARK: - Native macOS Menu Bar Item (Simployer Logo Icon)
        MenuBarExtra {
            MenuBarContentView(store: store, updater: updater)
        } label: {
            if let icon = SimployerLogoAsset.menuBarIcon {
                Image(nsImage: icon)
            } else {
                Image(systemName: "shield.checkered")
            }
        }
    }
}

struct MenuBarContentView: View {
    @ObservedObject var store: ComplyStore
    @ObservedObject var updater: ComplyUpdater
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        let l10n = store.l10n
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                SimployerLogoView()
                    .frame(width: 16, height: 16)
                    .padding(3)
                    .background(SolTokens.plum900)
                    .cornerRadius(4)
                
                Text("Simployer Comply")
                    .font(.headline)
                    .foregroundColor(SolTokens.ink900)
            }
            
            Text("Fjord Dynamics AS · \(store.currentScenario.headcount) \(l10n.staff8.components(separatedBy: " ").last ?? "ansatte")")
                .font(.caption)
                .foregroundColor(SolTokens.ink600)
            
            Divider()
            
            Button(l10n.menuOpenControlRoom) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "main")
            }
            .keyboardShortcut("o", modifiers: .command)
            
            Button(store.language == .se ? "Sök efter uppdateringar…" : (store.language == .no ? "Se etter oppdateringer…" : "Check for Updates…")) {
                updater.checkForUpdates()
            }
            .disabled(!updater.canCheckForUpdates)
            
            Divider()
            
            Text(l10n.menuStatusLabel)
                .font(.caption2)
                .foregroundColor(SolTokens.green800)
            
            Button(l10n.menuQuit) {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(4)
    }
}
