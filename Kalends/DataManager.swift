import SwiftUI
import Combine
import Foundation

class DataManager: ObservableObject {
    @Published var viewMode: ViewMode = .monthRows
    @Published var calendars: [KalendsCalendar] = []
    @Published var activeCalendarId: String?
    @Published var showingNewCalendarSheet = false
    
    // Flag for testing to skip persistence operations
    var skipPersistence = false
    
    private let viewModeKey = "viewMode"
    private let calendarsDirectory = "calendars"
    private let activeCalendarKey = "activeCalendar"
    
    private var cancellables = Set<AnyCancellable>()
    
    var markedDays: [Date: Bool] {
        get {
            guard let activeCalendar = activeCalendar else { return [:] }
            
            let dateFormatter = ISO8601DateFormatter()
            var result = [Date: Bool]()
            
            for (stringDate, value) in activeCalendar.markedDays {
                if let date = dateFormatter.date(from: stringDate) {
                    let normalized = normalizeDate(date)
                    result[normalized] = value
                }
            }
            
            return result
        }
        set {
            guard var activeCalendar = activeCalendar, let index = calendars.firstIndex(of: activeCalendar) else { 
                return 
            }
            
            let dateFormatter = ISO8601DateFormatter()
            var newMarkedDays = [String: Bool]()
            
            for (date, value) in newValue {
                let normalizedDate = normalizeDate(date)
                let stringDate = dateFormatter.string(from: normalizedDate)
                newMarkedDays[stringDate] = value
            }
            
            activeCalendar.markedDays = newMarkedDays
            calendars[index] = activeCalendar
            saveCalendar(activeCalendar)
        }
    }
    
    // Helper method to normalize dates by removing time components
    private func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
    var activeCalendar: KalendsCalendar? {
        if let id = activeCalendarId {
            return calendars.first { $0.id == id }
        }
        return calendars.first
    }
    
    init() {
        // Ensure we handle async operations appropriately
        loadViewMode()
        loadCalendars()
        loadActiveCalendarId()
        
        // Set up autosaving when data changes
        $viewMode
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveViewMode() }
            .store(in: &cancellables)
            
        $activeCalendarId
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveActiveCalendarId() }
            .store(in: &cancellables)
        
        // Defer changes to published properties to avoid publishing during view updates
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Create default calendar if none exist
            if self.calendars.isEmpty {
                let defaultCalendar = KalendsCalendar(title: "Default", colorName: "pink")
                self.addCalendar(defaultCalendar)
            }
            
            if self.activeCalendarId == nil && !self.calendars.isEmpty {
                self.activeCalendarId = self.calendars[0].id
            }
        }
    }
    
    // MARK: - Calendar Management
    
    func addCalendar(_ calendar: KalendsCalendar) {
        calendars.append(calendar)
        saveCalendar(calendar)
        
        // Make this the active calendar if it's the first one
        if calendars.count == 1 || activeCalendarId == nil {
            activeCalendarId = calendar.id
        }
    }
    
    func deleteCalendar(_ calendar: KalendsCalendar) {
        // First find the index of the calendar to delete
        guard let index = calendars.firstIndex(where: { $0.id == calendar.id }) else {
            return
        }
        
        // Store the ID to check if this is the active calendar
        let deletedId = calendar.id
        
        // Remove the calendar from the array
        calendars.remove(at: index)
        
        // Delete the persisted file
        deleteCalendarFile(calendar)
        
        // If we deleted the active calendar, select another one if available
        if activeCalendarId == deletedId {
            activeCalendarId = calendars.first?.id
        }
    }
    
    func setActiveCalendar(_ calendar: KalendsCalendar) {
        // Ensure the calendar exists in our array before setting it active
        if calendars.contains(where: { $0.id == calendar.id }) {
            activeCalendarId = calendar.id
        }
    }
    
    // MARK: - Persistence
    
    private func loadViewMode() {
        if skipPersistence { return }
        if let rawValue = UserDefaults.standard.string(forKey: viewModeKey),
           let mode = ViewMode(rawValue: rawValue) {
            viewMode = mode
        }
    }
    
    private func saveViewMode() {
        if skipPersistence { return }
        UserDefaults.standard.set(viewMode.rawValue, forKey: viewModeKey)
    }
    
    private func loadActiveCalendarId() {
        if skipPersistence { return }
        activeCalendarId = UserDefaults.standard.string(forKey: activeCalendarKey)
    }
    
    private func saveActiveCalendarId() {
        if skipPersistence { return }
        UserDefaults.standard.set(activeCalendarId, forKey: activeCalendarKey)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getCalendarsDirectory() -> URL {
        let directory = getDocumentsDirectory().appendingPathComponent(calendarsDirectory)
        
        // Create the directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        return directory
    }
    
    private func getCalendarURL(_ calendar: KalendsCalendar) -> URL {
        getCalendarsDirectory().appendingPathComponent("\(calendar.id).plist")
    }
    
    private func loadCalendars() {
        if skipPersistence { return }
        
        let directory = getCalendarsDirectory()
        
        // Get all calendar files
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return
        }
        
        // Load each calendar file
        var loadedCalendars: [KalendsCalendar] = []
        for fileURL in fileURLs where fileURL.pathExtension == "plist" {
            if let data = try? Data(contentsOf: fileURL) {
                let decoder = PropertyListDecoder()
                if let calendar = try? decoder.decode(KalendsCalendar.self, from: data) {
                    loadedCalendars.append(calendar)
                }
            }
        }
        
        calendars = loadedCalendars
    }
    
    private func saveCalendar(_ calendar: KalendsCalendar) {
        if skipPersistence { return }
        
        let fileURL = getCalendarURL(calendar)
        let encoder = PropertyListEncoder()
        
        if let data = try? encoder.encode(calendar) {
            try? data.write(to: fileURL)
        }
    }
    
    private func deleteCalendarFile(_ calendar: KalendsCalendar) {
        if skipPersistence { return }
        
        let fileURL = getCalendarURL(calendar)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - UI State Management
    
    func showNewCalendarSheet() {
        showingNewCalendarSheet = true
    }
    
    func hideNewCalendarSheet() {
        showingNewCalendarSheet = false
    }
}

// Helper extension to convert dictionary keys
extension Dictionary {
    func compactMapKeys<T>(_ transform: (Key) -> T?) -> [T: Value] {
        var dict = [T: Value]()
        for (key, value) in self {
            if let transformedKey = transform(key) {
                dict[transformedKey] = value
            }
        }
        return dict
    }
} 