import Testing
import Foundation
@testable import Kalends

struct IntegrationTests {
    
    @Test func calendarCreationAndMarkedDays() async throws {
        // Set up
        let dataManager = DataManager()
        
        // Start with a clean slate
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
        
        // Create calendars
        let workCalendar = KalendsCalendar(title: "Work", colorName: "blue")
        let personalCalendar = KalendsCalendar(title: "Personal", colorName: "green")
        
        // Add them to data manager
        dataManager.addCalendar(workCalendar)
        dataManager.addCalendar(personalCalendar)
        
        // Mark days in work calendar
        dataManager.setActiveCalendar(workCalendar)
        let workDate = Date()
        let workMarkedDays = [workDate: true]
        dataManager.markedDays = workMarkedDays
        
        // Mark days in personal calendar
        dataManager.setActiveCalendar(personalCalendar)
        let personalDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let personalMarkedDays = [personalDate: true]
        dataManager.markedDays = personalMarkedDays
        
        // Switch back to work calendar
        dataManager.setActiveCalendar(workCalendar)
        
        // Verify work calendar marked days
        #expect(dataManager.markedDays[workDate, default: false] == true)
        #expect(dataManager.markedDays[personalDate, default: true] == false)
        
        // Switch to personal calendar
        dataManager.setActiveCalendar(personalCalendar)
        
        // Verify personal calendar marked days
        #expect(dataManager.markedDays[workDate, default: true] == false)
        #expect(dataManager.markedDays[personalDate, default: false] == true)
        
        // Clean up
        for calendar in dataManager.calendars {
            dataManager.deleteCalendar(calendar)
        }
    }
    
    @Test func calendarPersistenceAcrossLaunches() async throws {
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
        
        // Create and save a calendar
        let personalCalendar = KalendsCalendar(title: "Personal", colorName: "green")
        dataManager.addCalendar(personalCalendar)
        
        // Mark some days
        dataManager.setActiveCalendar(personalCalendar)
        let markedDate = Date()
        let markedDays = [markedDate: true]
        dataManager.markedDays = markedDays
        
        // Simulate app restart
        let newDataManager = DataManager()
        
        // Verify calendars loaded
        #expect(newDataManager.calendars.count >= 1)
        
        // Find our personal calendar
        if let loadedPersonalCalendar = newDataManager.calendars.first(where: { $0.id == personalCalendar.id }) {
            // Set it active
            newDataManager.setActiveCalendar(loadedPersonalCalendar)
            
            // Verify marked days were persisted
            #expect(newDataManager.markedDays[markedDate, default: false] == true)
        } else {
            struct PersistenceError: Error {
                let message: String
            }
            throw PersistenceError(message: "Failed to find persisted calendar")
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