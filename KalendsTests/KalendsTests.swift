//
//  KalendsTests.swift
//  KalendsTests
//
//  Created by Bonus TM on 13.04.2025.
//  Copyright © 2025 Kalends. All rights reserved.
//

import Testing
@testable import Kalends

struct KalendsTests {
    @Test func calendarCreation() async throws {
        let calendar = KalendsCalendar(title: "Test Calendar", colorName: "blue")
        
        #expect(calendar.title == "Test Calendar")
        #expect(calendar.colorName == "blue")
        #expect(calendar.id == "test-calendar")
        #expect(calendar.markedDays.isEmpty)
    }
    
    @Test func calendarIdGeneration() async throws {
        let calendar1 = KalendsCalendar(title: "Test & Special Ch@rs!", colorName: "red")
        #expect(calendar1.id == "test-&-special-ch@rs!")
        
        let calendar2 = KalendsCalendar(title: "Work Schedule", colorName: "green")
        #expect(calendar2.id == "work-schedule")
    }
    
    @Test func calendarEquality() async throws {
        let calendar1 = KalendsCalendar(title: "Test", colorName: "red")
        
        var calendar2 = KalendsCalendar(title: "Test", colorName: "blue")
        calendar2.id = calendar1.id
        
        #expect(calendar1 == calendar2, "Calendars with same ID should be equal")
        
        let calendar3 = KalendsCalendar(title: "Different", colorName: "red")
        #expect(calendar1 != calendar3, "Calendars with different IDs should not be equal")
    }
}
