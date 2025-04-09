import SwiftUI

struct MonthRowView: View {
    let month: Int
    let year: Int
    @Binding var markedDays: [Date: Bool]
    
    private let calendar = Calendar.current
    private let daysInWeek = 31
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Month name and year
            VStack(alignment: .leading) {
                Text(monthName)
                    .font(.headline)
                Text(yearString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, alignment: .leading)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            
            // Days grid
            HStack(spacing: 1) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    DaySquareView(
                        day: day,
                        month: month,
                        year: year,
                        isMarked: isMarked(day: day),
                        onToggle: { toggleDay(day: day) }
                    )
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        return dateFormatter.string(from: date)
    }
    
    private var yearString: String {
        return "\(year)"
    }
    
    private var daysInMonth: Int {
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
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
