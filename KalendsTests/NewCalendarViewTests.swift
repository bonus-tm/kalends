import Testing
import SwiftUI
@testable import Kalends

struct NewCalendarViewTests {
    
    @Test func createCalendarWithTitleAndColor() async throws {
        var createdCalendar: KalendsCalendar?
        
        // Create the view model
        let viewModel = NewCalendarViewModel { calendar in
            createdCalendar = calendar
        }
        
        // Set values
        viewModel.calendarTitle = "Work"
        viewModel.selectedColor = "blue"
        
        // Create the calendar
        viewModel.createCalendar()
        
        // Check the created calendar
        #expect(createdCalendar != nil)
        #expect(createdCalendar?.title == "Work")
        #expect(createdCalendar?.colorName == "blue")
        #expect(createdCalendar?.id == "work")
    }
    
    @Test func emptyTitleValidation() async throws {
        let viewModel = NewCalendarViewModel { _ in }
        
        // Default state
        viewModel.calendarTitle = ""
        #expect(!viewModel.isValid)
        
        // Valid state
        viewModel.calendarTitle = "Test"
        #expect(viewModel.isValid)
    }
    
    @Test func createWithEmptyTitleUsesDefaultTitle() async throws {
        var createdCalendar: KalendsCalendar?
        
        // Create the view model
        let viewModel = NewCalendarViewModel { calendar in
            createdCalendar = calendar
        }
        
        // Empty title but force creation
        viewModel.calendarTitle = ""
        viewModel.createCalendarWithFallback()
        
        // The calendar should get a default title
        #expect(createdCalendar?.title == "Untitled Calendar")
    }
}

// Simple view model for testing
class NewCalendarViewModel {
    var calendarTitle = ""
    var selectedColor = "pink"
    private let onCalendarCreated: (KalendsCalendar) -> Void
    
    var isValid: Bool {
        !calendarTitle.isEmpty
    }
    
    init(onCalendarCreated: @escaping (KalendsCalendar) -> Void) {
        self.onCalendarCreated = onCalendarCreated
    }
    
    func createCalendar() {
        guard isValid else { return }
        let calendar = KalendsCalendar(title: calendarTitle, colorName: selectedColor)
        onCalendarCreated(calendar)
    }
    
    func createCalendarWithFallback() {
        let title = calendarTitle.isEmpty ? "Untitled Calendar" : calendarTitle
        let calendar = KalendsCalendar(title: title, colorName: selectedColor)
        onCalendarCreated(calendar)
    }
} 