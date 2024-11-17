////
////  DebugViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 调试视图控制器
//final class DebugViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var segmentedControl: UISegmentedControl = {
//        let control = UISegmentedControl(items: ["Logs", "Network", "Performance"])
//        control.translatesAutoresizingMaskIntoConstraints = false
//        control.selectedSegmentIndex = 0
//        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
//        return control
//    }()
//    
//    private lazy var containerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var logsViewController = LogsViewController()
//    private lazy var networkViewController = NetworkDebugViewController()
//    private lazy var performanceViewController = PerformanceDebugViewController()
//    
//    private lazy var toolbarItems: [UIBarButtonItem] = {
//        let shareButton = UIBarButtonItem(
//            image: UIImage(systemName: "square.and.arrow.up"),
//            style: .plain,
//            target: self,
//            action: #selector(shareButtonTapped)
//        )
//        
//        let clearButton = UIBarButtonItem(
//            image: UIImage(systemName: "trash"),
//            style: .plain,
//            target: self,
//            action: #selector(clearButtonTapped)
//        )
//        
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        
//        return [shareButton, flexibleSpace, clearButton]
//    }()
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        showCurrentViewController()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Debug"
//        view.backgroundColor = .systemBackground
//        
//        navigationController?.isToolbarHidden = false
//        toolbarItems = self.toolbarItems
//        
//        view.addSubview(segmentedControl)
//        view.addSubview(containerView)
//        
//        NSLayoutConstraint.activate([
//            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - 视图切换
//    private func showCurrentViewController() {
//        // 移除当前显示的视图控制器
//        containerView.subviews.forEach { $0.removeFromSuperview() }
//        
//        let viewController: UIViewController
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            viewController = logsViewController
//        case 1:
//            viewController = networkViewController
//        case 2:
//            viewController = performanceViewController
//        default:
//            return
//        }
//        
//        addChild(viewController)
//        containerView.addSubview(viewController.view)
//        viewController.view.frame = containerView.bounds
//        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        viewController.didMove(toParent: self)
//    }
//    
//    // MARK: - 动作处理
//    @objc private func segmentChanged() {
//        showCurrentViewController()
//    }
//    
//    @objc private func shareButtonTapped() {
//        let currentVC: DebugSharable? = {
//            switch segmentedControl.selectedSegmentIndex {
//            case 0: return logsViewController
//            case 1: return networkViewController
//            case 2: return performanceViewController
//            default: return nil
//            }
//        }()
//        
//        guard let data = currentVC?.shareableData() else { return }
//        
//        let activityVC = UIActivityViewController(
//            activityItems: [data],
//            applicationActivities: nil
//        )
//        present(activityVC, animated: true)
//    }
//    
//    @objc private func clearButtonTapped() {
//        let alert = UIAlertController(
//            title: "Clear Data",
//            message: "Are you sure you want to clear all data? This action cannot be undone.",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
//            switch self?.segmentedControl.selectedSegmentIndex {
//            case 0:
//                self?.logsViewController.clearLogs()
//            case 1:
//                self?.networkViewController.clearData()
//            case 2:
//                self?.performanceViewController.clearData()
//            default:
//                break
//            }
//        })
//        
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - 日志视图控制器
//final class LogsViewController: UIViewController, DebugSharable {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .plain)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(LogCell.self, forCellReuseIdentifier: "LogCell")
//        return table
//    }()
//    
//    private lazy var filterButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
//        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // MARK: - 属性
//    private var logs: [LogManager.LogEntry] = []
//    private var filteredLogs: [LogManager.LogEntry] = []
//    private var logObserver: UUID?
//    private var currentFilter: LogFilter = LogFilter()
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupObservers()
//        loadLogs()
//    }
//    
//    deinit {
//        if let observer = logObserver {
//            LogManager.shared.removeObserver(observer)
//        }
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(tableView)
//        view.addSubview(filterButton)
//        
//        NSLayoutConstraint.activate([
//            filterButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
//            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            filterButton.widthAnchor.constraint(equalToConstant: 44),
//            filterButton.heightAnchor.constraint(equalToConstant: 44),
//            
//            tableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 8),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - 数据加载
//    private func setupObservers() {
//        logObserver = LogManager.shared.addObserver { [weak self] entry in
//            self?.logs.append(entry)
//            self?.applyFilter()
//            self?.tableView.reloadData()
//            
//            // 滚动到底部
//            if self?.currentFilter.shouldAutoScroll ?? false {
//                self?.scrollToBottom()
//            }
//        }
//    }
//    
//    private func loadLogs() {
//        logs = LogManager.shared.getEntries()
//        applyFilter()
//        tableView.reloadData()
//    }
//    
//    // MARK: - 过滤
//    private func applyFilter() {
//        filteredLogs = logs.filter { entry in
//            if let level = currentFilter.level, entry.level != level {
//                return false
//            }
//            
//            if let category = currentFilter.category, entry.category != category {
//                return false
//            }
//            
//            if let searchText = currentFilter.searchText, !entry.message.localizedCaseInsensitiveContains(searchText) {
//                return false
//            }
//            
//            return true
//        }
//    }
//    
//    // MARK: - 公共方法
//    func clearLogs() {
//        LogManager.shared.clearLogs()
//        logs.removeAll()
//        filteredLogs.removeAll()
//        tableView.reloadData()
//    }
//    
//    func shareableData() -> Any {
//        // 将日志转换为可分享的格式
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
//        
//        let text = filteredLogs.map { entry in
//            "[\(formatter.string(from: entry.timestamp))] [\(entry.level)] [\(entry.category)] \(entry.message)"
//        }.joined(separator: "\n")
//        
//        return text
//    }
//    
//    // MARK: - 动作处理
//    @objc private func filterButtonTapped() {
//        let filterVC = LogFilterViewController(currentFilter: currentFilter)
//        filterVC.delegate = self
//        let nav = UINavigationController(rootViewController: filterVC)
//        present(nav, animated: true)
//    }
//    
//    private func scrollToBottom() {
//        guard !filteredLogs.isEmpty else { return }
//        let lastIndex = IndexPath(row: filteredLogs.count - 1, section: 0)
//        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
//    }
//}
//
//// MARK: - UITableView数据源和代理
//extension LogsViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredLogs.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
//        let entry = filteredLogs[indexPath.row]
//        cell.configure(with: entry)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let entry = filteredLogs[indexPath.row]
//        let detailVC = LogDetailViewController(entry: entry)
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//}
