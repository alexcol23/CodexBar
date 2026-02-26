import AppKit
import CodexBarCore
import CodexBarMacroSupport
import Foundation
import SwiftUI

@ProviderImplementationRegistration
struct LiteLLMProviderImplementation: ProviderImplementation {
    let id: UsageProvider = .litellm

    @MainActor
    func presentation(context _: ProviderPresentationContext) -> ProviderPresentation {
        ProviderPresentation { _ in "api" }
    }

    @MainActor
    func observeSettings(_ settings: SettingsStore) {
        _ = settings.litellmAPIToken
        _ = settings.litellmBaseURL
    }

    @MainActor
    func settingsSnapshot(context: ProviderSettingsSnapshotContext) -> ProviderSettingsSnapshotContribution? {
        _ = context
        return .litellm(context.settings.litellmSettingsSnapshot())
    }

    @MainActor
    func isAvailable(context: ProviderAvailabilityContext) -> Bool {
        if LiteLLMSettingsReader.apiKey(environment: context.environment) != nil {
            return true
        }
        return !context.settings.litellmAPIToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @MainActor
    func settingsFields(context: ProviderSettingsContext) -> [ProviderSettingsFieldDescriptor] {
        [
            ProviderSettingsFieldDescriptor(
                id: "litellm-api-key",
                title: "API Key",
                subtitle: "LiteLLM proxy key. Overridden by LITELLM_API_KEY or ANTHROPIC_API_KEY env vars.",
                kind: .secure,
                placeholder: "sk-...",
                binding: Binding(
                    get: { context.settings.litellmAPIToken },
                    set: { context.settings.litellmAPIToken = $0 }),
                actions: [],
                isVisible: nil,
                onActivate: nil),
            ProviderSettingsFieldDescriptor(
                id: "litellm-base-url",
                title: "Base URL",
                subtitle: "LiteLLM proxy URL. Overridden by LITELLM_BASE_URL env var.",
                kind: .plain,
                placeholder: LiteLLMSettingsReader.defaultBaseURL,
                binding: Binding(
                    get: { context.settings.litellmBaseURL },
                    set: { context.settings.litellmBaseURL = $0 }),
                actions: [],
                isVisible: nil,
                onActivate: nil),
        ]
    }
}
