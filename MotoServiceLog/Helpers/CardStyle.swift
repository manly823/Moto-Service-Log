import SwiftUI

struct CardStyle: ViewModifier {
    var opacity: Double = 0.08
    func body(content: Content) -> some View {
        content.padding()
            .background(Color.white.opacity(opacity))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
extension View {
    func cardStyle(opacity: Double = 0.08) -> some View { modifier(CardStyle(opacity: opacity)) }
}

// MARK: - Theme

struct Theme {
    static let bg = Color(red: 0.09, green: 0.09, blue: 0.11)
    static let surface = Color(red: 0.14, green: 0.14, blue: 0.17)
    static let racing = Color(red: 0.9, green: 0.15, blue: 0.1)
    static let accent = Color(red: 1.0, green: 0.45, blue: 0.0)
    static let tach = Color(red: 0.2, green: 0.85, blue: 0.3)
    static let warn = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let chrome = Color(red: 0.75, green: 0.78, blue: 0.82)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.55, green: 0.58, blue: 0.65)
    static var bgGradient: LinearGradient {
        LinearGradient(colors: [bg, Color(red: 0.06, green: 0.06, blue: 0.08)], startPoint: .top, endPoint: .bottom)
    }
}

func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

// MARK: - Arc Gauge Shape (Custom Shape — new quality feature)

struct ArcGauge: Shape {
    var progress: Double
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    func path(in rect: CGRect) -> Path {
        let startAngle: Double = 135
        let totalSweep: Double = 270
        let endAngle = startAngle + totalSweep * min(max(progress, 0), 1)
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                     radius: min(rect.width, rect.height) / 2 - 4,
                     startAngle: .degrees(startAngle),
                     endAngle: .degrees(endAngle),
                     clockwise: false)
        return path
    }
}

struct ArcGaugeView: View {
    let value: Double
    let label: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                ArcGauge(progress: 1)
                    .stroke(Color.white.opacity(0.07), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 70, height: 70)
                ArcGauge(progress: value)
                    .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 70, height: 70)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            }
            Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(.white).lineLimit(1)
            Text(subtitle).font(.system(size: 8)).foregroundColor(Theme.textSecondary).lineLimit(1)
        }.frame(width: 90)
    }
}
