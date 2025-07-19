//
//  TFYChainGenerator.swift
//  TFYSwiftCategoryUtil
//
//  Created by AI Assistant on 2024/12/19.
//  用途：通用链式工具生成器，支持自动分析类并生成链式扩展
//

import Foundation
import ObjectiveC

// MARK: - 链式生成器配置
/// 链式生成器配置选项
public struct TFYChainGeneratorConfig {
    /// 是否包含只读属性
    public var includeReadOnlyProperties: Bool = false
    /// 是否包含私有属性
    public var includePrivateProperties: Bool = false
    /// 是否包含系统方法
    public var includeSystemMethods: Bool = false
    /// 是否包含私有方法
    public var includePrivateMethods: Bool = false
    /// 是否包含继承的属性
    public var includeInheritedProperties: Bool = true
    /// 是否包含继承的方法
    public var includeInheritedMethods: Bool = true
    /// 属性过滤规则
    public var propertyFilter: ((String, String) -> Bool)?
    /// 方法过滤规则
    public var methodFilter: ((String, [String]) -> Bool)?
    /// 自定义属性映射
    public var propertyMapping: [String: String] = [:]
    /// 自定义方法映射
    public var methodMapping: [String: String] = [:]
    /// 生成的代码模板
    public var codeTemplate: String = ""
    /// 是否包含注释
    public var includeComments: Bool = true
    /// 是否包含文档注释
    public var includeDocumentation: Bool = true
    
    public init() {}
}

// MARK: - 属性信息模型
/// 属性信息模型
public struct TFYPropertyInfo {
    /// 属性名
    public let name: String
    /// 属性类型
    public let type: String
    /// 是否只读
    public let isReadOnly: Bool
    /// 是否私有
    public let isPrivate: Bool
    /// 属性编码
    public let encoding: String
    /// 自定义名称
    public var customName: String?
    /// 属性描述
    public let description: String
    
    public init(name: String, type: String, isReadOnly: Bool, isPrivate: Bool, encoding: String, description: String = "") {
        self.name = name
        self.type = type
        self.isReadOnly = isReadOnly
        self.isPrivate = isPrivate
        self.encoding = encoding
        self.description = description
    }
}

// MARK: - 方法信息模型
/// 方法信息模型
public struct TFYMethodInfo {
    /// 方法名
    public let name: String
    /// 选择器
    public let selector: Selector
    /// 参数类型
    public let parameterTypes: [String]
    /// 返回类型
    public let returnType: String
    /// 是否私有
    public let isPrivate: Bool
    /// 是否系统方法
    public let isSystemMethod: Bool
    /// 自定义名称
    public var customName: String?
    /// 方法描述
    public let description: String
    
    public init(name: String, selector: Selector, parameterTypes: [String], returnType: String, isPrivate: Bool, isSystemMethod: Bool, description: String = "") {
        self.name = name
        self.selector = selector
        self.parameterTypes = parameterTypes
        self.returnType = returnType
        self.isPrivate = isPrivate
        self.isSystemMethod = isSystemMethod
        self.description = description
    }
}

// MARK: - 运行时工具类
/// 运行时工具类
public class TFYRuntimeUtils {
    
    /// 获取类的所有属性
    public static func getProperties(for classType: AnyClass) -> [TFYPropertyInfo] {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(classType, &count) else {
            return []
        }
        defer { free(properties) }
        
        var propertyInfos: [TFYPropertyInfo] = []
        
        for i in 0..<Int(count) {
            let property = properties[i]
            let propertyName = String(cString: property_getName(property))
            
            let attributes = getPropertyAttributes(property)
            let propertyInfo = TFYPropertyInfo(
                name: propertyName,
                type: attributes.type,
                isReadOnly: attributes.isReadOnly,
                isPrivate: propertyName.hasPrefix("_"),
                encoding: attributes.encoding,
                description: "Property: \(propertyName) of type \(attributes.type)"
            )
            
            propertyInfos.append(propertyInfo)
        }
        
        return propertyInfos
    }
    
