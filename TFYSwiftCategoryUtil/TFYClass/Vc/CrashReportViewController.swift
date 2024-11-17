////
////  CrashReportViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 崩溃报告视图控制器
//final class CrashReportViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(CrashReportCell.self, forCellReuseIdentifier: "CrashReportCell")
//        return table
//    }()
//    
//    private lazy var emptyLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "No crash reports available"
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        return label
//    }()
//    
//    // MARK: - 属性
//    private var reports: [CrashReport] = []
//    private let crashManager = CrashReportManager.shared
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadReports()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Crash Reports"
//        view.backgroundColor = .systemBackground
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Clear",
//            style: .plain,
//            target: self,
//            action: #selector(clearButtonTapped)
//        )
//        
//        view.addSubview(tableView)
//        view.addSubview(emptyLabel)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    // MARK: - 数据加载
//    private func loadReports() {
//        reports = crashManager.getCrashReports()
//        updateUI()
//    }
//    
//    private func updateUI() {
//        emptyLabel.isHidden = !reports.isEmpty
//        tableView.reloadData()
//    }
//    
//    // MARK: - 动作处理
//    @objc private func clearButtonTapped() {
//        let alert = UIAlertController(
//            title: "Clear Reports",
//            message: "Are you sure you want to clear all crash reports? This action cannot be undone.",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
//            self?.crashManager.clearReports()
//            self?.reports.removeAll()
//            self?.updateUI()
//        })
//        
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UITableView数据源和代理
//extension CrashReportViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return reports.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CrashReportCell", for: indexPath) as! CrashReportCell
//        let report = reports[indexPath.row]
//        cell.configure(with: report)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let report = reports[indexPath.row]
//        let detailVC = CrashDetailViewController(report: report)
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//}
//
//// MARK: - 崩溃报告单元格
//final class CrashReportCell: UITableViewCell {
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        return label
//    }()
//    
//    private lazy var subtitleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .secondaryLabel
//        return label
//    }()
//    
//    private lazy var typeLabel: PaddedLabel = {
//        let label = PaddedLabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 12, weight: .medium)
//        label.layer.cornerRadius = 4
//        label.clipsToBounds = true
//        return label
//    }()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        accessoryType = .disclosureIndicator
//        
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(subtitleLabel)
//        contentView.addSubview(typeLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(equalTo: typeLabel.leadingAnchor, constant: -8),
//            
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
//            
//            typeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            typeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
//        ])
//    }
//    
//    func configure(with report: CrashReport) {
//        titleLabel.text = report.name
//        subtitleLabel.text = report.formattedTimestamp
//        
//        switch report.type {
//        case .exception:
//            typeLabel.text = "Exception"
//            typeLabel.backgroundColor = .systemRed.withAlphaComponent(0.1)
//            typeLabel.textColor = .systemRed
//        case .signal:
//            typeLabel.text = "Signal"
//            typeLabel.backgroundColor = .systemOrange.withAlphaComponent(0.1)
//            typeLabel.textColor = .systemOrange
//        }
//    }
//}
//
//// MARK: - 辅助视图
//final class PaddedLabel: UILabel {
//    override var intrinsicContentSize: CGSize {
//        let size = super.intrinsicContentSize
//        return CGSize(width: size.width + 16, height: size.height + 8)
//    }
//}
