////
////  RuleEditorViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 规则编辑器视图控制器
//final class RuleEditorViewController: UIViewController {
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
//        placeholder: "My Rule"
//    )
//    
//    private lazy var typeField = FormPickerField(
//        title: "Type",
//        options: RuleType.allCases.map { $0.displayName }
//    )
//    
//    private lazy var valueField = FormTextField(
//        title: "Value",
//        placeholder: "Enter rule value"
//    )
//    
//    private lazy var actionField = FormPickerField(
//        title: "Action",
//        options: RuleAction.allCases.map { $0.displayName }
//    )
//    
//    private lazy var serverField = FormPickerField(
//        title: "Server",
//        options: []
//    )
//    
//    private lazy var enabledSwitch = FormSwitch(
//        title: "Enabled",
//        isOn: true
//    )
//    
//    private lazy var helpButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Rule Format Help", for: .normal)
//        button.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    // MARK: - 属性
//    private let viewModel: RuleEditorViewModel
//    weak var delegate: RuleEditorDelegate?
//    private var keyboardObserver: KeyboardObserver?
//    
//    // MARK: - 初始化
//    init(rule: RoutingRule? = nil) {
//        self.viewModel = RuleEditorViewModel(rule: rule)
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
//        loadServers()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = viewModel.isEditing ? "Edit Rule" : "Add Rule"
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
//            typeField,
//            valueField,
//            actionField,
//            serverField,
//            enabledSwitch,
//            helpButton
//        ].forEach { formStackView.addArrangedSubview($0) }
//        
//        // 设置初始值
//        if let rule = viewModel.rule {
//            nameField.text = rule.name
//            typeField.selectedOption = rule.type.displayName
//            valueField.text = rule.value
//            actionField.selectedOption = rule.action.displayName
//            enabledSwitch.isOn = rule.enabled
//        }
//        
//        // 根据动作类型显示/隐藏服务器选择
//        updateServerFieldVisibility()
//    }
//    
//    private func setupBindings() {
//        // 字段验证绑定
//        nameField.textDidChange = { [weak self] text in
//            self?.viewModel.validateName(text)
//        }
//        
//        valueField.textDidChange = { [weak self] text in
//            self?.viewModel.validateValue(text)
//        }
//        
//        typeField.optionDidChange = { [weak self] option in
//            self?.viewModel.validateValue(self?.valueField.text)
//        }
//        
//        actionField.optionDidChange = { [weak self] option in
//            self?.updateServerFieldVisibility()
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
//    private func loadServers() {
//        let servers = viewModel.loadAvailableServers()
//        serverField.options = servers.map { $0.name }
//        if let rule = viewModel.rule,
//           case .byServer(let serverId) = rule.action,
//           let server = servers.first(where: { $0.id == serverId }) {
//            serverField.selectedOption = server.name
//        }
//    }
//    
//    private func updateServerFieldVisibility() {
//        let actionName = actionField.selectedOption
//        let showServer = RuleAction.allCases.first { $0.displayName == actionName } == .byServer(nil)
//        serverField.isHidden = !showServer
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
//        typeField.errorMessage = errors["type"]
//        valueField.errorMessage = errors["value"]
//        actionField.errorMessage = errors["action"]
//        serverField.errorMessage = errors["server"]
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
//        guard let type = RuleType.allCases.first(where: { $0.displayName == typeField.selectedOption }),
//              let actionName = actionField.selectedOption,
//              let action = RuleAction.fromDisplayName(actionName, serverName: serverField.selectedOption) else {
//            return
//        }
//        
//        let rule = RoutingRule(
//            id: viewModel.rule?.id ?? UUID().uuidString,
//            name: nameField.text ?? "",
//            type: type,
//            value: valueField.text ?? "",
//            action: action,
//            enabled: enabledSwitch.isOn
//        )
//        
//        viewModel.saveRule(rule) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let rule):
//                    self?.delegate?.ruleEditor(self!, didFinishEditing: rule)
//                    self?.dismiss(animated: true)
//                case .failure(let error):
//                    self?.showError(error)
//                }
//            }
//        }
//    }
//    
//    @objc private func helpButtonTapped() {
//        guard let type = RuleType.allCases.first(where: { $0.displayName == typeField.selectedOption }) else {
//            return
//        }
//        
//        let alert = UIAlertController(
//            title: "Rule Format Help",
//            message: type.formatHelp,
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
//// MARK: - 规则编辑器代理
//protocol RuleEditorDelegate: AnyObject {
//    func ruleEditor(_ editor: RuleEditorViewController, didFinishEditing rule: RoutingRule)
//}
