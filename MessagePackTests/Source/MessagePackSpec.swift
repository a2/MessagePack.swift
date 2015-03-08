import MessagePack
import Nimble
import Quick

let NSDataEquality: (NSData, NSData) -> Bool = { $0.isEqualToData($1) }

class MessagePackSpec: QuickSpec {
    override func spec() {
        describe("example") {
            let example: MessagePackValue = ["compact": true, "schema": 0]

            // Two possible "correct" values because dictionaries are unordered
            let correct: [NSData] = [
                makeData([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00]),
                makeData([0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3]),
            ]

            it("packs correctly") {
                expect(pack(example)).to(beContainedIn(correct, NSDataEquality))
                return
            }

            it("unpacks correctly") {
                for bytes in correct {
                    expect(unpack(bytes)) == example
                }
            }
        }

        describe("nil") {
            let value = MessagePackValue.Nil
            let packed = makeData([0xc0])

            it("converts from literal") {
                let implicitValue: MessagePackValue = nil
                expect(implicitValue) == value
            }

            it("packs correctly") {
                expect(pack(value)) == packed
                return
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
                return
            }
        }

        describe("true") {
            let value = MessagePackValue.Bool(true)
            let packed = makeData([0xc3])

            it("converts from literal") {
                let implicitValue: MessagePackValue = true
                expect(implicitValue) == value
            }

            it("packs correctly") {
                expect(pack(value)) == packed
                return
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
                return
            }
        }

        describe("false") {
            let value = MessagePackValue.Bool(false)
            let packed = makeData([0xc2])

            it("converts from literal") {
                let implicitValue: MessagePackValue = false
                expect(implicitValue) == value
            }

            it("packs correctly") {
                expect(pack(value)) == packed
            }
        }

        describe("int") {
            it("converts from positive literal") {
                let value: MessagePackValue = 42
                let explicitValue = MessagePackValue.UInt(42)
                expect(value) == explicitValue
            }

            it("converts from negative literal") {
                let value: MessagePackValue = -1
                let explicitValue = MessagePackValue.Int(-1)
                expect(value) == explicitValue
            }

            let value = MessagePackValue.UInt(0x42)
            let packed = makeData([0x42])

            it("packs correctly") {
                expect(pack(value)) == packed
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
            }
        }

        describe("double") {
            let value = MessagePackValue.Double(3.14)
            let packed = makeData([0xcb, 0x40, 0x09, 0x1e, 0xb8, 0x51, 0xeb, 0x85, 0x1f])

            it("converts from literal") {
                let implicitValue: MessagePackValue = 3.14
                expect(implicitValue) == value
            }

            it("packs correctly") {
                expect(pack(value)) == packed
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
            }
        }

        describe("float") {
            let value = MessagePackValue.Float(3.14)
            let packed = makeData([0xca, 0x40, 0x48, 0xf5, 0xc3])

            it("packs correctly") {
                expect(pack(value)) == packed
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
            }
        }

        describe("string") {
            let value = MessagePackValue.String("Hello, world!")
            let packed = makeData([0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])

            it("converts from literal") {
                let implicitValue: MessagePackValue = "Hello, world!"
                expect(implicitValue) == value
            }

            it("packs correctly") {
                expect(pack(value)) == packed
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
            }
        }

        describe("binary") {
            let value = MessagePackValue.Binary(makeData([0x00, 0x01, 0x02, 0x03, 0x04]))
            let packed = makeData([0xc4, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04])

            it("packs correctly") {
                expect(pack(value)) == packed
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
            }
        }

        describe("array") {
            let value = MessagePackValue.Array([.UInt(0), .UInt(1), .UInt(2), .UInt(3), .UInt(4)])
            let packed = makeData([0x95, 0x00, 0x01, 0x02, 0x03, 0x04])

            it("converts from literal") {
                let implicitValue: MessagePackValue = [0, 1, 2, 3, 4]
                expect(implicitValue) == value
            }

            it("packs correctly") {
                expect(pack(value)) == packed
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
            }
        }

        describe("map") {
            let value = MessagePackValue.Map([.String("c"): .String("cookie")])
            let packed = makeData([0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65])

            it("converts from literal") {
                let implicitValue: MessagePackValue = ["c": "cookie"]
                expect(implicitValue) == value
            }

            it("packs correctly") {
                expect(pack(value)) == packed
            }

            it("unpacks correctly") {
                expect(unpack(packed)) == value
            }
        }

        describe("extended") {
            context("fixext 1") {
                let value = MessagePackValue.Extended(type: 5, data: makeData([0x00]))
                let packed = makeData([0xd4, 0x05, 0x00])

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }

            context("fixext 2") {
                let value = MessagePackValue.Extended(type: 5, data: makeData([0x00, 0x01]))
                let packed = makeData([0xd5, 0x05, 0x00, 0x01])

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }

            context("fixext 4") {
                let value = MessagePackValue.Extended(type: 5, data: makeData([0x00, 0x01, 0x02, 0x03]))
                let packed = makeData([0xd6, 0x05, 0x00, 0x01, 0x02, 0x03])

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }

            context("fixext 8") {
                let value = MessagePackValue.Extended(type: 5, data: makeData([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))
                let packed = makeData([0xd7, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }

            context("fixext 16") {
                let value = MessagePackValue.Extended(type: 5, data: makeData([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]))
                let packed = makeData([0xd8, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f])

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }

            context("ext 8") {
                let payload = Array(count: 7, repeatedValue: UInt8())
                let value = MessagePackValue.Extended(type: 5, data: makeData(payload))
                let packed = makeData([0xc7, 0x07, 0x05] + payload)

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }

            context("ext 16") {
                let payload = Array(count: 0x100, repeatedValue: UInt8())
                let value = MessagePackValue.Extended(type: 5, data: makeData(payload))
                let packed = makeData([0xc8, 0x01, 0x00, 0x05] + payload)

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }

            context("ext 32") {
                let payload = Array(count: 0x10000, repeatedValue: UInt8())
                let value = MessagePackValue.Extended(type: 5, data: makeData(payload))
                let packed = makeData([0xc9, 0x00, 0x01, 0x00, 0x00, 0x05] + payload)

                it("packs correctly") {
                    expect(pack(value)) == packed
                }

                it("unpacks correctly") {
                    expect(unpack(packed)) == value
                }
            }
        }
    }
}
