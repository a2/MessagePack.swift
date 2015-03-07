/**
    Splits an integer into `parts` bytes.

    :param: value The integer to split.
    :param: parts The number of bytes into which to split.

    :returns: An byte array representation of `value`.
*/
private func splitInt(value: UInt64, #parts: Int) -> [UInt8] {
    return map(stride(from: 8 * (parts - 1), through: 0, by: -8)) { (shift: Int) -> UInt8 in
        return UInt8(truncatingBitPattern: value >> UInt64(shift))
    }
}

/**
    Encodes a positive integer into MessagePack bytes.

    :param: value The integer to split.

    :returns: A MessagePack byte representation of `value`.
*/
private func packIntPos(value: UInt64) -> [UInt8] {
    switch value {
    case let value where value <= 0x7f:
        return [UInt8(truncatingBitPattern: value)]
    case let value where value <= 0xff:
        return [0xcc, UInt8(truncatingBitPattern: value)]
    case let value where value <= 0xffff:
        return [0xcd] + splitInt(value, parts: 2)
    case let value where value <= 0xffffffff:
        return [0xce] + splitInt(value, parts: 4)
    case let value where value <= 0xffffffffffffffff:
        return [0xcf] + splitInt(value, parts: 8)
    default:
        preconditionFailure()
    }
}

/**
    Encodes a negative integer into MessagePack bytes.

    :param: value The integer to split.

    :returns: A MessagePack byte representation of `value`.
*/
private func packIntNeg(value: Int64) -> [UInt8] {
    switch value {
    case let value where value >= -0x20:
        return [0xe0 + UInt8(truncatingBitPattern: value)]
    case let value where value >= -0x7f:
        return [0xd0, UInt8(bitPattern: Int8(value))]
    case let value where value >= -0x7fff:
        let truncated = UInt16(bitPattern: Int16(value))
        return [0xd1] + splitInt(UInt64(truncated), parts: 2)
    case let value where value >= -0x7fffffff:
        let truncated = UInt32(bitPattern: Int32(value))
        return [0xd2] + splitInt(UInt64(truncated), parts: 4)
    case let value where value >= -0x7fffffffffffffff:
        let truncated = UInt64(bitPattern: value)
        return [0xd3] + splitInt(truncated, parts: 8)
    default:
        preconditionFailure()
    }
}

/**
    The MessagePackValue enum encapsulates the following types:

    - Nil
    - Bool
    - Int
    - UInt
    - Float
    - Double
    - String
    - Binary
    - Array
    - Map
    - Extended
*/
public enum MessagePackValue: Equatable {
    case Nil
    case Bool(Swift.Bool)
    case Int(Int64)
    case UInt(UInt64)
    case Float(Float32)
    case Double(Float64)
    case String(Swift.String)
    case Binary([UInt8])
    case Array([MessagePackValue])
    case Map([MessagePackValue : MessagePackValue])
    case Extended(type: Int8, data: [UInt8])
}

extension MessagePackValue: Hashable {
    public var hashValue: Swift.Int {
        switch self {
        case .Nil: return 0
        case .Bool(let value): return value.hashValue
        case .Int(let value): return value.hashValue
        case .UInt(let value): return value.hashValue
        case .Float(let value): return value.hashValue
        case .Double(let value): return value.hashValue
        case .String(let string): return string.hashValue
        case .Binary(let bytes): return hashBytes(bytes)
        case .Array(let array): return array.count
        case .Map(let dict): return dict.count
        case .Extended(let type, let bytes): return type.hashValue ^ hashBytes(bytes)
        }
    }
}

/**
    Flattens a dictionary into an array of alternating keys and values.

    :param: dict The dictionary to flatten.
    
    :returns: An array of keys and values.
*/
private func flatten<T>(dict: [T : T]) -> [T] {
    return map(dict) { [$0.0, $0.1] }.reduce([], combine: +)
}

