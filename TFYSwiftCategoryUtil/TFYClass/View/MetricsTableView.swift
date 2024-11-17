////
////  MetricsTableView.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 性能指标表格视图
//final class MetricsTableView: UIView {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(MetricCell.self, forCellReuseIdentifier: "MetricCell")
//        table.isScrollEnabled = false
//        return table
//    }()
//    
//    // MARK: - 数据
//    private var sections: [MetricSection] = []
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
//        addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//    
//    // MARK: - 更新
//    func update(with metrics: PerformanceMetrics) {
//        sections = [
//            MetricSection(title: "CPU & Memory", items: [
//                MetricItem(title: "CPU Usage", value: MetricsFormatter.formatCPU(metrics.cpuUsage), status: getStatus(metrics.cpuUsage, threshold: PerformanceThresholds.cpuWarning)),
//                MetricItem(title: "Memory Usage", value: MetricsFormatter.formatMemory(metrics.memoryUsage), status: getStatus(Double(metrics.memoryUsage), threshold: Double(PerformanceThresholds.memoryWarning)))
//            ]),
//            MetricSection(title: "Graphics & UI", items: [
//                MetricItem(title: "Frame Rate", value: MetricsFormatter.formatFPS(metrics.fps), status: getStatus(metrics.fps, threshold: PerformanceThresholds.fpsWarning, inverted: true)),
//                MetricItem(title: "Frame Drops", value: "\(metrics.frameDrops)", status: getStatus(Double(metrics.frameDrops), threshold: 10))
//            ]),
//            MetricSection(title: "Network", items: [
//                MetricItem(title: "Throughput", value: MetricsFormatter.formatNetwork(metrics.networkThroughput), status: getStatus(metrics.networkThroughput, threshold: PerformanceThresholds.networkWarning)),
//                MetricItem(title: "Response Time", value: MetricsFormatter.formatDuration(metrics.averageResponseTime), status: getStatus(metrics.averageResponseTime, threshold: PerformanceThresholds.responseWarning))
//            ])
//        ]
//        
//        tableView.reloadData()
//    }
//}
//
//// MARK: - UITableView 数据源和代理
//extension MetricsTableView: UITableViewDataSource, UITableViewDelegate {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sections.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sections[section].items.count
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sections[section].title
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricCell", for: indexPath) as! MetricCell
//        let item = sections[indexPath.section].items[indexPath.row]
//        cell.configure(with: item)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 44
//    }
//}
//
//// MARK: - 指标单元格
//final class MetricCell: UITableViewCell {
//    
//    // MARK: - UI组件
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16)
//        return label
//    }()
//    
//    private lazy var valueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
//        return label
//    }()
//    
//    private lazy var statusIndicator: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 4
//        return view
//    }()
//    
//    // MARK: - 初始化
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        [titleLabel, valueLabel, statusIndicator].forEach {
//            contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            statusIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            statusIndicator.widthAnchor.constraint(equalToConstant: 8),
//            statusIndicator.heightAnchor.constraint(equalToConstant: 8),
//            
//            valueLabel.trailingAnchor.constraint(equalTo: statusIndicator.leadingAnchor, constant: -8),
//            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//    
//    // MARK: - 配置
//    func configure(with item: MetricItem) {
//        titleLabel.text = item.title
//        valueLabel.text = item.value
//        
//        statusIndicator.backgroundColor = {
//            switch item.status {
//            case .good: return .systemGreen
//            case .warning: return .systemYellow
//            case .critical: return .systemRed
//            }
//        }()
//    }
//}
//
//// MARK: - 数据模型
//struct MetricSection {
//    let title: String
//    let items: [MetricItem]
//}
//
//struct MetricItem {
//    let title: String
//    let value: String
//    let status: MetricStatus
//}
//
//enum MetricStatus {
//    case good
//    case warning
//    case critical
//}
//
//// MARK: - 辅助方法
//private func getStatus(_ value: Double, threshold: Double, inverted: Bool = false) -> MetricStatus {
//    if inverted {
//        if value <= threshold * 0.7 { return .critical }
//        if value <= threshold { return .warning }
//        return .good
//    } else {
//        if value >= threshold * 1.3 { return .critical }
//        if value >= threshold { return .warning }
//        return .good
//    }
//}
