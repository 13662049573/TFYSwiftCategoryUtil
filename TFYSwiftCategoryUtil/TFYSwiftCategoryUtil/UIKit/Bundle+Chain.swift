//
//  Bundle+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/15.
//

import Foundation
import UIKit

public enum BundleType {
    // 自己 module 下的 bundle 文件
    case currentBundle
    // 其他 module 下的 bundle 文件
    case otherBundle
}

public extension TFY where Base: Bundle {
    // MARK: 2.1、App命名空间
    /// App命名空间
    static var namespace: String {
        guard let namespace =  Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else { return "" }
        return  namespace
    }
    
    // MARK: 2.2、项目/app 的名字
    /// 项目/app 的名字
    static var bundleName: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    }
    
    // MARK: 2.4、获取app的 Build ID
    /// 获取app的 Build ID
    static var appBuild: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
    }
    
    // MARK: 2.5、获取app的 Bundle Identifier
    /// 获取app的 Bundle Identifier
    static var appBundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    // MARK: 2.7、App 名称
    /// App 名称
    static var appDisplayName: String {
        return (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) ?? ""
    }
    
    // MARK: 1.1、通过 通过字符串地址 从 Bundle 里面获取资源文件（支持当前的 Moudle下的Bundle和其他Moudle下的 Bundle）
    /// 从 Bundle 里面获取资源文件（支持当前的 Moudle下的Bundle和其他Moudle下的 Bundle）
    /// - Parameters:
    ///   - bundName: bundle 的名字
    ///   - resourceName: 资源的名字，比如图片的名字
    ///   - bundleType: 类型：默认 currentBundle是在自己 module 下的 bundle 文件
    /// - Returns: 资源路径
    static func getBundlePathResource(bundName: String, resourceName: String, bundleType: BundleType = .currentBundle) -> String {
        if bundleType == .otherBundle {
            return "Frameworks/\(bundName).framework/\(bundName).bundle/\(resourceName)"
        }
        return "\(bundName).bundle/" + "\(resourceName)"
    }
    
    // MARK: 1.2、通过 Bundle 里面获取资源文件（支持当前的 Moudle下的Bundle和其他Moudle下的
    /// 通过 Bundle 里面获取资源文件（支持当前的 Moudle下的Bundle和其他Moudle下的
    /// - Parameters:
    ///   - bundName: bundle 的名字
    ///   - resourceName: 资源的名字，比如图片的名字(需要写出完整的名字，如图片：icon@2x)
    ///   - bundleType: 类型：默认 currentBundle是在自己 module 下的 bundle 文件
    /// - Returns: 资源路径
    static func getBundleResource(bundName: String, resourceName: String, ofType ext: String?, bundleType: BundleType = .currentBundle) -> String? {
        let resourcePath = bundleType == .otherBundle ? "Frameworks/\(bundName).framework/\(bundName)" : "\(bundName)"
        guard let bundlePath = Bundle.main.path(forResource: resourcePath, ofType: "bundle"), let bundle = Bundle(path: bundlePath) else {
            return nil
        }
        let imageStr = bundle.path(forResource: resourceName, ofType: ext)
        return imageStr
    }
    
    // MARK: 1.3、读取项目本地文件数据
    /// 读取项目本地文件数据
    /// - Parameters:
    ///   - fileName: 文件名字
    ///   - type: 资源类型
    /// - Returns: 返回对应URL
    static func readLocalData(_ fileName: String, _ type: String) -> URL? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: type) else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
    
}

public extension Bundle {
    /// 应用显示版本 (CFBundleShortVersionString)
    static var appVersion: String? {
        return main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    /// 应用构建版本 (CFBundleVersion)
    static var buildVersion: String? {
        return main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    /// 完整版本信息 (格式：1.0.0.123)
    static var fullVersion: String? {
        guard let version = appVersion, let build = buildVersion else { return nil }
        return "\(version).\(build)"
    }
}

public extension UIDevice {
    /// 便捷访问版本信息
    static var appVersion: String { Bundle.appVersion ?? "0.0.0" }
    static var buildVersion: String { Bundle.buildVersion ?? "0" }
    static var fullVersion: String { Bundle.fullVersion ?? "0.0.0.0" }
}

// 版本比较扩展
public extension String {
    
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."
        var versionComponents = self.components(separatedBy: versionDelimiter)
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)
        
        let zeroDiff = versionComponents.count - otherVersionComponents.count
        
        if zeroDiff > 0 {
            otherVersionComponents += Array(repeating: "0", count: zeroDiff)
        } else if zeroDiff < 0 {
            versionComponents += Array(repeating: "0", count: -zeroDiff)
        }
        
        for (v, ov) in zip(versionComponents, otherVersionComponents) {
            let vInt = Int(v) ?? 0
            let ovInt = Int(ov) ?? 0
            if vInt < ovInt {
                return .orderedAscending
            } else if vInt > ovInt {
                return .orderedDescending
            }
        }
        return .orderedSame
    }
}
