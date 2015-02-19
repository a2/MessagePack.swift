private func splitInt(value: UInt64, #parts: Int) -> [UInt8] {
    return map(stride(from: 8 * (parts - 1), through: 0, by: -8)) { (shift: Int) -> UInt8 in
        return UInt8(truncatingBitPattern: value >> UInt64(shift))
    }
}

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

public enum MessagePackValue: Equatable, Hashable {
    case MPNil
    case MPBool(Bool)
    case MPInt(Int64)
    case MPUInt(UInt64)
    case MPFloat32(Float32)
    case MPFloat64(Float64)
    case MPString(String)
    case MPBinary([UInt8])
    case MPArray([MessagePackValue])
    case MPMap([MessagePackValue : MessagePackValue])
    case MPExtended(type: Int8, data: [UInt8])

    public var hashValue: Int {
        switch self {
        case .MPNil: return 0
        case .MPBool(let value): return value.hashValue
        case .MPInt(let value): return value.hashValue
        case .MPUInt(let value): return value.hashValue
        case .MPFloat32(let value): return value.hashValue
        case .MPFloat64(let value): return value.hashValue
        case .MPString(let string): return string.hashValue
        case .MPBinary(let bytes): return hashBytes(bytes)
        case .MPArray(let array): return array.count
        case .MPMap(let dict): return dict.count
        case .MPExtended(let type, let bytes): return type.hashValue ^ hashBytes(bytes)
        }
    }
}

private func flatten<T>(dict: [T : T]) -> [T] {
    return map(dict) { [$0.0, $0.1] }.reduce([], +)
}

public func unpack<G: GeneratorType where G.Element == UInt8>(inout generator: G) -> MessagePackValue? {
    if let value = generator.next() {
        switch value {
        case 0x00...0x7f:
            return .MPUInt(UInt64(value))
        case 0x80...0x8f:
            let length = Int(value - 0x80)
            if let dict = joinMap(&generator, length) {
                return .MPMap(dict)
            }
        case 0x90...0x9f:
            let length = Int(value - 0x90)
            if let array = joinArrayUnpack(&generator, length) {
                return .MPArray(array)
            }
        case 0xa0...0xbf:
            let length = Int(value - 0xa0)
            if let string = joinString(&generator, length) {
                return .MPString(string)
            }
        case 0xc0:
            return .MPNil
        case 0xc2:
            return .MPBool(false)
        case 0xc3:
            return .MPBool(true)
        case 0xc4...0xc6:
            let size = 1 << Int(value - 0xc4)
            if let length = joinUInt64(&generator, size) {
                if let array = joinArrayUnpack(&generator, Int(length)) {
                    return .MPArray(array)
                }
            }
        case 0xc7...0xc9:
            let size = 1 << Int(value - 0xc7)
            if let length = joinUInt64(&generator, size) {
                if let typeByte = generator.next() {
                    let type = Int8(bitPattern: typeByte)
                    if let bytes = joinArrayRaw(&generator, Int(length)) {
                        return .MPExtended(type: type, data: bytes)
                    }
                }
            }
        case 0xca:
            if let bytes = joinUInt64(&generator, 4) {
                let float = unsafeBitCast(UInt32(truncatingBitPattern: bytes), Float32.self)
                return .MPFloat32(float)
            }
        case 0xcb:
            if let bytes = joinUInt64(&generator, 8) {
                let double = unsafeBitCast(bytes, Float64.self)
                return .MPFloat64(double)
            }
        case 0xcc...0xcf:
            let length = 1 << (value - 0xcc)
            if let integer = joinUInt64(&generator, length) {
                return .MPUInt(integer)
            }
        case 0xd0:
            if let byte = generator.next() {
                let integer = Int8(bitPattern: byte)
                return .MPInt(Int64(integer))
            }
        case 0xd1:
            if let bytes = joinUInt64(&generator, 2) {
                let integer = Int16(bitPattern: UInt16(truncatingBitPattern: bytes))
                return .MPInt(Int64(integer))
            }
        case 0xd2:
            if let bytes = joinUInt64(&generator, 4) {
                let integer = Int32(bitPattern: UInt32(truncatingBitPattern: bytes))
                return .MPInt(Int64(integer))
            }
        case 0xd3:
            if let bytes = joinUInt64(&generator, 2) {
                let integer = Int64(bitPattern: bytes)
                return .MPInt(integer)
            }
        case 0xd4...0xd8:
            let length = 1 << Int(value - 0xd4)
            if let typeByte = generator.next() {
                let type = Int8(bitPattern: typeByte)
                if let bytes = joinArrayRaw(&generator, length) {
                    return .MPExtended(type: type, data: bytes)
                }
            }
        case 0xd9...0xdb:
            let lengthSize = 1 << Int(value - 0xd9)
            if let length = joinUInt64(&generator, lengthSize) {
                if let string = joinString(&generator, Int(length)) {
                    return .MPString(string)
                }
            }
        case 0xdc...0xdd:
            let lengthSize = 1 << Int(value - 0xdc)
            if let length = joinUInt64(&generator, lengthSize) {
                if let array = joinArrayUnpack(&generator, Int(length)) {
                    return .MPArray(array)
                }
            }
        case 0xde...0xdf:
            let lengthSize = 1 << Int(value - 0xdc)
            if let length = joinUInt64(&generator, lengthSize) {
                if let dict = joinMap(&generator, Int(length)) {
                    return .MPMap(dict)
                }
            }
        case 0xe0...0xff:
            return .MPInt(Int64(value) - 0x100)
        default:
            break
        }
    }

    return nil
}

