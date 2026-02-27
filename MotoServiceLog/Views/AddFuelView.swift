import SwiftUI

struct AddFuelView: View {
    @EnvironmentObject var manager: MotoManager
    @Environment(\.dismiss) var dismiss
    @State private var liters = ""
    @State private var pricePerL = ""
    @State private var mileage = ""
    @State private var date = Date()
    @State private var fullTank = true

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        fuelGauge
                        inputField("Liters", text: $liters, icon: "drop.fill", keyboard: .decimalPad)
                        inputField("Price per liter ($)", text: $pricePerL, icon: "dollarsign.circle", keyboard: .decimalPad)
                        inputField("Odometer (km)", text: $mileage, icon: "gauge.with.needle", keyboard: .numberPad)
                        DatePicker("Date", selection: $date, displayedComponents: .date).foregroundColor(.white).cardStyle()
                        Toggle(isOn: $fullTank) { HStack { Image(systemName: "fuelpump.circle.fill").foregroundColor(Theme.accent); Text("Full tank").foregroundColor(.white) } }.tint(Theme.accent).cardStyle()
                    }.padding()
                }
            }
            .navigationTitle("Add Fuel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let entry = FuelEntry(bikeId: manager.activeBike.id, date: date, liters: Double(liters) ?? 0,
                                              costPerLiter: Double(pricePerL) ?? 0, mileage: Int(mileage) ?? manager.activeBike.currentMileage, fullTank: fullTank)
                        manager.addFuel(entry)
                        haptic(.heavy)
                        dismiss()
                    }.foregroundColor(Theme.accent).bold()
                }
            }
        }
    }

    private var fuelGauge: some View {
        let litersVal = Double(liters) ?? 0
        let fill = min(litersVal / manager.activeBike.fuelCapacityL, 1.0)
        return VStack(spacing: 6) {
            ZStack {
                ArcGauge(progress: 1).stroke(Color.white.opacity(0.07), style: StrokeStyle(lineWidth: 8, lineCap: .round)).frame(width: 120, height: 120)
                ArcGauge(progress: fill).stroke(Theme.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round)).frame(width: 120, height: 120).animation(.easeOut, value: fill)
                VStack(spacing: 0) {
                    Text(String(format: "%.1f", litersVal)).font(.title2.bold()).foregroundColor(.white)
                    Text("/ \(String(format: "%.0f", manager.activeBike.fuelCapacityL)) L").font(.caption2).foregroundColor(Theme.textSecondary)
                }
            }
        }.frame(maxWidth: .infinity).cardStyle()
    }

    private func inputField(_ label: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(Theme.textSecondary).frame(width: 24)
            TextField(label, text: text).foregroundColor(.white).keyboardType(keyboard)
        }.cardStyle()
    }
}
