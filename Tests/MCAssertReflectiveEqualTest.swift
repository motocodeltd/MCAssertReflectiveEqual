//
// Created by Stefanos Zachariadis first name at last name dot net
// Copyright (c) 2017 motocode ltd. All rights reserved. MIT license
//

import Foundation
import XCTest
import MCAssertReflectiveEqual

class MCAssertReflectiveEqualTest: XCTestCase {

    private let tester = Tester()
    
    private enum MyEnum {
        case A, B
    }

    private struct EmptyStruct {

    }

    private class EmptyClass {

    }

    private class Loopy {
        var loop: Loopy?
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

    func testWillCompareItemToNil() {
        let a: String? = nil
        let b = "bob"
        XCTAssertFalse(tester.areEqual(a, b))
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

        XCTAssertFalse(tester.areEqual(first, second))
        let matcher = matcherFor(Double.self, { (one, two) in
            return abs(one - two) < 0.001
        })

        XCTAssertTrue(tester.areEqual(first, second, matchers: [matcher]))
    }

    func testWillUseCustomMatcherToSayDifferentIntsAreEqual() {
        let matcher = matcherFor(Int.self, { (one, two) -> Bool in
            return true
        })
        XCTAssertTrue(tester.areEqual(1, 2, matchers: [matcher]))
    }

    func testTwoNumbersAreEqual() {
        XCTAssertTrue(tester.areEqual(1, 1))
    }

    func testTwoNumbersAreNotEqual() {
        XCTAssertFalse(tester.areEqual(1, 2))
    }

    func testTwoEmptyArraysAreEqual() {
        XCTAssertTrue(tester.areEqual([], []))
    }

    func testTwoArraysAreEqual() {
        XCTAssertTrue(tester.areEqual([1], [1]))
    }

    func testTwoArraysOfDifferentSizeNotEqual() {
        XCTAssertFalse(tester.areEqual([1], [1, 2]))
    }

    func testTwoArraysAreNotEqual() {
        XCTAssertFalse(tester.areEqual([1], [2]))
    }

    func testTwoNilsOfSameTypeAreEqual() {
        let a: String? = nil
        let b: String? = nil
        XCTAssertTrue(tester.areEqual(a, b))
    }

    func testTwoNilsOfDifferentTypeCoeercedAreNotEqual() {
        let a: String? = nil
        let b: Int? = nil
        XCTAssertFalse(tester.areEqual(a as Any, b as Any))
    }

    func testANilIsNotEqualToAValue() {
        let a: String? = nil
        let b: String? = "bob"
        XCTAssertFalse(tester.areEqual(a, b))
    }

    func testOptionalsAreEqual() {
        let a: String? = "bob"
        let b: String? = "bob"
        XCTAssertTrue(tester.areEqual(a, b))
    }

    func testOptionalsAreNotEqual() {
        let a: String? = "bob"
        let b: String? = "robert"
        XCTAssertFalse(tester.areEqual(a, b))
    }

    func testEmptyDictionariesAreEqual() {
        XCTAssertTrue(tester.areEqual([:], [:]))
    }

    func testDictionariesAreEqual() {
        XCTAssertTrue(tester.areEqual(["a": "b"], ["a": "b"]))
    }

    func testDictionariesAreNotEqual() {
        XCTAssertFalse(tester.areEqual(["a": "b"], ["c": "d"]))
    }

    func testOrderDoesNotMatterForDictionaries() {
        var a: [String: String] = [:]
        var b: [String: String] = [:]
        a["a"] = "b"
        a["b"] = "a"

        b["b"] = "a"
        b["a"] = "b"

        XCTAssertTrue(tester.areEqual(a, b))
    }

    func testTwoEmptyObjectsAreEqual() {
        XCTAssertTrue(tester.areEqual(EmptyClass(), EmptyClass()))
    }

    func testSameObjectIsEqual() {
        let obj = ClassWithVal(1)
        XCTAssertTrue(tester.areEqual(obj, obj))
    }

    func testTwoObjectsAreEqual() {
        XCTAssertTrue(tester.areEqual(ClassWithVal(1), ClassWithVal(1)))
    }

    func testTwoObjectsAreNotEqual() {
        XCTAssertFalse(tester.areEqual(ClassWithVal(1), ClassWithVal(2)))
    }


    func testSameFunctionTwiceIsEqual() {
        func a() {

        }

        XCTAssertTrue(tester.areEqual(a, a))
    }

    func testClosureEquality() {
        let a = {

        }
        XCTAssertTrue(tester.areEqual(a, a))
    }

    func testTwoTuplesAreEqual() {
        XCTAssertTrue(tester.areEqual((1, 2), (1, 2)))
    }

    func testTwoTuplesAreNotEqual() {
        XCTAssertFalse(tester.areEqual((1, 1), (1, 2)))
    }

    func testTwoTuplesOfDifferentSizesCoercedAreNotEqual() {
        XCTAssertFalse(tester.areEqual((1, 2, 1) as Any, (1, 2) as Any))
    }

    func testTwoEmptyStructsAreEqual() {
        XCTAssertTrue(tester.areEqual(EmptyStruct(), EmptyStruct()))
    }

    func testTwoStructsWithValAreEqual() {
        XCTAssertTrue(tester.areEqual(StructWithVal(1), StructWithVal(1)))
    }

    func testTwoStructsWithValAreNotEqual() {
        XCTAssertFalse(tester.areEqual(StructWithVal(3), StructWithVal(1)))
    }

    func testTwoEnumsAreEqual() {
        XCTAssertTrue(tester.areEqual(MyEnum.A, MyEnum.A))
    }

    func testTwoEnumsAreNotEqual() {
        XCTAssertFalse(tester.areEqual(MyEnum.A, MyEnum.B))
    }

    func testMatchingLoops() {
        let a = Loopy()
        a.loop = a

        let b = Loopy()
        b.loop = b

        XCTAssertTrue(tester.areEqual(a, b))
    }

    func testStructLoops() {
        var a = LoopyStruct()
        a.loop = a

        var b = LoopyStruct()
        b.loop = b

        XCTAssertTrue(tester.areEqual(a, b))
    }
}
