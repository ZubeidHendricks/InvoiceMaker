import Foundation
import Combine

// Engagement layer per ../PLAYBOOK.md: competence feedback only (CF row).
// Lifetime invoiced total + largest-invoice personal record — money is the
// competence score. No points, no badges, no leaderboards.
final class InvoiceStats: ObservableObject {
    @Published private(set) var lifetimeTotal: Double
    @Published private(set) var largestInvoice: Double

    private let defaults: UserDefaults
    private static let totalKey = "invoice.lifetime.total.v1"
    private static let largestKey = "invoice.largest.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        lifetimeTotal = defaults.double(forKey: Self.totalKey)
        largestInvoice = defaults.double(forKey: Self.largestKey)
    }

    /// Record a generated invoice's total.
    func recordInvoice(total: Double) {
        guard total > 0 else { return }
        lifetimeTotal += total
        largestInvoice = max(largestInvoice, total)
        defaults.set(lifetimeTotal, forKey: Self.totalKey)
        defaults.set(largestInvoice, forKey: Self.largestKey)
    }
}
