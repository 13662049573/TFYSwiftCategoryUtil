import Foundation

// MARK: - Send Packet
class GCDAsyncUdpSendPacket {
    let buffer: Data
    let timeout: TimeInterval
    let tag: Int
    
    var resolveInProgress = false
    var filterInProgress = false
    
    var resolvedAddresses: [Data]?
    var resolveError: Error?
    
    var address: Data?
    var addressFamily: Int32 = 0
    
    init(data: Data, timeout: TimeInterval, tag: Int) {
        self.buffer = data
        self.timeout = timeout
        self.tag = tag
    }
}

// MARK: - Special Packet
class GCDAsyncUdpSpecialPacket: GCDAsyncUdpSendPacket {
    override init(data: Data = Data(), timeout: TimeInterval = -1, tag: Int = 0) {
        super.init(data: data, timeout: timeout, tag: tag)
    }
} 