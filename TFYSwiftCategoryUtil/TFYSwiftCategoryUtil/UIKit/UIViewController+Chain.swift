//
//  UIViewController+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/15.
//

import Foundation
import UIKit
import SafariServices

public func TopestController(inWindow window: UIWindow? = nil) -> UIViewController? {
    return TFY<UIViewController>.topestController(inWindow: window)
}

public enum UIViewControllerFindParentControllerOption {
    case first // 找到的第一个
    case last // 找到的最后一个
}

public extension TFY where Base: UIViewController {
    
    /// 获取当前controller指定class的parentViewController
    ///
    /// - Parameter clazz: 想要获取的parentViewController的class
    /// option: 查找选项
    ///
    /// - Returns: 当前controller指定class的parentViewController
    func findParentController(forClass clazz: AnyClass,
                              option: UIViewControllerFindParentControllerOption = .first) -> UIViewController? {
        var result: UIViewController? = nil
        
        var currentController = base.parent
        while let whileController = currentController {
            if whileController.isKind(of: clazz) {
                result = whileController
                if option == .first {
                    break
                }
            }
            currentController = whileController.parent
        }
        
        return result
    }
    
    /// 获取当前App最顶层的controller
    /// 通常为最后被present的controller
    /// 或UITabBarController中显示的controller
    /// 或UINavigationController中显示的controller
    ///
    /// - Returns: 当前App最顶层的controller
    static func topestController(inWindow window: UIWindow? = nil) -> UIViewController? {
        return topestController(withRootViewController: window?.rootViewController)
    }
    
    private static func topestController(withRootViewController rootViewController: UIViewController? = nil) -> UIViewController? {
        guard let controller = rootViewController ?? UIWindow.keyWindow!.rootViewController else {
            return nil
        }
        
        var findController: UIViewController? = controller
        
        if let presentedViewController = controller.presentedViewController {
            findController = presentedViewController
        }
        else if let tabBarController = controller as? UITabBarController {
            findController = tabBarController.selectedViewController ?? tabBarController.viewControllers?.last
        }
        else if let navigationController = controller as? UINavigationController {
            findController = navigationController.visibleViewController ?? navigationController.viewControllers.last
        }
        else {
            while let vc = findController, vc.isBeingDismissed {
                findController = findController?.presentingViewController
            }
            return findController
        }
        
        if findController == nil {
            return controller
        }
        
        return topestController(withRootViewController: findController)
    }
    
}


public extension UIViewController {
    
    /// ViewController class name
    var classNameValue: String { NSStringFromClass(self.classForCoder).components(separatedBy: ".").last! }
    
    /// Adds a child viewController to the current controller view
    /// - Parameter viewController: The child view
    func addChild(viewController: UIViewController, in view: UIView) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    /// Removes a child viewController from current
    /// - Parameter viewController: The child view controller to remove
    func removeChild(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    /// Combine an array of models and an array of views.
    ///
    /// - Parameters:
    ///   - models: The models as data source.
    ///   - views: The views in need of loading data. Note that this is an inout parameters.
    ///   - newViewGeneration: The function to generate new views, which would immediately be appended into `views`.
    ///   - operation: The main operation that combine each model and view together.
    ///   - remainingViews: The handler responsible for dealing with the rest of unused views.
    class func combine<Model, View>(models: [Model], into views: inout [View], newViewGeneration: () -> View, using operation: (Model, View) -> Void, remainingViews: (ArraySlice<View>) -> Void) {

        // If the models outnumber the views, generate more views
        if models.count > views.count {
            for _ in 0 ..< models.count - views.count {
                views.append(newViewGeneration())
            }
        }

        // Combine each model into each view
        for i in 0 ..< models.count {
            operation(models[i], views[i])
        }

        // Handle the rest of unused views
        if views.count > models.count {
            remainingViews(views.suffix(from: models.count))
        }
    }

    /// Present system alert
    ///
    /// - Parameters:
    ///   - title: Title
    ///   - message: Message
    ///   - confirmTitle: Confirm button title
    ///   - confirmHandler: Confirm handler to run on press
    ///   - cancelTitle: Cancel button title
    ///   - cancelHandler: Cancel handler to run on press
    func showSystemAlert(
        title: String?,
        message: String? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        cancelTitle: String = "Cancel",
        cancelHandler: (() -> Void)? = nil)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(
            title: cancelTitle,
            style: .cancel,
            handler: { _ in cancelHandler?() }
        )
        alertController.addAction(cancelAction)

        if let confirmTitle = confirmTitle {
            let confirmAction = UIAlertAction(
                title: confirmTitle,
                style: .default,
                handler: { _ in confirmHandler?() }
            )
            alertController.addAction(confirmAction)
        }

        present(alertController, animated: true, completion: nil)
    }

