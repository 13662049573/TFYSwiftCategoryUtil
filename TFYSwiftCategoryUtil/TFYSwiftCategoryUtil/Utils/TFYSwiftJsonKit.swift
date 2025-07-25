//
//  TFYSwiftJsonKit.swift
//  TFYSwiftPickerView
//
//  Created by 田风有 on 2022/5/19.
//  用途：JSON 编解码工具，支持对象、字典、数组与 JSON 的互转。
//

import Foundation
import UIKit

/// JSON解析错误类型
public enum TFYJsonError: Error {
    /// 无效数据
    case invalidData
    /// 编码失败
    case encodingFailed(Error)
    /// 解码失败
    case decodingFailed(Error)
    /// 无效类型
    case invalidType
    /// 自定义错误
    case customError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "无效的数据"
        case .encodingFailed(let error):
            return "编码失败: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "解码失败: \(error.localizedDescription)"
        case .invalidType:
            return "类型无效"
        case .customError(let message):
            return message
        }
    }
}

/// JSON编解码配置
public struct TFYJsonConfig {
    /// 日期编码策略
    public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601
    /// 日期解码策略
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601
    /// 键编码策略
    public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
    /// 键解码策略
    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    /// 数据格式化选项
    public var outputFormatting: JSONEncoder.OutputFormatting = []
    /// 浮点数编码策略
    public var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy = .throw
    /// 浮点数解码策略
    public var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw
    
    public init() {}
    
    /// 创建JSON编码器
    func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.outputFormatting = outputFormatting
        encoder.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        return encoder
    }
    
    /// 创建JSON解码器
    func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        return decoder
    }
}

/// JSON工具类
public class TFYSwiftJsonKit: NSObject {
    
    /// 默认配置
    public static var defaultConfig = TFYJsonConfig()
    
    // MARK: - 编码方法 (对象 -> JSON)
    
    /// 将对象编码为JSON数据
    /// - Parameters:
    ///   - value: 要编码的对象
    ///   - config: JSON配置
    /// - Returns: 编码结果
    public static func encode<T: Encodable>(_ value: T, 
                                          config: TFYJsonConfig = defaultConfig) -> Result<Data, TFYJsonError> {
        do {
            let encoder = config.makeEncoder()
            let data = try encoder.encode(value)
            return .success(data)
        } catch {
            return .failure(.encodingFailed(error))
        }
    }
    
