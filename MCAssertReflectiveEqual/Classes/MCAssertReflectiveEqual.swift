//
// Created by Stefanos Zachariadis first name at last name dot net
// Copyright (c) 2017 motocode ltd. All rights reserved. MIT license
//

import Foundation
import XCTest

internal typealias MCNSObjectEqualsFunction = (NSObject, NSObject, String, StaticString, UInt) -> Void

private let NSObjectEqualsFunction: MCNSObjectEqualsFunction = { (expected, actual, message, file, line) in
    XCTAssertEqual(expected, actual, message, file: file, line: line)
}

internal typealias MCOptionalStringEqualsFunction = (String?, String?, String, StaticString, UInt) -> Void

private let optionalStringEqualsFunction: MCOptionalStringEqualsFunction = { (expected, actual, message, file, line) in
    XCTAssertEqual(expected, actual, message, file: file, line: line)
}

internal typealias MCFailFunction = (String, StaticString, UInt) -> Void

private let failFunction: MCFailFunction = { (message, file, line) in
    XCTFail(message, file: file, line: line)
}

public class Matcher {
    fileprivate let type: Any
    fileprivate let comparator: (Any, Any) -> Bool

    init<T>(type: T.Type, comparator: @escaping (T, T) -> Bool) {
        self.type = type;
        self.comparator = { (a, b) -> Bool in
            return comparator(a as! T, b as! T)
        }
    }
}

public func matcherFor<T>(_ type: T.Type, _ comparator: @escaping (_ expected: T, _ actual: T) -> Bool) -> Matcher {
    return Matcher(type: type, comparator: comparator)
}

public func MCAssertReflectiveEqual<T>(_ expected: T, _ actual: T,
                                       matchers: [Matcher] = [],
                                       file: StaticString = #file,
                                       line: UInt = #line) {
    internalMCAssertReflectiveEqual(expected, actual, matchers: matchers, file: file, line: line)
}

internal func internalMCAssertReflectiveEqual<T>(_ expected: T, _ actual: T,
                                                 matchers: [Matcher],
                                                 file: StaticString = #file,
                                                 line: UInt = #line,
                                                 nsObjectCheckFunction: MCNSObjectEqualsFunction = NSObjectEqualsFunction,
                                                 optionalStringEqualsFunction: MCOptionalStringEqualsFunction = optionalStringEqualsFunction,
                                                 failFunction: MCFailFunction = failFunction) {
    var expectedVisited = Set<ObjectIdentifier>()
    var actualVisited = Set<ObjectIdentifier>()

    let matchersByType: [String: (Any, Any) -> Bool] = matchers.reduce([String: (Any, Any) -> Bool]()) { (result, matcher) in
        var mutableResult = result
        var desc = String()
        dump(matcher.type, to: &desc)
        mutableResult[desc] = matcher.comparator
        return mutableResult
    }

    let typeMirror = Mirror(reflecting: actual)
    var typeAsString = String()
    dump(typeMirror.subjectType, to: &typeAsString)

    MCAssertReflectiveEqual(expected, actual, fieldName: typeAsString, expectedVisited: &expectedVisited, actualVisited: &actualVisited,
            expectedDescription: "", actualDescription: "", depth: 0,
            matchersByType: matchersByType,
            file: file, line: line,
            nsObjectCheckFunction: nsObjectCheckFunction,
            optionalStringEqualsFunction: optionalStringEqualsFunction,
            failFunction: failFunction)
}

private func appendItemDescription(fieldName: String?, previousDescription: String, depth: Int) -> String {
    let tabs = (0...depth).map({ _ in
        return "\t"
    }).reduce("") { (old, new) -> String in
        return old.appending(new)
    }

    return "\(previousDescription)\n\(tabs) \(fieldName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "[unnamed field]")"
}

