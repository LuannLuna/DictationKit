import Foundation

actor DeepgramService {
    private let apiKey: String
    private let baseURL = "https://api.deepgram.com/v1/listen"
    
    init() {
        self.apiKey = SecureConfigurationManager.shared.getDeepgramApiKey()
    }
    
    func transcribe(audioURL: URL) async throws -> TranscriptionResult {
        let userSettings = AppGroupsManager.shared.getUserSettings()
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("audio/m4a", forHTTPHeaderField: "Content-Type")
        
        // Add query parameters for better transcription
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "model", value: "nova-2"),
            URLQueryItem(name: "language", value: userSettings.language),
            URLQueryItem(name: "punctuate", value: userSettings.autoPunctuation ? "true" : "false"),
            URLQueryItem(name: "capitalize", value: userSettings.autoCapitalization ? "true" : "false"),
            URLQueryItem(name: "diarize", value: "false"),
            URLQueryItem(name: "utterances", value: "false"),
            URLQueryItem(name: "paragraphs", value: "false")
        ]
        request.url = urlComponents.url
        
        do {
            let audioData = try Data(contentsOf: audioURL)
            request.httpBody = audioData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TranscriptionError.networkError
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw TranscriptionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
            }
            
            let result = try JSONDecoder().decode(DeepgramResponse.self, from: data)
            
            guard let channel = result.results.channels.first,
                  let alternative = channel.alternatives.first else {
                throw TranscriptionError.apiError("No transcription results")
            }
            
            return TranscriptionResult(
                transcript: alternative.transcript,
                confidence: alternative.confidence ?? 0.0,
                isFinal: true
            )
            
        } catch {
            if error is TranscriptionError {
                throw error
            } else {
                throw TranscriptionError.networkError
            }
        }
    }
}

// MARK: - Deepgram Response Models
struct DeepgramResponse: Codable {
    let results: Results
}

struct Results: Codable {
    let channels: [Channel]
}

struct Channel: Codable {
    let alternatives: [Alternative]
}

struct Alternative: Codable {
    let transcript: String
    let confidence: Double?
    
    enum CodingKeys: String, CodingKey {
        case transcript
        case confidence
    }
} 
