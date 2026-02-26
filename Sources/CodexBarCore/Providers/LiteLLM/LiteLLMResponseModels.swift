import Foundation

/// Raw JSON response from `GET /user/info` on a LiteLLM proxy.
public struct LiteLLMUserInfoResponse: Codable, Sendable {
    public let user_info: LiteLLMUserInfo?
    public let keys: [LiteLLMKeyInfo]?
    public let teams: [LiteLLMTeamInfo]?
}

public struct LiteLLMUserInfo: Codable, Sendable {
    public let max_budget: Double?
    public let spend: Double?
    public let budget_duration: String?
    public let budget_reset_at: String?
    public let user_email: String?
}

public struct LiteLLMKeyInfo: Codable, Sendable {
    public let spend: Double?
}

public struct LiteLLMTeamInfo: Codable, Sendable {
    public let team_alias: String?
    public let max_budget: Double?
    public let spend: Double?
    public let budget_duration: String?
    public let budget_reset_at: String?
}
