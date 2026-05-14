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
