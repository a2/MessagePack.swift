import Foundation

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
public enum MessagePackValue {
    case Nil
    case Bool(Swift.Bool)
    case Int(Int64)
    case UInt(UInt64)
    case Float(Float32)
    case Double(Float64)
    case String(Swift.String)
    case Binary(NSData)
    case Array([MessagePackValue])
    case Map([MessagePackValue : MessagePackValue])
    case Extended(Int8, NSData)
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
        case .Binary(let data): return data.hashValue
        case .Array(let array): return array.count
        case .Map(let dict): return dict.count
        case .Extended(let type, let data): return type.hashValue ^ data.hashValue
        }
    }
}

/**
    Unpacks a generator of bytes into a MessagePackValue.

    - parameter generator: The generator that yields bytes.

    - returns: A MessagePackValue, or `nil` if the generator runs out of bytes.
*/
public func unpack<G: GeneratorType where G.Element == UInt8>(inout generator: G) -> MessagePackValue? {
    guard let value = generator.next() else { return nil }

    switch value {

    // positive fixint
    case 0x00...0x7f:
        return .UInt(numericCast(value))

    // fixmap
    case 0x80...0x8f:
        let length = Int(value - 0x80)
        if let dict = joinMap(&generator, length: length) {
            return .Map(dict)
        }

    // fixarray
    case 0x90...0x9f:
        let length = Int(value - 0x90)
        if let array = joinArray(&generator, length: length) {
            return .Array(array)
        }

    // fixstr
    case 0xa0...0xbf:
        let length = Int(value - 0xa0)
        if let string = joinString(&generator, length: length) {
            return .String(string)
        }

    // nil
    case 0xc0:
        return .Nil

    // false
    case 0xc2:
        return .Bool(false)

    // true
    case 0xc3:
        return .Bool(true)

    // bin 8, 16, 32
    case 0xc4...0xc6:
        let size = 1 << numericCast(value - 0xc4)
        if let length = joinUInt64(&generator, size: size),
            data = joinData(&generator, length: numericCast(length)) {
                return .Binary(data)
        }

    // ext 8, 16, 32
    case 0xc7...0xc9:
        let size = 1 << Int(value - 0xc7)
        if let length = joinUInt64(&generator, size: size),
            typeByte = generator.next() {
                let type = Int8(bitPattern: typeByte)
                if let data = joinData(&generator, length: numericCast(length)) {
                    return .Extended(type, data)
                }
        }

    // float 32
    case 0xca:
        if let bytes = joinUInt64(&generator, size: 4) {
            let float = unsafeBitCast(UInt32(truncatingBitPattern: bytes), Float32.self)
            return .Float(float)
        }

    // float 64
    case 0xcb:
        if let bytes = joinUInt64(&generator, size: 8) {
            let double = unsafeBitCast(bytes, Float64.self)
            return .Double(double)
        }

    // uint 8, 16, 32, 64
    case 0xcc...0xcf:
        let length = 1 << (numericCast(value) - 0xcc)
        if let integer = joinUInt64(&generator, size: length) {
            return .UInt(integer)
        }

    // int 8
    case 0xd0:
        if let byte = generator.next() {
            let integer = Int8(bitPattern: byte)
            return .Int(numericCast(integer))
        }

    // int 16
    case 0xd1:
        if let bytes = joinUInt64(&generator, size: 2) {
            let integer = Int16(bitPattern: UInt16(truncatingBitPattern: bytes))
            return .Int(numericCast(integer))
        }

    // int 32
    case 0xd2:
        if let bytes = joinUInt64(&generator, size: 4) {
            let integer = Int32(bitPattern: UInt32(truncatingBitPattern: bytes))
            return .Int(numericCast(integer))
        }

    // int 64
    case 0xd3:
        if let bytes = joinUInt64(&generator, size: 8) {
            let integer = Int64(bitPattern: bytes)
            return .Int(integer)
        }

    // fixent 1, 2, 4, 8, 16
    case 0xd4...0xd8:
        let length = 1 << Int(value - 0xd4)
        if let typeByte = generator.next() {
            let type = Int8(bitPattern: typeByte)
            if let bytes = joinData(&generator, length: length) {
                return .Extended(type, bytes)
            }
        }

    // str 8, 16, 32
    case 0xd9...0xdb:
        let lengthSize = 1 << Int(value - 0xd9)
        if let length = joinUInt64(&generator, size: lengthSize),
            string = joinString(&generator, length: numericCast(length)) {
                return .String(string)
        }

    // array 16, 32
    case 0xdc...0xdd:
        let lengthSize = 1 << Int(value - 0xdb)
        if let length = joinUInt64(&generator, size: lengthSize),
            array = joinArray(&generator, length: numericCast(length)) {
                return .Array(array)
        }

    // map 16, 32
    case 0xde...0xdf:
        let lengthSize = 1 << Int(value - 0xdd)
        if let length = joinUInt64(&generator, size: lengthSize),
            dict = joinMap(&generator, length: numericCast(length)) {
                return .Map(dict)
        }

    // negative fixint
    case 0xe0..<0xff:
        return .Int(numericCast(value) - 0x100)

    // negative fixint (workaround for rdar://19779978)
    case 0xff:
        return .Int(numericCast(value) - 0x100)

    default:
        break
    }

    return nil
}

/**
    Unpacks a data object into a MessagePackValue.

    - parameter data: A data object to unpack.

    - returns: A MessagePackValue, or `nil` if the data is malformed.
*/
public func unpack(data: NSData) -> MessagePackValue? {
    let immutableData = data.copy() as! NSData
    let ptr = UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(immutableData.bytes), count: immutableData.length)
    var generator = ptr.generate()
    return unpack(&generator)
}

