import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")
    private let brandRed = Color(hex: "5C0A14")
    private let gold = Color(hex: "C4A882")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        LinearGradient(colors: [Color(hex: "3D0608"), brandRed], startPoint: .topLeading, endPoint: .bottomTrailing)
                        VStack(spacing: 10) {
                            Image("AbyrLogo")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 140)
                            Text("Welcome back")
                                .font(.system(size: 11))
                                .tracking(3)
                                .foregroundColor(gold.opacity(0.7))
                                .textCase(.uppercase)
                        }
                        .padding(.vertical, 48)
                    }

                    // Form
                    VStack(spacing: 20) {
                        inputField(label: "Email", placeholder: "you@email.com", text: $email, isSecure: false)
                        inputField(label: "Password", placeholder: "Min. 8 characters", text: $password, isSecure: true)

                        HStack {
                            Spacer()
                            Button("Forgot password?") {}
                                .font(.system(size: 10))
                                .foregroundColor(goldTan)
                        }

                        // Sign In button
                        Button {
                            Task { await signIn() }
                        } label: {
                            Text(isLoading ? "SIGNING IN..." : "SIGN IN")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(3)
                                .foregroundColor(warmCream)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(isLoading ? Color.gray : inkBlack)
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Divider
                        HStack {
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                            Text("or").font(.system(size: 10)).foregroundColor(.secondary)
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                        }

                        // Social buttons
                        HStack(spacing: 12) {
                            socialButton(label: "Google", bg: Color.white, fg: inkBlack)
                            socialButton(label: "Facebook", bg: Color(hex: "1877F2"), fg: .white)
                        }

                        // Sign Up link
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Button("Create one") { showSignUp = true }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(inkBlack)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView()
        }
    }

    private func inputField(label: String, placeholder: String, text: Binding<String>, isSecure: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.secondary)
            if isSecure {
                SecureField(placeholder, text: text)
                    .font(.system(size: 13))
                    .padding(.bottom, 10)
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(inkBlack), alignment: .bottom)
            } else {
                TextField(placeholder, text: text)
                    .font(.system(size: 13))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.bottom, 10)
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(inkBlack), alignment: .bottom)
            }
        }
    }

    private func socialButton(label: String, bg: Color, fg: Color) -> some View {
        Button {} label: {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(fg)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(bg)
                .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
    // line ~115 — before the last closing }
    private func signIn() async {
            isLoading = true
            errorMessage = ""
            do {
                _ = try await auth.login(email: email, password: password)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
}

