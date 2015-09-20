@testable import MessagePack
import XCTest

func string(length: Int, repeatedValue: String = "*") -> String {
    var str = ""
    str.reserveCapacity(length * repeatedValue.characters.count)

    for _ in 0..<length {
        str.appendContentsOf(repeatedValue)
    }

    return str
}

func data(string: String) -> ArraySlice<Byte> {
    return string.nulTerminatedUTF8.dropLast()
}

class StringTests: XCTestCase {
    func testLiteralConversion() {
        var implicitValue: MessagePackValue

        implicitValue = "Hello, world!"
        XCTAssertEqual(implicitValue, MessagePackValue.String("Hello, world!"))

        implicitValue = MessagePackValue(extendedGraphemeClusterLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, MessagePackValue.String("Hello, world!"))

        implicitValue = MessagePackValue(unicodeScalarLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, MessagePackValue.String("Hello, world!"))
    }

    func testPackFixstr() {
        let packed: Data = [0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]
        XCTAssertEqual(pack(.String("Hello, world!")), packed)
    }

    func testUnpackFixstr() {
        let packed: Data = [0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String("Hello, world!"))
    }

    func testPackStr8() {
        let str = string(0x20)
        XCTAssertEqual(pack(.String(str)), [0xd9, 0x20] + data(str))
    }

    func testUnpackStr8() {
        let str = string(0x20)
        let packed = [0xd9, 0x20] + data(str)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String(str))
    }

    func testPackStr16() {
        let str = string(0x1000)
        XCTAssertEqual(pack(.String(str)), [0xda, 0x10, 0x00] + data(str))
    }

    func testUnpackStr16() {
        let str = string(0x1000)
        let packed = [0xda, 0x10, 0x00] + data(str)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String(str))
    }

    func testPackStr32() {
        let str = string(0x10000)
        XCTAssertEqual(pack(.String(str)), [0xdb, 0x00, 0x01, 0x00, 0x00] + data(str))
    }

    func testUnpackStr32() {
        let str = string(0x10000)
        let packed = [0xdb, 0x00, 0x01, 0x00, 0x00] + data(str)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String(str))
    }
}
