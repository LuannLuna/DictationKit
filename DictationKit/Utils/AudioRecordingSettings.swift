import AVFoundation

public struct AudioRecordingSettings {
    public let format: AudioFormatID
    public let sampleRate: Double
    public let numberOfChannels: Int
    public let quality: AVAudioQuality
    
    public static func settings(for quality: AudioQuality) -> AudioRecordingSettings {
        return AudioRecordingSettings(
            format: kAudioFormatMPEG4AAC,
            sampleRate: Double(quality.sampleRate),
            numberOfChannels: 1,
            quality: .high
        )
    }
    
    public var dictionary: [String: Any] {
        return [
            AVFormatIDKey: Int(format),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: numberOfChannels,
            AVEncoderAudioQualityKey: quality.rawValue
        ]
    }
} 

public enum AudioQuality: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    public var sampleRate: Int {
        switch self {
        case .low: return 8000
        case .medium: return 16000
        case .high: return 44100
        }
    }

    public var bitRate: Int {
        switch self {
        case .low: return 64
        case .medium: return 128
        case .high: return 256
        }
    }
}
