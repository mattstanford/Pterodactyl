//
//  JSONObject.swift
//  PterodactylLib & PterodactylServer
//
//  Copyright © 2024 Matt Stanford. All rights reserved.
//

import Foundation

enum JSONDecodingError: Error {
    case notAnObject
}

struct JSONObject: Codable {
    var value: [String: Any]

    public init(_ value: [String: Any]) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: JSONCodingKeys.self) else {
            throw JSONDecodingError.notAnObject
        }
        self.value = Self.decode(fromObject: container)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: JSONCodingKeys.self)
        try Self.encode(value, into: &container)
    }

    static func encode(_ dictionary: [String: Any], into container: inout KeyedEncodingContainer<JSONCodingKeys>) throws {
        for key in dictionary.keys {
            let value = dictionary[key]
            let encodingKey = JSONCodingKeys(stringValue: key)

            if let value = value as? String {
                try container.encode(value, forKey: encodingKey)
            } else if let value = value as? Int {
                try container.encode(value, forKey: encodingKey)
            } else if let value = value as? Double {
                try container.encode(value, forKey: encodingKey)
            } else if let value = value as? Bool {
                try container.encode(value, forKey: encodingKey)
            } else if let value = value as? [String: Any] {
                var keyedContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: encodingKey)
                try encode(value, into: &keyedContainer)
            } else if let value = value as? [Any] {
                var unkeyedContainer = container.nestedUnkeyedContainer(forKey: encodingKey)
                try encode(value, into: &unkeyedContainer)
            } else if let value = value as? Encodable {
                try container.encode(value, forKey: JSONCodingKeys(stringValue: key))
            } else if value != nil {
                throw EncodingError.invalidValue(value as Any, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unencodable value"))
            }
        }
    }

    static func encode(_ array: [Any], into container: inout UnkeyedEncodingContainer) throws {
        for value in array {
            if let value = value as? String {
                try container.encode(value)
            } else if let value = value as? Int {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? [String: Any] {
                var keyedContainer: KeyedEncodingContainer<JSONCodingKeys> = container.nestedContainer(keyedBy: JSONCodingKeys.self)
                try encode(value, into: &keyedContainer)
            } else if let value = value as? [Any] {
                var unkeyedContainer = container.nestedUnkeyedContainer()
                try encode(value, into: &unkeyedContainer)
            } else if let value = value as? Encodable {
                try container.encode(value)
            } else if value as Any? == nil {
                try container.encodeNil()
            } else {
                throw EncodingError.invalidValue(value as Any, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unencodable value"))
            }
        }
    }

    static func decode(fromObject container: KeyedDecodingContainer<JSONCodingKeys>) -> [String: Any] {
        var result: [String: Any] = [:]

        for key in container.allKeys {
            if let val = try? container.decode(Int.self, forKey: key) { result[key.stringValue] = val }
            else if let val = try? container.decode(Double.self, forKey: key) { result[key.stringValue] = val }
            else if let val = try? container.decode(String.self, forKey: key) { result[key.stringValue] = val }
            else if let val = try? container.decode(Bool.self, forKey: key) { result[key.stringValue] = val }
            else if let nestedContainer = try? container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key) {
                result[key.stringValue] = decode(fromObject: nestedContainer)
            } else if var nestedArray = try? container.nestedUnkeyedContainer(forKey: key) {
                result[key.stringValue] = decode(fromArray: &nestedArray)
            } else if (try? container.decodeNil(forKey: key)) == true  {
                result.updateValue(Optional<Any>(nil) as Any, forKey: key.stringValue)
            }
        }

        return result
    }

    static func decode(fromArray container: inout UnkeyedDecodingContainer) -> [Any] {
        var result: [Any] = []

        while !container.isAtEnd {
            if let value = try? container.decode(String.self) { result.append(value) }
            else if let value = try? container.decode(Int.self) { result.append(value) }
            else if let value = try? container.decode(Double.self) { result.append(value) }
            else if let value = try? container.decode(Bool.self) { result.append(value) }
            else if let nestedContainer = try? container.nestedContainer(keyedBy: JSONCodingKeys.self) {
                result.append(decode(fromObject: nestedContainer))
            }
            else if var nestedArray = try? container.nestedUnkeyedContainer() {
                result.append(decode(fromArray: &nestedArray))
            } else if (try? container.decodeNil()) == true {
                result.append(Optional<Any>(nil) as Any)
            }
        }

        return result
    }
}
