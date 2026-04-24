import Foundation
import SwiftData

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var errorMessage: String?
    @Published var linkToken: String?
    @Published var showPlaidLink = false

    func fetchLinkToken() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            linkToken = try await PlaidService.shared.createLinkToken()
            showPlaidLink = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handlePlaidSuccess(
        publicToken: String,
        modelContext: ModelContext
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let exchange = try await PlaidService.shared.exchangePublicToken(publicToken)
            let item = PlaidItem(
                itemId: exchange.itemId,
                institutionId: exchange.institutionId,
                institutionName: exchange.institutionName,
                institutionColor: exchange.institutionColor ?? "#1D4ED8"
            )
            modelContext.insert(item)
            try modelContext.save()
            await syncItem(item: item, modelContext: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func syncItem(item: PlaidItem, modelContext: ModelContext) async {
        isSyncing = true
        defer { isSyncing = false }
        do {
            let result = try await PlaidService.shared.syncTransactions(
                itemId: item.itemId,
                cursor: item.syncCursor
            )

            // Upsert accounts
            let itemId = item.itemId
            let fetch = FetchDescriptor<STAccount>(
                predicate: #Predicate { $0.itemId == itemId }
            )
            let existing = (try? modelContext.fetch(fetch)) ?? []
            let existingIds = Set(existing.map(\.accountId))

            for accountResp in result.accounts {
                if let acct = existing.first(where: { $0.accountId == accountResp.accountId }) {
                    acct.currentBalance = accountResp.currentBalance
                    acct.availableBalance = accountResp.availableBalance
                } else if !existingIds.contains(accountResp.accountId) {
                    let acct = STAccount(
                        accountId: accountResp.accountId,
                        itemId: item.itemId,
                        name: accountResp.name,
                        officialName: accountResp.officialName,
                        type: accountResp.type,
                        subtype: accountResp.subtype,
                        mask: accountResp.mask,
                        currentBalance: accountResp.currentBalance,
                        availableBalance: accountResp.availableBalance,
                        isoCurrencyCode: accountResp.isoCurrencyCode ?? "USD",
                        institutionName: item.institutionName,
                        institutionColor: item.institutionColor
                    )
                    modelContext.insert(acct)
                }
            }

            // Insert new transactions
            let txFetch = FetchDescriptor<STTransaction>()
            let existingTx = (try? modelContext.fetch(txFetch)) ?? []
            let existingTxIds = Set(existingTx.map(\.transactionId))

            for tx in result.added where !existingTxIds.contains(tx.transactionId) {
                let primary = CategoryHelper.normalize(tx.primaryCategory ?? "OTHER")
                let newTx = STTransaction(
                    transactionId: tx.transactionId,
                    accountId: tx.accountId,
                    itemId: item.itemId,
                    name: tx.name,
                    merchantName: tx.merchantName,
                    amount: tx.amount,
                    date: PlaidService.shared.parseDate(tx.date),
                    primaryCategory: primary,
                    detailedCategory: tx.detailedCategory ?? primary,
                    isoCurrencyCode: "USD",
                    pending: tx.pending,
                    logoUrl: tx.logoUrl
                )
                modelContext.insert(newTx)
            }

            // Update modified transactions
            for tx in result.modified {
                if let existing = existingTx.first(where: { $0.transactionId == tx.transactionId }) {
                    existing.amount = tx.amount
                    existing.pending = tx.pending
                    existing.merchantName = tx.merchantName
                }
            }

            // Remove deleted
            for removedId in result.removed {
                if let tx = existingTx.first(where: { $0.transactionId == removedId }) {
                    modelContext.delete(tx)
                }
            }

            item.syncCursor = result.nextCursor
            item.lastSynced = Date()
            try modelContext.save()

            UserDefaults.standard.set(Date(), forKey: Constants.UserDefaultsKeys.lastSyncDate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeItem(item: PlaidItem, modelContext: ModelContext) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await PlaidService.shared.removeItem(itemId: item.itemId)
        } catch {
            // Continue with local removal even if server fails
        }

        // Delete local accounts and transactions
        let itemId = item.itemId
        let acctFetch = FetchDescriptor<STAccount>(
            predicate: #Predicate { $0.itemId == itemId }
        )
        if let accounts = try? modelContext.fetch(acctFetch) {
            let ids = accounts.map(\.accountId)
            let txFetch = FetchDescriptor<STTransaction>()
            if let txs = try? modelContext.fetch(txFetch) {
                txs.filter { ids.contains($0.accountId) }.forEach { modelContext.delete($0) }
            }
            accounts.forEach { modelContext.delete($0) }
        }
        modelContext.delete(item)
        try? modelContext.save()
    }
}
