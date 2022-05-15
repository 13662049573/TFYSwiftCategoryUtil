//
//  WKScriptHandlerParamsEncoder
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//
import Foundation

public class WKScriptHandlerParamsEncoder : Decoder {
    
    public enum ParamsType {
        case none
        case value
        case array
        case more
    }
    
    
    var type:ParamsType = .none
    var params:[String] = []
    var paramsCount:Int {
        switch type {
        case .none:     return 0
        case .array:    return 1
        case .value:    return 1
        case .more:     return params.count
        }
    }

    init(path:[CodingKey] = []) throws {
        codingPath = path
    }
    
    public func append(_ value:String) {
        if !codingPath.isEmpty { return }
        params.append(value)
    }
    
    
    /// The path of coding keys taken to get to this point in encoding.
    public let codingPath:[CodingKey]
    /// Any contextual information set by the user for encoding.
    public var userInfo: [CodingUserInfoKey : Any] { return [:] }

    /// Returns the data stored in this decoder as represented in a container appropriate for holding values with no keys.
    ///
    /// - returns: An unkeyed container view into this decoder.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        type = .array
        return UnkeyedContainer(self, path: codingPath)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        type = .value
        return ValueContainer(self, path: codingPath)
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer<Key>(KeyedContainer<Key>(self, path: codingPath))
    }
    
}


