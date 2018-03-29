import Foundation
import XCTest
@testable import MessagePack

class StringTests: XCTestCase {
    static var allTests = {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPackFixstr", testPackFixstr),
            ("testUnpackFixstr", testUnpackFixstr),
            ("testUnpackFixstrEmpty", testUnpackFixstrEmpty),
            ("testPackStr8", testPackStr8),
            ("testUnpackStr8", testUnpackStr8),
            ("testPackStr16", testPackStr16),
            ("testUnpackStr16", testUnpackStr16),
            ("testPackStr32", testPackStr32),
            ("testUnpackStr32", testUnpackStr32),
        ]
    }()

    func testLiteralConversion() {
        var implicitValue: MessagePackValue

        implicitValue = "Hello, world!"
        XCTAssertEqual(implicitValue, .string("Hello, world!"))

        implicitValue = MessagePackValue(extendedGraphemeClusterLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, .string("Hello, world!"))

        implicitValue = MessagePackValue(unicodeScalarLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, .string("Hello, world!"))
    }

    func testPackFixstr() {
        let packed = Data([0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])
        XCTAssertEqual(pack(.string("Hello, world!")), packed)
    }

    func testUnpackFixstr() {
        let packed = Data([0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .string("Hello, world!"))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testUnpackFixstrEmpty() {
        let packed = Data([0xa0])

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .string(""))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackStr8() {
        let string = String(repeating: "*", count: 0x20)
        XCTAssertEqual(pack(.string(string)), Data([0xd9, 0x20]) + string.data(using: .utf8)!)
    }

    func testUnpackStr8() {
        let string = String(repeating: "*", count: 0x20)
        let packed = Data([0xd9, 0x20]) + string.data(using: .utf8)!

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .string(string))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackStr16() {
        let string = String(repeating: "*", count: 0x1000)
        XCTAssertEqual(pack(.string(string)), [0xda, 0x10, 0x00] + string.data(using: .utf8)!)
    }

    func testUnpackStr16() {
        let string = String(repeating: "*", count: 0x1000)
        let packed = Data([0xda, 0x10, 0x00]) + string.data(using: .utf8)!

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .string(string))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackStr32() {
        let string = String(repeating: "*", count: 0x10000)
        XCTAssertEqual(pack(.string(string)), Data([0xdb, 0x00, 0x01, 0x00, 0x00]) + string.data(using: .utf8)!)
    }

    func testUnpackStr32() {
        let string = String(repeating: "*", count: 0x10000)
        let packed = Data([0xdb, 0x00, 0x01, 0x00, 0x00]) + string.data(using: .utf8)!

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .string(string))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
