import Foundation
import SwiftData

@Model
final class STAccount {
    var accountId: String
    var itemId: String
    var name: String
    var officialName: String?
    var type: String          // depository, credit, loan, investment
    var subtype: String       // checking, savings, credit card
    var mask: String?
    var currentBalance: Double?
    var availableBalance: Double?
    var isoCurrencyCode: String
    var institutionName: String
    var institutionColor: String
    var createdAt: Date

    init(
        accountId: String,
        itemId: String,
        name: String,
        officialName: String? = nil,
        type: String,
        subtype: String,
        mask: String? = nil,
        currentBalance: Double? = nil,
        availableBalance: Double? = nil,
        isoCurrencyCode: String = "USD",
        institutionName: String,
        institutionColor: String = "#1D4ED8"
    ) {
        self.accountId = accountId
        self.itemId = itemId
        self.name = name
        self.officialName = officialName
        self.type = type
        self.subtype = subtype
        self.mask = mask
        self.currentBalance = currentBalance
        self.availableBalance = availableBalance
        self.isoCurrencyCode = isoCurrencyCode
        self.institutionName = institutionName
        self.institutionColor = institutionColor
        self.createdAt = Date()
    }

    var displayName: String { officialName ?? name }

    var balanceDisplay: Double {
        if type == "credit" {
            return -(currentBalance ?? 0)
        }
        return currentBalance ?? availableBalance ?? 0
    }

    var subtypeIcon: String {
        switch subtype.lowercased() {
        case "checking": return "banknote"
        case "savings": return "building.columns"
        case "credit card": return "creditcard"
        default: return "creditcard"
        }
    }
}
