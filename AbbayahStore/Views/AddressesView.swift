import SwiftUI

struct SavedAddress: Identifiable, Codable, Equatable {
    var id = UUID()
    var label: String
    var line1: String
    var city: String
    var isDefault: Bool
}

struct AddressesView: View {
    @State private var addresses: [SavedAddress] = []
    @State private var showAddForm = false
    @State private var newLabel = ""
    @State private var newLine1 = ""
    @State private var newCity = ""

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")
    private let brandRed = Color(hex: "5C0A14")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    if addresses.isEmpty && !showAddForm {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 60)
                            Image(systemName: "mappin")
                                .font(.system(size: 52))
                                .foregroundColor(goldTan.opacity(0.3))
                            Text("No Addresses Yet")
                                .font(.custom("Georgia", size: 24))
                                .italic()
                                .foregroundColor(inkBlack)
                            Text("Add a delivery address\nto speed up checkout.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    ForEach(addresses) { address in
                        addressCard(address: address)
                    }

                    if showAddForm {
                        addForm
                    } else {
                        Button {
                            showAddForm = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 13)).foregroundColor(goldTan)
                                Text("Add New Address")
                                    .font(.system(size: 13)).foregroundColor(goldTan)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .overlay(Rectangle().stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4])).foregroundColor(borderColor))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }

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
                    .resizable().renderingMode(.original).scaledToFit()
                    .frame(width: 160).scaleEffect(1.5)
            }
        }
        .onAppear { loadAddresses() }
    }

    // MARK: - Address Card
    private func addressCard(address: SavedAddress) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(address.label)
                    .font(.system(size: 13, weight: .medium)).foregroundColor(inkBlack)
                if address.isDefault {
                    Text("DEFAULT")
                        .font(.system(size: 7, weight: .medium)).tracking(1)
                        .foregroundColor(warmCream)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(inkBlack)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 10)

            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(address.line1)
                    .font(.system(size: 12)).foregroundColor(inkBlack)
                Text(address.city)
                    .font(.system(size: 11)).foregroundColor(.secondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)

            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 16)

            HStack(spacing: 20) {
                if !address.isDefault {
                    Button {
                        setDefault(address)
                    } label: {
                        Text("SET DEFAULT")
                            .font(.system(size: 9, weight: .medium)).tracking(1).foregroundColor(goldTan)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    delete(address)
                } label: {
                    Text("DELETE")
                        .font(.system(size: 9, weight: .medium)).tracking(1).foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Add Form
    private var addForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NEW ADDRESS")
                .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)

            formField("Label (e.g. Home, Work)", text: $newLabel)
            formField("Address", text: $newLine1)
            formField("City", text: $newCity)

            HStack(spacing: 12) {
                Button {
                    saveNewAddress()
                } label: {
                    Text("SAVE")
                        .font(.system(size: 11, weight: .medium)).tracking(2)
                        .foregroundColor(warmCream)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(!newLine1.isEmpty && !newCity.isEmpty ? inkBlack : Color.gray)
                }
                .buttonStyle(.plain)
                .disabled(newLine1.isEmpty || newCity.isEmpty)

                Button {
                    showAddForm = false
                    clearForm()
                } label: {
                    Text("CANCEL")
                        .font(.system(size: 11, weight: .medium)).tracking(2)
                        .foregroundColor(inkBlack)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func formField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 13))
            .padding(.bottom, 8)
            .overlay(Rectangle().frame(height: 0.5).foregroundColor(borderColor), alignment: .bottom)
    }

    // MARK: - Data
    private func loadAddresses() {
        if let data = UserDefaults.standard.data(forKey: "abyr_addresses"),
           let saved = try? JSONDecoder().decode([SavedAddress].self, from: data) {
            addresses = saved
        }

        let d = UserDefaults.standard
        let checkoutLine1 = d.string(forKey: "addr_line1") ?? ""
        let checkoutCity = d.string(forKey: "addr_city") ?? ""

        if !checkoutLine1.isEmpty {
            let alreadyExists = addresses.contains { $0.line1 == checkoutLine1 && $0.city == checkoutCity }
            if !alreadyExists {
                let addr = SavedAddress(
                    label: "Home",
                    line1: checkoutLine1,
                    city: checkoutCity,
                    isDefault: addresses.isEmpty
                )
                addresses.append(addr)
                persist()
            }
        }
    }

    private func saveNewAddress() {
        let addr = SavedAddress(
            label: newLabel.isEmpty ? "Home" : newLabel,
            line1: newLine1,
            city: newCity,
            isDefault: addresses.isEmpty
        )
        addresses.append(addr)
        persist()
        showAddForm = false
        clearForm()
    }

    private func delete(_ address: SavedAddress) {
        addresses.removeAll { $0.id == address.id }
        if address.isDefault, let first = addresses.first {
            if let i = addresses.firstIndex(where: { $0.id == first.id }) {
                addresses[i].isDefault = true
            }
        }
        persist()
    }

    private func setDefault(_ address: SavedAddress) {
        for i in addresses.indices {
            addresses[i].isDefault = addresses[i].id == address.id
        }
        persist()

        let d = UserDefaults.standard
        d.set(address.line1, forKey: "addr_line1")
        d.set(address.city, forKey: "addr_city")
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(addresses) {
            UserDefaults.standard.set(data, forKey: "abyr_addresses")
        }
    }

    private func clearForm() {
        newLabel = ""; newLine1 = ""; newCity = ""
    }
}
