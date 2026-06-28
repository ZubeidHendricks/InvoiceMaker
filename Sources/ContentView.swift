import SwiftUI
import AppFactoryKit

// Invoice Maker — fill in details and line items, generate a clean PDF invoice,
// and share it. Fully on-device. Free tier adds a small footer; Pro removes it.
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory

    @State private var invoice = Invoice()
    @State private var shareItem: ShareItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Invoice #", text: $invoice.number)
                    TextField("Your name / business", text: $invoice.fromName)
                    TextField("Bill to", text: $invoice.toName)
                    DatePicker("Date", selection: $invoice.date, displayedComponents: .date)
                }

                Section("Items") {
                    ForEach($invoice.items) { $item in
                        VStack(spacing: 6) {
                            TextField("Description", text: $item.desc)
                            HStack {
                                TextField("Qty", value: $item.quantity, format: .number).keyboardType(.decimalPad)
                                TextField("Rate", value: $item.rate, format: .number).keyboardType(.decimalPad)
                                Spacer()
                                Text(item.amount, format: .currency(code: "USD")).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { invoice.items.remove(atOffsets: $0) }
                    Button { invoice.items.append(LineItem(desc: "", quantity: 1, rate: 0)) } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }

                Section("Tax") {
                    HStack { Text("Tax %"); Spacer(); TextField("0", value: $invoice.taxPercent, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80) }
                }

                Section {
                    HStack { Text("Total").font(.headline); Spacer(); Text(invoice.total, format: .currency(code: "USD")).font(.headline) }
                    Button { exportPDF() } label: {
                        Label("Generate PDF", systemImage: "doc.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).tint(.green)
                    .disabled(invoice.items.isEmpty)
                }
            }
            .navigationTitle("Invoice Maker")
        }
        .sheet(item: $shareItem) { ActivityView(items: $0.items) }
    }

    private func exportPDF() {
        // Free: PDF with footer. Pro: no footer (gate removal of the watermark).
        let isPro = factory.subscriptions.isSubscribed
        if !isPro { factory.analytics.track(.premiumFeatureBlocked(feature: "remove_watermark")) }
        let data = InvoicePDF.render(invoice, watermark: !isPro)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(invoice.number).pdf")
        try? data.write(to: url)
        shareItem = ShareItem(items: [url])
    }
}

struct ShareItem: Identifiable { let id = UUID(); let items: [Any] }

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
