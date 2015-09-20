extension MessagePackValue {
    public init() {
        self = .Nil
    }

    public init(_ value: Swift.Bool) {
        self = .Bool(value)
    }

    public init<S: SignedIntegerType>(_ value: S) {
        self = .Int(numericCast(value))
    }

    public init<U: UnsignedIntegerType>(_ value: U) {
        self = .UInt(numericCast(value))
    }

    public init(_ value: Swift.Float) {
        self = .Float(value)
    }

    public init(_ value: Swift.Double) {
        self = .Double(value)
    }

    public init(_ value: Swift.String) {
        self = .String(value)
    }

    public init(_ value: [MessagePackValue]) {
        self = .Array(value)
    }

    public init(_ value: [MessagePackValue : MessagePackValue]) {
        self = .Map(value)
    }

    public init(_ value: Data) {
        self = .Binary(value)
    }
}
