////
////  SettingsViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 设置视图控制器
//final class SettingsViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
//        table.register(SwitchSettingCell.self, forCellReuseIdentifier: "SwitchSettingCell")
//        return table
//    }()
//    
//    // MARK: - 属性
//    private let viewModel = SettingsViewModel()
//    private var configObserver: UUID?
//    
//    // MARK: - 设置项
//    private enum Section: Int, CaseIterable {
//        case general
//        case proxy
//        case security
//        case advanced
//        case about
//        
//        var title: String {
//            switch self {
//            case .general: return "General"
//            case .proxy: return "Proxy"
//            case .security: return "Security"
//            case .advanced: return "Advanced"
//            case .about: return "About"
//            }
//        }
//    }
//    
//    private struct Setting {
//        let title: String
//        let type: SettingType
//        let key: String
//        var value: Any?
//        var action: (() -> Void)?
//    }
//    
//    private enum SettingType {
//        case toggle
//        case select
//        case input
//        case action
//        case info
//    }
//    
//    private var settings: [Section: [Setting]] = [:]
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupSettings()
//        setupObservers()
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
//        title = "Settings"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Done",
//            style: .done,
//            target: self,
//            action: #selector(doneButtonTapped)
//        )
//        
//        view.addSubview(tableView)
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    private func setupSettings() {
//        // 通用设置
//        settings[.general] = [
//            Setting(title: "Language", type: .select, key: "language", value: viewModel.language),
//            Setting(title: "Theme", type: .select, key: "theme", value: viewModel.theme),
//            Setting(title: "Auto Start", type: .toggle, key: "autoStart", value: viewModel.autoStart),
//            Setting(title: "Show Notifications", type: .toggle, key: "showNotifications", value: viewModel.showNotifications)
//        ]
//        
//        // 代理设置
//        settings[.proxy] = [
//            Setting(title: "Servers", type: .action, key: "servers") { [weak self] in
//                self?.showServerList()
//            },
//            Setting(title: "Routing Rules", type: .action, key: "rules") { [weak self] in
//                self?.showRoutingRules()
//            },
//            Setting(title: "DNS Servers", type: .action, key: "dns") { [weak self] in
//                self?.showDNSSettings()
//            },
//            Setting(title: "Enable UDP", type: .toggle, key: "enableUDP", value: viewModel.enableUDP)
//        ]
//        
//        // 安全设置
//        settings[.security] = [
//            Setting(title: "SSL Pinning", type: .toggle, key: "sslPinning", value: viewModel.sslPinning),
//            Setting(title: "Jailbreak Detection", type: .toggle, key: "jailbreakDetection", value: viewModel.jailbreakDetection),
//            Setting(title: "Secure DNS", type: .toggle, key: "secureDNS", value: viewModel.secureDNS)
//        ]
//        
//        // 高级设置
//        settings[.advanced] = [
//            Setting(title: "MTU", type: .input, key: "mtu", value: viewModel.mtu),
//            Setting(title: "Timeout", type: .input, key: "timeout", value: viewModel.timeout),
//            Setting(title: "TCP Fast Open", type: .toggle, key: "tcpFastOpen", value: viewModel.tcpFastOpen),
//            Setting(title: "Export Logs", type: .action, key: "exportLogs") { [weak self] in
//                self?.exportLogs()
//            }
//        ]
//        
//        // 关于
//        settings[.about] = [
//            Setting(title: "Version", type: .info, key: "version", value: viewModel.version),
//            Setting(title: "Check for Updates", type: .action, key: "checkUpdates") { [weak self] in
//                self?.checkForUpdates()
//            },
//            Setting(title: "Privacy Policy", type: .action, key: "privacy") { [weak self] in
//                self?.showPrivacyPolicy()
//            }
//        ]
//    }
//    
//    private func setupObservers() {
//        configObserver = ConfigurationManager.shared.addObserver(for: [.general, .proxy, .security]) { [weak self] _ in
//            DispatchQueue.main.async {
//                self?.refreshSettings()
//            }
//        }
//    }
//    
//    private func refreshSettings() {
//        viewModel.refreshConfigurations()
//        setupSettings()
//        tableView.reloadData()
//    }
//    
//    // MARK: - 动作处理
//    @objc private func doneButtonTapped() {
//        dismiss(animated: true)
//    }
//    
//    private func showServerList() {
//        let vc = ServerListViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    private func showRoutingRules() {
//        let vc = RoutingRulesViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    private func showDNSSettings() {
//        let vc = DNSSettingsViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    private func exportLogs() {
//        // 实现日志导出逻辑
//        let logs = CryptoLogger.shared.getLogReport()
//        let activityVC = UIActivityViewController(
//            activityItems: [logs],
//            applicationActivities: nil
//        )
//        present(activityVC, animated: true)
//    }
//    
//    private func checkForUpdates() {
//        viewModel.checkForUpdates { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let available):
//                    if available {
//                        self?.showUpdateAlert()
//                    } else {
//                        self?.showNoUpdateAlert()
//                    }
//                case .failure(let error):
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//    
//    private func showPrivacyPolicy() {
//        if let url = URL(string: "https://example.com/privacy") {
//            UIApplication.shared.open(url)
//        }
//    }
//    
//    private func showUpdateAlert() {
//        let alert = UIAlertController(
//            title: "Update Available",
//            message: "A new version is available. Would you like to update now?",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
//            // 处理更新逻辑
//        })
//        alert.addAction(UIAlertAction(title: "Later", style: .cancel))
//        present(alert, animated: true)
//    }
//    
//    private func showNoUpdateAlert() {
//        let alert = UIAlertController(
//            title: "No Updates",
//            message: "You're running the latest version.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    private func showError(_ error: Error) {
//        let alert = UIAlertController(
//            title: "Error",
//            message: error.localizedDescription,
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UITableView数据源和代理
//extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return Section.allCases.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let section = Section(rawValue: section),
//              let sectionSettings = settings[section] else {
//            return 0
//        }
//        return sectionSettings.count
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return Section(rawValue: section)?.title
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let section = Section(rawValue: indexPath.section),
//              let sectionSettings = settings[section],
//              let setting = sectionSettings[safe: indexPath.row] else {
//            return UITableViewCell()
//        }
//        
//        switch setting.type {
//        case .toggle:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchSettingCell", for: indexPath) as! SwitchSettingCell
//            cell.configure(with: setting)
//            cell.switchValueChanged = { [weak self] isOn in
//                self?.viewModel.updateSetting(key: setting.key, value: isOn)
//            }
//            return cell
//            
//        case .select, .input, .action, .info:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
//            cell.configure(with: setting)
//            return cell
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        guard let section = Section(rawValue: indexPath.section),
//              let sectionSettings = settings[section],
//              let setting = sectionSettings[safe: indexPath.row] else {
//            return
//        }
//        
//        setting.action?()
//    }
//}
//
//// MARK: - 数组安全下标访问
//private extension Array {
//    subscript(safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}
