////
////  CrashReportManager.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//
//// MARK: - 崩溃报告管理器
//final class CrashReportManager {
//    static let shared = CrashReportManager()
//    
//    // MARK: - 属性
//    private let queue = DispatchQueue(label: "com.tfy.ssr.crash", qos: .utility)
//    private let storage = CrashStorage()
//    private var previousCrashHandler: NSUncaughtExceptionHandler?
//    
//    // MARK: - 初始化
//    private init() {
//        setupCrashHandler()
//    }
//    
//    // MARK: - 公共方法
//    func getCrashReports() -> [CrashReport] {
//        return storage.loadReports()
//    }
//    
//    func clearReports() {
//        storage.clearReports()
//    }
//    
//    // MARK: - 私有方法
//    private func setupCrashHandler() {
//        previousCrashHandler = NSGetUncaughtExceptionHandler()
//        NSSetUncaughtExceptionHandler { [weak self] exception in
//            self?.handleException(exception)
//        }
//        
//        signal(SIGABRT) { signal in
//            CrashReportManager.shared.handleSignal(signal)
//        }
//        signal(SIGILL) { signal in
//            CrashReportManager.shared.handleSignal(signal)
//        }
//        signal(SIGSEGV) { signal in
//            CrashReportManager.shared.handleSignal(signal)
//        }
//        signal(SIGFPE) { signal in
//            CrashReportManager.shared.handleSignal(signal)
//        }
//        signal(SIGBUS) { signal in
//            CrashReportManager.shared.handleSignal(signal)
//        }
//        signal(SIGPIPE) { signal in
//            CrashReportManager.shared.handleSignal(signal)
//        }
//    }
//    
//    private func handleException(_ exception: NSException) {
//        let report = CrashReport(
//            type: .exception,
//            name: exception.name.rawValue,
//            reason: exception.reason ?? "Unknown reason",
//            callStack: exception.callStackSymbols,
//            deviceInfo: DeviceInfo.current,
//            timestamp: Date()
//        )
//        
//        storage.saveReport(report)
//        
//        if let previousHandler = previousCrashHandler {
//            previousHandler(exception)
//        }
//    }
//    
//    private func handleSignal(_ signal: Int32) {
//        var callStack: [String] = []
//        Thread.callStackSymbols.forEach { symbol in
//            callStack.append(symbol)
//        }
//        
//        let report = CrashReport(
//            type: .signal,
//            name: String(cString: sys_signame(signal)),
//            reason: "Signal \(signal) received",
//            callStack: callStack,
//            deviceInfo: DeviceInfo.current,
//            timestamp: Date()
//        )
//        
//        storage.saveReport(report)
//    }
//}
//
//// MARK: - 性能分析器
//final class PerformanceProfiler {
//    static let shared = PerformanceProfiler()
//    
//    // MARK: - 属性
//    private var currentProfile: PerformanceProfile?
//    private var profiles: [PerformanceProfile] = []
//    private let storage = PerformanceStorage()
//    private let queue = DispatchQueue(label: "com.tfy.ssr.profiler", qos: .utility)
//    
//    // MARK: - 公共方法
//    func startProfiling(name: String) {
//        queue.async {
//            self.currentProfile = PerformanceProfile(
//                name: name,
//                startTime: Date()
//            )
//        }
//    }
//    
//    func stopProfiling() {
//        queue.async {
//            guard var profile = self.currentProfile else { return }
//            profile.endTime = Date()
//            profile.metrics = PerformanceManager.shared.currentMetrics
//            self.profiles.append(profile)
//            self.storage.saveProfile(profile)
//            self.currentProfile = nil
//        }
//    }
//    
//    func getProfiles() -> [PerformanceProfile] {
//        return storage.loadProfiles()
//    }
//    
//    func clearProfiles() {
//        queue.async {
//            self.profiles.removeAll()
//            self.storage.clearProfiles()
//        }
//    }
//}
//
//// MARK: - 数据模型
//struct CrashReport: Codable {
//    enum CrashType: String, Codable {
//        case exception
//        case signal
//    }
//    
//    let type: CrashType
//    let name: String
//    let reason: String
//    let callStack: [String]
//    let deviceInfo: DeviceInfo
//    let timestamp: Date
//    
//    var formattedTimestamp: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return formatter.string(from: timestamp)
//    }
//}
//
//struct DeviceInfo: Codable {
//    let systemName: String
//    let systemVersion: String
//    let deviceModel: String
//    let appVersion: String
//    let appBuild: String
//    
//    static var current: DeviceInfo {
//        return DeviceInfo(
//            systemName: UIDevice.current.systemName,
//            systemVersion: UIDevice.current.systemVersion,
//            deviceModel: UIDevice.current.model,
//            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown",
//            appBuild: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
//        )
//    }
//}
//
//struct PerformanceProfile: Codable {
//    let name: String
//    let startTime: Date
//    var endTime: Date
//    var metrics: PerformanceMetrics
//    
//    var duration: TimeInterval {
//        return endTime.timeIntervalSince(startTime)
//    }
//}
//
//// MARK: - 存储类
//final class CrashStorage {
//    private let fileManager = FileManager.default
//    private let decoder = JSONDecoder()
//    private let encoder = JSONEncoder()
//    
//    private var crashesDirectory: URL {
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls[0].appendingPathComponent("crashes")
//    }
//    
//    init() {
//        createDirectoryIfNeeded()
//    }
//    
//    func saveReport(_ report: CrashReport) {
//        do {
//            let data = try encoder.encode(report)
//            let fileURL = crashesDirectory.appendingPathComponent("\(report.timestamp.timeIntervalSince1970).crash")
//            try data.write(to: fileURL)
//        } catch {
//            print("Failed to save crash report: \(error)")
//        }
//    }
//    
//    func loadReports() -> [CrashReport] {
//        var reports: [CrashReport] = []
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(at: crashesDirectory, includingPropertiesForKeys: nil)
//            for file in files {
//                if let data = try? Data(contentsOf: file),
//                   let report = try? decoder.decode(CrashReport.self, from: data) {
//                    reports.append(report)
//                }
//            }
//        } catch {
//            print("Failed to load crash reports: \(error)")
//        }
//        
//        return reports.sorted { $0.timestamp > $1.timestamp }
//    }
//    
//    func clearReports() {
//        do {
//            let files = try fileManager.contentsOfDirectory(at: crashesDirectory, includingPropertiesForKeys: nil)
//            for file in files {
//                try fileManager.removeItem(at: file)
//            }
//        } catch {
//            print("Failed to clear crash reports: \(error)")
//        }
//    }
//    
//    private func createDirectoryIfNeeded() {
//        do {
//            try fileManager.createDirectory(at: crashesDirectory, withIntermediateDirectories: true)
//        } catch {
//            print("Failed to create crashes directory: \(error)")
//        }
//    }
//}