private func MCAssertReflectiveEqual(_ expected: Any,
                                     _ actual: Any,
                                     fieldName: String?,
                                     expectedVisited: inout Set<ObjectIdentifier>,
                                     actualVisited: inout Set<ObjectIdentifier>,
                                     expectedDescription: String,
                                     actualDescription: String,
                                     depth: Int,
                                     matchersByType: [String: (Any, Any) -> Bool],
                                     file: StaticString,
                                     line: UInt,
                                     nsObjectCheckFunction: MCNSObjectEqualsFunction,
                                     optionalStringEqualsFunction: MCOptionalStringEqualsFunction,
                                     failFunction: MCFailFunction) {

    let expectedDescription = appendItemDescription(fieldName: fieldName, previousDescription: expectedDescription, depth: depth)
    let actualDescription = appendItemDescription(fieldName: fieldName, previousDescription: actualDescription, depth: depth)
    let expectedMirror = Mirror(reflecting: expected)
    let actualMirror = Mirror(reflecting: actual)

    guard expectedMirror.subjectType == actualMirror.subjectType else {
        failFunction("Types not the same expected: \(expectedDescription) is a \(expectedMirror.subjectType) \ngot:\n\(actualDescription) which is a \(actualMirror.subjectType)", file, line)
        return
    }

    var typeAsString = String()
    dump(expectedMirror.subjectType, to: &typeAsString)

    if let matcher = matchersByType[typeAsString] {
        if (!matcher(expected, actual)) {
            failFunction("\(expectedDescription): \(expected) not equal to \(actual) using custom matcher", file, line)
        }
        return
    }

    let expectedAsObject = expected as AnyObject
    let actualAsObject = actual as AnyObject

    if (expectedAsObject === actualAsObject) {
        return
    }

    var expectedChildren = expectedMirror.children
    var actualChildren = actualMirror.children

    guard expectedChildren.count == actualChildren.count else {
        failFunction("\(expectedDescription) has \(expectedChildren.count) but \(actualDescription) has \(actualChildren.count)", file, line)
        return
    }

    if (expectedChildren.count == 0) {
        if let expectedNsObj = expected as? NSObject, let actualNsObj = actual as? NSObject {
            nsObjectCheckFunction(expectedNsObj, actualNsObj, "\(expectedDescription): \(expectedNsObj) not equal to \(actualNsObj)", file, line)
        } else if (expectedMirror.displayStyle == .struct || expectedMirror.displayStyle == .class) {
            return
        } else if (expectedMirror.displayStyle == .enum) {
            optionalStringEqualsFunction(String(describing: expected), String(describing: actual), "\(expectedDescription): \(expected) not equal to \(actual)", file, line)
        } else if (expectedMirror.description.contains("->")) {
            print("ignoring closures in \(expectedDescription): \(actual)")
        } else {
            failFunction("cannot compare\n\(expectedDescription): \(actual)", file, line)
        }
    } else {
        while (!expectedChildren.isEmpty) {
            let expectedChild = expectedChildren.popFirst()!
            let actualChild = actualChildren.popFirst()!

            let canHoldChildrenByReference = expectedMirror.displayStyle == .class

            if (canHoldChildrenByReference) {
                let expectedChildAsObject = expectedChild.value as AnyObject
                let actualChildAsObject = actualChild.value as AnyObject
                let expectedHasBeenVisited = !expectedVisited.insert(ObjectIdentifier(expectedChildAsObject)).inserted
                let actualHasBeenVisited = !actualVisited.insert(ObjectIdentifier(actualChildAsObject)).inserted

                if (expectedHasBeenVisited || actualHasBeenVisited) {
                    if (expectedHasBeenVisited == actualHasBeenVisited) {
                        print("\(expectedDescription)\nand\(actualDescription)\n are matching looping objects \n")
                        return
                    } else {
                        failFunction("failed to compare\n\(expectedDescription)\n and \n\(actualDescription)\nlooping objects", file, line)
                        return
                    }
                }
            }


            optionalStringEqualsFunction(expectedChild.label, actualChild.label, "\(expectedDescription): \(String(describing: expectedChild.label)) not equal to \n\(actualDescription): \(String(describing: actualChild.label))", file, line)

            MCAssertReflectiveEqual(expectedChild.value, actualChild.value, fieldName: expectedChild.label,
                    expectedVisited: &expectedVisited, actualVisited: &actualVisited,
                    expectedDescription: expectedDescription,
                    actualDescription: actualDescription,
                    depth: depth + 1,
                    matchersByType: matchersByType,
                    file: file, line: line,
                    nsObjectCheckFunction: nsObjectCheckFunction,
                    optionalStringEqualsFunction: optionalStringEqualsFunction,
                    failFunction: failFunction)
            if (canHoldChildrenByReference) {
                _ = expectedVisited.remove(ObjectIdentifier(expectedChild.value as AnyObject))
                _ = actualVisited.remove(ObjectIdentifier(actualChild.value as AnyObject))
            }
        }
    }
}
