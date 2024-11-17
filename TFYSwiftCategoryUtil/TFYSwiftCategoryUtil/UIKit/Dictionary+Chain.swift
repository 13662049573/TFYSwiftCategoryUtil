//
//  Dictionary+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/18.
//

import Foundation
import AVFoundation

extension Dictionary: TFYCompatible {}

public extension Dictionary {
    
    // MARK: 1.1、检查字典里面是否有某个 key
    /// 检查字典里面是否有某个 key
    func has(_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    // MARK: 1.2、字典的key或者value组成的数组
    /// 字典的key或者value组成的数组
    /// - Parameter map: map
    /// - Returns: 数组
    func toArray<V>(_ map: (Key, Value) -> V) -> [V] {
        return self.map(map)
    }
    
    // MARK: 1.3、JSON字符串 -> 字典
    /// 本地JSON 转 字典
    /// - Parameter json: JSON字符串
    /// - Returns: 字典
    static func pathForResource(name:String,ofType:String) -> Dictionary<String, Any>? {
        var encoding:String.Encoding = .ascii
        
        let path:String = Bundle.main.path(forResource: name, ofType: ofType)!
        
        if let plays = try? String(contentsOfFile: path, usedEncoding: &encoding){
            let dict = Dictionary.jsonToDictionary(json: plays)
            
            return dict
        }
        return nil
    }
    // MARK: 1.3、JSON字符串 -> 字典
    /// JsonString转为字典
    /// - Parameter json: JSON字符串
    /// - Returns: 字典
    static func jsonToDictionary(json: String) -> Dictionary<String, Any>? {
        if let data = (try? JSONSerialization.jsonObject(
            with: json.data(using: String.Encoding.utf8,allowLossyConversion: true)!,
            options: JSONSerialization.ReadingOptions.mutableContainers)) as? Dictionary<String, Any> {
            return data
        } else {
            return nil
        }
    }
    
    // MARK: 1.4、字典 -> JSON字符串
    /// 字典转换为JSONString
    static func toJSON() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) {
            let jsonStr = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            return String(jsonStr ?? "")
        }
        return nil
    }
    
    // MARK: 1.5、字典里面所有的 key
    /// 字典里面所有的key
    /// - Returns: key 数组
    func allKeys() -> [Key] {
        /*
         shuffled：不会改变原数组，返回一个新的随机化的数组。  可以用于let 数组
         */
        return self.keys.shuffled()
    }
    
    // MARK: 1.6、字典里面所有的 value
    /// 字典里面所有的value
    /// - Returns: value 数组
    func allValues() -> [Value] {
        return self.values.shuffled()
    }
    
    // MARK: 1.7、设置value
    subscript<Result>(key: Key, as type: Result.Type) -> Result? {
        get {
            return self[key] as? Result
        }
        set {
            // 如果传⼊ nil, 就删除现存的值。
            guard let value = newValue else {
                self[key] = nil
                return
            }
            // 如果类型不匹配，就忽略掉。
            guard let value2 = value as? Value else {
                return
            }
            self[key] = value2
        }
    }
    
    // MARK: 1.8、设置value
    /// 设置value
    /// - Parameters:
    ///   - keys: key链
    ///   - newValue: 新的value
    @discardableResult
    mutating func setValue(keys: [String], newValue: Any) -> Bool {
        guard keys.count > 1 else {
            guard keys.count == 1, let key = keys[0] as? Dictionary<Key, Value>.Keys.Element else {
                return false
            }
            self[key] = (newValue as! Value)
            return true
        }
        guard let key = keys[0] as? Dictionary<Key, Value>.Keys.Element, self.keys.contains(key), var value1 = self[key] as? [String: Any] else {
            return false
        }
        let result = Dictionary<String, Any>.value(keys: Array(keys[1..<keys.count]), oldValue: &value1, newValue: newValue)
        self[key] = (value1 as! Value)
        return result
    }
    
    /// 字典深层次设置value
    /// - Parameters:
    ///   - keys: key链
    ///   - oldValue: 字典
    ///   - newValue: 新的值
    @discardableResult
    private static func value(keys: [String], oldValue: inout [String: Any], newValue: Any) -> Bool {
        guard keys.count > 1 else {
            oldValue[keys[0]] = newValue
            return true
        }
        guard var value1 = oldValue[keys[0]] as? [String : Any] else { return false}
        let key = Array(keys[1..<keys.count])
        let result = value(keys: key, oldValue: &value1, newValue: newValue)
        oldValue[keys[0]] = value1
        return result
    }
    
    /// key是否存在在字典中
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    /// 移除key对应的value
    mutating func removeAll<S: Sequence>(keys: S) where S.Element == Key {
        keys.forEach { removeValue(forKey: $0) }
    }
    
    /// 字典转Data
    func toData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    /// 字典转json
    func toJson(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
    func toModel<T>(_ type: T.Type) -> T? where T: Decodable {
        return self.toData()?.tfy.toModel(T.self)
    }
}

// MARK: - 二、其他基本扩展
public extension TFY where Base == Dictionary<String, Any> {
    
    // MARK: 2.1、字典转JSON
    /// 字典转JSON
    @discardableResult
    func dictionaryToJson() -> String? {
        if (!JSONSerialization.isValidJSONObject(base)) {
            TFYUtils.log("无法解析出JSONString")
            return nil
        }
        if let data = try? JSONSerialization.data(withJSONObject: base) {
            let JSONString = NSString(data:data,encoding: String.Encoding.utf8.rawValue)
            return JSONString! as String
        } else {
            TFYUtils.log("无法解析出JSONString")
            return nil
        }
    }
}


