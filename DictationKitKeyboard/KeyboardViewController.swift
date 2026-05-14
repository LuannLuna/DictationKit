import UIKit
import AVFoundation
import Combine

class KeyboardViewController: UIInputViewController {
    
    // MARK: - UI Components
    private var nextKeyboardButton: UIButton!
    private var dictationButton: UIButton!
    private var transcriptLabel: UILabel!
    private var statusLabel: UILabel!
    private var containerView: UIView!
    
    // MARK: - State Management
    private var isRecording = false
    private var currentTranscript = ""
    private var lastTranscript = ""
    private var errorMessage: String?
    
    // MARK: - Audio Components
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    
    // MARK: - Deepgram Service
    private let deepgramService = DeepgramService()
    
    // MARK: - App Groups Manager
    private let appGroupsManager = AppGroupsManager.shared
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLastTranscript()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        updateTextColor()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupContainerView()
        setupDictationButton()
        setupTranscriptLabel()
        setupStatusLabel()
        setupNextKeyboardButton()
        setupConstraints()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
    }
    
    private func setupDictationButton() {
        dictationButton = UIButton(type: .system)
        dictationButton.setTitle("🎤", for: .normal)
        dictationButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        dictationButton.backgroundColor = UIColor.systemBlue
        dictationButton.layer.cornerRadius = 25
        dictationButton.translatesAutoresizingMaskIntoConstraints = false
        dictationButton.addTarget(self, action: #selector(dictationButtonTapped), for: .touchUpInside)
        containerView.addSubview(dictationButton)
    }
    
    private func setupTranscriptLabel() {
        transcriptLabel = UILabel()
        transcriptLabel.text = "Tap 🎤 to start dictation"
        transcriptLabel.font = UIFont.systemFont(ofSize: 14)
        transcriptLabel.textColor = UIColor.secondaryLabel
        transcriptLabel.numberOfLines = 3
        transcriptLabel.textAlignment = .center
        transcriptLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(transcriptLabel)
    }
    
    private func setupStatusLabel() {
        statusLabel = UILabel()
        statusLabel.text = ""
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = UIColor.systemGreen
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statusLabel)
    }
    
    private func setupNextKeyboardButton() {
        self.nextKeyboardButton = UIButton(type: .system)
        self.nextKeyboardButton.setTitle("🌐", for: [])
        self.nextKeyboardButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        containerView.addSubview(self.nextKeyboardButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Dictation button
            dictationButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dictationButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -20),
            dictationButton.widthAnchor.constraint(equalToConstant: 50),
            dictationButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Transcript label
            transcriptLabel.topAnchor.constraint(equalTo: dictationButton.bottomAnchor, constant: 16),
            transcriptLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            transcriptLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: transcriptLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Next keyboard button
            nextKeyboardButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 40),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Dictation Actions
    @objc private func dictationButtonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        Task {
            do {
                try await configureAudioSession()
                try await startAudioRecording()
                
                await MainActor.run {
                    isRecording = true
                    updateDictationButton()
                    statusLabel.text = "Recording..."
                    statusLabel.textColor = UIColor.systemRed
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    private func stopRecording() {
        Task {
            do {
                let audioURL = try await stopAudioRecording()
                
                await MainActor.run {
                    isRecording = false
                    updateDictationButton()
                    statusLabel.text = "Transcribing..."
                    statusLabel.textColor = UIColor.systemOrange
                }
                
                // Transcribe audio
                let result = try await deepgramService.transcribe(audioURL: audioURL)
                
                await MainActor.run {
                    currentTranscript = result.transcript
                    lastTranscript = result.transcript
                    updateTranscriptDisplay()
                    statusLabel.text = "Transcription complete"
                    statusLabel.textColor = UIColor.systemGreen
                    
                    // Insert text into the text field
                    textDocumentProxy.insertText(result.transcript)
                    
                    // Save transcript
                    appGroupsManager.saveTranscript(result.transcript)
                }
                
                deactivateAudioSession()
                
            } catch {
                await handleError(error)
            }
        }
    }
    
    // MARK: - Audio Recording
    private func configureAudioSession() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
                try audioSession.setActive(true)
                
                audioSession.requestRecordPermission { allowed in
                    if allowed {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: TranscriptionError.permissionDenied)
                    }
                }
            } catch {
                continuation.resume(throwing: TranscriptionError.audioRecordingFailed)
            }
        }
    }
    
    private func startAudioRecording() async throws {
        let settings = AudioRecordingSettings.settings(for: appGroupsManager.getUserSettings().audioQuality)
        let audioFilename = getTemporaryAudioFileURL()
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings.dictionary)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            recordingStartTime = Date()
            startRecordingTimer()
        } catch {
            throw TranscriptionError.audioRecordingFailed
        }
    }
    
    private func stopAudioRecording() async throws -> URL {
        guard let recorder = audioRecorder else {
            throw TranscriptionError.audioRecordingFailed
        }
        
        recorder.stop()
        audioRecorder = nil
        stopRecordingTimer()
        
        let audioURL = recorder.url
        return audioURL
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            let duration = Date().timeIntervalSince(startTime)
            self.updateRecordingStatus(duration: duration)
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil
    }
    
    private func getTemporaryAudioFileURL() -> URL {
        let filename = "keyboard_recording_\(Date().timeIntervalSince1970).m4a"
        return FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    }
    
    // MARK: - UI Updates
    private func updateDictationButton() {
        if isRecording {
            dictationButton.backgroundColor = UIColor.systemRed
            dictationButton.setTitle("⏹️", for: .normal)
        } else {
            dictationButton.backgroundColor = UIColor.systemBlue
            dictationButton.setTitle("🎤", for: .normal)
        }
    }
    
    private func updateTranscriptDisplay() {
        if !currentTranscript.isEmpty {
            transcriptLabel.text = currentTranscript
            transcriptLabel.textColor = UIColor.label
        } else {
            transcriptLabel.text = "Tap 🎤 to start dictation"
            transcriptLabel.textColor = UIColor.secondaryLabel
        }
    }
    
    private func updateRecordingStatus(duration: TimeInterval) {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        statusLabel.text = String(format: "Recording... %02d:%02d", minutes, seconds)
    }
    
    private func updateTextColor() {
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    // MARK: - Data Management
    private func loadLastTranscript() {
        lastTranscript = appGroupsManager.getLastTranscript() ?? ""
        if !lastTranscript.isEmpty {
            transcriptLabel.text = "Last: \(lastTranscript)"
            transcriptLabel.textColor = UIColor.secondaryLabel
        }
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) async {
        await MainActor.run {
            isRecording = false
            updateDictationButton()
            
            if let transcriptionError = error as? TranscriptionError {
                errorMessage = transcriptionError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            
            statusLabel.text = errorMessage
            statusLabel.textColor = UIColor.systemRed
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension KeyboardViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Audio recording failed")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio recording encode error: \(error)")
        }
    }
}
