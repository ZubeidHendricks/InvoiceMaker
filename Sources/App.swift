import SwiftUI
import AppFactoryKit

// Invoice Maker — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "invoicemaker_pro_yearly"
    static let weekly = "invoicemaker_pro_weekly"
}

@MainActor
enum InvoiceMakerFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Invoice Maker",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "doc.text",
                          title: "Professional Invoices",
                          message: "Create clean, itemized invoices and estimates in seconds."),
                    .init(systemImage: "square.and.arrow.up",
                          title: "Export & Send",
                          message: "Generate a polished PDF and share it with any client."),
                    .init(systemImage: "chart.line.uptrend.xyaxis",
                          title: "Stay on Top",
                          message: "Add tax, your branding, and keep every invoice organized.")
                ],
                presentsPaywallOnFinish: true,
                accent: .green
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Invoice Maker Pro",
                subheadline: "Everything you need to bill clients like a pro.",
                benefits: [
                    .init(systemImage: "infinity", title: "Unlimited invoices"),
                    .init(systemImage: "paintpalette", title: "Your logo & branding"),
                    .init(systemImage: "doc.fill", title: "Watermark-free PDF export"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/InvoiceMaker/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/InvoiceMaker/privacy.html"),
                style: PaywallStyle(accent: .green, heroSystemImage: "doc.text.fill")
            )
        )
        return AppFactory(config)
    }
}

@main
struct InvoiceMakerApp: App {
    @StateObject private var factory = InvoiceMakerFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.green)
        }
    }
}
