import SwiftUI

struct MainView: View {
    @EnvironmentObject var manager: MotoManager
    @State private var activeSheet: Dest?

    enum Dest: String, Identifiable {
        case serviceLog, addService, fuelLog, addFuel, costStats, reference, settings
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            Theme.bgGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    bikeHeader
                    gaugesGrid
                    upcomingSection
                    actionButtons
                }.padding()
            }
        }
        .sheet(item: $activeSheet) { d in sheetFor(d) }
    }

    // MARK: - Bike Header (odometer style)
    private var bikeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Moto Service Log").font(.caption).foregroundColor(Theme.textSecondary)
                Text("\(manager.activeBike.year) \(manager.activeBike.make) \(manager.activeBike.model)")
                    .font(.title3.bold()).foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                odometerDisplay
                Text(manager.settings.distanceUnit.rawValue).font(.caption2).foregroundColor(Theme.textSecondary)
            }
            Button { activeSheet = .settings } label: {
                Image(systemName: "gearshape.fill").font(.title3).foregroundColor(Theme.chrome)
            }.padding(.leading, 8)
        }
    }

    private var odometerDisplay: some View {
        let digits = String(format: "%06d", manager.activeBike.currentMileage)
        return HStack(spacing: 2) {
            ForEach(Array(digits.enumerated()), id: \.offset) { _, ch in
                Text(String(ch)).font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white).frame(width: 18, height: 26)
                    .background(Color.white.opacity(0.08)).cornerRadius(4)
            }
        }
    }

    // MARK: - Arc Gauges Grid (2x3 — NOT circles)
    private var gaugesGrid: some View {
        let types: [ServiceType] = [.oilChange, .tires, .chain, .brakes, .sparkPlugs, .coolant]
        return VStack(spacing: 6) {
            HStack { Text("Service Status").font(.headline).foregroundColor(.white); Spacer() }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(types) { type in
                    gaugeCell(type)
                }
            }
        }.cardStyle()
    }

    private func gaugeCell(_ type: ServiceType) -> some View {
        let progress = manager.gaugeProgress(for: type)
        let urg = manager.urgency(for: type)
        let kmLeft = manager.kmUntilService(for: type)
        let sub = kmLeft.map { $0 > 0 ? "\($0) km" : "OVERDUE" } ?? "—"
        return ArcGaugeView(value: progress, label: type.rawValue, icon: type.icon, color: urg.color, subtitle: sub)
    }

    // MARK: - Upcoming Tasks (horizontal scroll)
    private var upcomingSection: some View {
        let upcoming = ServiceType.allCases.compactMap { type -> (ServiceType, Int)? in
            guard let km = manager.kmUntilService(for: type), km <= manager.intervalKm(for: type) / 3 else { return nil }
            return (type, km)
        }.sorted { $0.1 < $1.1 }

        return VStack(spacing: 8) {
            HStack { Text("Upcoming").font(.headline).foregroundColor(.white); Spacer()
                Text("\(upcoming.count)").font(.caption).padding(.horizontal, 8).padding(.vertical, 2)
                    .background(upcoming.isEmpty ? Theme.tach.opacity(0.2) : Theme.racing.opacity(0.2)).cornerRadius(8)
                    .foregroundColor(upcoming.isEmpty ? Theme.tach : Theme.racing) }
            if upcoming.isEmpty {
                HStack { Image(systemName: "checkmark.seal.fill").foregroundColor(Theme.tach); Text("All services up to date").foregroundColor(Theme.textSecondary); Spacer() }
                    .cardStyle()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(upcoming, id: \.0) { item in taskCard(item.0, kmLeft: item.1) }
                    }
                }
            }
        }
    }

    private func taskCard(_ type: ServiceType, kmLeft: Int) -> some View {
        let urg = manager.urgency(for: type)
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: type.icon).foregroundColor(urg.color)
                Text(type.rawValue).font(.caption.bold()).foregroundColor(.white)
            }
            Text(kmLeft <= 0 ? "OVERDUE" : "in \(kmLeft) km").font(.caption2).foregroundColor(urg.color)
        }
        .padding(12).frame(width: 140)
        .background(urg.color.opacity(0.1)).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(urg.color.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Action Buttons (metal dashboard style — NOT circles)
    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                dashBtn(icon: "wrench.and.screwdriver.fill", label: "Service Log", color: Theme.racing) { activeSheet = .serviceLog }
                dashBtn(icon: "fuelpump.fill", label: "Fuel Log", color: Theme.accent) { activeSheet = .fuelLog }
            }
            HStack(spacing: 10) {
                dashBtn(icon: "chart.pie.fill", label: "Cost Stats", color: Theme.chrome) { activeSheet = .costStats }
                dashBtn(icon: "book.fill", label: "Reference", color: Theme.textSecondary) { activeSheet = .reference }
            }
        }
    }

    private func dashBtn(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button { haptic(); action() } label: {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.title3)
                Text(label).font(.subheadline.bold())
                Spacer()
                Image(systemName: "chevron.right").font(.caption)
            }
            .foregroundColor(.white).padding()
            .background(
                LinearGradient(colors: [color.opacity(0.25), color.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.3), lineWidth: 1))
        }
    }

    @ViewBuilder
    private func sheetFor(_ d: Dest) -> some View {
        switch d {
        case .serviceLog: ServiceLogView().environmentObject(manager)
        case .addService: AddServiceView().environmentObject(manager)
        case .fuelLog: FuelLogView().environmentObject(manager)
        case .addFuel: AddFuelView().environmentObject(manager)
        case .costStats: CostStatsView().environmentObject(manager)
        case .reference: ReferenceView()
        case .settings: SettingsView().environmentObject(manager)
        }
    }
}
