import SwiftUI

struct ServiceLogView: View {
    @EnvironmentObject var manager: MotoManager
    @Environment(\.dismiss) var dismiss
    @State private var search = ""
    @State private var showAdd = false
    @State private var filter: ServiceType?

    var filtered: [ServiceRecord] {
        var list = manager.services
        if let f = filter { list = list.filter { $0.type == f } }
        if !search.isEmpty { list = list.filter { $0.type.rawValue.localizedCaseInsensitiveContains(search) || $0.parts.localizedCaseInsensitiveContains(search) || $0.notes.localizedCaseInsensitiveContains(search) } }
        return list.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    filterBar
                    if filtered.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "wrench.and.screwdriver").font(.system(size: 40)).foregroundColor(Theme.textSecondary)
                            Text("No Records").foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filtered) { s in serviceRow(s) }
                                .onDelete { idx in idx.map { filtered[$0] }.forEach { manager.deleteService($0) } }
                                .listRowBackground(Color.clear)
                        }.listStyle(.plain).scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Service Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button { showAdd = true } label: { Image(systemName: "plus.circle.fill").foregroundColor(Theme.racing) } }
            }
            .sheet(isPresented: $showAdd) { AddServiceView().environmentObject(manager) }
        }
        .searchable(text: $search, prompt: "Search services…")
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", active: filter == nil) { filter = nil }
                ForEach(ServiceType.allCases) { t in
                    filterChip(label: t.rawValue, active: filter == t, color: t.color) { filter = t }
                }
            }.padding(.horizontal).padding(.vertical, 8)
        }
    }

    private func filterChip(label: String, active: Bool, color: Color = Theme.racing, action: @escaping () -> Void) -> some View {
        Button { haptic(.light); action() } label: {
            Text(label).font(.caption.bold()).foregroundColor(active ? .white : Theme.textSecondary)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(active ? color.opacity(0.3) : Color.white.opacity(0.05)).cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(active ? color.opacity(0.5) : Color.clear, lineWidth: 1))
        }
    }

    private func serviceRow(_ s: ServiceRecord) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(s.type.color.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: s.type.icon).foregroundColor(s.type.color).font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(s.type.rawValue).font(.subheadline.bold()).foregroundColor(.white)
                HStack(spacing: 4) {
                    Text("\(s.mileage) km").font(.caption).foregroundColor(Theme.textSecondary)
                    if !s.parts.isEmpty { Text("· \(s.parts)").font(.caption).foregroundColor(Theme.textSecondary).lineLimit(1) }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(s.date, style: .date).font(.caption2).foregroundColor(Theme.textSecondary)
                if s.cost > 0 { Text("$\(s.cost, specifier: "%.0f")").font(.caption.bold()).foregroundColor(Theme.accent) }
            }
        }.padding(.vertical, 4)
    }
}
