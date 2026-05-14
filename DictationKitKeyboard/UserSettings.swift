public struct UserSettings: Codable {
    public var autoCapitalization: Bool
    public var autoPunctuation: Bool
    public var language: String
    public var audioQuality: AudioQuality

    public static let `default` = UserSettings(
        autoCapitalization: true,
        autoPunctuation: true,
        language: "en-US",
        audioQuality: .high
    )

    public init(autoCapitalization: Bool, autoPunctuation: Bool, language: String, audioQuality: AudioQuality) {
        self.autoCapitalization = autoCapitalization
        self.autoPunctuation = autoPunctuation
        self.language = language
        self.audioQuality = audioQuality
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