////
////  NetworkDebugger.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 网络请求调试器
//final class NetworkDebugger {
//    static let shared = NetworkDebugger()
//    
//    // MARK: - 属性
//    private let queue = DispatchQueue(label: "com.tfy.ssr.network-debugger", qos: .utility)
//    private var observers: [UUID: NetworkObserver] = [:]
//    private var requests: [String: NetworkRequest] = [:]
//    
//    // MARK: - 初始化
//    private init() {
//        setupURLProtocol()
//    }
//    
//    // MARK: - 公共方法
//    func startMonitoring() {
//        URLProtocol.registerClass(NetworkDebuggerURLProtocol.self)
//    }
//    
//    func stopMonitoring() {
//        URLProtocol.unregisterClass(NetworkDebuggerURLProtocol.self)
//    }
//    
//    @discardableResult
//    func addObserver(_ handler: @escaping (NetworkRequest) -> Void) -> UUID {
//        let id = UUID()
//        queue.async {
//            self.observers[id] = NetworkObserver(handler: handler)
//        }
//        return id
//    }
//    
//    func removeObserver(_ id: UUID) {
//        queue.async {
//            self.observers.removeValue(forKey: id)
//        }
//    }
//    
//    // MARK: - 请求处理
//    func startRequest(_ request: URLRequest) -> String {
//        let id = UUID().uuidString
//        let networkRequest = NetworkRequest(
//            id: id,
//            url: request.url?.absoluteString ?? "",
//            method: request.httpMethod ?? "UNKNOWN",
//            requestHeaders: request.allHTTPHeaderFields ?? [:],
//            requestBody: request.httpBody,
//            startTime: Date()
//        )
//        
//        queue.async {
//            self.requests[id] = networkRequest
//        }
//        
//        return id
//    }
//    
//    func completeRequest(_ id: String, response: URLResponse?, data: Data?, error: Error?) {
//        queue.async {
//            guard var request = self.requests[id] else { return }
//            
//            request.endTime = Date()
//            request.duration = request.endTime.timeIntervalSince(request.startTime)
//            
//            if let httpResponse = response as? HTTPURLResponse {
//                request.statusCode = httpResponse.statusCode
//                request.responseHeaders = httpResponse.allHeaderFields as? [String: String] ?? [:]
//            }
//            
//            request.responseBody = data
//            request.error = error
//            
//            self.requests[id] = request
//            self.notifyObservers(request)
//        }
//    }
//    
//    // MARK: - 私有方法
//    private func setupURLProtocol() {
//        // 配置URLSession以支持自定义URLProtocol
//        let config = URLSessionConfiguration.default
//        config.protocolClasses = [NetworkDebuggerURLProtocol.self]
//        URLSession.shared.configuration.protocolClasses = [NetworkDebuggerURLProtocol.self]
//    }
//    
//    private func notifyObservers(_ request: NetworkRequest) {
//        observers.values.forEach { observer in
//            DispatchQueue.main.async {
//                observer.handler(request)
//            }
//        }
//    }
//}
//
//// MARK: - 网络请求URL协议
//final class NetworkDebuggerURLProtocol: URLProtocol {
//    
//    private var dataTask: URLSessionDataTask?
//    private var requestId: String?
//    
//    // MARK: - URLProtocol方法
//    override class func canInit(with request: URLRequest) -> Bool {
//        guard let scheme = request.url?.scheme else { return false }
//        return ["http", "https"].contains(scheme)
//    }
//    
//    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//        return request
//    }
//    
//    override func startLoading() {
//        requestId = NetworkDebugger.shared.startRequest(request)
//        
//        let config = URLSessionConfiguration.default
//        config.protocolClasses = nil // 避免递归
//        
//        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
//        dataTask = session.dataTask(with: request)
//        dataTask?.resume()
//    }
//    
//    override func stopLoading() {
//        dataTask?.cancel()
//    }
//}
//
//// MARK: - URLSession代理
//extension NetworkDebuggerURLProtocol: URLSessionDataDelegate {
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
//                   completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
//        completionHandler(.allow)
//    }
//    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        client?.urlProtocol(self, didLoad: data)
//    }
//    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        if let requestId = requestId {
//            NetworkDebugger.shared.completeRequest(requestId, response: task.response, data: nil, error: error)
//        }
//        
//        if let error = error {
//            client?.urlProtocol(self, didFailWithError: error)
//        } else {
//            client?.urlProtocolDidFinishLoading(self)
//        }
//    }
//}
//
//// MARK: - 网络请求模型
//struct NetworkRequest {
//    let id: String
//    let url: String
//    let method: String
//    let requestHeaders: [String: String]
//    let requestBody: Data?
//    let startTime: Date
//    var endTime: Date = Date()
//    var duration: TimeInterval = 0
//    var statusCode: Int?
//    var responseHeaders: [String: String] = [:]
//    var responseBody: Data?
//    var error: Error?
//    
//    var isSuccess: Bool {
//        guard let statusCode = statusCode else { return false }
//        return (200...299).contains(statusCode)
//    }
//    
//    var formattedDuration: String {
//        if duration < 1 {
//            return String(format: "%.0fms", duration * 1000)
//        } else {
//            return String(format: "%.2fs", duration)
//        }
//    }
//    
//    var formattedRequestBody: String? {
//        guard let data = requestBody else { return nil }
//        return formatData(data)
//    }
//    
//    var formattedResponseBody: String? {
//        guard let data = responseBody else { return nil }
//        return formatData(data)
//    }
//    
//    private func formatData(_ data: Data) -> String {
//        if let json = try? JSONSerialization.jsonObject(with: data),
//           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
//           let string = String(data: prettyData, encoding: .utf8) {
//            return string
//        }
//        return String(data: data, encoding: .utf8) ?? "Unable to decode data"
//    }
//}
//
//// MARK: - 网络统计模型
//struct NetworkStats {
//    let totalRequests: Int
//    let successRequests: Int
//    let errorRequests: Int
//    let averageTime: TimeInterval
//    
//    init(requests: [NetworkRequest]) {
//        totalRequests = requests.count
//        successRequests = requests.filter { $0.isSuccess }.count
//        errorRequests = totalRequests - successRequests
//        averageTime = requests.map { $0.duration }.reduce(0, +) / Double(max(totalRequests, 1))
//    }
//}
//
//// MARK: - 网络观察者
//struct NetworkObserver {
//    let handler: (NetworkRequest) -> Void
//}
