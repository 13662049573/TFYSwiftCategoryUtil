////
////  RuleEditorViewModel.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 规则编辑器视图模型
//final class RuleEditorViewModel {
//    
//    // MARK: - 可观察属性
//    let validationErrors = Observable<[String: String]>([:])
//    let isSaving = Observable<Bool>(false)
//    let error = Observable<Error?>(nil)
//    
//    // MARK: - 属性
//    let rule: RoutingRule?
//    var isEditing: Bool { rule != nil }
//    
//    private let configManager = ConfigurationManager.shared
//    private let validator = RuleValidator()
//    
//    // MARK: - 初始化
//    init(rule: RoutingRule? = nil) {
//        self.rule = rule
//    }
//    
//    // MARK: - 公共方法
//    func validateName(_ name: String?) {
//        var errors = validationErrors.value
//        if let error = validator.validateName(name) {
//            errors["name"] = error
//        } else {
//            errors.removeValue(forKey: "name")
//        }
//        validationErrors.value = errors
//    }
//    
//    func validateValue(_ value: String?) {
//        var errors = validationErrors.value
//        if let error = validator.validateValue(value) {
//            errors["value"] = error
//        } else {
//            errors.removeValue(forKey: "value")
//        }
//        validationErrors.value = errors
//    }
//    
//    func loadAvailableServers() -> [ServerConfig] {
//        guard let config: ProxyConfig = configManager.getConfiguration(.proxy) else {
//            return []
//        }
//        return config.servers
//    }
//    
//    func saveRule(_ rule: RoutingRule, completion: @escaping (Result<RoutingRule, Error>) -> Void) {
//        // 验证规则
//        if let error = validator.validateRule(rule) {
//            completion(.failure(error))
//            return
//        }
//        
//        isSaving.value = true
//        
//        guard var config: ProxyConfig = configManager.getConfiguration(.proxy) else {
//            isSaving.value = false
//            completion(.failure(ConfigError.configurationNotFound))
//            return
//        }
//        
//        if let index = config.routingRules.firstIndex(where: { $0.id == rule.id }) {
//            config.routingRules[index] = rule
//        } else {
//            config.routingRules.append(rule)
//        }
//        
//        do {
//            try configManager.updateConfiguration(.proxy, config: config)
//            isSaving.value = false
//            completion(.success(rule))
//        } catch {
//            isSaving.value = false
//            completion(.failure(error))
//        }
//    }
//}
//
//// MARK: - 规则验证器
//final class RuleValidator {
//    
//    func validateRule(_ rule: RoutingRule) -> Error? {
//        if rule.name.isEmpty {
//            return RuleError.invalidName("Name cannot be empty")
//        }
//        
//        if rule.value.isEmpty {
//            return RuleError.invalidValue("Value cannot be empty")
//        }
//        
//        // 根据规则类型验证值格式
//        switch rule.type {
//        case .domain:
//            if !isValidDomain(rule.value) {
//                return RuleError.invalidValue("Invalid domain format")
//            }
//            
//        case .ipCIDR:
//            if !isValidCIDR(rule.value) {
//                return RuleError.invalidValue("Invalid CIDR format")
//            }
//            
//        case .geoIP:
//            if !isValidGeoIP(rule.value) {
//                return RuleError.invalidValue("Invalid GeoIP format")
//            }
//            
//        case .port:
//            if !isValidPort(rule.value) {
//                return RuleError.invalidValue("Invalid port format")
//            }
//            
//        case .process:
//            if !isValidProcess(rule.value) {
//                return RuleError.invalidValue("Invalid process name")
//            }
//            
//        case .regex:
//            if !isValidRegex(rule.value) {
//                return RuleError.invalidValue("Invalid regular expression")
//            }
//        }
//        
//        return nil
//    }
//    
//    func validateName(_ name: String?) -> String? {
//        guard let name = name else {
//            return "Name is required"
//        }
//        
//        if name.isEmpty {
//            return "Name cannot be empty"
//        }
//        
//        if name.count > 50 {
//            return "Name is too long (max 50 characters)"
//        }
//        
//        return nil
//    }
//    
//    func validateValue(_ value: String?) -> String? {
//        guard let value = value else {
//            return "Value is required"
//        }
//        
//        if value.isEmpty {
//            return "Value cannot be empty"
//        }
//        
//        return nil
//    }
//    
//    // MARK: - 私有验证方法
//    private func isValidDomain(_ value: String) -> Bool {
//        // 域名格式验证
//        let pattern = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
//        return value.range(of: pattern, options: .regularExpression) != nil
//    }
//    
//    private func isValidCIDR(_ value: String) -> Bool {
//        // CIDR格式验证
//        let parts = value.split(separator: "/")
//        guard parts.count == 2,
//              let prefix = Int(parts[1]),
//              prefix >= 0 && prefix <= 32 else {
//            return false
//        }
//        
//        let ipParts = parts[0].split(separator: ".")
//        guard ipParts.count == 4 else {
//            return false
//        }
//        
//        return ipParts.allSatisfy { part in
//            guard let num = Int(part) else { return false }
//            return num >= 0 && num <= 255
//        }
//    }
//    
//    private func isValidGeoIP(_ value: String) -> Bool {
//        // GeoIP格式验证 (两字母国家代码)
//        let pattern = "^[A-Z]{2}$"
//        return value.range(of: pattern, options: .regularExpression) != nil
//    }
//    
//    private func isValidPort(_ value: String) -> Bool {
//        // 端口格式验证
//        guard let port = Int(value) else {
//            return false
//        }
//        return port > 0 && port <= 65535
//    }
//    
//    private func isValidProcess(_ value: String) -> Bool {
//        // 进程名称验证
//        return !value.isEmpty && value.count <= 100
//    }
//    
//    private func isValidRegex(_ value: String) -> Bool {
//        // 正则表达式验证
//        do {
//            _ = try NSRegularExpression(pattern: value)
//            return true
//        } catch {
//            return false
//        }
//    }
//}
//
//// MARK: - 规则错误
//enum RuleError: LocalizedError {
//    case invalidName(String)
//    case invalidValue(String)
//    case invalidType(String)
//    case invalidAction(String)
//    case invalidServer(String)
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidName(let message): return message
//        case .invalidValue(let message): return message
//        case .invalidType(let message): return message
//        case .invalidAction(let message): return message
//        case .invalidServer(let message): return message
//        }
//    }
//}
//
//// MARK: - 规则类型扩展
//extension RuleType {
//    var displayName: String {
//        switch self {
//        case .domain: return "Domain"
//        case .ipCIDR: return "IP CIDR"
//        case .geoIP: return "GeoIP"
//        case .port: return "Port"
//        case .process: return "Process"
//        case .regex: return "Regular Expression"
//        }
//    }
//    
//    var formatHelp: String {
//        switch self {
//        case .domain:
//            return "Enter a domain name (e.g., example.com)"
//        case .ipCIDR:
//            return "Enter an IP range in CIDR notation (e.g., 192.168.1.0/24)"
//        case .geoIP:
//            return "Enter a two-letter country code (e.g., US)"
//        case .port:
//            return "Enter a port number (1-65535)"
//        case .process:
//            return "Enter a process name (e.g., chrome)"
//        case .regex:
//            return "Enter a regular expression pattern"
//        }
//    }
//}
//
//// MARK: - 规则动作扩展
//extension RuleAction {
//    var displayName: String {
//        switch self {
//        case .proxy: return "Proxy"
//        case .direct: return "Direct"
//        case .reject: return "Reject"
//        case .byServer(let serverId): return serverId != nil ? "By Server" : "By Server"
//        }
//    }
//    
//    static func fromDisplayName(_ name: String, serverName: String?) -> RuleAction? {
//        switch name {
//        case "Proxy": return .proxy
//        case "Direct": return .direct
//        case "Reject": return .reject
//        case "By Server":
//            guard let serverName = serverName else { return nil }
//            return .byServer(serverName)
//        default: return nil
//        }
//    }
//}
