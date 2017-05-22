import Foundation
import XCTest
@testable import MCAssertReflectiveEqual

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
    
    private struct LoopyStruct {
        var loop: Any?
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
    
    func testWillCompareItemToNil() {
        let a:String? = nil
        let b = "bob"
        XCTAssertFalse(areEqual(a, b))
    }
    
    func testWillUseCustomMatcherToSayDoublesCloseToEachOther() {
        struct DoubleHolder {
            private let val: Double
            
            init(val: Double) {
                self.val = val
            }
        }
        
        let first = DoubleHolder(val: 1.00001)
        let second = DoubleHolder(val: 1.00002)
        
        XCTAssertFalse(areEqual(first, second))
        equal = nil
        let matcher = matcherFor(Double.self, { (one, two) in
            return abs(one - two) < 0.001
        })
        
        XCTAssertTrue(areEqual(first, second, customMatchers: [matcher]))
    }
    
    func testWillUseCustomMatcherToSayDifferentIntsAreEqual() {
        let matcher = matcherFor(Int.self, {(one, two) -> Bool in
            return true
        })
        XCTAssertTrue(areEqual(1, 2, customMatchers: [matcher]))
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
    
    func testTwoNilsOfDifferentTypeCoeercedAreNotEqual() {
        let a:String? = nil
        let b:Int? = nil
        XCTAssertFalse(areEqual(a as Any, b as Any))
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
    
    func testTwoTuplesOfDifferentSizesCoercedAreNotEqual() {
        XCTAssertFalse(areEqual((1, 2, 1) as Any, (1, 2) as Any))
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
    
    func testStructLoops() {
        var a = LoopyStruct()
        a.loop = a
        
        var b = LoopyStruct()
        b.loop = b
        
        XCTAssertTrue(areEqual(a, b))
    }
    
    
    private func areEqual<T>(_ expected: T, _ actual: T, customMatchers: [Matcher] = []) -> Bool {
        internalMCAssertReflectiveEqual(expected, actual, customMatchers: customMatchers,
                                        nsObjectCheckFunction: nsObjectCheckFunction,
                                        optionalStringEqualsFunction: optionalStringFunction,
                                        failFunction: failFunction)
        return equal ?? true
    }
}
