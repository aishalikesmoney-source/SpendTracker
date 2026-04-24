import Foundation
import SwiftData

// Injects realistic dummy data matching Plaid's /transactions/sync response shape.
// Only compiled in DEBUG — strip from release builds automatically.
#if DEBUG
enum SeedData {

    // MARK: - Plaid Items (connected banks)

    static let items: [PlaidItem] = [
        PlaidItem(
            itemId: "item_chase_001",
            institutionId: "ins_3",
            institutionName: "Chase",
            institutionColor: "#117ACA"
        ),
        PlaidItem(
            itemId: "item_amex_001",
            institutionId: "ins_10",
            institutionName: "American Express",
            institutionColor: "#016FD0"
        ),
    ]

    // MARK: - Accounts

    static let accounts: [STAccount] = [
        STAccount(
            accountId: "acc_chase_checking",
            itemId: "item_chase_001",
            name: "Total Checking",
            officialName: "Chase Total Checking®",
            type: "depository",
            subtype: "checking",
            mask: "4821",
            currentBalance: 4_823.17,
            availableBalance: 4_773.17,
            institutionName: "Chase",
            institutionColor: "#117ACA"
        ),
        STAccount(
            accountId: "acc_chase_savings",
            itemId: "item_chase_001",
            name: "Savings",
            officialName: "Chase Savings℠",
            type: "depository",
            subtype: "savings",
            mask: "9302",
            currentBalance: 12_400.00,
            availableBalance: 12_400.00,
            institutionName: "Chase",
            institutionColor: "#117ACA"
        ),
        STAccount(
            accountId: "acc_amex_gold",
            itemId: "item_amex_001",
            name: "Gold Card",
            officialName: "American Express Gold Card",
            type: "credit",
            subtype: "credit card",
            mask: "1004",
            currentBalance: 1_243.88,
            availableBalance: nil,
            institutionName: "American Express",
            institutionColor: "#016FD0"
        ),
    ]

    // MARK: - Transactions (90 days, realistic mix)

    static var transactions: [STTransaction] {
        var result: [STTransaction] = []
        result += foodTransactions
        result += shoppingTransactions
        result += transportTransactions
        result += billsTransactions
        result += entertainmentTransactions
        result += healthTransactions
        result += incomeTransactions
        result += transferTransactions
        return result
    }

    // MARK: Food & Drink (most frequent)

    private static var foodTransactions: [STTransaction] {
        let entries: [(String, String, Double, Int)] = [
            ("Chipotle Mexican Grill", "Chipotle", 14.85, 1),
            ("Starbucks", "Starbucks", 6.75, 2),
            ("Whole Foods Market", "Whole Foods", 87.43, 3),
            ("DoorDash", "DoorDash", 42.18, 5),
            ("Sweetgreen", "Sweetgreen", 16.50, 6),
            ("Trader Joe's", "Trader Joe's", 63.22, 8),
            ("Starbucks", "Starbucks", 5.95, 9),
            ("Uber Eats", "Uber Eats", 38.74, 10),
            ("Chipotle Mexican Grill", "Chipotle", 13.25, 12),
            ("Whole Foods Market", "Whole Foods", 91.10, 15),
            ("DoorDash", "DoorDash", 55.30, 17),
            ("Starbucks", "Starbucks", 7.25, 18),
            ("Sweetgreen", "Sweetgreen", 18.00, 20),
            ("Trader Joe's", "Trader Joe's", 72.44, 22),
            ("Chipotle Mexican Grill", "Chipotle", 15.60, 25),
            ("Starbucks", "Starbucks", 6.45, 27),
            ("Whole Foods Market", "Whole Foods", 54.87, 30),
            ("Uber Eats", "Uber Eats", 29.99, 33),
            ("DoorDash", "DoorDash", 47.62, 35),
            ("Starbucks", "Starbucks", 8.10, 38),
            ("Local Ramen Bar", "Local Ramen Bar", 22.00, 40),
            ("Trader Joe's", "Trader Joe's", 68.90, 42),
            ("Chipotle Mexican Grill", "Chipotle", 14.10, 45),
            ("Sweetgreen", "Sweetgreen", 17.25, 48),
            ("DoorDash", "DoorDash", 33.45, 50),
        ]
        return entries.enumerated().map { idx, e in
            STTransaction(
                transactionId: "txn_food_\(idx)",
                accountId: idx % 2 == 0 ? "acc_chase_checking" : "acc_amex_gold",
                itemId: idx % 2 == 0 ? "item_chase_001" : "item_amex_001",
                name: e.0,
                merchantName: e.1,
                amount: e.2,
                date: daysAgo(e.3),
                primaryCategory: "FOOD_AND_DRINK",
                detailedCategory: "FOOD_AND_DRINK_RESTAURANTS"
            )
        }
    }

    // MARK: Shopping

