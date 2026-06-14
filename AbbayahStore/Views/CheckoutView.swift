import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cart: CartStore

    private let brandRed = Color(hex: "5C0A14")
    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    @State private var name = ""
    @State private var line1 = ""
    @State private var city = ""
    @State private var phone = ""
    @State private var isPlacing = false
    @State private var errorMessage = ""
    @State private var placedOrder: PlacedOrder?

    var canPlace: Bool {
        !name.isEmpty && !line1.isEmpty && !city.isEmpty && !cart.isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("DELIVERY ADDRESS")
                        .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 16)

                    VStack(spacing: 16) {
                        field("Full Name", text: $name)
                        field("Address", text: $line1)
                        field("City", text: $city)
                        field("Phone", text: $phone)
                    }
                    .padding(.horizontal, 20)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 11)).foregroundColor(.red)
                            .padding(.horizontal, 20).padding(.top, 12)
                    }

                    // Summary
                    Text("ORDER SUMMARY")
                        .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                        .padding(.horizontal, 20).padding(.top, 28).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        ForEach(cart.items) { item in
                            HStack {
                                Text("\(item.product.name) × \(item.quantity)")
                                    .font(.system(size: 11)).foregroundColor(.secondary)
                                Spacer()
                                Text("SAR \(item.product.displayPrice * Double(item.quantity), specifier: "%.2f")")
                                    .font(.system(size: 11)).foregroundColor(inkBlack)
                            }
                            .padding(.horizontal, 20).padding(.vertical, 8)
                        }
                        Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                        HStack {
                            Text("Total").font(.system(size: 13, weight: .medium)).foregroundColor(inkBlack)
                            Spacer()
                            Text("SAR \(cart.totalPrice, specifier: "%.2f")")
                                .font(.custom("Georgia", size: 16)).italic().foregroundColor(goldTan)
                        }
                        .padding(.horizontal, 20).padding(.vertical, 12)
                    }
                    .background(Color.white)

                    Color.clear.frame(height: 120)
                }
            }

            VStack(spacing: 0) {
                Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                Button {
                    Task { await placeOrder() }
                } label: {
                    Text(isPlacing ? "PLACING ORDER..." : "PLACE ORDER")
                        .font(.system(size: 11, weight: .medium)).tracking(3)
                        .foregroundColor(warmCream)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(canPlace && !isPlacing ? brandRed : Color.gray)
                }
                .buttonStyle(.plain)
                .disabled(!canPlace || isPlacing)
                .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 24)
                .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable().renderingMode(.original).scaledToFit()
                    .frame(width: 160).scaleEffect(1.5)
            }
        }
        .navigationDestination(item: $placedOrder) { order in
            OrderConfirmedView(orderNumber: order.number)
        }
        .onAppear {
            loadSavedAddress()
        }
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium)).tracking(1.5).foregroundColor(.secondary)
            TextField("", text: text)
                .font(.system(size: 13))
                .padding(.bottom, 10)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(inkBlack), alignment: .bottom)
        }
    }

    private func loadSavedAddress() {
        let d = UserDefaults.standard
        if name.isEmpty { name = d.string(forKey: "addr_name") ?? "" }
        if line1.isEmpty { line1 = d.string(forKey: "addr_line1") ?? "" }
        if city.isEmpty { city = d.string(forKey: "addr_city") ?? "" }
        if phone.isEmpty { phone = d.string(forKey: "addr_phone") ?? "" }
    }

    private func saveAddress() {
        let d = UserDefaults.standard
        d.set(name, forKey: "addr_name")
        d.set(line1, forKey: "addr_line1")
        d.set(city, forKey: "addr_city")
        d.set(phone, forKey: "addr_phone")
    }

    private func placeOrder() async {
        isPlacing = true
        errorMessage = ""
        do {
            let order = try await OrderService.shared.placeOrder(
                items: cart.items, name: name, line1: line1, city: city, phone: phone
            )
            saveAddress()
            cart.clear()
            placedOrder = PlacedOrder(number: order.orderNumber)
        } catch {
            errorMessage = "Could not place order. Please try again."
        }
        isPlacing = false
    }
}

struct PlacedOrder: Identifiable, Hashable {
    let id = UUID()
    let number: String
}
