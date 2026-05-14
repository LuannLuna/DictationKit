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