import SwiftUI

enum ServiceType: String, Codable, CaseIterable, Identifiable, Hashable {
    case oilChange = "Oil Change"
    case oilFilter = "Oil Filter"
    case airFilter = "Air Filter"
    case sparkPlugs = "Spark Plugs"
    case chain = "Chain & Sprockets"
    case tires = "Tires"
    case brakes = "Brake Pads"
    case coolant = "Coolant"
    case battery = "Battery"
    case general = "General"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .oilChange: return "drop.fill"
        case .oilFilter: return "line.3.horizontal.decrease.circle.fill"
        case .airFilter: return "wind"
        case .sparkPlugs: return "bolt.fill"
        case .chain: return "link"
        case .tires: return "circle.circle.fill"
        case .brakes: return "stop.circle.fill"
        case .coolant: return "thermometer.medium"
        case .battery: return "battery.75percent"
        case .general: return "wrench.and.screwdriver.fill"
        }
    }
    var color: Color {
        switch self {
        case .oilChange: return Color(red: 0.85, green: 0.65, blue: 0.1)
        case .oilFilter: return .orange
        case .airFilter: return .cyan
        case .sparkPlugs: return .yellow
        case .chain: return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .tires: return Color(red: 0.5, green: 0.5, blue: 0.55)
        case .brakes: return Color(red: 0.9, green: 0.2, blue: 0.15)
        case .coolant: return Color(red: 0.2, green: 0.7, blue: 0.9)
        case .battery: return Color(red: 0.3, green: 0.85, blue: 0.3)
        case .general: return Color(red: 0.6, green: 0.6, blue: 0.65)
        }
    }
    var defaultIntervalKm: Int {
        switch self {
        case .oilChange: return 6000; case .oilFilter: return 12000; case .airFilter: return 20000
        case .sparkPlugs: return 20000; case .chain: return 25000; case .tires: return 15000
        case .brakes: return 20000; case .coolant: return 30000; case .battery: return 40000
        case .general: return 10000
        }
    }
}

enum Urgency: String, Codable {
    case good = "Good"
    case soon = "Due Soon"
    case overdue = "Overdue"
    case unknown = "No Data"
    var color: Color {
        switch self {
        case .good: return Color(red: 0.2, green: 0.85, blue: 0.3)
        case .soon: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .overdue: return Color(red: 0.9, green: 0.2, blue: 0.15)
        case .unknown: return Color(red: 0.5, green: 0.5, blue: 0.55)
        }
    }
}

struct Bike: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String = ""
    var make: String = ""
    var model: String = ""
    var year: Int = 2024
    var currentMileage: Int = 0
    var fuelCapacityL: Double = 15
}

struct ServiceRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    var bikeId: UUID
    var type: ServiceType = .general
    var date: Date = Date()
    var mileage: Int = 0
    var cost: Double = 0
    var parts: String = ""
    var notes: String = ""
}

struct ServiceInterval: Identifiable, Codable, Hashable {
    var id = UUID()
    var type: ServiceType
    var intervalKm: Int
}

struct FuelEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var bikeId: UUID
    var date: Date = Date()
    var liters: Double = 0
    var costPerLiter: Double = 0
    var mileage: Int = 0
    var fullTank: Bool = true
    var totalCost: Double { liters * costPerLiter }
}

enum DistanceUnit: String, Codable, CaseIterable { case km = "km"; case miles = "mi" }
enum FuelUnit: String, Codable, CaseIterable { case liters = "L"; case gallons = "gal" }

struct MotoSettings: Codable {
    var hasCompletedOnboarding: Bool = false
    var distanceUnit: DistanceUnit = .km
    var fuelUnit: FuelUnit = .liters
}
