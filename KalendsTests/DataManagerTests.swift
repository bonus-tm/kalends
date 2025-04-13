import Testing
import Foundation
@testable import Kalends

struct DataManagerTests {
    
    let testCalendar1 = KalendsCalendar(title: "Test Calendar 1", colorName: "red")
    let testCalendar2 = KalendsCalendar(title: "Test Calendar 2", colorName: "blue")
    
    @Test func addingCalendar() async throws {
        // Set up
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // When
        dataManager.addCalendar(testCalendar1)
        
        // Then
        #expect(dataManager.calendars.count == 1)
        #expect(dataManager.calendars.first == testCalendar1)
        #expect(dataManager.activeCalendarId == testCalendar1.id, "First added calendar should be active")
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
    
    @Test func settingActiveCalendar() async throws {
        // Set up
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Given
        dataManager.addCalendar(testCalendar1)
        dataManager.addCalendar(testCalendar2)
        
        // When
        dataManager.setActiveCalendar(testCalendar2)
        
        // Then
        #expect(dataManager.activeCalendarId == testCalendar2.id)
        #expect(dataManager.activeCalendar == testCalendar2)
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
    
    @Test func deletingCalendar() async throws {
        // Set up
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Given
        dataManager.addCalendar(testCalendar1)
        dataManager.addCalendar(testCalendar2)
        
        // When
        dataManager.deleteCalendar(testCalendar1)
        
        // Then
        #expect(dataManager.calendars.count == 1)
        #expect(dataManager.calendars.first == testCalendar2)
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
    
    @Test func deletingActiveCalendar() async throws {
        // Set up
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Given
        dataManager.addCalendar(testCalendar1)
        dataManager.addCalendar(testCalendar2)
        dataManager.setActiveCalendar(testCalendar1)
        
        // When
        dataManager.deleteCalendar(testCalendar1)
        
        // Then
        #expect(dataManager.activeCalendarId == testCalendar2.id, "Should fall back to another calendar")
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
    
    @Test func markedDaysGetterSetter() async throws {
        // Set up
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Given
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let markedDays = [today: true, tomorrow: false]
        
        dataManager.addCalendar(testCalendar1)
        
        // When
        dataManager.markedDays = markedDays
        
        // Then
        #expect(dataManager.markedDays.count == 2)
        #expect(dataManager.markedDays[today, default: false] == true)
        #expect(dataManager.markedDays[tomorrow, default: true] == false)
        
        // No active calendar
        dataManager.activeCalendarId = nil
        #expect(dataManager.markedDays.isEmpty)
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
    
    @Test func persistenceOfCalendars() async throws {
        // Skip this test in CI environment to avoid file system permissions issues
        if ProcessInfo.processInfo.environment["CI"] == "true" {
            return
        }
        
        // Set up
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Given
        dataManager.addCalendar(testCalendar1)
        dataManager.addCalendar(testCalendar2)
        
        // Today's date
        let today = Date()
        let updatedMarkedDays = [today: true]
        dataManager.markedDays = updatedMarkedDays
        
        // When - create a new data manager which should load the saved data
        let newDataManager = DataManager()
        
        // Then
        #expect(newDataManager.calendars.count >= 1)
        
        // Check if the calendar with marked days is present
        if let calendar = newDataManager.calendars.first(where: { $0.id == testCalendar1.id }) {
            newDataManager.setActiveCalendar(calendar)
            #expect(newDataManager.markedDays[today, default: false] == true)
        } else {
            struct CalendarError: Error {
                let message: String
            }
            throw CalendarError(message: "Saved calendar not found")
        }
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        for calendar in newDataManager.calendars {
            newDataManager.deleteCalendar(calendar)
        }
    }
} 