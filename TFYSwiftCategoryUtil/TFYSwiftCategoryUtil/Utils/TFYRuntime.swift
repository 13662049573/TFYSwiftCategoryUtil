//
//  TFYRuntime.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/17.
//  用途：Runtime 工具，支持关联对象、属性/方法/协议获取、方法交换等。
//

import UIKit

/// 获取关联对象
public func tfy_getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

/// 设置关联对象
public func tfy_setRetainedAssociatedObject<T>(_ object: Any, 
                                              _ key: UnsafeRawPointer, 
                                              _ value: T, 
                                              _ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
    objc_setAssociatedObject(object, key, value, policy)
}

/// Runtime工具类
public class TFYRuntime: NSObject {
    
    // MARK: - 类型判断
    
    /// 判断是否是系统类
    /// - Parameter className: 类名
    /// - Returns: 是否是系统类
    public static func isSystemClass(_ className: AnyClass) -> Bool {
        let bundlePath = Bundle(for: className).bundlePath
        return bundlePath.contains("/System/Library/") || bundlePath.contains("/usr/lib/")
    }
    
    /// 获取类的继承链
    /// - Parameter className: 类名
    /// - Returns: 继承链数组
    public static func getInheritanceHierarchy(_ className: AnyClass) -> [AnyClass] {
        var hierarchy: [AnyClass] = []
        var currentClass: AnyClass? = className
        
        while let cls = currentClass {
            hierarchy.append(cls)
            currentClass = class_getSuperclass(cls)
        }
        return hierarchy
    }
    
    // MARK: - 属性和方法获取
    
    /// 获取类的成员变量列表
    @discardableResult
    public static func ivars(_ type: AnyClass) -> [String] {
        var listName = [String]()
        var count: UInt32 = 0
        guard let ivars = class_copyIvarList(type, &count) else {
            return listName
        }
        defer {
            free(ivars)
        }
        
        for i in 0..<count {
            guard let namePointer = ivar_getName(ivars[Int(i)]) else { continue }
            let name = String(cString: namePointer)
            debugPrint("ivar name: \(name)")
            listName.append(name)
        }
        return listName
    }
    
    /// 获取类的所有属性名
    @discardableResult
    public static func getAllPropertyName(_ aClass: AnyClass) -> [String] {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(aClass, &count) else {
            return []
        }
        defer {
            free(properties)
        }
        
        var propertyNames = [String]()
        for i in 0..<Int(count) {
            let property = properties[i]
            guard let propertyName = String(utf8String: property_getName(property)) else {
                continue
            }
            propertyNames.append(propertyName)
        }
        return propertyNames
    }
    
    /// 获取类的方法列表
    @discardableResult
    public static func methods(from classType: AnyClass) -> [Selector] {
        var count: UInt32 = 0
        guard let methods = class_copyMethodList(classType, &count) else {
            return []
        }
        defer {
            free(methods)
        }
        
        var selectors = [Selector]()
        for i in 0..<Int(count) {
            let selector = method_getName(methods[i])
            debugPrint("\(classType)的方法：\(selector)")
            selectors.append(selector)
        }
        return selectors
    }
    
    /// 获取类的协议列表
    public static func getProtocols(_ classType: AnyClass) -> [Protocol] {
        var count: UInt32 = 0
        guard let protocols = class_copyProtocolList(classType, &count) else {
            return []
        }
        defer {
            free(UnsafeMutableRawPointer(protocols))
        }
        
        var protocolList = [Protocol]()
        for i in 0..<Int(count) {
            protocolList.append(protocols[i])
        }
        return protocolList
    }
    
    /// 获取属性的类型编码
    public static func getPropertyType(_ property: objc_property_t) -> String {
        guard let attributesPointer = property_getAttributes(property) else {
            print("TFYRuntime: 属性类型解析失败 property=\(property)")
            return ""
        }
        let attributes = String(cString: attributesPointer)
        let slices = attributes.split(separator: "\"")
        guard slices.count >= 2 else {
            print("TFYRuntime: 属性类型格式异常 attributes=\(attributes)")
            return ""
        }
        return String(slices[1])
    }
}

// MARK: - 方法交换
public extension TFYRuntime {
    
    /// 交换实例方法（使用方法名字符串）
    static func exchangeMethod(target: String,
                             replace: String,
                             class classType: AnyClass) {
        exchangeMethod(selector: Selector(target),
                      replace: Selector(replace),
                      class: classType)
    }
    
    /// 交换实例方法（使用选择器）
    static func exchangeMethod(selector: Selector,
                             replace: Selector,
                             class classType: AnyClass) {
        guard let originalMethod = class_getInstanceMethod(classType, selector),
              let replaceMethod = class_getInstanceMethod(classType, replace) else {
            debugPrint("Method exchange failed: methods not found")
            return
        }
        
        let didAddMethod = class_addMethod(classType,
                                         selector,
                                         method_getImplementation(replaceMethod),
                                         method_getTypeEncoding(replaceMethod))
        
        if didAddMethod {
            class_replaceMethod(classType,
                              replace,
                              method_getImplementation(originalMethod),
                              method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, replaceMethod)
        }
    }
    
    /// 交换类方法
    static func exchangeClassMethod(selector: Selector,
                                  replace: Selector,
                                  class classType: AnyClass) {
        guard let originalMethod = class_getClassMethod(classType, selector),
              let replaceMethod = class_getClassMethod(classType, replace) else {
            return
        }
        method_exchangeImplementations(originalMethod, replaceMethod)
    }
}

// MARK: - 动态添加方法
public extension TFYRuntime {
    
    /// 动态添加方法
    /// - Parameters:
    ///   - selector: 方法选择器
    ///   - classType: 类型
    ///   - implementation: 方法实现
    static func addMethod(_ selector: Selector,
                         to classType: AnyClass,
                         implementation: IMP) {
        class_addMethod(classType,
                       selector,
                       implementation,
                       "v@:")
    }
    
    /// 检查类是否响应某个方法
    static func hasMethod(_ selector: Selector, in classType: AnyClass) -> Bool {
        return class_getInstanceMethod(classType, selector) != nil
    }
}

// MARK: - 属性操作
public extension TFYRuntime {
    
    /// 动态添加属性
    static func addProperty(_ name: String,
                           to classType: AnyClass,
                           attributes: objc_property_attribute_t...) {
        let attributeList = UnsafeMutablePointer<objc_property_attribute_t>.allocate(capacity: attributes.count)
        attributes.enumerated().forEach { index, attribute in
            attributeList[index] = attribute
        }
        
        // 修复：安全地处理 C 字符串转换
        guard let cName = (name as NSString).utf8String else {
            attributeList.deallocate()
            return
        }
        
        class_addProperty(classType, cName, attributeList, UInt32(attributes.count))
        attributeList.deallocate()
    }
    
    /// 获取属性值
    static func getPropertyValue(_ property: String, from object: Any) -> Any? {
        let mirror = Mirror(reflecting: object)
        return mirror.children.first { $0.label == property }?.value
    }
}
