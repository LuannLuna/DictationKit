import SwiftUI
import AVFoundation
import Combine

@main
struct DictationKitApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
