import Foundation

/// Processed usage data derived from a LiteLLM `/user/info` response.
public struct LiteLLMUsageData: Sendable {
    public let personalSpend: Double
    public let personalBudget: Double?
    public let personalUsagePercent: Double
    public let teamName: String?
    public let teamSpend: Double
    public let teamBudget: Double?
    public let teamUsagePercent: Double
    public let budgetResetAt: Date?
    public let userEmail: String?
    public let updatedAt: Date

    public func toUsageSnapshot() -> UsageSnapshot {
        let primary = RateWindow(
            usedPercent: self.personalUsagePercent,
            windowMinutes: nil,
            resetsAt: self.budgetResetAt,
            resetDescription: "Monthly")

        let secondary = RateWindow(
            usedPercent: self.teamUsagePercent,
            windowMinutes: nil,
            resetsAt: self.budgetResetAt,
            resetDescription: "Monthly")

        let cost: ProviderCostSnapshot? = self.personalBudget.map { budget in
            ProviderCostSnapshot(
                used: self.personalSpend,
                limit: budget,
                currencyCode: "USD",
                period: "Monthly",
                resetsAt: self.budgetResetAt,
                updatedAt: self.updatedAt)
        }

        let identity = ProviderIdentitySnapshot(
            providerID: .litellm,
            accountEmail: self.userEmail,
            accountOrganization: self.teamName,
            loginMethod: "API Key")

        return UsageSnapshot(
            primary: primary,
            secondary: secondary,
            tertiary: nil,
            providerCost: cost,
            updatedAt: self.updatedAt,
            identity: identity)
    }
}
