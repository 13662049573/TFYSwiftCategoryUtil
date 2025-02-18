//
//  TFYUtils.swift
//  TFYSwiftCategoryUtil
//
// 田风有 on 2022/5/12.
//

import Foundation
import UIKit
import StoreKit
import SystemConfiguration.CaptiveNetwork
import Combine
import Network
import LocalAuthentication

// MARK: - 文件路径常量
public struct FilePath {
    /// 文档目录路径
    public static let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as NSString
    
    /// 缓存目录路径
    public static let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! as NSString
    
    /// 临时目录路径
    public static let temp = NSTemporaryDirectory() as NSString
}

// MARK: - 主工具类
public enum TFYUtils {
    
    // MARK: - 窗口管理
    public enum Window {
        /// 获取当前活动窗口
        public static var current: UIWindow? {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }?
                .windows
                .first(where: \.isKeyWindow)
        }
        
        /// 获取顶层视图控制器
        public static var topViewController: UIViewController? {
            guard let window = current else { return nil }
            
            func findTop(from controller: UIViewController?) -> UIViewController? {
                if let nav = controller as? UINavigationController {
                    return findTop(from: nav.visibleViewController)
                }
                if let tab = controller as? UITabBarController {
                    return findTop(from: tab.selectedViewController)
                }
                if let presented = controller?.presentedViewController {
                    return findTop(from: presented)
                }
                return controller
            }
            
            return findTop(from: window.rootViewController)
        }
    }
    
    // MARK: - 增强日志系统
    public enum Logger {
        /// 日志级别
        public enum Level: String, CaseIterable {
            case debug = "🟢 DEBUG"
            case info = "🔵 INFO"
            case warning = "🟠 WARNING"
            case error = "🔴 ERROR"
        }
        
        /// 日志配置
        public struct Config {
            public static var maxFileSize: Int = 1024 * 1024 * 5 // 5MB
            public static var maxFiles: Int = 7 // 保留7天
            public static var enabledLevels: Set<Level> = Set(Level.allCases)
        }
        
        /// 分级日志记录
        public static func log(
            _ items: Any...,
            level: Level = .debug,
            file: String = #fileID,
            line: Int = #line,
            function: String = #function
        ) {
            guard Config.enabledLevels.contains(level) else { return }
            
            let content = buildLogContent(items, level: level, file: file, line: line, function: function)
            print(content)
            writeToRotatedFile(content: content)
        }
        
        private static func buildLogContent(
            _ items: [Any],
            level: Level,
            file: String,
            line: Int,
            function: String
        ) -> String {
            let timestamp = Date().ISO8601Format()
            let message = items.map { "\($0)" }.joined(separator: " ")
            return "\(timestamp) \(level.rawValue) [\(file):\(line)] \(function) - \(message)"
        }
        
        private static func writeToRotatedFile(content: String) {
            let fileManager = Foundation.FileManager.default
            let logDir = FilePath.cache.appendingPathComponent("logs")
            
            // 创建日志目录
            if !fileManager.fileExists(atPath: logDir) {
                try? fileManager.createDirectory(atPath: logDir, withIntermediateDirectories: true)
            }
            
            // 按日期分文件
            let formatter = Foundation.DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let filename = "app_\(formatter.string(from: Date())).log"
            let filePath = (logDir as NSString).appendingPathComponent(filename)
            
            // 写入文件
            if let data = (content + "\n").data(using: .utf8) {
                if fileManager.fileExists(atPath: filePath) {
                    if let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: filePath)) {
                        handle.seekToEndOfFile()
                        handle.write(data)
                        try? handle.close()
                    }
                } else {
                    try? data.write(to: URL(fileURLWithPath: filePath))
                }
            }
            
            cleanOldLogs()
        }
        
        private static func cleanOldLogs() {
            let fileManager = Foundation.FileManager.default
            let logDir = FilePath.cache.appendingPathComponent("logs")
            
            guard let files = try? fileManager.contentsOfDirectory(atPath: logDir),
                  files.count > Config.maxFiles else { return }
            
            let sortedFiles = files.sorted()
            let filesToDelete = sortedFiles[0..<(sortedFiles.count - Config.maxFiles)]
            
            filesToDelete.forEach { file in
                let fullPath = (logDir as NSString).appendingPathComponent(file)
                try? fileManager.removeItem(atPath: fullPath)
            }
        }
    }
    
    // MARK: - 内购管理
    public enum IAP {
        public enum PurchaseError: Error, CustomStringConvertible {
            case paymentNotAllowed
            case invalidProduct
            case purchaseFailed(SKError)
            case verificationFailed
            
            public var description: String {
                switch self {
                case .paymentNotAllowed: return "支付功能不可用"
                case .invalidProduct: return "无效商品ID"
                case .purchaseFailed(let error): return "购买失败: \(error.localizedDescription)"
                case .verificationFailed: return "购买验证失败"
                }
            }
        }
        
        /// 安全购买方法
        public static func purchase(
            productId: String,
            completion: @escaping (Result<Transaction, PurchaseError>) -> Void
        ) {
            guard SKPaymentQueue.canMakePayments() else {
                completion(.failure(.paymentNotAllowed))
                return
            }
            
            Task {
                do {
                    let products = try await Product.products(for: [productId])
                    guard let product = products.first else {
                        completion(.failure(.invalidProduct))
                        return
                    }
                    
                    let result = try await product.purchase()
                    switch result {
                    case .success(let verification):
                        let transaction = try checkVerified(verification)
                        await transaction.finish()
                        completion(.success(transaction))
                    case .pending:
                        throw SKError(.paymentNotAllowed)
                    case .userCancelled:
                        throw SKError(.paymentCancelled)
                    @unknown default:
                        throw SKError(.unknown)
                    }
                } catch let error as SKError {
                    completion(.failure(.purchaseFailed(error)))
                } catch {
                    completion(.failure(.verificationFailed))
                }
            }
        }
        
        private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
            switch result {
            case .unverified:
                throw PurchaseError.verificationFailed
            case .verified(let safe):
                return safe
            }
        }
    }
    
    // MARK: - 网络工具
    public enum Network {
        public enum Status: CustomStringConvertible {
            case wifi
            case cellular
            case disconnected
            
            public var description: String {
                switch self {
                case .wifi: return "Wi-Fi"
                case .cellular: return "蜂窝网络"
                case .disconnected: return "无网络连接"
                }
            }
        }
        
        /// 实时网络状态监测
        public static func monitor(handler: @escaping (Status) -> Void) -> NWPathMonitor {
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "com.tfy.network.monitor")
            
            monitor.pathUpdateHandler = { path in
                let status: Status
                switch path.status {
                case .satisfied:
                    status = path.usesInterfaceType(.wifi) ? .wifi : .cellular
                default:
                    status = .disconnected
                }
                DispatchQueue.main.async { handler(status) }
            }
            
            monitor.start(queue: queue)
            return monitor
        }
        
        /// 当前网络状态
        public static var currentStatus: Status {
            let monitor = NWPathMonitor()
            let semaphore = DispatchSemaphore(value: 0)
            var currentStatus: Status = .disconnected
            
            monitor.pathUpdateHandler = { path in
                switch path.status {
                case .satisfied:
                    currentStatus = path.usesInterfaceType(.wifi) ? .wifi : .cellular
                default:
                    currentStatus = .disconnected
                }
                semaphore.signal()
            }
            
            let queue = DispatchQueue(label: "com.tfy.network.status")
            monitor.start(queue: queue)
            semaphore.wait()
            return currentStatus
        }
    }
    
    // MARK: - 系统功能
    public enum System {
        /// 安全打开URL
        public static func openURL(_ urlString: String) async -> Bool {
            guard let url = URL(string: urlString),
                  await UIApplication.shared.canOpenURL(url) else {
                return false
            }
            
            return await UIApplication.shared.open(url)
        }
        
        /// 拨打电话
        public static func call(_ number: String) async -> Bool {
            let urlString = "tel://\(number)"
            return await openURL(urlString)
        }
        
        /// 跳转App Store评分
        public static func requestReview() {
            if let scene = UIApplication.shared.connectedScenes.first(where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    public enum viewController {
    
            // MARK: - 容器控制器查找
            /// 获取当前视图所在的容器控制器（增强版）
            /// - Parameters:
            ///   - types: 优先查找的容器类型顺序，默认 [UINavigationController.self, UITabBarController.self]
            /// - Returns: 找到的第一个匹配的容器控制器
            public static func currentContainer(
                for viewController: UIViewController,
                types: [UIViewController.Type] = [UINavigationController.self, UITabBarController.self]
            ) -> UIViewController? {
                // 优先检查直接父级关系
                for type in types {
                    if let container = findContainer(from: viewController, type: type) {
                        return container
                    }
                }
                // 扩展查找层级
                return findExtendedContainer(from: viewController, types: types)
            }
            
            /// 当前容器控制器（便捷访问）
            public static var currentContainer: UIViewController? {
                guard let currentVC = Window.topViewController else {
                    Logger.log("无法获取当前视图控制器", level: .warning)
                    return nil
                }
                return currentContainer(for: currentVC)
            }
            
            // MARK: - 私有方法
            private static func currentContainer(for controller: UIViewController) -> UIViewController? {
                currentContainer(for: controller, types: [UINavigationController.self, UITabBarController.self])
            }
            
            private static func findExtendedContainer(
                from source: UIViewController,
                types: [UIViewController.Type]
            ) -> UIViewController? {
                var current: UIViewController? = source
                
                while let controller = current {
                    for type in types {
                        if controller.isKind(of: type) {
                            return controller
                        }
                    }
                    current = getNextParent(for: controller)
                }
                return nil
            }
            
            private static func getNextParent(for controller: UIViewController) -> UIViewController? {
                if let parent = controller.parent { return parent }
                if let presenting = controller.presentingViewController { return presenting }
                if let navParent = controller.navigationController { return navParent }
                if let tabParent = controller.tabBarController { return tabParent }
                return nil
            }
            
            // MARK: - 容器查找
            public static func findContainer<T: UIViewController>(
                from source: UIViewController,
                type: T.Type
            ) -> T? {
                if let target = source as? T { return target }
                if let parent = source.parent { return findContainer(from: parent, type: type) }
                if let presented = source.presentedViewController { return findContainer(from: presented, type: type) }
                if let nav = source.navigationController { return findContainer(from: nav, type: type) }
                if let tab = source.tabBarController { return findContainer(from: tab, type: type) }
                return nil
            }
            
            // MARK: - 控制器操作
            /// 关闭控制器
            public static func dismiss(_ controller: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
                DispatchQueue.main.async {
                    controller.dismiss(animated: animated, completion: completion)
                }
            }
            
            // MARK: - 页面跳转
            /// 返回到指定类型的控制器界面
            public static func returnTo<T: UIViewController>(
                _ type: T.Type,
                animated: Bool = true,
                inclusive: Bool = false,
                completion: @escaping (Bool) -> Void
            ) {
                guard let currentVC = Window.topViewController else {
                    Logger.log("无法获取当前视图控制器", level: .warning)
                    completion(false)
                    return
                }
                
                guard let targetVC = findTargetViewController(from: currentVC, type: type, inclusive: inclusive) else {
                    Logger.log("未找到 \(type) 类型的控制器", level: .info)
                    completion(false)
                    return
                }
                
                performNavigation(to: targetVC, from: currentVC, animated: animated, completion: completion)
            }
            
            // MARK: - 私有实现
            private static func findTargetViewController<T: UIViewController>(
                from source: UIViewController,
                type: T.Type,
                inclusive: Bool
            ) -> T? {
                var controllers = [UIViewController]()
                
                if let nav = source.navigationController {
                    controllers = nav.viewControllers
                } else if let presentedChain = getPresentedChain(from: source) {
                    controllers = presentedChain
                }
                
                let matched = controllers.reversed().first { controller in
                    inclusive ? controller.isKind(of: type) : (controller != source && controller.isKind(of: type))
                }
                
                return matched as? T
            }
            
            private static func getPresentedChain(from source: UIViewController) -> [UIViewController]? {
                var chain = [UIViewController]()
                var current: UIViewController? = source
                
                while let controller = current {
                    chain.append(controller)
                    current = controller.presentingViewController
                }
                
                return chain.isEmpty ? nil : chain
            }
            
            private static func performNavigation<T: UIViewController>(
                to target: T,
                from source: UIViewController,
                animated: Bool,
                completion: @escaping (Bool) -> Void
            ) {
                if let nav = source.navigationController, nav.viewControllers.contains(target) {
                    popToViewController(nav: nav, target: target, animated: animated, completion: completion)
                } else if source.presentingViewController != nil {
                    dismissToViewController(source: source, target: target, animated: animated, completion: completion)
                } else {
                    completion(false)
                }
            }
            
            private static func popToViewController<T: UIViewController>(
                nav: UINavigationController,
                target: T,
                animated: Bool,
                completion: @escaping (Bool) -> Void
            ) {
                DispatchQueue.main.async {
                    nav.popToViewController(target, animated: animated) { _ in
                        completion(true)
                    }
                }
            }
            
            private static func dismissToViewController<T: UIViewController>(
                source: UIViewController,
                target: T,
                animated: Bool,
                completion: @escaping (Bool) -> Void
            ) {
                DispatchQueue.main.async {
                    source.dismiss(animated: animated) {
                        completion(true)
                    }
                }
            }
        }
}

// MARK: - 新增设备信息模块
public extension TFYUtils {
    
    enum Device {
        /// 设备类型判断
        public enum ModelType {
            case iPhone
            case iPad
            case mac
            case carPlay
            case unspecified
        }
        
        /// 当前设备类型
        public static var modelType: ModelType {
            #if targetEnvironment(macCatalyst)
            return .mac
            #elseif targetEnvironment(simulator)
            return .unspecified
            #else
            switch UIDevice.current.userInterfaceIdiom {
            case .phone: return .iPhone
            case .pad: return .iPad
            case .carPlay: return .carPlay
            default: return .unspecified
            }
            #endif
        }
        
        /// 设备安全区域
        public static var safeAreaInsets: UIEdgeInsets {
            Window.current?.safeAreaInsets ?? .zero
        }
        
        /// 设备名称
        public static var name: String {
            UIDevice.current.name
        }
        
        /// 系统版本
        public static var systemVersion: String {
            UIDevice.current.systemVersion
        }
        
        /// 是否是刘海屏设备
        public static var hasNotch: Bool {
            safeAreaInsets.top > 20
        }
        
        /// 屏幕尺寸
        public static var screenSize: CGSize {
            UIScreen.main.bounds.size
        }
        
        /// 电池电量
        public static var batteryLevel: Float {
            UIDevice.current.isBatteryMonitoringEnabled = true
            return UIDevice.current.batteryLevel
        }
        
        /// 是否处于低电量模式
        public static var isLowPowerModeEnabled: Bool {
            ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}

// MARK: - 新增安全存储模块
public extension TFYUtils {
    enum Keychain {
        /// 安全存储数据
        public static func save(_ data: Data, service: String, account: String) throws {
            let query = [
                kSecValueData: data,
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account
            ] as CFDictionary
            
            let status = SecItemAdd(query, nil)
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
        }
        
        /// 读取安全数据
        public static func read(service: String, account: String) throws -> Data {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecReturnData: true
            ] as CFDictionary
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query, &result)
            
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
            
            return result as? Data ?? Data()
        }
        
        public enum KeychainError: Error {
            case unhandledError(status: OSStatus)
        }
    }
}

// MARK: - 新增动画效果模块
public extension TFYUtils {
    enum Animation {
        /// 弹性缩放动画
        public static func springScale(
            view: UIView,
            duration: TimeInterval = 0.6,
            scale: CGFloat = 0.95
        ) {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.2,
                options: [.curveEaseInOut],
                animations: {
                    view.transform = CGAffineTransform(scaleX: scale, y: scale)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        view.transform = .identity
                    }
                }
            )
        }
        
        /// 渐隐过渡
        public static func crossfade(
            view: UIView,
            duration: TimeInterval = 0.3
        ) {
            let transition = CATransition()
            transition.duration = duration
            transition.type = .fade
            view.layer.add(transition, forKey: nil)
        }
    }
}

