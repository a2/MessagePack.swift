import Foundation

/// Joins bytes to form an integer.
///
/// - parameter data: The input data to unpack.
/// - parameter size: The size of the integer.
///
/// - returns: An integer representation of `size` bytes of data and the not-unpacked remaining data.
func unpackInteger(_ data: Subdata, count: Int) throws -> (value: UInt64, remainder: Subdata) {
    guard count > 0 else {
        throw MessagePackError.invalidArgument
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }

    var value: UInt64 = 0
    for i in 0 ..< count {
        let byte = data[i]
        value = value << 8 | UInt64(byte)
    }

    return (value, data[count ..< data.count])
}

/// Joins bytes to form a string.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the string.
///
/// - returns: A string representation of `size` bytes of data and the not-unpacked remaining data.
func unpackString(_ data: Subdata, count: Int) throws -> (value: String, remainder: Subdata) {
    guard count > 0 else {
        return ("", data)
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }

    let subdata = data[0 ..< count]
    guard let result = String(data: subdata.data, encoding: .utf8) else {
        throw MessagePackError.invalidData
    }

    return (result, data[count ..< data.count])
}

/// Joins bytes to form a data object.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the data.
///
/// - returns: A subsection of data representing `size` bytes and the not-unpacked remaining data.
func unpackData(_ data: Subdata, count: Int) throws -> (value: Subdata, remainder: Subdata) {
    guard count > 0 else {
        throw MessagePackError.invalidArgument
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }

    return (data[0 ..< count], data[count ..< data.count])
}

/// Joins bytes to form an array of `MessagePackValue` values.
///
/// - parameter data: The input data to unpack.
/// - parameter count: The number of elements to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: An array of `count` elements and the not-unpacked remaining data.
func unpackArray(_ data: Subdata, count: Int, compatibility: Bool) throws -> (value: [MessagePackValue], remainder: Subdata) {
    var values = [MessagePackValue]()
    var remainder = data
    var newValue: MessagePackValue

    for _ in 0 ..< count {
        (newValue, remainder) = try unpack(remainder, compatibility: compatibility)
        values.append(newValue)
    }

    return (values, remainder)
}

/// Joins bytes to form a dictionary with `MessagePackValue` key/value entries.
///
/// - parameter data: The input data to unpack.
/// - parameter count: The number of elements to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: An dictionary of `count` entries and the not-unpacked remaining data.
func unpackMap(_ data: Subdata, count: Int, compatibility: Bool) throws -> (value: [MessagePackValue: MessagePackValue], remainder: Subdata) {
    var dict = [MessagePackValue: MessagePackValue](minimumCapacity: count)
    var lastKey: MessagePackValue? = nil

    let (array, remainder) = try unpackArray(data, count: 2 * count, compatibility: compatibility)
    for item in array {
        if let key = lastKey {
            dict[key] = item
            lastKey = nil
        } else {
            lastKey = item
        }
    }

    return (dict, remainder)
}

