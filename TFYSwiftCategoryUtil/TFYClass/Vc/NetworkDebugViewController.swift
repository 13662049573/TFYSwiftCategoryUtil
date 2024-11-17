////
////  NetworkDebugViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 网络调试视图控制器
//final class NetworkDebugViewController: UIViewController, DebugSharable {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .plain)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(NetworkRequestCell.self, forCellReuseIdentifier: "NetworkRequestCell")
//        return table
//    }()
//    
//    private lazy var statsView: NetworkStatsView = {
//        let view = NetworkStatsView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    // MARK: - 属性
//    private var requests: [NetworkRequest] = []
//    private var networkObserver: UUID?
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupObservers()
//    }
//    
//    deinit {
//        if let observer = networkObserver {
//            NetworkDebugger.shared.removeObserver(observer)
//        }
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(statsView)
//        view.addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            statsView.topAnchor.constraint(equalTo: view.topAnchor),
//            statsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            statsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            statsView.heightAnchor.constraint(equalToConstant: 100),
//            
//            tableView.topAnchor.constraint(equalTo: statsView.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - 观察者设置
//    private func setupObservers() {
//        networkObserver = NetworkDebugger.shared.addObserver { [weak self] request in
//            self?.requests.insert(request, at: 0)
//            self?.updateStats()
//            self?.tableView.reloadData()
//        }
//    }
//    
//    // MARK: - 数据处理
//    private func updateStats() {
//        let stats = NetworkStats(requests: requests)
//        statsView.update(with: stats)
//    }
//    
//    // MARK: - 公共方法
//    func clearData() {
//        requests.removeAll()
//        updateStats()
//        tableView.reloadData()
//    }
//    
//    func shareableData() -> Any {
//        // 将网络请求数据转换为可分享的格式
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
//        
//        let text = requests.map { request in
//            """
//            [\(formatter.string(from: request.startTime))]
//            \(request.method) \(request.url)
//            Status: \(request.statusCode ?? 0)
//            Duration: \(String(format: "%.2f", request.duration))s
//            Request Headers: \(request.requestHeaders)
//            Response Headers: \(request.responseHeaders)
//            """
//        }.joined(separator: "\n\n")
//        
//        return text
//    }
//}
//
//// MARK: - 性能监控视图控制器
//final class PerformanceDebugViewController: UIViewController, DebugSharable {
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
//        stack.spacing = 16
//        return stack
//    }()
//    
//    private lazy var cpuChart = PerformanceChartView(title: "CPU Usage")
//    private lazy var memoryChart = PerformanceChartView(title: "Memory Usage")
//    private lazy var fpsChart = PerformanceChartView(title: "FPS")
//    private lazy var networkChart = PerformanceChartView(title: "Network")
//    
//    // MARK: - 属性
//    private var performanceObserver: UUID?
//    private var updateTimer: Timer?
//    private var metrics: [PerformanceMetrics] = []
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupObservers()
//        startMonitoring()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        stopMonitoring()
//    }
//    
//    deinit {
//        if let observer = performanceObserver {
//            PerformanceManager.shared.removeObserver(observer)
//        }
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(stackView)
//        
//        [cpuChart, memoryChart, fpsChart, networkChart].forEach {
//            stackView.addArrangedSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
//    // MARK: - 监控
//    private func setupObservers() {
//        performanceObserver = PerformanceManager.shared.addObserver { [weak self] metrics in
//            self?.metrics.append(metrics)
//            self?.updateCharts()
//        }
//    }
//    
//    private func startMonitoring() {
//        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            self?.updateCharts()
//        }
//    }
//    
//    private func stopMonitoring() {
//        updateTimer?.invalidate()
//        updateTimer = nil
//    }
//    
//    private func updateCharts() {
//        // 只保留最近60秒的数据
//        let maxDataPoints = 60
//        if metrics.count > maxDataPoints {
//            metrics.removeFirst(metrics.count - maxDataPoints)
//        }
//        
//        // 更新图表
//        cpuChart.update(with: metrics.map { $0.cpuUsage })
//        memoryChart.update(with: metrics.map { Double($0.memoryUsage) })
//        fpsChart.update(with: metrics.map { Double($0.fps) })
//        networkChart.update(with: metrics.map { Double($0.networkThroughput) })
//    }
//    
//    // MARK: - 公共方法
//    func clearData() {
//        metrics.removeAll()
//        updateCharts()
//    }
//    
//    func shareableData() -> Any {
//        // 将性能数据转换为可分享的格式
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
//        
//        let text = metrics.map { metrics in
//            """
//            [\(formatter.string(from: metrics.timestamp))]
//            CPU: \(String(format: "%.1f%%", metrics.cpuUsage))
//            Memory: \(ByteCountFormatter.string(fromByteCount: Int64(metrics.memoryUsage), countStyle: .memory))
//            FPS: \(metrics.fps)
//            Network: \(ByteCountFormatter.string(fromByteCount: Int64(metrics.networkThroughput), countStyle: .binary))/s
//            """
//        }.joined(separator: "\n\n")
//        
//        return text
//    }
//}
//
//// MARK: - DebugSharable协议
//protocol DebugSharable {
//    func shareableData() -> Any
//    func clearData()
//}
