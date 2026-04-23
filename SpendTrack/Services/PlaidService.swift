import Foundation

enum PlaidError: LocalizedError {
    case serverUnreachable
    case badResponse(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .serverUnreachable:
            return "Cannot reach the SpendTrack server. Make sure it's running at \(PlaidService.shared.baseURL)"
        case .badResponse(let msg):
            return msg
        case .decodingError:
            return "Unexpected server response format."
        }
    }
}

// MARK: - Response Models

struct LinkTokenResponse: Decodable {
    let linkToken: String
    enum CodingKeys: String, CodingKey { case linkToken = "link_token" }
}

struct ExchangeResponse: Decodable {
    let itemId: String
    let institutionId: String
    let institutionName: String
    let institutionColor: String?
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case institutionId = "institution_id"
        case institutionName = "institution_name"
        case institutionColor = "institution_color"
    }
}

struct SyncResponse: Decodable {
    let accounts: [AccountResponse]
    let added: [TransactionResponse]
    let modified: [TransactionResponse]
    let removed: [String]
    let nextCursor: String?
    enum CodingKeys: String, CodingKey {
        case accounts, added, modified, removed
        case nextCursor = "next_cursor"
    }
}

struct AccountResponse: Decodable {
    let accountId: String
    let name: String
    let officialName: String?
    let type: String
    let subtype: String
    let mask: String?
    let currentBalance: Double?
    let availableBalance: Double?
    let isoCurrencyCode: String?
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case name, mask
        case officialName = "official_name"
        case type, subtype
        case currentBalance = "current_balance"
        case availableBalance = "available_balance"
        case isoCurrencyCode = "iso_currency_code"
    }
}

struct TransactionResponse: Decodable {
    let transactionId: String
    let accountId: String
    let name: String
    let merchantName: String?
    let amount: Double
    let date: String
    let primaryCategory: String?
    let detailedCategory: String?
    let pending: Bool
    let logoUrl: String?
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case accountId = "account_id"
        case name
        case merchantName = "merchant_name"
        case amount, date, pending
        case primaryCategory = "primary_category"
        case detailedCategory = "detailed_category"
        case logoUrl = "logo_url"
    }
}

// MARK: - Service

@MainActor
final class PlaidService: ObservableObject {
    static let shared = PlaidService()

    var baseURL: String {
        UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.customServerURL)
            ?? Constants.serverBaseURL
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    func createLinkToken() async throws -> String {
        let url = URL(string: "\(baseURL)/api/link-token")!
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["user_id": "local_user"])

        let (data, response) = try await fetchWithRetry(request: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw PlaidError.badResponse(String(data: data, encoding: .utf8) ?? "Unknown error")
        }
        let decoded = try JSONDecoder().decode(LinkTokenResponse.self, from: data)
        return decoded.linkToken
    }

    func exchangePublicToken(_ publicToken: String) async throws -> ExchangeResponse {
        let url = URL(string: "\(baseURL)/api/exchange-token")!
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["public_token": publicToken])

        let (data, response) = try await fetchWithRetry(request: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw PlaidError.badResponse(String(data: data, encoding: .utf8) ?? "Unknown error")
        }
        return try JSONDecoder().decode(ExchangeResponse.self, from: data)
    }

    func syncTransactions(itemId: String, cursor: String?) async throws -> SyncResponse {
        let url = URL(string: "\(baseURL)/api/sync")!
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = ["item_id": itemId]
        if let cursor { body["cursor"] = cursor }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await fetchWithRetry(request: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw PlaidError.badResponse(String(data: data, encoding: .utf8) ?? "Unknown error")
        }
        return try JSONDecoder().decode(SyncResponse.self, from: data)
    }

    func removeItem(itemId: String) async throws {
        let url = URL(string: "\(baseURL)/api/item/\(itemId)")!
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "DELETE"

        let (_, response) = try await fetchWithRetry(request: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw PlaidError.badResponse("Failed to remove item")
        }
    }

    // MARK: - Helpers

    func parseDate(_ string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }

    private func fetchWithRetry(request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .cannotConnectToHost || error.code == .networkConnectionLost {
            throw PlaidError.serverUnreachable
        }
    }
}
