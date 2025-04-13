import SwiftUI
import Foundation

enum ViewMode: String, CaseIterable {
    case monthRows = "month-rows"
    case monthsGrid = "months-grid"
}

struct ViewModeSwitcher: View {
    @Binding var selectedMode: ViewMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                }) {
                    Image(systemName: imageForMode(mode))
                        .foregroundColor(selectedMode == mode ? .accentColor : .primary)
                }
                .frame(width: 40, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selectedMode == mode ? Color.accentColor.opacity(0.1) : Color.clear)
                )
                .contentShape(Rectangle())
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func imageForMode(_ mode: ViewMode) -> String {
        switch mode {
        case .monthRows:
            return "list.bullet"
        case .monthsGrid:
            return "square.grid.3x3"
        }
    }
}

struct YearNavigationView: View {
    @Binding var currentYear: Int
    let yearsToShow = 5 // Number of years to show on each side
    
    var body: some View {
            HStack(spacing: 15) {
                // Past years
                ForEach((currentYear-yearsToShow..<currentYear), id: \.self) { year in
                    Text(String(year))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            currentYear = year
                        }
                }
                
                // Current year
                Text(String(currentYear))
                    .font(.title.bold())
                    .foregroundColor(.primary)
                
                // Future years
                ForEach((currentYear+1...currentYear+yearsToShow), id: \.self) { year in
                    Text(String(year))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            currentYear = year
                        }
                }
            }
            .padding(.horizontal)
    }
}

struct ContentView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var currentYear: Int = Foundation.Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationView {
            // Sidebar
            CalendarSidebarView()
            
            // Main content
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top bar with year navigation and view mode switcher
                    HStack {
                        Spacer()
                        YearNavigationView(currentYear: $currentYear)
                        Spacer()
                        ViewModeSwitcher(selectedMode: $dataManager.viewMode)
                    }
                    .padding([.top, .trailing], 10)
                    
                    // Content based on view mode
                    if dataManager.viewMode == .monthRows {
                        monthRowsView
                    } else {
                        monthsGridView
                    }
                    Spacer()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
        .sheet(isPresented: $dataManager.showingNewCalendarSheet) {
            NewCalendarView { newCalendar in
                dataManager.addCalendar(newCalendar)
                dataManager.setActiveCalendar(newCalendar)
                dataManager.hideNewCalendarSheet()
            }
        }
        .onCommand(#selector(NSDocumentController.newDocument(_:))) {
            dataManager.showNewCalendarSheet()
        }
    }
    
    // Month rows layout
    private var monthRowsView: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(1...12, id: \.self) { month in
                    MonthRowView(
                        month: month,
                        year: currentYear,
                        markedDays: $dataManager.markedDays,
                        calendarColor: dataManager.activeCalendar?.color ?? Color.accentColor
                    )
                }
            }
            .padding()
        }
    }
    
    // Months grid layout
    let monthWidth:CGFloat = 230
    private var monthsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.fixed(monthWidth)),
                GridItem(.fixed(monthWidth)),
                GridItem(.fixed(monthWidth)),
                GridItem(.fixed(monthWidth))
            ], alignment: .center) {
                ForEach(1...12, id: \.self) { month in
                    MonthGridView(
                        month: month,
                        year: currentYear,
                        markedDays: $dataManager.markedDays,
                        calendarColor: dataManager.activeCalendar?.color ?? Color.accentColor
                    )
                }
            }
            .padding()
        }
    }
    
    private func toggleSidebar() {
        NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
    }
} 