/**
    Unpacks a generator of bytes into a MessagePackValue.

    :param: generator The generator that yields bytes.

    :returns: A MessagePackValue, or `nil` if the generator runs out of bytes.
*/
public func unpack<G: GeneratorType where G.Element == UInt8>(inout generator: G) -> MessagePackValue? {
    if let value = generator.next() {
        switch value {

        // positive fixint
        case 0x00...0x7f:
            return .UInt(UInt64(value))

        // fixmap
        case 0x80...0x8f:
            let length = Int(value - 0x80)
            if let dict = joinMap(&generator, length) {
                return .Map(dict)
            }

        // fixarray
        case 0x90...0x9f:
            let length = Int(value - 0x90)
            if let array = joinArrayUnpack(&generator, length) {
                return .Array(array)
            }

        // fixstr
        case 0xa0...0xbf:
            let length = Int(value - 0xa0)
            if let string = joinString(&generator, length) {
                return .String(string)
            }

        // nil
        case 0xc0:
            return .Nil

        // (never used)
        case 0xc1:
            break

        // false
        case 0xc2:
            return .Bool(false)

        // true
        case 0xc3:
            return .Bool(true)

        // bin 8, 16, 32
        case 0xc4...0xc6:
            let size = 1 << Int(value - 0xc4)
            if let length = joinUInt64(&generator, size), bytes = joinArrayRaw(&generator, Int(length)) {
                return .Binary(bytes)
            }

        // ext 8, 16, 32
        case 0xc7...0xc9:
            let size = 1 << Int(value - 0xc7)
            if let length = joinUInt64(&generator, size), typeByte = generator.next() {
                let type = Int8(bitPattern: typeByte)
                if let bytes = joinArrayRaw(&generator, Int(length)) {
                    return .Extended(type: type, data: bytes)
                }
            }

        // float 32
        case 0xca:
            if let bytes = joinUInt64(&generator, 4) {
                let float = unsafeBitCast(UInt32(truncatingBitPattern: bytes), Float32.self)
                return .Float(float)
            }

        // float 64
        case 0xcb:
            if let bytes = joinUInt64(&generator, 8) {
                let double = unsafeBitCast(bytes, Float64.self)
                return .Double(double)
            }

        // uint 8, 16, 32, 64
        case 0xcc...0xcf:
            let length = 1 << (Int(value) - 0xcc)
            if let integer = joinUInt64(&generator, length) {
                return .UInt(integer)
            }

        // int 8
        case 0xd0:
            if let byte = generator.next() {
                let integer = Int8(bitPattern: byte)
                return .Int(Int64(integer))
            }

        // int 16
        case 0xd1:
            if let bytes = joinUInt64(&generator, 2) {
                let integer = Int16(bitPattern: UInt16(truncatingBitPattern: bytes))
                return .Int(Int64(integer))
            }

        // int 32
        case 0xd2:
            if let bytes = joinUInt64(&generator, 4) {
                let integer = Int32(bitPattern: UInt32(truncatingBitPattern: bytes))
                return .Int(Int64(integer))
            }

        // int 64
        case 0xd3:
            if let bytes = joinUInt64(&generator, 2) {
                let integer = Int64(bitPattern: bytes)
                return .Int(integer)
            }

        // fixent 1, 2, 4, 8, 16
        case 0xd4...0xd8:
            let length = 1 << Int(value - 0xd4)
            if let typeByte = generator.next() {
                let type = Int8(bitPattern: typeByte)
                if let bytes = joinArrayRaw(&generator, length) {
                    return .Extended(type: type, data: bytes)
                }
            }

        // str 8, 16, 32
        case 0xd9...0xdb:
            let lengthSize = 1 << Int(value - 0xd9)
            if let length = joinUInt64(&generator, lengthSize), string = joinString(&generator, Int(length)) {
                return .String(string)
            }

        // array 16, 32
        case 0xdc...0xdd:
            let lengthSize = 1 << Int(value - 0xdc)
            if let length = joinUInt64(&generator, lengthSize), array = joinArrayUnpack(&generator, Int(length)) {
                return .Array(array)
            }

        // map 16, 32
        case 0xde...0xdf:
            let lengthSize = 1 << Int(value - 0xdc)
            if let length = joinUInt64(&generator, lengthSize), dict = joinMap(&generator, Int(length)) {
                return .Map(dict)
            }

        // negative fixint
        case 0xe0...0xff:
            return .Int(Int64(value) - 0x100)

        default:
            break
        }
    }

    return nil
}

/**
    Unpacks a seequence of bytes into a MessagePackValue.

    :param: data The sequence of bytes.

    :returns: A MessagePackValue, or `nil` if the sequence runs out of bytes.
*/
public func unpack<S: SequenceType where S.Generator.Element == UInt8>(data: S) -> MessagePackValue? {
    var generator = data.generate()
    return unpack(&generator)
}

