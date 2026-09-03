import SwiftUI

// MARK: - FAQ
struct FAQView: View {
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    private let faqs: [(q: String, a: String)] = [
        ("How long does delivery take?",
         "Orders within Hargeisa and Riyadh are typically delivered within 2–4 business days. You'll be able to track your order status in the app under My Orders."),
        ("Is delivery free?",
         "Delivery is free on all orders over SAR 200. For orders below that, a flat SAR 25 delivery fee applies."),
        ("What payment methods do you accept?",
         "We currently accept cash on delivery. More payment options are coming soon."),
        ("Can I return or exchange an item?",
         "Yes. Items can be returned or exchanged within 7 days of delivery, provided they are unworn and in their original condition. Contact us to arrange a return."),
        ("How do I know my size?",
         "Each product page lists available sizes from XS to XL. If you're unsure, reach out through Contact Us and we'll help you choose."),
        ("How do I track my order?",
         "Open the app, go to your profile, and tap My Orders. Each order shows its current status, from placed through to delivered.")
    ]

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(faqs.indices, id: \.self) { i in
                        FAQRow(question: faqs[i].q, answer: faqs[i].a)
                        if i < faqs.count - 1 {
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                        }
                    }
                }
                .background(Color.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("FAQ").font(.system(size: 11, weight: .medium)).tracking(2).foregroundColor(inkBlack)
            }
        }
    }
}

private struct FAQRow: View {
    let question: String
    let answer: String
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack {
                    Text(question)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: expanded ? "minus" : "plus")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "8B7355"))
                }
                .padding(.horizontal, 16).padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            if expanded {
                Text(answer)
                    .font(.system(size: 12)).foregroundColor(.secondary).lineSpacing(5)
                    .padding(.horizontal, 16).padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Contact Us
struct ContactView: View {
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Get in Touch")
                        .font(.custom("Georgia", size: 24)).italic().foregroundColor(inkBlack)
                        .padding(.bottom, 2)
                    Text("We'd love to hear from you. Reach us through any of the channels below and we'll respond as soon as we can.")
                        .font(.system(size: 12)).foregroundColor(.secondary).lineSpacing(4)

                    contactRow(icon: "envelope", label: "Email", value: "hello@abyrline.com",
                               url: "mailto:hello@abyrline.com")
                    contactRow(icon: "phone", label: "Phone", value: "+252 63 000 0000",
                               url: "tel:+25263000000")
                    contactRow(icon: "camera", label: "Instagram", value: "@abyrline",
                               url: "https://instagram.com/abyrline")
                    contactRow(icon: "message", label: "WhatsApp", value: "Chat with us",
                               url: "https://wa.me/25263000000")
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("CONTACT US").font(.system(size: 11, weight: .medium)).tracking(2).foregroundColor(inkBlack)
            }
        }
    }

    private func contactRow(icon: String, label: String, value: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16)).foregroundColor(goldTan)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label.uppercased())
                        .font(.system(size: 8, weight: .medium)).tracking(1).foregroundColor(.secondary)
                    Text(value)
                        .font(.system(size: 13)).foregroundColor(inkBlack)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11)).foregroundColor(goldTan.opacity(0.6))
            }
            .padding(16)
            .background(Color.white)
            .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
        }
    }
}

// MARK: - About Abyr
struct AboutView: View {
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let gold = Color(hex: "C4A882")
    private let sandBg = Color(hex: "FAFAF8")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("EST. 2026 · HARGEISA")
                        .font(.system(size: 9, weight: .medium)).tracking(3).foregroundColor(goldTan)
                        .padding(.top, 10)

                    Text("Abyr")
                        .font(.custom("Georgia", size: 40)).italic().foregroundColor(inkBlack)

                    Text("Elegance, woven with intention.")
                        .font(.custom("Georgia", size: 17)).italic().foregroundColor(goldTan)

                    Text("Abyr Line was born from a love of timeless modest fashion. Each abaya in our collection is chosen for its quality, its craftsmanship, and the quiet confidence it gives the woman who wears it.")
                        .font(.system(size: 13)).foregroundColor(inkBlack.opacity(0.85)).lineSpacing(6)

                    Text("From our home in Hargeisa to your wardrobe, we're committed to pieces that feel as considered as they look — designed to be worn, loved, and remembered.")
                        .font(.system(size: 13)).foregroundColor(inkBlack.opacity(0.85)).lineSpacing(6)

                    Rectangle().fill(gold.opacity(0.4)).frame(height: 0.5).padding(.vertical, 6)

                    Text("Thank you for being part of our story.")
                        .font(.custom("Georgia", size: 15)).italic().foregroundColor(inkBlack)

                    Text("Follow us @abyrline")
                        .font(.system(size: 11, weight: .medium)).tracking(1).foregroundColor(goldTan)
                        .padding(.top, 2)
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ABOUT ABYR").font(.system(size: 11, weight: .medium)).tracking(2).foregroundColor(inkBlack)
            }
        }
    }
}
