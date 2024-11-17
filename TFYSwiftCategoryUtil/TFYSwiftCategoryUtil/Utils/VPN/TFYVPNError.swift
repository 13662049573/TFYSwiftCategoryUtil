//
//  TFYVPNError.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation

/// VPN错误类型
public enum VPNError: LocalizedError {
    /// 网络不可用
    case networkUnavailable
    /// 配置错误
    case configurationError(String)
    /// 连接错误
    case connectionError(String)
    /// 认证错误
    case authenticationError(String)
    /// 协议错误
    case protocolError(String)
    /// 加密错误
    case encryptionError(String)
    /// 混淆错误
    case obfuscationError(String)
    /// 超时错误
    case timeoutError
    /// 达到最大重连次数
    case maxReconnectAttemptsReached
    /// 未知错误
    case unknownError(String)
    
    /// 错误描述
    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "网络不可用"
        case .configurationError(let message):
            return "配置错误: \(message)"
        case .connectionError(let message):
            return "连接错误: \(message)"
        case .authenticationError(let message):
            return "认证错误: \(message)"
        case .protocolError(let message):
            return "协议错误: \(message)"
        case .encryptionError(let message):
            return "加密错误: \(message)"
        case .obfuscationError(let message):
            return "混淆错误: \(message)"
        case .timeoutError:
            return "连接超时"
        case .maxReconnectAttemptsReached:
            return "达到最大重连次数"
        case .unknownError(let message):
            return "未知错误: \(message)"
        }
    }
}

/// VPN状态
public enum VPNStatus: CustomStringConvertible {
    /// 无效
    case invalid
    /// 断开连接
    case disconnected
    /// 正在连接
    case connecting
    /// 已连接
    case connected
    /// 正在断开连接
    case disconnecting
    /// 正在重新连接
    case reasserting
    
    /// 状态描述
    public var description: String {
        switch self {
        case .invalid:
            return "无效"
        case .disconnected:
            return "已断开连接"
        case .connecting:
            return "正在连接"
        case .connected:
            return "已连接"
        case .disconnecting:
            return "正在断开连接"
        case .reasserting:
            return "正在重新连接"
        }
    }
    
    /// 是否处于活动状态（连接中或已连接）
    public var isActive: Bool {
        switch self {
        case .connecting, .connected, .reasserting:
            return true
        case .disconnected, .disconnecting, .invalid:
            return false
        }
    }
    
    /// 是否已连接
    public var isConnected: Bool {
        return self == .connected
    }
    
    /// 是否正在连接
    public var isConnecting: Bool {
        return self == .connecting || self == .reasserting
    }
    
    /// 是否已断开
    public var isDisconnected: Bool {
        return self == .disconnected || self == .invalid
    }
}
