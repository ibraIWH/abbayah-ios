import SwiftUI

struct AddressesView: View {
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    let addresses = [
        AddressItem(id: "1", label: "Home", name: "Ibrahim Al-Wahidi", address: "12 King Fahd Rd\nRiyadh, Saudi Arabia 11564", phone: "+966 5XX XXX XXXX", isDefault: true),
        AddressItem(id: "2", label: "Work", name: "Ibrahim Al-Wahidi", address: "Saudi Railway HQ\nCentral Station, Riyadh", phone: "+966 5XX XXX XXXX", isDefault: false),
    ]

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(addresses) { address in
                        addressCard(address: address)
                    }

                    // Add new address
                    Button {} label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 13))
                                .foregroundColor(goldTan)
                            Text("Add New Address")
                                .font(.system(size: 13))
                                .foregroundColor(goldTan)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .overlay(Rectangle().stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4])).foregroundColor(borderColor))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
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

    private func addressCard(address: AddressItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Label + default badge
            HStack {
                Text(address.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(inkBlack)
                if address.isDefault {
                    Text("DEFAULT")
                        .font(.system(size: 7, weight: .medium))
                        .tracking(1)
                        .foregroundColor(warmCream)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(inkBlack)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 10)

            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 16)

            // Address details
            VStack(alignment: .leading, spacing: 4) {
                Text(address.name)
                    .font(.system(size: 12))
                    .foregroundColor(inkBlack)
                Text(address.address)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                Text(address.phone)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 16)

            // Actions
            HStack(spacing: 20) {
                Button {} label: {
                    Text("EDIT")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1)
                        .foregroundColor(goldTan)
                }
                .buttonStyle(.plain)

                if !address.isDefault {
                    Button {} label: {
                        Text("SET DEFAULT")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(1)
                            .foregroundColor(goldTan)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {} label: {
                    Text("DELETE")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct AddressItem: Identifiable {
    let id: String
    let label: String
    let name: String
    let address: String
    let phone: String
    let isDefault: Bool
}