    /// Present system alert with distructive primary action
    ///
    /// - Parameters:
    ///   - title: Title
    ///   - message: Message
    ///   - confirmTitle: Confirm button title
    ///   - confirmHandler: Confirm handler to run on press
    ///   - cancelTitle: Cancel button title
    ///   - cancelHandler: Cancel handler to run on press
    func showSystemDistructiveAlert(
        title: String?,
        message: String? = nil,
        destructiveTitle: String?,
        destructiveHandler: (() -> Void)?,
        cancelTitle: String?,
        cancelHandler: (() -> Void)? = nil)
    {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(
            title: cancelTitle,
            style: .cancel,
            handler: { _ in
                cancelHandler?()
            }))
        alertViewController.addAction(UIAlertAction(
            title: destructiveTitle,
            style: .destructive,
            handler: { _ in
                destructiveHandler?()
            }))
        present(alertViewController, animated: true, completion: nil)
    }


    /// Present action sheet
    ///
    /// - Parameters:
    ///   - title: Title
    ///   - message: Message
    ///   - actions: Actions in the sheet
    func showSystemActionSheet(title: String?, message: String?, validActions: (String?, (() -> Void)?)...) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        validActions.forEach { action in
            ac.addAction(UIAlertAction(
                title: action.0,
                style: .default,
                handler: { _ in
                    action.1?()
                }))
        }
        ac.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        present(ac, animated: true, completion: nil)
    }


    /// NavigationBar tint color
    var titleColor: UIColor? {
        get {
            return navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] as? UIColor
        }
        set {
            if navigationController?.navigationBar.titleTextAttributes == nil {
                navigationController?.navigationBar.titleTextAttributes = [:]
            }
            navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = newValue
        }
    }


    /// NavigationBar font
    var titleFont: UIFont? {
        get {
            return navigationController?.navigationBar.titleTextAttributes?[.font] as? UIFont
        }
        set {
            if navigationController?.navigationBar.titleTextAttributes == nil {
                navigationController?.navigationBar.titleTextAttributes = [:]
            }
            navigationController?.navigationBar.titleTextAttributes?[.font] = newValue
        }
    }

    /// Is view loaded and in window
    var viewIsVisible: Bool {
        return (isViewLoaded && view.window != nil)
    }

    private struct AutoHideKeyboardTapKey {
        static var autoHideKeyboardTapKey: UInt8 = 111
    }

    /// Should hide keyboard on view tap
    var automaticallyHideKeyboardWhenViewTapped: Bool {
        get {
            return objc_getAssociatedObject(self, &AutoHideKeyboardTapKey.autoHideKeyboardTapKey) != nil
        }
        set {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.resignTextFieldToHideKeyboard(_:)))
            view.addGestureRecognizer(tap)
            objc_setAssociatedObject(self, &AutoHideKeyboardTapKey.autoHideKeyboardTapKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
    }
    
    /// Resign keyboard
    @objc func resignTextFieldToHideKeyboard(_ sender: AnyObject) {
        view.endEditing(false)
    }

    /// Get the current visible view controller by crawling the view controller heirarchy
    ///
    /// - Parameter base: `UIViewController` to search
    /// - Returns: Current `UIViewController`
    @available(iOS 13.0, *)
    class func getCurrentViewController(base: UIViewController? = KeyWindows()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getCurrentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getCurrentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getCurrentViewController(base: presented)
        }
        return base
    }
    
   class func KeyWindows() -> UIWindow? {
        var keyWindow:UIWindow?
        keyWindow = UIApplication.shared.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows.first
        return keyWindow
    }

    /// Add a bottom tool bar to view controller
    var bottomToolBar: UIView? {
        get {
            if let toolbarItems = toolbarItems, toolbarItems.count == 3 {
                return toolbarItems[1].customView
            }
            return nil
        }
        set {
            if let bar = newValue {
                let toolbarItems = [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(customView: bar),
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                ]
                setToolbarItems(toolbarItems, animated: false)
            } else {
                setToolbarItems(nil, animated: false)
            }
        }
    }

    /// Pop view controller from nav stack
    func popFromNavigationStack() {
        navigationController?.popViewController(animated: true)
    }

    /// Add dismiss `UIBarButtonItem` naviation item
    func addDismissNavigationItem(localizedTitle: String = "Dismiss", image: UIImage? = nil) {
        if let image = image {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissSelf(_:)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: localizedTitle, style: .plain, target: self, action: #selector(dismissSelf(_:)))
        }
    }

    @objc func dismissSelf(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    private struct HidesNavigationBarBackgroundKey {
        static var whenVisible = "hidesNavigationBarBackgroundWhenVisible"
    }

    /// Hide navigation bar background when visible
    var hidesNavigationBarBackgroundWhenVisible: Bool {
        get {
            return (objc_getAssociatedObject(self,(HidesNavigationBarBackgroundKey.whenVisible)) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self,(HidesNavigationBarBackgroundKey.whenVisible), true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    /// Navigation bar height
    var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.bounds.height ?? 0
    }

    /// Tab bar height
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.bounds.height ?? 0
    }

    func pushSafariViewController(urlString: String, entersReaderIfAvailable: Bool = false) {
        if let url = URL(string: urlString) {
            let safariViewController: SFSafariViewController = {
                if #available(iOS 11.0, *) {
                    let configuration = SFSafariViewController.Configuration()
                    configuration.entersReaderIfAvailable = entersReaderIfAvailable
                    return SFSafariViewController(url: url, configuration: configuration)
                } else {
                    return SFSafariViewController(url: url)
                }
            }()
            if #available(iOS 11.0, *) {
                safariViewController.dismissButtonStyle = .close
                safariViewController.configuration.entersReaderIfAvailable = true
            }
            present(safariViewController, animated: true, completion: nil)
        }
    }
}

