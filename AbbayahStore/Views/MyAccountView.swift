import SwiftUI

struct MyAccountView: View {
    
    private let brandRed = Color(hex: "5C0A14")
    private let gold = Color(hex: "C4A882")
    private let goldTan = Color(hex: "8B7355")
    private let inkBlack = Color(hex: "1A1A1A")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── PROFILE HEADER ──────────────────
                    ZStack {
                        brandRed.ignoresSafeArea()

                        VStack(spacing: 12) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "3D0608"))
                                    .frame(width: 80, height: 80)
                                Text("IW")
                                    .font(.custom("Georgia", size: 28))
                                    .italic()
                                    .foregroundColor(gold)
                            }

                            // Name + email
                            VStack(spacing: 4) {
                                Text("Ibrahim Al-Wahidi")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(warmCream)
                                Text("ibrahim@icloud.com")
                                    .font(.system(size: 11))
                                    .foregroundColor(gold.opacity(0.7))
                            }
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 28)
                    }

                    // ── MENU ITEMS ──────────────────────
                    VStack(spacing: 0) {
                        menuSection(title: "Shopping") {
                            NavigationLink { MyOrdersView() } label: { menuRowLabel(icon: "bag", label: "My Orders") }
                            NavigationLink { FavouritesView() } label: { menuRowLabel(icon: "heart", label: "Favourites") }
                            NavigationLink { AddressesView() } label: { menuRowLabel(icon: "mappin", label: "Addresses") }
                            menuRow(icon: "creditcard", label: "Payment Methods")
                        }

                        menuSection(title: "Account") {
                            menuRow(icon: "person", label: "Edit Profile")
                            menuRow(icon: "bell", label: "Notifications")
                            menuRow(icon: "lock", label: "Change Password")
                        }

                        menuSection(title: "Support") {
                            menuRow(icon: "questionmark.circle", label: "FAQ")
                            menuRow(icon: "envelope", label: "Contact Us")
                            menuRow(icon: "info.circle", label: "About Abyr")
                        }

                        // Sign Out
                        Button {
                            // TODO: sign out
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                                    .frame(width: 24)
                                Text("Sign Out")
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .background(Color.white)
                        .padding(.top, 16)
                    }

                    Color.clear.frame(height: 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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

    // MARK: - Menu Section
    private func menuSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundColor(goldTan)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
        }
    }
    private func menuRowLabel(icon: String, label: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(goldTan)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(inkBlack)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(Color.gray.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(borderColor)
                .padding(.leading, 58),
            alignment: .bottom
        )
    }

    // MARK: - Menu Row
    private func menuRow(icon: String, label: String) -> some View {
        Button {
            // TODO: navigate
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(goldTan)
                    .frame(width: 24)

                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(inkBlack)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(Color.gray.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(borderColor)
                    .padding(.leading, 58),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }
}
