//
//  WKScriptHandlerParamsDecoder
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import Foundation

extension WKScriptHandlerParamsDecoder {
    struct ValueContainer : SingleValueDecodingContainer {
        
        let body:Any
        /// The path of coding keys taken to get to this point in encoding.
        public let codingPath:[CodingKey]
        
        init(_ value:Any, key:CodingKey? = nil, path:[CodingKey] = []) {
            var list:[CodingKey] = path
            if let last = key {
                list.append(last)
            }
            codingPath = list
            body = value
        }
        // MARK: - SingleValueDecodingContainer
        
        /// Decodes a null value.
        ///
        /// - returns: Whether the encountered value was null.
        public func decodeNil() -> Bool {
            switch body {
            case _ as NSNull:   return true
            default:            return false
            }
        }
        
        
        func decode<Number>(_ type: Number.Type) throws -> NSNumber {
            switch body {
            case let value as Bool:     return value ? 1 : 0
            case let value as NSNumber: return value
            case let value as Date:     return NSNumber(value: value.timeIntervalSince1970)
            case let value as String:
                if let double = Double(value) {
                    return NSNumber(value: double)
                }
                break
            case _ as NSNull:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value is null")
                throw DecodingError.valueNotFound(type, context)
            default: break
            }
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not number")
            throw DecodingError.typeMismatch(type, context)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Bool.Type) throws -> Bool {
            switch body {
            case let value as Bool: return value
            case let value as NSNumber: return value.boolValue
            case let value as String where value == "true": return true
            case let value as String where value == "false": return false
            case _ as NSNull:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value is null")
                throw DecodingError.valueNotFound(type, context)
            default: break
            }
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not boolean")
            throw DecodingError.typeMismatch(type, context)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int.Type) throws -> Int {
            return try decode(NSNumber.self).intValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int8.Type) throws -> Int8 {
            return try decode(NSNumber.self).int8Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int16.Type) throws -> Int16 {
            return try decode(NSNumber.self).int16Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int32.Type) throws -> Int32 {
            return try decode(NSNumber.self).int32Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int64.Type) throws -> Int64 {
            return try decode(NSNumber.self).int64Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt.Type) throws -> UInt {
            return try decode(NSNumber.self).uintValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try decode(NSNumber.self).uint8Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try decode(NSNumber.self).uint16Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try decode(NSNumber.self).uint32Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try decode(NSNumber.self).uint64Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Float.Type) throws -> Float {
            return try decode(NSNumber.self).floatValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Double.Type) throws -> Double {
            return try decode(NSNumber.self).doubleValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: String.Type) throws -> String {
            switch body {
            case let value as String:   return value
            case let value as NSNumber: return value.stringValue
            case let value as Bool:     return value.description
            case let value as Date:
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return fmt.string(from: value)
            case _ as NSNull:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value is null")
                throw DecodingError.valueNotFound(type, context)
            default: break
            }
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not string")
            throw DecodingError.typeMismatch(type, context)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let decoder = try WKScriptHandlerParamsDecoder(body, path: codingPath)
            return try T(from: decoder)
        }
        
    }
}
