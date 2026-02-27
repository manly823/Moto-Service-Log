import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: MotoManager
    @Environment(\.dismiss) var dismiss
    @State private var bikeName: String = ""
    @State private var bikeMake: String = ""
    @State private var bikeModel: String = ""
    @State private var bikeYear: String = ""
    @State private var mileage: String = ""
    @State private var fuelCap: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        bikeSection
                        unitsSection
                        intervalsSection
                        exportSection
                        resetSection
                    }.padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Done") { saveProfile(); dismiss() } } }
            .onAppear {
                let b = manager.activeBike
                bikeName = b.name; bikeMake = b.make; bikeModel = b.model
                bikeYear = "\(b.year)"; mileage = "\(b.currentMileage)"; fuelCap = String(format: "%.1f", b.fuelCapacityL)
            }
        }
    }

    private var bikeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Motorcycle Profile", icon: "motorcycle.fill")
            profileField("Name", text: $bikeName)
            profileField("Make", text: $bikeMake)
            profileField("Model", text: $bikeModel)
            profileField("Year", text: $bikeYear, keyboard: .numberPad)
            profileField("Mileage (km)", text: $mileage, keyboard: .numberPad)
            profileField("Fuel Capacity (L)", text: $fuelCap, keyboard: .decimalPad)
        }.cardStyle()
    }

    private var unitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Units", icon: "ruler")
            Picker("Distance", selection: $manager.settings.distanceUnit) {
                ForEach(DistanceUnit.allCases, id: \.self) { Text($0.rawValue) }
            }.pickerStyle(.segmented)
            Picker("Fuel", selection: $manager.settings.fuelUnit) {
                ForEach(FuelUnit.allCases, id: \.self) { Text($0.rawValue) }
            }.pickerStyle(.segmented)
        }.cardStyle()
    }

    private var intervalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Service Intervals", icon: "clock.arrow.circlepath")
            ForEach($manager.intervals) { $interval in
                HStack {
                    Image(systemName: interval.type.icon).foregroundColor(interval.type.color).frame(width: 24)
                    Text(interval.type.rawValue).font(.caption).foregroundColor(.white)
                    Spacer()
                    TextField("km", value: $interval.intervalKm, format: .number)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        .foregroundColor(Theme.accent).frame(width: 80)
                    Text("km").font(.caption2).foregroundColor(Theme.textSecondary)
                }
            }
        }.cardStyle()
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Data", icon: "square.and.arrow.up")
            ShareLink(item: manager.exportJSON()) {
                HStack {
                    Image(systemName: "doc.text").foregroundColor(Theme.tach)
                    Text("Export All Data (JSON)").font(.subheadline).foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(Theme.textSecondary)
                }
            }
        }.cardStyle()
    }

    private var resetSection: some View {
        Button {
            manager.settings.hasCompletedOnboarding = false
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise").foregroundColor(Theme.racing)
                Text("Show Onboarding Again").font(.subheadline).foregroundColor(Theme.racing)
                Spacer()
            }
        }.cardStyle()
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(Theme.racing)
            Text(title).font(.subheadline.bold()).foregroundColor(.white)
        }
    }

    private func profileField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack {
            Text(label).font(.caption).foregroundColor(Theme.textSecondary).frame(width: 100, alignment: .leading)
            TextField(label, text: text).foregroundColor(.white).keyboardType(keyboard)
        }
    }

    private func saveProfile() {
        guard var b = manager.bikes.first else { return }
        b.name = bikeName; b.make = bikeMake; b.model = bikeModel
        b.year = Int(bikeYear) ?? b.year; b.currentMileage = Int(mileage) ?? b.currentMileage
        b.fuelCapacityL = Double(fuelCap) ?? b.fuelCapacityL
        manager.bikes = [b]
    }
}
