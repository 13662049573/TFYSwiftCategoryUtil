////
////  ServerEditViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 服务器编辑视图控制器
//final class ServerEditViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var scrollView: UIScrollView = {
//        let scroll = UIScrollView()
//        scroll.translatesAutoresizingMaskIntoConstraints = false
//        scroll.keyboardDismissMode = .interactive
//        return scroll
//    }()
//    
//    private lazy var contentView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var formStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.spacing = 16
//        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        stack.isLayoutMarginsRelativeArrangement = true
//        return stack
//    }()
//    
//    private lazy var nameField = FormTextField(
//        title: "Name",
//        placeholder: "My Server"
//    )
//    
//    private lazy var hostField = FormTextField(
//        title: "Host",
//        placeholder: "example.com",
//        keyboardType: .URL,
//        autocapitalizationType: .none
//    )
//    
//    private lazy var portField = FormTextField(
//        title: "Port",
//        placeholder: "443",
//        keyboardType: .numberPad
//    )
//    
//    private lazy var methodField = FormPickerField(
//        title: "Method",
//        options: SSREncryptMethod.allCases.map { $0.rawValue }
//    )
//    
//    private lazy var passwordField = FormTextField(
//        title: "Password",
//        placeholder: "Required",
//        isSecureTextEntry: true
//    )
//    
//    private lazy var protocolField = FormPickerField(
//        title: "Protocol",
//        options: SSRProtocol.allCases.map { $0.rawValue }
//    )
//    
//    private lazy var protocolParamField = FormTextField(
//        title: "Protocol Param",
//        placeholder: "Optional"
//    )
//    
//    private lazy var obfsField = FormPickerField(
//        title: "Obfuscation",
//        options: SSRObfuscation.allCases.map { $0.rawValue }
//    )
//    
//    private lazy var obfsParamField = FormTextField(
//        title: "Obfs Param",
//        placeholder: "Optional"
//    )
//    
//    private lazy var remarksField = FormTextField(
//        title: "Remarks",
//        placeholder: "Optional"
//    )
//    
//    private lazy var groupField = FormTextField(
//        title: "Group",
//        placeholder: "Optional"
//    )
//    
//    private lazy var advancedSettingsButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Advanced Settings", for: .normal)
//        button.addTarget(self, action: #selector(advancedSettingsButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private lazy var testButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Test Connection", for: .normal)
//        button.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // MARK: - 属性
//    private let viewModel: ServerEditViewModel
//    private var keyboardObserver: KeyboardObserver?
//    
//    // MARK: - 初始化
//    init(server: ServerConfig? = nil) {
//        self.viewModel = ServerEditViewModel(server: server)
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
//        setupBindings()
//        setupKeyboardHandling()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = viewModel.isEditing ? "Edit Server" : "Add Server"
//        view.backgroundColor = .systemBackground
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            title: "Cancel",
//            style: .plain,
//            target: self,
//            action: #selector(cancelButtonTapped)
//        )
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Save",
//            style: .done,
//            target: self,
//            action: #selector(saveButtonTapped)
//        )
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        contentView.addSubview(formStackView)
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            formStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            formStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//        
//        // 添加表单字段
//        [
//            nameField,
//            hostField,
//            portField,
//            methodField,
//            passwordField,
//            protocolField,
//            protocolParamField,
//            obfsField,
//            obfsParamField,
//            remarksField,
//            groupField,
//            advancedSettingsButton,
//            testButton
//        ].forEach { formStackView.addArrangedSubview($0) }
//        
//        // 设置初始值
//        if let server = viewModel.server {
//            nameField.text = server.name
//            hostField.text = server.host
//            portField.text = String(server.port)
//            methodField.selectedOption = server.method
//            passwordField.text = server.password
//            protocolField.selectedOption = server.protocol
//            protocolParamField.text = server.protocolParam
//            obfsField.selectedOption = server.obfs
//            obfsParamField.text = server.obfsParam
//            remarksField.text = server.remarks
//            groupField.text = server.group
//        }
//    }
//    
//    private func setupBindings() {
//        // 字段验证绑定
//        nameField.textDidChange = { [weak self] text in
//            self?.viewModel.validateName(text)
//        }
//        
//        hostField.textDidChange = { [weak self] text in
//            self?.viewModel.validateHost(text)
//        }
//        
//        portField.textDidChange = { [weak self] text in
//            self?.viewModel.validatePort(text)
//        }
//        
//        // 错误处理绑定
//        viewModel.validationErrors.bind { [weak self] errors in
//            self?.updateValidationErrors(errors)
//        }
//        
//        viewModel.isSaving.bind { [weak self] isSaving in
//            self?.updateSavingState(isSaving)
//        }
//        
//        viewModel.error.bind { [weak self] error in
//            if let error = error {
//                self?.showError(error)
//            }
//        }
//    }
//    
//    private func setupKeyboardHandling() {
//        keyboardObserver = KeyboardObserver { [weak self] keyboardFrame in
//            self?.adjustForKeyboard(keyboardFrame)
//        }
//    }
//    
//    private func adjustForKeyboard(_ keyboardFrame: CGRect) {
//        let convertedFrame = view.convert(keyboardFrame, from: nil)
//        let intersection = convertedFrame.intersection(view.bounds)
//        
//        scrollView.contentInset.bottom = intersection.height
//        scrollView.scrollIndicatorInsets.bottom = intersection.height
//    }
//    
//    private func updateValidationErrors(_ errors: [String: String]) {
//        nameField.errorMessage = errors["name"]
//        hostField.errorMessage = errors["host"]
//        portField.errorMessage = errors["port"]
//        methodField.errorMessage = errors["method"]
//        passwordField.errorMessage = errors["password"]
//        protocolField.errorMessage = errors["protocol"]
//        obfsField.errorMessage = errors["obfs"]
//    }
//    
//    private func updateSavingState(_ isSaving: Bool) {
//        navigationItem.rightBarButtonItem?.isEnabled = !isSaving
//        let title = isSaving ? "Saving..." : "Save"
//        navigationItem.rightBarButtonItem?.title = title
//    }
//    
//    // MARK: - 动作处理
//    @objc private func cancelButtonTapped() {
//        dismiss(animated: true)
//    }
//    
//    @objc private func saveButtonTapped() {
//        let config = ServerConfig(
//            name: nameField.text ?? "",
//            host: hostField.text ?? "",
//            port: Int(portField.text ?? "0") ?? 0,
//            method: methodField.selectedOption ?? "",
//            password: passwordField.text ?? "",
//            protocol: protocolField.selectedOption ?? "",
//            protocolParam: protocolParamField.text,
//            obfs: obfsField.selectedOption ?? "",
//            obfsParam: obfsParamField.text,
//            remarks: remarksField.text,
//            group: groupField.text
//        )
//        
//        viewModel.saveServer(config) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.dismiss(animated: true)
//                case .failure(let error):
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//    
//    @objc private func advancedSettingsButtonTapped() {
//        let vc = ServerAdvancedSettingsViewController(server: viewModel.server)
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    @objc private func testButtonTapped() {
//        guard let config = try? viewModel.validateCurrentConfig() else {
//            return
//        }
//        
//        viewModel.testConnection(config) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let latency):
//                    self?.showTestResult(latency: latency)
//                case .failure(let error):
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//    
//    private func showTestResult(latency: TimeInterval) {
//        let message = String(format: "Connection successful\nLatency: %.0fms", latency * 1000)
//        let banner = NotificationBanner(
//            title: "Test Result",
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
