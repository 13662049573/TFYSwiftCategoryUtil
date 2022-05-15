//
//  WKScriptHandlerParamsDecoder
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import Foundation

extension CodingKey {
    
    public static func ==(lhs:Self, rhs:Self) -> Bool {
        return lhs.stringValue == rhs.stringValue && lhs.intValue == rhs.intValue
    }
}


extension WKScriptHandlerParamsDecoder {
    
    struct KeyedUnknowContainer <K> : KeyedDecodingContainerProtocol where K : CodingKey {
        typealias Key = K
        
        let body:Any
        /// The path of coding keys taken to get to this point in decoding.
        let codingPath:[CodingKey]
        
        init(_ value:Any, key:CodingKey? = nil, path:[CodingKey] = []) {
            var pathList:[CodingKey] = path
            if let last = key { pathList.append(last) }
            codingPath = pathList
            body = value
        }
        
        /// All the keys the `Decoder` has for this container.
        ///
        /// Different keyed containers from the same `Decoder` may return different keys here; it is possible to encode with multiple key types which are not convertible to one another. This should report all keys present which are convertible to the requested type.
        var allKeys: [K] { return [] }
        
        
        /// Returns a Boolean value indicating whether the decoder contains a value associated with the given key.
        ///
        /// The value associated with `key` may be a null value as appropriate for the data format.
        ///
        /// - parameter key: The key to search for.
        /// - returns: Whether the `Decoder` has an entry for the given key.
        func contains(_ key: K) -> Bool { return true }
        
        /// Decodes a null value for the given key.
        ///
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: Whether the encountered value was null.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        func decodeNil(forKey key: K) throws -> Bool { return true }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
            let container = ValueContainer(body, key: key, path: codingPath)
            return try container.decode(type)
        }
        
        func decode<Number>(_ type: Number.Type, forKey key: K) throws -> NSNumber {
            let container = ValueContainer(body, key: key, path: codingPath)
            return try container.decode(type)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int.Type, forKey key: K) throws -> Int {
            return try decode(NSNumber.self, forKey: key).intValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
            return try decode(NSNumber.self, forKey: key).int8Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
            return try decode(NSNumber.self, forKey: key).int16Value
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
            return try decode(NSNumber.self, forKey: key).int32Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
            return try decode(NSNumber.self, forKey: key).int64Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
            return try decode(NSNumber.self, forKey: key).uintValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
            return try decode(NSNumber.self, forKey: key).uint8Value
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
            return try decode(NSNumber.self, forKey: key).uint16Value
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
            return try decode(NSNumber.self, forKey: key).uint32Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
            return try decode(NSNumber.self, forKey: key).uint64Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Float.Type, forKey key: K) throws -> Float {
            return try decode(NSNumber.self, forKey: key).floatValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Double.Type, forKey key: K) throws -> Double {
            return try decode(NSNumber.self, forKey: key).doubleValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: String.Type, forKey key: K) throws -> String {
            let container = ValueContainer(body, key: key, path: codingPath)
            return try container.decode(type)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
            let decoder = try WKScriptHandlerParamsDecoder(body, key: key, path: codingPath)
            return try T(from: decoder)
        }
        
