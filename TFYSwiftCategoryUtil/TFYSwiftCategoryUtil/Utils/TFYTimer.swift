//
//  TFYTimer.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/18.
//  用途：GCD定时器工具，支持定时器、节流防抖、倒计时等功能。
//

import Foundation

/// 定时器状态
public enum TFYTimerState {
    case created
    case running
    case suspended
    case cancelled
}

/// 定时器类
public class TFYTimer {
    
    // MARK: - 属性
    
    /// 内部GCD定时器
    private let internalTimer: DispatchSourceTimer
    
    /// 定时器状态
    private var state: TFYTimerState = .created
    
    /// 是否重复执行
    public let repeats: Bool
    
    /// 定时器回调类型
    public typealias SwiftTimerHandler = (TFYTimer) -> Void
    
    /// 定时器回调
    private var handler: SwiftTimerHandler
    
    /// 生命周期事件回调
    public var onStateChange: ((TFYTimerState) -> Void)?
    
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
        // 确保定时器被正确清理
        if state != .cancelled {
            internalTimer.cancel()
        }
    }
    
    // MARK: - 状态查询
    
    /// 定时器是否有效（未取消）
    public var isValid: Bool {
        return state != .cancelled
    }
    
    /// 定时器是否正在运行
    public var isRunning: Bool {
        return state == .running
    }
    
    /// 定时器是否已暂停
    public var isSuspended: Bool {
        return state == .suspended
    }
    
    /// 获取当前状态
    public var currentState: TFYTimerState {
        return state
    }
    
    // MARK: - 控制方法
    
    /// 立即触发定时器
    /// 重复定时器不会打断原有的执行计划
    /// 非重复定时器触发后会自动失效
    public func fire() {
        guard isValid else { return }
        handler(self)
        if !repeats {
            cancel()
        }
    }
    
    /// 启动定时器
    public func start() {
        guard isValid && state != .running else { return }
        internalTimer.resume()
        state = .running
        onStateChange?(state)
    }
    
    /// 暂停定时器
    public func suspend() {
        guard state == .running else { return }
        internalTimer.suspend()
        state = .suspended
        onStateChange?(state)
    }
    
    /// 取消定时器
    public func cancel() {
        guard state != .cancelled else { return }
        internalTimer.cancel()
        state = .cancelled
        onStateChange?(state)
    }
    
    /// 重新设置重复定时器的时间间隔
    /// - Parameter interval: 新的时间间隔
    public func rescheduleRepeating(interval: DispatchTimeInterval) {
        guard repeats && isValid else { return }
        internalTimer.schedule(deadline: .now() + interval,
                             repeating: interval)
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
    
    /// 存储工作项的字典（线程安全）
    private static var workItems = [String: DispatchWorkItem]()
    private static let workItemsLock = NSLock()
    
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
        
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        
        // 取消已存在的工作项
        if let item = workItems[identifier] {
            item.cancel()
        }
        
        // 创建新的工作项
        let item = DispatchWorkItem {
            handler()
            workItemsLock.lock()
            workItems.removeValue(forKey: identifier)
            workItemsLock.unlock()
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
        
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        
        // 已存在工作项则直接返回
        if workItems[identifier] != nil {
            return
        }
        
        // 创建新的工作项
        let item = DispatchWorkItem {
            handler()
            workItemsLock.lock()
            workItems.removeValue(forKey: identifier)
            workItemsLock.unlock()
        }
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }
    
    /// 取消节流定时器
    /// - Parameter identifier: 标识符
    static func cancelThrottlingTimer(identifier: String) {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        
        if let item = workItems[identifier] {
            item.cancel()
            workItems.removeValue(forKey: identifier)
        }
    }
    
    /// 取消所有节流/防抖操作
    static func cancelAllThrottlingTimers() {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        
        for (_, item) in workItems {
            item.cancel()
        }
        workItems.removeAll()
    }
    
    /// 获取当前活跃的节流/防抖操作数量
    static var activeThrottlingTimersCount: Int {
        workItemsLock.lock()
        defer { workItemsLock.unlock() }
        return workItems.count
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
    
    /// 完成回调
    public var onComplete: (() -> Void)?
    
    /// 状态变化回调
    public var onStateChange: ((TFYCountDownTimer, _ leftTimes: Int) -> Void)?
    
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
                self.onStateChange?(self, self.leftTimes)
                
                if self.leftTimes == 0 {
                    self.onComplete?()
                }
            } else {
                self.internalTimer.suspend()
            }
        }
    }
    
    // MARK: - 状态查询
    
    /// 获取剩余次数
    public var remainingTimes: Int {
        return leftTimes
    }
    
    /// 获取总次数
    public var totalTimes: Int {
        return originalTimes
    }
    
    /// 获取进度（0.0 - 1.0）
    public var progress: Double {
        return Double(originalTimes - leftTimes) / Double(originalTimes)
    }
    
    /// 是否已完成
    public var isCompleted: Bool {
        return leftTimes == 0
    }
    
    /// 是否正在运行
    public var isRunning: Bool {
        return internalTimer.isRunning
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
    
    /// 恢复倒计时
    public func resume() {
        self.internalTimer.start()
    }
    
    /// 重置倒计时
    public func reCountDown() {
        self.leftTimes = self.originalTimes
    }
    
    /// 取消倒计时
    public func cancel() {
        self.internalTimer.cancel()
    }
    
    /// 设置剩余次数
    /// - Parameter times: 新的剩余次数
    public func setRemainingTimes(_ times: Int) {
        self.leftTimes = max(0, min(times, originalTimes))
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
    
    /// 从毫秒数创建时间间隔
    /// - Parameter milliseconds: 毫秒数
    /// - Returns: 时间间隔
    static func fromMilliseconds(_ milliseconds: Int) -> DispatchTimeInterval {
        return .milliseconds(milliseconds)
    }
    
    /// 从微秒数创建时间间隔
    /// - Parameter microseconds: 微秒数
    /// - Returns: 时间间隔
    static func fromMicroseconds(_ microseconds: Int) -> DispatchTimeInterval {
        return .microseconds(microseconds)
    }
    
    /// 从纳秒数创建时间间隔
    /// - Parameter nanoseconds: 纳秒数
    /// - Returns: 时间间隔
    static func fromNanoseconds(_ nanoseconds: Int) -> DispatchTimeInterval {
        return .nanoseconds(nanoseconds)
    }
}

// MARK: - TFYTimer 用法示例
/*
// 1. 普通定时器（单次/重复）
let timer = TFYTimer(interval: .seconds(2), repeats: false) { t in
    print("单次定时器触发")
}
timer.start()

let repeatTimer = TFYTimer.repeaticTimer(interval: .seconds(1)) { t in
    print("重复定时器触发")
}
repeatTimer.onStateChange = { state in
    print("定时器状态变化: \(state)")
}
repeatTimer.start()

// 2. 节流/防抖
TFYTimer.debounce(interval: .seconds(1), identifier: "search") {
    print("防抖触发：用户停止输入1秒后执行")
}

TFYTimer.throttle(interval: .seconds(2), identifier: "api") {
    print("节流触发：2秒内只会执行一次")
}

// 取消所有节流/防抖
TFYTimer.cancelAllThrottlingTimers()

// 3. 倒计时定时器
let countDown = TFYCountDownTimer(interval: .seconds(1), times: 5) { timer, left in
    print("倒计时剩余: \(left)")
}
countDown.onComplete = {
    print("倒计时完成")
}
countDown.onStateChange = { timer, left in
    print("倒计时状态变化，剩余: \(left)")
}
countDown.start()

// 4. 进阶：动态重置、暂停、恢复
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    countDown.suspend()
    print("倒计时暂停")
}
DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    countDown.resume()
    print("倒计时恢复")
}
DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
    countDown.reCountDown()
    countDown.start()
    print("倒计时重置并启动")
}
*/