// MARK: - 新增本地通知模块
public extension TFYUtils {
    enum Notification {
        /// 请求通知权限
        public static func requestAuthorization() async -> Bool {
            do {
                return try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                Logger.log("通知权限请求失败: \(error)", level: .error)
                return false
            }
        }
        
        /// 发送本地通知
        public static func schedule(
            title: String,
            body: String,
            interval: TimeInterval = 1.0
        ) async {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: interval,
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                Logger.log("通知发送失败: \(error)", level: .error)
            }
        }
    }
}

// MARK: - 新增触觉反馈模块
public extension TFYUtils {
    enum Haptics {
        /// 触觉反馈类型
        public enum FeedbackType {
            case success
            case warning
            case error
            case selection
            case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
        }
        
        /// 触发触觉反馈
        public static func generate(_ type: FeedbackType) {
            switch type {
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .impact(let style):
                UIImpactFeedbackGenerator(style: style).impactOccurred()
            }
        }
    }
}

// MARK: - 新增生物识别模块
public extension TFYUtils {
    enum Biometrics {
        /// 生物识别类型
        public enum BiometricType {
            case none
            case touchID
            case faceID
            
            public var description: String {
                switch self {
                case .none: return "不支持"
                case .touchID: return "Touch ID"
                case .faceID: return "Face ID"
                }
            }
        }
        
