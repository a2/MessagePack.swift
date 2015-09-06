public typealias Byte = UInt8
public typealias Data = [Byte]

/// The MessagePackValue enum encapsulates one of the following types: Nil, Bool, Int, UInt, Float, Double, String, Binary, Array, Map, and Extended.
public enum MessagePackValue {
    case Nil
    case Bool(Swift.Bool)
    case Int(Int64)
    case UInt(UInt64)
    case Float(Swift.Float)
    case Double(Swift.Double)
    case String(Swift.String)
    case Binary(Data)
    case Array([MessagePackValue])
    case Map([MessagePackValue : MessagePackValue])
    case Extended(Int8, Data)
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
        case .Binary(let data): return data.count
        case .Array(let array): return array.count
        case .Map(let dict): return dict.count
        case .Extended(let type, let data): return type.hashValue ^ data.count
        }
    }
}

public func ==(lhs: MessagePackValue, rhs: MessagePackValue) -> Bool {
    switch (lhs, rhs) {
    case (.Nil, .Nil):
        return true
    case let (.Bool(lhv), .Bool(rhv)):
        return lhv == rhv
    case let (.Int(lhv), .Int(rhv)):
        return lhv == rhv
    case let (.UInt(lhv), .UInt(rhv)):
        return lhv == rhv
    case let (.Int(lhv), .UInt(rhv)):
        return lhv >= 0 && numericCast(lhv) == rhv
    case let (.UInt(lhv), .Int(rhv)):
        return rhv >= 0 && lhv == numericCast(rhv)
    case let (.Float(lhv), .Float(rhv)):
        return lhv == rhv
    case let (.Double(lhv), .Double(rhv)):
        return lhv == rhv
    case let (.String(lhv), .String(rhv)):
        return lhv == rhv
    case let (.Binary(lhv), .Binary(rhv)):
        return lhv == rhv
    case let (.Array(lhv), .Array(rhv)):
        return lhv == rhv
    case let (.Map(lhv), .Map(rhv)):
        return lhv == rhv
    case let (.Extended(lht, lhb), .Extended(rht, rhb)):
        return lht == rht && lhb == rhb
    default:
        return false
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
            return "Data(\(dataDescription(data)))"
        case let .Array(array):
            return "Array(\(array.description))"
        case let .Map(dict):
            return "Map(\(dict.description))"
        case let .Extended(type, data):
            return "Extended(\(type), \(dataDescription(data)))"
        }
    }
}

public enum MessagePackError: ErrorType {
    case InsufficientData
    case InvalidData
}

func dataDescription(data: Data) -> String {
    let bytes = data.map { byte -> String in
        let prefix: String
        if byte < 0x10 {
            prefix = "0x0"
        } else {
            prefix = "0x"
        }

        return prefix + String(byte, radix: 16)
    }

    return "[" + bytes.joinWithSeparator(", ") + "]"
}
