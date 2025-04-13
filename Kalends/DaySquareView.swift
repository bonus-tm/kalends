import SwiftUI
import Foundation

struct DaySquareView: View {
    let day: Int
    let month: Int
    let year: Int
    let isMarked: Bool
    let calendarColor: Color
    let onToggle: () -> Void
    
    @State private var isHovering = false
    
    private let calendar = Foundation.Calendar.current
    
    var body: some View {
        let isToday = isCurrentDay
        
        Button(action: onToggle) {
            Text("\(day)")
                .font(.system(size: 12))
                .frame(width: 30, height: 30)
                .background(
                    ZStack {
                        if isMarked {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(calendarColor.opacity(0.3))
                        }
                        
                        if isHovering && !isMarked {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.1))
                        }
                        
                        if isToday {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.red, lineWidth: 1)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private var isCurrentDay: Bool {
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        return components.year == year && components.month == month && components.day == day
    }
} 