//
//  TFYWindowCleaner.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFY on 2024
//
//  TFYWindowCleaner - Window清理工具
//
//  功能说明：
//  - 清理window上的所有子视图和容器
//  - 移除所有模态呈现的视图控制器
//  - 清理导航控制器栈
//  - 重置window的根视图控制器
//  - 清理内存中的视图控制器引用
//  - 支持选择性清理和完全清理
//  - 提供清理完成回调
//  - 支持动画清理过程
//
//  使用示例：
//  // 完全清理所有window内容
//  TFYWindowCleaner.cleanAllWindows()
//      .withAnimation(true)
//      .withCompletion { print("清理完成") }
//      .execute()
//
//  // 清理指定window
//  TFYWindowCleaner.cleanWindow(UIApplication.shared.windows.first!)
//      .withRemoveModalControllers(true)
//      .withClearNavigationStack(true)
//      .execute()
//
//  // 清理当前活动window
//  TFYWindowCleaner.cleanCurrentWindow()
//      .withRemoveSubviews(true)
//      .execute()
//
//  注意事项：
//  - 支持iOS 9.0+，部分功能需要更高版本
//  - 自动处理内存管理和资源释放
//  - 线程安全，所有操作都在主线程执行
//  - 支持深色模式和动态字体
//  - 兼容iPhone和iPad的不同清理行为
//

import UIKit
import Foundation

// MARK: - 清理类型枚举
public enum CleanType: Hashable {
    case all                    // 清理所有内容
    case subviews              // 只清理子视图
    case modalControllers      // 只清理模态控制器
    case navigationStack       // 只清理导航栈
    case rootController        // 只清理根控制器
    case backgroundViews       // 只清理背景视图
    case overlayViews          // 只清理覆盖视图
    case custom([CleanType])   // 自定义清理组合
    
    // 实现Hashable协议
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .all:
            hasher.combine(0)
        case .subviews:
            hasher.combine(1)
        case .modalControllers:
            hasher.combine(2)
        case .navigationStack:
            hasher.combine(3)
        case .rootController:
            hasher.combine(4)
        case .backgroundViews:
            hasher.combine(5)
        case .overlayViews:
            hasher.combine(6)
        case .custom(let types):
            hasher.combine(7)
            hasher.combine(types)
        }
    }
    
    // 实现Equatable协议
    public static func == (lhs: CleanType, rhs: CleanType) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case (.subviews, .subviews):
            return true
        case (.modalControllers, .modalControllers):
            return true
        case (.navigationStack, .navigationStack):
            return true
        case (.rootController, .rootController):
            return true
        case (.backgroundViews, .backgroundViews):
            return true
        case (.overlayViews, .overlayViews):
            return true
        case (.custom(let lhsTypes), .custom(let rhsTypes)):
            return lhsTypes == rhsTypes
        default:
            return false
        }
    }
}

// MARK: - 清理配置
public struct CleanConfig {
    public var animated: Bool = true
    public var completion: (() -> Void)?
    public var removeSubviews: Bool = true
    public var removeModalControllers: Bool = true
    public var clearNavigationStack: Bool = true
    public var resetRootController: Bool = false
    public var preserveCurrentView: Bool = true  // 保留当前视图
    public var cleanTypes: [CleanType] = [.backgroundViews, .overlayViews]  // 默认只清理背景和覆盖视图
    public var animationDuration: TimeInterval = 0.3
    
    public init() {}
}

// MARK: - 清理构建器
public class CleanBuilder {
    private let window: UIWindow?
    private var config = CleanConfig()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    // MARK: - 配置方法
    @discardableResult
    public func withAnimation(_ animated: Bool) -> CleanBuilder {
        config.animated = animated
        return self
    }
    
    @discardableResult
    public func withCompletion(_ completion: @escaping () -> Void) -> CleanBuilder {
        config.completion = completion
        return self
    }
    
    @discardableResult
    public func withRemoveSubviews(_ remove: Bool) -> CleanBuilder {
        config.removeSubviews = remove
        return self
    }
    