/**
    Packs a MessagePackValue into an array of bytes.

    :param: value The value to encode
    
    :returns: An array of bytes.
*/
public func pack(value: MessagePackValue) -> [UInt8] {
    switch value {
    case .Nil:
        return [0xc0]

    case .Bool(let value):
        return [value ? 0xc3 : 0xc2]

    case .Int(let value):
        return value >= 0 ? packIntPos(UInt64(value)) : packIntNeg(value)

    case .UInt(let value):
        return packIntPos(value)
        
    case .Float(let value):
        let integerValue = unsafeBitCast(value, UInt32.self)
        return [0xca] + splitInt(UInt64(integerValue), parts: 4)

    case .Double(let value):
        let integerValue = unsafeBitCast(value, UInt64.self)
        return [0xcb] + splitInt(integerValue, parts: 8)

    case .String(let string):
        let utf8 = string.utf8
        var prefix: [UInt8]
        switch UInt32(count(utf8)) {
        case let count where count <= 0x19:
            prefix = [0xa0 | UInt8(count)]
        case let count where count <= 0xff:
            prefix = [0xd9, UInt8(count)]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: Int16(count))
            prefix = [0xda] + splitInt(UInt64(truncated), parts: 2)
        case let count where count <= 0xffffffff:
            prefix = [0xdb] + splitInt(UInt64(count), parts: 4)
        default:
            preconditionFailure()
        }
        return prefix + utf8

    case .Binary(let bytes):
        var prefix: [UInt8]
        switch UInt32(bytes.count) {
        case let count where count <= 0xff:
            prefix = [0xc4, UInt8(count)]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: Int16(count))
            prefix = [0xc5] + splitInt(UInt64(truncated), parts: 2)
        case let count where count <= 0xffffffff:
            prefix = [0xc6] + splitInt(UInt64(count), parts: 4)
        default:
            preconditionFailure()
        }
        return prefix + bytes

    case .Array(let array):
        var prefix: [UInt8]
        switch UInt32(array.count) {
        case let count where count <= 0xe:
            prefix = [0x90 | UInt8(count)]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: Int16(count))
            prefix = [0xdc] + splitInt(UInt64(truncated), parts: 2)
        case let count where count <= 0xffffffff:
            prefix = [0xdd] + splitInt(UInt64(count), parts: 4)
        default:
            preconditionFailure()
        }
        return prefix + array.map(pack).reduce([], combine: +)

    case .Map(let dict):
        var prefix: [UInt8]
        switch UInt32(dict.count) {
        case let count where count <= 0xe:
            prefix = [0x80 | UInt8(count)]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: Int16(count))
            prefix = [0xde] + splitInt(UInt64(truncated), parts: 2)
        case let count where count <= 0xffffffff:
            prefix = [0xdf] + splitInt(UInt64(count), parts: 4)
        default:
            preconditionFailure()
        }
        return prefix + flatten(dict).map(pack).reduce([], combine: +)

    case .Extended(let type, let bytes):
        let unsignedType = UInt8(bitPattern: type)
        var prefix: [UInt8]
        switch UInt32(bytes.count) {
        case 1:
            prefix = [0xd4, unsignedType]
        case 2:
            prefix = [0xd5, unsignedType]
        case 4:
            prefix = [0xd6, unsignedType]
        case 8:
            prefix = [0xd7, unsignedType]
        case 16:
            prefix = [0xd8, unsignedType]
        case let count where count <= 0xff:
            prefix = [0xc7, UInt8(count), unsignedType]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: Int16(count))
            prefix = [0xc8] + splitInt(UInt64(truncated), parts: 2) + [unsignedType]
        case let count where count <= 0xffffffff:
            prefix = [0xc9] + splitInt(UInt64(count), parts: 4) + [unsignedType]
        default:
            preconditionFailure()
        }
        return prefix + bytes
    }
}

