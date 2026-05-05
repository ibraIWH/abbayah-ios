import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.95

    private let brandRed = Color(hex: "5C0A14")
    private let deepRed = Color(hex: "3D0608")
    private let gold = Color(hex: "C4A882")

    var body: some View {
        if isActive {
            HomeView()
        } else {
            ZStack {
                // Brand red background
                LinearGradient(
                    colors: [deepRed, brandRed],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle gold glow
                RadialGradient(
                    colors: [gold.opacity(0.06), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo image
                    // Logo image
                    Image("AbyrLogo")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 220)
                        .opacity(opacity)
                        .scaleEffect(scale)

                    Spacer()

                    // Bottom tagline + dots
                    VStack(spacing: 8) {
                        Text("LINE")
                            .font(.system(size: 10, weight: .light))
                            .tracking(8)
                            .foregroundColor(gold.opacity(0.5))

                        HStack(spacing: 6) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .frame(width: 4, height: 4)
                                    .foregroundColor(gold.opacity(Double(i + 1) * 0.25))
                            }
                        }
                    }
                    .opacity(opacity)
                    .padding(.bottom, 52)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) {
                    opacity = 1.0
                    scale = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
