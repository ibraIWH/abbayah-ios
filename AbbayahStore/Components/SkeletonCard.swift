import SwiftUI

struct SkeletonCard: View {
    @State private var animate = false
    private let borderColor = Color(hex: "E8E8E4")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color(hex: "EDE8E0")
                LinearGradient(
                    colors: [Color.clear, Color.white.opacity(0.5), Color.clear],
                    startPoint: animate ? .leading : .trailing,
                    endPoint: animate ? .trailing : .leading
                )
            }
            .frame(height: 200)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 2).fill(borderColor).frame(height: 8).frame(width: 50)
                RoundedRectangle(cornerRadius: 2).fill(borderColor).frame(height: 10).frame(maxWidth: .infinity)
                RoundedRectangle(cornerRadius: 2).fill(borderColor).frame(height: 8).frame(width: 70)
            }
            .padding(10)
            .background(Color.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) { animate = true }
        }
    }
}
