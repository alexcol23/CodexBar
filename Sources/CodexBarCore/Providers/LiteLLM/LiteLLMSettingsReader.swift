import Foundation

public enum LiteLLMSettingsReader: Sendable {
    public static let apiKeyKey = "LITELLM_API_KEY"
    public static let anthropicAPIKeyKey = "ANTHROPIC_API_KEY"
    public static let baseURLKey = "LITELLM_BASE_URL"
    public static let defaultBaseURL = "https://fern.addi.com"

    public static func apiKey(
        environment: [String: String] = ProcessInfo.processInfo.environment) -> String?
    {
        if let token = self.cleaned(environment[apiKeyKey]) { return token }
        if let token = self.cleaned(environment[anthropicAPIKeyKey]) { return token }
        return nil
    }

    public static func baseURL(
        environment: [String: String] = ProcessInfo.processInfo.environment) -> String
    {
        if let url = self.cleaned(environment[baseURLKey]) { return url }
        return defaultBaseURL
    }

    static func cleaned(_ raw: String?) -> String? {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }

        if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
            (value.hasPrefix("'") && value.hasSuffix("'"))
        {
            value.removeFirst()
            value.removeLast()
        }

        value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

public enum LiteLLMSettingsError: LocalizedError, Sendable {
    case missingToken

    public var errorDescription: String? {
        switch self {
        case .missingToken:
            "LiteLLM API key not found. Set apiKey in ~/.codexbar/config.json or LITELLM_API_KEY / ANTHROPIC_API_KEY."
        }
    }
}
