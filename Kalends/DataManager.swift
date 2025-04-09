import SwiftUI
import Combine

class DataManager: ObservableObject {
    @Published var viewMode: ViewMode = .monthRows
    @Published var markedDays: [Date: Bool] = [:]
    
    private let viewModeKey = "viewMode"
    private let markedDaysFilename = "markedDays.plist"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadViewMode()
        loadMarkedDays()
        
        // Set up autosaving when data changes
        $viewMode
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveViewMode() }
            .store(in: &cancellables)
            
        $markedDays
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveMarkedDays() }
            .store(in: &cancellables)
    }
    
    private func loadViewMode() {
        if let rawValue = UserDefaults.standard.string(forKey: viewModeKey),
           let mode = ViewMode(rawValue: rawValue) {
            viewMode = mode
        }
    }
    
    private func saveViewMode() {
        UserDefaults.standard.set(viewMode.rawValue, forKey: viewModeKey)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func loadMarkedDays() {
        let fileURL = getDocumentsDirectory().appendingPathComponent(markedDaysFilename)
        
        if let data = try? Data(contentsOf: fileURL) {
            let decoder = PropertyListDecoder()
            
            // Date can't be used directly as a key in Codable, so we store [String: Bool]
            if let decodedData = try? decoder.decode([String: Bool].self, from: data) {
                let dateFormatter = ISO8601DateFormatter()
                markedDays = decodedData.compactMapKeys { key in
                    dateFormatter.date(from: key)
                }
            }
        }
    }
    
    private func saveMarkedDays() {
        let fileURL = getDocumentsDirectory().appendingPathComponent(markedDaysFilename)
        let encoder = PropertyListEncoder()
        
        // Convert Date keys to String since Date isn't directly Hashable in Codable
        let dateFormatter = ISO8601DateFormatter()
        let stringDict = markedDays.compactMapKeys { date in
            dateFormatter.string(from: date)
        }
        
        if let data = try? encoder.encode(stringDict) {
            try? data.write(to: fileURL)
        }
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