        /// 获取当前设备支持的生物识别类型
        public static var biometricType: BiometricType {
            let context = LAContext()
            var error: NSError?
            
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return .none
            }
            
            switch context.biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            default:
                return .none
            }
        }
        
        /// 执行生物识别验证
        public static func authenticate(
            reason: String,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            let context = LAContext()
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

// MARK: - 新增文件操作模块
public extension TFYUtils {
    enum FileManager {
        /// 获取文件大小
        public static func fileSize(at path: String) -> Int64 {
            guard let attributes = try? Foundation.FileManager.default.attributesOfItem(atPath: path) else {
                return 0
            }
            return attributes[.size] as? Int64 ?? 0
        }
        
        /// 格式化文件大小
        public static func formatFileSize(_ size: Int64) -> String {
            let units = ["B", "KB", "MB", "GB"]
            var size = Double(size)
            var unitIndex = 0
            
            while size >= 1024 && unitIndex < units.count - 1 {
                size /= 1024
                unitIndex += 1
            }
            
            return String(format: "%.2f %@", size, units[unitIndex])
        }
        
        /// 创建目录
        public static func createDirectory(at path: String) throws {
            try Foundation.FileManager.default.createDirectory(
                atPath: path,
                withIntermediateDirectories: true
            )
        }
        
        /// 删除文件或目录
        public static func remove(at path: String) throws {
            try Foundation.FileManager.default.removeItem(atPath: path)
        }
    }
}

// MARK: - 新增图片处理模块
public extension TFYUtils {
    enum ImageProcessor {
        /// 压缩图片
        public static func compress(
            image: UIImage,
            maxSize: Int = 1024 * 1024  // 1MB
        ) -> Data? {
            var compression: CGFloat = 1.0
            var data = image.jpegData(compressionQuality: compression)
            
            while let currentData = data, currentData.count > maxSize && compression > 0.1 {
                compression -= 0.1
                data = image.jpegData(compressionQuality: compression)
            }
            
            return data
        }
        
        /// 调整图片尺寸
        public static func resize(
            image: UIImage,
            to size: CGSize,
            scale: CGFloat = UIScreen.main.scale
        ) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            
            image.draw(in: CGRect(origin: .zero, size: size))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        
        /// 生成圆角图片
        public static func roundCorners(
            image: UIImage,
            radius: CGFloat
        ) -> UIImage? {
            let rect = CGRect(origin: .zero, size: image.size)
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            defer { UIGraphicsEndImageContext() }
            
            let context = UIGraphicsGetCurrentContext()
            context?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
            context?.clip()
            
            image.draw(in: rect)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}

// MARK: - 新增日期处理模块
public extension TFYUtils {
    enum DateUtils {  // 重命名以避免与 Foundation.DateFormatter 冲突
        private static let sharedFormatter: Foundation.DateFormatter = {
            let formatter = Foundation.DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")  // 设置中文区域
            return formatter
        }()
        
        /// 格式化日期
        public static func string(
            from date: Date,
            format: String = "yyyy-MM-dd HH:mm:ss"
        ) -> String {
            sharedFormatter.dateFormat = format
            return sharedFormatter.string(from: date)
        }
        
        /// 解析日期字符串
        public static func date(
            from string: String,
            format: String = "yyyy-MM-dd HH:mm:ss"
        ) -> Date? {
            sharedFormatter.dateFormat = format
            return sharedFormatter.date(from: string)
        }
        
        /// 相对时间描述
        public static func relativeTimeDescription(from date: Date) -> String {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
            
            if let year = components.year, year > 0 {
                return "\(year)年前"
            }
            if let month = components.month, month > 0 {
                return "\(month)个月前"
            }
            if let day = components.day, day > 0 {
                return "\(day)天前"
            }
            if let hour = components.hour, hour > 0 {
                return "\(hour)小时前"
            }
            if let minute = components.minute, minute > 0 {
                return "\(minute)分钟前"
            }
            return "刚刚"
        }
        
        /// 获取指定格式的当前时间字符串
        public static func currentTimeString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
            string(from: Date(), format: format)
        }
    }
}

// 扩展 UINavigationController 支持带 completion 的 pop 方法
extension UINavigationController {
    func popToViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        popToViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            completion(true)
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            completion(true)
        }
    }
}

