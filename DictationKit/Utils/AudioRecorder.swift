import Foundation
import AVFoundation

@MainActor
class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    
    override init() {
        super.init()
    }
    
    func startRecording() async throws {
        let settings = AudioRecordingSettings.settings(for: AppGroupsManager.shared.getUserSettings().audioQuality)
        
        let audioFilename = getTemporaryAudioFileURL()
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings.dictionary)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingStartTime = Date()
            startRecordingTimer()
        } catch {
            throw TranscriptionError.audioRecordingFailed
        }
    }
    
    func stopRecording() async throws -> URL {
        guard let recorder = audioRecorder else {
            throw TranscriptionError.audioRecordingFailed
        }
        
        recorder.stop()
        audioRecorder = nil
        isRecording = false
        stopRecordingTimer()
        
        let audioURL = recorder.url
        return audioURL
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingDuration = 0
        recordingStartTime = nil
    }
    
    private func getTemporaryAudioFileURL() -> URL {
        let filename = "recording_\(Date().timeIntervalSince1970).m4a"
        return FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
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
