////
////  PerformanceProfileDetailViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 性能分析详情视图控制器
//final class PerformanceProfileDetailViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var scrollView: UIScrollView = {
//        let scroll = UIScrollView()
//        scroll.translatesAutoresizingMaskIntoConstraints = false
//        return scroll
//    }()
//    
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.spacing = 20
//        return stack
//    }()
//    
//    private lazy var summarySection = DetailSection(title: "Summary")
//    private lazy var metricsSection = DetailSection(title: "Performance Metrics")
//    
//    private lazy var cpuChart = PerformanceChartView(
//        title: "CPU Usage",
//        formatter: { String(format: "%.1f%%", $0) }
//    )
//    
//    private lazy var memoryChart = PerformanceChartView(
//        title: "Memory Usage",
//        formatter: { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .memory) }
//    )
//    
//    private lazy var fpsChart = PerformanceChartView(
//        title: "FPS",
//        formatter: { String(format: "%.1f", $0) }
//    )
//    
//    private lazy var networkChart = PerformanceChartView(
//        title: "Network Throughput",
//        formatter: { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .binary) + "/s" }
//    )
//    
//    // MARK: - 属性
//    private let profile: PerformanceProfile
//    private let analyzer = PerformanceAnalyzer()
//    
//    // MARK: - 初始化
//    init(profile: PerformanceProfile) {
//        self.profile = profile
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupData()
//        analyzePerformance()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Performance Analysis"
//        view.backgroundColor = .systemBackground
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "square.and.arrow.up"),
//            style: .plain,
//            target: self,
//            action: #selector(shareButtonTapped)
//        )
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(stackView)
//        
//        [summarySection, metricsSection, cpuChart, memoryChart, fpsChart, networkChart].forEach {
//            stackView.addArrangedSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
//            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
//            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
//            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
//            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
//        ])
//    }
//    
//    // MARK: - 数据设置
//    private func setupData() {
//        // 概要信息
//        summarySection.addRow(title: "Name", value: profile.name)
//        summarySection.addRow(title: "Duration", value: formatDuration(profile.duration))
//        summarySection.addRow(title: "Start Time", value: formatDate(profile.startTime))
//        summarySection.addRow(title: "End Time", value: formatDate(profile.endTime))
//        
//        // 性能指标
//        metricsSection.addRow(title: "Average CPU", value: profile.metrics.formattedCPUUsage)
//        metricsSection.addRow(title: "Peak Memory", value: profile.metrics.formattedMemoryUsage)
//        metricsSection.addRow(title: "Average FPS", value: profile.metrics.formattedFPS)
//        metricsSection.addRow(title: "Network", value: profile.metrics.formattedNetworkThroughput)
//        
//        // 更新图表
//        updateCharts()
//    }
//    
//    // MARK: - 性能分析
//    private func analyzePerformance() {
//        let analysis = analyzer.analyze(profile)
//        
//        if !analysis.isEmpty {
//            let analysisSection = DetailSection(title: "Analysis")
//            stackView.insertArrangedSubview(analysisSection, at: 1)
//            
//            analysis.forEach { item in
//                analysisSection.addRow(
//                    title: item.severity.icon,
//                    value: item.message,
//                    valueColor: item.severity.color
//                )
//            }
//        }
//    }
//    
//    // MARK: - 辅助方法
//    private func formatDuration(_ duration: TimeInterval) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second, .nanosecond]
//        formatter.unitsStyle = .abbreviated
//        return formatter.string(from: duration) ?? "Unknown"
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return formatter.string(from: date)
//    }
//    
//    private func updateCharts() {
//        // 这里应该从性能数据中获取时间序列数据
//        // 为了演示，我们使用模拟数据
//        let timePoints = 60
//        let cpuData = (0..<timePoints).map { _ in Double.random(in: 0...100) }
//        let memoryData = (0..<timePoints).map { _ in Double.random(in: 100_000_000...500_000_000) }
//        let fpsData = (0..<timePoints).map { _ in Double.random(in: 30...60) }
//        let networkData = (0..<timePoints).map { _ in Double.random(in: 0...1_000_000) }
//        
//        cpuChart.update(with: cpuData)
//        memoryChart.update(with: memoryData)
//        fpsChart.update(with: fpsData)
//        networkChart.update(with: networkData)
//    }
//    
//    // MARK: - 动作处理
//    @objc private func shareButtonTapped() {
//        let text = """
//        Performance Profile: \(profile.name)
//        
//        Duration: \(formatDuration(profile.duration))
//        Start Time: \(formatDate(profile.startTime))
//        End Time: \(formatDate(profile.endTime))
//        
//        Performance Metrics:
//        CPU Usage: \(profile.metrics.formattedCPUUsage)
//        Memory Usage: \(profile.metrics.formattedMemoryUsage)
//        FPS: \(profile.metrics.formattedFPS)
//        Network Throughput: \(profile.metrics.formattedNetworkThroughput)
//        """
//        
//        let activityVC = UIActivityViewController(
//            activityItems: [text],
//            applicationActivities: nil
//        )
//        present(activityVC, animated: true)
//    }
//}
