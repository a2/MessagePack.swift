import Foundation

extension MessagePackValue {
    public init() {
        self = .nil
    }

    public init(_ value: Bool) {
        self = .bool(value)
    }

    public init<S: SignedInteger>(_ value: S) {
        self = .int(Int64(value))
    }

    public init<U: UnsignedInteger>(_ value: U) {
        self = .uint(UInt64(value))
    }

    public init(_ value: Float) {
        self = .float(value)
    }

    public init(_ value: Double) {
        self = .double(value)
    }

    public init(_ value: String) {
        self = .string(value)
    }

    public init(_ value: [MessagePackValue]) {
        self = .array(value)
    }

    public init(_ value: [MessagePackValue: MessagePackValue]) {
        self = .map(value)
    }

    public init(_ value: Data) {
        self = .binary(value)
    }
}