@objc public extension UIViewController {
    
    var keyWindow: UIWindow? {
        var keyWindow:UIWindow?
        keyWindow = UIApplication.shared.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows.first
        return keyWindow
    }
    
    var vcName: String {
        var name = String(describing: self.classForCoder)
        if name.hasSuffix("ViewController") {
            name = name.replacingOccurrences(of: "ViewController", with: "")
        }
        if name.hasSuffix("Controller") {
            name = name.replacingOccurrences(of: "Controller", with: "")
        }
        return name
    }
    
    /// 是否正在展示
    var isCurrentVC: Bool {
        return isViewLoaded == true && (view!.window != nil)
    }
    
    /// 呈现
    func present(_ animated: Bool = true, style: UIModalPresentationStyle = .fullScreen, completion: (() -> Void)? = nil) {
        guard let keyWindow = keyWindow,
              let rootVC = keyWindow.rootViewController
              else { return }
        if let presentedViewController = rootVC.presentedViewController {
            presentedViewController.dismiss(animated: false, completion: nil)
        }

        DispatchQueue.main.async {
            switch self {
            case let alertVC as UIAlertController:
                if alertVC.preferredStyle == .alert {
                    if alertVC.actions.count == 0 {
                        rootVC.present(alertVC, animated: animated, completion: {
                            DispatchQueue.main.after(TimeInterval(1.5), execute: {
                                alertVC.dismiss(animated: animated, completion: completion)
                            })
                        })
                        return
                    }
                    rootVC.present(alertVC, animated: animated, completion: completion)
                } else {
                    //防止 ipad 下 sheet 会崩溃的问题
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        if let controller = alertVC.popoverPresentationController {
                            controller.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                            controller.sourceView = keyWindow
                            
                            let isEmpty = controller.sourceRect.equalTo(.null) || controller.sourceRect.equalTo(.zero)
                            if isEmpty {
                                controller.sourceRect = CGRect(x: keyWindow.bounds.midX, y: 64, width: 1, height: 1)
                            }
                        }
                    }
                    rootVC.present(alertVC, animated: animated, completion: completion)
                }
                
            default:
                rootVC.present(self, animated: animated, completion: completion)
            }
        }
    }
    
    /// 消失
    func dismissVC(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let keyWindow = keyWindow,
              let rootVC = keyWindow.rootViewController
              else { return }
        
        DispatchQueue.main.async {
            if let presentedViewController = rootVC.presentedViewController {
                presentedViewController.dismiss(animated: animated, completion: completion)
            }
        }
    }
    
    ///判断上一页是哪个页面
    func pushFromVC(_ type: UIViewController.Type) -> Bool {
        guard let viewControllers = navigationController?.viewControllers,
              viewControllers.count > 1,
              let index = viewControllers.firstIndex(of: self) else {
            return false }
                        
        let result = viewControllers[index - 1].isKind(of: type)
        return result
    }
    
    /// 重置布局(UIDocumentPickerViewController需要为automatic)
    func setupContentInsetAdjustmentBehavior(_ isAutomatic: Bool = false) {
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = isAutomatic == true ? .automatic : .never
        }
    }
    
    /// [源]创建UISearchController(设置IQKeyboardManager.shared.enable = false//避免searchbar下移)
    func createSearchVC(_ resultsController: UIViewController) -> UISearchController {
        resultsController.edgesForExtendedLayout = []
        definesPresentationContext = true
        
        let searchVC = UISearchController(searchResultsController: resultsController)
        if resultsController.conforms(to: UISearchResultsUpdating.self) {
            searchVC.searchResultsUpdater = resultsController as? UISearchResultsUpdating
        }
        searchVC.searchBar.barStyle = .default
        searchVC.searchBar.isTranslucent = false
        searchVC.searchBar.placeholder = "搜索"
        return searchVC
    }
        
    /// 导航栏返回按钮图片定制
    func createBackItem(_ image: UIImage) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem?.addAction({ (item) in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    /// 添加子控制器(对应方法 removeChildVC)
    func addChildVC(_ vc: UIViewController) {
        addChild(vc)
        vc.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    /// 移除添加的子控制器(对应方法 addChildVC)
    func removeChildVC(_ vc: UIViewController) {
        assert(vc.isKind(of: UIViewController.self))
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
    
    /// 显示controller(手动调用viewWillAppear和viewDidAppear,viewWillDisappear)
    func transitionTo(VC: UIViewController) {
        beginAppearanceTransition(false, animated: true)  //调用self的 viewWillDisappear:
        VC.beginAppearanceTransition(true, animated: true)  //调用VC的 viewWillAppear:
        endAppearanceTransition() //调用self的viewDidDisappear:
        VC.endAppearanceTransition() //调用VC的viewDidAppear:
        /*
         isAppearing 设置为 true : 触发 viewWillAppear:
         isAppearing 设置为 false : 触发 viewWillDisappear:
         endAppearanceTransition方法会基于我们传入的isAppearing来调用viewDidAppear:以及viewDidDisappear:方法
         */
    }
    /// 手动调用 viewWillAppear,viewDidDisappear 或 viewWillDisappear,viewDidDisappear
    func beginAppearance(_ isAppearing: Bool, animated: Bool){
        beginAppearanceTransition(isAppearing, animated: animated)
        endAppearanceTransition()
    }
    
    ///背景灰度设置
    func setAlphaOfBackgroundViews(_ alpha: CGFloat) {
        guard let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow else { return }
        UIView.animate(withDuration: 0.2) {
            statusBarWindow.alpha = alpha
            self.view.alpha = alpha
            self.navigationController?.navigationBar.alpha = alpha
        }
    }
        
    ///呈现popover
    func presentPopover(_ contentVC: UIViewController,
                        sender: UIView,
                        arrowDirection: UIPopoverArrowDirection = .any,
                        offset: UIOffset = .zero,
                        completion: (() -> Void)? = nil){
        if contentVC.presentingViewController != nil {
            return
        }
        
        contentVC.modalPresentationStyle = .popover

        guard let superview = sender.superview else { return }
        let sourceRect = superview.convert(sender.frame, to: self.view)
        
        guard let popoverPresentationVC = contentVC.popoverPresentationController else { return }
        popoverPresentationVC.permittedArrowDirections = arrowDirection
        popoverPresentationVC.sourceView = self.view
        popoverPresentationVC.sourceRect = sourceRect.offsetBy(dx: offset.horizontal, dy: offset.vertical)
        if conforms(to: UIPopoverPresentationControllerDelegate.self) {
            popoverPresentationVC.delegate = self as? UIPopoverPresentationControllerDelegate
        }
        present(contentVC, animated: true, completion: completion)
    }
    
    ///左滑返回按钮(viewDidAppear/viewWillDisappear)
    func popGesture(_ isEnabled: Bool) {
        guard let navigationController = navigationController,
              let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer,
              let gestureRecognizers = interactivePopGestureRecognizer.view?.gestureRecognizers
              else { return }
   
        gestureRecognizers.forEach { (gesture) in
            gesture.isEnabled = isEnabled
        }
        interactivePopGestureRecognizer.isEnabled = isEnabled
    }
    
    ///左滑返回关闭(viewDidAppear/viewWillDisappear)
    func popGestureClose() {
        popGesture(false)
    }

    ///左滑返回打开(viewDidAppear/viewWillDisappear)
    func popGestureOpen() {
        popGesture(true)
    }
}


public extension UIViewController{
    
    ///刷新 tabBarItem
    func reloadTabarItem(_ item: (String, UIImage?, UIImage?)) {
        guard let img = item.1,
              let imgH = item.2 else {
                tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
                return }
        
        let value = img.withRenderingMode(.alwaysOriginal)
        let valueH = imgH.withRenderingMode(.alwaysTemplate)
        tabBarItem = UITabBarItem(title: item.0, image: value, selectedImage: valueH)
    }
}

public extension DispatchQueue{
    private static var _onceTracker = [String]()
    /// 函数只被执行一次
    class func oncecontroll(token: String, block: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    /// 延迟 delay 秒 执行
    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
}
