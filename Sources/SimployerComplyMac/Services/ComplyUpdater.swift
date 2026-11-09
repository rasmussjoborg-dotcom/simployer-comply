import SwiftUI
import Sparkle
import Combine

@MainActor
public final class ComplyUpdater: ObservableObject {
    public static let shared = ComplyUpdater()
    
    public let updaterController: SPUStandardUpdaterController
    @Published public var canCheckForUpdates: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        let controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        self.updaterController = controller
        
        controller.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canCheck in
                self?.canCheckForUpdates = canCheck
            }
            .store(in: &cancellables)
    }
    
    public func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
