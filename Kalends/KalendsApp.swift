import SwiftUI

@main
struct KalendsApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup("Kalends") {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .environmentObject(dataManager)
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Calendar...") {
                    dataManager.showNewCalendarSheet()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .defaultSize(width: 800, height: 600)
        .defaultPosition(.center)
    }
} 
