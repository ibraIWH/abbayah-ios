import SwiftUI

struct CartView: View {
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")
    private let gold = Color(hex: "C4A882")

    @State private var showCheckout = false

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            // Empty cart state
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "bag")
                    .font(.system(size: 52))
                    .foregroundColor(goldTan.opacity(0.4))
                Text("Your Cart is Empty")
                    .font(.custom("Georgia", size: 24))
                    .italic()
                    .foregroundColor(inkBlack)
                Text("Add products to your cart\nto get started.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                Spacer()
            }

            // TODO: replace with real cart items after auth
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 160)
                    .scaleEffect(1.5)
            }
        }
    }
}
