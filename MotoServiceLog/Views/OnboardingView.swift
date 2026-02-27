import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var manager: MotoManager
    @State private var page = 0
    @State private var bikeName = ""
    @State private var bikeMake = ""
    @State private var bikeModel = ""
    @State private var bikeYear = ""
    @State private var bikeMileage = ""
    @State private var bikeFuelCap = ""

    private var canFinish: Bool {
        !bikeName.trimmingCharacters(in: .whitespaces).isEmpty
    }

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
                    bikeSetupPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                if page == 4 {
                    Button {
                        let bike = Bike(
                            name: bikeName.trimmingCharacters(in: .whitespaces),
                            make: bikeMake.trimmingCharacters(in: .whitespaces),
                            model: bikeModel.trimmingCharacters(in: .whitespaces),
                            year: Int(bikeYear) ?? Calendar.current.component(.year, from: Date()),
                            currentMileage: Int(bikeMileage) ?? 0,
                            fuelCapacityL: Double(bikeFuelCap) ?? 15
                        )
                        manager.setupBike(bike)
                        haptic(.heavy)
                        withAnimation { manager.settings.hasCompletedOnboarding = true }
                    } label: {
                        Text("Start Riding").font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(canFinish ? Theme.racing : Theme.racing.opacity(0.3)).cornerRadius(14)
                    }
                    .disabled(!canFinish)
                    .padding(.horizontal, 40).padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Bike Setup Page
    private var bikeSetupPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 30)
                ZStack {
                    Circle().fill(Theme.racing.opacity(0.12)).frame(width: 120, height: 120)
                    Image(systemName: "motorcycle.fill").font(.system(size: 44)).foregroundColor(Theme.racing)
                }
                Text("Your Motorcycle").font(.title.bold()).foregroundColor(.white)
                Text("Tell us about your bike").font(.subheadline).foregroundColor(Theme.textSecondary)

                VStack(spacing: 12) {
                    onboardField("Bike Name *", text: $bikeName, icon: "pencil", placeholder: "e.g. My Ducati")
                    onboardField("Make", text: $bikeMake, icon: "building.2", placeholder: "e.g. Ducati")
                    onboardField("Model", text: $bikeModel, icon: "tag", placeholder: "e.g. Monster 821")
                    onboardField("Year", text: $bikeYear, icon: "calendar", placeholder: "e.g. 2023", keyboard: .numberPad)
                    onboardField("Current Mileage (km)", text: $bikeMileage, icon: "gauge.with.needle", placeholder: "e.g. 5000", keyboard: .numberPad)
                    onboardField("Fuel Tank (liters)", text: $bikeFuelCap, icon: "fuelpump", placeholder: "e.g. 15", keyboard: .decimalPad)
                }.padding(.horizontal, 24)

                Spacer().frame(height: 80)
            }
        }
    }

    private func onboardField(_ label: String, text: Binding<String>, icon: String, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.bold()).foregroundColor(Theme.textSecondary)
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundColor(Theme.racing).frame(width: 24)
                TextField(placeholder, text: text).foregroundColor(.white).keyboardType(keyboard)
            }
            .padding().background(Color.white.opacity(0.08)).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 1))
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
