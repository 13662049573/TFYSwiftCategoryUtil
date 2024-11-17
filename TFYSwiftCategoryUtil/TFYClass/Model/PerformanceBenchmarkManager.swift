////
////  PerformanceBenchmarkManager.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 性能基准测试管理器
//final class PerformanceBenchmarkManager {
//    
//    // MARK: - 基准测试类型
//    enum BenchmarkType {
//        case cpu
//        case memory
//        case graphics
//        case network
//        case diskIO
//        case database
//    }
//    
//    // MARK: - 基准测试结果
//    struct BenchmarkResult {
//        let type: BenchmarkType
//        let score: Double
//        let metrics: PerformanceMetrics
//        let timestamp: Date
//        let duration: TimeInterval
//        let baseline: Double?
//        
//        var deviation: Double? {
//            guard let baseline = baseline else { return nil }
//            return ((score - baseline) / baseline) * 100
//        }
//    }
//    
//    // MARK: - 属性
//    private let performanceManager = PerformanceManager.shared
//    private var currentTest: BenchmarkType?
//    private var startTime: Date?
//    private var baselineScores: [BenchmarkType: Double] = [:]
//    
//    // MARK: - 公共方法
//    func runBenchmark(_ type: BenchmarkType, completion: @escaping (BenchmarkResult) -> Void) {
//        guard currentTest == nil else {
//            print("Another benchmark is already running")
//            return
//        }
//        
//        currentTest = type
//        startTime = Date()
//        
//        // 开始性能监控
//        performanceManager.startMonitoring()
//        
//        // 执行相应的基准测试
//        switch type {
//        case .cpu:
//            runCPUBenchmark(completion: completion)
//        case .memory:
//            runMemoryBenchmark(completion: completion)
//        case .graphics:
//            runGraphicsBenchmark(completion: completion)
//        case .network:
//            runNetworkBenchmark(completion: completion)
//        case .diskIO:
//            runDiskIOBenchmark(completion: completion)
//        case .database:
//            runDatabaseBenchmark(completion: completion)
//        }
//    }
//    
//    func setBaseline(_ score: Double, for type: BenchmarkType) {
//        baselineScores[type] = score
//    }
//    
//    func getBaseline(for type: BenchmarkType) -> Double? {
//        return baselineScores[type]
//    }
//    
//    // MARK: - 私有基准测试方法
//    private func runCPUBenchmark(completion: @escaping (BenchmarkResult) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            // CPU密集型操作
//            var score = 0.0
//            
//            // 矩阵运算测试
//            let size = 200
//            var matrix1 = Array(repeating: Array(repeating: Double.random(in: 0...1), count: size), count: size)
//            var matrix2 = Array(repeating: Array(repeating: Double.random(in: 0...1), count: size), count: size)
//            
//            let startTime = CACurrentMediaTime()
//            
//            // 执行矩阵乘法
//            for i in 0..<size {
//                for j in 0..<size {
//                    var sum = 0.0
//                    for k in 0..<size {
//                        sum += matrix1[i][k] * matrix2[k][j]
//                    }
//                    score += sum
//                }
//            }
//            
//            let duration = CACurrentMediaTime() - startTime
//            score = 1000000.0 / duration // 标准化分数
//            
//            self.finishBenchmark(score: score, completion: completion)
//        }
//    }
//    
//    private func runMemoryBenchmark(completion: @escaping (BenchmarkResult) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            var score = 0.0
//            let iterations = 1000
//            
//            let startTime = CACurrentMediaTime()
//            
//            // 内存分配和释放测试
//            for _ in 0..<iterations {
//                autoreleasepool {
//                    var array = [Data]()
//                    for _ in 0..<1000 {
//                        let data = Data(count: 1024) // 1KB
//                        array.append(data)
//                    }
//                    score += Double(array.count)
//                }
//            }
//            
//            let duration = CACurrentMediaTime() - startTime
//            score = Double(iterations) / duration
//            
//            self.finishBenchmark(score: score, completion: completion)
//        }
//    }
//    
//    private func runGraphicsBenchmark(completion: @escaping (BenchmarkResult) -> Void) {
//        let size = CGSize(width: 1024, height: 1024)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let startTime = CACurrentMediaTime()
//            var score = 0.0
//            
//            // 图形渲染测试
//            for _ in 0..<100 {
//                autoreleasepool {
//                    let image = renderer.image { context in
//                        for _ in 0..<100 {
//                            let rect = CGRect(
//                                x: CGFloat.random(in: 0...size.width),
//                                y: CGFloat.random(in: 0...size.height),
//                                width: CGFloat.random(in: 10...100),
//                                height: CGFloat.random(in: 10...100)
//                            )
//                            
//                            context.cgContext.setFillColor(
//                                UIColor(
//                                    red: .random(in: 0...1),
//                                    green: .random(in: 0...1),
//                                    blue: .random(in: 0...1),
//                                    alpha: 1
//                                ).cgColor
//                            )
//                            context.fill(rect)
//                        }
//                    }
//                    score += Double(image.scale)
//                }
//            }
//            
//            let duration = CACurrentMediaTime() - startTime
//            score = score / duration
//            
//            self.finishBenchmark(score: score, completion: completion)
//        }
//    }
//    
//    // MARK: - 辅助方法
//    private func finishBenchmark(score: Double, completion: @escaping (BenchmarkResult) -> Void) {
//        guard let type = currentTest, let startTime = startTime else { return }
//        
//        let duration = Date().timeIntervalSince(startTime)
//        let metrics = performanceManager.getCurrentMetrics()
//        
//        performanceManager.stopMonitoring()
//        
//        let result = BenchmarkResult(
//            type: type,
//            score: score,
//            metrics: metrics,
//            timestamp: Date(),
//            duration: duration,
//            baseline: getBaseline(for: type)
//        )
//        
//        currentTest = nil
//        self.startTime = nil
//        
//        DispatchQueue.main.async {
//            completion(result)
//        }
//    }
//}
