import Testing
@testable import Kalends

struct CalendarModelTests {
    
    @Test func calendarCreation() async throws {
        // Given
        let title = "My Calendar"
        let colorName = "blue"
        
        // When
        let calendar = KalendsCalendar(title: title, colorName: colorName)
        
        // Then
        #expect(calendar.title == title)
        #expect(calendar.colorName == colorName)
        #expect(calendar.id == "my-calendar")
        #expect(calendar.markedDays.isEmpty)
    }
    
    @Test func calendarIdGeneration() async throws {
        // Test with special characters
        let calendar1 = KalendsCalendar(title: "Test & Special Ch@rs!", colorName: "red")
        #expect(calendar1.id == "test-&-special-ch@rs!")
        
        // Test with spaces
        let calendar2 = KalendsCalendar(title: "Work Schedule", colorName: "green")
        #expect(calendar2.id == "work-schedule")
        
        // Test with uppercase
        let calendar3 = KalendsCalendar(title: "IMPORTANT DATES", colorName: "yellow")
        #expect(calendar3.id == "important-dates")
    }
    
    @Test func calendarEquality() async throws {
        // Two calendars with the same ID but different properties
        let calendar1 = KalendsCalendar(title: "Test", colorName: "red")
        
        var calendar2 = KalendsCalendar(title: "Test", colorName: "blue")
        calendar2.id = calendar1.id
        
        // They should be equal because equality is based on ID
        #expect(calendar1 == calendar2)
        
        // Different ID
        let calendar3 = KalendsCalendar(title: "Different", colorName: "red")
        #expect(calendar1 != calendar3)
    }
} 