/**
    Tests the equality of two MessagePackValue values.
    
    :param: lhs The left-hand value.
    :param: rhs The right-hand value.

    :returns: True if the values are of the same type and have equal contents.
*/
public func ==(lhs: MessagePackValue, rhs: MessagePackValue) -> Bool {
    switch (lhs, rhs) {
    case (.Nil, .Nil):
        return true
    case let (.Bool(lhv), .Bool(rhv)) where lhv == rhv:
        return true
    case let (.Int(lhv), .Int(rhv)) where lhv == rhv:
        return true
    case let (.UInt(lhv), .UInt(rhv)) where lhv == rhv:
        return true
    case let (.Int(lhv), .UInt(rhv)) where lhv >= 0 && UInt64(lhv) == rhv:
        return true
    case let (.UInt(lhv), .Int(rhv)) where rhv >= 0 && lhv == UInt64(rhv):
        return true
    case let (.Float(lhv), .Float(rhv)) where lhv == rhv:
        return true
    case let (.Double(lhv), .Double(rhv)) where lhv == rhv:
        return true
    case let (.String(lhv), .String(rhv)) where lhv == rhv:
        return true
    case let (.Binary(lhv), .Binary(rhv)) where lhv == rhv:
        return true
    case let (.Array(lhv), .Array(rhv)) where lhv == rhv:
        return true
    case let (.Map(lhv), .Map(rhv)) where lhv == rhv:
        return true
    case let (.Extended(lht, lhb), .Extended(rht, rhb)) where lht == rht && lhb == rhb:
        return true
    default:
        return false
    }
}

extension MessagePackValue: ArrayLiteralConvertible {
    public init(arrayLiteral elements: MessagePackValue...) {
        self = .Array(elements)
    }
}

extension MessagePackValue: BooleanLiteralConvertible {
    public init(booleanLiteral value: Swift.Bool) {
        self = .Bool(value)
    }
}

extension MessagePackValue: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (MessagePackValue, MessagePackValue)...) {
        let dict = elements.reduce([MessagePackValue : MessagePackValue]()) { (var dict, tuple) in
            let (key, value) = tuple
            dict[key] = value
            return dict
        }
        self = .Map(dict)
    }
}

extension MessagePackValue: ExtendedGraphemeClusterLiteralConvertible {
    public init(extendedGraphemeClusterLiteral value: Swift.String) {
        self = .String(value)
    }
}

extension MessagePackValue: FloatLiteralConvertible {
    public init(floatLiteral value: Swift.Double) {
        self = .Double(value)
    }
}

extension MessagePackValue: IntegerLiteralConvertible {
    public init(integerLiteral value: Int64) {
        self = .Int(value)
    }
}

extension MessagePackValue: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .Nil
    }
}

extension MessagePackValue: StringLiteralConvertible {
    public init(stringLiteral value: Swift.String) {
        self = .String(value)
    }
}

extension MessagePackValue: UnicodeScalarLiteralConvertible {
    public init(unicodeScalarLiteral value: Swift.String) {
        self = .String(value)
    }
}

extension MessagePackValue {
    public init() {
        self = .Nil
    }

    public init<B: BooleanType>(_ value: B) {
        self = .Bool(value.boolValue)
    }

    public init<S: SignedIntegerType>(_ value: S) {
        self = .Int(Int64(value.toIntMax()))
    }

    public init<U: UnsignedIntegerType>(_ value: U) {
        self = .UInt(UInt64(value.toUIntMax()))
    }

    public init(_ value: Swift.Float) {
        self = .Float(value)
    }

    public init(_ value: Swift.Double) {
        self = .Double(value)
    }

    public init(_ value: Swift.String) {
        self = .String(value)
    }

    public init(_ value: [MessagePackValue]) {
        self = .Array(value)
    }

    public init(_ value: [MessagePackValue : MessagePackValue]) {
        self = .Map(value)
    }

    public init(_ value: [UInt8]) {
        self = .Binary(value)
    }
}

extension MessagePackValue {
    /// The number of elements in the `.Array` or `.Map`, `nil` otherwise.
    public var count: Swift.Int? {
        switch self {
        case .Array(let array):
            return array.count
        case .Map(let dict):
            return dict.count
        default:
            return nil
        }
    }

    /// The element at subscript `i` in the `.Array`, `nil` otherwise.
    public subscript (i: Swift.Int) -> MessagePackValue? {
        switch self {
        case .Array(let array) where i < array.count:
            return array[i]
        default:
            return nil
        }
    }

    /// The element at keyed subscript `key`, `nil` otherwise.
    public subscript (key: MessagePackValue) -> MessagePackValue? {
        switch self {
        case .Map(let dict):
            return dict[key]
        default:
            return nil
        }
    }

    /// True if `.Nil`, false otherwise.
    public var isNil: Swift.Bool {
        return self == .Nil
    }

