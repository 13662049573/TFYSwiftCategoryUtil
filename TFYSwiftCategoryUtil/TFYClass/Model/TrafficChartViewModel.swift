////
////  TrafficChartViewModel.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 图表数据模型
//struct ChartData {
//    // MARK: - 数据点
//    struct DataPoint {
//        let timestamp: Date
//        let uploadValue: Double
//        let downloadValue: Double
//        
//        var totalValue: Double {
//            uploadValue + downloadValue
//        }
//    }
//    
//    // MARK: - 属性
//    let points: [DataPoint]
//    let period: StatsPeriod
//    let maxValue: Double
//    let minValue: Double
//    let averageValue: Double
//    
//    var timeLabels: [String] {
//        let formatter = DateFormatter()
//        switch period {
//        case .hour:
//            formatter.dateFormat = "HH:mm"
//        case .day:
//            formatter.dateFormat = "HH:00"
//        case .week:
//            formatter.dateFormat = "E"
//        case .month:
//            formatter.dateFormat = "MM/dd"
//        }
//        
//        return points.map { formatter.string(from: $0.timestamp) }
//    }
//    
//    var valueLabels: [String] {
//        let formatter = ByteCountFormatter()
//        formatter.countStyle = .binary
//        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
//        
//        let values = stride(from: 0, through: maxValue, by: maxValue / 4)
//        return values.map { formatter.string(fromByteCount: Int64($0)) }
//    }
//    
//    // MARK: - 初始化
//    init(points: [DataPoint], period: StatsPeriod) {
//        self.points = points
//        self.period = period
//        self.maxValue = points.map { $0.totalValue }.max() ?? 0
//        self.minValue = points.map { $0.totalValue }.min() ?? 0
//        self.averageValue = points.map { $0.totalValue }.reduce(0, +) / Double(points.count)
//    }
//}
//
//// MARK: - 流量图表视图模型
//final class TrafficChartViewModel {
//    
//    // MARK: - 可观察属性
//    let analytics = Observable<TrafficAnalytics>(TrafficAnalytics())
//    let chartData = Observable<ChartData?>(nil)
//    let error = Observable<Error?>(nil)
//    
//    // MARK: - 私有属性
//    private let trafficManager = TrafficManager.shared
//    private let storage = TrafficStorage()
//    private var currentPeriod: StatsPeriod = .hour
//    private var timer: Timer?
//    
//    // MARK: - 初始化
//    init() {
//        setupTimer()
//    }
//    
//    deinit {
//        timer?.invalidate()
//    }
//    
//    // MARK: - 公共方法
//    func loadData(for period: StatsPeriod) {
//        currentPeriod = period
//        
//        // 加载统计数据
//        let stats = storage.getStats(for: period)
//        let analytics = storage.getAggregatedStats(for: period)
//        self.analytics.value = analytics
//        
//        // 转换为图表数据
//        let points = convertToDataPoints(stats)
//        let chartData = ChartData(points: points, period: period)
//        self.chartData.value = chartData
//    }
//    
//    func updateCurrentStats(_ stats: TrafficStats) {
//        // 仅在查看小时数据时更新实时数据
//        guard currentPeriod == .hour else { return }
//        
//        var points = chartData.value?.points ?? []
//        let newPoint = ChartData.DataPoint(
//            timestamp: stats.timestamp,
//            uploadValue: Double(stats.uploadSpeed),
//            downloadValue: Double(stats.downloadSpeed)
//        )
//        
//        // 移除超过时间范围的数据点
//        let cutoffDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
//        points = points.filter { $0.timestamp > cutoffDate }
//        
//        // 添加新数据点
//        points.append(newPoint)
//        
//        // 更新图表数据
//        let chartData = ChartData(points: points, period: .hour)
//        self.chartData.value = chartData
//    }
//    
//    // MARK: - 私有方法
//    private func setupTimer() {
//        // 每分钟更新一次数据
//        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            self.loadData(for: self.currentPeriod)
//        }
//    }
//    
//    private func convertToDataPoints(_ stats: [TrafficStats]) -> [ChartData.DataPoint] {
//        return stats.map { stat in
//            ChartData.DataPoint(
//                timestamp: stat.timestamp,
//                uploadValue: Double(stat.uploadBytes),
//                downloadValue: Double(stat.downloadBytes)
//            )
//        }
//    }
//    
//    private func aggregateDataPoints(_ points: [ChartData.DataPoint], by interval: TimeInterval) -> [ChartData.DataPoint] {
//        guard !points.isEmpty else { return [] }
//        
//        var aggregatedPoints: [ChartData.DataPoint] = []
//        var currentInterval = points.first!.timestamp
//        var uploadSum: Double = 0
//        var downloadSum: Double = 0
//        var count = 0
//        
//        for point in points {
//            if point.timestamp.timeIntervalSince(currentInterval) < interval {
//                uploadSum += point.uploadValue
//                downloadSum += point.downloadValue
//                count += 1
//            } else {
//                if count > 0 {
//                    let averagePoint = ChartData.DataPoint(
//                        timestamp: currentInterval,
//                        uploadValue: uploadSum / Double(count),
//                        downloadValue: downloadSum / Double(count)
//                    )
//                    aggregatedPoints.append(averagePoint)
//                }
//                
//                currentInterval = point.timestamp
//                uploadSum = point.uploadValue
//                downloadSum = point.downloadValue
//                count = 1
//            }
//        }
//        
//        // 添加最后一个区间的数据
//        if count > 0 {
//            let averagePoint = ChartData.DataPoint(
//                timestamp: currentInterval,
//                uploadValue: uploadSum / Double(count),
//                downloadValue: downloadSum / Double(count)
//            )
//            aggregatedPoints.append(averagePoint)
//        }
//        
//        return aggregatedPoints
//    }
//    
//    private func getAggregationInterval(for period: StatsPeriod) -> TimeInterval {
//        switch period {
//        case .hour:
//            return 60 // 1分钟
//        case .day:
//            return 3600 // 1小时
//        case .week:
//            return 86400 // 1天
//        case .month:
//            return 86400 // 1天
//        }
//    }
//}
//
//// MARK: - 时间周期扩展
//extension StatsPeriod {
//    init?(rawValue: Int) {
//        switch rawValue {
//        case 0: self = .hour
//        case 1: self = .day
//        case 2: self = .week
//        case 3: self = .month
//        default: return nil
//        }
//    }
//    
//    var title: String {
//        switch self {
//        case .hour: return "Hour"
//        case .day: return "Day"
//        case .week: return "Week"
//        case .month: return "Month"
//        }
//    }
//}
