import Foundation

public enum LiteLLMUsageFetcher {
    public static func fetchUsage(
        apiKey: String,
        baseURL: String,
        environment _: [String: String] = [:]) async throws -> LiteLLMUsageData
    {
        let urlString = baseURL.hasSuffix("/")
            ? "\(baseURL)user/info"
            : "\(baseURL)/user/info"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(LiteLLMUserInfoResponse.self, from: data)
        return Self.processResponse(decoded)
    }

    private static func processResponse(_ response: LiteLLMUserInfoResponse) -> LiteLLMUsageData {
        let effectiveSpend = response.keys?
            .compactMap(\.spend)
            .reduce(0, +) ?? 0

        let personalBudget = response.user_info?.max_budget
        let personalPercent: Double = {
            guard let budget = personalBudget, budget > 0 else { return 0 }
            return min((effectiveSpend / budget) * 100, 100)
        }()

        let team = response.teams?.first
        let teamSpend = team?.spend ?? 0
        let teamBudget = team?.max_budget
        let teamPercent: Double = {
            guard let budget = teamBudget, budget > 0 else { return 0 }
            return min((teamSpend / budget) * 100, 100)
        }()

        let resetAt: Date? = {
            guard let raw = response.user_info?.budget_reset_at ?? team?.budget_reset_at else {
                return nil
            }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: raw) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            return formatter.date(from: raw)
        }()

        return LiteLLMUsageData(
            personalSpend: effectiveSpend,
            personalBudget: personalBudget,
            personalUsagePercent: personalPercent,
            teamName: team?.team_alias,
            teamSpend: teamSpend,
            teamBudget: teamBudget,
            teamUsagePercent: teamPercent,
            budgetResetAt: resetAt,
            userEmail: response.user_info?.user_email,
            updatedAt: Date())
    }
}
