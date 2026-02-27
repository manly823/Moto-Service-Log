import SwiftUI

struct AddServiceView: View {
    @EnvironmentObject var manager: MotoManager
    @Environment(\.dismiss) var dismiss
    @State private var type: ServiceType = .oilChange
    @State private var date = Date()
    @State private var mileage = ""
    @State private var cost = ""
    @State private var parts = ""
    @State private var notes = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // Type picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SERVICE TYPE").font(.caption.bold()).foregroundColor(Theme.textSecondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(ServiceType.allCases) { t in
                                        Button { type = t } label: {
                                            VStack(spacing: 4) {
                                                Image(systemName: t.icon).font(.title3)
                                                Text(t.rawValue).font(.system(size: 8))
                                            }
                                            .foregroundColor(type == t ? .white : Theme.textSecondary)
                                            .frame(width: 64, height: 56)
                                            .background(type == t ? t.color.opacity(0.3) : Color.white.opacity(0.05))
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(type == t ? t.color : Color.clear, lineWidth: 1))
                                        }
                                    }
                                }
                            }
                        }.cardStyle()

                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .foregroundColor(.white).cardStyle()

                        inputField("Mileage (km)", text: $mileage, icon: "gauge.with.needle", keyboard: .numberPad)
                        inputField("Cost ($)", text: $cost, icon: "dollarsign.circle", keyboard: .decimalPad)
                        inputField("Parts Used", text: $parts, icon: "shippingbox")
                        inputField("Notes", text: $notes, icon: "note.text")
                    }.padding()
                }
            }
            .navigationTitle("Add Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let rec = ServiceRecord(bikeId: manager.activeBike.id, type: type, date: date,
                                                mileage: Int(mileage) ?? manager.activeBike.currentMileage,
                                                cost: Double(cost) ?? 0, parts: parts, notes: notes)
                        manager.addService(rec)
                        haptic(.heavy)
                        dismiss()
                    }.foregroundColor(Theme.racing).bold()
                }
            }
        }
    }

    private func inputField(_ label: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(Theme.textSecondary).frame(width: 24)
            TextField(label, text: text).foregroundColor(.white).keyboardType(keyboard)
        }.cardStyle()
    }
}
