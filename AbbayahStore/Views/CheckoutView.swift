import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var auth: AuthService
    @StateObject private var addressService = AddressService.shared

    private let brandRed = Color(hex: "5C0A14")
    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    @State private var selectedAddressID: String?
    @State private var isPlacing = false
    @State private var errorMessage = ""
    @State private var placedOrder: PlacedOrder?

    private let freeThreshold: Double = 200
    private var deliveryFee: Double { cart.totalPrice >= freeThreshold ? 0 : 25 }
    private var grandTotal: Double { cart.totalPrice + deliveryFee }

    private var selectedAddress: Address? {
        addressService.addresses.first { $0.id == selectedAddressID }
    }
    private var canPlace: Bool { selectedAddress != nil && !cart.isEmpty && !isPlacing }

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Text("DELIVERY ADDRESS")
                        .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 14)

                    if addressService.isLoading && addressService.addresses.isEmpty {
                        ProgressView().tint(inkBlack)
                            .frame(maxWidth: .infinity).padding(.vertical, 30)
                    } else if addressService.addresses.isEmpty {
                        noAddressesYet
                    } else {
                        VStack(spacing: 10) {
                            ForEach(addressService.addresses) { addr in
                                addressRow(addr)
                            }
                        }
                        .padding(.horizontal, 20)

                        addAddressButton.padding(.horizontal, 20).padding(.top, 12)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage).font(.system(size: 11)).foregroundColor(.red)
                            .padding(.horizontal, 20).padding(.top, 14)
                    }

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
                        summaryRow("Subtotal", "SAR \(String(format: "%.2f", cart.totalPrice))")
                        summaryRow("Delivery", deliveryFee == 0 ? "Free" : "SAR 25.00",
                                   valueColor: deliveryFee == 0 ? Color(hex: "1B5E20") : inkBlack)
                        Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                        HStack {
                            Text("Total").font(.system(size: 13, weight: .medium)).foregroundColor(inkBlack)
                            Spacer()
                            Text("SAR \(grandTotal, specifier: "%.2f")")
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
                    Text(isPlacing ? "PLACING ORDER..."
                         : selectedAddress == nil ? "SELECT AN ADDRESS" : "PLACE ORDER")
                        .font(.system(size: 11, weight: .medium)).tracking(3)
                        .foregroundColor(warmCream)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(canPlace ? brandRed : Color.gray)
                }
                .buttonStyle(.plain)
                .disabled(!canPlace)
                .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 24)
                .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .toolbar {
            ToolbarItem(placement: .principal) { AbyrNavLogo() }
        }
        .navigationDestination(item: $placedOrder) { order in
            OrderConfirmedView(orderNumber: order.number)
        }
        .task {
            await addressService.fetch()
            if selectedAddressID == nil {
                selectedAddressID = (addressService.addresses.first { $0.isDefault == true }
                                     ?? addressService.addresses.first)?.id
            }
        }
    }

    private func addressRow(_ addr: Address) -> some View {
        let isSelected = addr.id == selectedAddressID
        return Button {
            selectedAddressID = addr.id
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 17))
                    .foregroundColor(isSelected ? inkBlack : Color.gray.opacity(0.4))
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(addr.name).font(.system(size: 13, weight: .medium)).foregroundColor(inkBlack)
                        if addr.isDefault == true {
                            Text("DEFAULT")
                                .font(.system(size: 7, weight: .medium)).tracking(1)
                                .foregroundColor(warmCream)
                                .padding(.horizontal, 6).padding(.vertical, 2).background(inkBlack)
                        }
                    }
                    Text(addr.line1).font(.system(size: 12)).foregroundColor(inkBlack)
                    Text(addr.city).font(.system(size: 11)).foregroundColor(.secondary)
                    if let phone = addr.phone, !phone.isEmpty {
                        Text(phone).font(.system(size: 11)).foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(Rectangle().stroke(isSelected ? inkBlack : borderColor, lineWidth: isSelected ? 1 : 0.5))
        }
        .buttonStyle(.plain)
    }

    private var noAddressesYet: some View {
        VStack(spacing: 14) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 34)).foregroundColor(goldTan.opacity(0.35))
            Text("No saved addresses")
                .font(.custom("Georgia", size: 18)).italic().foregroundColor(inkBlack)
            Text("Add a delivery address to place your order.")
                .font(.system(size: 11)).foregroundColor(.secondary).multilineTextAlignment(.center)
            addAddressButton.padding(.top, 4)
        }
        .frame(maxWidth: .infinity).padding(.horizontal, 20).padding(.vertical, 28)
        .background(Color.white).padding(.horizontal, 20)
    }

    private var addAddressButton: some View {
        NavigationLink {
            AddressesView()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "plus").font(.system(size: 11, weight: .semibold))
                Text("ADD NEW ADDRESS").font(.system(size: 10, weight: .medium)).tracking(2)
            }
            .foregroundColor(inkBlack)
            .frame(maxWidth: .infinity).frame(height: 46)
            .overlay(Rectangle().stroke(inkBlack, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private func summaryRow(_ label: String, _ value: String, valueColor: Color? = nil) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size: 11)).foregroundColor(valueColor ?? inkBlack)
        }
        .padding(.horizontal, 20).padding(.vertical, 10)
    }

    private func placeOrder() async {
        guard let addr = selectedAddress else { return }
        isPlacing = true
        errorMessage = ""
        do {
            let order = try await OrderService.shared.placeOrder(
                items: cart.items,
                name: addr.name,
                line1: addr.line1,
                city: addr.city,
                phone: addr.phone ?? ""
            )
            cart.clear()
            placedOrder = PlacedOrder(number: order.orderNumber)
        } catch {
            errorMessage = error.localizedDescription
        }
        isPlacing = false
    }
}

struct PlacedOrder: Identifiable, Hashable {
    let id = UUID()
    let number: String
}
