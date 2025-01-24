import Foundation

// MARK: - PreBuffer

extension GCDAsyncSocket {
    
    /// A buffer that stores data before it is processed
    internal class PreBuffer {
        /// The actual data storage
        private var buffer: NSMutableData
        /// The offset where reading should begin
        private var readOffset: Int = 0
        
        /// Initialize an empty pre-buffer
        init() {
            buffer = NSMutableData()
        }
        
        /// Initialize with existing data
        init(data: Data) {
            buffer = NSMutableData(data: data)
        }
        
        /// Get number of available bytes to read
        var availableBytes: Int {
            return buffer.length - readOffset
        }
        
        /// Get pointer to the current read position
        func readBuffer() -> UnsafeRawPointer {
            return buffer.bytes.advanced(by: readOffset)
        }
        
        /// Mark bytes as read
        func didRead(_ length: Int) {
            readOffset += length
            
            // If we've read everything, reset the buffer
            if readOffset == buffer.length {
                buffer.length = 0
                readOffset = 0
            }
        }
        
        /// Append new data to the buffer
        func append(_ data: Data) {
            // If we've read everything, reset the buffer first
            if readOffset == buffer.length {
                buffer.length = 0
                readOffset = 0
            }
            
            buffer.append(data)
        }
        
        /// Reset the buffer
        func reset() {
            buffer.length = 0
            readOffset = 0
        }
        
        /// Get all unread data
        var unreadData: Data {
            if readOffset == buffer.length {
                return Data()
            } else {
                return buffer.subdata(with: NSRange(location: readOffset, length: buffer.length - readOffset))
            }
        }
        
        /// Get total length of the buffer
        var totalLength: Int {
            return buffer.length
        }
        
        /// Check if buffer is empty
        var isEmpty: Bool {
            return buffer.length == 0
        }
    }
} 