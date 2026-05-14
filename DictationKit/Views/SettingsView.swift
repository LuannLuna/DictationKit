import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Audio Quality") {
                    Picker("Quality", selection: $appState.userSettings.audioQuality) {
                        ForEach(AudioQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue.capitalized)
                                .tag(quality)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Transcription Options") {
                    Toggle("Auto Capitalization", isOn: $appState.userSettings.autoCapitalization)
                    Toggle("Auto Punctuation", isOn: $appState.userSettings.autoPunctuation)
                }

                Section("Language") {
                    Picker("Language", selection: $appState.userSettings.language) {
                        Text("English (US)").tag("en-US")
                        Text("Spanish").tag("es-ES")
                        Text("French").tag("fr-FR")
                        Text("German").tag("de-DE")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        appState.saveUserSettings()
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SettingsView_Preview: View {
    @StateObject private var appState = AppState()

    var body: some View {
        SettingsView()
            .environmentObject(appState)
    }
}

#Preview {
    SettingsView_Preview()
}
#endif
