import Foundation

enum MessagePackError: ErrorType {
    case NotEnoughData
    case InvalidString
}

/**
    Creates a data object from the underlying storage of the array.

    - parameter array: An array to convert to data.

    - returns: A data object.
*/
func makeData(array: [UInt8]) -> NSData {
    return array.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<UInt8>) -> NSData in
        NSData(bytes: ptr.baseAddress, length: ptr.count)
    }
}

/**
    Joins `size` values from `generator` to form a `UInt64`.

    - parameter generator: The generator that yields bytes.
    - parameter size: The number of bytes to yield.

    - returns: A `UInt64` representing an integer of `size` bytes.
*/
func joinUInt64<G: GeneratorType where G.Element == UInt8>(inout generator: G, size: Int) throws -> UInt64 {
    var int: UInt64 = 0
    for _ in 0..<size {
        if let byte = generator.next() {
            int = int << 8 | numericCast(byte)
        } else {
            throw MessagePackError.NotEnoughData
        }
    }

    return int
}

/**
    Joins `length` values from `generator` to form a `String`.

    - parameter generator: The generator that yields bytes.
    - parameter length: The length of the resulting string.

    - returns: A `String` representing `length` bytes.
*/
func joinString<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) throws -> String {
    let ptrCount = length + 1 // +1 for \0-termination
    let ptr = UnsafeMutablePointer<CChar>.alloc(ptrCount)
    defer {
        ptr.dealloc(ptrCount)
    }

    for i in 0..<length {
        if let byte = generator.next() {
            ptr[i] = CChar(bitPattern: byte)
        } else {
            throw MessagePackError.NotEnoughData
        }
    }
    ptr[length] = 0

    guard let string = String.fromCString(ptr) else {
        throw MessagePackError.InvalidString
    }

    return string
}

/**
    Joins bytes from `generator` to form a data object of size `length`.

    - parameter generator: The generator that yields bytes.
    - parameter length: The length of the data.

    - returns: A data object with length `length`.
*/
func joinData<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) throws -> NSData {
    var array = [UInt8]()
    array.reserveCapacity(length)

    for _ in 0..<length {
        if let value = generator.next() {
            array.append(value)
        } else {
            throw MessagePackError.NotEnoughData
        }
    }

    return makeData(array)
}

/**
    Joins bytes from `generator` to form an `Array` of size `length` containing `MessagePackValue` values.

    - parameter generator: The generator that yields bytes.
    - parameter length: The length of the array.

    - returns: An `Array` of length `length`.
*/
func joinArray<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) throws -> [MessagePackValue] {
    var array = [MessagePackValue]()
    array.reserveCapacity(length)

    for _ in 0..<length {
        if let value = unpack(&generator) {
            array.append(value)
        } else {
            throw MessagePackError.NotEnoughData
        }
    }

    return array
}

/**
    Joins bytes from `generator` to form a `Dictionary` of size `length` containing `MessagePackValue` keys and values.

    - parameter generator: The generator that yields bytes.
    - parameter length: The length of the array.

    - returns: A `Dictionary` of count `length`.
*/
func joinMap<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) throws -> [MessagePackValue : MessagePackValue] {
    var dict = [MessagePackValue : MessagePackValue](minimumCapacity: length)
    var lastKey: MessagePackValue? = nil
    for item in try joinArray(&generator, length: length * 2) {
        if let key = lastKey {
            dict[key] = item
            lastKey = nil
        } else {
            lastKey = item
        }
    }

    return dict
}

/**
    Splits an integer into `parts` bytes.

    - parameter value: The integer to split.
    - parameter parts: The number of bytes into which to split.

    - returns: An byte array representation of `value`.
*/
func splitInt(value: UInt64, parts: Int) -> [UInt8] {
    precondition(parts > 0)
    return stride(from: 8 * (parts - 1), through: 0, by: -8).map { shift in
        return UInt8(truncatingBitPattern: value >> numericCast(shift))
    }
}

/**
    Encodes a positive integer into MessagePack bytes.

    - parameter value: The integer to split.

    - returns: A MessagePack byte representation of `value`.
*/
func packIntPos(value: UInt64) -> [UInt8] {
    switch value {
    case let value where value <= 0x7f:
        return [UInt8(truncatingBitPattern: value)]
    case let value where value <= 0xff:
        return [0xcc, UInt8(truncatingBitPattern: value)]
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

    - returns: A MessagePack byte representation of `value`.
*/
func packIntNeg(value: Int64) -> [UInt8] {
    precondition(value < 0)

    switch value {
    case let value where value >= -0x20:
        return [0xe0 + 0x1f & UInt8(truncatingBitPattern: value)]
    case let value where value >= -0x7f:
        return [0xd0, UInt8(bitPattern: numericCast(value))]
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

/**
    Flattens a dictionary into an array of alternating keys and values.

    - parameter dict: The dictionary to flatten.

    - returns: An array of keys and values.
*/
func flatten<T>(dict: [T : T]) -> [T] {
    return dict.flatMap { [$0.0, $0.1] }
}
