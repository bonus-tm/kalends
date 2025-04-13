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
        
        // Get access to private property using reflection
        let mirror = Mirror(reflecting: todayView)
        let isCurrentDay = await mirror.children
            .first(where: { $0.label == "isCurrentDay" })?.value as? Bool ?? false
        
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
        
        // Get access to private property using reflection
        let tomorrowMirror = Mirror(reflecting: tomorrowView)
        let isTomorrowCurrentDay = await tomorrowMirror.children
            .first(where: { $0.label == "isCurrentDay" })?.value as? Bool ?? false
        
        // Verify it's not detected as today
        #expect(!isTomorrowCurrentDay)
    }
} 