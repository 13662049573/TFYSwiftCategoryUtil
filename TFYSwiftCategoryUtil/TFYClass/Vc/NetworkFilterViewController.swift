////
////  NetworkFilterViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 网络请求过滤器视图控制器
//final class NetworkFilterViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var searchBar: UISearchBar = {
//        let search = UISearchBar()
//        search.translatesAutoresizingMaskIntoConstraints = false
//        search.placeholder = "Search URL or Method"
//        search.delegate = self
//        return search
//    }()
//    
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        return table
//    }()
//    
//    // MARK: - 属性
//    private var currentFilter: NetworkFilter
//    weak var delegate: NetworkFilterDelegate?
//    
//    private let sections: [(title: String, options: [FilterOption])] = [
//        ("Status", [
//            FilterOption(title: "All", key: "status", value: "all"),
//            FilterOption(title: "Success (2xx)", key: "status", value: "success"),
//            FilterOption(title: "Error (4xx, 5xx)", key: "status", value: "error")
//        ]),
//        ("Method", [
//            FilterOption(title: "All", key: "method", value: "all"),
//            FilterOption(title: "GET", key: "method", value: "GET"),
//            FilterOption(title: "POST", key: "method", value: "POST"),
//            FilterOption(title: "PUT", key: "method", value: "PUT"),
//            FilterOption(title: "DELETE", key: "method", value: "DELETE")
//        ]),
//        ("Duration", [
//            FilterOption(title: "All", key: "duration", value: "all"),
//            FilterOption(title: "< 300ms", key: "duration", value: "fast"),
//            FilterOption(title: "300ms - 1s", key: "duration", value: "medium"),
//            FilterOption(title: "> 1s", key: "duration", value: "slow")
//        ])
//    ]
//    
//    // MARK: - 初始化
//    init(currentFilter: NetworkFilter) {
//        self.currentFilter = currentFilter
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
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Filter"
//        view.backgroundColor = .systemBackground
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            title: "Reset",
//            style: .plain,
//            target: self,
//            action: #selector(resetButtonTapped)
//        )
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Done",
//            style: .done,
//            target: self,
//            action: #selector(doneButtonTapped)
//        )
//        
//        view.addSubview(searchBar)
//        view.addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        
//        searchBar.text = currentFilter.searchText
//    }
//    
//    // MARK: - 动作处理
//    @objc private func resetButtonTapped() {
//        currentFilter = NetworkFilter()
//        searchBar.text = nil
//        tableView.reloadData()
//    }
//    
//    @objc private func doneButtonTapped() {
//        delegate?.networkFilter(self, didUpdateFilter: currentFilter)
//        dismiss(animated: true)
//    }
//}
//
//// MARK: - UITableView数据源和代理
//extension NetworkFilterViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sections.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sections[section].options.count
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sections[section].title
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let option = sections[indexPath.section].options[indexPath.row]
//        
//        cell.textLabel?.text = option.title
//        cell.accessoryType = isOptionSelected(option) ? .checkmark : .none
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let option = sections[indexPath.section].options[indexPath.row]
//        updateFilter(with: option)
//        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
//    }
//    
//    private func isOptionSelected(_ option: FilterOption) -> Bool {
//        switch option.key {
//        case "status":
//            return currentFilter.status == option.value
//        case "method":
//            return currentFilter.method == option.value
//        case "duration":
//            return currentFilter.duration == option.value
//        default:
//            return false
//        }
//    }
//    
//    private func updateFilter(with option: FilterOption) {
//        switch option.key {
//        case "status":
//            currentFilter.status = option.value
//        case "method":
//            currentFilter.method = option.value
//        case "duration":
//            currentFilter.duration = option.value
//        default:
//            break
//        }
//    }
//}
//
//// MARK: - UISearchBar代理
//extension NetworkFilterViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        currentFilter.searchText = searchText.isEmpty ? nil : searchText
//    }
//}
//
//// MARK: - 数据模型
//struct NetworkFilter {
//    var searchText: String?
//    var status: String = "all"
//    var method: String = "all"
//    var duration: String = "all"
//    
//    func applies(to request: NetworkRequest) -> Bool {
//        // 搜索文本过滤
//        if let searchText = searchText,
//           !searchText.isEmpty,
//           !request.url.localizedCaseInsensitiveContains(searchText) {
//            return false
//        }
//        
//        // 状态过滤
//        if status != "all" {
//            switch status {
//            case "success":
//                if !request.isSuccess {
//                    return false
//                }
//            case "error":
//                if request.isSuccess {
//                    return false
//                }
//            default:
//                break
//            }
//        }
//        
//        // 方法过滤
//        if method != "all" && request.method != method {
//            return false
//        }
//        
//        // 持续时间过滤
//        if duration != "all" {
//            switch duration {
//            case "fast":
//                if request.duration >= 0.3 {
//                    return false
//                }
//            case "medium":
//                if request.duration < 0.3 || request.duration > 1.0 {
//                    return false
//                }
//            case "slow":
//                if request.duration <= 1.0 {
//                    return false
//                }
//            default:
//                break
//            }
//        }
//        
//        return true
//    }
//}
//
//// MARK: - 过滤选项
//struct FilterOption {
//    let title: String
//    let key: String
//    let value: String
//}
//
//// MARK: - 过滤器代理
//protocol NetworkFilterDelegate: AnyObject {
//    func networkFilter(_ filter: NetworkFilterViewController, didUpdateFilter: NetworkFilter)
//}
