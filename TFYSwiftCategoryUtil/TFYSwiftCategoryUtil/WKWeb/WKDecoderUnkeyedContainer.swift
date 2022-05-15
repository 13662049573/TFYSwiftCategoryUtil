//
//  WKScriptHandlerParamsDecoder
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import Foundation

extension WKScriptHandlerParamsDecoder {
    
    struct UnkeyedContainer : UnkeyedDecodingContainer {
        
        let list:NSArray
        /// The path of coding keys taken to get to this point in encoding.
        public let codingPath:[CodingKey]
        
        init(_ value:NSArray, key:CodingKey? = nil, path:[CodingKey] = []) throws {
            var pathList:[CodingKey] = path
            if let last = key {
                pathList.append(last)
            }
            list = value
            codingPath = pathList
        }
        
        var index:Int = 0
        
        mutating func next() throws -> (CodingKey, Any) {
            if index >= list.count {
                throw DecodingError.dataCorruptedError(in: self, debugDescription: "index: \(index) out of range 0..<\(list.count)")
            }
            defer { index += 1 }
            return (IndexKey(intValue: index), list[index])
        }
        
        // MARK: - UnkeyedDecodingContainer
        
        /// The number of elements contained within this container.
        ///
        /// If the number of elements is unknown, the value is `nil`.
        public var count: Int? { return list.count }
        
        /// A Boolean value indicating whether there are no more elements left to be decoded in the container.
        public var isAtEnd: Bool { return index >= list.count }
        
        /// The current decoding index of the container (i.e. the index of the next element to be decoded.)
        /// Incremented after every successful decode call.
        public var currentIndex: Int { return index }
        
        mutating func decode<Number>(_ type: Number.Type) throws -> NSNumber {
            let (key, body) = try next()
            let container = ValueContainer(body, path: codingPath + [key])
            return try container.decode(type)
        }
        
        /// Decodes a null value.
        ///
        /// If the value is not null, does not increment currentIndex.
        ///
        /// - returns: Whether the encountered value was null.
        /// - throws: `DecodingError.valueNotFound` if there are no more values to decode.
        public mutating func decodeNil() throws -> Bool {
            let (_, body) = try next()
            switch body {
            case _ as NSNull:   return true
            default:            break
            }
            index -= 1
            return false
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Bool.Type) throws -> Bool {
            let (key, body) = try next()
            
            let container = ValueContainer(body, path: codingPath + [key])
            return try container.decode(type)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int.Type) throws -> Int {
            return try decode(type).intValue
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int8.Type) throws -> Int8 {
            return try decode(type).int8Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int16.Type) throws -> Int16 {
            return try decode(type).int16Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int32.Type) throws -> Int32 {
            return try decode(type).int32Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Int64.Type) throws -> Int64 {
            return try decode(type).int64Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt.Type) throws -> UInt {
            return try decode(type).uintValue
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try decode(type).uint8Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try decode(type).uint16Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try decode(type).uint32Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try decode(type).uint64Value
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Float.Type) throws -> Float {
            return try decode(type).floatValue
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: Double.Type) throws -> Double {
            return try decode(type).doubleValue
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode(_ type: String.Type) throws -> String {
            let (key, body) = try next()
            
            let container = ValueContainer(body, path: codingPath + [key])
            return try container.decode(type)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - parameter type: The type of value to decode.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let (key, body) = try next()
            let decoder = try WKScriptHandlerParamsDecoder(body, path: codingPath + [key])
            return try T(from: decoder)
        }
        
        /// Decodes a nested container keyed by the given type.
        ///
        /// - parameter type: The key type to use for the container.
        /// - returns: A keyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let (key, body) = try next()
            switch body {
            case let obj as NSDictionary:
                let container = KeyedContainer<NestedKey>(obj, key:key, path: codingPath)
                return KeyedDecodingContainer<NestedKey>(container)
            default: break
            }
            let context = DecodingError.Context(codingPath: codingPath + [key], debugDescription: "not dictionary")
            throw DecodingError.typeMismatch(type, context)
        }
        
        /// Decodes an unkeyed nested container.
        ///
        /// - returns: An unkeyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let (key, body) = try next()
            switch body {
            case let value as NSArray: return try UnkeyedContainer(value, path: codingPath + [key])
            default: break
            }
            let context = DecodingError.Context(codingPath: codingPath + [key], debugDescription: "not array")
            throw DecodingError.typeMismatch(NSArray.self, context)

        }
        
        /// Decodes a nested container and returns a `Decoder` instance for decoding `super` from that container.
        ///
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        public mutating func superDecoder() throws -> Decoder {
            let (key, body) = try next()
            return try WKScriptHandlerParamsDecoder(body, path: codingPath + [key])
        }
    }
}