        /// Returns the data stored for the given key as represented in a container keyed by the given key type.
        ///
        /// - parameter type: The key type to use for the container.
        /// - parameter key: The key that the nested container is associated with.
        /// - returns: A keyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = KeyedUnknowContainer<NestedKey>(body, key:key, path: codingPath)
            return KeyedDecodingContainer<NestedKey>(container)
        }
        
        /// Returns the data stored for the given key as represented in an unkeyed container.
        ///
        /// - parameter key: The key that the nested container is associated with.
        /// - returns: An unkeyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
            switch body {
            case let list as NSArray:
                return try UnkeyedContainer(list, key: key, path: codingPath)
            default: break
            }
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "nil not contains \(key.stringValue)")
            throw DecodingError.typeMismatch(NSArray.self, context)
        }
        
        /// Returns a `Decoder` instance for decoding `super` from the container associated with the default `super` key.
        ///
        /// Equivalent to calling `superDecoder(forKey:)` with `Key(stringValue: "super", intValue: 0)`.
        ///
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the default `super` key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the default `super` key.
        func superDecoder(forKey key: K) throws -> Decoder {
            return try WKScriptHandlerParamsDecoder(body, key: key, path: codingPath)
        }
        
        /// Returns a `Decoder` instance for decoding `super` from the container associated with the given key.
        ///
        /// - parameter key: The key to decode `super` for.
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func superDecoder() throws -> Decoder {
            return try WKScriptHandlerParamsDecoder(body, path: codingPath)
        }
    }
    
    struct KeyedContainer<K> : KeyedDecodingContainerProtocol where K : CodingKey {
        
        
        typealias Key = K
        
        let obj:NSDictionary
        /// The path of coding keys taken to get to this point in decoding.
        public let codingPath:[CodingKey]
        
        init(_ value:NSDictionary, key:CodingKey? = nil, path:[CodingKey] = []) {
            var pathList:[CodingKey] = path
            if let last = key {
                pathList.append(last)
            }
            codingPath = pathList
            obj = value
        }
        
        func getValue(forKey key: Key) throws -> Any {
            guard let value = obj[key.stringValue] else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "not contains \(key.stringValue)")
                throw DecodingError.keyNotFound(key, context)
            }
            return value

        }
        
        /// All the keys the `Decoder` has for this container.
        ///
        /// Different keyed containers from the same `Decoder` may return different keys here; it is possible to encode with multiple key types which are not convertible to one another. This should report all keys present which are convertible to the requested type.
        var allKeys: [K] {
            return obj.allKeys.compactMap { K(stringValue: String(describing: $0)) }
        }
        
        
        /// Returns a Boolean value indicating whether the decoder contains a value associated with the given key.
        ///
        /// The value associated with `key` may be a null value as appropriate for the data format.
        ///
        /// - parameter key: The key to search for.
        /// - returns: Whether the `Decoder` has an entry for the given key.
        func contains(_ key: K) -> Bool {
            return obj.allKeys.contains(where: { String(describing: $0) == key.stringValue })
        }
        
        /// Decodes a null value for the given key.
        ///
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: Whether the encountered value was null.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        func decodeNil(forKey key: K) throws -> Bool {
            if obj.allKeys.contains(where: { String(describing: $0) == key.stringValue }) {
                let body = obj[key.stringValue]
                switch body {
                case _ as NSNull: return true
                default: return false
                }
            }
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "nil not contains \(key.stringValue)")
            throw DecodingError.keyNotFound(key, context)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
            let body = try getValue(forKey: key)
            let container = ValueContainer(body, key: key, path: codingPath)
            return try container.decode(type)
        }
        
        func decode<Number>(_ type: Number.Type, forKey key: K) throws -> NSNumber {
            let body = try getValue(forKey: key)
            let container = ValueContainer(body, key: key, path: codingPath)
            return try container.decode(type)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int.Type, forKey key: K) throws -> Int {
            return try decode(NSNumber.self, forKey: key).intValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
            return try decode(NSNumber.self, forKey: key).int8Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
            return try decode(NSNumber.self, forKey: key).int16Value
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
            return try decode(NSNumber.self, forKey: key).int32Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
            return try decode(NSNumber.self, forKey: key).int64Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
            return try decode(NSNumber.self, forKey: key).uintValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
            return try decode(NSNumber.self, forKey: key).uint8Value
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
            return try decode(NSNumber.self, forKey: key).uint16Value
        }
        
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
            return try decode(NSNumber.self, forKey: key).uint32Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
            return try decode(NSNumber.self, forKey: key).uint64Value
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Float.Type, forKey key: K) throws -> Float {
            return try decode(NSNumber.self, forKey: key).floatValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Double.Type, forKey key: K) throws -> Double {
            return try decode(NSNumber.self, forKey: key).doubleValue
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: String.Type, forKey key: K) throws -> String {
            let body = try getValue(forKey: key)
            let container = ValueContainer(body, key: key, path: codingPath)
            return try container.decode(type)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - parameter type: The type of value to decode.
        /// - parameter key: The key that the decoded value is associated with.
        /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
            let body = try getValue(forKey: key)
            let decoder = try WKScriptHandlerParamsDecoder(body, key: key, path: codingPath)
            return try T(from: decoder)
        }
        
        /// Returns the data stored for the given key as represented in a container keyed by the given key type.
        ///
        /// - parameter type: The key type to use for the container.
        /// - parameter key: The key that the nested container is associated with.
        /// - returns: A keyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let body = try getValue(forKey: key)
            switch body {
            case let obj as NSDictionary:
                let container = KeyedContainer<NestedKey>(obj, key:key, path: codingPath)
                return KeyedDecodingContainer<NestedKey>(container)
            default:
                let container = KeyedUnknowContainer<NestedKey>(body, key:key, path: codingPath)
                return KeyedDecodingContainer<NestedKey>(container)
            }
        }
        
        /// Returns the data stored for the given key as represented in an unkeyed container.
        ///
        /// - parameter key: The key that the nested container is associated with.
        /// - returns: An unkeyed decoding container view into `self`.
        /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
            let body = try getValue(forKey: key)
            switch body {
            case let list as NSArray:
                return try UnkeyedContainer(list, key: key, path: codingPath)
            default: break
            }
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "nil not contains \(key.stringValue)")
            throw DecodingError.typeMismatch(NSArray.self, context)
        }
        
        /// Returns a `Decoder` instance for decoding `super` from the container associated with the default `super` key.
        ///
        /// Equivalent to calling `superDecoder(forKey:)` with `Key(stringValue: "super", intValue: 0)`.
        ///
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the default `super` key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the default `super` key.
        func superDecoder(forKey key: K) throws -> Decoder {
            let body = try getValue(forKey: key)
            return try WKScriptHandlerParamsDecoder(body, key: key, path: codingPath)
        }
        
        /// Returns a `Decoder` instance for decoding `super` from the container associated with the given key.
        ///
        /// - parameter key: The key to decode `super` for.
        /// - returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func superDecoder() throws -> Decoder {
            return try WKScriptHandlerParamsDecoder(obj, path: codingPath)
        }
        
    }
}