    /// The integer value if `.Int` or an appropriately valued `.UInt`, `nil` otherwise.
    public var integerValue: Int64? {
        switch self {
        case .Int(let value):
            return value
        case .UInt(let value) where value < UInt64(Swift.Int64.max):
            return Int64(value)
        default:
            return nil
        }
    }

    /// The unsigned integer value if `.UInt` or positive `.Int`, `nil` otherwise.
    public var unsignedIntegerValue: UInt64? {
        switch self {
        case .Int(let value) where value > 0:
            return UInt64(value)
        case .UInt(let value):
            return value
        default:
            return nil
        }
    }

    /// The contained array if `.Array`, `nil` otherwise.
    public var arrayValue: [MessagePackValue]? {
        switch self {
        case .Array(let array):
            return array
        default:
            return nil
        }
    }

    /// The contained boolean value if `.Bool`, `nil` otherwise.
    public var boolValue: Swift.Bool? {
        switch self {
        case .Bool(let value):
            return value
        default:
            return nil
        }
    }

    /// The contained floating point value if `.Float` or `.Double`, `nil` otherwise.
    public var floatValue: Swift.Float? {
        switch self {
        case .Float(let value):
            return value
        case .Double(let value):
            return Swift.Float(value)
        default:
            return nil
        }
    }

    /// The contained double-precision floating point value if `.Float` or `.Double`, `nil` otherwise.
    public var doubleValue: Swift.Double? {
        switch self {
        case .Float(let value):
            return Swift.Double(value)
        case .Double(let value):
            return value
        default:
            return nil
        }
    }

    /// The contained string if `.String`, `nil` otherwise.
    public var stringValue: Swift.String? {
        switch self {
        case .String(let string):
            return string
        default:
            return nil
        }
    }

    /// The contained binary data if `.Binary`, `nil` otherwise.
    public var binaryValue: [UInt8]? {
        switch self {
        case .Binary(let bytes):
            return bytes
        default:
            return nil
        }
    }

    /// The contained type and data if Extended, `nil` otherwise.
    public var extendedValue: (type: Int8, data: [UInt8])? {
        switch self {
        case .Extended(type: let type, data: let data):
            return (type, data)
        default:
            return nil
        }
    }

    /// The contained type if `.Extended`, `nil` otherwise.
    public var extendedType: Int8? {
        switch self {
        case .Extended(type: let type, data: _):
            return type
        default:
            return nil
        }
    }

    /// The contained data if `.Extended`, `nil` otherwise.
    public var extendedData: [UInt8]? {
        switch self {
        case .Extended(type: _, data: let data):
            return data
        default:
            return nil
        }
    }

    /// The contained dictionary if `.Map`, `nil` otherwise.
    public var dictionaryValue: [MessagePackValue : MessagePackValue]? {
        switch self {
        case .Map(let dict):
            return dict
        default:
            return nil
        }
    }
}

extension MessagePackValue: Printable {
    public var description: Swift.String {
        switch self {
        case .Nil:
            return "<Nil>"
        case .Bool(let value):
            return value ? "true" : "false"
        case .Int(let value):
            return "\(value)"
        case .UInt(let value):
            return "\(value)"
        case .Float(let value):
            return "\(value)"
        case .Double(let value):
            return "\(value)"
        case .String(let string):
            return string
        case .Binary(let bytes):
            return "<Data: \(bytes.count) byte(s)>"
        case .Array(let array):
            return "<Array: \(array.count) element(s)>"
        case .Map(let dict):
            return "<Map: \(dict.count) pair(s)>"
        case .Extended(let type, let bytes):
            return "<ExtendedType: type \(type); \(bytes.count) byte(s)>"
        }
    }
}

extension MessagePackValue: DebugPrintable {
    public var debugDescription: Swift.String {
        switch self {
        case .Nil:
            return ".Nil"
        case .Bool(let value):
            return ".Bool(\(value))"
        case .Int(let value):
            return ".Int(\(value))"
        case .UInt(let value):
            return ".UInt(\(value))"
        case .Float(let value):
            return ".Float(\(value))"
        case .Double(let value):
            return ".Double(\(value))"
        case .String(let string):
            return ".String(\"\(string)\")"
        case .Binary(let bytes):
            return ".Binary(\(bytes))"
        case .Array(let array):
            return ".Array(\(array))"
        case .Map(let dict):
            return ".Map(\(dict))"
        case .Extended(let type, let bytes):
            return ".Extended(type: \(type), bytes: \(bytes))"
        }
    }
}