/// Unpacks data into a MessagePackValue and returns the remaining data.
///
/// - parameter data: The input data to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: A `MessagePackValue`and the not-unpacked remaining data.
public func unpack(_ data: Subdata, compatibility: Bool = false) throws -> (value: MessagePackValue, remainder: Subdata) {
    guard !data.isEmpty else {
        throw MessagePackError.insufficientData
    }

    let value = data[0]
    let data = data[1 ..< data.endIndex]

    switch value {

    // positive fixint
    case 0x00 ... 0x7f:
        return (.uint(UInt64(value)), data)

    // fixmap
    case 0x80 ... 0x8f:
        let count = Int(value - 0x80)
        let (dict, remainder) = try unpackMap(data, count: count, compatibility: compatibility)
        return (.map(dict), remainder)

    // fixarray
    case 0x90 ... 0x9f:
        let count = Int(value - 0x90)
        let (array, remainder) = try unpackArray(data, count: count, compatibility: compatibility)
        return (.array(array), remainder)

    // fixstr
    case 0xa0 ... 0xbf:
        let count = Int(value - 0xa0)
        if compatibility {
            let (subdata, remainder) = try unpackData(data, count: count)
            return (.binary(subdata.data), remainder)
        } else {
            let (string, remainder) = try unpackString(data, count: count)
            return (.string(string), remainder)
        }

    // nil
    case 0xc0:
        return (.nil, data)

    // false
    case 0xc2:
        return (.bool(false), data)

    // true
    case 0xc3:
        return (.bool(true), data)

    // bin 8, 16, 32
    case 0xc4 ... 0xc6:
        let intCount = 1 << Int(value - 0xc4)
        let (dataCount, remainder1) = try unpackInteger(data, count: intCount)
        let (subdata, remainder2) = try unpackData(remainder1, count: Int(dataCount))
        return (.binary(subdata.data), remainder2)

    // ext 8, 16, 32
    case 0xc7 ... 0xc9:
        let intCount = 1 << Int(value - 0xc7)

        let (dataCount, remainder1) = try unpackInteger(data, count: intCount)
        guard !remainder1.isEmpty else {
            throw MessagePackError.insufficientData
        }

        let type = Int8(bitPattern: remainder1[0])
        let (subdata, remainder2) = try unpackData(remainder1[1 ..< remainder1.count], count: Int(dataCount))
        return (.extended(type, subdata.data), remainder2)

    // float 32
    case 0xca:
        let (intValue, remainder) = try unpackInteger(data, count: 4)
        let float = Float(bitPattern: UInt32(truncatingIfNeeded: intValue))
        return (.float(float), remainder)

    // float 64
    case 0xcb:
        let (intValue, remainder) = try unpackInteger(data, count: 8)
        let double = Double(bitPattern: intValue)
        return (.double(double), remainder)

    // uint 8, 16, 32, 64
    case 0xcc ... 0xcf:
        let count = 1 << (Int(value) - 0xcc)
        let (integer, remainder) = try unpackInteger(data, count: count)
        return (.uint(integer), remainder)

    // int 8
    case 0xd0:
        guard !data.isEmpty else {
            throw MessagePackError.insufficientData
        }

        let byte = Int8(bitPattern: data[0])
        return (.int(Int64(byte)), data[1 ..< data.count])

    // int 16
    case 0xd1:
        let (bytes, remainder) = try unpackInteger(data, count: 2)
        let integer = Int16(bitPattern: UInt16(truncatingIfNeeded: bytes))
        return (.int(Int64(integer)), remainder)

    // int 32
    case 0xd2:
        let (bytes, remainder) = try unpackInteger(data, count: 4)
        let integer = Int32(bitPattern: UInt32(truncatingIfNeeded: bytes))
        return (.int(Int64(integer)), remainder)

    // int 64
    case 0xd3:
        let (bytes, remainder) = try unpackInteger(data, count: 8)
        let integer = Int64(bitPattern: bytes)
        return (.int(integer), remainder)

    // fixent 1, 2, 4, 8, 16
    case 0xd4 ... 0xd8:
        let count = 1 << Int(value - 0xd4)

        guard !data.isEmpty else {
            throw MessagePackError.insufficientData
        }

        let type = Int8(bitPattern: data[0])
        let (subdata, remainder) = try unpackData(data[1 ..< data.count], count: count)
        return (.extended(type, subdata.data), remainder)

    // str 8, 16, 32
    case 0xd9 ... 0xdb:
        let countSize = 1 << Int(value - 0xd9)
        let (count, remainder1) = try unpackInteger(data, count: countSize)
        if compatibility {
            let (subdata, remainder2) = try unpackData(remainder1, count: Int(count))
            return (.binary(subdata.data), remainder2)
        } else {
            let (string, remainder2) = try unpackString(remainder1, count: Int(count))
            return (.string(string), remainder2)
        }

    // array 16, 32
    case 0xdc ... 0xdd:
        let countSize = 1 << Int(value - 0xdb)
        let (count, remainder1) = try unpackInteger(data, count: countSize)
        let (array, remainder2) = try unpackArray(remainder1, count: Int(count), compatibility: compatibility)
        return (.array(array), remainder2)

    // map 16, 32
    case 0xde ... 0xdf:
        let countSize = 1 << Int(value - 0xdd)
        let (count, remainder1) = try unpackInteger(data, count: countSize)
        let (dict, remainder2) = try unpackMap(remainder1, count: Int(count), compatibility: compatibility)
        return (.map(dict), remainder2)

    // negative fixint
    case 0xe0 ..< 0xff:
        return (.int(Int64(value) - 0x100), data)

    // negative fixint (workaround for rdar://19779978)
    case 0xff:
        return (.int(Int64(value) - 0x100), data)

    default:
        throw MessagePackError.invalidData
    }
}

/// Unpacks data into a MessagePackValue and returns the remaining data.
///
/// - parameter data: The input data to unpack.
///
/// - returns: A `MessagePackValue` and the not-unpacked remaining data.
public func unpack(_ data: Data, compatibility: Bool = false) throws -> (value: MessagePackValue, remainder: Data) {
    let (value, remainder) = try unpack(Subdata(data: data), compatibility: compatibility)
    return (value, remainder.data)
}

/// Unpacks a data object into a `MessagePackValue`, ignoring excess data.
///
/// - parameter data: The data to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: The contained `MessagePackValue`.
public func unpackFirst(_ data: Data, compatibility: Bool = false) throws -> MessagePackValue {
    return try unpack(data, compatibility: compatibility).value
}

/// Unpacks a data object into an array of `MessagePackValue` values.
///
/// - parameter data: The data to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: The contained `MessagePackValue` values.
public func unpackAll(_ data: Data, compatibility: Bool = false) throws -> [MessagePackValue] {
    var values = [MessagePackValue]()

    var data = Subdata(data: data)
    while !data.isEmpty {
        let value: MessagePackValue
        (value, data) = try unpack(data, compatibility: compatibility)
        values.append(value)
    }

    return values
}