/**
    Packs a MessagePackValue into an array of bytes.

    - parameter value: The value to encode

    - returns: An array of bytes.
*/
public func pack(value: MessagePackValue) -> NSData {
    switch value {
    case .Nil:
        return makeData([0xc0])

    case .Bool(let value):
        return makeData([value ? 0xc3 : 0xc2])

    case .Int(let value):
        let bytes = value >= 0 ? packIntPos(numericCast(value)) : packIntNeg(value)
        return makeData(bytes)

    case .UInt(let value):
        return makeData(packIntPos(value))

    case .Float(let value):
        let integerValue = unsafeBitCast(value, UInt32.self)
        return makeData([0xca] + splitInt(numericCast(integerValue), parts: 4))

    case .Double(let value):
        let integerValue = unsafeBitCast(value, UInt64.self)
        return makeData([0xcb] + splitInt(integerValue, parts: 8))

    case .String(let string):
        let utf8 = string.utf8
        let count = UInt32(utf8.count)
        precondition(count <= 0xffff_ffff)

        let prefix: [UInt8]
        switch count {
        case let count where count <= 0x19:
            prefix = [0xa0 | numericCast(count)]
        case let count where count <= 0xff:
            prefix = [0xd9, numericCast(count)]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: numericCast(count))
            prefix = [0xda] + splitInt(numericCast(truncated), parts: 2)
        default:
            prefix = [0xdb] + splitInt(numericCast(count), parts: 4)
        }
        return makeData(prefix + utf8)

    case .Binary(let data):
        let length = UInt32(data.length)
        precondition(length <= 0xffff_ffff)

        let prefix: [UInt8]
        switch length {
        case let length where length <= 0xff:
            prefix = [0xc4, numericCast(length)]
        case let length where length <= 0xffff:
            let truncated = UInt16(bitPattern: numericCast(length))
            prefix = [0xc5] + splitInt(numericCast(truncated), parts: 2)
        default:
            prefix = [0xc6] + splitInt(numericCast(length), parts: 4)
        }

        let mutableData = NSMutableData()
        mutableData.appendData(makeData(prefix))
        mutableData.appendData(data)
        return mutableData

    case .Array(let array):
        let count = UInt32(array.count)
        precondition(count <= 0xffff_ffff)

        let prefix: [UInt8]
        switch count {
        case let count where count <= 0xe:
            prefix = [0x90 | numericCast(count)]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: numericCast(count))
            prefix = [0xdc] + splitInt(numericCast(truncated), parts: 2)
        default:
            prefix = [0xdd] + splitInt(numericCast(count), parts: 4)
        }

        let mutableData = NSMutableData()
        mutableData.appendData(makeData(prefix))

        let dataArray = array.map(pack)
        for data in dataArray {
            mutableData.appendData(data)
        }

        return mutableData

    case .Map(let dict):
        let count = UInt32(dict.count)
        precondition(count < 0xffff_ffff)

        var prefix: [UInt8]
        switch count {
        case let count where count <= 0xe:
            prefix = [0x80 | numericCast(count)]
        case let count where count <= 0xffff:
            let truncated = UInt16(bitPattern: numericCast(count))
            prefix = [0xde] + splitInt(numericCast(truncated), parts: 2)
        default:
            prefix = [0xdf] + splitInt(numericCast(count), parts: 4)
        }

        let mutableData = NSMutableData()
        mutableData.appendData(makeData(prefix))

        let dataArray = flatten(dict).map(pack)
        for data in dataArray {
            mutableData.appendData(data)
        }

        return mutableData

    case .Extended(let type, let data):
        let length = UInt32(data.length)
        precondition(length <= 0xffff_ffff)

        let unsignedType = UInt8(bitPattern: type)
        var prefix: [UInt8]
        switch UInt32(data.length) {
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
        case let length where length <= 0xff:
            prefix = [0xc7, numericCast(length), unsignedType]
        case let length where length <= 0xffff:
            let truncated = UInt16(bitPattern: numericCast(length))
            prefix = [0xc8] + splitInt(numericCast(truncated), parts: 2) + [unsignedType]
        default:
            prefix = [0xc9] + splitInt(numericCast(length), parts: 4) + [unsignedType]
        }

        let mutableData = NSMutableData()
        mutableData.appendData(makeData(prefix))
        mutableData.appendData(data)
        return mutableData
    }
}

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
    case let (.Int(lhv), .UInt(rhv)) where lhv >= 0 && numericCast(lhv) == rhv:
        return true
    case let (.UInt(lhv), .Int(rhv)) where rhv >= 0 && lhv == numericCast(rhv):
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
        var dict = [MessagePackValue : MessagePackValue](minimumCapacity: elements.count)
        for (key, value) in elements {
            dict[key] = value
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

extension MessagePackValue: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .Nil:
            return "Nil"
        case let .Bool(value):
            return "Bool(\(value))"
        case let .Int(value):
            return "Int(\(value))"
        case let .UInt(value):
            return "UInt(\(value))"
        case let .Float(value):
            return "Float(\(value))"
        case let .Double(value):
            return "Double(\(value))"
        case let .String(string):
            return "String(\(string))"
        case let .Binary(data):
            return "Data(\(data.description))"
        case let .Array(array):
            return "Array(\(array.description))"
        case let .Map(dict):
            return "Map(\(dict.description))"
        case let .Extended(type, data):
            return "Extended(\(type), \(data.description))"
        }
    }
}
