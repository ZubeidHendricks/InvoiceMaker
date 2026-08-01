import XCTest
import PDFKit
// Invoice.swift compiled into this test target.

final class InvoiceTests: XCTestCase {
    func testTotalsMath() {
        var inv = Invoice()
        inv.items = [LineItem(desc: "A", quantity: 2, rate: 10),
                     LineItem(desc: "B", quantity: 1, rate: 5)]
        inv.taxPercent = 10
        XCTAssertEqual(inv.subtotal, 25, accuracy: 0.001)
        XCTAssertEqual(inv.tax, 2.5, accuracy: 0.001)
        XCTAssertEqual(inv.total, 27.5, accuracy: 0.001)
    }

    func testLineItemAmount() {
        XCTAssertEqual(LineItem(desc: "x", quantity: 3, rate: 7.5).amount, 22.5, accuracy: 0.001)
    }

    func testPDFIsValid() {
        var inv = Invoice()
        inv.items = [LineItem(desc: "Consulting", quantity: 1, rate: 100)]
        let data = InvoicePDF.render(inv, watermark: false)
        XCTAssertEqual(String(data: data.prefix(5), encoding: .ascii), "%PDF-")
        XCTAssertEqual(PDFDocument(data: data)?.pageCount, 1)
    }
}

// Engagement layer per ../PLAYBOOK.md (CF): lifetime invoiced total + record.
final class InvoiceStatsTests: XCTestCase {
    private let suiteName = "invoicestats.tests"
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testAccumulatesTotalAndTracksLargest() {
        let stats = InvoiceStats(defaults: defaults)
        stats.recordInvoice(total: 100)
        stats.recordInvoice(total: 250)
        stats.recordInvoice(total: 50)
        XCTAssertEqual(stats.lifetimeTotal, 400, accuracy: 0.001)
        XCTAssertEqual(stats.largestInvoice, 250, accuracy: 0.001)
    }

    func testPersistsAcrossInstances() {
        InvoiceStats(defaults: defaults).recordInvoice(total: 99.5)
        let reloaded = InvoiceStats(defaults: defaults)
        XCTAssertEqual(reloaded.lifetimeTotal, 99.5, accuracy: 0.001)
        XCTAssertEqual(reloaded.largestInvoice, 99.5, accuracy: 0.001)
    }

    func testIgnoresNonPositiveTotals() {
        let stats = InvoiceStats(defaults: defaults)
        stats.recordInvoice(total: 0)
        stats.recordInvoice(total: -10)
        XCTAssertEqual(stats.lifetimeTotal, 0, accuracy: 0.001)
        XCTAssertEqual(stats.largestInvoice, 0, accuracy: 0.001)
    }
}
