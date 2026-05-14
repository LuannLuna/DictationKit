public class SecureConfigurationManager {
    public static let shared = SecureConfigurationManager()
    
    private let deepgramApiKey = "deepgramApiKey"
    private let fleksyLicenseKey = "fleksyLicenseKey"
    private let fleksyLicenseSecret = "fleksyLicenseSecret"

    private init() {}
    
    public func getDeepgramApiKey() -> String {
        return deepgramApiKey
    }
    
    public func getFleksyLicenseKey() -> String {
        return fleksyLicenseKey
    }
    
    public func getFleksyLicenseSecret() -> String {
        return fleksyLicenseSecret
    }
} 
