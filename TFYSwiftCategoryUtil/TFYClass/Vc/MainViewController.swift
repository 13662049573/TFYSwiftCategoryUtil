//// MARK: - 主视图控制器
//
//
//import UIKit
//
//final class MainViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var statusView: ConnectionStatusView = {
//        let view = ConnectionStatusView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var serverListView: ServerListView = {
//        let view = ServerListView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.delegate = self
//        return view
//    }()
//    
//    private lazy var connectionButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.cornerRadius = 25
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
//        button.addTarget(self, action: #selector(connectionButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private lazy var settingsButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "gear"), for: .normal)
//        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // MARK: - 属性
//    private let viewModel = MainViewModel()
//    private var statusObserver: UUID?
//    private var configObserver: UUID?
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupBindings()
//        setupObservers()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        viewModel.refreshStatus()
//    }
//    
//    deinit {
//        if let observer = statusObserver {
//            ConnectionManager.shared.removeObserver(observer)
//        }
//        if let observer = configObserver {
//            ConfigurationManager.shared.removeObserver(observer)
//        }
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        // 添加子视图
//        view.addSubview(statusView)
//        view.addSubview(serverListView)
//        view.addSubview(connectionButton)
//        view.addSubview(settingsButton)
//        
//        // 设置约束
//        NSLayoutConstraint.activate([
//            statusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            statusView.heightAnchor.constraint(equalToConstant: 100),
//            
//            serverListView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 20),
//            serverListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            serverListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            serverListView.bottomAnchor.constraint(equalTo: connectionButton.topAnchor, constant: -20),
//            
//            connectionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            connectionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            connectionButton.widthAnchor.constraint(equalToConstant: 200),
//            connectionButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            settingsButton.widthAnchor.constraint(equalToConstant: 44),
//            settingsButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//        
//        // 设置主题
//        applyTheme()
//    }
//    
//    private func setupBindings() {
//        // 状态绑定
//        viewModel.connectionStatus.bind { [weak self] status in
//            self?.updateUIForConnectionStatus(status)
//        }
//        
//        // 服务器列表绑定
//        viewModel.servers.bind { [weak self] servers in
//            self?.serverListView.updateServers(servers)
//        }
//        
//        // 错误绑定
//        viewModel.error.bind { [weak self] error in
//            if let error = error {
//                self?.showError(error)
//            }
//        }
//    }
//    
//    private func setupObservers() {
//        // 观察连接状态变化
//        statusObserver = ConnectionManager.shared.addObserver { [weak self] status in
//            DispatchQueue.main.async {
//                self?.viewModel.connectionStatus.value = status
//            }
//        }
//        
//        // 观察配置变化
//        configObserver = ConfigurationManager.shared.addObserver(for: [.proxy]) { [weak self] _ in
//            DispatchQueue.main.async {
//                self?.viewModel.refreshServers()
//            }
//        }
//    }
//    
//    private func applyTheme() {
//        let isDarkMode = traitCollection.userInterfaceStyle == .dark
//        
//        // 状态视图主题
//        statusView.backgroundColor = isDarkMode ? .systemGray6 : .systemGray5
//        statusView.layer.cornerRadius = 12
//        
//        // 连接按钮主题
//        connectionButton.backgroundColor = isDarkMode ? .systemBlue : .systemGreen
//        connectionButton.setTitleColor(.white, for: .normal)
//        
//        // 设置按钮主题
//        settingsButton.tintColor = .systemBlue
//    }
//    
//    private func updateUIForConnectionStatus(_ status: ConnectionStatus) {
//        switch status {
//        case .disconnected:
//            connectionButton.setTitle("Connect", for: .normal)
//            connectionButton.backgroundColor = .systemGreen
//            statusView.updateStatus(.disconnected)
//            
//        case .connecting:
//            connectionButton.setTitle("Connecting...", for: .normal)
//            connectionButton.backgroundColor = .systemOrange
//            statusView.updateStatus(.connecting)
//            
//        case .connected:
//            connectionButton.setTitle("Disconnect", for: .normal)
//            connectionButton.backgroundColor = .systemRed
//            statusView.updateStatus(.connected)
//            
//        case .error(let error):
//            connectionButton.setTitle("Retry", for: .normal)
//            connectionButton.backgroundColor = .systemRed
//            statusView.updateStatus(.error(error))
//        }
//    }
//    
//    // MARK: - 动作处理
//    @objc private func connectionButtonTapped() {
//        switch viewModel.connectionStatus.value {
//        case .disconnected, .error:
//            viewModel.connect()
//        case .connected:
//            viewModel.disconnect()
//        case .connecting:
//            // 可选：添加取消连接的逻辑
//            break
//        }
//    }
//    
//    @objc private func settingsButtonTapped() {
//        let settingsVC = SettingsViewController()
//        let navController = UINavigationController(rootViewController: settingsVC)
//        present(navController, animated: true)
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
//// MARK: - ServerListViewDelegate
//extension MainViewController: ServerListViewDelegate {
//    func serverListView(_ view: ServerListView, didSelectServer server: ServerConfig) {
//        viewModel.selectServer(server)
//    }
//    
//    func serverListView(_ view: ServerListView, didRequestEditFor server: ServerConfig) {
//        let editVC = ServerEditViewController(server: server)
//        let navController = UINavigationController(rootViewController: editVC)
//        present(navController, animated: true)
//    }
//}
//
//// MARK: - 主视图模型
//final class MainViewModel {
//    // 可观察属性
//    let connectionStatus = Observable<ConnectionStatus>(.disconnected)
//    let servers = Observable<[ServerConfig]>([])
//    let error = Observable<Error?>(nil)
//    
//    private let connectionManager = ConnectionManager.shared
//    private let configManager = ConfigurationManager.shared
//    
//    init() {
//        refreshServers()
//    }
//    
//    func refreshStatus() {
//        connectionStatus.value = connectionManager.currentStatus
//    }
//    
//    func refreshServers() {
//        if let config: ProxyConfig = configManager.getConfiguration(.proxy) {
//            servers.value = config.servers
//        }
//    }
//    
//    func connect() {
//        guard let server = servers.value.first(where: { $0.id == configManager.getConfiguration(.proxy)?.activeServer }) else {
//            error.value = ConnectionError.noServerSelected
//            return
//        }
//        
//        connectionManager.connect(using: server) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.connectionStatus.value = .connected
//                case .failure(let error):
//                    self?.connectionStatus.value = .error(error)
//                    self?.error.value = error
//                }
//            }
//        }
//    }
//    
//    func disconnect() {
//        connectionManager.disconnect { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.connectionStatus.value = .disconnected
//                case .failure(let error):
//                    self?.error.value = error
//                }
//            }
//        }
//    }
//    
//    func selectServer(_ server: ServerConfig) {
//        var config: ProxyConfig = configManager.getConfiguration(.proxy) ?? ProxyConfig()
//        config.activeServer = server.id
//        
//        do {
//            try configManager.updateConfiguration(.proxy, config: config)
//        } catch {
//            self.error.value = error
//        }
//    }
//}
//
//// MARK: - 可观察类
//final class Observable<T> {
//    typealias Listener = (T) -> Void
//    
//    var value: T {
//        didSet {
//            listener?(value)
//        }
//    }
//    
//    private var listener: Listener?
//    
//    init(_ value: T) {
//        self.value = value
//    }
//    
//    func bind(_ listener: @escaping Listener) {
//        self.listener = listener
//        listener(value)
//    }
//}
