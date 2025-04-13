import SwiftUI

struct NewCalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var dataManager: DataManager
    @State private var calendarTitle = ""
    @State private var selectedColor = "pink"
    var onCalendarCreated: (KalendsCalendar) -> Void
    
    let availableColors = [
        "pink", "blue", "green", "orange", "purple", "red", "yellow", "indigo", "teal", "cyan"
    ]
    
    // Dictionary to map color names to actual SwiftUI Color values
    let colorMap: [String: Color] = [
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
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Calendar")
                .font(.headline)
            
            TextField("Calendar Title", text: $calendarTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Color selection
            HStack {
                Text("Color:")
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(availableColors, id: \.self) { colorName in
                            Circle()
                                .fill(colorMap[colorName] ?? .pink)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == colorName ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = colorName
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dataManager.hideNewCalendarSheet()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Create") {
                    let newCalendar = KalendsCalendar(title: calendarTitle.isEmpty ? "Untitled Calendar" : calendarTitle,
                                               colorName: selectedColor)
                    onCalendarCreated(newCalendar)
                    dataManager.hideNewCalendarSheet()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(calendarTitle.isEmpty)
            }
            .padding()
        }
        .frame(width: 400, height: 200)
        .padding()
    }
} 