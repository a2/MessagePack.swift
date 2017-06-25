@testable import MessagePackTests
import XCTest

XCTMain([
    testCase(ArrayTests.allTests),
    testCase(BinaryTests.allTests),
    testCase(ConvenienceInitializersTests.allTests),
    testCase(ConveniencePropertiesTests.allTests),
    testCase(DescriptionTests.allTests),
    testCase(DoubleTests.allTests),
    testCase(EqualityTests.allTests),
    testCase(ExampleTests.allTests),
    testCase(ExtendedTests.allTests),
    testCase(FalseTests.allTests),
    testCase(FloatTests.allTests),
    testCase(HashValueTests.allTests),
    testCase(IntegerTests.allTests),
    testCase(MapTests.allTests),
    testCase(NilTests.allTests),
    testCase(SubdataTests.allTests),
    testCase(StringTests.allTests),
    testCase(TrueTests.allTests),
])
