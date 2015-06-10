/**
    Splits an integer into a number of bytes.

    - parameter value: The integer to split.
    - parameter parts: The number of bytes into which to split.

    - returns: An byte array representation.
*/
func splitInt(value: UInt64, parts: Int) -> Data {
    precondition(parts > 0)
    return stride(from: 8 * (parts - 1), through: 0, by: -8).map { shift in
        return Byte(truncatingBitPattern: value >> numericCast(shift))
    }
}

/**
    Encodes a positive integer into MessagePack bytes.

    - parameter value: The integer to split.

    - returns: A MessagePack byte representation.
*/
func packIntPos(value: UInt64) -> Data {
    switch value {
    case let value where value <= 0x7f:
        return [Byte(truncatingBitPattern: value)]
    case let value where value <= 0xff:
        return [0xcc, Byte(truncatingBitPattern: value)]
    case let value where value <= 0xffff:
        return [0xcd] + splitInt(value, parts: 2)
    case let value where value <= 0xffff_ffff:
        return [0xce] + splitInt(value, parts: 4)
    default:
        return [0xcf] + splitInt(value, parts: 8)
    }
}

/**
    Encodes a negative integer into MessagePack bytes.

    - parameter value: The integer to split.

    - returns: A MessagePack byte representation.
*/
func packIntNeg(value: Int64) -> Data {
    precondition(value < 0)

    switch value {
    case let value where value >= -0x20:
        return [0xe0 + 0x1f & Byte(truncatingBitPattern: value)]
    case let value where value >= -0x7f:
        return [0xd0, Byte(bitPattern: numericCast(value))]
    case let value where value >= -0x7fff:
        let truncated = UInt16(bitPattern: numericCast(value))
        return [0xd1] + splitInt(numericCast(truncated), parts: 2)
    case let value where value >= -0x7fff_ffff:
        let truncated = UInt32(bitPattern: numericCast(value))
        return [0xd2] + splitInt(numericCast(truncated), parts: 4)
    default:
        let truncated = UInt64(bitPattern: value)
        return [0xd3] + splitInt(truncated, parts: 8)
    }
}
