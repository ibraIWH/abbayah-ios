import SwiftUI

struct EmailVerifyView: View {
    let email: String

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")
    private let gold = Color(hex: "C4A882")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        LinearGradient(colors: [Color(hex: "3D0608"), Color(hex: "5C0A14")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Image("AbyrLogo")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 140)
                            .padding(.vertical, 48)
                    }

                    VStack(spacing: 0) {
                        // Icon
                        ZStack {
                            Circle()
                                .stroke(gold, lineWidth: 1)
                                .frame(width: 72, height: 72)
                            Image(systemName: "envelope")
                                .font(.system(size: 28))
                                .foregroundColor(gold)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 24)

                        Text("Verify your email")
                            .font(.custom("Georgia", size: 26))
                            .italic()
                            .foregroundColor(inkBlack)
                            .padding(.bottom, 8)

                        Text("We've sent a link to")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(email.isEmpty ? "your email" : email)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(inkBlack)
                            .padding(.bottom, 32)

                        // Steps
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STEPS")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(2)
                                .foregroundColor(goldTan)
                                .padding(.bottom, 4)

                            ForEach(Array(["Open your email inbox", "Tap the verification link", "You'll be signed in automatically"].enumerated()), id: \.offset) { i, step in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(inkBlack)
                                            .frame(width: 20, height: 20)
                                        Text("\(i + 1)")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(warmCream)
                                    }
                                    Text(step)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(Color(hex: "F5F2EC"))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)

                        // Buttons
                        VStack(spacing: 12) {
                            Button {
                                // TODO: open mail app
                            } label: {
                                Text("OPEN EMAIL APP")
                                    .font(.system(size: 11, weight: .medium))
                                    .tracking(3)
                                    .foregroundColor(warmCream)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(inkBlack)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 24)

                            Button {} label: {
                                Text("Resend Link")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 24)
                        }

                        Text("Link expires in 24 hours")
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray.opacity(0.4))
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
    }
}
