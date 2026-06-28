import UIKit

struct LineItem: Identifiable, Hashable {
    var id = UUID()
    var desc: String
    var quantity: Double
    var rate: Double
    var amount: Double { quantity * rate }
}

struct Invoice {
    var number: String = "INV-001"
    var fromName: String = ""
    var toName: String = ""
    var date: Date = Date()
    var items: [LineItem] = []
    var taxPercent: Double = 0

    var subtotal: Double { items.reduce(0) { $0 + $1.amount } }
    var tax: Double { subtotal * taxPercent / 100 }
    var total: Double { subtotal + tax }
}

/// Renders an invoice to a clean A4-ish PDF, fully on-device. Free tier stamps a
/// small footer; Pro removes it (`watermark: false`).
enum InvoicePDF {
    static func render(_ invoice: Invoice, watermark: Bool) -> Data {
        let pageW: CGFloat = 612, pageH: CGFloat = 792   // US Letter @72dpi
        let bounds = CGRect(x: 0, y: 0, width: pageW, height: pageH)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        let currency: (Double) -> String = { v in
            let f = NumberFormatter(); f.numberStyle = .currency; return f.string(from: v as NSNumber) ?? "$\(v)"
        }
        return renderer.pdfData { ctx in
            ctx.beginPage()
            let margin: CGFloat = 48
            var y: CGFloat = margin

            draw("INVOICE", at: CGPoint(x: margin, y: y), font: .boldSystemFont(ofSize: 28))
            draw(invoice.number, at: CGPoint(x: pageW - margin - 140, y: y + 8), font: .systemFont(ofSize: 14), width: 140, align: .right)
            y += 56

            let df = DateFormatter(); df.dateStyle = .medium
            draw("From", at: CGPoint(x: margin, y: y), font: .boldSystemFont(ofSize: 11), color: .gray)
            draw("Bill To", at: CGPoint(x: pageW/2, y: y), font: .boldSystemFont(ofSize: 11), color: .gray)
            y += 16
            draw(invoice.fromName, at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 14))
            draw(invoice.toName, at: CGPoint(x: pageW/2, y: y), font: .systemFont(ofSize: 14))
            y += 22
            draw("Date: \(df.string(from: invoice.date))", at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 12), color: .darkGray)
            y += 40

            // Table header.
            drawRule(at: y - 6, from: margin, to: pageW - margin)
            draw("Description", at: CGPoint(x: margin, y: y), font: .boldSystemFont(ofSize: 12))
            draw("Qty", at: CGPoint(x: pageW - margin - 220, y: y), font: .boldSystemFont(ofSize: 12), width: 50, align: .right)
            draw("Rate", at: CGPoint(x: pageW - margin - 150, y: y), font: .boldSystemFont(ofSize: 12), width: 70, align: .right)
            draw("Amount", at: CGPoint(x: pageW - margin - 80, y: y), font: .boldSystemFont(ofSize: 12), width: 80, align: .right)
            y += 8
            drawRule(at: y + 12, from: margin, to: pageW - margin)
            y += 22

            for item in invoice.items {
                draw(item.desc, at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 12), width: pageW - margin*2 - 240)
                draw(String(format: "%g", item.quantity), at: CGPoint(x: pageW - margin - 220, y: y), font: .systemFont(ofSize: 12), width: 50, align: .right)
                draw(currency(item.rate), at: CGPoint(x: pageW - margin - 150, y: y), font: .systemFont(ofSize: 12), width: 70, align: .right)
                draw(currency(item.amount), at: CGPoint(x: pageW - margin - 80, y: y), font: .systemFont(ofSize: 12), width: 80, align: .right)
                y += 22
            }

            y += 10
            drawRule(at: y - 4, from: pageW/2, to: pageW - margin)
            totalRow("Subtotal", currency(invoice.subtotal), &y, pageW, margin, bold: false)
            if invoice.taxPercent > 0 {
                totalRow("Tax (\(String(format: "%g", invoice.taxPercent))%)", currency(invoice.tax), &y, pageW, margin, bold: false)
            }
            totalRow("Total", currency(invoice.total), &y, pageW, margin, bold: true)

            if watermark {
                draw("Made with InvoiceMaker", at: CGPoint(x: margin, y: pageH - margin), font: .systemFont(ofSize: 9), color: .lightGray)
            }
        }
    }

    private static func totalRow(_ label: String, _ value: String, _ y: inout CGFloat, _ pageW: CGFloat, _ margin: CGFloat, bold: Bool) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: 15) : .systemFont(ofSize: 13)
        draw(label, at: CGPoint(x: pageW - margin - 240, y: y), font: font, width: 140, align: .right)
        draw(value, at: CGPoint(x: pageW - margin - 90, y: y), font: font, width: 90, align: .right)
        y += 24
    }

    private static func draw(_ text: String, at p: CGPoint, font: UIFont, color: UIColor = .black, width: CGFloat = 400, align: NSTextAlignment = .left) {
        let style = NSMutableParagraphStyle(); style.alignment = align
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: style]
        text.draw(in: CGRect(x: p.x, y: p.y, width: width, height: font.lineHeight + 4), withAttributes: attrs)
    }

    private static func drawRule(at y: CGFloat, from x0: CGFloat, to x1: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x0, y: y)); path.addLine(to: CGPoint(x: x1, y: y))
        UIColor.lightGray.setStroke(); path.lineWidth = 0.5; path.stroke()
    }
}
