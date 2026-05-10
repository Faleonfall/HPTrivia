import StoreKit

@MainActor
@Observable
class Store {
    var products: [Product] = []
    var purchased = Set<String>()

    private let productIDs = ["hp4", "hp5", "hp6", "hp7"]
    private var updates: Task<Void, Never>? = nil

    init() {
        updates = watchForUpdates()
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            products.sort {
                (productIDs.firstIndex(of: $0.id) ?? 0) < (productIDs.firstIndex(of: $1.id) ?? 0)
            }
            await checkPurchased()
        } catch {
            print("Unable to load product: \(error)")
        }
    }

    // MARK: - Purchases

    func purchase(_ productID: String) async -> Bool {
        if products.isEmpty {
            await loadProducts()
        }
        guard let product = products.first(where: { $0.id == productID }) else {
            print("Product not available: \(productID)")
            return false
        }
        return await purchase(product)
    }

    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .unverified(let signedType, let verificationError):
                    print("Error on \(signedType): \(verificationError)")
                case .verified(let signedType):
                    purchased.insert(signedType.productID)
                    await signedType.finish()
                    return true
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Unable to load product: \(error)")
        }
        return false
    }

    // MARK: - Entitlements

    private func checkPurchased() async {
        for product in products {
            guard let status = await product.currentEntitlement else { continue }

            switch status {
            case .unverified(let signedType, let verificationError):
                print("Error on \(signedType): \(verificationError)")
            case .verified(let signedType):
                if signedType.revocationDate == nil {
                    purchased.insert(signedType.productID)
                } else {
                    purchased.remove(signedType.productID)
                }
            }
        }
    }

    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await checkPurchased()
            }
        }
    }
}
