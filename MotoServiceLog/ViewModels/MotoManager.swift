import SwiftUI

@MainActor
final class MotoManager: ObservableObject {
    @Published var bikes: [Bike] { didSet { Storage.shared.save(bikes, forKey: "bikes") } }
    @Published var services: [ServiceRecord] { didSet { Storage.shared.save(services, forKey: "services") } }
    @Published var intervals: [ServiceInterval] { didSet { Storage.shared.save(intervals, forKey: "intervals") } }
    @Published var fuelLog: [FuelEntry] { didSet { Storage.shared.save(fuelLog, forKey: "fuel") } }
    @Published var settings: MotoSettings { didSet { Storage.shared.save(settings, forKey: "settings") } }

    var activeBike: Bike { bikes.first ?? Bike(name: "My Bike") }

    init() {
        self.bikes = Storage.shared.load(forKey: "bikes", default: [])
        self.services = Storage.shared.load(forKey: "services", default: [])
        self.intervals = Storage.shared.load(forKey: "intervals", default: [])
        self.fuelLog = Storage.shared.load(forKey: "fuel", default: [])
        self.settings = Storage.shared.load(forKey: "settings", default: MotoSettings())
        if intervals.isEmpty { intervals = ServiceType.allCases.map { ServiceInterval(type: $0, intervalKm: $0.defaultIntervalKm) } }
    }

    func setupBike(_ bike: Bike) {
        bikes = [bike]
        services = []
        fuelLog = []
    }

    // MARK: - CRUD
    func addService(_ s: ServiceRecord) { services.insert(s, at: 0) }
    func deleteService(_ s: ServiceRecord) { services.removeAll { $0.id == s.id } }
    func addFuel(_ f: FuelEntry) { fuelLog.insert(f, at: 0) }
    func deleteFuel(_ f: FuelEntry) { fuelLog.removeAll { $0.id == f.id } }

    func updateMileage(_ km: Int) {
        guard var b = bikes.first else { return }
        b.currentMileage = km
        bikes = [b]
    }

    // MARK: - Service Status
    func lastService(for type: ServiceType) -> ServiceRecord? {
        services.filter { $0.type == type }.sorted { $0.mileage > $1.mileage }.first
    }

    func intervalKm(for type: ServiceType) -> Int {
        intervals.first { $0.type == type }?.intervalKm ?? type.defaultIntervalKm
    }

    func kmUntilService(for type: ServiceType) -> Int? {
        guard let last = lastService(for: type) else { return nil }
        let next = last.mileage + intervalKm(for: type)
        return next - activeBike.currentMileage
    }

    func urgency(for type: ServiceType) -> Urgency {
        guard let kmLeft = kmUntilService(for: type) else { return .unknown }
        if kmLeft <= 0 { return .overdue }
        if kmLeft <= intervalKm(for: type) / 5 { return .soon }
        return .good
    }

    func gaugeProgress(for type: ServiceType) -> Double {
        guard let last = lastService(for: type) else { return 0 }
        let interval = Double(intervalKm(for: type))
        let used = Double(activeBike.currentMileage - last.mileage)
        return min(max(1 - used / interval, 0), 1)
    }

    // MARK: - Fuel Stats
    var avgConsumption: Double {
        let full = fuelLog.filter { $0.fullTank }.sorted { $0.mileage < $1.mileage }
        guard full.count >= 2 else { return 0 }
        let totalL = full.dropFirst().reduce(0.0) { $0 + $1.liters }
        let totalKm = Double(full.last!.mileage - full.first!.mileage)
        guard totalKm > 0 else { return 0 }
        return totalL / totalKm * 100
    }

    var totalFuelCost: Double { fuelLog.reduce(0) { $0 + $1.totalCost } }
    var totalServiceCost: Double { services.reduce(0) { $0 + $1.cost } }
    var totalCost: Double { totalFuelCost + totalServiceCost }

    func costByType() -> [(type: ServiceType, cost: Double)] {
        var map: [ServiceType: Double] = [:]
        for s in services { map[s.type, default: 0] += s.cost }
        return map.map { ($0.key, $0.value) }.sorted { $0.cost > $1.cost }
    }

    // MARK: - Export
    func exportJSON() -> String {
        struct Export: Codable { let bikes: [Bike]; let services: [ServiceRecord]; let fuel: [FuelEntry] }
        let export = Export(bikes: bikes, services: services, fuel: fuelLog)
        guard let data = try? JSONEncoder().encode(export), let str = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }

}
