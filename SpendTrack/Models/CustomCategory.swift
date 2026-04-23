import Foundation
import SwiftData

@Model
final class CustomCategory {
    var id: String
    var name: String
    var colorHex: String
    var sfSymbol: String
    var isSystem: Bool
    var createdAt: Date

    init(name: String, colorHex: String, sfSymbol: String, isSystem: Bool = false) {
        self.id = UUID().uuidString
        self.name = name
        self.colorHex = colorHex
        self.sfSymbol = sfSymbol
        self.isSystem = isSystem
        self.createdAt = Date()
    }

    static var systemCategories: [CustomCategory] {
        [
            CustomCategory(name: "FOOD_AND_DRINK",    colorHex: "#F97316", sfSymbol: "fork.knife",             isSystem: true),
            CustomCategory(name: "SHOPPING",           colorHex: "#A855F7", sfSymbol: "bag.fill",               isSystem: true),
            CustomCategory(name: "TRANSPORTATION",     colorHex: "#3B82F6", sfSymbol: "car.fill",               isSystem: true),
            CustomCategory(name: "TRAVEL",             colorHex: "#0EA5E9", sfSymbol: "airplane",               isSystem: true),
            CustomCategory(name: "ENTERTAINMENT",      colorHex: "#EC4899", sfSymbol: "play.circle.fill",       isSystem: true),
            CustomCategory(name: "MEDICAL",            colorHex: "#22C55E", sfSymbol: "heart.fill",             isSystem: true),
            CustomCategory(name: "BILLS",              colorHex: "#EAB308", sfSymbol: "bolt.fill",              isSystem: true),
            CustomCategory(name: "PERSONAL_CARE",      colorHex: "#F472B6", sfSymbol: "sparkles",               isSystem: true),
            CustomCategory(name: "HOME",               colorHex: "#6366F1", sfSymbol: "house.fill",             isSystem: true),
            CustomCategory(name: "INCOME",             colorHex: "#10B981", sfSymbol: "arrow.down.circle.fill", isSystem: true),
            CustomCategory(name: "TRANSFER",           colorHex: "#6B7280", sfSymbol: "arrow.left.arrow.right", isSystem: true),
            CustomCategory(name: "OTHER",              colorHex: "#9CA3AF", sfSymbol: "questionmark.circle",    isSystem: true),
        ]
    }
}
