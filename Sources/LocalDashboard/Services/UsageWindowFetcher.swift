import Foundation

typealias DataTaskFunc = @Sendable (URLRequest) async throws -> (Data, URLResponse)

func fetchUsageWindow(
    tokenProvider: KeychainTokenProviding,
    dataTask: DataTaskFunc
) async -> UsageWindowInfo? {
    guard let token = tokenProvider.fetchOAuthToken() else { return nil }
    guard let url = URL(string: "https://api.anthropic.com/api/oauth/usage") else { return nil }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = 3
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")

    do {
        let (data, response) = try await dataTask(request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
        return parseUsageWindowResponse(data)
    } catch {
        return nil
    }
}
