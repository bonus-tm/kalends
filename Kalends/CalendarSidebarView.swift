import SwiftUI
import AppKit

struct CalendarSidebarView: View {
    @EnvironmentObject private var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Calendars")
                .font(.headline)
                .padding(.top, 20)
                .padding(.leading, 16)
            
            List(selection: Binding<String?>(
                get: { dataManager.activeCalendarId },
                set: { newId in
                    if let newId = newId, let calendar = dataManager.calendars.first(where: { $0.id == newId }) {
                        dataManager.setActiveCalendar(calendar)
                    }
                }
            )) {
                ForEach(dataManager.calendars) { calendar in
                    HStack {
                        Circle()
                            .fill(calendar.color)
                            .frame(width: 12, height: 12)
                        Text(calendar.title)
                    }
                    .tag(calendar.id)
                    .padding(.vertical, 4)
                }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    // Show the new calendar sheet using the shared dataManager
                    dataManager.showNewCalendarSheet()
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
            }
        }
        .frame(width: 200)
        .background(Color(NSColor.windowBackgroundColor))
    }
} 