//
//  TFYSwiftJsonKit.swift
//  TFYSwiftPickerView
//
//  Created by 田风有 on 2022/5/19.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import Foundation
import UIKit
import Dispatch

extension JSONEncoder {
    func encode<T: Encodable>(_ value: T, using customEncodeMethod: @escaping (T, Encoder) throws -> Void) throws -> Data {
        let anyEncodable = AnyEncodable(value, customEncodeMethod)
        return try self.encode(anyEncodable)
    }
}

struct AnyEncodable<T: Encodable>: Encodable {
    private let _encode: (T, Encoder) throws -> Void
    private let value: T

    init(_ value: T, _ customEncodeMethod: @escaping (T, Encoder) throws -> Void) {
        self.value = value
        self._encode = customEncodeMethod
    }

    func encode(to encoder: Encoder) throws {
        try _encode(value, encoder)
    }
}

public class TFYSwiftJsonKit: NSObject {

    public static func getJsonStrFromDictionary(_ dictionary: [String : Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            if var jsonString = String(data: jsonData, encoding: .utf8) {
                // 替换转义字符
                jsonString = jsonString.replacingOccurrences(of: "\\/", with: "/")
//                XCDLog(jsonString)
                return jsonString
            }
            return nil
        } catch {
            TFYLog(error.localizedDescription)
            return nil
        }
    }
    
    public static func getJsonDataFromDictionary(_ dictionary: [String : Any]) -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            return data
        } catch {
            TFYLog(error)
            return nil
        }
    }
    
    /// 字典转字符串
    public static func dicValueString(_ dic:[String : Any]) -> String? {
        if let dicData = TFYSwiftJsonKit.getJsonDataFromDictionary(dic) {
            return String(data:dicData, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    /// 数组转字符串
    public static func arrValueString(_ array: Array<Dictionary<String, Any>>) -> String? {
        if let arrData = TFYSwiftJsonKit.getJsonDataFromArray(array) {
            return String(data:arrData, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    /// MARK: 字符串转字典
    public static func stringValueDic(_ str: String) -> [String : Any]?{
        let data = str.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    
    /// MARK: 字符串转数组
    public static func stringValueArr(_ str: String) -> [Any]?{
        let data = str.data(using: String.Encoding.utf8)
        if let array = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [Any] {
            return array
        }
        return nil
    }
    
    public static func getJsonDataFromArray(_ array: Array<Dictionary<String, Any>>) -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            return data
        } catch {
            TFYLog(error)
            return nil
        }
    }
    
    public static func decodeJsonDataToModel<T: Decodable>(_ data: Data, type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let model = try decoder.decode(T.self, from: data)
            return model
        } catch {
            TFYLog(error)
            return nil
        }
    }
    
    /// 模型转JSON字符串
    public static func toJson<T>(_ model: T) -> String? where T : Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        guard let data = try? encoder.encode(model) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public static func modelsToJson<T>(_ models: [T], outputFormat: JSONEncoder.OutputFormatting = .prettyPrinted) -> String? where T : Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormat
        guard let data = try? encoder.encode(models) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// JSON字符串转字典
    public static func dictionaryFrom(jsonString: String) -> Dictionary<String, Any>? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers), let result = dict as? Dictionary<String, Any> else { return nil }
        return result
    }

    /// JSON字符串转数组
    public static func arrayFrom(jsonString: String) -> [Dictionary<String, Any>]? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        guard let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers), let result = array as? [Dictionary<String, Any>] else { return nil }
        return result
    }
    
    /// JSON字符串/字典 转模型
    public static func toModel<T>(_ type: T.Type, value: Any) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        return try? decoder.decode(type, from: data)
    }
}
