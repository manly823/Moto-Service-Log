import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var manager: MotoManager
    @State private var page = 0
    var body: some View {
        ZStack {
            Theme.bgGradient.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    obPage(icon: "motorcycle.fill", title: "Moto Service Log", sub: "Ride with confidence",
                           desc: "Track every service, monitor intervals, log fuel, analyze costs. Your motorcycle maintenance co-pilot.", color: Theme.racing).tag(0)
                    obPage(icon: "gauge.with.needle.fill", title: "Service Gauges", sub: "See status at a glance",
                           desc: "Arc gauges show remaining service life for oil, tires, chain, brakes. Green means good, yellow means soon, red means overdue.", color: Theme.tach).tag(1)
                    obPage(icon: "fuelpump.fill", title: "Fuel Tracking", sub: "Know your consumption",
                           desc: "Log every fill-up, track cost per kilometer, see consumption trends with charts. Calculate average L/100km automatically.", color: Theme.accent).tag(2)
                    obPage(icon: "chart.pie.fill", title: "Cost Analysis", sub: "Where your money goes",
                           desc: "Breakdown of service costs by type, fuel expenses over time. Export all data as JSON to share or backup.", color: Theme.chrome).tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                if page == 3 {
                    Button { withAnimation { manager.settings.hasCompletedOnboarding = true } } label: {
                        Text("Start Riding").font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(Theme.racing).cornerRadius(14)
                    }.padding(.horizontal, 40).padding(.bottom, 40)
                }
            }
        }
    }
    private func obPage(icon: String, title: String, sub: String, desc: String, color: Color) -> some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 150, height: 150)
                Circle().fill(color.opacity(0.06)).frame(width: 200, height: 200)
                Image(systemName: icon).font(.system(size: 56)).foregroundColor(color)
            }
            Text(title).font(.largeTitle.bold()).foregroundColor(.white)
            Text(sub).font(.title3).foregroundColor(color)
            Text(desc).font(.body).foregroundColor(Theme.textSecondary).multilineTextAlignment(.center).padding(.horizontal, 40)
            Spacer(); Spacer()
        }
    }
}
