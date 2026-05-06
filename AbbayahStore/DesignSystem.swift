import SwiftUI

// MARK: - Abyr Design System
extension Color {
    static let brandRed = Color(hex: "5C0A14")
    static let deepRed = Color(hex: "3D0608")
    static let abyrGold = Color(hex: "C4A882")
    static let abyrTan = Color(hex: "8B7355")
    static let inkBlack = Color(hex: "1A1A1A")
    static let sandBg = Color(hex: "FAFAF8")
    static let warmCream = Color(hex: "F5F0E8")
    static let abyrBorder = Color(hex: "E8E8E4")
}

// MARK: - Shared Nav Logo
struct AbyrNavLogo: View {
    var dark: Bool = true
    var body: some View {
        Image(dark ? "AbyrLogoDark" : "AbyrLogo")
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(width: 160)
            .scaleEffect(1.5)
    }
}

// MARK: - Shared CTA Button
struct AbyrButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .medium))
                .tracking(3)
                .foregroundColor(.warmCream)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.inkBlack)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shared Section Header
struct AbyrSectionHeader: View {
    let subtitle: String
    let title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(subtitle.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundColor(.abyrTan)
            Text(title)
                .font(.custom("Georgia", size: 22))
                .italic()
                .foregroundColor(.inkBlack)
        }
    }
}
