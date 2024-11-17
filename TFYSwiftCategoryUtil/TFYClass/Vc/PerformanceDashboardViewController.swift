////
////  PerformanceDashboardViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 性能监控仪表盘视图控制器
//final class PerformanceDashboardViewController: UIViewController {
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
//    private lazy var cpuGauge = GaugeView(
//        title: "CPU Usage",
//        maxValue: 100,
//        warningThreshold: 70,
//        criticalThreshold: 90,
//        unit: "%"
//    )
//    
//    private lazy var memoryGauge = GaugeView(
//        title: "Memory Usage",
//        maxValue: 1024,
//        warningThreshold: 768,
//        criticalThreshold: 896,
//        unit: "MB"
//    )
//    
//    private lazy var fpsGauge = GaugeView(
//        title: "FPS",
//        maxValue: 60,
//        warningThreshold: 45,
//        criticalThreshold: 30,
//        unit: "FPS",
//        isInverted: true
//    )
//    
//    private lazy var networkGauge = GaugeView(
//        title: "Network",
//        maxValue: 10,
//        warningThreshold: 5,
//        criticalThreshold: 8,
//        unit: "MB/s"
//    )
//    
//    private lazy var startStopButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Start Monitoring", for: .normal)
//        button.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // MARK: - 属性
//    private let performanceManager = PerformanceManager.shared
//    private var isMonitoring = false
//    private var observerId: UUID?
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        stopMonitoring()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Performance Monitor"
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(stackView)
//        
//        [cpuGauge, memoryGauge, fpsGauge, networkGauge, startStopButton].forEach {
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
//            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
//            
//            cpuGauge.heightAnchor.constraint(equalToConstant: 120),
//            memoryGauge.heightAnchor.constraint(equalToConstant: 120),
//            fpsGauge.heightAnchor.constraint(equalToConstant: 120),
//            networkGauge.heightAnchor.constraint(equalToConstant: 120)
//        ])
//    }
//    
//    // MARK: - 监控控制
//    @objc private func startStopButtonTapped() {
//        if isMonitoring {
//            stopMonitoring()
//        } else {
//            startMonitoring()
//        }
//    }
//    
//    private func startMonitoring() {
//        isMonitoring = true
//        startStopButton.setTitle("Stop Monitoring", for: .normal)
//        
//        observerId = performanceManager.addObserver { [weak self] metrics in
//            self?.updateGauges(with: metrics)
//        }
//        
//        performanceManager.startMonitoring()
//    }
//    
//    private func stopMonitoring() {
//        isMonitoring = false
//        startStopButton.setTitle("Start Monitoring", for: .normal)
//        
//        if let id = observerId {
//            performanceManager.removeObserver(id)
//            observerId = nil
//        }
//        
//        performanceManager.stopMonitoring()
//    }
//    
//    // MARK: - 数据更新
//    private func updateGauges(with metrics: PerformanceMetrics) {
//        cpuGauge.setValue(metrics.cpuUsage)
//        memoryGauge.setValue(Double(metrics.memoryUsage) / 1_000_000) // Convert to MB
//        fpsGauge.setValue(metrics.fps)
//        networkGauge.setValue(metrics.networkThroughput / 1_000_000) // Convert to MB/s
//    }
//}
//
//// MARK: - 仪表盘视图
//final class GaugeView: UIView {
//    
//    // MARK: - UI组件
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .secondaryLabel
//        return label
//    }()
//    
//    private let valueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .monospacedSystemFont(ofSize: 24, weight: .bold)
//        label.textColor = .label
//        return label
//    }()
//    
//    private let gaugeLayer = CAShapeLayer()
//    private let progressLayer = CAShapeLayer()
//    
//    // MARK: - 属性
//    private let maxValue: Double
//    private let warningThreshold: Double
//    private let criticalThreshold: Double
//    private let unit: String
//    private let isInverted: Bool
//    
//    // MARK: - 初始化
//    init(title: String, maxValue: Double, warningThreshold: Double, criticalThreshold: Double, unit: String, isInverted: Bool = false) {
//        self.maxValue = maxValue
//        self.warningThreshold = warningThreshold
//        self.criticalThreshold = criticalThreshold
//        self.unit = unit
//        self.isInverted = isInverted
//        super.init(frame: .zero)
//        
//        titleLabel.text = title
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置和更新方法在下一部分继续...
//}
//// MARK: - 仪表盘视图（续）
//extension GaugeView {
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        layer.addSublayer(gaugeLayer)
//        layer.addSublayer(progressLayer)
//        
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//            
//            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20)
//        ])
//        
//        setupLayers()
//    }
//    
//    private func setupLayers() {
//        gaugeLayer.fillColor = nil
//        gaugeLayer.strokeColor = UIColor.systemGray5.cgColor
//        gaugeLayer.lineWidth = 10
//        gaugeLayer.lineCap = .round
//        
//        progressLayer.fillColor = nil
//        progressLayer.lineWidth = 10
//        progressLayer.lineCap = .round
//    }
//    
//    // MARK: - 布局
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) * 0.35
//        
//        let startAngle = CGFloat.pi * 0.8
//        let endAngle = CGFloat.pi * 2.2
//        
//        let path = UIBezierPath(
//            arcCenter: center,
//            radius: radius,
//            startAngle: startAngle,
//            endAngle: endAngle,
//            clockwise: true
//        )
//        
//        gaugeLayer.path = path.cgPath
//        progressLayer.path = path.cgPath
//    }
//    
//    // MARK: - 值更新
//    func setValue(_ value: Double) {
//        let clampedValue = min(max(0, value), maxValue)
//        let percentage = clampedValue / maxValue
//        
//        // 更新值标签
//        valueLabel.text = String(format: "%.1f %@", clampedValue, unit)
//        
//        // 计算进度
//        let startAngle = CGFloat.pi * 0.8
//        let totalAngle = CGFloat.pi * 1.4
//        let progressAngle = startAngle + (totalAngle * CGFloat(percentage))
//        
//        // 创建动画
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = progressLayer.strokeEnd
//        animation.toValue = CGFloat(percentage)
//        animation.duration = 0.3
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        
//        // 更新进度层
//        progressLayer.strokeEnd = CGFloat(percentage)
//        progressLayer.add(animation, forKey: "progressAnimation")
//        
//        // 更新颜色
//        updateColor(for: clampedValue)
//    }
//    
//    // MARK: - 颜色更新
//    private func updateColor(for value: Double) {
//        let normalizedValue = isInverted ? maxValue - value : value
//        let color: UIColor
//        
//        if normalizedValue >= criticalThreshold {
//            color = .systemRed
//        } else if normalizedValue >= warningThreshold {
//            color = .systemYellow
//        } else {
//            color = .systemGreen
//        }
//        
//        // 创建颜色动画
//        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
//        colorAnimation.fromValue = progressLayer.strokeColor
//        colorAnimation.toValue = color.cgColor
//        colorAnimation.duration = 0.3
//        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        
//        progressLayer.strokeColor = color.cgColor
//        progressLayer.add(colorAnimation, forKey: "colorAnimation")
//        
//        // 更新值标签颜色
//        UIView.animate(withDuration: 0.3) {
//            self.valueLabel.textColor = color
//        }
//    }
//}
//
//// MARK: - 性能指标格式化工具
//struct MetricsFormatter {
//    
//    static func formatCPU(_ value: Double) -> String {
//        return String(format: "%.1f%%", value)
//    }
//    
//    static func formatMemory(_ bytes: UInt64) -> String {
//        let formatter = ByteCountFormatter()
//        formatter.countStyle = .memory
//        formatter.includesUnit = true
//        return formatter.string(fromByteCount: Int64(bytes))
//    }
//    
//    static func formatFPS(_ value: Double) -> String {
//        return String(format: "%.1f FPS", value)
//    }
//    
//    static func formatNetwork(_ bytesPerSecond: Double) -> String {
//        let formatter = ByteCountFormatter()
//        formatter.countStyle = .binary
//        formatter.includesUnit = true
//        return formatter.string(fromByteCount: Int64(bytesPerSecond)) + "/s"
//    }
//    
//    static func formatDuration(_ seconds: TimeInterval) -> String {
//        if seconds < 1 {
//            return String(format: "%.0fms", seconds * 1000)
//        } else {
//            return String(format: "%.2fs", seconds)
//        }
//    }
//}
//
//// MARK: - 性能阈值配置
//struct PerformanceThresholds {
//    // CPU阈值（百分比）
//    static let cpuWarning: Double = 70
//    static let cpuCritical: Double = 90
//    
//    // 内存阈值（字节）
//    static let memoryWarning: UInt64 = 500_000_000  // 500MB
//    static let memoryCritical: UInt64 = 1_000_000_000  // 1GB
//    
//    // FPS阈值
//    static let fpsWarning: Double = 45
//    static let fpsCritical: Double = 30
//    
//    // 网络阈值（字节/秒）
//    static let networkWarning: Double = 5_000_000  // 5MB/s
//    static let networkCritical: Double = 10_000_000  // 10MB/s
//    
//    // 响应时间阈值（秒）
//    static let responseWarning: TimeInterval = 1.0
//    static let responseCritical: TimeInterval = 3.0
//}
