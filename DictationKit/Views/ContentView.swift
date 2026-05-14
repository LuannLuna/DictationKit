import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Dictation Kit")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Tap to start dictation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Recording Button
                RecordingButton(
                    isRecording: appState.isRecording,
                    onStart: { appState.startRecording() },
                    onStop: { appState.stopRecording() }
                )

                // Transcript Display
                TranscriptView(
                    currentTranscript: appState.currentTranscript,
                    lastTranscript: appState.lastTranscript
                )

                Spacer()

                // Settings Button
                Button(action: { showingSettings = true }) {
                    Label("Settings", systemImage: "gear")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .alert("Error", isPresented: $appState.showError) {
            Button("OK") { }
        } message: {
            Text(appState.errorMessage ?? "An unknown error occurred")
        }
    }
}

#if DEBUG
struct ContentView_Preview: View {
    @StateObject private var appState = AppState()

    var body: some View {
        ContentView()
            .environmentObject(appState)
    }
}

#Preview {
    SettingsView_Preview()
}
#endif
