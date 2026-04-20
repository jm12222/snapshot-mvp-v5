import SwiftUI

// MARK: - Link History Item

struct LinkHistoryItem: Identifiable, Codable, Hashable {
    let id: UUID
    let url: String
    let title: String
    let visitDate: Date
    
    init(url: String, title: String, visitDate: Date = Date()) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.visitDate = visitDate
    }
    
    var displayURL: String {
        if let url = URL(string: url) {
            return url.host ?? url.absoluteString
        }
        return url
    }
}

// MARK: - Link History Store

@MainActor
class LinkHistoryStore: ObservableObject {
    static let shared = LinkHistoryStore()
    
    @Published private(set) var items: [LinkHistoryItem] = []
    
    private let userDefaultsKey = "linkHistoryItems"
    
    private init() {
        loadHistory()
    }
    
    func addItem(url: String, title: String) {
        let newItem = LinkHistoryItem(url: url, title: title)
        
        // Remove duplicate if same URL exists
        items.removeAll { $0.url == url }
        
        // Add new item at the beginning
        items.insert(newItem, at: 0)
        
        // Limit history to 100 items
        if items.count > 100 {
            items = Array(items.prefix(100))
        }
        
        saveHistory()
    }
    
    func removeItem(_ item: LinkHistoryItem) {
        items.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    func clearAll() {
        items.removeAll()
        saveHistory()
    }
    
    // Group items by date
    func groupedByDate() -> [(date: Date, items: [LinkHistoryItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { item in
            calendar.startOfDay(for: item.visitDate)
        }
        
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, items: $0.value.sorted { $0.visitDate > $1.visitDate }) }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([LinkHistoryItem].self, from: data) {
            items = decoded
        }
    }
}

// MARK: - Link History View

struct LinkHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var historyStore = LinkHistoryStore.shared
    @State private var showClearAlert = false
    @AppStorage("linkHistoryEnabled") private var isLinkHistoryEnabled = true
    
    var onLinkTapped: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "History",
                backAction: { dismiss() },
                icon1: {
                    if !historyStore.items.isEmpty {
                        Button("Clear") {
                            showClearAlert = true
                        }
                        .body2LinkTypography()
                        .foregroundStyle(Color("blueLink"))
                    }
                }
            )
            
            if !isLinkHistoryEnabled {
                disabledState
            } else if historyStore.items.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .background(Color("surfaceBackground"))
        .hideFDSTabBar(true)
        .alert("Clear all history?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                historyStore.clearAll()
            }
        } message: {
            Text("This will remove all browsing history.")
        }
    }
    
    // MARK: - Disabled State
    
    private var disabledState: some View {
        VStack(spacing: 16) {
            Image("on-this-day-outline")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(Color("secondaryIcon"))
            
            Text("Link history is off")
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
            
            Text("Turn on link history to see a list of links you visit in the browser.")
                .body3Typography()
                .foregroundStyle(Color("secondaryText"))
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Navigate to settings
                dismiss()
            }) {
                Text("Go to browser settings")
                    .body2LinkTypography()
                    .foregroundStyle(Color("blueLink"))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image("globe-americas-outline")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color("secondaryIcon"))
            
            Text("No browsing history")
                .headline2EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
            
            Text("Links you visit will appear here")
                .body2Typography()
                .foregroundStyle(Color("secondaryText"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    // MARK: - History List
    
    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(historyStore.groupedByDate(), id: \.date) { group in
                    FDSUnitHeader(headlineText: formatDate(group.date))
                    
                    ForEach(group.items) { item in
                        FDSListCell(
                            headlineText: item.title,
                            bodyText: item.displayURL,
                            leftAddOn: .asyncProfilePhoto(
                                urlString: item.url,
                                type: .nonActor,
                                size: .size40,
                                placeholderIcon: "globe-americas-filled"
                            ),
                            rightAddOn: .chevron,
                            action: {
                                onLinkTapped?(item.url)
                            }
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                historyStore.removeItem(item)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Date Formatting
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LinkHistoryView { url in
            print("Tapped: \(url)")
        }
    }
    .environmentObject(FDSTabBarHelper())
}

