import Foundation

// MARK: - Logging

extension GCDAsyncSocket {
    
    /// Log levels for socket operations
    public enum LogLevel: Int {
        case off = 0
        case error
        case warning
        case info
        case verbose
        case debug
    }
    
    /// Current log level
    public static var logLevel: LogLevel = .off
    
    /// Log message with error level
    internal func LogError(_ message: String, function: String = #function) {
        if GCDAsyncSocket.logLevel.rawValue >= LogLevel.error.rawValue {
            print("🔴 [ERROR] [\(type(of: self))] \(function): \(message)")
        }
    }
    
    /// Log message with warning level
    internal func LogWarn(_ message: String, function: String = #function) {
        if GCDAsyncSocket.logLevel.rawValue >= LogLevel.warning.rawValue {
            print("⚠️ [WARN] [\(type(of: self))] \(function): \(message)")
        }
    }
    
    /// Log message with info level
    internal func LogInfo(_ message: String, function: String = #function) {
        if GCDAsyncSocket.logLevel.rawValue >= LogLevel.info.rawValue {
            print("ℹ️ [INFO] [\(type(of: self))] \(function): \(message)")
        }
    }
    
    /// Log message with verbose level
    internal func LogVerbose(_ message: String, function: String = #function) {
        if GCDAsyncSocket.logLevel.rawValue >= LogLevel.verbose.rawValue {
            print("📝 [VERBOSE] [\(type(of: self))] \(function): \(message)")
        }
    }
    
    /// Log message with debug level
    internal func LogDebug(_ message: String, function: String = #function) {
        if GCDAsyncSocket.logLevel.rawValue >= LogLevel.debug.rawValue {
            print("🔍 [DEBUG] [\(type(of: self))] \(function): \(message)")
        }
    }
    
    /// Log data with specified level
    internal func LogData(_ data: Data, length: Int? = nil, prefix: String = "", level: LogLevel = .debug) {
        guard GCDAsyncSocket.logLevel.rawValue >= level.rawValue else { return }
        
        let actualLength = length ?? data.count
        let bytes = [UInt8](data.prefix(actualLength))
        var logString = prefix
        
        // Add hex representation
        logString += "Hex: "
        for byte in bytes {
            logString += String(format: "%02x ", byte)
        }
        
        // Add ASCII representation if possible
        logString += "\nASCII: "
        for byte in bytes {
            if (0x20...0x7e).contains(byte) {
                logString += String(format: "%c", byte)
            } else {
                logString += "."
            }
        }
        
        switch level {
        case .error:   LogError(logString)
        case .warning: LogWarn(logString)
        case .info:    LogInfo(logString)
        case .verbose: LogVerbose(logString)
        case .debug:   LogDebug(logString)
        case .off:     break
        }
    }
}

// MARK: - Debug Description

extension GCDAsyncSocket {
    
    /// Get socket flags description
    internal var flagsDescription: String {
        var desc = "Socket Flags:"
        if flags.contains(.started)              { desc += " Started" }
        if flags.contains(.connected)            { desc += " Connected" }
        if flags.contains(.forbidReadsWrites)    { desc += " ForbidReadsWrites" }
        if flags.contains(.readsPaused)          { desc += " ReadsPaused" }
        if flags.contains(.writesPaused)         { desc += " WritesPaused" }
        if flags.contains(.disconnectAfterReads) { desc += " DisconnectAfterReads" }
        if flags.contains(.disconnectAfterWrites){ desc += " DisconnectAfterWrites" }
        if flags.contains(.socketCanAcceptBytes) { desc += " SocketCanAcceptBytes" }
        if flags.contains(.readSourceSuspended)  { desc += " ReadSourceSuspended" }
        if flags.contains(.writeSourceSuspended) { desc += " WriteSourceSuspended" }
        if flags.contains(.queuedTLS)           { desc += " QueuedTLS" }
        if flags.contains(.startingReadTLS)     { desc += " StartingReadTLS" }
        if flags.contains(.startingWriteTLS)    { desc += " StartingWriteTLS" }
        if flags.contains(.socketSecure)        { desc += " SocketSecure" }
        if flags.contains(.socketHasReadEOF)    { desc += " SocketHasReadEOF" }
        if flags.contains(.readStreamClosed)    { desc += " ReadStreamClosed" }
        if flags.contains(.dealloc)             { desc += " Dealloc" }
        if flags.contains(.connecting)          { desc += " Connecting" }
        return desc
    }
    
    /// Get socket config description
    internal var configDescription: String {
        var desc = "Socket Config:"
        if config.contains(.IPv4Disabled)            { desc += " IPv4Disabled" }
        if config.contains(.IPv6Disabled)            { desc += " IPv6Disabled" }
        if config.contains(.preferIPv6)              { desc += " PreferIPv6" }
        if config.contains(.allowHalfDuplexConnection){ desc += " AllowHalfDuplexConnection" }
        return desc
    }
} 