    /// 获取类的所有方法
    public static func getMethods(for classType: AnyClass) -> [TFYMethodInfo] {
        var count: UInt32 = 0
        guard let methods = class_copyMethodList(classType, &count) else {
            return []
        }
        defer { free(methods) }
        
        var methodInfos: [TFYMethodInfo] = []
        
        for i in 0..<Int(count) {
            let method = methods[i]
            let selector = method_getName(method)
            let selectorString = NSStringFromSelector(selector)
            
            let methodInfo = TFYMethodInfo(
                name: selectorString,
                selector: selector,
                parameterTypes: getMethodParameterTypes(method),
                returnType: getMethodReturnType(method),
                isPrivate: selectorString.hasPrefix("_"),
                isSystemMethod: isSystemMethod(selectorString),
                description: "Method: \(selectorString)"
            )
            
            methodInfos.append(methodInfo)
        }
        
        return methodInfos
    }
    
    /// 获取属性特性
    private static func getPropertyAttributes(_ property: objc_property_t) -> (type: String, isReadOnly: Bool, encoding: String) {
        guard let attributesPointer = property_getAttributes(property) else {
            return ("", false, "")
        }
        
        let attributes = String(cString: attributesPointer)
        let components = attributes.split(separator: ",")
        
        var type = ""
        var isReadOnly = false
        
        for component in components {
            let comp = String(component)
            if comp.hasPrefix("T@\"") {
                // 对象类型
                let startIndex = comp.index(comp.startIndex, offsetBy: 3)
                let endIndex = comp.index(comp.endIndex, offsetBy: -1)
                type = String(comp[startIndex..<endIndex])
            } else if comp.hasPrefix("T") {
                // 基本类型
                let startIndex = comp.index(comp.startIndex, offsetBy: 1)
                type = String(comp[startIndex...])
            } else if comp == "R" {
                isReadOnly = true
            }
        }
        
        return (type, isReadOnly, attributes)
    }
    
    /// 获取方法参数类型
    private static func getMethodParameterTypes(_ method: Method) -> [String] {
        let count = method_getNumberOfArguments(method)
        var types: [String] = []
        
        for i in 2..<count { // 跳过 self 和 _cmd
            let type = method_copyArgumentType(method, i)
            defer { free(type) }
            
            if let type = type {
                types.append(String(cString: type))
            }
        }
        
        return types
    }
    
    /// 获取方法返回类型
    private static func getMethodReturnType(_ method: Method) -> String {
        let returnType = method_copyReturnType(method)
        defer { free(returnType) }
        
        return String(cString: returnType)
    }
    
    /// 判断是否为系统方法
    private static func isSystemMethod(_ selectorString: String) -> Bool {
        let systemPrefixes = [
            "init", "dealloc", "load", "initialize",
            "setValue:forKey:", "valueForKey:",
            "setValue:forKeyPath:", "valueForKeyPath:",
            "addObserver:forKeyPath:options:context:",
            "removeObserver:forKeyPath:",
            "removeObserver:forKeyPath:context:"
        ]
        
        return systemPrefixes.contains { selectorString.hasPrefix($0) }
    }
}

// MARK: - 链式生成器
/// 通用链式工具生成器
public class TFYChainGenerator {
    
    // MARK: - 单例
    public static let shared = TFYChainGenerator()
    private init() {}
    
    // MARK: - 主要生成方法
    
    /// 为指定类生成链式扩展
    /// - Parameters:
    ///   - className: 类名
    ///   - config: 配置选项
    /// - Returns: 生成的代码字符串
    @discardableResult
    public func generateChainExtension(for className: String, config: TFYChainGeneratorConfig = TFYChainGeneratorConfig()) -> String {
        // 尝试获取类
        guard let classType = NSClassFromString(className) else {
            return generateErrorCode(className: className, error: "Class not found: \(className)")
        }
        
        let properties: [TFYPropertyInfo] = getProperties(for: classType, config: config)
        let methods: [TFYMethodInfo] = getMethods(for: classType, config: config)
        
        return generateCode(className: className, properties: properties, methods: methods, config: config)
    }
    
