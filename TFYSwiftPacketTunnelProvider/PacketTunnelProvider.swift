//
//  PacketTunnelProvider.swift
//  TFYSwiftPacketTunnelProvider
//
//  Created by apple on 2024/11/27.
//

import NetworkExtension
import Foundation

class PacketTunnelProvider: NEPacketTunnelProvider {
    

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        
    }
    

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
       
    }
}

