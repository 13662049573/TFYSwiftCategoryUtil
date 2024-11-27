import Foundation

// 定义错误代码常量
private enum CFHostErrorCode {
    static let unknown = -1
    static let hostNotFound = 1
    static let nameSyntaxError = 2
    static let serverFailed = 3
    static let noAddress = 4
}

protocol SimplePingDelegate: AnyObject {
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data)
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error)
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16)
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error)
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16)
}

class SimplePing: NSObject {
    weak var delegate: SimplePingDelegate?
    private let hostName: String
    private var host: CFHost?
    private var socket: CFSocket?
    private(set) var sendDate: Date?
    
    init(hostName: String) {
        self.hostName = hostName
        super.init()
    }
    
    func start() {
        var context = CFHostClientContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        let host: CFHost = CFHostCreateWithName(kCFAllocatorDefault, hostName as CFString).takeRetainedValue()
        CFHostSetClient(host, { (host, typeInfo, streamError, info) in
            guard let info = info else { return }
            let pinger = Unmanaged<SimplePing>.fromOpaque(info).takeUnretainedValue()
            
            if streamError?.pointee.error != 0 {
                let error = NSError(domain: kCFErrorDomainCFNetwork as String,
                                  code: Int(streamError?.pointee.error ?? 0),
                                  userInfo: nil)
                pinger.delegate?.simplePing(pinger, didFailWithError: error)
            } else {
                var resolved: DarwinBoolean = false
                guard let addresses = CFHostGetAddressing(host, &resolved)?.takeUnretainedValue() as NSArray? else {
                    let error = NSError(domain: kCFErrorDomainCFNetwork as String,
                                      code: CFHostErrorCode.unknown,
                                      userInfo: [NSLocalizedDescriptionKey: "无法解析主机地址"])
                    pinger.delegate?.simplePing(pinger, didFailWithError: error)
                    return
                }
                
                if let address = addresses.firstObject as? Data {
                    pinger.delegate?.simplePing(pinger, didStartWithAddress: address)
                } else {
                    let error = NSError(domain: kCFErrorDomainCFNetwork as String,
                                      code: CFHostErrorCode.hostNotFound,
                                      userInfo: [NSLocalizedDescriptionKey: "未找到主机地址"])
                    pinger.delegate?.simplePing(pinger, didFailWithError: error)
                }
            }
        }, &context)
        
        CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        
        let streamError = UnsafeMutablePointer<CFStreamError>.allocate(capacity: 1)
        defer { streamError.deallocate() }
        
        if !CFHostStartInfoResolution(host, .addresses, streamError) {
            let error = NSError(domain: kCFErrorDomainCFNetwork as String,
                              code: Int(streamError.pointee.error),
                              userInfo: [NSLocalizedDescriptionKey: "无法启动主机解析"])
            delegate?.simplePing(self, didFailWithError: error)
            return
        }
        
        self.host = host
    }
    
    func stop() {
        if let host = self.host {
            CFHostUnscheduleFromRunLoop(host, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            CFHostSetClient(host, nil, nil)
            self.host = nil
        }
        
        if let socket = self.socket {
            CFSocketInvalidate(socket)
            self.socket = nil
        }
    }
    
    func send(with data: Data?) {
        sendDate = Date()
        
        // 模拟ping响应
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.1...0.5)) { [weak self] in
            guard let self = self else { return }
            
            // 创建一个模拟的响应包
            let responseData = Data([0x00, 0x01, 0x02, 0x03])
            self.delegate?.simplePing(self, didSendPacket: responseData, sequenceNumber: 1)
            
            // 模拟接收响应
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.delegate?.simplePing(self, didReceivePingResponsePacket: responseData, sequenceNumber: 1)
            }
        }
    }
} 