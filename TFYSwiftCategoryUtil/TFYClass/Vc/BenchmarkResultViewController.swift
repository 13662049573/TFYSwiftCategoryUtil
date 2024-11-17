////
////  BenchmarkResultViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 性能基准测试结果视图控制器
//final class BenchmarkResultViewController: UIViewController {
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
//    private lazy var scoreView: ScoreCardView = {
//        let view = ScoreCardView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var comparisonChart: ComparisonChartView = {
//        let chart = ComparisonChartView()
//        chart.translatesAutoresizingMaskIntoConstraints = false
//        return chart
//    }()
//    
//    private lazy var metricsTable: MetricsTableView = {
//        let table = MetricsTableView()
//        table.translatesAutoresizingMaskIntoConstraints = false
//        return table
//    }()
//    
//    private lazy var shareButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Share Results", for: .normal)
//        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // MARK: - 属性
//    private let result: BenchmarkResult
//    private let previousResults: [BenchmarkResult]
//    
//    // MARK: - 初始化
//    init(result: BenchmarkResult, previousResults: [BenchmarkResult] = []) {
//        self.result = result
//        self.previousResults = previousResults
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
//        updateUI()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Benchmark Results"
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(stackView)
//        
//        [scoreView, comparisonChart, metricsTable, shareButton].forEach {
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
//            scoreView.heightAnchor.constraint(equalToConstant: 150),
//            comparisonChart.heightAnchor.constraint(equalToConstant: 200),
//            metricsTable.heightAnchor.constraint(equalToConstant: 300)
//        ])
//    }
//    
//    private func updateUI() {
//        // 更新分数卡片
//        scoreView.configure(with: result)
//        
//        // 更新比较图表
//        let comparisonData = ComparisonChartData(
//            currentResult: result,
//            previousResults: previousResults,
//            baseline: result.baseline
//        )
//        comparisonChart.update(with: comparisonData)
//        
//        // 更新指标表格
//        metricsTable.update(with: result.metrics)
//    }
//    
//    // MARK: - 动作处理
//    @objc private func shareButtonTapped() {
//        let report = generateReport()
//        let activityVC = UIActivityViewController(
//            activityItems: [report],
//            applicationActivities: nil
//        )
//        present(activityVC, animated: true)
//    }
//    
//    // MARK: - 报告生成
//    private func generateReport() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .medium
//        
//        var report = """
//        Benchmark Results
//        ================
//        Type: \(result.type)
//        Date: \(dateFormatter.string(from: result.timestamp))
//        Duration: \(String(format: "%.2f seconds", result.duration))
//        
//        Score: \(String(format: "%.2f", result.score))
//        """
//        
//        if let baseline = result.baseline {
//            report += "\nBaseline: \(String(format: "%.2f", baseline))"
//            if let deviation = result.deviation {
//                report += "\nDeviation: \(String(format: "%.1f%%", deviation))"
//            }
//        }
//        
//        report += "\n\nPerformance Metrics\n------------------\n"
//        report += "CPU Usage: \(MetricsFormatter.formatCPU(result.metrics.cpuUsage))\n"
//        report += "Memory Usage: \(MetricsFormatter.formatMemory(result.metrics.memoryUsage))\n"
//        report += "FPS: \(MetricsFormatter.formatFPS(result.metrics.fps))\n"
//        report += "Network Throughput: \(MetricsFormatter.formatNetwork(result.metrics.networkThroughput))"
//        
//        return report
//    }
//}
//
//// MARK: - 分数卡片视图（续）
//final class ScoreCardView: UIView {
//    
//    // MARK: - UI组件
//    private lazy var scoreLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .monospacedSystemFont(ofSize: 48, weight: .bold)
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private lazy var typeLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private lazy var deviationLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14)
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private lazy var backgroundView: UIVisualEffectView = {
//        let blur = UIBlurEffect(style: .systemMaterial)
//        let view = UIVisualEffectView(effect: blur)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.layer.masksToBounds = true
//        return view
//    }()
//    
//    // MARK: - 初始化
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        addSubview(backgroundView)
//        [scoreLabel, typeLabel, deviationLabel].forEach {
//            backgroundView.contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            backgroundView.topAnchor.constraint(equalTo: topAnchor),
//            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            
//            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
//            
//            typeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            typeLabel.bottomAnchor.constraint(equalTo: scoreLabel.topAnchor, constant: -8),
//            
//            deviationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            deviationLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8)
//        ])
//    }
//    
//    // MARK: - 配置
//    func configure(with result: BenchmarkResult) {
//        scoreLabel.text = String(format: "%.0f", result.score)
//        typeLabel.text = String(describing: result.type).uppercased()
//        
//        if let deviation = result.deviation {
//            let isImprovement = deviation > 0
//            deviationLabel.text = String(format: "%@%.1f%%",
//                                       isImprovement ? "+" : "",
//                                       deviation)
//            deviationLabel.textColor = isImprovement ? .systemGreen : .systemRed
//        } else {
//            deviationLabel.text = "No Baseline"
//            deviationLabel.textColor = .secondaryLabel
//        }
//    }
//}
//
//// MARK: - 比较图表视图
//final class ComparisonChartView: UIView {
//    
//    // MARK: - 数据模型
//    struct ChartData {
//        let currentResult: BenchmarkResult
//        let previousResults: [BenchmarkResult]
//        let baseline: Double?
//    }
//    
//    // MARK: - UI组件
//    private let chartLayer = CAShapeLayer()
//    private let baselineLayer = CAShapeLayer()
//    private let gridLayer = CAShapeLayer()
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.text = "Performance Trend"
//        return label
//    }()
//    
//    // MARK: - 初始化
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        layer.addSublayer(gridLayer)
//        layer.addSublayer(baselineLayer)
//        layer.addSublayer(chartLayer)
//        
//        addSubview(titleLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
//        ])
//        
//        setupLayers()
//    }
//    
//    private func setupLayers() {
//        gridLayer.strokeColor = UIColor.systemGray5.cgColor
//        gridLayer.lineWidth = 0.5
//        
//        baselineLayer.strokeColor = UIColor.systemGray.cgColor
//        baselineLayer.lineWidth = 1
//        baselineLayer.lineDashPattern = [4, 4]
//        
//        chartLayer.fillColor = nil
//        chartLayer.strokeColor = UIColor.systemBlue.cgColor
//        chartLayer.lineWidth = 2
//    }
//    
//    // MARK: - 更新
//    func update(with data: ChartData) {
//        let chartRect = CGRect(
//            x: 0,
//            y: titleLabel.frame.maxY + 16,
//            width: bounds.width,
//            height: bounds.height - titleLabel.frame.maxY - 16
//        )
//        
//        drawGrid(in: chartRect)
//        drawBaseline(data.baseline, in: chartRect)
//        drawChart(data, in: chartRect)
//    }
//    
//    // MARK: - 绘制方法
//    private func drawGrid(in rect: CGRect) {
//        let path = UIBezierPath()
//        
//        // 水平网格线
//        let verticalStep = rect.height / 4
//        for i in 0...4 {
//            let y = rect.minY + CGFloat(i) * verticalStep
//            path.move(to: CGPoint(x: rect.minX, y: y))
//            path.addLine(to: CGPoint(x: rect.maxX, y: y))
//        }
//        
//        // 垂直网格线
//        let horizontalStep = rect.width / 6
//        for i in 0...6 {
//            let x = rect.minX + CGFloat(i) * horizontalStep
//            path.move(to: CGPoint(x: x, y: rect.minY))
//            path.addLine(to: CGPoint(x: x, y: rect.maxY))
//        }
//        
//        gridLayer.path = path.cgPath
//    }
//    
//    private func drawBaseline(_ baseline: Double?, in rect: CGRect) {
//        guard let baseline = baseline else {
//            baselineLayer.path = nil
//            return
//        }
//        
//        let path = UIBezierPath()
//        let y = rect.maxY - (CGFloat(baseline) / CGFloat(maxValue)) * rect.height
//        
//        path.move(to: CGPoint(x: rect.minX, y: y))
//        path.addLine(to: CGPoint(x: rect.maxX, y: y))
//        
//        baselineLayer.path = path.cgPath
//    }
//    
//    private func drawChart(_ data: ChartData, in rect: CGRect) {
//        let allResults = [data.currentResult] + data.previousResults
//        guard !allResults.isEmpty else {
//            chartLayer.path = nil
//            return
//        }
//        
//        let path = UIBezierPath()
//        let step = rect.width / CGFloat(allResults.count - 1)
//        
//        for (index, result) in allResults.enumerated() {
//            let x = rect.maxX - CGFloat(index) * step
//            let y = rect.maxY - (CGFloat(result.score) / CGFloat(maxValue)) * rect.height
//            
//            if index == 0 {
//                path.move(to: CGPoint(x: x, y: y))
//            } else {
//                path.addLine(to: CGPoint(x: x, y: y))
//            }
//        }
//        
//        chartLayer.path = path.cgPath
//    }
//    
//    // MARK: - 辅助属性
//    private var maxValue: Double {
//        100 // 可以根据实际数据动态调整
//    }
//}
