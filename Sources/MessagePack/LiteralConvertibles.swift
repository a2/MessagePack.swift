extension MessagePackValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MessagePackValue...) {
        self = .array(elements)
    }
}

extension MessagePackValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension MessagePackValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (MessagePackValue, MessagePackValue)...) {
        var dict = [MessagePackValue: MessagePackValue](minimumCapacity: elements.count)
        for (key, value) in elements {
            dict[key] = value
        }

        self = .map(dict)
    }
}

extension MessagePackValue: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
}

extension MessagePackValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension MessagePackValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self = .int(value)
    }
}

extension MessagePackValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension MessagePackValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension MessagePackValue: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
}
