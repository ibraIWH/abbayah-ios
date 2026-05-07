import SwiftUI

struct OrderConfirmedView: View {
    private let brandRed = Color(hex: "5C0A14")
    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let gold = Color(hex: "C4A882")

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Success icon
                ZStack {
                    Circle()
                        .stroke(Color(hex: "1B5E20"), lineWidth: 1)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(Color(hex: "1B5E20"))
                }
                .padding(.bottom, 28)

                // Title
                Text("Order Confirmed")
                    .font(.custom("Georgia", size: 30))
                    .italic()
                    .foregroundColor(inkBlack)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)

                Text("Thank you for your order.\nWe'll send a confirmation to your email.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.bottom, 36)

                // Order number
                VStack(spacing: 6) {
                    Text("ORDER NUMBER")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(2)
                        .foregroundColor(goldTan)
                    Text("ABR-20260001")
                        .font(.custom("Georgia", size: 20))
                        .italic()
                        .foregroundColor(goldTan)
                        .letterSpacing(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(hex: "F5F2EC"))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                Text("Estimated delivery: 3 – 5 business days")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {} label: {
                        Text("TRACK MY ORDER")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(3)
                            .foregroundColor(warmCream)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(brandRed)
                    }
                    .buttonStyle(.plain)

                    Button {
                        // Pop to root
                        dismiss()
                    } label: {
                        Text("CONTINUE SHOPPING")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(3)
                            .foregroundColor(brandRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .overlay(Rectangle().stroke(brandRed, lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AbyrNavLogo()
            }
        }
    }
}

extension Text {
    func letterSpacing(_ spacing: CGFloat) -> some View {
        self.kerning(spacing)
    }
}
