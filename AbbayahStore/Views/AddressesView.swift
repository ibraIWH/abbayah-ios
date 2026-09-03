import SwiftUI

struct AddressesView: View {
    @StateObject private var service = AddressService.shared

    @State private var showAddForm = false
    @State private var newName = ""
    @State private var newLine1 = ""
    @State private var newCity = ""
    @State private var newPhone = ""
    @State private var isSaving = false

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let warmCream = Color(hex: "F5F0E8")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    private var canSave: Bool {
        !newName.isEmpty && !newLine1.isEmpty && !newCity.isEmpty && !isSaving
    }

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {

                    if service.isLoading && service.addresses.isEmpty {
                        ProgressView().tint(inkBlack)
                            .frame(maxWidth: .infinity).padding(.top, 60)
                    } else if service.addresses.isEmpty && !showAddForm {
                        emptyState
                    } else {
                        ForEach(service.addresses) { address in
                            addressCard(address)
                        }
                    }

                    if showAddForm {
                        addForm
                    } else {
                        Button {
                            showAddForm = true
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "plus").font(.system(size: 11, weight: .semibold))
                                Text("ADD NEW ADDRESS")
                                    .font(.system(size: 10, weight: .medium)).tracking(2)
                            }
                            .foregroundColor(inkBlack)
                            .frame(maxWidth: .infinity).frame(height: 46)
                            .overlay(Rectangle().stroke(inkBlack, lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
                    }

                    if let msg = service.errorMessage {
                        Text(msg).font(.system(size: 11)).foregroundColor(.red)
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { AbyrNavLogo() }
        }
        .task { await service.fetch() }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 40)).foregroundColor(goldTan.opacity(0.35))
            Text("No Saved Addresses")
                .font(.custom("Georgia", size: 20)).italic().foregroundColor(inkBlack)
            Text("Add a delivery address to speed up checkout.")
                .font(.system(size: 11)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40)
    }

    private func addressCard(_ address: Address) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(address.name)
                    .font(.system(size: 13, weight: .medium)).foregroundColor(inkBlack)
                if address.isDefault == true {
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
                Text(address.line1).font(.system(size: 12)).foregroundColor(inkBlack)
                Text(address.city).font(.system(size: 11)).foregroundColor(.secondary)
                if let phone = address.phone, !phone.isEmpty {
                    Text(phone).font(.system(size: 11)).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)

            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 16)

            HStack(spacing: 20) {
                if address.isDefault != true {
                    Button {
                        Task { await service.setDefault(id: address.id) }
                    } label: {
                        Text("SET DEFAULT")
                            .font(.system(size: 9, weight: .medium)).tracking(1).foregroundColor(goldTan)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Button {
                    Task { await service.delete(id: address.id) }
                } label: {
                    Text("DELETE")
                        .font(.system(size: 9, weight: .medium)).tracking(1)
                        .foregroundColor(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(Color.white)
        .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
    }

    private var addForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NEW ADDRESS")
                .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)

            formField("Full Name", text: $newName)
            formField("Address", text: $newLine1)
            formField("City", text: $newCity)
            formField("Phone (for delivery)", text: $newPhone)

            HStack(spacing: 12) {
                Button {
                    Task {
                        isSaving = true
                        let ok = await service.add(
                            name: newName, line1: newLine1, city: newCity,
                            phone: newPhone, isDefault: service.addresses.isEmpty
                        )
                        isSaving = false
                        if ok { clearForm(); showAddForm = false }
                    }
                } label: {
                    Text(isSaving ? "SAVING..." : "SAVE")
                        .font(.system(size: 11, weight: .medium)).tracking(2)
                        .foregroundColor(warmCream)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(canSave ? inkBlack : Color.gray)
                }
                .buttonStyle(.plain)
                .disabled(!canSave)

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
        .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
    }

    private func formField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 13))
            .padding(.vertical, 10).padding(.horizontal, 12)
            .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
    }

    private func clearForm() {
        newName = ""; newLine1 = ""; newCity = ""; newPhone = ""
    }
}