    /// 为指定类类型生成链式扩展
    /// - Parameters:
    ///   - classType: 类类型
    ///   - config: 配置选项
    /// - Returns: 生成的代码字符串
    @discardableResult
    public func generateChainExtension<T: NSObject>(for classType: T.Type, config: TFYChainGeneratorConfig = TFYChainGeneratorConfig()) -> String {
        let className = String(describing: classType)
        let properties: [TFYPropertyInfo] = getProperties(for: classType as AnyClass, config: config)
        let methods: [TFYMethodInfo] = getMethods(for: classType as AnyClass, config: config)
        
        return generateCode(className: className, properties: properties, methods: methods, config: config)
    }
    
    /// 批量生成多个类的链式扩展
    /// - Parameters:
    ///   - classNames: 类名数组
    ///   - config: 配置选项
    /// - Returns: 生成的代码字符串
    @discardableResult
    public func generateChainExtensions(for classNames: [String], config: TFYChainGeneratorConfig = TFYChainGeneratorConfig()) -> String {
        var allCode = ""
        
        for className in classNames {
            let code = generateChainExtension(for: className, config: config)
            allCode += code + "\n\n"
        }
        
        return allCode
    }
    
    /// 生成并保存到文件
    /// - Parameters:
    ///   - className: 类名
    ///   - filePath: 文件路径
    ///   - config: 配置选项
    /// - Returns: 是否成功
    @discardableResult
    public func generateAndSave(for className: String, to filePath: String, config: TFYChainGeneratorConfig = TFYChainGeneratorConfig()) -> Bool {
        let code = generateChainExtension(for: className, config: config)
        
        do {
            try code.write(toFile: filePath, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("TFYChainGenerator: 保存文件失败 - \(error)")
            return false
        }
    }
    
    // MARK: - 属性分析
    
    /// 获取类的属性信息
    private func getProperties(for classType: AnyClass, config: TFYChainGeneratorConfig) -> [TFYPropertyInfo] {
        var properties: [TFYPropertyInfo] = []
        var currentClass: AnyClass? = classType
        
        while let cls = currentClass {
            let classProperties = TFYRuntimeUtils.getProperties(for: cls)
            properties.append(contentsOf: classProperties)
            
            if !config.includeInheritedProperties {
                break
            }
            currentClass = class_getSuperclass(cls)
        }
        
        // 应用过滤和映射
        return applyPropertyFilters(properties, config: config)
    }
    
    /// 应用属性过滤和映射
    private func applyPropertyFilters(_ properties: [TFYPropertyInfo], config: TFYChainGeneratorConfig) -> [TFYPropertyInfo] {
        var filteredProperties: [TFYPropertyInfo] = []
        
        for property in properties {
            // 过滤私有属性
            if !config.includePrivateProperties && property.isPrivate {
                continue
            }
            
            // 应用过滤规则
            if let filter = config.propertyFilter {
                if !filter(property.name, property.type) {
                    continue
                }
            }
            
            // 应用自定义映射
            if let customName = config.propertyMapping[property.name] {
                var mutableInfo = property
                mutableInfo.customName = customName
                filteredProperties.append(mutableInfo)
            } else {
                filteredProperties.append(property)
            }
        }
        
        // 去重
        var uniqueProperties: [TFYPropertyInfo] = []
        var seenNames = Set<String>()
        
        for property in filteredProperties {
            if !seenNames.contains(property.name) {
                seenNames.insert(property.name)
                uniqueProperties.append(property)
            }
        }
        
        return uniqueProperties
    }
    
    // MARK: - 方法分析
    
    /// 获取类的方法信息
    private func getMethods(for classType: AnyClass, config: TFYChainGeneratorConfig) -> [TFYMethodInfo] {
        var methods: [TFYMethodInfo] = []
        var currentClass: AnyClass? = classType
        
        while let cls = currentClass {
            let classMethods = TFYRuntimeUtils.getMethods(for: cls)
            methods.append(contentsOf: classMethods)
            
            if !config.includeInheritedMethods {
                break
            }
            currentClass = class_getSuperclass(cls)
        }
        
        // 应用过滤和映射
        return applyMethodFilters(methods, config: config)
    }
    
    /// 应用方法过滤和映射
    private func applyMethodFilters(_ methods: [TFYMethodInfo], config: TFYChainGeneratorConfig) -> [TFYMethodInfo] {
        var filteredMethods: [TFYMethodInfo] = []
        
        for method in methods {
            // 过滤私有方法
            if !config.includePrivateMethods && method.isPrivate {
                continue
            }
            
            // 过滤系统方法
            if !config.includeSystemMethods && method.isSystemMethod {
                continue
            }
            
            // 应用过滤规则
            if let filter = config.methodFilter {
                if !filter(method.name, method.parameterTypes) {
                    continue
                }
            }
            
            // 应用自定义映射
            if let customName = config.methodMapping[method.name] {
                var mutableInfo = method
                mutableInfo.customName = customName
                filteredMethods.append(mutableInfo)
            } else {
                filteredMethods.append(method)
            }
        }
        
        // 去重
        var uniqueMethods: [TFYMethodInfo] = []
        var seenSelectors = Set<String>()
        
        for method in filteredMethods {
            let selectorString = NSStringFromSelector(method.selector)
            if !seenSelectors.contains(selectorString) {
                seenSelectors.insert(selectorString)
                uniqueMethods.append(method)
            }
        }
        
        return uniqueMethods
    }
    
    // MARK: - 代码生成
    
    /// 生成链式扩展代码
    private func generateCode(className: String, properties: [TFYPropertyInfo], methods: [TFYMethodInfo], config: TFYChainGeneratorConfig) -> String {
        var code = generateHeader(className: className, config: config)
        
        // 生成属性链式方法
        for property in properties {
            if !property.isReadOnly || config.includeReadOnlyProperties {
                code += generatePropertyChainMethod(property, className: className, config: config)
            }
        }
        
        // 生成方法链式调用
        for method in methods {
            code += generateMethodChainCall(method, className: className, config: config)
        }
        
        code += "}\n"
        
        return code
    }
    
    /// 生成文件头部
    private func generateHeader(className: String, config: TFYChainGeneratorConfig) -> String {
        var header = """
        //
        //  \(className)+Chain.swift
        //  Auto-generated by TFYChainGenerator
        //  Generated on: \(Date())
        //
        
        import Foundation
        
        """
        
        if config.includeComments {
            header += """
            // MARK: - \(className) 链式扩展
            // 此文件包含 \(className) 的链式编程扩展
            // 所有方法都支持链式调用，返回 self 以支持连续调用
            
            """
        }
        
        header += """
        // 链式编程包装器
        public struct \(className)Chain {
            private let base: \(className)
            
            public init(_ base: \(className)) {
                self.base = base
            }
            
            public var build: \(className) { return base }
        }
        
        // 链式编程协议
        public protocol \(className)ChainCompatible {}
        
        public extension \(className)ChainCompatible where Self: \(className) {
            var chain: \(className)Chain { \(className)Chain(self) }
        }
        
        // 链式扩展实现
        public extension \(className)Chain {
        
        """
        
        return header
    }
    
    /// 生成属性链式方法
    private func generatePropertyChainMethod(_ property: TFYPropertyInfo, className: String, config: TFYChainGeneratorConfig) -> String {
        let methodName = property.customName ?? property.name
        let type = property.type.isEmpty ? "Any" : property.type
        
        var method = ""
        
        if config.includeDocumentation {
            method += """
                
                /// 设置 \(property.name)
                /// - Parameter \(property.name): \(property.description)
                /// - Returns: 链式调用对象
                
            """
        }
        
        method += """
            
            @discardableResult
            func \(methodName)(_ \(property.name): \(type)) -> \(className)Chain {
                base.\(property.name) = \(property.name)
                return self
            }
            
        """
        
        return method
    }
    
    /// 生成方法链式调用
    private func generateMethodChainCall(_ method: TFYMethodInfo, className: String, config: TFYChainGeneratorConfig) -> String {
        let methodName = method.customName ?? method.name
        let parameters = generateMethodParameters(method)
        
        var methodCode = ""
        
        if config.includeDocumentation {
            methodCode += """
                
                /// 调用 \(method.name)
                /// \(method.description)
                /// - Returns: 链式调用对象
                
            """
        }
        
        methodCode += """
            
            @discardableResult
            func \(methodName)(\(parameters)) -> \(className)Chain {
                _ = base.\(method.name)(\(generateMethodCallParameters(method)))
                return self
            }
            
        """
        
        return methodCode
    }
    
    /// 生成方法参数
    private func generateMethodParameters(_ method: TFYMethodInfo) -> String {
        guard !method.parameterTypes.isEmpty else { return "" }
        
        var parameters: [String] = []
        for (index, type) in method.parameterTypes.enumerated() {
            let paramName = "param\(index + 1)"
            parameters.append("_ \(paramName): \(type)")
        }
        
        return parameters.joined(separator: ", ")
    }
    
    /// 生成方法调用参数
    private func generateMethodCallParameters(_ method: TFYMethodInfo) -> String {
        guard !method.parameterTypes.isEmpty else { return "" }
        
        var parameters: [String] = []
        for index in 0..<method.parameterTypes.count {
            parameters.append("param\(index + 1)")
        }
        
        return parameters.joined(separator: ", ")
    }
    
    /// 生成错误代码
    private func generateErrorCode(className: String, error: String) -> String {
        return """
        //
        //  \(className)+Chain.swift
        //  Auto-generated by TFYChainGenerator
        //  Generated on: \(Date())
        //
        
        import Foundation
        
        // MARK: - \(className) 链式扩展
        // 错误: \(error)
        // 无法生成链式扩展，请检查类名是否正确
        
        // 错误: 无法找到类 \(className)
        // 请确保类名正确且类已正确导入
        
        """
    }
}

// MARK: - 便捷方法
public extension TFYChainGenerator {
    
