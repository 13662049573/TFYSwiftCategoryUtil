//
//  Codable+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/19.
//

import Foundation
import UIKit

public protocol TFYCodable: Codable {
    /// 转换为字典
    func toDict() -> Dictionary<String, Any>?
    /// 转换为Data
    func toData() -> Data?
    /// 转换为JSON字符串
    func toString() -> String?
}

public extension TFYCodable {
    /// 转换为Data
    /// - Returns: 编码后的Data，失败返回nil
    func toData() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            TFYUtils.Logger.log("TFYCodable: 编码为Data失败 - \(error.localizedDescription)")
            return nil
        }
    }
    /// 转换为字典
    /// - Returns: 字典，失败返回nil
    func toDict() -> Dictionary<String, Any>? {
        guard let data = toData() else {
            TFYUtils.Logger.log("TFYCodable: model to data error")
            return nil
        }
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            TFYUtils.Logger.log("TFYCodable: Data转字典失败 - \(error.localizedDescription)")
            return nil
        }
    }
    /// 转换为JSON字符串
    /// - Returns: JSON字符串，失败返回nil
    func toString() -> String? {
        guard let data = toData() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// 转换为格式化的JSON字符串
    /// - Returns: 格式化的JSON字符串，失败返回nil
    /// - Note: 支持iOS 15+，适配iPhone和iPad
    func toPrettyString() -> String? {
        guard let data = toData() else { return nil }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8)
        } catch {
            TFYUtils.Logger.log("TFYCodable: 格式化JSON失败 - \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 深拷贝对象
    /// - Returns: 深拷贝的对象，失败返回nil
    /// - Note: 支持iOS 15+，适配iPhone和iPad
    func deepCopy() -> Self? {
        guard let data = toData() else { return nil }
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            TFYUtils.Logger.log("TFYCodable: 深拷贝失败 - \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 验证对象是否有效
    /// - Returns: 如果对象可以正确编码和解码则返回true
    /// - Note: 支持iOS 15+，适配iPhone和iPad
    var isValid: Bool {
        guard let data = toData() else { return false }
        do {
            _ = try JSONDecoder().decode(Self.self, from: data)
            return true
        } catch {
            return false
        }
    }
}

