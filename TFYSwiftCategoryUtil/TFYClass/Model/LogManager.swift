////
////  LogManager.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 日志管理器
//final class LogManager {
//    static let shared = LogManager()
//    
//    // MARK: - 日志级别
//    enum Level: Int {
//        case debug = 0
//        case info
//        case warning
//        case error
//        
//        var icon: String {
//            switch self {
//            case .debug: return "🔍"
//            case .info: return "ℹ️"
//            case .warning: return "⚠️"
//            case .error: return "❌"
//            }
//        }
//        
//        var color: UIColor {
//            switch self {
//            case .debug: return .systemGray
//            case .info: return .systemBlue
//            case .warning: return .systemYellow
//            case .error: return .systemRed
//            }
//        }
//    }
//    
//    // MARK: - 日志条目
//    struct LogEntry: Codable {
//        let timestamp: Date
//        let level: Level
//        let category: String
//        let message: String
//        let file: String
//        let function: String
//        let line: Int
//        var metadata: [String: String]?
//        
//        var formattedTimestamp: String {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
//            return formatter.string(from: timestamp)
//        }
//    }
//    
//    // MARK: - 属性
//    private let queue = DispatchQueue(label: "com.tfy.ssr.log", qos: .utility)
//    private let storage = LogStorage()
//    private let maxEntries = 10000
//    private var currentEntries: [LogEntry] = []
//    private var observers: [UUID: LogObserver] = [:]
//    private var minimumLevel: Level = .debug
//    
//    // MARK: - 初始化
//    private init() {
//        loadExistingLogs()
//        setupPeriodicCleanup()
//    }
//    
//    // MARK: - 公共方法
//    func log(
//        level: Level,
//        category: String,
//        message: String,
//        metadata: [String: String]? = nil,
//        file: String = #file,
//        function: String = #function,
//        line: Int = #line
//    ) {
//        guard level.rawValue >= minimumLevel.rawValue else { return }
//        
//        let entry = LogEntry(
//            timestamp: Date(),
//            level: level,
//            category: category,
//            message: message,
//            file: file,
//            function: function,
//            line: line,
//            metadata: metadata
//        )
//        
//        queue.async {
//            self.addEntry(entry)
//            self.notifyObservers(entry)
//            self.storage.saveEntry(entry)
//        }
//    }
//    
//    func debug(_ message: String, category: String = "Debug", metadata: [String: String]? = nil,
//               file: String = #file, function: String = #function, line: Int = #line) {
//        log(level: .debug, category: category, message: message, metadata: metadata,
//            file: file, function: function, line: line)
//    }
//    
//    func info(_ message: String, category: String = "Info", metadata: [String: String]? = nil,
//              file: String = #file, function: String = #function, line: Int = #line) {
//        log(level: .info, category: category, message: message, metadata: metadata,
//            file: file, function: function, line: line)
//    }
//    
//    func warning(_ message: String, category: String = "Warning", metadata: [String: String]? = nil,
//                 file: String = #file, function: String = #function, line: Int = #line) {
//        log(level: .warning, category: category, message: message, metadata: metadata,
//            file: file, function: function, line: line)
//    }
//    
//    func error(_ message: String, category: String = "Error", metadata: [String: String]? = nil,
//               file: String = #file, function: String = #function, line: Int = #line) {
//        log(level: .error, category: category, message: message, metadata: metadata,
//            file: file, function: function, line: line)
//    }
//    
//    func getEntries(
//        level: Level? = nil,
//        category: String? = nil,
//        from: Date? = nil,
//        to: Date? = nil
//    ) -> [LogEntry] {
//        queue.sync {
//            var filtered = currentEntries
//            
//            if let level = level {
//                filtered = filtered.filter { $0.level == level }
//            }
//            
//            if let category = category {
//                filtered = filtered.filter { $0.category == category }
//            }
//            
//            if let from = from {
//                filtered = filtered.filter { $0.timestamp >= from }
//            }
//            
//            if let to = to {
//                filtered = filtered.filter { $0.timestamp <= to }
//            }
//            
//            return filtered
//        }
//    }
//    
//    func clearLogs() {
//        queue.async {
//            self.currentEntries.removeAll()
//            self.storage.clearLogs()
//            self.notifyObserversForClear()
//        }
//    }
//    
//    func setMinimumLevel(_ level: Level) {
//        queue.async {
//            self.minimumLevel = level
//        }
//    }
//    
//    @discardableResult
//    func addObserver(_ handler: @escaping (LogEntry) -> Void) -> UUID {
//        let id = UUID()
//        queue.async {
//            self.observers[id] = LogObserver(handler: handler)
//        }
//        return id
//    }
//    
//    func removeObserver(_ id: UUID) {
//        queue.async {
//            self.observers.removeValue(forKey: id)
//        }
//    }
//    
//    // MARK: - 私有方法
//    private func loadExistingLogs() {
//        queue.async {
//            self.currentEntries = self.storage.loadLogs()
//        }
//    }
//    
//    private func setupPeriodicCleanup() {
//        // 每天清理一次旧日志
//        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
//            self?.cleanupOldLogs()
//        }
//    }
//    
//    private func addEntry(_ entry: LogEntry) {
//        currentEntries.append(entry)
//        if currentEntries.count > maxEntries {
//            currentEntries.removeFirst(currentEntries.count - maxEntries)
//        }
//    }
//    
//    private func cleanupOldLogs() {
//        queue.async {
//            // 保留最近7天的日志
//            let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//            self.currentEntries = self.currentEntries.filter { $0.timestamp > cutoffDate }
//            self.storage.cleanupLogs(before: cutoffDate)
//        }
//    }
//    
//    private func notifyObservers(_ entry: LogEntry) {
//        observers.values.forEach { observer in
//            DispatchQueue.main.async {
//                observer.handler(entry)
//            }
//        }
//    }
//    
//    private func notifyObserversForClear() {
//        observers.values.forEach { observer in
//            DispatchQueue.main.async {
//                observer.handler(LogEntry(
//                    timestamp: Date(),
//                    level: .info,
//                    category: "System",
//                    message: "Logs cleared",
//                    file: #file,
//                    function: #function,
//                    line: #line
//                ))
//            }
//        }
//    }
//}
//
//// MARK: - 日志观察者
//struct LogObserver {
//    let handler: (LogManager.LogEntry) -> Void
//}
//
//// MARK: - 日志存储
//final class LogStorage {
//    private let fileManager = FileManager.default
//    private let decoder = JSONDecoder()
//    private let encoder = JSONEncoder()
//    
//    private var logsDirectory: URL {
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls[0].appendingPathComponent("logs")
//    }
//    
//    init() {
//        createLogsDirectoryIfNeeded()
//    }
//    
//    func saveEntry(_ entry: LogManager.LogEntry) {
//        do {
//            let data = try encoder.encode(entry)
//            let fileName = "\(entry.formattedTimestamp)-\(UUID().uuidString).log"
//            let fileURL = logsDirectory.appendingPathComponent(fileName)
//            try data.write(to: fileURL)
//        } catch {
//            print("Failed to save log entry: \(error)")
//        }
//    }
//    
//    func loadLogs() -> [LogManager.LogEntry] {
//        var entries: [LogManager.LogEntry] = []
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil)
//            for file in files {
//                if let data = try? Data(contentsOf: file),
//                   let entry = try? decoder.decode(LogManager.LogEntry.self, from: data) {
//                    entries.append(entry)
//                }
//            }
//        } catch {
//            print("Failed to load logs: \(error)")
//        }
//        
//        return entries.sorted { $0.timestamp < $1.timestamp }
//    }
//    
//    func clearLogs() {
//        do {
//            let files = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil)
//            for file in files {
//                try fileManager.removeItem(at: file)
//            }
//        } catch {
//            print("Failed to clear logs: \(error)")
//        }
//    }
//    
//    func cleanupLogs(before date: Date) {
//        do {
//            let files = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey])
//            for file in files {
//                guard let creationDate = try file.resourceValues(forKeys: [.creationDateKey]).creationDate,
//                      creationDate < date else {
//                    continue
//                }
//                try fileManager.removeItem(at: file)
//            }
//        } catch {
//            print("Failed to cleanup logs: \(error)")
//        }
//    }
//    
//    private func createLogsDirectoryIfNeeded() {
//        do {
//            try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
//        } catch {
//            print("Failed to create logs directory: \(error)")
//        }
//    }
//}