    /// 快速生成 UIView 链式扩展
    @discardableResult
    func generateUIViewChain() -> String {
        var config = TFYChainGeneratorConfig()
        config.includeReadOnlyProperties = false
        config.includePrivateProperties = false
        config.includeSystemMethods = false
        config.propertyFilter = { name, type in
            // 过滤掉一些不需要的属性
            let excludedProperties = ["layer", "superview", "window", "next"]
            return !excludedProperties.contains(name)
        }
        
        return generateChainExtension(for: "UIView", config: config)
    }
    
    /// 快速生成 UIButton 链式扩展
    @discardableResult
    func generateUIButtonChain() -> String {
        var config = TFYChainGeneratorConfig()
        config.includeReadOnlyProperties = false
        config.includePrivateProperties = false
        config.includeSystemMethods = false
        
        return generateChainExtension(for: "UIButton", config: config)
    }
    
    /// 快速生成 UILabel 链式扩展
    @discardableResult
    func generateUILabelChain() -> String {
        var config = TFYChainGeneratorConfig()
        config.includeReadOnlyProperties = false
        config.includePrivateProperties = false
        config.includeSystemMethods = false
        
        return generateChainExtension(for: "UILabel", config: config)
    }
}

// MARK: - 使用示例
extension TFYChainGenerator {
    
    /// 生成使用示例代码
    @discardableResult
    public func generateUsageExample(for className: String) -> String {
        return """
        //
        //  \(className) 链式使用示例
        //
        
        // 创建实例
        let instance = \(className)()
        
        // 链式调用
        instance.chain
            .property1(value1)
            .property2(value2)
            .method1(param1)
            .method2(param1, param2)
            .build  // 获取最终对象
        
        // 或者直接使用
        let result = instance.chain
            .property1(value1)
            .property2(value2)
            .build
        
        // 条件设置
        if condition {
            instance.chain
                .property1(value1)
                .property2(value2)
        }
        
        // 配置块
        instance.chain
            .property1(value1)
            .property2(value2)
            .build
        
        """
    }
}