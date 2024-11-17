////
////  ServerAdvancedSettingsViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 服务器高级设置视图控制器
//final class ServerAdvancedSettingsViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(SwitchSettingCell.self, forCellReuseIdentifier: "SwitchSettingCell")
//        table.register(ValueSettingCell.self, forCellReuseIdentifier: "ValueSettingCell")
//        return table
//    }()
//    
//    // MARK: - 属性
//    private let viewModel: ServerAdvancedViewModel
//    private var settings: [[AdvancedSetting]] = []
//    
//    struct AdvancedSetting {
//        let title: String
//        let type: SettingType
//        var value: Any
//        let key: String
//        
//        enum SettingType {
//            case toggle
//            case value
//            case selection
//        }
//    }
//    
//    // MARK: - 初始化
//    init(server: ServerConfig?) {
//        self.viewModel = ServerAdvancedViewModel(server: server)
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
//        setupSettings()
//        setupBindings()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Advanced Settings"
//        view.backgroundColor = .systemBackground
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
//        settings = [
//            // 连接设置
//            [
//                AdvancedSetting(
//                    title: "UDP Relay",
//                    type: .toggle,
//                    value: viewModel.udpRelay,
//                    key: "udpRelay"
//                ),
//                AdvancedSetting(
//                    title: "TCP Fast Open",
//                    type: .toggle,
//                    value: viewModel.tcpFastOpen,
//                    key: "tcpFastOpen"
//                ),
//                AdvancedSetting(
//                    title: "MTU",
//                    type: .value,
//                    value: viewModel.mtu,
//                    key: "mtu"
//                )
//            ],
//            
//            // 性能设置
//            [
//                AdvancedSetting(
//                    title: "Connection Timeout",
//                    type: .value,
//                    value: viewModel.timeout,
//                    key: "timeout"
//                ),
//                AdvancedSetting(
//                    title: "Weight",
//                    type: .value,
//                    value: viewModel.weight,
//                    key: "weight"
//                )
//            ],
//            
//            // 测试设置
//            [
//                AdvancedSetting(
//                    title: "Test URL",
//                    type: .value,
//                    value: viewModel.testUrl ?? "",
//                    key: "testUrl"
//                ),
//                AdvancedSetting(
//                    title: "Test Timeout",
//                    type: .value,
//                    value: viewModel.testTimeout,
//                    key: "testTimeout"
//                )
//            ]
//        ]
//    }
//    
//    private func setupBindings() {
//        viewModel.error.bind { [weak self] error in
//            if let error = error {
//                self?.showError(error)
//            }
//        }
//    }
//    
//    // MARK: - 辅助方法
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
//extension ServerAdvancedSettingsViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return settings.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return settings[section].count
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0: return "Connection"
//        case 1: return "Performance"
//        case 2: return "Testing"
//        default: return nil
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let setting = settings[indexPath.section][indexPath.row]
//        
//        switch setting.type {
//        case .toggle:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchSettingCell", for: indexPath) as! SwitchSettingCell
//            cell.configure(title: setting.title, isOn: setting.value as? Bool ?? false)
//            cell.switchValueChanged = { [weak self] isOn in
//                self?.viewModel.updateSetting(key: setting.key, value: isOn)
//            }
//            return cell
//            
//        case .value:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ValueSettingCell", for: indexPath) as! ValueSettingCell
//            cell.configure(title: setting.title, value: "\(setting.value)")
//            return cell
//            
//        case .selection:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ValueSettingCell", for: indexPath) as! ValueSettingCell
//            cell.configure(title: setting.title, value: setting.value as? String ?? "")
//            cell.accessoryType = .disclosureIndicator
//            return cell
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let setting = settings[indexPath.section][indexPath.row]
//        if setting.type == .value {
//            showValueEditor(for: setting)
//        } else if setting.type == .selection {
//            showSelectionPicker(for: setting)
//        }
//    }
//    
//    private func showValueEditor(for setting: AdvancedSetting) {
//        let alert = UIAlertController(
//            title: setting.title,
//            message: nil,
//            preferredStyle: .alert
//        )
//        
//        alert.addTextField { textField in
//            textField.text = "\(setting.value)"
//            textField.keyboardType = .numberPad
//        }
//        
//        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
//            guard let newValue = alert?.textFields?.first?.text else { return }
//            self?.viewModel.updateSetting(key: setting.key, value: newValue)
//        })
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    
//    private func showSelectionPicker(for setting: AdvancedSetting) {
//        // 实现选择器逻辑
//    }
//}
//
//// MARK: - 服务器高级设置视图模型
//final class ServerAdvancedViewModel {
//    // 可观察属性
//    let error = Observable<Error?>(nil)
//    
//    // 设置属性
//    var udpRelay: Bool
//    var tcpFastOpen: Bool
//    var mtu: Int
//    var timeout: TimeInterval
//    var weight: Int
//    var testUrl: String?
//    var testTimeout: TimeInterval
//    
//    private let server: ServerConfig?
//    private let configManager = ConfigurationManager.shared
//    
//    init(server: ServerConfig?) {
//        self.server = server
//        
//        // 初始化设置值
//        self.udpRelay = server?.udpRelay ?? true
//        self.tcpFastOpen = server?.tcpFastOpen ?? true
//        self.mtu = server?.mtu ?? 1500
//        self.timeout = server?.timeout ?? 30
//        self.weight = server?.weight ?? 100
//        self.testUrl = server?.testUrl
//        self.testTimeout = 5
//    }
//    
//    func updateSetting(key: String, value: Any) {
//        switch key {
//        case "udpRelay":
//            guard let boolValue = value as? Bool else { return }
//            udpRelay = boolValue
//            
//        case "tcpFastOpen":
//            guard let boolValue = value as? Bool else { return }
//            tcpFastOpen = boolValue
//            
//        case "mtu":
//            guard let stringValue = value as? String,
//                  let intValue = Int(stringValue) else { return }
//            mtu = intValue
//            
//        case "timeout":
//            guard let stringValue = value as? String,
//                  let doubleValue = Double(stringValue) else { return }
//            timeout = doubleValue
//            
//        case "weight":
//            guard let stringValue = value as? String,
//                  let intValue = Int(stringValue) else { return }
//            weight = intValue
//            
//        case "testUrl":
//            guard let stringValue = value as? String else { return }
//            testUrl = stringValue
//            
//        case "testTimeout":
//            guard let stringValue = value as? String,
//                  let doubleValue = Double(stringValue) else { return }
//            testTimeout = doubleValue
//            
//        default:
//            break
//        }
//        
//        saveSettings()
//    }
//    
//    private func saveSettings() {
//        guard var config: ProxyConfig = configManager.getConfiguration(.proxy) else {
//            error.value = ConfigError.configurationNotFound
//            return
//        }
//        
//        if let index = config.servers.firstIndex(where: { $0.id == server?.id }) {
//            config.servers[index].udpRelay = udpRelay
//            config.servers[index].tcpFastOpen = tcpFastOpen
//            config.servers[index].mtu = mtu
//            config.servers[index].timeout = timeout
//            config.servers[index].weight = weight
//            config.servers[index].testUrl = testUrl
//        }
//        
//        do {
//            try configManager.updateConfiguration(.proxy, config: config)
//        } catch {
//            self.error.value = error
//        }
//    }
//}
