import SwiftUI

@main
struct SimployerComplyIOSApp: App {
    @StateObject private var store = ComplyStore.shared
    
    var body: some Scene {
        WindowGroup {
            IOSMainView()
                .environmentObject(store)
                .background(SolTokens.paper100)
                .preferredColorScheme(.dark)
        }
    }
}
