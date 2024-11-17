////
////  TrafficStorage.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//
//// MARK: - 流量数据存储
//final class TrafficStorage {
//    
//    // MARK: - 属性
//    private let queue = DispatchQueue(label: "com.tfy.ssr.storage", qos: .utility)
//    private let fileManager = FileManager.default
//    private let decoder = JSONDecoder()
//    private let encoder = JSONEncoder()
//    
//    private var storageURL: URL {
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls[0].appendingPathComponent("traffic_stats")
//    }
//    
//    // MARK: - 初始化
//    init() {
//        createStorageDirectoryIfNeeded()
//    }
//    
//    // MARK: - 公共方法
//    func saveStats(_ stats: TrafficStats) {
//        queue.async {
//            self.saveStatsToFile(stats)
//            self.cleanupOldStats()
//        }
//    }
//    
//    func getStats(for period: StatsPeriod) -> [TrafficStats] {
//        queue.sync {
//            let cutoffDate = getCutoffDate(for: period)
//            return loadStats(since: cutoffDate)
//        }
//    }
//    
//    func getAggregatedStats(for period: StatsPeriod) -> TrafficAnalytics {
//        queue.sync {
//            let stats = getStats(for: period)
//            return analyzeStats(stats)
//        }
//    }
//    
//    // MARK: - 私有方法
//    private func createStorageDirectoryIfNeeded() {
//        do {
//            try fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
//        } catch {
//            print("Failed to create storage directory: \(error)")
//        }
//    }
//    
//    private func saveStatsToFile(_ stats: TrafficStats) {
//        let fileName = getFileName(for: stats.timestamp)
//        let fileURL = storageURL.appendingPathComponent(fileName)
//        
//        do {
//            let data = try encoder.encode(stats)
//            try data.write(to: fileURL)
//        } catch {
//            print("Failed to save stats: \(error)")
//        }
//    }
//    
//    private func loadStats(since date: Date) -> [TrafficStats] {
//        var stats: [TrafficStats] = []
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(at: storageURL, includingPropertiesForKeys: [.creationDateKey])
//            
//            for file in files {
//                guard let creationDate = try file.resourceValues(forKeys: [.creationDateKey]).creationDate,
//                      creationDate >= date else {
//                    continue
//                }
//                
//                if let data = try? Data(contentsOf: file),
//                   let stat = try? decoder.decode(TrafficStats.self, from: data) {
//                    stats.append(stat)
//                }
//            }
//        } catch {
//            print("Failed to load stats: \(error)")
//        }
//        
//        return stats.sorted { $0.timestamp < $1.timestamp }
//    }
//    
//    private func cleanupOldStats() {
//        let cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(at: storageURL, includingPropertiesForKeys: [.creationDateKey])
//            
//            for file in files {
//                guard let creationDate = try file.resourceValues(forKeys: [.creationDateKey]).creationDate,
//                      creationDate < cutoffDate else {
//                    continue
//                }
//                
//                try fileManager.removeItem(at: file)
//            }
//        } catch {
//            print("Failed to cleanup old stats: \(error)")
//        }
//    }
//    
//    private func getFileName(for date: Date) -> String {
//        let formatter = ISO8601DateFormatter()
//        return formatter.string(from: date) + ".json"
//    }
//    
//    private func getCutoffDate(for period: StatsPeriod) -> Date {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        switch period {
//        case .hour:
//            return calendar.date(byAdding: .hour, value: -1, to: now) ?? now
//        case .day:
//            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
//        case .week:
//            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
//        case .month:
//            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
//        }
//    }
//    
//    private func analyzeStats(_ stats: [TrafficStats]) -> TrafficAnalytics {
//        var analytics = TrafficAnalytics()
//        
//        guard !stats.isEmpty else { return analytics }
//        
//        // 计算总流量
//        analytics.totalUpload = stats.reduce(0) { $0 + $1.uploadBytes }
//        analytics.totalDownload = stats.reduce(0) { $0 + $1.downloadBytes }
//        
//        // 计算平均速度
//        analytics.averageUploadSpeed = stats.reduce(0.0) { $0 + $1.uploadSpeed } / Double(stats.count)
//        analytics.averageDownloadSpeed = stats.reduce(0.0) { $0 + $1.downloadSpeed } / Double(stats.count)
//        
//        // 计算峰值速度
//        analytics.peakUploadSpeed = stats.map { $0.uploadSpeed }.max() ?? 0
//        analytics.peakDownloadSpeed = stats.map { $0.downloadSpeed }.max() ?? 0
//        
//        // 计算使用时长
//        if let firstDate = stats.first?.timestamp,
//           let lastDate = stats.last?.timestamp {
//            analytics.duration = lastDate.timeIntervalSince(firstDate)
//        }
//        
//        // 计算每小时使用情况
//        var hourlyUsage: [Int: Int64] = [:]
//        for stat in stats {
//            let hour = Calendar.current.component(.hour, from: stat.timestamp)
//            hourlyUsage[hour, default: 0] += stat.uploadBytes + stat.downloadBytes
//        }
//        analytics.hourlyUsage = hourlyUsage
//        
//        return analytics
//    }
//}
//
//// MARK: - 流量分析模型
//struct TrafficAnalytics {
//    var totalUpload: Int64 = 0
//    var totalDownload: Int64 = 0
//    var averageUploadSpeed: Double = 0
//    var averageDownloadSpeed: Double = 0
//    var peakUploadSpeed: Double = 0
//    var peakDownloadSpeed: Double = 0
//    var duration: TimeInterval = 0
//    var hourlyUsage: [Int: Int64] = [:]
//    
//    // 获取可读性好的流量数据
//    var readableTotalUpload: String {
//        ByteCountFormatter.string(fromByteCount: totalUpload, countStyle: .file)
//    }
//    
//    var readableTotalDownload: String {
//        ByteCountFormatter.string(fromByteCount: totalDownload, countStyle: .file)
//    }
//    
//    var readableAverageUploadSpeed: String {
//        ByteCountFormatter.string(fromByteCount: Int64(averageUploadSpeed), countStyle: .file) + "/s"
//    }
//    
//    var readableAverageDownloadSpeed: String {
//        ByteCountFormatter.string(fromByteCount: Int64(averageDownloadSpeed), countStyle: .file) + "/s"
//    }
//    
//    var readablePeakUploadSpeed: String {
//        ByteCountFormatter.string(fromByteCount: Int64(peakUploadSpeed), countStyle: .file) + "/s"
//    }
//    
//    var readablePeakDownloadSpeed: String {
//        ByteCountFormatter.string(fromByteCount: Int64(peakDownloadSpeed), countStyle: .file) + "/s"
//    }
//    
//    var readableDuration: String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.day, .hour, .minute]
//        formatter.unitsStyle = .full
//        return formatter.string(from: duration) ?? "Unknown"
//    }
//    
//    // 获取高峰使用时段
//    var peakHours: [Int] {
//        guard !hourlyUsage.isEmpty else { return [] }
//        let maxUsage = hourlyUsage.values.max() ?? 0
//        return hourlyUsage.filter { $0.value == maxUsage }.map { $0.key }
//    }
//}
