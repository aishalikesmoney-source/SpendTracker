import SwiftUI

enum CategoryHelper {
    // Maps Plaid personal_finance_category primary to our internal keys
    static func normalize(_ plaidCategory: String) -> String {
        let upper = plaidCategory.uppercased()
        if upper.contains("FOOD") || upper.contains("DRINK") || upper.contains("RESTAURANT") {
            return "FOOD_AND_DRINK"
        } else if upper.contains("TRAVEL") || upper.contains("AIRLINE") || upper.contains("HOTEL") {
            return "TRAVEL"
        } else if upper.contains("TRANSPORT") || upper.contains("RIDESHARE") || upper.contains("GAS") {
            return "TRANSPORTATION"
        } else if upper.contains("ENTERTAINMENT") || upper.contains("RECREATION") {
            return "ENTERTAINMENT"
        } else if upper.contains("MEDICAL") || upper.contains("HEALTH") || upper.contains("PHARMACY") {
            return "MEDICAL"
        } else if upper.contains("PERSONAL_CARE") || upper.contains("PERSONAL CARE") {
            return "PERSONAL_CARE"
        } else if upper.contains("HOME") || upper.contains("RENT") || upper.contains("MORTGAGE") {
            return "HOME"
        } else if upper.contains("UTILITIES") || upper.contains("BILL") || upper.contains("SUBSCRIPTION") {
            return "BILLS"
        } else if upper.contains("GENERAL_MERCHANDISE") || upper.contains("SHOP") || upper.contains("RETAIL") {
            return "SHOPPING"
        } else if upper.contains("INCOME") || upper.contains("WAGES") || upper.contains("PAYROLL") {
            return "INCOME"
        } else if upper.contains("TRANSFER") || upper.contains("PAYMENT") || upper.contains("LOAN") {
            return "TRANSFER"
        }
        return "OTHER"
    }

    static func displayName(for category: String) -> String {
        switch category {
        case "FOOD_AND_DRINK":  return "Food & Drink"
        case "SHOPPING":        return "Shopping"
        case "TRANSPORTATION":  return "Transportation"
        case "TRAVEL":          return "Travel"
        case "ENTERTAINMENT":   return "Entertainment"
        case "MEDICAL":         return "Health"
        case "BILLS":           return "Bills & Utilities"
        case "PERSONAL_CARE":   return "Personal Care"
        case "HOME":            return "Home"
        case "INCOME":          return "Income"
        case "TRANSFER":        return "Transfers"
        case "OTHER":           return "Other"
        default:                return category.capitalized.replacingOccurrences(of: "_", with: " ")
        }
    }

    static func sfSymbol(for category: String) -> String {
        switch category {
        case "FOOD_AND_DRINK":  return "fork.knife"
        case "SHOPPING":        return "bag.fill"
        case "TRANSPORTATION":  return "car.fill"
        case "TRAVEL":          return "airplane"
        case "ENTERTAINMENT":   return "play.circle.fill"
        case "MEDICAL":         return "heart.fill"
        case "BILLS":           return "bolt.fill"
        case "PERSONAL_CARE":   return "sparkles"
        case "HOME":            return "house.fill"
        case "INCOME":          return "arrow.down.circle.fill"
        case "TRANSFER":        return "arrow.left.arrow.right"
        default:                return "questionmark.circle"
        }
    }

    static func color(for category: String) -> Color {
        switch category {
        case "FOOD_AND_DRINK":  return Color(hex: "#F97316")
        case "SHOPPING":        return Color(hex: "#A855F7")
        case "TRANSPORTATION":  return Color(hex: "#3B82F6")
        case "TRAVEL":          return Color(hex: "#0EA5E9")
        case "ENTERTAINMENT":   return Color(hex: "#EC4899")
        case "MEDICAL":         return Color(hex: "#22C55E")
        case "BILLS":           return Color(hex: "#EAB308")
        case "PERSONAL_CARE":   return Color(hex: "#F472B6")
        case "HOME":            return Color(hex: "#6366F1")
        case "INCOME":          return Color(hex: "#10B981")
        case "TRANSFER":        return Color(hex: "#6B7280")
        default:                return Color(hex: "#9CA3AF")
        }
    }
}
