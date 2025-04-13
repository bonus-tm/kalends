import SwiftUI

struct KalendsCalendar: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var colorName: String
    var markedDays: [String: Bool] = [:]
    
    var color: Color {
        Self.colorMap[colorName] ?? .pink
    }
    
    // Dictionary to map color names to actual SwiftUI Color values
    private static let colorMap: [String: Color] = [
        "pink": .pink,
        "blue": .blue,
        "green": .green,
        "orange": .orange,
        "purple": .purple,
        "red": .red,
        "yellow": .yellow,
        "indigo": .indigo,
        "teal": .teal,
        "cyan": .cyan
    ]
    
    init(title: String, colorName: String) {
        self.id = title.lowercased().replacingOccurrences(of: " ", with: "-")
        self.title = title
        self.colorName = colorName
    }
    
    static func == (lhs: KalendsCalendar, rhs: KalendsCalendar) -> Bool {
        return lhs.id == rhs.id
    }
} 