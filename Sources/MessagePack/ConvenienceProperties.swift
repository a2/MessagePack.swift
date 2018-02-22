import Foundation

extension MessagePackValue {
    /// The number of elements in the `.Array` or `.Map`, `nil` otherwise.
    public var count: Int? {
        switch self {
        case .array(let array):
            return array.count
        case .map(let dict):
            return dict.count
        default:
            return nil
        }
    }

    /// The element at subscript `i` in the `.Array`, `nil` otherwise.
    public subscript (i: Int) -> MessagePackValue? {
        switch self {
        case .array(let array):
            return i < array.count ? array[i] : Optional.none
        default:
            return nil
        }
    }

    /// The element at keyed subscript `key`, `nil` otherwise.
    public subscript (key: MessagePackValue) -> MessagePackValue? {
        switch self {
        case .map(let dict):
            return dict[key]
        default:
            return nil
        }
    }

    /// True if `.Nil`, false otherwise.
    public var isNil: Bool {
        switch self {
        case .nil:
            return true
        default:
            return false
        }
    }

    // MARK: Signed integer values

    /// The integer value if `.int` or an appropriately valued `.uint`, `nil` otherwise.
    @available(*, deprecated, message: "use int64Value: instead")
    public var integerValue: Int64? {
        switch self {
        case .int(let value):
            return value
        case .uint(let value) where value <= UInt64(Int64.max):
            return Int64(value)
        default:
            return nil
        }
    }

    /// The signed platform-dependent width integer value if `.int` or an
    /// appropriately valued `.uint`, `nil` otherwise.
    public var intValue: Int? {
        switch self {
        case .int(let value):
            return Int(exactly: value)
        case .uint(let value):
            return Int(exactly: value)
        default:
            return nil
        }
    }

    /// The signed 8-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public var int8Value: Int8? {
        switch self {
        case .int(let value):
            return Int8(exactly: value)
        case .uint(let value):
            return Int8(exactly: value)
        default:
            return nil
        }
    }

    /// The signed 16-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public var int16Value: Int16? {
        switch self {
        case .int(let value):
            return Int16(exactly: value)
        case .uint(let value):
            return Int16(exactly: value)
        default:
            return nil
        }
    }

    /// The signed 32-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public var int32Value: Int32? {
        switch self {
        case .int(let value):
            return Int32(exactly: value)
        case .uint(let value):
            return Int32(exactly: value)
        default:
            return nil
        }
    }

    /// The signed 64-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public var int64Value: Int64? {
        switch self {
        case .int(let value):
            return value
        case .uint(let value):
            return Int64(exactly: value)
        default:
            return nil
        }
    }

    // MARK: Unsigned integer values

    /// The unsigned integer value if `.uint` or positive `.int`, `nil` otherwise.
    @available(*, deprecated, message: "use uint64Value: instead")
    public var unsignedIntegerValue: UInt64? {
        switch self {
        case .int(let value) where value >= 0:
            return UInt64(value)
        case .uint(let value):
            return value
        default:
            return nil
        }
    }

    /// The unsigned platform-dependent width integer value if `.uint` or an
    /// appropriately valued `.int`, `nil` otherwise.
    public var uintValue: UInt? {
        switch self {
        case .int(let value):
            return UInt(exactly: value)
        case .uint(let value):
            return UInt(exactly: value)
        default:
            return nil
        }
    }

    /// The unsigned 8-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public var uint8Value: UInt8? {
        switch self {
        case .int(let value):
            return UInt8(exactly: value)
        case .uint(let value):
            return UInt8(exactly: value)
        default:
            return nil
        }
    }

    /// The unsigned 16-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public var uint16Value: UInt16? {
        switch self {
        case .int(let value):
            return UInt16(exactly: value)
        case .uint(let value):
            return UInt16(exactly: value)
        default:
            return nil
        }
    }

    /// The unsigned 32-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public var uint32Value: UInt32? {
        switch self {
        case .int(let value):
            return UInt32(exactly: value)
        case .uint(let value):
            return UInt32(exactly: value)
        default:
            return nil
        }
    }

    /// The unsigned 64-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public var uint64Value: UInt64? {
        switch self {
        case .int(let value):
            return UInt64(exactly: value)
        case .uint(let value):
            return value
        default:
            return nil
        }
    }

    /// The contained array if `.Array`, `nil` otherwise.
    public var arrayValue: [MessagePackValue]? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }

    /// The contained boolean value if `.Bool`, `nil` otherwise.
    public var boolValue: Bool? {
        switch self {
        case .bool(let value):
            return value
        default:
            return nil
        }
    }

    /// The contained floating point value if `.Float` or `.Double`, `nil` otherwise.
    public var floatValue: Float? {
        switch self {
        case .float(let value):
            return value
        case .double(let value):
          return Float(exactly: value)
        default:
            return nil
        }
    }

    /// The contained double-precision floating point value if `.Float` or `.Double`, `nil` otherwise.
    public var doubleValue: Double? {
        switch self {
        case .float(let value):
            return Double(exactly: value)
        case .double(let value):
            return value
        default:
            return nil
        }
    }

    /// The contained string if `.String`, `nil` otherwise.
    public var stringValue: String? {
        switch self {
        case .binary(let data):
            return String(data: data, encoding: .utf8)
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    /// The contained data if `.Binary` or `.Extended`, `nil` otherwise.
    public var dataValue: Data? {
        switch self {
        case .binary(let bytes):
            return bytes
        case .extended(_, let data):
            return data
        default:
            return nil
        }
    }

    /// The contained type and data if Extended, `nil` otherwise.
    public var extendedValue: (Int8, Data)? {
        if case .extended(let type, let data) = self {
            return (type, data)
        } else {
            return nil
        }
    }

    /// The contained type if `.Extended`, `nil` otherwise.
    public var extendedType: Int8? {
        if case .extended(let type, _) = self {
            return type
        } else {
            return nil
        }
    }

    /// The contained dictionary if `.Map`, `nil` otherwise.
    public var dictionaryValue: [MessagePackValue: MessagePackValue]? {
        if case .map(let dict) = self {
            return dict
        } else {
            return nil
        }
    }
}
