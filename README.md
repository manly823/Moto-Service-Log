# Moto Service Log

Motorcycle maintenance tracker with arc-gauge dashboard, fuel logging, cost analytics, and reference guide.

## Features

- **Arc Gauge Dashboard** — 2×3 grid of animated arc gauges showing remaining service life for oil, tires, chain, brakes, spark plugs, coolant. Color-coded: green (good) → yellow (due soon) → red (overdue)
- **Odometer Display** — digital odometer readout styled like a real motorcycle instrument cluster
- **Service Log** — full history of maintenance records with search (`.searchable`) and filter chips by service type
- **Fuel Tracking** — log every fill-up, automatic L/100km calculation, cost-per-fill charts (Swift Charts `BarMark`)
- **Cost Analytics** — pie chart breakdown by service type (`SectorMark`), monthly spending trend with stacked bars for service vs fuel
- **Reference Guide** — tire pressure tables, chain tension specs, fluid recommendations with segmented tab switcher
- **Data Export** — `ShareLink` to export all bikes, services, and fuel data as JSON
- **Customizable Intervals** — set service intervals per type (km), see what's due on dashboard
- **Bike Profile** — name, make, model, year, mileage, fuel capacity
- **Onboarding** — 4-page intro with animated icons

## Tech Stack

- SwiftUI (iOS 17+)
- Swift Charts (BarMark, SectorMark)
- Custom Shape (`ArcGauge` — 270° animated arc)
- ShareLink (JSON export)
- .searchable modifier
- UserDefaults persistence via Storage helper
- MVVM architecture
- Haptic feedback

## Structure

```
MotoServiceLog/
├── MotoServiceLogApp.swift
├── Models/
│   └── MotoModels.swift          # Bike, ServiceRecord, FuelEntry, enums
├── Helpers/
│   ├── CardStyle.swift           # Theme, ArcGauge Shape, haptics
│   └── Storage.swift             # UserDefaults persistence
├── ViewModels/
│   └── MotoManager.swift         # CRUD, urgency calc, fuel stats, export
└── Views/
    ├── OnboardingView.swift      # 4-page intro
    ├── MainView.swift            # Dashboard with arc gauges + odometer
    ├── ServiceLogView.swift      # Service history with search + filters
    ├── AddServiceView.swift      # Add service record form
    ├── FuelLogView.swift         # Fuel log with charts
    ├── AddFuelView.swift         # Add fuel entry with gauge preview
    ├── CostStatsView.swift       # Cost breakdown + monthly trend
    ├── ReferenceView.swift       # Tire, chain, fluid specs
    └── SettingsView.swift        # Profile, intervals, units, export
```

## Build

```bash
xcodebuild -project MotoServiceLog.xcodeproj -scheme MotoServiceLog \
  -destination 'generic/platform=iOS Simulator' -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO build
```

## License

MIT