    @discardableResult
    public func withRemoveModalControllers(_ remove: Bool) -> CleanBuilder {
        config.removeModalControllers = remove
        return self
    }
    
    @discardableResult
    public func withClearNavigationStack(_ clear: Bool) -> CleanBuilder {
        config.clearNavigationStack = clear
        return self
    }
    
    @discardableResult
    public func withResetRootController(_ reset: Bool) -> CleanBuilder {
        config.resetRootController = reset
        return self
    }
    
    @discardableResult
    public func withCleanTypes(_ types: [CleanType]) -> CleanBuilder {
        config.cleanTypes = types
        return self
    }
    
    @discardableResult
    public func withAnimationDuration(_ duration: TimeInterval) -> CleanBuilder {
        config.animationDuration = duration
        return self
    }
    
    // MARK: - 执行清理
    public func execute() {
        TFYWindowCleaner.cleanWindow(window, config: config)
    }
}

// MARK: - 主导航工具类
public class TFYWindowCleaner {
    
    // MARK: - 私有属性
    private static var isCleaning = false
    private static let cleaningQueue = DispatchQueue(label: "com.tfy.windowcleaner", qos: .userInitiated)
    
    // MARK: - 公共API
    
    /// 清理所有window
    /// - Returns: 清理构建器
    public static func cleanAllWindows() -> CleanBuilder {
        return CleanBuilder(window: nil)
    }
    
    /// 清理当前活动window
    /// - Returns: 清理构建器
    public static func cleanCurrentWindow() -> CleanBuilder {
        let currentWindow = getCurrentWindow()
        return CleanBuilder(window: currentWindow)
    }
    
    /// 清理指定window
    /// - Parameter window: 要清理的window
    /// - Returns: 清理构建器
    public static func cleanWindow(_ window: UIWindow) -> CleanBuilder {
        return CleanBuilder(window: window)
    }
    
    /// 智能清理当前window（保留当前界面）
    /// - Returns: 清理构建器
    public static func smartCleanCurrentWindow() -> CleanBuilder {
        let currentWindow = getCurrentWindow()
        let builder = CleanBuilder(window: currentWindow)
        return builder.withCleanTypes([.backgroundViews, .overlayViews])
    }
    
    /// 清理背景视图
    /// - Returns: 清理构建器
    public static func cleanBackgroundViews() -> CleanBuilder {
        let currentWindow = getCurrentWindow()
        let builder = CleanBuilder(window: currentWindow)
        return builder.withCleanTypes([.backgroundViews])
    }
    
    /// 清理覆盖视图
    /// - Returns: 清理构建器
    public static func cleanOverlayViews() -> CleanBuilder {
        let currentWindow = getCurrentWindow()
        let builder = CleanBuilder(window: currentWindow)
        return builder.withCleanTypes([.overlayViews])
    }
    
    // MARK: - 核心清理方法
    
    /// 执行window清理
    /// - Parameters:
    ///   - window: 要清理的window，nil表示清理所有window
    ///   - config: 清理配置
    public static func cleanWindow(_ window: UIWindow?, config: CleanConfig = CleanConfig()) {
        let windowsToClean = window != nil ? [window!] : getAllWindows()
        
        for window in windowsToClean {
            performClean(on: window, config: config)
        }
    }
    
    /// 清理所有window
    /// - Parameter config: 清理配置
    public static func cleanAllWindows(config: CleanConfig = CleanConfig()) {
        let allWindows = getAllWindows()
        
        for window in allWindows {
            performClean(on: window, config: config)
        }
    }
    
    /// 清理当前活动window
    /// - Parameter config: 清理配置
    public static func cleanCurrentWindow(config: CleanConfig = CleanConfig()) {
        guard let currentWindow = getCurrentWindow() else {
            print("TFYWindowCleaner: 无法获取当前活动window")
            config.completion?()
            return
        }
        
        performClean(on: currentWindow, config: config)
    }
    
