////
////  ServerListViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 服务器列表视图控制器
//final class ServerListViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(ServerCell.self, forCellReuseIdentifier: "ServerCell")
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
//            image: UIImage(systemName: "server.rack"),
//            title: "No Servers",
//            message: "Add a server to get started"
//        )
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isHidden = true
//        return view
//    }()
//    
//    // MARK: - 属性
//    private let viewModel = ServerListViewModel()
//    private var configObserver: UUID?
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupObservers()
//        viewModel.loadServers()
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
//        title = "Servers"
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
//        viewModel.servers.bind { [weak self] servers in
//            self?.updateUI(with: servers)
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
//                self?.viewModel.loadServers()
//            }
//        }
//    }
//    
//    private func updateUI(with servers: [ServerConfig]) {
//        emptyStateView.isHidden = !servers.isEmpty
//        tableView.reloadData()
//    }
//    
//    // MARK: - 动作处理
//    @objc private func addButtonTapped() {
//        let vc = ServerEditViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        present(nav, animated: true)
//    }
//    
//    @objc private func importButtonTapped() {
//        let alert = UIAlertController(
//            title: "Import Servers",
//            message: "Choose import method",
//            preferredStyle: .actionSheet
//        )
//        
//        alert.addAction(UIAlertAction(title: "From URL", style: .default) { [weak self] _ in
//            self?.importFromURL()
//        })
//        
//        alert.addAction(UIAlertAction(title: "From QR Code", style: .default) { [weak self] _ in
//            self?.importFromQRCode()
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
//    private func importFromURL() {
//        let alert = UIAlertController(
//            title: "Import from URL",
//            message: "Enter subscription URL",
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
//            self?.viewModel.importServers(from: url) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let count):
//                        self?.showSuccess("Successfully imported \(count) servers")
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
//    private func importFromQRCode() {
//        let scanner = QRCodeScannerViewController { [weak self] result in
//            switch result {
//            case .success(let code):
//                self?.viewModel.importServers(from: code) { result in
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(let count):
//                            self?.showSuccess("Successfully imported \(count) servers")
//                        case .failure(let error):
//                            self?.showError(error)
//                        }
//                    }
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self?.showError(error)
//                }
//            }
//        }
//        
//        present(scanner, animated: true)
//    }
//    
//    private func importFromClipboard() {
//        guard let content = UIPasteboard.general.string else {
//            showError(ServerError.invalidClipboardContent)
//            return
//        }
//        
//        viewModel.importServers(from: content) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let count):
//                    self?.showSuccess("Successfully imported \(count) servers")
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
//extension ServerListViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.servers.value.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell", for: indexPath) as! ServerCell
//        let server = viewModel.servers.value[indexPath.row]
//        cell.configure(with: server)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let server = viewModel.servers.value[indexPath.row]
//        let vc = ServerEditViewController(server: server)
//        let nav = UINavigationController(rootViewController: vc)
//        present(nav, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let server = viewModel.servers.value[indexPath.row]
//        
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
//            self?.viewModel.deleteServer(server)
//            completion(true)
//        }
//        deleteAction.backgroundColor = .systemRed
//        
//        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completion in
//            self?.shareServer(server)
//            completion(true)
//        }
//        shareAction.backgroundColor = .systemBlue
//        
//        return UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
//    }
//    
//    private func shareServer(_ server: ServerConfig) {
//        let encoder = ServerEncoder()
//        guard let shareURL = try? encoder.encode(server) else {
//            showError(ServerError.encodingFailed)
//            return
//        }
//        
//        let activityVC = UIActivityViewController(
//            activityItems: [shareURL],
//            applicationActivities: nil
//        )
//        present(activityVC, animated: true)
//    }
//}
//
//// MARK: - 服务器错误
//enum ServerError: LocalizedError {
//    case invalidClipboardContent
//    case invalidQRCode
//    case invalidURL
//    case importFailed
//    case encodingFailed
//    case decodingFailed
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidClipboardContent:
//            return "Invalid clipboard content"
//        case .invalidQRCode:
//            return "Invalid QR code"
//        case .invalidURL:
//            return "Invalid URL"
//        case .importFailed:
//            return "Failed to import servers"
//        case .encodingFailed:
//            return "Failed to encode server configuration"
//        case .decodingFailed:
//            return "Failed to decode server configuration"
//        }
//    }
//}
