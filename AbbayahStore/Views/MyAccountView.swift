import SwiftUI

struct MyAccountView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var showSignOutConfirm = false

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
                                Text(initials)
                                    .font(.custom("Georgia", size: 28))
                                    .italic()
                                    .foregroundColor(gold)
                            }

                            // Name + email
                            VStack(spacing: 4) {
                                Text(auth.currentUser?.name ?? "Guest")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(warmCream)
                                Text(auth.currentUser?.email ?? "Not signed in")
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
                            NavigationLink { EditProfileView() } label: { menuRowLabel(icon: "person", label: "Edit Profile") }
                            menuRow(icon: "bell", label: "Notifications")
                            NavigationLink { ChangePasswordView() } label: { menuRowLabel(icon: "lock", label: "Change Password") }
                        }

                        menuSection(title: "Support") {
                            NavigationLink { FAQView() } label: { menuRowLabel(icon: "questionmark.circle", label: "FAQ") }
                            NavigationLink { ContactView() } label: { menuRowLabel(icon: "envelope", label: "Contact Us") }
                            NavigationLink { AboutView() } label: { menuRowLabel(icon: "info.circle", label: "About Abyr") }
                        }

                        // Sign Out / Sign In
                        if auth.isLoggedIn {
                            Button {
                                showSignOutConfirm = true
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
                            .buttonStyle(.plain)
                            .background(Color.white)
                            .padding(.top, 16)
                        } else {
                            NavigationLink {
                                SignInView()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                        .font(.system(size: 16))
                                        .foregroundColor(brandRed)
                                        .frame(width: 24)
                                    Text("Sign In")
                                        .font(.system(size: 13))
                                        .foregroundColor(brandRed)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(.plain)
                            .background(Color.white)
                            .padding(.top, 16)
                        }
                    }

                    Color.clear.frame(height: 100)
                }
            }
        }
        .confirmationDialog(
            "Sign out of your account?",
            isPresented: $showSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                auth.signOut()
            }
            Button("Cancel", role: .cancel) { }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AbyrNavLogo()
            }
        }
    }

    // MARK: - Initials for avatar
    private var initials: String {
        let name = auth.currentUser?.name ?? "Guest"
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
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

    // MARK: - Menu Row Label (for NavigationLink)
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

    // MARK: - Menu Row (plain button)
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
