//
//  WKScriptHandlerParamsDecoder
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import Foundation

public struct WKScriptHandlerParamsDecoder : Decoder {
    
    let body:Any
    
    /// The path of coding keys taken to get to this point in encoding.
    public let codingPath:[CodingKey]
    
    init(_ value:Any, key:CodingKey? = nil, path:[CodingKey] = []) throws {
        var list:[CodingKey] = path
        if let last = key { list.append(last) }
        codingPath = list
        body = value
    }
    
    /// Any contextual information set by the user for encoding.
    public var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    /// Returns the data stored in this decoder as represented in a container appropriate for holding values with no keys.
    ///
    /// - returns: An unkeyed container view into this decoder.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch body {
        case let list as NSArray: return try UnkeyedContainer(list, path: codingPath)
        default:
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not array")
            throw DecodingError.typeMismatch(NSArray.self, context)
        }
        
    }
    
    /// Returns the data stored in this decoder as represented in a container appropriate for holding a single primitive value.
    ///
    /// - returns: A single value container view into this decoder.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a single value container.
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ValueContainer(body, path: codingPath)
    }
    
    /// Returns the data stored in this decoder as represented in a container keyed by the given key type.
    ///
    /// - parameter type: The key type to use for the container.
    /// - returns: A keyed decoding container view into this decoder.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        switch body {
        case let obj as NSDictionary:
            return KeyedDecodingContainer<Key>(KeyedContainer<Key>(obj, path: codingPath))
        default:
            return KeyedDecodingContainer<Key>(KeyedUnknowContainer<Key>(body, path: codingPath))
        }
    }
    
}
