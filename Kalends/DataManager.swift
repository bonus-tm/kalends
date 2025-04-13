import SwiftUI
import Combine

class DataManager: ObservableObject {
    @Published var viewMode: ViewMode = .monthRows
    @Published var calendars: [KalendsCalendar] = []
    @Published var activeCalendarId: String?
    @Published var showingNewCalendarSheet = false
    
    private let viewModeKey = "viewMode"
    private let calendarsDirectory = "calendars"
    private let activeCalendarKey = "activeCalendar"
    
    private var cancellables = Set<AnyCancellable>()
    
    var markedDays: [Date: Bool] {
        get {
            guard let activeCalendar = activeCalendar else { return [:] }
            let dateFormatter = ISO8601DateFormatter()
            return activeCalendar.markedDays.compactMapKeys { key in
                dateFormatter.date(from: key)
            }
        }
        set {
            guard var activeCalendar = activeCalendar, let index = calendars.firstIndex(of: activeCalendar) else { return }
            
            let dateFormatter = ISO8601DateFormatter()
            let stringDict = newValue.compactMapKeys { date in
                dateFormatter.string(from: date)
            }
            
            activeCalendar.markedDays = stringDict
            calendars[index] = activeCalendar
            saveCalendar(activeCalendar)
        }
    }
    
    var activeCalendar: KalendsCalendar? {
        if let id = activeCalendarId {
            return calendars.first { $0.id == id }
        }
        return calendars.first
    }
    
    init() {
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
        if calendars.count == 1 {
            DispatchQueue.main.async { [weak self] in
                self?.activeCalendarId = calendar.id
            }
        }
    }
    
    func deleteCalendar(_ calendar: KalendsCalendar) {
        calendars.removeAll { $0.id == calendar.id }
        deleteCalendarFile(calendar)
        
        // If we deleted the active calendar, select another one
        if activeCalendarId == calendar.id {
            DispatchQueue.main.async { [weak self] in
                self?.activeCalendarId = self?.calendars.first?.id
            }
        }
    }
    
    func setActiveCalendar(_ calendar: KalendsCalendar) {
        DispatchQueue.main.async { [weak self] in
            self?.activeCalendarId = calendar.id
        }
    }
    
    // MARK: - Persistence
    
    private func loadViewMode() {
        if let rawValue = UserDefaults.standard.string(forKey: viewModeKey),
           let mode = ViewMode(rawValue: rawValue) {
            viewMode = mode
        }
    }
    
    private func saveViewMode() {
        UserDefaults.standard.set(viewMode.rawValue, forKey: viewModeKey)
    }
    
    private func loadActiveCalendarId() {
        activeCalendarId = UserDefaults.standard.string(forKey: activeCalendarKey)
    }
    
    private func saveActiveCalendarId() {
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
        let fileURL = getCalendarURL(calendar)
        let encoder = PropertyListEncoder()
        
        if let data = try? encoder.encode(calendar) {
            try? data.write(to: fileURL)
        }
    }
    
    private func deleteCalendarFile(_ calendar: KalendsCalendar) {
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