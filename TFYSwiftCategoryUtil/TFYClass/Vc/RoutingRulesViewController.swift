////
////  RoutingRulesViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 路由规则视图控制器
//final class RoutingRulesViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(RuleCell.self, forCellReuseIdentifier: "RuleCell")
//        return table
//    }()
//    
//    private lazy var addButton: UIBarButtonItem = {
//        return UIBarButtonItem(
//            barButtonSystemItem: .add,
//            target: self,
//            action: #selector(addButtonTapped)
//        )
//    }()
//    
//    private lazy var importButton: UIBarButtonItem = {
//        return UIBarButtonItem(
//            image: UIImage(systemName: "square.and.arrow.down"),
//            style: .plain,
//            target: self,
//            action: #selector(importButtonTapped)
//        )
//    }()
//    
//    private lazy var emptyStateView: EmptyStateView = {
//        let view = EmptyStateView(
//            image: UIImage(systemName: "arrow.triangle.branch"),
//            title: "No Rules",
//            message: "Add routing rules to customize traffic handling"
//        )
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isHidden = true
//        return view
//    }()
//    
//    // MARK: - 属性
//    private let viewModel = RoutingRulesViewModel()
//    private var configObserver: UUID?
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupObservers()
//        viewModel.loadRules()
//    }
//    
//    deinit {
//        if let observer = configObserver {
//            ConfigurationManager.shared.removeObserver(observer)
//        }
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Routing Rules"
//        navigationItem.rightBarButtonItems = [addButton, importButton]
//        
//        view.addSubview(tableView)
//        view.addSubview(emptyStateView)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
//        ])
//        
//        // 绑定视图模型
//        viewModel.rules.bind { [weak self] rules in
//            self?.updateUI(with: rules)
//        }
//        
//        viewModel.error.bind { [weak self] error in
//            if let error = error {
//                self?.showError(error)
//            }
//        }
//    }
//    
//    private func setupObservers() {
//        configObserver = ConfigurationManager.shared.addObserver(for: [.proxy]) { [weak self] _ in
//            DispatchQueue.main.async {
//                self?.viewModel.loadRules()
//            }
//        }
//    }
//    
//    private func updateUI(with rules: [RoutingRule]) {
//        emptyStateView.isHidden = !rules.isEmpty
//        tableView.reloadData()
//    }
//    
//    // MARK: - 动作处理
//    @objc private func addButtonTapped() {
//        showRuleEditor()
//    }
//    
//    @objc private func importButtonTapped() {
//        let alert = UIAlertController(
//            title: "Import Rules",
//            message: "Choose import method",
//            preferredStyle: .actionSheet
//        )
//        
//        alert.addAction(UIAlertAction(title: "From File", style: .default) { [weak self] _ in
//            self?.importFromFile()
//        })
//        
//        alert.addAction(UIAlertAction(title: "From URL", style: .default) { [weak self] _ in
//            self?.importFromURL()
//        })
//        
//        alert.addAction(UIAlertAction(title: "From Clipboard", style: .default) { [weak self] _ in
//            self?.importFromClipboard()
//        })
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    
//    private func showRuleEditor(rule: RoutingRule? = nil) {
//        let vc = RuleEditorViewController(rule: rule)
//        vc.delegate = self
//        let nav = UINavigationController(rootViewController: vc)
//        present(nav, animated: true)
//    }
//    
//    private func importFromFile() {
//        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        present(documentPicker, animated: true)
//    }
//    
//    private func importFromURL() {
//        let alert = UIAlertController(
//            title: "Import from URL",
//            message: "Enter rules URL",
//            preferredStyle: .alert
//        )
//        
//        alert.addTextField { textField in
//            textField.placeholder = "https://"
//            textField.keyboardType = .URL
//            textField.autocapitalizationType = .none
//        }
//        
//        alert.addAction(UIAlertAction(title: "Import", style: .default) { [weak self, weak alert] _ in
//            guard let urlString = alert?.textFields?.first?.text,
//                  let url = URL(string: urlString) else {
//                return
//            }
//            
//            self?.viewModel.importRules(from: url) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let count):
//                        self?.showSuccess("Successfully imported \(count) rules")
//                    case .failure(let error):
//                        self?.showError(error)
//                    }
//                }
//            }
//        })
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    
//    private func importFromClipboard() {
//        guard let content = UIPasteboard.general.string else {
//            showError(RuleError.invalidClipboardContent)
//            return
//        }
//        
//        viewModel.importRules(from: content) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let count):
//                    self?.showSuccess("Successfully imported \(count) rules")
//                case .failure(let error):
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//    
//    private func showSuccess(_ message: String) {
//        let banner = NotificationBanner(
//            title: "Success",
//            subtitle: message,
//            style: .success
//        )
//        banner.show()
//    }
//    
//    private func showError(_ error: Error) {
//        let banner = NotificationBanner(
//            title: "Error",
//            subtitle: error.localizedDescription,
//            style: .danger
//        )
//        banner.show()
//    }
//}
//
//// MARK: - UITableView数据源和代理
//extension RoutingRulesViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.rules.value.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "RuleCell", for: indexPath) as! RuleCell
//        let rule = viewModel.rules.value[indexPath.row]
//        cell.configure(with: rule)
//        cell.switchValueChanged = { [weak self] isEnabled in
//            self?.viewModel.toggleRule(at: indexPath.row, enabled: isEnabled)
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let rule = viewModel.rules.value[indexPath.row]
//        showRuleEditor(rule: rule)
//    }
//    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
//            self?.viewModel.deleteRule(at: indexPath.row)
//            completion(true)
//        }
//        
//        let moveAction = UIContextualAction(style: .normal, title: "Move") { [weak self] _, _, completion in
//            self?.showMoveOptions(for: indexPath.row)
//            completion(true)
//        }
//        moveAction.backgroundColor = .systemBlue
//        
//        return UISwipeActionsConfiguration(actions: [deleteAction, moveAction])
//    }
//    
//    private func showMoveOptions(for index: Int) {
//        let alert = UIAlertController(
//            title: "Move Rule",
//            message: "Choose position",
//            preferredStyle: .actionSheet
//        )
//        
//        if index > 0 {
//            alert.addAction(UIAlertAction(title: "Move to Top", style: .default) { [weak self] _ in
//                self?.viewModel.moveRule(from: index, to: 0)
//            })
//        }
//        
//        if index < viewModel.rules.value.count - 1 {
//            alert.addAction(UIAlertAction(title: "Move to Bottom", style: .default) { [weak self] _ in
//                self?.viewModel.moveRule(from: index, to: self?.viewModel.rules.value.count ?? 0 - 1)
//            })
//        }
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UIDocumentPickerDelegate
//extension RoutingRulesViewController: UIDocumentPickerDelegate {
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let url = urls.first else { return }
//        
//        viewModel.importRules(from: url) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let count):
//                    self?.showSuccess("Successfully imported \(count) rules")
//                case .failure(let error):
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - RuleEditorDelegate
//extension RoutingRulesViewController: RuleEditorDelegate {
//    func ruleEditor(_ editor: RuleEditorViewController, didFinishEditing rule: RoutingRule) {
//        viewModel.updateRule(rule)
//    }
//}
