import MessagePack
import Quick
import Nimble

class MessagePackSpec: QuickSpec {
    override func spec() {
        describe("example") {
            it("packs conrrectly") {
                let value: MessagePackValue = ["compact": true, "schema": 0]

                // Two possible "correct" values because dictionaries are unordered
                let correct: [[UInt8]] = [
                    [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00],
                    [0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3],
                ]

                expect(pack(value)).to(beContainedIn(correct, ==))
            }
        }

        describe("nil") {
            it("converts from literal") {
                let value: MessagePackValue = nil
                let explicitValue = MessagePackValue.MPNil
                expect(value) == explicitValue
            }

            it("packs correctly") {
                let value = MessagePackValue.MPNil
                expect(pack(value)) == [0xc0]
            }

            it("unpacks correctly") {
                let value = MessagePackValue.MPNil
                expect(unpack(pack(value))) == value
            }
        }

        describe("true") {
            it("converts from literal") {
                let value: MessagePackValue = true
                let explicitValue = MessagePackValue.MPBool(true)
                expect(value) == explicitValue
            }

            it("packs correctly") {
                let value = MessagePackValue.MPBool(true)
                expect(pack(value)) == [0xc3]
            }

            it("unpacks correctly") {
                let value = MessagePackValue.MPBool(true)
                expect(unpack(pack(value))) == value
            }
        }

        describe("false") {
            it("converts from literal") {
                let value: MessagePackValue = false
                let explicitValue = MessagePackValue.MPBool(false)
                expect(value) == explicitValue
            }

            it("packs correctly") {
                let value = MessagePackValue.MPBool(false)
                expect(pack(value)) == [0xc2]
            }

            it("unpacks correctly") {
                let value = MessagePackValue.MPBool(false)
                expect(unpack(pack(value))) == value
            }
        }

        describe("int") {
            it("converts from positive literal") {
                let value: MessagePackValue = 42
                let explicitValue = MessagePackValue.MPUInt(42)
                expect(value) == explicitValue
            }

            it("converts from negative literal") {
                let value: MessagePackValue = -1
                let explicitValue = MessagePackValue.MPInt(-1)
                expect(value) == explicitValue
            }

            it("packs correctly") {
                let value = MessagePackValue.MPUInt(0x42)
                expect(pack(value)) == [0x42]
            }

            it("unpacks correctly") {
                let value = MessagePackValue.MPUInt(0x42)
                expect(unpack(pack(value))) == value
            }
        }
    }
}
