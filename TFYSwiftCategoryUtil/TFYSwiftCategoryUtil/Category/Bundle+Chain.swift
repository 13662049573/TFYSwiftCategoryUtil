//
//  Bundle+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/15.
//

import Foundation

public extension Bundle {
    /// App命名空间
    static var namespace: String {
        return (Bundle.main.infoDictionary?["CFBundleExecutable"] as? String) ?? ""
    }

    /// App 名称
    static var appDisplayName: String {
        return (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) ?? ""
    }

    /// 应用名称
    static var appBundleName: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    }

    /// 应用ID
    static var appBundleID: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String) ?? ""
    }

    /// 应用版本号
    static var appVersion: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    }

    /// 应用构建版本号
    static var appBuildVersion: String? {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
    }
}
