import CodexBarCore
import Foundation

extension SettingsStore {
    var litellmAPIToken: String {
        get { self.configSnapshot.providerConfig(for: .litellm)?.sanitizedAPIKey ?? "" }
        set {
            self.updateProviderConfig(provider: .litellm) { entry in
                entry.apiKey = self.normalizedConfigValue(newValue)
            }
            self.logSecretUpdate(provider: .litellm, field: "apiKey", value: newValue)
        }
    }

    var litellmBaseURL: String {
        get { self.configSnapshot.providerConfig(for: .litellm)?.region ?? "" }
        set {
            self.updateProviderConfig(provider: .litellm) { entry in
                entry.region = self.normalizedConfigValue(newValue)
            }
        }
    }
}

extension SettingsStore {
    func litellmSettingsSnapshot() -> ProviderSettingsSnapshot.LiteLLMProviderSettings {
        ProviderSettingsSnapshot.LiteLLMProviderSettings(baseURL: self.litellmBaseURL)
    }
}
