import CodexBarMacroSupport
import Foundation

@ProviderDescriptorRegistration
@ProviderDescriptorDefinition
public enum LiteLLMProviderDescriptor {
    static func makeDescriptor() -> ProviderDescriptor {
        ProviderDescriptor(
            id: .litellm,
            metadata: ProviderMetadata(
                id: .litellm,
                displayName: "LiteLLM",
                sessionLabel: "Personal",
                weeklyLabel: "Team",
                opusLabel: nil,
                supportsOpus: false,
                supportsCredits: false,
                creditsHint: "",
                toggleTitle: "Show LiteLLM usage",
                cliName: "litellm",
                defaultEnabled: false,
                isPrimaryProvider: false,
                usesAccountFallback: false,
                dashboardURL: nil,
                statusPageURL: nil),
            branding: ProviderBranding(
                iconStyle: .litellm,
                iconResourceName: "ProviderIcon-litellm",
                color: ProviderColor(red: 1 / 255, green: 163 / 255, blue: 224 / 255)),
            tokenCost: ProviderTokenCostConfig(
                supportsTokenCost: false,
                noDataMessage: { "LiteLLM cost summary is shown via budget bars." }),
            fetchPlan: ProviderFetchPlan(
                sourceModes: [.auto, .api],
                pipeline: ProviderFetchPipeline(resolveStrategies: { _ in [LiteLLMAPIFetchStrategy()] })),
            cli: ProviderCLIConfig(
                name: "litellm",
                aliases: ["lite-llm"],
                versionDetector: nil))
    }
}

struct LiteLLMAPIFetchStrategy: ProviderFetchStrategy {
    let id: String = "litellm.api"
    let kind: ProviderFetchKind = .apiToken

    func isAvailable(_ context: ProviderFetchContext) async -> Bool {
        LiteLLMSettingsReader.apiKey(environment: context.env) != nil
    }

    func fetch(_ context: ProviderFetchContext) async throws -> ProviderFetchResult {
        guard let apiKey = LiteLLMSettingsReader.apiKey(environment: context.env) else {
            throw LiteLLMSettingsError.missingToken
        }
        let baseURL = Self.resolveBaseURL(context: context)
        let usage = try await LiteLLMUsageFetcher.fetchUsage(
            apiKey: apiKey,
            baseURL: baseURL,
            environment: context.env)
        return self.makeResult(
            usage: usage.toUsageSnapshot(),
            sourceLabel: "api")
    }

    func shouldFallback(on _: Error, context _: ProviderFetchContext) -> Bool {
        false
    }

    private static func resolveBaseURL(context: ProviderFetchContext) -> String {
        if let settingsURL = context.settings?.litellm?.baseURL,
           !settingsURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            return settingsURL
        }
        return LiteLLMSettingsReader.baseURL(environment: context.env)
    }
}
