import SwiftUI
import Charts

struct CostStatsView: View {
    @EnvironmentObject var manager: MotoManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        totalCard
                        pieBreakdown
                        monthlyTrend
                    }.padding()
                }
            }
            .navigationTitle("Cost Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    private var totalCard: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("Service").font(.caption2).foregroundColor(Theme.textSecondary)
                Text(String(format: "$%.0f", manager.totalServiceCost)).font(.title3.bold()).foregroundColor(Theme.racing)
            }.frame(maxWidth: .infinity)
            Divider().frame(height: 40).background(Color.white.opacity(0.1))
            VStack(spacing: 4) {
                Text("Fuel").font(.caption2).foregroundColor(Theme.textSecondary)
                Text(String(format: "$%.0f", manager.totalFuelCost)).font(.title3.bold()).foregroundColor(Theme.accent)
            }.frame(maxWidth: .infinity)
            Divider().frame(height: 40).background(Color.white.opacity(0.1))
            VStack(spacing: 4) {
                Text("Total").font(.caption2).foregroundColor(Theme.textSecondary)
                Text(String(format: "$%.0f", manager.totalCost)).font(.title3.bold()).foregroundColor(.white)
            }.frame(maxWidth: .infinity)
        }.cardStyle()
    }

    private var pieBreakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("By Service Type").font(.subheadline.bold()).foregroundColor(.white)
            let items = manager.costByType()
            if items.isEmpty {
                Text("No data").foregroundColor(Theme.textSecondary)
            } else {
                Chart(items, id: \.type) { item in
                    SectorMark(angle: .value("Cost", item.cost), innerRadius: .ratio(0.5), angularInset: 2)
                        .foregroundStyle(item.type.color)
                        .cornerRadius(4)
                }
                .frame(height: 200)
                ForEach(items, id: \.type) { item in
                    HStack(spacing: 8) {
                        Circle().fill(item.type.color).frame(width: 10, height: 10)
                        Text(item.type.rawValue).font(.caption).foregroundColor(.white)
                        Spacer()
                        Text(String(format: "$%.0f", item.cost)).font(.caption.bold()).foregroundColor(Theme.textSecondary)
                    }
                }
            }
        }.cardStyle()
    }

    private var monthlyTrend: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Spending").font(.subheadline.bold()).foregroundColor(.white)
            let monthlyData = monthlyBreakdown()
            if monthlyData.isEmpty {
                Text("No data").foregroundColor(Theme.textSecondary)
            } else {
                Chart(monthlyData, id: \.month) { item in
                    BarMark(x: .value("Month", item.month, unit: .month), y: .value("Service", item.serviceCost))
                        .foregroundStyle(Theme.racing.gradient).cornerRadius(4)
                    BarMark(x: .value("Month", item.month, unit: .month), y: .value("Fuel", item.fuelCost))
                        .foregroundStyle(Theme.accent.gradient).cornerRadius(4)
                }
                .chartXAxis { AxisMarks(values: .automatic) { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
                .chartYAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary); AxisGridLine().foregroundStyle(Color.white.opacity(0.05)) } }
                .frame(height: 160)
                HStack(spacing: 16) {
                    HStack(spacing: 4) { Circle().fill(Theme.racing).frame(width: 8, height: 8); Text("Service").font(.caption2).foregroundColor(Theme.textSecondary) }
                    HStack(spacing: 4) { Circle().fill(Theme.accent).frame(width: 8, height: 8); Text("Fuel").font(.caption2).foregroundColor(Theme.textSecondary) }
                }
            }
        }.cardStyle()
    }

    private func monthlyBreakdown() -> [(month: Date, serviceCost: Double, fuelCost: Double)] {
        let cal = Calendar.current
        var map: [Date: (s: Double, f: Double)] = [:]
        for s in manager.services {
            let m = cal.date(from: cal.dateComponents([.year, .month], from: s.date))!
            map[m, default: (0, 0)].s += s.cost
        }
        for f in manager.fuelLog {
            let m = cal.date(from: cal.dateComponents([.year, .month], from: f.date))!
            map[m, default: (0, 0)].f += f.totalCost
        }
        return map.map { (month: $0.key, serviceCost: $0.value.s, fuelCost: $0.value.f) }.sorted { $0.month < $1.month }
    }
}
