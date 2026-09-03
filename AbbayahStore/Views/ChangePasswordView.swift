import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var current = ""
    @State private var newPass = ""
    @State private var confirm = ""
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var savedOK = false

    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let sandBg = Color(hex: "FAFAF8")
    private let brandRed = Color(hex: "5C0A14")

    private var canSave: Bool {
        !current.isEmpty && newPass.count >= 8 && newPass == confirm && !isSaving
    }

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    secureField("CURRENT PASSWORD", text: $current)
                    secureField("NEW PASSWORD", text: $newPass)
                    secureField("CONFIRM NEW PASSWORD", text: $confirm)

                    if !newPass.isEmpty && newPass.count < 8 {
                        Text("New password must be at least 8 characters.")
                            .font(.system(size: 10)).foregroundColor(.secondary)
                    }
                    if !confirm.isEmpty && newPass != confirm {
                        Text("Passwords don't match.")
                            .font(.system(size: 10)).foregroundColor(.red)
                    }
                    if !errorMessage.isEmpty {
                        Text(errorMessage).font(.system(size: 11)).foregroundColor(.red)
                    }
                    if savedOK {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "1B5E20"))
                            Text("Password changed").font(.system(size: 11, weight: .medium)).foregroundColor(Color(hex: "1B5E20"))
                        }
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        Text(isSaving ? "UPDATING..." : "UPDATE PASSWORD")
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
                Text("CHANGE PASSWORD")
                    .font(.system(size: 11, weight: .medium)).tracking(2).foregroundColor(inkBlack)
            }
        }
    }

    private func secureField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 9, weight: .medium)).tracking(1.5).foregroundColor(.secondary)
            SecureField("", text: text)
                .font(.system(size: 14))
                .padding(.bottom, 10)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(inkBlack), alignment: .bottom)
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = ""
        savedOK = false
        do {
            try await auth.changePassword(current: current, newPassword: newPass)
            savedOK = true
            current = ""; newPass = ""; confirm = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
