//
//  Timer+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/18.
//

import Foundation
import UIKit


// MARK: - 一、基本的扩展
public extension Timer {
    
    // MARK: 1.1、构造器创建定时器
    /// 构造器创建定时器
    /// - Parameters:
    ///   - timeInterval: 时间间隔
    ///   - repeats: 是否重复执行
    ///   - block: 执行代码的block
    convenience init(safeTimerWithTimeInterval timeInterval: TimeInterval, repeats: Bool, block: @escaping ((Timer) -> Void)) {
        if #available(iOS 10.0, *) {
            self.init(timeInterval: timeInterval, repeats: repeats, block: block)
            return
        }
        self.init(timeInterval: timeInterval, target: Timer.self, selector: #selector(Timer.timerCB(timer:)), userInfo: block, repeats: repeats)
    }
    
    // MARK: 1.2、类方法创建定时器
    ///  创建定时器
    /// - Parameters:
    ///   - timeInterval: 时间间隔
    ///   - repeats: 是否重复执行
    ///   - block: 执行代码的block
    /// - Returns: 返回 Timer
    @discardableResult
    static func scheduledSafeTimer(timeInterval: TimeInterval, repeats: Bool, block: @escaping ((Timer) -> Void)) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: block)
        }
        return Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerCB(timer:)), userInfo: block, repeats: repeats)
    }

    // MARK: 1.3、C语言的形式创建定时器(创建后立即执行一次)
    /// C语言的形式创建定时器
    /// - Parameters:
    ///   - timeInterval: 时间间隔
    ///   - handler: 定时器的回调
    /// - Returns: 返回 Timer
    @discardableResult
    static func runThisEvery(timeInterval: TimeInterval, handler: @escaping (Timer?) -> Void) -> Timer? {
        let fireDate = CFAbsoluteTimeGetCurrent()
        guard let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, timeInterval, 0, 0, handler) else {
            return nil
        }
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer
    }
}

// MARK: - 私有的方法
public extension Timer {
    @objc fileprivate class func timerCB(timer: Timer) {
        guard let cb = timer.userInfo as? ((Timer) -> Void) else {
            timer.invalidate()
            return
        }
        cb(timer)
    }
    
    /// 分类方法
    @discardableResult
    static func scheduled(_ Interval: TimeInterval = 60, repeats: Bool = true, action: @escaping((Timer) -> Void)) -> Timer {
        return scheduledTimer(timeInterval: Interval, target: self, selector: #selector(handleInvoke(_:)), userInfo: action, repeats: repeats)
    }
    
    @objc private static func handleInvoke(_ timer: Timer) {
        if let action = timer.userInfo as? ((Timer) -> Void) {
            action(timer)
        }
    }
    /// 继续：触发时间设置在现在/获取，这样定时器自动进入马上进入工作状态.
    func activate() {
        self.fireDate = .distantPast
    }
    /// 暂停：触发时间设置在未来，既很久之后，这样定时器自动进入等待触发的状态.
    func pause() {
        self.fireDate = .distantFuture
    }
    ///创建 GCDTimer
    static func createGCDTimer(_ interval: TimeInterval = 60, repeats: Bool = true, action: @escaping(() -> Void)) -> DispatchSourceTimer {
        let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
        codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
        codeTimer.setEventHandler {
            if repeats == false {
                codeTimer.cancel()
            }
            DispatchQueue.main.async(execute: action)
        }
        
        codeTimer.resume()
        return codeTimer
    }
    
    static func cancelGCDTimer(_ timer: DispatchSourceTimer?) {
        timer?.cancel()
    }
}

public extension DispatchSourceTimer{
    
    static func create(_ interval: TimeInterval = 60, repeats: Bool = true, action: @escaping(() -> Void)) -> DispatchSourceTimer {
        let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
        codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
        codeTimer.setEventHandler {
            if repeats == false {
                codeTimer.cancel()
            }
            DispatchQueue.main.async(execute: action)
        }
        
        codeTimer.resume()
        return codeTimer
    }
}
