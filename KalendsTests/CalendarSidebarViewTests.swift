import Testing
import SwiftUI
@testable import Kalends

struct CalendarSidebarViewTests {
    
    @Test func calendarSidebarDisplaysAllCalendars() async throws {
        // Create a data manager with test data
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Add test calendars
        dataManager.addCalendar(KalendsCalendar(title: "Test Calendar 1", colorName: "red"))
        dataManager.addCalendar(KalendsCalendar(title: "Test Calendar 2", colorName: "blue"))
        
        // Create a view model backed by our test data manager
        let viewModel = CalendarSidebarViewModel(dataManager: dataManager)
        
        // Check if all calendars are present in view model
        #expect(viewModel.calendars.count == 2)
        #expect(viewModel.calendars[0].title == "Test Calendar 1")
        #expect(viewModel.calendars[1].title == "Test Calendar 2")
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
    
    @Test func selectingCalendarMakesItActive() async throws {
        // Create a data manager with test data
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Add test calendars
        dataManager.addCalendar(KalendsCalendar(title: "Test Calendar 1", colorName: "red"))
        dataManager.addCalendar(KalendsCalendar(title: "Test Calendar 2", colorName: "blue"))
        
        // Create a view model backed by our test data manager
        let viewModel = CalendarSidebarViewModel(dataManager: dataManager)
        
        // Set active calendar
        let calendarToSelect = viewModel.calendars[1]
        viewModel.selectCalendar(calendarToSelect)
        
        // Check active calendar in data manager
        #expect(dataManager.activeCalendarId == calendarToSelect.id)
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
}

// Simple view model for testing
class CalendarSidebarViewModel {
    private let dataManager: DataManager
    
    var calendars: [KalendsCalendar] {
        dataManager.calendars
    }
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func selectCalendar(_ calendar: KalendsCalendar) {
        dataManager.setActiveCalendar(calendar)
    }
} 