//
//  TFYTimer.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/18.
//

import Foundation

/// 定时器类
public class TFYTimer {
    
    // MARK: - 属性
    
    /// 内部GCD定时器
    private let internalTimer: DispatchSourceTimer
    
    /// 是否正在运行
    private var isRunning = false
    
    /// 是否重复执行
    public let repeats: Bool
    
    /// 定时器回调类型
    public typealias SwiftTimerHandler = (TFYTimer) -> Void
    
    /// 定时器回调
    private var handler: SwiftTimerHandler
    
    // MARK: - 初始化方法
    
    /// 创建定时器
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - repeats: 是否重复
    ///   - leeway: 允许的延迟误差
    ///   - queue: 执行队列
    ///   - handler: 回调处理
    public init(interval: DispatchTimeInterval,
                repeats: Bool = false,
                leeway: DispatchTimeInterval = .seconds(0),
                queue: DispatchQueue = .main,
                handler: @escaping SwiftTimerHandler) {
        
        self.handler = handler
        self.repeats = repeats
        
        // 创建定时器源
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        
        // 设置回调
        internalTimer.setEventHandler { [weak self] in
            guard let self = self else { return }
            handler(self)
        }
        
        // 设置定时器
        if repeats {
            internalTimer.schedule(deadline: .now() + interval,
                                 repeating: interval,
                                 leeway: leeway)
        } else {
            internalTimer.schedule(deadline: .now() + interval,
                                 leeway: leeway)
        }
    }
    
    /// 创建重复执行的定时器
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - leeway: 允许的延迟误差
    ///   - queue: 执行队列
    ///   - handler: 回调处理
    /// - Returns: 定时器实例
    public static func repeaticTimer(interval: DispatchTimeInterval,
                                   leeway: DispatchTimeInterval = .seconds(0),
                                   queue: DispatchQueue = .main,
                                   handler: @escaping SwiftTimerHandler) -> TFYTimer {
        return TFYTimer(interval: interval,
                       repeats: true,
                       leeway: leeway,
                       queue: queue,
                       handler: handler)
    }
    
    deinit {
        if !self.isRunning {
            internalTimer.resume()
        }
    }
    
    // MARK: - 控制方法
    
    /// 立即触发定时器
    /// 重复定时器不会打断原有的执行计划
    /// 非重复定时器触发后会自动失效
    public func fire() {
        handler(self)
        if !repeats {
            internalTimer.cancel()
        }
    }
    
    /// 启动定时器
    public func start() {
        if !isRunning {
            internalTimer.resume()
            isRunning = true
        }
    }
    
    /// 暂停定时器
    public func suspend() {
        if isRunning {
            internalTimer.suspend()
            isRunning = false
        }
    }
    
    /// 重新设置重复定时器的时间间隔
    /// - Parameter interval: 新的时间间隔
    public func rescheduleRepeating(interval: DispatchTimeInterval) {
        if repeats {
            internalTimer.schedule(deadline: .now() + interval,
                                 repeating: interval)
        }
    }
    
    /// 重新设置定时器回调
    /// - Parameter handler: 新的回调处理
    public func rescheduleHandler(handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        internalTimer.setEventHandler { [weak self] in
            guard let self = self else { return }
            handler(self)
        }
    }
}

// MARK: - 节流与防抖
public extension TFYTimer {
    
    /// 存储工作项的字典
    private static var workItems = [String: DispatchWorkItem]()
    
    /// 防抖操作
    /// 在指定的interval后调用handler
    /// 在间隔时间内重复调用会取消之前的调用
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - identifier: 标识符
    ///   - queue: 执行队列
    ///   - handler: 回调处理
    static func debounce(interval: DispatchTimeInterval,
                        identifier: String,
                        queue: DispatchQueue = .main,
                        handler: @escaping () -> Void) {
        
        // 取消已存在的工作项
        if let item = workItems[identifier] {
            item.cancel()
        }
        
        // 创建新的工作项
        let item = DispatchWorkItem {
            handler()
            workItems.removeValue(forKey: identifier)
        }
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }
    
    /// 节流操作
    /// 在指定的interval后调用handler
    /// 在间隔时间内重复调用无效
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - identifier: 标识符
    ///   - queue: 执行队列
    ///   - handler: 回调处理
    static func throttle(interval: DispatchTimeInterval,
                        identifier: String,
                        queue: DispatchQueue = .main,
                        handler: @escaping () -> Void) {
        
        // 已存在工作项则直接返回
        if workItems[identifier] != nil {
            return
        }
        
        // 创建新的工作项
        let item = DispatchWorkItem {
            handler()
            workItems.removeValue(forKey: identifier)
        }
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }
    
    /// 取消节流定时器
    /// - Parameter identifier: 标识符
    static func cancelThrottlingTimer(identifier: String) {
        if let item = workItems[identifier] {
            item.cancel()
            workItems.removeValue(forKey: identifier)
        }
    }
}

// MARK: - 倒计时定时器
public class TFYCountDownTimer {
    
    // MARK: - 属性
    
    /// 内部定时器
    private let internalTimer: TFYTimer
    
    /// 剩余次数
    private var leftTimes: Int
    
    /// 原始次数
    private let originalTimes: Int
    
    /// 回调处理
    private let handler: (TFYCountDownTimer, _ leftTimes: Int) -> Void
    
    // MARK: - 初始化方法
    
    /// 创建倒计时定时器
    /// - Parameters:
    ///   - interval: 时间间隔
    ///   - times: 总次数
    ///   - queue: 执行队列
    ///   - handler: 回调处理
    public init(interval: DispatchTimeInterval,
                times: Int,
                queue: DispatchQueue = .main,
                handler: @escaping (TFYCountDownTimer, _ leftTimes: Int) -> Void) {
        
        self.leftTimes = times
        self.originalTimes = times
        self.handler = handler
        
        // 创建重复定时器
        self.internalTimer = TFYTimer.repeaticTimer(interval: interval,
                                                   queue: queue) { _ in }
        
        // 设置定时器回调
        self.internalTimer.rescheduleHandler { [weak self] _ in
            guard let self = self else { return }
            if self.leftTimes > 0 {
                self.leftTimes -= 1
                self.handler(self, self.leftTimes)
            } else {
                self.internalTimer.suspend()
            }
        }
    }
    
    // MARK: - 控制方法
    
    /// 启动倒计时
    public func start() {
        self.internalTimer.start()
    }
    
    /// 暂停倒计时
    public func suspend() {
        self.internalTimer.suspend()
    }
    
    /// 重置倒计时
    public func reCountDown() {
        self.leftTimes = self.originalTimes
    }
}

// MARK: - 时间间隔扩展
public extension DispatchTimeInterval {
    
    /// 从秒数创建时间间隔
    /// - Parameter seconds: 秒数
    /// - Returns: 时间间隔
    static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
        return .milliseconds(Int(seconds * 1000))
    }
}
