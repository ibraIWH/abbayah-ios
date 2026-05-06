import SwiftUI

struct SignUpView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreed = false
    @State private var showVerify = false

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
                            Text("Create your account")
                                .font(.system(size: 11))
                                .tracking(3)
                                .foregroundColor(gold.opacity(0.7))
                                .textCase(.uppercase)
                        }
                        .padding(.vertical, 48)
                    }

                    // Form
                    VStack(spacing: 20) {
                        inputField(label: "Full Name", placeholder: "Your name", text: $fullName, isSecure: false)
                        inputField(label: "Email", placeholder: "you@email.com", text: $email, isSecure: false)
                        inputField(label: "Password", placeholder: "Min. 8 characters", text: $password, isSecure: true)

                        // Terms
                        HStack(alignment: .top, spacing: 10) {
                            Button { agreed.toggle() } label: {
                                Image(systemName: agreed ? "checkmark.square.fill" : "square")
                                    .foregroundColor(agreed ? inkBlack : borderColor)
                                    .font(.system(size: 18))
                            }
                            .buttonStyle(.plain)
                            Text("I agree to the Terms & Conditions and Privacy Policy")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineSpacing(3)
                        }

                        // Create Account button
                        Button {
                            if agreed { showVerify = true }
                        } label: {
                            Text("CREATE ACCOUNT")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(3)
                                .foregroundColor(warmCream)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(agreed ? inkBlack : Color.gray.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                        .disabled(!agreed)

                        // Divider
                        HStack {
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                            Text("or").font(.system(size: 10)).foregroundColor(.secondary)
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                        }

                        // Social
                        HStack(spacing: 12) {
                            socialButton(label: "Google", bg: Color.white, fg: inkBlack)
                            socialButton(label: "Facebook", bg: Color(hex: "1877F2"), fg: .white)
                        }

                        // Sign In link
                        HStack(spacing: 4) {
                            Text("Already a member?")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Button("Sign In") {}
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
        .navigationDestination(isPresented: $showVerify) {
            EmailVerifyView(email: email)
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
}