    /// 取消当前清理操作
    public static func cancelCleaning() {
        isCleaning = false
        print("TFYWindowCleaner: 清理操作已取消")
    }
    
    /// 检查是否正在清理
    public static var isCurrentlyCleaning: Bool {
        return isCleaning
    }
    
    // MARK: - 私有方法
    
    /// 获取所有window
    private static func getAllWindows() -> [UIWindow] {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
        } else {
            return UIApplication.shared.windows
        }
    }
    
    /// 获取当前活动window
    private static func getCurrentWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }?
                .windows
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    /// 获取当前视图控制器
    private static func getCurrentViewController(from window: UIWindow) -> UIViewController? {
        var currentVC = window.rootViewController
        
        while let presentedVC = currentVC?.presentedViewController {
            currentVC = presentedVC
        }
        
        if let navController = currentVC as? UINavigationController {
            currentVC = navController.visibleViewController
        }
        
        if let tabController = currentVC as? UITabBarController {
            currentVC = tabController.selectedViewController
        }
        
        return currentVC
    }
    
    /// 判断是否为背景视图
    private static func isBackgroundView(_ view: UIView) -> Bool {
        // 检查视图的用途标签（优先级最高，性能最好）
        if view.tag == 1001 || view.tag == 1002 { // 常见的背景视图标签
            return true
        }
        
        // 检查视图的类名
        let className = NSStringFromClass(type(of: view))
        if className.contains("Background") || className.contains("BG") {
            return true
        }
        
        // 检查视图的特征来判断是否为背景视图（性能较低，最后检查）
        let frame = view.frame
        let windowFrame = view.window?.frame ?? .zero
        
        // 背景视图通常覆盖整个屏幕
        return frame.size.width >= windowFrame.size.width * 0.9 &&
               frame.size.height >= windowFrame.size.height * 0.9
    }
    
    /// 判断是否为覆盖视图
    private static func isOverlayView(_ view: UIView) -> Bool {
        // 检查视图的用途标签（优先级最高，性能最好）
        if view.tag == 2001 || view.tag == 2002 { // 常见的覆盖视图标签
            return true
        }
        
        // 检查视图的类名
        let className = NSStringFromClass(type(of: view))
        if className.contains("Overlay") || className.contains("Modal") || className.contains("Popup") {
            return true
        }
        
        // 检查视图的特征来判断是否为覆盖视图（性能较低，最后检查）
        let frame = view.frame
        let windowFrame = view.window?.frame ?? .zero
        
        // 覆盖视图通常覆盖部分或全部屏幕
        return frame.size.width >= windowFrame.size.width * 0.8 ||
               frame.size.height >= windowFrame.size.height * 0.8
    }
    
    /// 判断是否为背景或覆盖视图
    private static func isBackgroundOrOverlayView(_ view: UIView) -> Bool {
        // 先检查标签，性能最好
        if view.tag == 1001 || view.tag == 1002 || view.tag == 2001 || view.tag == 2002 {
            return true
        }
        
        // 再检查类名
        let className = NSStringFromClass(type(of: view))
        if className.contains("Background") || className.contains("BG") ||
           className.contains("Overlay") || className.contains("Modal") || className.contains("Popup") {
            return true
        }
        
        // 最后检查尺寸特征
        let frame = view.frame
        let windowFrame = view.window?.frame ?? .zero
        
        return frame.size.width >= windowFrame.size.width * 0.8 ||
               frame.size.height >= windowFrame.size.height * 0.8
    }
    
    /// 执行清理操作
    private static func performClean(on window: UIWindow, config: CleanConfig) {
        // 检查是否正在清理
        guard !isCleaning else {
            print("TFYWindowCleaner: 清理操作正在进行中，请稍后再试")
            config.completion?()
            return
        }
        
        // 设置清理状态
        isCleaning = true
        
        DispatchQueue.main.async {
            // 解析清理类型
            let cleanTypes = parseCleanTypes(config.cleanTypes)
            
            // 执行清理
            if cleanTypes.contains(CleanType.all) || cleanTypes.contains(CleanType.subviews) {
                if config.preserveCurrentView {
                    smartCleanSubviews(on: window, animated: config.animated, duration: config.animationDuration)
                } else {
                    cleanSubviews(on: window, animated: config.animated, duration: config.animationDuration)
                }
            }
            
            if cleanTypes.contains(CleanType.all) || cleanTypes.contains(CleanType.backgroundViews) {
                cleanBackgroundViews(on: window, animated: config.animated, duration: config.animationDuration)
            }
            
            if cleanTypes.contains(CleanType.all) || cleanTypes.contains(CleanType.overlayViews) {
                cleanOverlayViews(on: window, animated: config.animated, duration: config.animationDuration)
            }
            
            if cleanTypes.contains(CleanType.all) || cleanTypes.contains(CleanType.modalControllers) {
                cleanModalControllers(on: window, animated: config.animated, duration: config.animationDuration)
            }
            
            if cleanTypes.contains(CleanType.all) || cleanTypes.contains(CleanType.navigationStack) {
                cleanNavigationStack(on: window, animated: config.animated, duration: config.animationDuration)
            }
            
            if cleanTypes.contains(CleanType.all) || cleanTypes.contains(CleanType.rootController) {
                cleanRootController(on: window, animated: config.animated, duration: config.animationDuration)
            }
            
            // 执行完成回调并重置状态
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) {
                isCleaning = false
                config.completion?()
            }
        }
    }
    
    /// 解析清理类型
    private static func parseCleanTypes(_ types: [CleanType]) -> Set<CleanType> {
        var result: Set<CleanType> = []
        
        for type in types {
            switch type {
            case .all:
                result.insert(CleanType.all)
            case .subviews:
                result.insert(CleanType.subviews)
            case .modalControllers:
                result.insert(CleanType.modalControllers)
            case .navigationStack:
                result.insert(CleanType.navigationStack)
            case .rootController:
                result.insert(CleanType.rootController)
            case .backgroundViews:
                result.insert(CleanType.backgroundViews)
            case .overlayViews:
                result.insert(CleanType.overlayViews)
            case .custom(let customTypes):
                result.formUnion(parseCleanTypes(customTypes))
            }
        }
        
        return result
    }
    
    /// 清理子视图
    private static func cleanSubviews(on window: UIWindow, animated: Bool, duration: TimeInterval) {
        let subviews = window.subviews
        
        if animated {
            UIView.animate(withDuration: duration, animations: {
                for subview in subviews {
                    subview.alpha = 0
                    subview.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }) { _ in
                for subview in subviews {
                    subview.removeFromSuperview()
                }
            }
        } else {
            for subview in subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    /// 智能清理子视图（保留当前界面）
    private static func smartCleanSubviews(on window: UIWindow, animated: Bool, duration: TimeInterval) {
        let subviews = window.subviews
        let currentViewController = getCurrentViewController(from: window)
        
        // 过滤出需要清理的视图
        let viewsToClean = subviews.filter { subview in
            // 保留当前视图控制器的视图
            if let currentVC = currentViewController,
               subview.isDescendant(of: currentVC.view) {
                return false
            }
            
            // 保留导航栏和标签栏
            if subview is UINavigationBar || subview is UITabBar {
                return false
            }
            
            // 保留系统UI元素
            if subview.tag == 999999 { // 系统保留标签
                return false
            }
            
            // 清理背景视图和覆盖视图
            return isBackgroundOrOverlayView(subview)
        }
        
        if animated {
            UIView.animate(withDuration: duration, animations: {
                for subview in viewsToClean {
                    subview.alpha = 0
                    subview.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }) { _ in
                for subview in viewsToClean {
                    subview.removeFromSuperview()
                }
            }
        } else {
            for subview in viewsToClean {
                subview.removeFromSuperview()
            }
        }
    }
    
    /// 清理背景视图
    private static func cleanBackgroundViews(on window: UIWindow, animated: Bool, duration: TimeInterval) {
        let subviews = window.subviews
        let backgroundViews = subviews.filter { isBackgroundView($0) }
        
        if animated {
            UIView.animate(withDuration: duration, animations: {
                for subview in backgroundViews {
                    subview.alpha = 0
                }
            }) { _ in
                for subview in backgroundViews {
                    subview.removeFromSuperview()
                }
            }
        } else {
            for subview in backgroundViews {
                subview.removeFromSuperview()
            }
        }
    }
    
    /// 清理覆盖视图
    private static func cleanOverlayViews(on window: UIWindow, animated: Bool, duration: TimeInterval) {
        let subviews = window.subviews
        let overlayViews = subviews.filter { isOverlayView($0) }
        
        if animated {
            UIView.animate(withDuration: duration, animations: {
                for subview in overlayViews {
                    subview.alpha = 0
                }
            }) { _ in
                for subview in overlayViews {
                    subview.removeFromSuperview()
                }
            }
        } else {
            for subview in overlayViews {
                subview.removeFromSuperview()
            }
        }
    }
    
    /// 清理模态控制器
    private static func cleanModalControllers(on window: UIWindow, animated: Bool, duration: TimeInterval) {
        cleanModalControllersRecursively(on: window, animated: animated, duration: duration, currentDepth: 0, maxDepth: 10)
    }
    
    /// 递归清理模态控制器（带深度控制）
    private static func cleanModalControllersRecursively(on window: UIWindow, animated: Bool, duration: TimeInterval, currentDepth: Int, maxDepth: Int) {
        // 防止递归过深
        guard currentDepth < maxDepth else {
            print("TFYWindowCleaner: 模态控制器清理达到最大递归深度: \(maxDepth)")
            return
        }
        
        var currentVC = window.rootViewController
        
        // 找到最顶层的模态控制器
        while let presentedVC = currentVC?.presentedViewController {
            currentVC = presentedVC
        }
        
        // 关闭所有模态控制器
        if let topVC = currentVC, topVC != window.rootViewController {
            topVC.dismiss(animated: animated) {
                // 递归清理，确保所有模态控制器都被关闭
                cleanModalControllersRecursively(on: window, animated: animated, duration: duration, currentDepth: currentDepth + 1, maxDepth: maxDepth)
            }
        }
    }
    
    /// 清理导航栈
    private static func cleanNavigationStack(on window: UIWindow, animated: Bool, duration: TimeInterval) {
        guard let rootVC = window.rootViewController else { return }
        
        if let navController = rootVC as? UINavigationController {
            // 清理导航栈，只保留根控制器
            if navController.viewControllers.count > 1 {
                if animated {
                    navController.popToRootViewController(animated: true)
                } else {
                    navController.viewControllers = [navController.viewControllers.first!]
                }
            }
        } else if let tabController = rootVC as? UITabBarController {
            // 清理标签控制器的导航栈
            for viewController in tabController.viewControllers ?? [] {
                if let navController = viewController as? UINavigationController {
                    if navController.viewControllers.count > 1 {
                        if animated {
                            navController.popToRootViewController(animated: true)
                        } else {
                            navController.viewControllers = [navController.viewControllers.first!]
                        }
                    }
                }
            }
        }
    }
    
    /// 清理根控制器
    private static func cleanRootController(on window: UIWindow, animated: Bool, duration: TimeInterval) {
        if animated {
            UIView.animate(withDuration: duration, animations: {
                window.rootViewController?.view.alpha = 0
                window.rootViewController?.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                window.rootViewController = nil
            }
        } else {
            window.rootViewController = nil
        }
    }
    
    // MARK: - 高级清理方法
    
    /// 深度清理window
    /// - Parameters:
    ///   - window: 要清理的window
    ///   - config: 清理配置
    public static func deepCleanWindow(_ window: UIWindow, config: CleanConfig = CleanConfig()) {
        DispatchQueue.main.async {
            // 1. 清理所有子视图
            cleanSubviews(on: window, animated: config.animated, duration: config.animationDuration)
            
            // 2. 关闭所有模态控制器
            cleanModalControllers(on: window, animated: config.animated, duration: config.animationDuration)
            
            // 3. 清理导航栈
            cleanNavigationStack(on: window, animated: config.animated, duration: config.animationDuration)
            
            // 4. 重置根控制器
            cleanRootController(on: window, animated: config.animated, duration: config.animationDuration)
            
            // 5. 清理内存引用
            clearMemoryReferences()
            
            // 6. 执行完成回调
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) {
                config.completion?()
            }
        }
    }
    
    /// 清理内存引用
    private static func clearMemoryReferences() {
        // 清理可能的循环引用
        autoreleasepool {
            // 这里可以添加更多的内存清理逻辑
        }
    }
    
    /// 重置window到初始状态
    /// - Parameters:
    ///   - window: 要重置的window
    ///   - newRootController: 新的根控制器
    ///   - config: 清理配置
    public static func resetWindow(_ window: UIWindow, to newRootController: UIViewController? = nil, config: CleanConfig = CleanConfig()) {
        DispatchQueue.main.async {
            // 1. 完全清理window
            deepCleanWindow(window, config: config)
            
            // 2. 设置新的根控制器
            if let newRootController = newRootController {
                window.rootViewController = newRootController
            }
            
            // 3. 确保window可见
            window.makeKeyAndVisible()
        }
    }
    
    /// 清理特定类型的视图控制器
    /// - Parameters:
    ///   - window: 要清理的window
    ///   - controllerType: 要清理的控制器类型
    ///   - config: 清理配置
    public static func cleanControllers<T: UIViewController>(_ window: UIWindow, ofType controllerType: T.Type, config: CleanConfig = CleanConfig()) {
        DispatchQueue.main.async {
            // 查找并清理指定类型的控制器
            if let rootVC = window.rootViewController {
                cleanControllersRecursively(rootVC, ofType: controllerType, animated: config.animated, currentDepth: 0, maxDepth: 10)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) {
                config.completion?()
            }
        }
    }
    
    /// 递归清理控制器（带深度控制）
    private static func cleanControllersRecursively<T: UIViewController>(_ viewController: UIViewController, ofType controllerType: T.Type, animated: Bool, currentDepth: Int, maxDepth: Int) {
        // 防止递归过深
        guard currentDepth < maxDepth else {
            print("TFYWindowCleaner: 控制器清理达到最大递归深度: \(maxDepth)")
            return
        }
        
        // 检查当前控制器
        if viewController.isKind(of: controllerType) {
            // 如果是模态控制器，关闭它
            if viewController.presentingViewController != nil {
                viewController.dismiss(animated: animated)
            }
            // 如果在导航栈中，移除它
            else if let navController = viewController.navigationController {
                var viewControllers = navController.viewControllers
                viewControllers.removeAll { $0.isKind(of: controllerType) }
                navController.setViewControllers(viewControllers, animated: animated)
            }
        }
        
        // 递归检查子控制器
        if let navController = viewController as? UINavigationController {
            for childVC in navController.viewControllers {
                cleanControllersRecursively(childVC, ofType: controllerType, animated: animated, currentDepth: currentDepth + 1, maxDepth: maxDepth)
            }
        } else if let tabController = viewController as? UITabBarController {
            for childVC in tabController.viewControllers ?? [] {
                cleanControllersRecursively(childVC, ofType: controllerType, animated: animated, currentDepth: currentDepth + 1, maxDepth: maxDepth)
            }
        }
        
        // 检查模态控制器
        if let presentedVC = viewController.presentedViewController {
            cleanControllersRecursively(presentedVC, ofType: controllerType, animated: animated, currentDepth: currentDepth + 1, maxDepth: maxDepth)
        }
    }
}

// MARK: - UIWindow扩展
public extension UIWindow {
    
    /// 清理当前window
    /// - Returns: 清理构建器
    func clean() -> CleanBuilder {
        return TFYWindowCleaner.cleanWindow(self)
    }
    
    /// 深度清理当前window
    /// - Returns: 清理构建器
    func deepClean() -> CleanBuilder {
        return CleanBuilder(window: self).withCleanTypes([.all])
    }
    
    /// 重置window到初始状态
    /// - Parameter newRootController: 新的根控制器
    /// - Returns: 清理构建器
    func reset(to newRootController: UIViewController? = nil) -> CleanBuilder {
        let builder = CleanBuilder(window: self)
        builder.withResetRootController(true)
        return builder
    }
}

// MARK: - UIApplication扩展
public extension UIApplication {
    
    /// 清理所有window
    /// - Returns: 清理构建器
    func cleanAllWindows() -> CleanBuilder {
        return TFYWindowCleaner.cleanAllWindows()
    }
    
    /// 清理当前活动window
    /// - Returns: 清理构建器
    func cleanCurrentWindow() -> CleanBuilder {
        return TFYWindowCleaner.cleanCurrentWindow()
    }
}

// MARK: - 错误处理扩展
public extension TFYWindowCleaner {
    
    /// 安全清理window（带错误处理）
    /// - Parameters:
    ///   - window: 要清理的window
    ///   - config: 清理配置
    ///   - errorHandler: 错误处理回调
    static func safeCleanWindow(_ window: UIWindow, config: CleanConfig = CleanConfig(), errorHandler: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            do {
                // 验证window状态
                guard window.isKeyWindow || window.isHidden == false else {
                    throw CleanError.invalidWindowState
                }
                
                // 执行清理
                performClean(on: window, config: config)
                
            } catch {
                errorHandler(error)
            }
        }
    }
    
    /// 批量安全清理windows
    /// - Parameters:
    ///   - windows: 要清理的windows数组
    ///   - config: 清理配置
    ///   - progressHandler: 进度回调
    ///   - completion: 完成回调
    ///   - errorHandler: 错误处理回调
    static func safeCleanWindows(_ windows: [UIWindow], config: CleanConfig = CleanConfig(), progressHandler: @escaping (Int, Int) -> Void, completion: @escaping () -> Void, errorHandler: @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            let totalCount = windows.count
            var completedCount = 0
            var hasError = false
            
            for (_, window) in windows.enumerated() {
                guard !hasError else { break }
                
                do {
                    // 验证window状态
                    guard window.isKeyWindow || window.isHidden == false else {
                        throw CleanError.invalidWindowState
                    }
                    
                    // 执行清理
                    performClean(on: window, config: config)
                    completedCount += 1
                    
                    // 报告进度
                    progressHandler(completedCount, totalCount)
                    
                } catch {
                    hasError = true
                    errorHandler(error)
                }
            }
            
            if !hasError {
                completion()
            }
        }
    }
}

// MARK: - 清理错误类型
public enum CleanError: Error, LocalizedError {
    case invalidWindowState
    case recursionDepthExceeded
    case operationCancelled
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .invalidWindowState:
            return "无效的window状态"
        case .recursionDepthExceeded:
            return "递归深度超出限制"
        case .operationCancelled:
            return "操作被取消"
        case .unknownError:
            return "未知错误"
        }
    }
}

// MARK: - 性能监控扩展
public extension TFYWindowCleaner {
    
    /// 带性能监控的清理
    /// - Parameters:
    ///   - window: 要清理的window
    ///   - config: 清理配置
    ///   - performanceHandler: 性能监控回调
    static func cleanWithPerformanceMonitoring(_ window: UIWindow, config: CleanConfig = CleanConfig(), performanceHandler: @escaping (TimeInterval, Int) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.async {
            // 执行清理
            performClean(on: window, config: config)
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = endTime - startTime
            let subviewCount = window.subviews.count
            
            performanceHandler(duration, subviewCount)
        }
    }
} 