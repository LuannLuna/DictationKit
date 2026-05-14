import Foundation

public class AppGroupsManager {
    public static let shared = AppGroupsManager()
    private let suiteName = "group.com.luannluna.DictationKit"
    private let defaults: UserDefaults?
    
    private init() {
        self.defaults = UserDefaults(suiteName: suiteName)
    }
    
    public func saveTranscript(_ transcript: String) {
        defaults?.set(transcript, forKey: "lastTranscript")
        defaults?.set(Date(), forKey: "lastTranscriptDate")
    }
    
    public func getLastTranscript() -> String? {
        return defaults?.string(forKey: "lastTranscript")
    }
    
    public func getLastTranscriptDate() -> Date? {
        return defaults?.object(forKey: "lastTranscriptDate") as? Date
    }
    
    public func saveUserSettings(_ settings: UserSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults?.set(data, forKey: "userSettings")
        }
    }
    
    public func getUserSettings() -> UserSettings {
        guard let data = defaults?.data(forKey: "userSettings"),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return UserSettings.default
        }
        return settings
    }
} 