    private static var shoppingTransactions: [STTransaction] {
        let entries: [(String, String, Double, Int)] = [
            ("Amazon.com", "Amazon", 34.99, 2),
            ("Target", "Target", 112.43, 7),
            ("Amazon.com", "Amazon", 89.00, 11),
            ("Apple Store", "Apple", 29.00, 14),
            ("Nike.com", "Nike", 145.00, 19),
            ("Amazon.com", "Amazon", 22.50, 23),
            ("IKEA", "IKEA", 287.63, 28),
            ("Target", "Target", 67.88, 32),
            ("Amazon.com", "Amazon", 18.99, 37),
            ("Nordstrom", "Nordstrom", 198.00, 44),
            ("Amazon.com", "Amazon", 55.49, 52),
            ("Best Buy", "Best Buy", 349.99, 60),
        ]
        return entries.enumerated().map { idx, e in
            STTransaction(
                transactionId: "txn_shop_\(idx)",
                accountId: idx % 2 == 0 ? "acc_amex_gold" : "acc_chase_checking",
                itemId: idx % 2 == 0 ? "item_amex_001" : "item_chase_001",
                name: e.0,
                merchantName: e.1,
                amount: e.2,
                date: daysAgo(e.3),
                primaryCategory: "GENERAL_MERCHANDISE",
                detailedCategory: "GENERAL_MERCHANDISE_ONLINE_MARKETPLACES"
            )
        }
    }

    // MARK: Transportation

    private static var transportTransactions: [STTransaction] {
        let entries: [(String, String, Double, Int)] = [
            ("Uber", "Uber", 18.43, 1),
            ("Lyft", "Lyft", 14.20, 4),
            ("NYC MTA", "MTA", 33.00, 7),
            ("Uber", "Uber", 22.10, 10),
            ("Shell", "Shell", 58.34, 13),
            ("Lyft", "Lyft", 11.75, 16),
            ("Uber", "Uber", 31.60, 19),
            ("EZPass", "EZPass", 25.00, 25),
            ("Uber", "Uber", 16.90, 31),
            ("Shell", "Shell", 62.11, 40),
            ("Lyft", "Lyft", 19.30, 55),
        ]
        return entries.enumerated().map { idx, e in
            STTransaction(
                transactionId: "txn_transport_\(idx)",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: e.0,
                merchantName: e.1,
                amount: e.2,
                date: daysAgo(e.3),
                primaryCategory: "TRANSPORTATION",
                detailedCategory: "TRANSPORTATION_TAXIS_AND_RIDE_SHARES"
            )
        }
    }

    // MARK: Bills & Utilities

    private static var billsTransactions: [STTransaction] {
        let entries: [(String, String, Double, Int)] = [
            ("Con Edison", "Con Edison", 134.22, 5),
            ("Netflix", "Netflix", 15.49, 5),
            ("Spotify", "Spotify", 9.99, 5),
            ("AT&T", "AT&T", 85.00, 5),
            ("Internet Bill - Optimum", "Optimum", 74.99, 5),
            ("Con Edison", "Con Edison", 128.44, 35),
            ("Netflix", "Netflix", 15.49, 35),
            ("Spotify", "Spotify", 9.99, 35),
            ("AT&T", "AT&T", 85.00, 35),
            ("Internet Bill - Optimum", "Optimum", 74.99, 35),
            ("Con Edison", "Con Edison", 142.10, 65),
            ("Netflix", "Netflix", 15.49, 65),
            ("Spotify", "Spotify", 9.99, 65),
        ]
        return entries.enumerated().map { idx, e in
            STTransaction(
                transactionId: "txn_bills_\(idx)",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: e.0,
                merchantName: e.1,
                amount: e.2,
                date: daysAgo(e.3),
                primaryCategory: "UTILITIES",
                detailedCategory: "UTILITIES_ELECTRIC_AND_GAS"
            )
        }
    }

    // MARK: Entertainment

    private static var entertainmentTransactions: [STTransaction] {
        let entries: [(String, String, Double, Int)] = [
            ("AMC Theaters", "AMC", 36.00, 3),
            ("Steam", "Steam", 59.99, 15),
            ("Broadway Tickets", "Telecharge", 248.00, 22),
            ("PS Store", "PlayStation", 69.99, 30),
            ("AMC Theaters", "AMC", 28.50, 45),
            ("Ticketmaster", "Ticketmaster", 185.00, 58),
        ]
        return entries.enumerated().map { idx, e in
            STTransaction(
                transactionId: "txn_ent_\(idx)",
                accountId: "acc_amex_gold",
                itemId: "item_amex_001",
                name: e.0,
                merchantName: e.1,
                amount: e.2,
                date: daysAgo(e.3),
                primaryCategory: "ENTERTAINMENT",
                detailedCategory: "ENTERTAINMENT_SPORTING_EVENTS_AMUSEMENT_PARKS_AND_MUSEUMS"
            )
        }
    }

    // MARK: Health

