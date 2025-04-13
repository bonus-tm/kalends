//
//  MonthGridView.swift
//  Kalends
//
//  Created by Bonus TM on 08.04.2025.
//  Copyright © 2025 Kalends. All rights reserved.
//


import SwiftUI
import Foundation

struct MonthGridView: View {
    let month: Int
    let year: Int
    @Binding var markedDays: [Date: Bool]
    var calendarColor: Color
    
    private let calendar = Foundation.Calendar.current
    private let weekdaySymbols = Foundation.Calendar.current.veryShortWeekdaySymbols
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Month name
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Text(monthName)
                    .font(.headline)
                    .padding(.bottom, 2)
                Spacer()
            }
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(0..<weekdaySymbols.count, id: \.self) { index in
                    Text(weekdaySymbols[index])
                        .font(.system(size: 10))
                        .frame(width: 31, height: 20)
                        .foregroundColor(.secondary)
                }
            }
            
            // Calendar grid
            VStack(alignment: .leading, spacing: 1) {
                ForEach(weeksOfMonth, id: \.self) { week in
                    HStack(spacing: 1) {
                        ForEach(0..<7) { weekdayIndex in
                            if let day = dayForDate(week: week, weekday: weekdayIndex) {
                                DaySquareView(
                                    day: day,
                                    month: month,
                                    year: year,
                                    isMarked: isMarked(day: day),
                                    calendarColor: calendarColor,
                                    onToggle: { toggleDay(day: day) }
                                )
                                .frame(width: 30, height: 30)
                            } else {
                                Color.clear
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                }
            }
            Spacer() // Push content to the top when fewer than 6 weeks
        }
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .frame(height: 250) // Fixed height to accommodate 6 weeks, month name, and weekday headers
    }
    
    private var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        return dateFormatter.string(from: date)
    }
    
    private var weeksOfMonth: [Date] {
        let monthStart = firstDayOfMonth
        
        // Calculate the first day of the first week containing the first day of the month
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let weekOffset = calendar.firstWeekday - firstWeekday
        let firstDateOfGrid = calendar.date(byAdding: .day, value: weekOffset, to: monthStart)!
        
        // Always generate 6 weeks
        var weeks: [Date] = []
        var currentDate = firstDateOfGrid
        
        for _ in 0..<6 {
            weeks.append(currentDate)
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        
        return weeks
    }
    
    private var firstDayOfMonth: Date {
        calendar.date(from: DateComponents(year: year, month: month, day: 1))!
    }
    
    private func dayForDate(week: Date, weekday: Int) -> Int? {
        let weekdayDate = calendar.date(byAdding: .day, value: weekday, to: week)!
        let components = calendar.dateComponents([.day, .month, .year], from: weekdayDate)
        
        guard components.month == month && components.year == year else {
            return nil
        }
        
        return components.day
    }
    
    private func isMarked(day: Int) -> Bool {
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components) else { return false }
        return markedDays[date, default: false]
    }
    
    private func toggleDay(day: Int) {
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components) else { return }
        DispatchQueue.main.async {
            markedDays[date] = !(markedDays[date] ?? false)
        }
    }
}
