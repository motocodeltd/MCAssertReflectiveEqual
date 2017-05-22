//
// Created by Stefanos Zachariadis first name at last name dot net
// Copyright (c) 2017 motocode ltd. All rights reserved. MIT license
//

import Foundation
import XCTest
import MCAssertReflectiveEqual

class MatchersTest : XCTestCase {

    private let tester = Tester()

    func testWillCompareDoublesWithAccuracy() {
        let a = 1.01
        let b = 1.02

        let doubleMatcher = matchDoubles(withAccuracy: 0.1)

        XCTAssertFalse(tester.areEqual(a, b))
        XCTAssertTrue(tester.areEqual(a, b, matchers: [doubleMatcher]))
    }
}
