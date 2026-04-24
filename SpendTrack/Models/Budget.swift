import Foundation
import SwiftData

@Model
final class Budget {
    var id: String
    var category: String
    var monthlyLimit: Double
    var month: Int   // 1-12
    var year: Int
    var notifiedAt80: Bool
    var notifiedAt100: Bool
    var createdAt: Date

    init(category: String, monthlyLimit: Double, month: Int, year: Int) {
        self.id = UUID().uuidString
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.month = month
        self.year = year
        self.notifiedAt80 = false
        self.notifiedAt100 = false
        self.createdAt = Date()
    }

    var progressLabel: String {
        let c = Calendar.current
        var components = DateComponents()
        components.month = month
        components.year = year
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: c.date(from: components) ?? Date())
    }
}
