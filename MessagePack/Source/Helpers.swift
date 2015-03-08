import Foundation

/**
    Creates a data object from the underlying storage of the array.

    :param: array An array to convert to data.

    :returns: A data object.
*/
func makeData(array: [UInt8]) -> NSData {
    return array.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<UInt8>) -> NSData in
        NSData(bytes: ptr.baseAddress, length: ptr.count)
    }
}

/**
    Joins `size` values from `generator` to form a `UInt64`.

    :param: generator The generator that yields bytes.
    :param: size The number of bytes to yield.

    :returns: A `UInt64`, or `nil` if the generator runs out of elements.
*/
func joinUInt64<G: GeneratorType where G.Element == UInt8>(inout generator: G, size: Int) -> UInt64? {
    var int: UInt64 = 0
    for _ in 0..<size {
        if let byte = generator.next() {
            int = int << 8 | UInt64(byte)
        } else {
            return nil
        }
    }

    return int
}

/**
    Joins `length` values from `generator` to form a `String`.

    :param: generator The generator that yields bytes.
    :param: length The length of the resulting string.

    :returns: A `String`, or `nil` if the generator runs out of elements.
*/
func joinString<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> String? {
    let ptrCount = length + 1 // +1 for \0-termination
    let ptr = UnsafeMutablePointer<CChar>.alloc(ptrCount)

    for i in 0..<length {
        if let byte = generator.next() {
            ptr[i] = CChar(bitPattern: byte)
        } else {
            ptr.dealloc(ptrCount)
            return nil
        }
    }
    ptr[length] = 0

    let string = String.fromCString(ptr)
    ptr.dealloc(ptrCount)

    return string
}

/**
    Joins bytes from `generator` to form an `Array` of size `length`.

    :param: generator The generator that yields bytes.
    :param: length The length of the array.

    :returns: An `Array`, or `nil` if the generator runs out of elements.
*/
func joinData<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> NSData? {
    var array = [UInt8]()
    array.reserveCapacity(length)

    for _ in 0..<length {
        if let value = generator.next() {
            array.append(value)
        } else {
            return nil
        }
    }

    return makeData(array)
}

/**
    Joins bytes from `generator` to form an `Array` of size `length` containing `MessagePackValue` values.

    :param: generator The generator that yields bytes.
    :param: length The length of the array.

    :returns: An `Array`, or `nil` if the generator runs out of elements.
*/
func joinArray<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> [MessagePackValue]? {
    var array = [MessagePackValue]()
    array.reserveCapacity(length)

    for _ in 0..<length {
        if let value = unpack(&generator) {
            array.append(value)
        } else {
            return nil
        }
    }

    return array
}

/**
    Joins bytes from `generator` to form a `Dictionary` of size `length` containing `MessagePackValue` keys and values.

    :param: generator The generator that yields bytes.
    :param: length The length of the array.

    :returns: A `Dictionary`, or `nil` if the generator runs out of elements.
*/
func joinMap<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> [MessagePackValue : MessagePackValue]? {
    let doubleLength = length * 2
    if let array = joinArray(&generator, length * 2) {
        var dict = [MessagePackValue : MessagePackValue]()
        var lastKey: MessagePackValue? = nil
        for item in array {
            if let key = lastKey {
                dict[key] = item
                lastKey = nil
            } else {
                lastKey = item
            }
        }

        return dict
    } else {
        return nil
    }
}

/**
    Splits an integer into `parts` bytes.

    :param: value The integer to split.
    :param: parts The number of bytes into which to split.

    :returns: An byte array representation of `value`.
*/
func splitInt(value: UInt64, #parts: Int) -> [UInt8] {
    return map(stride(from: 8 * (parts - 1), through: 0, by: -8)) { (shift: Int) -> UInt8 in
        return UInt8(truncatingBitPattern: value >> UInt64(shift))
    }
}

/**
    Encodes a positive integer into MessagePack bytes.

    :param: value The integer to split.

    :returns: A MessagePack byte representation of `value`.
*/
func packIntPos(value: UInt64) -> NSData {
    switch value {
    case let value where value <= 0x7f:
        return makeData([UInt8(truncatingBitPattern: value)])
    case let value where value <= 0xff:
        return makeData([0xcc, UInt8(truncatingBitPattern: value)])
    case let value where value <= 0xffff:
        return makeData([0xcd] + splitInt(value, parts: 2))
    case let value where value <= 0xffff_ffff:
        return makeData([0xce] + splitInt(value, parts: 4))
    case let value where value <= 0xffff_ffff_ffff_ffff:
        return makeData([0xcf] + splitInt(value, parts: 8))
    default:
        preconditionFailure()
    }
}

/**
    Encodes a negative integer into MessagePack bytes.

    :param: value The integer to split.

    :returns: A MessagePack byte representation of `value`.
*/
func packIntNeg(value: Int64) -> NSData {
    switch value {
    case let value where value >= -0x20:
        return makeData([0xe0 + UInt8(truncatingBitPattern: value)])
    case let value where value >= -0x7f:
        return makeData([0xd0, UInt8(bitPattern: Int8(value))])
    case let value where value >= -0x7fff:
        let truncated = UInt16(bitPattern: Int16(value))
        return makeData([0xd1] + splitInt(UInt64(truncated), parts: 2))
    case let value where value >= -0x7fff_ffff:
        let truncated = UInt32(bitPattern: Int32(value))
        return makeData([0xd2] + splitInt(UInt64(truncated), parts: 4))
    case let value where value >= -0x7fff_ffff_ffff_ffff:
        let truncated = UInt64(bitPattern: value)
        return makeData([0xd3] + splitInt(truncated, parts: 8))
    default:
        preconditionFailure()
    }
}

/**
    Flattens a dictionary into an array of alternating keys and values.

    :param: dict The dictionary to flatten.

    :returns: An array of keys and values.
*/
func flatten<T>(dict: [T : T]) -> [T] {
    return map(dict) { [$0.0, $0.1] }.reduce([], combine: +)
}
