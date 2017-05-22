//
// Created by Stefanos Zachariadis first name at last name dot net
// Copyright (c) 2017 motocode ltd. All rights reserved. MIT license
//

import Foundation
@testable import MCAssertReflectiveEqual

class Tester {
    private var equal: Bool?

    private func failFunction(message: String, file: StaticString, line: UInt) {
        equal = false
    }

    private func nsObjectCheckFunction(expected: NSObject, actual: NSObject, message: String, file: StaticString, line: UInt) {
        if let equal = equal {
            if (!equal) {
                return
            }
        }
        equal = actual == expected
    }

    private func optionalStringFunction(expected: String?, actual: String?, message: String, file: StaticString, line: UInt) {
        if let equal = equal {
            if (!equal) {
                return
            }
        }
        equal = actual == expected
    }

    func areEqual<T>(_ expected: T, _ actual: T, matchers: [Matcher] = []) -> Bool {
        equal = nil
        internalMCAssertReflectiveEqual(expected, actual, matchers: matchers,
                nsObjectCheckFunction: nsObjectCheckFunction,
                optionalStringEqualsFunction: optionalStringFunction,
                failFunction: failFunction)
        return equal ?? true
    }
}