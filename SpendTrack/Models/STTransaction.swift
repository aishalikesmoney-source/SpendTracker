import Foundation
import SwiftData

@Model
final class STTransaction {
    var transactionId: String
    var accountId: String
    var itemId: String
    var name: String
    var merchantName: String?
    var amount: Double          // positive = expense, negative = income (Plaid convention)
    var date: Date
    var primaryCategory: String
    var detailedCategory: String
    var customCategory: String?  // user override
    var customTag: String?       // user-applied tag
    var note: String?
    var isoCurrencyCode: String
    var pending: Bool
    var logoUrl: String?
    var createdAt: Date

    init(
        transactionId: String,
        accountId: String,
        itemId: String,
        name: String,
        merchantName: String? = nil,
        amount: Double,
        date: Date,
        primaryCategory: String = "OTHER",
        detailedCategory: String = "OTHER",
        isoCurrencyCode: String = "USD",
        pending: Bool = false,
        logoUrl: String? = nil
    ) {
        self.transactionId = transactionId
        self.accountId = accountId
        self.itemId = itemId
        self.name = name
        self.merchantName = merchantName
        self.amount = amount
        self.date = date
        self.primaryCategory = primaryCategory
        self.detailedCategory = detailedCategory
        self.isoCurrencyCode = isoCurrencyCode
        self.pending = pending
        self.logoUrl = logoUrl
        self.createdAt = Date()
    }

    var displayName: String { merchantName ?? name }

    var isExpense: Bool { amount > 0 }

    var effectiveCategory: String { customCategory ?? primaryCategory }

    var isUncategorized: Bool {
        primaryCategory == "OTHER" && customCategory == nil
    }
}
