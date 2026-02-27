import SwiftUI
import Charts

struct FuelLogView: View {
    @EnvironmentObject var manager: MotoManager
    @Environment(\.dismiss) var dismiss
    @State private var showAdd = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        statsHeader
                        consumptionChart
                        fuelList
                    }.padding()
                }
            }
            .navigationTitle("Fuel Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button { showAdd = true } label: { Image(systemName: "plus.circle.fill").foregroundColor(Theme.accent) } }
            }
            .sheet(isPresented: $showAdd) { AddFuelView().environmentObject(manager) }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 0) {
            statCell("Avg", value: String(format: "%.1f", manager.avgConsumption), unit: "L/100km", color: Theme.accent)
            Divider().frame(height: 40).background(Color.white.opacity(0.1))
            statCell("Entries", value: "\(manager.fuelLog.count)", unit: "fill-ups", color: Theme.tach)
            Divider().frame(height: 40).background(Color.white.opacity(0.1))
            statCell("Total", value: String(format: "%.0f", manager.totalFuelCost), unit: "$", color: Theme.racing)
        }.cardStyle()
    }

    private func statCell(_ label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.caption2).foregroundColor(Theme.textSecondary)
            Text(value).font(.title3.bold()).foregroundColor(color)
            Text(unit).font(.caption2).foregroundColor(Theme.textSecondary)
        }.frame(maxWidth: .infinity)
    }

    private var consumptionChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cost per Fill-up").font(.subheadline.bold()).foregroundColor(.white)
            let sorted = manager.fuelLog.sorted { $0.date < $1.date }
            Chart(sorted) { entry in
                BarMark(x: .value("Date", entry.date, unit: .day), y: .value("Cost", entry.totalCost))
                    .foregroundStyle(Theme.accent.gradient)
                    .cornerRadius(4)
            }
            .chartXAxis { AxisMarks(values: .automatic) { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
            .chartYAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary); AxisGridLine().foregroundStyle(Color.white.opacity(0.05)) } }
            .frame(height: 160)
        }.cardStyle()
    }

    private var fuelList: some View {
        VStack(spacing: 10) {
            HStack { Text("History").font(.subheadline.bold()).foregroundColor(.white); Spacer() }
            ForEach(manager.fuelLog.sorted { $0.date > $1.date }) { f in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Theme.accent.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: "fuelpump.fill").foregroundColor(Theme.accent)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f L", f.liters)).font(.subheadline.bold()).foregroundColor(.white)
                        Text("\(f.mileage) km").font(.caption).foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "$%.2f", f.totalCost)).font(.caption.bold()).foregroundColor(Theme.accent)
                        Text(f.date, style: .date).font(.caption2).foregroundColor(Theme.textSecondary)
                    }
                }.cardStyle(opacity: 0.05)
            }
        }
    }
}
