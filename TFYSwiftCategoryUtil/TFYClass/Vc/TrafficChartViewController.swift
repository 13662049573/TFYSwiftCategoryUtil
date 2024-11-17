////
////  TrafficChartViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 流量统计图表视图控制器
//final class TrafficChartViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var segmentedControl: UISegmentedControl = {
//        let control = UISegmentedControl(items: ["Hour", "Day", "Week", "Month"])
//        control.translatesAutoresizingMaskIntoConstraints = false
//        control.selectedSegmentIndex = 0
//        control.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
//        return control
//    }()
//    
//    private lazy var chartView: ChartView = {
//        let view = ChartView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var statsStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.spacing = 8
//        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        stack.isLayoutMarginsRelativeArrangement = true
//        return stack
//    }()
//    
//    private lazy var uploadLabel = StatsLabel(title: "Upload")
//    private lazy var downloadLabel = StatsLabel(title: "Download")
//    private lazy var speedLabel = StatsLabel(title: "Average Speed")
//    private lazy var peakLabel = StatsLabel(title: "Peak Speed")
//    private lazy var durationLabel = StatsLabel(title: "Duration")
//    
//    // MARK: - 属性
//    private let viewModel = TrafficChartViewModel()
//    private var trafficObserver: UUID?
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupBindings()
//        loadData()
//    }
//    
//    deinit {
//        if let observer = trafficObserver {
//            TrafficManager.shared.removeObserver(observer)
//        }
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Traffic Statistics"
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(segmentedControl)
//        view.addSubview(chartView)
//        view.addSubview(statsStackView)
//        
//        [
//            uploadLabel,
//            downloadLabel,
//            speedLabel,
//            peakLabel,
//            durationLabel
//        ].forEach { statsStackView.addArrangedSubview($0) }
//        
//        NSLayoutConstraint.activate([
//            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            chartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
//            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            chartView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
//            
//            statsStackView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 16),
//            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            statsStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//    
//    private func setupBindings() {
//        viewModel.analytics.bind { [weak self] analytics in
//            self?.updateUI(with: analytics)
//        }
//        
//        viewModel.chartData.bind { [weak self] data in
//            self?.chartView.updateChart(with: data)
//        }
//        
//        trafficObserver = TrafficManager.shared.addObserver { [weak self] stats in
//            self?.viewModel.updateCurrentStats(stats)
//        }
//    }
//    
//    // MARK: - 数据加载
//    private func loadData() {
//        let period = StatsPeriod(rawValue: segmentedControl.selectedSegmentIndex) ?? .hour
//        viewModel.loadData(for: period)
//    }
//    
//    // MARK: - UI更新
//    private func updateUI(with analytics: TrafficAnalytics) {
//        uploadLabel.setValue(analytics.readableTotalUpload)
//        downloadLabel.setValue(analytics.readableTotalDownload)
//        speedLabel.setValue("\(analytics.readableAverageUploadSpeed) ↑ / \(analytics.readableAverageDownloadSpeed) ↓")
//        peakLabel.setValue("\(analytics.readablePeakUploadSpeed) ↑ / \(analytics.readablePeakDownloadSpeed) ↓")
//        durationLabel.setValue(analytics.readableDuration)
//    }
//    
//    // MARK: - 动作处理
//    @objc private func periodChanged() {
//        loadData()
//    }
//}
//
//// MARK: - 图表视图
//final class ChartView: UIView {
//    
//    // MARK: - 属性
//    private var chartLayer: CAShapeLayer?
//    private var gridLayer: CAShapeLayer?
//    private var labelsLayer: CAShapeLayer?
//    
//    // MARK: - 初始化
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    // MARK: - 视图设置
//    private func setupView() {
//        backgroundColor = .systemBackground
//        layer.cornerRadius = 8
//        layer.masksToBounds = true
//    }
//    
//    // MARK: - 公共方法
//    func updateChart(with data: ChartData) {
//        // 移除旧图层
//        chartLayer?.removeFromSuperlayer()
//        gridLayer?.removeFromSuperlayer()
//        labelsLayer?.removeFromSuperlayer()
//        
//        // 创建新图层
//        chartLayer = createChartLayer(with: data)
//        gridLayer = createGridLayer(with: data)
//        labelsLayer = createLabelsLayer(with: data)
//        
//        // 添加图层
//        if let gridLayer = gridLayer {
//            layer.addSublayer(gridLayer)
//        }
//        if let chartLayer = chartLayer {
//            layer.addSublayer(chartLayer)
//        }
//        if let labelsLayer = labelsLayer {
//            layer.addSublayer(labelsLayer)
//        }
//        
//        // 添加动画
//        addChartAnimation()
//    }
//    
//    // MARK: - 私有方法
//    private func createChartLayer(with data: ChartData) -> CAShapeLayer {
//        let layer = CAShapeLayer()
//        layer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
//        layer.strokeColor = UIColor.systemBlue.cgColor
//        layer.lineWidth = 2
//        
//        let path = UIBezierPath()
//        // 绘制图表路径...
//        
//        layer.path = path.cgPath
//        return layer
//    }
//    
//    private func createGridLayer(with data: ChartData) -> CAShapeLayer {
//        let layer = CAShapeLayer()
//        layer.strokeColor = UIColor.systemGray.withAlphaComponent(0.2).cgColor
//        layer.lineWidth = 0.5
//        
//        let path = UIBezierPath()
//        // 绘制网格线...
//        
//        layer.path = path.cgPath
//        return layer
//    }
//    
//    private func createLabelsLayer(with data: ChartData) -> CAShapeLayer {
//        let layer = CAShapeLayer()
//        // 添加标签...
//        return layer
//    }
//    
//    private func addChartAnimation() {
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = 0
//        animation.toValue = 1
//        animation.duration = 1
//        chartLayer?.add(animation, forKey: "chartAnimation")
//    }
//}
//
//// MARK: - 统计标签
//final class StatsLabel: UIView {
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .secondaryLabel
//        return label
//    }()
//    
//    private let valueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        return label
//    }()
//    
//    init(title: String) {
//        super.init(frame: .zero)
//        titleLabel.text = title
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupView() {
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
