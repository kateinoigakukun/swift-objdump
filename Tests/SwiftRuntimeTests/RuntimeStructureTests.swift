import XCTest
@testable import SwiftRuntime


class RuntimeStructureTests: XCTestCase {

    func testPair() {
        typealias S = RuntimePair<RuntimeValue<Int>, RuntimeValue<Int>>
        struct R {
            let value1: Int
            let value2: Int
        }

        var data = R(value1: 0x80, value2: 0xff)
        let s = S(&data)
        XCTAssertEqual(s.project1().get(), 0x80)
        XCTAssertEqual(s.project2().get(), 0xff)
    }

    func testUnion() {
        typealias S = RuntimeUnion<RuntimeValue<UInt64>, RuntimeValue<UInt8>>

        var data = 0xffff
        let s = S(&data)
        XCTAssertEqual(s.project1().get(), 0xffff)
        XCTAssertEqual(s.project2().get(), 0xff)
    }

    func testComposition() {
        typealias S = RuntimePair<
            RuntimeValue<Int>,
            RuntimeUnion<
                RuntimeValue<UInt64>,
                RuntimeValue<UInt8>
            >
        >
        struct R {
            let value1: Int
            let value2: Int
        }

        var data = R(value1: 0x80, value2: 0xffff)
        let s = S(&data)
        XCTAssertEqual(s.project1().get(), 0x80)
        XCTAssertEqual(s.project2().project1().get(), 0xffff)
        XCTAssertEqual(s.project2().project2().get(), 0xff)
    }

    class ExampleClass {
        let value: Int = 0
    }
    func testParseClassMetadata() {
        let ptr = unsafeBitCast(ExampleClass.self, to: UnsafeRawPointer.self).advanced(by: -8)
        let metadata = ClassFullMetadata(ptr)
        let name = String(cString: metadata.descriptor.name.get())

        XCTAssertEqual(name, "ExampleClass")
    }
}
