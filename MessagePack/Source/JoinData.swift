import Foundation

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
