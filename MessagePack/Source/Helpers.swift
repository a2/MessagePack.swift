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
