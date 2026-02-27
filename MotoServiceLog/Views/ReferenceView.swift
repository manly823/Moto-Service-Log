import SwiftUI

struct ReferenceView: View {
    @Environment(\.dismiss) var dismiss
    @State private var section = 0

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        segmentedPicker
                        switch section {
                        case 0: tirePressure
                        case 1: chainTension
                        case 2: fluidSpecs
                        default: EmptyView()
                        }
                    }.padding()
                }
            }
            .navigationTitle("Reference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    private var segmentedPicker: some View {
        HStack(spacing: 4) {
            refTab("Tires", idx: 0); refTab("Chain", idx: 1); refTab("Fluids", idx: 2)
        }.padding(4).background(Color.white.opacity(0.05)).cornerRadius(12)
    }

    private func refTab(_ label: String, idx: Int) -> some View {
        Button { withAnimation { section = idx }; haptic(.light) } label: {
            Text(label).font(.subheadline.bold()).foregroundColor(section == idx ? .white : Theme.textSecondary)
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .background(section == idx ? Theme.racing.opacity(0.3) : Color.clear).cornerRadius(10)
        }
    }

    private var tirePressure: some View {
        VStack(spacing: 12) {
            refCard(icon: "circle.circle.fill", title: "Front Tire", items: [
                "Sport: 33–36 PSI (2.3–2.5 bar)", "Touring: 36–42 PSI (2.5–2.9 bar)", "Off-road: 15–21 PSI (1.0–1.5 bar)"])
            refCard(icon: "circle.circle.fill", title: "Rear Tire", items: [
                "Sport: 36–42 PSI (2.5–2.9 bar)", "Touring: 36–42 PSI (2.5–2.9 bar)", "Off-road: 12–18 PSI (0.8–1.2 bar)"])
            refCard(icon: "exclamationmark.triangle.fill", title: "Tips", items: [
                "Always check when cold", "Don't exceed sidewall max", "Check before every ride"])
        }
    }

    private var chainTension: some View {
        VStack(spacing: 12) {
            refCard(icon: "link", title: "Slack Measurement", items: [
                "Standard: 25–35mm (1.0–1.4 in)", "Sport: 20–30mm", "Measure at tightest point", "Bike on side stand, rear wheel off ground"])
            refCard(icon: "drop.fill", title: "Lubrication", items: [
                "Every 500–1000 km", "After rain or wash", "Use chain-specific lube", "Clean with kerosene, NOT WD-40"])
            refCard(icon: "wrench.and.screwdriver.fill", title: "Replacement", items: [
                "Every 20,000–40,000 km", "Replace sprockets with chain", "Check for stiff links"])
        }
    }

    private var fluidSpecs: some View {
        VStack(spacing: 12) {
            refCard(icon: "drop.fill", title: "Engine Oil", items: [
                "Sport: 10W-40 or 10W-50 full synthetic", "Touring: 10W-40 semi-synthetic", "JASO MA2 rated for wet clutch", "Change: 5,000–10,000 km"])
            refCard(icon: "thermometer.medium", title: "Coolant", items: [
                "50/50 ethylene glycol mix", "Change every 2 years / 30,000 km", "Never mix colors"])
            refCard(icon: "stop.circle.fill", title: "Brake Fluid", items: [
                "DOT 4 (most bikes)", "Change every 2 years", "Hygroscopic — absorbs moisture", "Use from sealed container only"])
        }
    }

    private func refCard(icon: String, title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(Theme.racing)
                Text(title).font(.subheadline.bold()).foregroundColor(.white)
            }
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(Theme.textSecondary).frame(width: 4, height: 4).padding(.top, 6)
                    Text(item).font(.caption).foregroundColor(Theme.textSecondary)
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
    }
}
