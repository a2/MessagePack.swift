internal func joinUInt64<G: GeneratorType where G.Element == UInt8>(inout generator: G, size: Int) -> UInt64? {
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

internal func joinString<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> String? {
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

internal func joinArrayRaw<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> [UInt8]? {
    var array = [UInt8]()
    array.reserveCapacity(length)

    for _ in 0..<length {
        if let value = generator.next() {
            array.append(value)
        } else {
            return nil
        }
    }

    return array
}

internal func joinArrayUnpack<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> [MessagePackValue]? {
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

internal func joinMap<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) -> [MessagePackValue : MessagePackValue]? {
    let doubleLength = length * 2
    if let array = joinArrayUnpack(&generator, length * 2) {
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
