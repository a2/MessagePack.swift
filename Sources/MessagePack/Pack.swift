import Foundation

/// Packs an integer into a byte array.
///
/// - parameter value: The integer to split.
/// - parameter parts: The number of bytes into which to split.
///
/// - returns: An byte array representation.
func packInteger(_ value: UInt64, parts: Int) -> Data {
    precondition(parts > 0)
    let bytes = stride(from: (8 * (parts - 1)), through: 0, by: -8).map { shift in
        return UInt8(truncatingIfNeeded: value >> UInt64(shift))
    }
    return Data(bytes)
}

/// Packs an unsigned integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
func packPositiveInteger(_ value: UInt64) -> Data {
    if value <= 0x7f {
        return Data([UInt8(truncatingIfNeeded: value)])
    } else if value <= 0xff {
        return Data([0xcc, UInt8(truncatingIfNeeded: value)])
    } else if value <= 0xffff {
        return Data([0xcd]) + packInteger(value, parts: 2)
    } else if value <= 0xffff_ffff as UInt64 {
        return Data([0xce]) + packInteger(value, parts: 4)
    } else {
        return Data([0xcf]) + packInteger(value, parts: 8)
    }
}

/// Packs a signed integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
func packNegativeInteger(_ value: Int64) -> Data {
    precondition(value < 0)
    if value >= -0x20 {
        return Data([0xe0 + 0x1f & UInt8(truncatingIfNeeded: value)])
    } else if value >= -0x7f {
        return Data([0xd0, UInt8(bitPattern: Int8(value))])
    } else if value >= -0x7fff {
        let truncated = UInt16(bitPattern: Int16(value))
        return Data([0xd1]) + packInteger(UInt64(truncated), parts: 2)
    } else if value >= -0x7fff_ffff {
        let truncated = UInt32(bitPattern: Int32(value))
        return Data([0xd2]) + packInteger(UInt64(truncated), parts: 4)
    } else {
        let truncated = UInt64(bitPattern: value)
        return Data([0xd3]) + packInteger(truncated, parts: 8)
    }
}

/// Packs a MessagePackValue into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
public func pack(_ value: MessagePackValue) -> Data {
    switch value {
    case .nil:
        return Data([0xc0])

    case .bool(let value):
        return Data([value ? 0xc3 : 0xc2])

    case .int(let value):
        if value >= 0 {
            return packPositiveInteger(UInt64(value))
        } else {
            return packNegativeInteger(value)
        }

    case .uint(let value):
        return packPositiveInteger(value)

    case .float(let value):
        return Data([0xca]) + packInteger(UInt64(value.bitPattern), parts: 4)

    case .double(let value):
        return Data([0xcb]) + packInteger(value.bitPattern, parts: 8)

    case .string(let string):
        let utf8 = string.utf8
        let count = UInt32(utf8.count)
        precondition(count <= 0xffff_ffff as UInt32)

        let prefix: Data
        if count <= 0x19 {
            prefix = Data([0xa0 | UInt8(count)])
        } else if count <= 0xff {
            prefix = Data([0xd9, UInt8(count)])
        } else if count <= 0xffff {
            prefix = Data([0xda]) + packInteger(UInt64(count), parts: 2)
        } else {
            prefix = Data([0xdb]) + packInteger(UInt64(count), parts: 4)
        }

        return prefix + utf8

    case .binary(let data):
        let count = UInt32(data.count)
        precondition(count <= 0xffff_ffff as UInt32)

        let prefix: Data
        if count <= 0xff {
            prefix = Data([0xc4, UInt8(count)])
        } else if count <= 0xffff {
            prefix = Data([0xc5]) + packInteger(UInt64(count), parts: 2)
        } else {
            prefix = Data([0xc6]) + packInteger(UInt64(count), parts: 4)
        }

        return prefix + data

    case .array(let array):
        let count = UInt32(array.count)
        precondition(count <= 0xffff_ffff as UInt32)

        let prefix: Data
        if count <= 0xe {
            prefix = Data([0x90 | UInt8(count)])
        } else if count <= 0xffff {
            prefix = Data([0xdc]) + packInteger(UInt64(count), parts: 2)
        } else {
            prefix = Data([0xdd]) + packInteger(UInt64(count), parts: 4)
        }

        return prefix + array.flatMap(pack)

    case .map(let dict):
        let count = UInt32(dict.count)
        precondition(count < 0xffff_ffff)

        var prefix: Data
        if count <= 0xe {
            prefix = Data([0x80 | UInt8(count)])
        } else if count <= 0xffff {
            prefix = Data([0xde]) + packInteger(UInt64(count), parts: 2)
        } else {
            prefix = Data([0xdf]) + packInteger(UInt64(count), parts: 4)
        }

        return prefix + dict.flatMap { [$0, $1] }.flatMap(pack)

    case .extended(let type, let data):
        let count = UInt32(data.count)
        precondition(count <= 0xffff_ffff as UInt32)

        let unsignedType = UInt8(bitPattern: type)
        var prefix: Data
        switch count {
        case 1:
            prefix = Data([0xd4, unsignedType])
        case 2:
            prefix = Data([0xd5, unsignedType])
        case 4:
            prefix = Data([0xd6, unsignedType])
        case 8:
            prefix = Data([0xd7, unsignedType])
        case 16:
            prefix = Data([0xd8, unsignedType])
        case let count where count <= 0xff:
            prefix = Data([0xc7, UInt8(count), unsignedType])
        case let count where count <= 0xffff:
            prefix = Data([0xc8]) + packInteger(UInt64(count), parts: 2) + Data([unsignedType])
        default:
            prefix = Data([0xc9]) + packInteger(UInt64(count), parts: 4) + Data([unsignedType])
        }

        return prefix + data
    }
}