    private static var healthTransactions: [STTransaction] {
        let entries: [(String, String, Double, Int)] = [
            ("CVS Pharmacy", "CVS", 24.99, 6),
            ("NYU Langone Health", "NYU Langone", 35.00, 18),
            ("Equinox", "Equinox", 185.00, 5),
            ("CVS Pharmacy", "CVS", 18.44, 29),
            ("Equinox", "Equinox", 185.00, 35),
            ("Walgreens", "Walgreens", 31.20, 40),
            ("Equinox", "Equinox", 185.00, 65),
        ]
        return entries.enumerated().map { idx, e in
            STTransaction(
                transactionId: "txn_health_\(idx)",
                accountId: idx % 2 == 0 ? "acc_amex_gold" : "acc_chase_checking",
                itemId: idx % 2 == 0 ? "item_amex_001" : "item_chase_001",
                name: e.0,
                merchantName: e.1,
                amount: e.2,
                date: daysAgo(e.3),
                primaryCategory: "MEDICAL",
                detailedCategory: "MEDICAL_PHARMACIES_AND_SUPPLEMENTS"
            )
        }
    }

    // MARK: Income (negative = credit in Plaid convention)

    private static var incomeTransactions: [STTransaction] {
        [
            STTransaction(
                transactionId: "txn_income_0",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: "VIANT INC PAYROLL",
                merchantName: "Viant Technology",
                amount: -4_583.33,
                date: daysAgo(2),
                primaryCategory: "INCOME",
                detailedCategory: "INCOME_WAGES"
            ),
            STTransaction(
                transactionId: "txn_income_1",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: "VIANT INC PAYROLL",
                merchantName: "Viant Technology",
                amount: -4_583.33,
                date: daysAgo(16),
                primaryCategory: "INCOME",
                detailedCategory: "INCOME_WAGES"
            ),
            STTransaction(
                transactionId: "txn_income_2",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: "VIANT INC PAYROLL",
                merchantName: "Viant Technology",
                amount: -4_583.33,
                date: daysAgo(46),
                primaryCategory: "INCOME",
                detailedCategory: "INCOME_WAGES"
            ),
            STTransaction(
                transactionId: "txn_income_3",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: "VIANT INC PAYROLL",
                merchantName: "Viant Technology",
                amount: -4_583.33,
                date: daysAgo(76),
                primaryCategory: "INCOME",
                detailedCategory: "INCOME_WAGES"
            ),
        ]
    }

    // MARK: Transfers

    private static var transferTransactions: [STTransaction] {
        [
            STTransaction(
                transactionId: "txn_transfer_0",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: "AMEX AUTOPAY",
                merchantName: "American Express",
                amount: 1_100.00,
                date: daysAgo(8),
                primaryCategory: "TRANSFER",
                detailedCategory: "TRANSFER_CREDIT_CARD_PAYMENT"
            ),
            STTransaction(
                transactionId: "txn_transfer_1",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: "Venmo Payment",
                merchantName: "Venmo",
                amount: 45.00,
                date: daysAgo(14),
                primaryCategory: "TRANSFER",
                detailedCategory: "TRANSFER_PEER_TO_PEER"
            ),
            STTransaction(
                transactionId: "txn_transfer_2",
                accountId: "acc_chase_checking",
                itemId: "item_chase_001",
                name: "AMEX AUTOPAY",
                merchantName: "American Express",
                amount: 980.00,
                date: daysAgo(38),
                primaryCategory: "TRANSFER",
                detailedCategory: "TRANSFER_CREDIT_CARD_PAYMENT"
            ),
        ]
    }

    // MARK: - Helpers

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    // MARK: - Inject into SwiftData

    static func inject(into context: ModelContext) {
        // Clear existing seed data first (identified by known itemIds)
        let seedItemIds = Set(items.map(\.itemId))

        let itemFetch = FetchDescriptor<PlaidItem>()
        if let existing = try? context.fetch(itemFetch) {
            existing.filter { seedItemIds.contains($0.itemId) }.forEach { context.delete($0) }
        }
        let accountFetch = FetchDescriptor<STAccount>()
        if let existing = try? context.fetch(accountFetch) {
            existing.filter { seedItemIds.contains($0.itemId) }.forEach { context.delete($0) }
        }
        let txFetch = FetchDescriptor<STTransaction>()
        if let existing = try? context.fetch(txFetch) {
            existing.filter { seedItemIds.contains($0.itemId) }.forEach { context.delete($0) }
        }

        items.forEach { context.insert($0) }
        accounts.forEach { context.insert($0) }
        transactions.forEach { context.insert($0) }

        try? context.save()
    }

    static func clear(from context: ModelContext) {
        let seedItemIds = Set(items.map(\.itemId))

        let itemFetch = FetchDescriptor<PlaidItem>()
        if let existing = try? context.fetch(itemFetch) {
            existing.filter { seedItemIds.contains($0.itemId) }.forEach { context.delete($0) }
        }
        let accountFetch = FetchDescriptor<STAccount>()
        if let existing = try? context.fetch(accountFetch) {
            existing.filter { seedItemIds.contains($0.itemId) }.forEach { context.delete($0) }
        }
        let txFetch = FetchDescriptor<STTransaction>()
        if let existing = try? context.fetch(txFetch) {
            existing.filter { seedItemIds.contains($0.itemId) }.forEach { context.delete($0) }
        }

        try? context.save()
    }
}
#endif
