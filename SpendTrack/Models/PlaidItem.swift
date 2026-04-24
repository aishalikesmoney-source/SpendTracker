import Foundation
import SwiftData

@Model
final class PlaidItem {
    var itemId: String
    var institutionId: String
    var institutionName: String
    var institutionColor: String
    var lastSynced: Date?
    var syncCursor: String?
    var createdAt: Date

    init(
        itemId: String,
        institutionId: String,
        institutionName: String,
        institutionColor: String = "#1D4ED8"
    ) {
        self.itemId = itemId
        self.institutionId = institutionId
        self.institutionName = institutionName
        self.institutionColor = institutionColor
        self.createdAt = Date()
    }
}
