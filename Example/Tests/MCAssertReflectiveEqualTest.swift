import Foundation
import XCTest
import MCAssertReflectiveEqual

 class MCAssertReflectiveEqualTest : XCTestCase {
    
    private enum MyEnum {
        case A, B
    }
    
    private struct EmptyStruct {
        
    }
    
    private class EmptyClass {
        
    }
    
    private class Loopy {
        var loop:Loopy?
    }
    
    private class ClassWithVal {
        var val: Int
        
        init(_ val: Int) {
            self.val = val
        }
    }
    
    private struct StructWithVal {
        var val: Int
        
        init(_ val: Int) {
            self.val = val
        }
    }
    
    private var equal:Bool?
    
    private func failFunction(message: String, file: StaticString, line: UInt) {
        equal = false
    }
    
    private func typeCheckFunction(expected: Any.Type, actual: Any.Type, message: String, file: StaticString, line: UInt) {
        if let equal = equal {
            if(!equal) {
                return
            }
        }
        equal = actual == expected
    }
    
    private func countCheckFunction(expected: IntMax, actual: IntMax, message: String, file: StaticString, line: UInt) {
        if let equal = equal {
            if(!equal) {
                return
            }
        }
        equal = actual == expected
    }
    
    private func nsObjectCheckFunction(expected: NSObject, actual: NSObject, message: String, file: StaticString, line: UInt) {
        if let equal = equal {
            if(!equal) {
                return
            }
        }
        equal = actual == expected
    }
    
    private func optionalStringFunction(expected: String?, actual: String?, message: String, file: StaticString, line: UInt) {
        if let equal = equal {
            if(!equal) {
                return
            }
        }
        equal = actual == expected
    }
    
    func testTwoNumbersAreEqual() {
        XCTAssertTrue(areEqual(1, 1))
    }
    
    func testTwoNumbersAreNotEqual() {
        XCTAssertFalse(areEqual(1, 2))
    }
    
    func testTwoEmptyArraysAreEqual() {
        XCTAssertTrue(areEqual([], []))
    }
    
    func testTwoArraysAreEqual() {
        XCTAssertTrue(areEqual([1], [1]))
    }
    
    func testTwoArraysOfDifferentSizeNotEqual() {
        XCTAssertFalse(areEqual([1], [1, 2]))
    }
    
    func testTwoArraysAreNotEqual() {
        XCTAssertFalse(areEqual([1], [2]))
    }
    
    func testTwoNilsOfSameTypeAreEqual() {
        let a:String? = nil
        let b:String? = nil
        XCTAssertTrue(areEqual(a, b))
    }
    
    func testTwoNilsOfDifferentTypeAreEqual() {
        let a:String? = nil
        let b:Int? = nil
        XCTAssertFalse(areEqual(a, b))
    }
    
    func testANilIsNotEqualToAValue() {
        let a:String? = nil
        let b:String? = "bob"
        XCTAssertFalse(areEqual(a, b))
    }
    
    func testOptionalsAreEqual() {
        let a:String? = "bob"
        let b:String? = "bob"
        XCTAssertTrue(areEqual(a, b))
    }
    
    func testOptionalsAreNotEqual() {
        let a:String? = "bob"
        let b:String? = "robert"
        XCTAssertFalse(areEqual(a, b))
    }
    
    func testEmptyDictionariesAreEqual() {
        XCTAssertTrue(areEqual([:], [:]))
    }
    
    func testDictionariesAreEqual() {
        XCTAssertTrue(areEqual(["a":"b"], ["a":"b"]))
    }
    
    func testDictionariesAreNotEqual() {
        XCTAssertFalse(areEqual(["a":"b"], ["c":"d"]))
    }
    
    func testOrderDoesNotMatterForDictionaries() {
        var a:[String:String] = [:]
        var b:[String:String] = [:]
        a["a"] = "b"
        a["b"] = "a"
        
        b["b"] = "a"
        b["a"] = "b"
        
        XCTAssertTrue(areEqual(a, b))
    }
    
    func testTwoEmptyObjectsAreEqual() {
        XCTAssertTrue(areEqual(EmptyClass(), EmptyClass()))
    }
    
    func testSameObjectIsEqual() {
        let obj = ClassWithVal(1)
        XCTAssertTrue(areEqual(obj, obj))
    }
    
    func testTwoObjectsAreEqual() {
        XCTAssertTrue(areEqual(ClassWithVal(1), ClassWithVal(1)))
    }
    
    func testTwoObjectsAreNotEqual() {
        XCTAssertFalse(areEqual(ClassWithVal(1), ClassWithVal(2)))
    }
    
    
    func testSameFunctionTwiceIsEqual() {
        func a() {
            
        }
        
        XCTAssertTrue(areEqual(a, a))
    }
    
    func testClosureEquality() {
        let a = {
            
        }
        XCTAssertTrue(areEqual(a, a))
    }
    
    func testTwoTuplesAreEqual() {
        XCTAssertTrue(areEqual((1, 2), (1, 2)))
    }
    
    func testTwoTuplesAreNotEqual() {
        XCTAssertFalse(areEqual((1, 1), (1, 2)))
    }
    
    func testTwoTuplesOfDifferentSizeAreNotEqual() {
        XCTAssertFalse(areEqual((1, 2, 1), (1, 2)))
    }
    
    func testTwoEmptyStructsAreEqual() {
        XCTAssertTrue(areEqual(EmptyStruct(), EmptyStruct()))
    }
    
    func testTwoStructsWithValAreEqual() {
        XCTAssertTrue(areEqual(StructWithVal(1), StructWithVal(1)))
    }
    
    func testTwoStructsWithValAreNotEqual() {
        XCTAssertFalse(areEqual(StructWithVal(3), StructWithVal(1)))
    }
    
    func testTwoEnumsAreEqual() {
        XCTAssertTrue(areEqual(MyEnum.A, MyEnum.A))
    }
    
    func testTwoEnumsAreNotEqual() {
        XCTAssertFalse(areEqual(MyEnum.A, MyEnum.B))
    }
    
    func testMatchingLoops() {
        let a = Loopy()
        a.loop = a
        
        let b = Loopy()
        b.loop = b
        
        XCTAssertTrue(areEqual(a, b))
    }
    
    
    private func areEqual (_ expected: Any, _ actual: Any) -> Bool {
        MCAssertReflectiveEqual(expected, actual,
                          typeCheckFunction: typeCheckFunction,
                          countCheckFunction: countCheckFunction,
                          nsObjectCheckFunction: nsObjectCheckFunction,
                          optionalStringEqualsFunction: optionalStringFunction,
                          failFunction: failFunction)
        return equal!
    }
}
