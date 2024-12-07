import Foundation

// MARK: - Socket State Management

extension GCDAsyncSocket {
    
    /// Socket state index for managing connection state
    fileprivate struct SocketState {
        /// Current state index
        private var index: Int = 0
        
        /// Get current state index
        var current: Int {
            return index
        }
        
        /// Increment state index
        mutating func increment() {
            index += 1
        }
        
        /// Check if state index matches given value
        func matches(_ other: Int) -> Bool {
            return index == other
        }
    }
    
    /// Socket state manager
    fileprivate var state: SocketState {
        get {
            if let existingState = objc_getAssociatedObject(self, &AssociatedKeys.state) as? SocketState {
                return existingState
            }
            let newState = SocketState()
            objc_setAssociatedObject(self, &AssociatedKeys.state, newState, .OBJC_ASSOCIATION_RETAIN)
            return newState
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.state, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Get current state index
    internal var currentStateIndex: Int {
        return state.current
    }
    
    /// Increment state index
    internal func incrementStateIndex() {
        var currentState = state
        currentState.increment()
        state = currentState
    }
    
    /// Check if state index matches
    internal func stateMatches(_ index: Int) -> Bool {
        return state.matches(index)
    }
}

// MARK: - Associated Keys

private struct AssociatedKeys {
    static var state = "GCDAsyncSocket.State"
} 