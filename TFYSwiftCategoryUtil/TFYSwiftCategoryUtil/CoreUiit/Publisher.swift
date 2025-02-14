import Combine
import Foundation
import UIKit

// MARK: - Public

public extension Publisher where Failure == Never {

    /// Receive Output value on main thread  (DispatchQueue.main)
    func receiveOnMain() -> Publishers.ReceiveOn<Self, DispatchQueue> {
        self.receive(on: DispatchQueue.main)
    }

    /// A single value sink function outputs a `Result`
    /// - Parameter result: Result<Output, Failure>
    /// - Returns: AnyCancellable
    func sink(result: @escaping ((Result<Self.Output, Self.Failure>) -> Void)) -> AnyCancellable {
        return sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                result(.failure(error))
            case .finished: break
            }
        }, receiveValue: { output in
            result(.success(output))
        })
    }

    /// Assign property to object without using [weak self]
    /// - Parameters:
    ///   - keyPath: Property keypath
    ///   - root: Any object
    /// - Returns: AnyCancellable
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
        sink { [weak root] in
            root?[keyPath: keyPath] = $0
        }
    }
 
}

public protocol TimerStartable {
    func start(totalTime: TimeInterval?) -> AnyPublisher<Date, Never>
    func stop()
}


extension Publishers.Autoconnect: TimerStartable where Upstream: Timer.TimerPublisher {
    
    /// Stops timer of current timer publisher instance
    public func stop() {
        upstream.connect().cancel()
    }
    
    /// Stops timer of current timer publisher instance after totalTime
    /// If totalTime is nil, then continues until hard stopped
    public func start(totalTime: TimeInterval? = nil) -> AnyPublisher<Date, Never> {
        var timeElapsed: TimeInterval = 0
        return flatMap { date in
            return Future<Date, Never> { promise in
                if let totalTime = totalTime, timeElapsed >= totalTime { self.stop() }
                promise(.success(date))
                timeElapsed += 1
            }
        }.eraseToAnyPublisher()
    }
}