public func pack(value: MessagePackValue) -> [UInt8] {
    switch value {
    case .MPNil:
        return [0xc0]
    case .MPBool(let value):
        return [value ? 0xc3 : 0xc2]
    case .MPInt(let value):
        return value >= 0 ? packIntPos(UInt64(value)) : packIntNeg(value)
    case .MPUInt(let value):
        return packIntPos(value)
    case .MPFloat32(let value):
        let integerValue = unsafeBitCast(value, UInt32.self)
        return [0xca] + splitInt(UInt64(integerValue), parts: 4)
    case .MPFloat64(let value):
        let integerValue = unsafeBitCast(value, UInt64.self)
        return [0xcb] + splitInt(integerValue, parts: 8)
    case .MPString(let string):
        let utf8 = string.utf8
        var prefix: [UInt8]
        switch UInt32(countElements(utf8)) {
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
    case .MPBinary(let bytes):
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
    case .MPArray(let array):
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
    case .MPMap(let dict):
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
        return prefix + flatten(dict).map(pack).reduce([], +)
    case .MPExtended(let type, let bytes):
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

public func unpack<S: SequenceType where S.Generator.Element == UInt8>(data: S) -> MessagePackValue? {
    var generator = data.generate()
    return unpack(&generator)
}

public func ==(lhs: MessagePackValue, rhs: MessagePackValue) -> Bool {
    switch (lhs, rhs) {
    case (.MPNil, .MPNil):
        return true
    case let (.MPBool(lhv), .MPBool(rhv)) where lhv == rhv:
        return true
    case let (.MPInt(lhv), .MPInt(rhv)) where lhv == rhv:
        return true
    case let (.MPUInt(lhv), .MPUInt(rhv)) where lhv == rhv:
        return true
    case let (.MPInt(lhv), .MPUInt(rhv)) where lhv > 0 && UInt64(lhv) == rhv:
        return true
    case let (.MPUInt(lhv), .MPInt(rhv)) where rhv > 0 && lhv == UInt64(rhv):
        return true
    case let (.MPFloat32(lhv), .MPFloat32(rhv)) where lhv == rhv:
        return true
    case let (.MPFloat64(lhv), .MPFloat64(rhv)) where lhv == rhv:
        return true
    case let (.MPString(lhv), .MPString(rhv)) where lhv == rhv:
        return true
    case let (.MPBinary(lhv), .MPBinary(rhv)) where lhv == rhv:
        return true
    case let (.MPArray(lhv), .MPArray(rhv)) where lhv == rhv:
        return true
    case let (.MPMap(lhv), .MPMap(rhv)) where lhv == rhv:
        return true
    case let (.MPExtended(lht, lhb), .MPExtended(rht, rhb)) where lht == rht && lhb == rhb:
        return true
    default:
        return false
    }
}

extension MessagePackValue: BooleanLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self = .MPBool(value)
    }
}

extension MessagePackValue: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (MessagePackValue, MessagePackValue)...) {
        let dict = elements.reduce([MessagePackValue : MessagePackValue]()) { (var dict, tuple) in
            let (key, value) = tuple
            dict[key] = value
            return dict
        }
        self = .MPMap(dict)
    }
}

extension MessagePackValue: ExtendedGraphemeClusterLiteralConvertible {
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .MPString(value)
    }
}

extension MessagePackValue: FloatLiteralConvertible {
    public init(floatLiteral value: Double) {
        self = .MPFloat64(value)
    }
}

extension MessagePackValue: IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self = .MPInt(Int64(value))
    }
}

extension MessagePackValue: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .MPNil
    }
}

extension MessagePackValue: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self = .MPString(value)
    }
}

extension MessagePackValue: UnicodeScalarLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .MPString(value)
    }
}
