import Combine

@MainActor
class AppState: ObservableObject {
    @Published var isRecording = false
    @Published var currentTranscript = ""
    @Published var lastTranscript = ""
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var userSettings = UserSettings.default

    private let audioRecorder = AudioRecorder()
    private let deepgramService = DeepgramService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadUserSettings()
        loadLastTranscript()

        // Observe transcript changes
        $currentTranscript
            .sink { [weak self] transcript in
                if !transcript.isEmpty {
                    self?.lastTranscript = transcript
                    AppGroupsManager.shared.saveTranscript(transcript)
                }
            }
            .store(in: &cancellables)
    }

    func startRecording() {
        Task {
            do {
                try await AudioSessionManager.shared.configureAudioSession()
                try await audioRecorder.startRecording()
                isRecording = true
                errorMessage = nil
            } catch {
                await handleError(error)
            }
        }
    }

    func stopRecording() {
        Task {
            do {
                let audioURL = try await audioRecorder.stopRecording()
                isRecording = false

                // Transcribe audio
                let result = try await deepgramService.transcribe(audioURL: audioURL)
                currentTranscript = result.transcript

                AudioSessionManager.shared.deactivateAudioSession()
            } catch {
                await handleError(error)
                isRecording = false
            }
        }
    }

    private func handleError(_ error: Error) async {
        await MainActor.run {
            if let transcriptionError = error as? TranscriptionError {
                errorMessage = transcriptionError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            showError = true
        }
    }

    private func loadUserSettings() {
        userSettings = AppGroupsManager.shared.getUserSettings()
    }

    private func loadLastTranscript() {
        lastTranscript = AppGroupsManager.shared.getLastTranscript() ?? ""
    }

    func saveUserSettings() {
        AppGroupsManager.shared.saveUserSettings(userSettings)
    }
}
