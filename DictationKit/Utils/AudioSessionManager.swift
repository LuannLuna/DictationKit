import Foundation
import AVFoundation

public class AudioSessionManager {
    public static let shared = AudioSessionManager()
    
    private init() {}
    
    public func configureAudioSession() async throws {
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
    
    public func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
}
