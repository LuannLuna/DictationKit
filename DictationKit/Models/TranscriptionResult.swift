import Foundation

public struct TranscriptionResult {
    public let transcript: String
    public let confidence: Double
    public let isFinal: Bool

    public init(transcript: String, confidence: Double, isFinal: Bool) {
        self.transcript = transcript
        self.confidence = confidence
        self.isFinal = isFinal
    }
}

public enum TranscriptionError: Error, LocalizedError {
    case audioRecordingFailed
    case networkError
    case apiError(String)
    case permissionDenied
    case invalidAudioFormat

    public var errorDescription: String? {
        switch self {
        case .audioRecordingFailed:
            return "Failed to record audio"
        case .networkError:
            return "Network connection error"
        case .apiError(let message):
            return "API Error: \(message)"
        case .permissionDenied:
            return "Microphone permission denied"
        case .invalidAudioFormat:
            return "Invalid audio format"
        }
    }
}
