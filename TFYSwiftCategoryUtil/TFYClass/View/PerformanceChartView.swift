////
////  PerformanceChartView.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 性能图表视图
//final class PerformanceChartView: UIView {
//    
//    // MARK: - UI组件
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .label
//        return label
//    }()
//    
//    private lazy var valueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.textColor = .label
//        return label
//    }()
//    
//    private lazy var chartView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .systemBackground
//        view.layer.cornerRadius = 8
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.systemGray5.cgColor
//        return view
//    }()
//    
//    private let graphLayer = CAShapeLayer()
//    private let gradientLayer = CAGradientLayer()
//    
//    // MARK: - 属性
//    private var dataPoints: [Double] = []
//    private let maxDataPoints = 60
//    private var formatter: (Double) -> String
//    
//    // MARK: - 初始化
//    init(title: String, formatter: @escaping (Double) -> String = { String(format: "%.1f", $0) }) {
//        self.formatter = formatter
//        super.init(frame: .zero)
//        titleLabel.text = title
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//        addSubview(chartView)
//        
//        chartView.layer.addSublayer(gradientLayer)
//        chartView.layer.addSublayer(graphLayer)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            
//            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            
//            chartView.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
//            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            chartView.heightAnchor.constraint(equalToConstant: 100),
//            chartView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//        
//        setupGradient()
//    }
//    
//    private func setupGradient() {
//        gradientLayer.colors = [
//            UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
//            UIColor.systemBlue.withAlphaComponent(0.1).cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
//    }
//    
//    // MARK: - 布局
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        gradientLayer.frame = chartView.bounds
//        updateChart()
//    }
//    
//    // MARK: - 数据更新
//    func update(with value: Double) {
//        dataPoints.append(value)
//        if dataPoints.count > maxDataPoints {
//            dataPoints.removeFirst()
//        }
//        
//        valueLabel.text = formatter(value)
//        updateChart()
//    }
//    
//    func update(with values: [Double]) {
//        dataPoints = values.suffix(maxDataPoints)
//        if let lastValue = values.last {
//            valueLabel.text = formatter(lastValue)
//        }
//        updateChart()
//    }
//    
//    // MARK: - 图表绘制
//    private func updateChart() {
//        guard !dataPoints.isEmpty else { return }
//        
//        let width = chartView.bounds.width
//        let height = chartView.bounds.height
//        let path = UIBezierPath()
//        let maxValue = dataPoints.max() ?? 1
//        
//        // 移动到第一个点
//        let firstPoint = CGPoint(
//            x: 0,
//            y: height - CGFloat(dataPoints[0] / maxValue) * height
//        )
//        path.move(to: firstPoint)
//        
//        // 绘制线段
//        for (index, value) in dataPoints.enumerated() {
//            let point = CGPoint(
//                x: CGFloat(index) / CGFloat(maxDataPoints - 1) * width,
//                y: height - CGFloat(value / maxValue) * height
//            )
//            path.addLine(to: point)
//        }
//        
//        // 添加渐变区域
//        path.addLine(to: CGPoint(x: width, y: height))
//        path.addLine(to: CGPoint(x: 0, y: height))
//        path.close()
//        
//        // 更新图层
//        graphLayer.path = path.cgPath
//        graphLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.1).cgColor
//        graphLayer.strokeColor = UIColor.systemBlue.cgColor
//        graphLayer.lineWidth = 2
//        
//        gradientLayer.frame = chartView.bounds
//    }
//}
//
//// MARK: - 网络统计视图
//final class NetworkStatsView: UIView {
//    
//    // MARK: - UI组件
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .horizontal
//        stack.distribution = .fillEqually
//        stack.spacing = 16
//        return stack
//    }()
//    
//    private lazy var requestsLabel = StatsItemView(title: "Requests")
//    private lazy var successLabel = StatsItemView(title: "Success")
//    private lazy var errorLabel = StatsItemView(title: "Errors")
//    private lazy var avgTimeLabel = StatsItemView(title: "Avg Time")
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
//        backgroundColor = .secondarySystemBackground
//        layer.cornerRadius = 8
//        
//        addSubview(stackView)
//        
//        [requestsLabel, successLabel, errorLabel, avgTimeLabel].forEach {
//            stackView.addArrangedSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
//        ])
//    }
//    
//    // MARK: - 数据更新
//    func update(with stats: NetworkStats) {
//        requestsLabel.setValue("\(stats.totalRequests)")
//        successLabel.setValue("\(stats.successRequests)")
//        errorLabel.setValue("\(stats.errorRequests)")
//        avgTimeLabel.setValue(String(format: "%.2fs", stats.averageTime))
//    }
//}
//
//// MARK: - 统计项视图
//final class StatsItemView: UIView {
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 12)
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private lazy var valueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        label.textAlignment = .center
//        return label
//    }()
//    
//    init(title: String) {
//        super.init(frame: .zero)
//        titleLabel.text = title
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//            
//            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//    
//    func setValue(_ value: String) {
//        valueLabel.text = value
//    }
//}
