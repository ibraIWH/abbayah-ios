import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var savedOK = false

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let warmCream = Color(hex: "F5F0E8")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let brandRed = Color(hex: "5C0A14")

    private var canSave: Bool {
        !name.isEmpty && !email.isEmpty && !isSaving
    }

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    field("FULL NAME", text: $name)
                    field("EMAIL", text: $email, keyboard: .emailAddress)
                    field("PHONE", text: $phone, keyboard: .phonePad)

                    Text("Changing your email means you'll need to verify the new address.")
                        .font(.system(size: 10)).foregroundColor(.secondary)

                    if !errorMessage.isEmpty {
                        Text(errorMessage).font(.system(size: 11)).foregroundColor(.red)
                    }
                    if savedOK {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "1B5E20"))
                            Text("Profile updated").font(.system(size: 11, weight: .medium)).foregroundColor(Color(hex: "1B5E20"))
                        }
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        Text(isSaving ? "SAVING..." : "SAVE CHANGES")
                            .font(.system(size: 11, weight: .medium)).tracking(3)
                            .foregroundColor(warmCream)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(canSave ? brandRed : Color.gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSave)
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("EDIT PROFILE")
                    .font(.system(size: 11, weight: .medium)).tracking(2).foregroundColor(inkBlack)
            }
        }
        .onAppear {
            name = auth.currentUser?.name ?? ""
            email = auth.currentUser?.email ?? ""
            phone = "" // phone isn't on the cached AuthUser; user can fill it
        }
    }

    private func field(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 9, weight: .medium)).tracking(1.5).foregroundColor(.secondary)
            TextField("", text: text)
                .font(.system(size: 14))
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled(keyboard == .emailAddress)
                .padding(.bottom, 10)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(inkBlack), alignment: .bottom)
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = ""
        savedOK = false
        do {
            _ = try await auth.updateProfile(name: name, email: email, phone: phone)
            savedOK = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