    /// 将对象编码为JSON字符串
    /// - Parameters:
    ///   - value: 要编码的对象
    ///   - config: JSON配置
    /// - Returns: 编码结果
    public static func encodeToString<T: Encodable>(_ value: T, 
                                                   config: TFYJsonConfig = defaultConfig) -> Result<String, TFYJsonError> {
        switch encode(value, config: config) {
        case .success(let data):
            if let string = String(data: data, encoding: .utf8) {
                return .success(string)
            }
            return .failure(.invalidData)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - 解码方法 (JSON -> 对象)
    
    /// 将JSON数据解码为对象
    /// - Parameters:
    ///   - type: 目标类型
    ///   - data: JSON数据
    ///   - config: JSON配置
    /// - Returns: 解码结果
    public static func decode<T: Decodable>(_ type: T.Type, 
                                          from data: Data, 
                                          config: TFYJsonConfig = defaultConfig) -> Result<T, TFYJsonError> {
        guard !data.isEmpty else {
            print("TFYSwiftJsonKit: decode 传入数据为空")
            return .failure(.invalidData)
        }
        do {
            let decoder = config.makeDecoder()
            let value = try decoder.decode(type, from: data)
            return .success(value)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    /// 将JSON字符串解码为对象
    /// - Parameters:
    ///   - type: 目标类型
    ///   - string: JSON字符串
    ///   - config: JSON配置
    /// - Returns: 解码结果
    public static func decode<T: Decodable>(_ type: T.Type, 
                                          from string: String, 
                                          config: TFYJsonConfig = defaultConfig) -> Result<T, TFYJsonError> {
        guard let data = string.data(using: .utf8) else {
            return .failure(.invalidData)
        }
        return decode(type, from: data, config: config)
    }
    
    // MARK: - 字典/数组转换
    
    /// 将字典转换为JSON数据
    /// - Parameter dictionary: 字典
    /// - Returns: 转换结果
    public static func dataFrom(dictionary: [String: Any]) -> Result<Data, TFYJsonError> {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            return .success(data)
        } catch {
            return .failure(.encodingFailed(error))
        }
    }
    
    /// 将数组转换为JSON数据
    /// - Parameter array: 数组
    /// - Returns: 转换结果
    public static func dataFrom(array: [Any]) -> Result<Data, TFYJsonError> {
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            return .success(data)
        } catch {
            return .failure(.encodingFailed(error))
        }
    }
    
    /// 将JSON数据转换为字典
    /// - Parameter data: JSON数据
    /// - Returns: 转换结果
    public static func dictionary(from data: Data) -> Result<[String: Any], TFYJsonError> {
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return .success(dict)
            }
            return .failure(.invalidType)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    /// 将JSON数据转换为数组
    /// - Parameter data: JSON数据
    /// - Returns: 转换结果
    public static func array(from data: Data) -> Result<[Any], TFYJsonError> {
        do {
            if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] {
                return .success(array)
            }
            return .failure(.invalidType)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    // MARK: - 模型转换
    
    /// 字典转模型
    /// - Parameters:
    ///   - type: 模型类型
    ///   - dict: 字典
    ///   - config: JSON配置
    /// - Returns: 转换结果
    public static func model<T: Decodable>(_ type: T.Type, 
                                         from dict: [String: Any], 
                                         config: TFYJsonConfig = defaultConfig) -> Result<T, TFYJsonError> {
        switch dataFrom(dictionary: dict) {
        case .success(let data):
            return decode(type, from: data, config: config)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 数组转模型数组
    /// - Parameters:
    ///   - type: 模型类型
    ///   - array: 数组
    ///   - config: JSON配置
    /// - Returns: 转换结果
    public static func models<T: Decodable>(_ type: T.Type, 
                                          from array: [[String: Any]], 
                                          config: TFYJsonConfig = defaultConfig) -> Result<[T], TFYJsonError> {
        switch dataFrom(array: array) {
        case .success(let data):
            return decode([T].self, from: data, config: config)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 模型转字典
    /// - Parameters:
    ///   - model: 模型对象
    ///   - config: JSON配置
    /// - Returns: 转换结果
    public static func dictionary<T: Encodable>(from model: T, 
                                              config: TFYJsonConfig = defaultConfig) -> Result<[String: Any], TFYJsonError> {
        switch encode(model, config: config) {
        case .success(let data):
            return dictionary(from: data)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 模型数组转字典数组
    /// - Parameters:
    ///   - models: 模型数组
    ///   - config: JSON配置
    /// - Returns: 转换结果
    public static func dictionaries<T: Encodable>(from models: [T], 
                                                config: TFYJsonConfig = defaultConfig) -> Result<[[String: Any]], TFYJsonError> {
        switch encode(models, config: config) {
        case .success(let data):
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    return .success(array)
                }
                return .failure(.invalidType)
            } catch {
                return .failure(.decodingFailed(error))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - 工具方法
    
    /// 格式化JSON字符串
    /// - Parameter jsonString: JSON字符串
    /// - Returns: 格式化结果
    public static func prettyPrint(_ jsonString: String) -> Result<String, TFYJsonError> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(.invalidData)
        }
        
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                return .success(prettyString)
            }
            return .failure(.invalidData)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    /// 验证JSON字符串是否有效
    /// - Parameter jsonString: JSON字符串
    /// - Returns: 验证结果
    public static func validate(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else {
            return false
        }
        
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return true
        } catch {
            return false
        }
    }
    
    /// 合并多个JSON对象
    /// - Parameter objects: JSON对象数组
    /// - Returns: 合并结果
    public static func merge(_ objects: [[String: Any]]) -> [String: Any] {
        var result: [String: Any] = [:]
        objects.forEach { dict in
            dict.forEach { key, value in
                result[key] = value
            }
        }
        return result
    }
    
    /// 快速创建配置
    /// - Parameters:
    ///   - dateFormat: 日期格式
    ///   - keyStrategy: 键编码策略
    ///   - outputFormatting: 输出格式化选项
    /// - Returns: JSON配置
    public static func config(
        dateFormat: String? = nil,
        keyStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
        outputFormatting: JSONEncoder.OutputFormatting = []
    ) -> TFYJsonConfig {
        var config = TFYJsonConfig()
        
        if let dateFormat = dateFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            config.dateEncodingStrategy = .formatted(formatter)
            config.dateDecodingStrategy = .formatted(formatter)
        }
        
        config.keyEncodingStrategy = keyStrategy
        config.outputFormatting = outputFormatting
        return config
    }
    
    // MARK: - 高级功能
    
    /// 深度合并两个JSON对象
    /// - Parameters:
    ///   - target: 目标对象
    ///   - source: 源对象
    /// - Returns: 合并后的对象
    public static func deepMerge(_ target: [String: Any], with source: [String: Any]) -> [String: Any] {
        var result = target
        
        for (key, value) in source {
            if let dictValue = value as? [String: Any],
               let existingValue = result[key] as? [String: Any] {
                result[key] = deepMerge(existingValue, with: dictValue)
            } else if let arrayValue = value as? [Any],
                      let existingValue = result[key] as? [Any] {
                result[key] = existingValue + arrayValue
            } else {
                result[key] = value
            }
        }
        
        return result
    }
    
    /// 提取JSON路径的值
    /// - Parameters:
    ///   - json: JSON对象
    ///   - path: 路径，如 "user.profile.name"
    /// - Returns: 路径对应的值
    public static func extractValue(from json: [String: Any], at path: String) -> Any? {
        let keys = path.components(separatedBy: ".")
        var current: Any = json
        
        for key in keys {
            if let dict = current as? [String: Any] {
                current = dict[key] ?? NSNull()
            } else if let array = current as? [Any],
                      let index = Int(key),
                      index >= 0 && index < array.count {
                current = array[index]
            } else {
                return nil
            }
            
            if current is NSNull {
                return nil
            }
        }
        
        return current
    }
    
    /// 验证JSON Schema
    /// - Parameters:
    ///   - json: 要验证的JSON
    ///   - schema: Schema定义
    /// - Returns: 验证结果
    public static func validateSchema(_ json: Any, against schema: [String: Any]) -> Bool {
        // 基础Schema验证实现
        guard let type = schema["type"] as? String else { return true }
        
        switch type {
        case "object":
            guard let jsonObject = json as? [String: Any] else { return false }
            
            // 检查必需字段
            if let required = schema["required"] as? [String] {
                for field in required {
                    if jsonObject[field] == nil { return false }
                }
            }
            
            // 检查属性类型
            if let properties = schema["properties"] as? [String: [String: Any]] {
                for (key, value) in jsonObject {
                    if let propertySchema = properties[key] {
                        if !validateSchema(value, against: propertySchema) {
                            return false
                        }
                    }
                }
            }
            
        case "array":
            guard let jsonArray = json as? [Any] else { return false }
            
            // 检查数组元素类型
            if let items = schema["items"] as? [String: Any] {
                for item in jsonArray {
                    if !validateSchema(item, against: items) {
                        return false
                    }
                }
            }
            
            // 检查数组长度限制
            if let minItems = schema["minItems"] as? Int {
                if jsonArray.count < minItems { return false }
            }
            if let maxItems = schema["maxItems"] as? Int {
                if jsonArray.count > maxItems { return false }
            }
            
        case "string":
            guard json is String else { return false }
            
            // 检查字符串长度限制
            if let minLength = schema["minLength"] as? Int {
                if let str = json as? String, str.count < minLength { return false }
            }
            if let maxLength = schema["maxLength"] as? Int {
                if let str = json as? String, str.count > maxLength { return false }
            }
            
            // 检查正则表达式
            if let pattern = schema["pattern"] as? String {
                if let str = json as? String {
                    let regex = try? NSRegularExpression(pattern: pattern, options: [])
                    let range = NSRange(location: 0, length: str.count)
                    if regex?.firstMatch(in: str, options: [], range: range) == nil {
                        return false
                    }
                }
            }
            
        case "number":
            guard json is NSNumber else { return false }
            
            // 检查数值范围
            if let minimum = schema["minimum"] as? Double {
                if let num = json as? NSNumber, num.doubleValue < minimum { return false }
            }
            if let maximum = schema["maximum"] as? Double {
                if let num = json as? NSNumber, num.doubleValue > maximum { return false }
            }
            
        case "integer":
            guard json is NSNumber else { return false }
            if let num = json as? NSNumber {
                // 检查是否为整数
                if num.doubleValue.truncatingRemainder(dividingBy: 1) != 0 { return false }
            }
            
        case "boolean":
            guard json is Bool else { return false }
            
        case "null":
            guard json is NSNull else { return false }
            
        default:
            return true
        }
        
        return true
    }
    
    // MARK: - Schema构建器
    
    /// 创建对象Schema
    /// - Parameters:
    ///   - properties: 属性定义
    ///   - required: 必需字段
    /// - Returns: Schema定义
    public static func objectSchema(properties: [String: [String: Any]], required: [String] = []) -> [String: Any] {
        return [
            "type": "object",
            "properties": properties,
            "required": required
        ]
    }
    
    /// 创建数组Schema
    /// - Parameters:
    ///   - items: 数组元素Schema
    ///   - minItems: 最小元素数量
    ///   - maxItems: 最大元素数量
    /// - Returns: Schema定义
    public static func arraySchema(items: [String: Any], minItems: Int? = nil, maxItems: Int? = nil) -> [String: Any] {
        var schema: [String: Any] = [
            "type": "array",
            "items": items
        ]
        
        if let minItems = minItems {
            schema["minItems"] = minItems
        }
        if let maxItems = maxItems {
            schema["maxItems"] = maxItems
        }
        
        return schema
    }
    
    /// 创建字符串Schema
    /// - Parameters:
    ///   - minLength: 最小长度
    ///   - maxLength: 最大长度
    ///   - pattern: 正则表达式
    /// - Returns: Schema定义
    public static func stringSchema(minLength: Int? = nil, maxLength: Int? = nil, pattern: String? = nil) -> [String: Any] {
        var schema: [String: Any] = ["type": "string"]
        
        if let minLength = minLength {
            schema["minLength"] = minLength
        }
        if let maxLength = maxLength {
            schema["maxLength"] = maxLength
        }
        if let pattern = pattern {
            schema["pattern"] = pattern
        }
        
        return schema
    }
    
    /// 创建数字Schema
    /// - Parameters:
    ///   - minimum: 最小值
    ///   - maximum: 最大值
    /// - Returns: Schema定义
    public static func numberSchema(minimum: Double? = nil, maximum: Double? = nil) -> [String: Any] {
        var schema: [String: Any] = ["type": "number"]
        
        if let minimum = minimum {
            schema["minimum"] = minimum
        }
        if let maximum = maximum {
            schema["maximum"] = maximum
        }
        
        return schema
    }
    
    /// 创建整数Schema
    /// - Parameters:
    ///   - minimum: 最小值
    ///   - maximum: 最大值
    /// - Returns: Schema定义
    public static func integerSchema(minimum: Int? = nil, maximum: Int? = nil) -> [String: Any] {
        var schema: [String: Any] = ["type": "integer"]
        
        if let minimum = minimum {
            schema["minimum"] = minimum
        }
        if let maximum = maximum {
            schema["maximum"] = maximum
        }
        
        return schema
    }
}

// MARK: - Codable扩展
public extension Encodable {
    /// 转换为字典
    func toDictionary(config: TFYJsonConfig = .init()) -> Result<[String: Any], TFYJsonError> {
        return TFYSwiftJsonKit.dictionary(from: self, config: config)
    }
    
    /// 转换为JSON字符串
    func toJsonString(config: TFYJsonConfig = .init()) -> Result<String, TFYJsonError> {
        return TFYSwiftJsonKit.encodeToString(self, config: config)
    }
}

// MARK: - 数组扩展
public extension Array where Element: Encodable {
    /// 模型数组转字典数组
    func toDictionaries(config: TFYJsonConfig = .init()) -> Result<[[String: Any]], TFYJsonError> {
        return TFYSwiftJsonKit.dictionaries(from: self, config: config)
    }
    
    /// 模型数组转JSON字符串
    func toJsonString(config: TFYJsonConfig = .init()) -> Result<String, TFYJsonError> {
        return TFYSwiftJsonKit.encodeToString(self, config: config)
    }
}

// MARK: - Decodable扩展
public extension Decodable {
    /// 从字典创建模型
    static func from(dict: [String: Any], config: TFYJsonConfig = .init()) -> Result<Self, TFYJsonError> {
        return TFYSwiftJsonKit.model(Self.self, from: dict, config: config)
    }
    
    /// 从字典数组创建模型数组
    static func from(array: [[String: Any]], config: TFYJsonConfig = .init()) -> Result<[Self], TFYJsonError> {
        return TFYSwiftJsonKit.models(Self.self, from: array, config: config)
    }
}

// MARK: - TFYSwiftJsonKit 用法示例
/*
// 1. 基本模型与JSON互转
struct Address: Codable {
    let city: String
    let street: String
}
struct User: Codable {
    let id: Int
    let name: String
    let address: Address
    let tags: [String]
}
let address = Address(city: "北京", street: "中关村")
let user = User(id: 1, name: "张三", address: address, tags: ["VIP", "Swift"])

// 模型转JSON字符串
let jsonStringResult = user.toJsonString()
switch jsonStringResult {
case .success(let jsonString):
    print("模型转JSON字符串: \(jsonString)")
case .failure(let error):
    print("编码失败: \(error.localizedDescription)")
}

// JSON字符串转模型
let jsonString = "{"id":1,"name":"张三","address":{"city":"北京","street":"中关村"},"tags":["VIP","Swift"]}"
let userResult = User.from(dict: TFYSwiftJsonKit.dictionary(from: jsonString.data(using: .utf8)!).value ?? [:])
switch userResult {
case .success(let user):
    print("JSON转模型: \(user)")
case .failure(let error):
    print("解码失败: \(error.localizedDescription)")
}

// 2. 嵌套模型数组转JSON
let users = [user, User(id: 2, name: "李四", address: address, tags: ["同事"])]
let usersJsonString = users.toJsonString().value ?? ""
print("模型数组转JSON字符串: \(usersJsonString)")

// 3. 字典/数组与模型互转
let dict: [String: Any] = ["id": 3, "name": "王五", "address": ["city": "上海", "street": "浦东"], "tags": ["新用户"]]
let userFromDict = User.from(dict: dict)
print("字典转模型: \(userFromDict)")

let userDict = user.toDictionary().value ?? [:]
print("模型转字典: \(userDict)")

// 4. JSON格式化、美化
let uglyJson = "{\"id\":1,\"name\":\"张三\",\"address\":{\"city\":\"北京\",\"street\":\"中关村\"},\"tags\":[\"VIP\",\"Swift\"]}"
let pretty = TFYSwiftJsonKit.prettyPrint(uglyJson)
print("格式化后的JSON:\n\(pretty.value ?? "")")

// 5. JSON Schema 验证
let schema = TFYSwiftJsonKit.objectSchema(properties: [
    "id": TFYSwiftJsonKit.integerSchema(minimum: 1),
    "name": TFYSwiftJsonKit.stringSchema(minLength: 1),
    "address": TFYSwiftJsonKit.objectSchema(properties: [
        "city": TFYSwiftJsonKit.stringSchema(),
        "street": TFYSwiftJsonKit.stringSchema()
    ], required: ["city", "street"]),
    "tags": TFYSwiftJsonKit.arraySchema(items: TFYSwiftJsonKit.stringSchema())
], required: ["id", "name", "address", "tags"])

let userDictForSchema = user.toDictionary().value ?? [:]
let isValid = TFYSwiftJsonKit.validateSchema(userDictForSchema, against: schema)
print("模型是否符合Schema: \(isValid)")
*/
