//
//  TFYAsynce.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/4/25.
//

import Foundation

/// 通用闭包类型
public typealias TFYSwiftBlock = () -> Void
/// 带返回值的闭包类型
public typealias TFYSwiftResultBlock<T> = () -> T
/// 带参数的闭包类型
public typealias TFYSwiftParamBlock<T> = (T) -> Void
/// 带参数和返回值的闭包类型
public typealias TFYSwiftParamResultBlock<T, R> = (T) -> R

// MARK: - 异步处理工具
public struct TFYAsynce {
    /// 默认的全局队列优先级
    public static let defaultQoS: DispatchQoS = .default
    
    /// 异步处理数据
    public static func async(
        qos: DispatchQoS = .default,
        _ block: @escaping TFYSwiftBlock
    ) {
        _async(qos: qos, block)
    }
    
    /// 异步处理数据并在主线程回调
    public static func async(
        qos: DispatchQoS = .default,
        _ block: @escaping TFYSwiftBlock,
        mainBlock: @escaping TFYSwiftBlock
    ) {
        _async(qos: qos, block, mainBlock)
    }
    
    /// 异步延迟执行
    @discardableResult
    public static func asyncDelay(
        _ seconds: Double,
        qos: DispatchQoS = .default,
        _ block: @escaping TFYSwiftBlock
    ) -> DispatchWorkItem {
        return _asyncDelay(seconds, qos: qos, block)
    }
    
    /// 异步延迟执行并在主线程回调
    @discardableResult
    public static func asyncDelay(
        _ seconds: Double,
        qos: DispatchQoS = .default,
        _ block: @escaping TFYSwiftBlock,
        mainBlock: @escaping TFYSwiftBlock
    ) -> DispatchWorkItem {
        return _asyncDelay(seconds, qos: qos, block, mainBlock)
    }
    
    /// 异步执行任务并获取结果
    public static func asyncResult<T>(
        qos: DispatchQoS = .default,
        _ block: @escaping TFYSwiftResultBlock<T>,
        completion: @escaping TFYSwiftParamBlock<T>
    ) {
        _async(qos: qos) {
            let result = block()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    /// 取消延迟执行的任务
    public static func cancelDelayTask(_ workItem: DispatchWorkItem) {
        workItem.cancel()
    }
}

// MARK: - 私有实现
private extension TFYAsynce {
    /// 异步执行
    static func _async(
        qos: DispatchQoS,
        _ block: @escaping TFYSwiftBlock,
        _ mainBlock: TFYSwiftBlock? = nil
    ) {
        let item = DispatchWorkItem(qos: qos, block: block)
        DispatchQueue.global(qos: qos.qosClass).async(execute: item)
        if let main = mainBlock {
            item.notify(queue: .main, execute: main)
        }
    }
    
    /// 异步延迟执行
    static func _asyncDelay(
        _ seconds: Double,
        qos: DispatchQoS,
        _ block: @escaping TFYSwiftBlock,
        _ mainBlock: TFYSwiftBlock? = nil
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem(qos: qos, block: block)
        DispatchQueue.global(qos: qos.qosClass).asyncAfter(
            deadline: .now() + seconds,
            execute: item
        )
        if let main = mainBlock {
            item.notify(queue: .main, execute: main)
        }
        return item
    }
}

// MARK: - 便利扩展
public extension TFYAsynce {
    /// 主线程执行
    static func main(_ block: @escaping TFYSwiftBlock) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    /// 主线程延迟执行
    @discardableResult
    static func mainDelay(_ seconds: Double, _ block: @escaping TFYSwiftBlock) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: item)
        return item
    }
    
    /// 并发执行多个任务
    static func concurrent(
        _ blocks: [TFYSwiftBlock],
        qos: DispatchQoS = .default,
        completion: TFYSwiftBlock? = nil
    ) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: qos.qosClass)
        
        blocks.forEach { block in
            queue.async(group: group) {
                block()
            }
        }
        
        if let completion = completion {
            group.notify(queue: .main) {
                completion()
            }
        }
    }
}
