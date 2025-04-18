import Testing
import SwiftUI
@testable import Kalends

struct DaySquareViewTests {
    
    @Test func daySquareShowsCalendarColor() async throws {
        // Create a test instance
        let view = DaySquareView(
            day: 15,
            month: 6,
            year: 2024,
            isMarked: true,
            calendarColor: Color.blue,
            onToggle: {}
        )
        
        // Verify the color is passed through
        #expect(view.calendarColor == Color.blue)
    }
    
    @Test func toggleCallsCallback() async throws {
        var toggled = false
        
        // Create a view with a toggle callback
        let view = DaySquareView(
            day: 15,
            month: 6,
            year: 2024,
            isMarked: false,
            calendarColor: Color.red,
            onToggle: {
                toggled = true
            }
        )
        
        // Trigger the toggle
        await view.onToggle()
        
        // Verify the callback was called
        #expect(toggled)
    }
    
    @Test func currentDayDetection() async throws {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        
        // Create a view for today
        let todayView = DaySquareView(
            day: components.day!,
            month: components.month!,
            year: components.year!,
            isMarked: false,
            calendarColor: Color.green,
            onToggle: {}
        )
        
        // Directly access the computed property since it's used in the View body
        // This is better than using reflection which might be fragile
        let isCurrentDay = todayView.isCurrentDay
        
        // Verify it detects today correctly
        #expect(isCurrentDay)
        
        // Create a view for tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let tomorrowComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        
        let tomorrowView = DaySquareView(
            day: tomorrowComponents.day!,
            month: tomorrowComponents.month!,
            year: tomorrowComponents.year!,
            isMarked: false,
            calendarColor: Color.green,
            onToggle: {}
        )
        
        // Directly access the computed property
        let isTomorrowCurrentDay = tomorrowView.isCurrentDay
        
        // Verify it's not detected as today
        #expect(!isTomorrowCurrentDay)
    }
} 