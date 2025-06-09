//  StoreManager.swift

import Foundation
import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPurchased: Bool = false
    @Published var restoreAlert: Bool = false
    @Published var restoreAlertMessage: String = ""

    let productIDs = ["coffeeRatioo"]

    init() {
        Task {
            await fetchProducts()
            await checkPurchased()
        }
        observeTransactionUpdates()
    }

    func fetchProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Ürünler çekilemedi: \(error)")
        }
    }

    // PARAMETRELİ: Yalnızca restore'da alert çıkar!
    func checkPurchased(isRestore: Bool = false) async {
        var found = false
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIDs.contains(transaction.productID) {
                    isPurchased = true
                    found = true
                }
            default:
                break
            }
        }
        if isRestore {
            if found {
                // Opsiyonel: başarı mesajı göstermek istersen buraya ekleyebilirsin
            } else {
                restoreAlertMessage = NSLocalizedString("purchase_not_found", comment: "")
                restoreAlert = true
            }
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    isPurchased = true
                default:
                    break
                }
            default:
                break
            }
        } catch {
            print("Satın alma hatası: \(error)")
        }
    }

    func restore() async {
        isPurchased = false // Önce false yap
        await checkPurchased(isRestore: true)
    }

    func observeTransactionUpdates() {
        Task.detached {
            for await update in Transaction.updates {
                switch update {
                case .verified(let transaction):
                    if self.productIDs.contains(transaction.productID) {
                        await MainActor.run {
                            self.isPurchased = true
                        }
                    }
                default:
                    break
                }
            }
        }
    }
}
