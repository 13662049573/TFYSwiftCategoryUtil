//
//  TFYSwiftJsonKit.swift
//  TFYSwiftPickerView
//
//  Created by 田风有 on 2022/5/19.
//  Copyright © 2022 TFYSwift. All rights reserved.
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
