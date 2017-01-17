import Foundation
import XCTest

typealias MCTypeCheckFunction = (Any.Type, Any.Type, String, StaticString, UInt) -> Void

private let typeCheckFunction:MCTypeCheckFunction = { (expected, actual, message, file, line) in
    XCTAssertTrue(expected == actual, message, file: file, line:line)
}

typealias MCCountCheckFunction = (IntMax, IntMax, String, StaticString, UInt) -> Void

private let countCheckFunction:MCCountCheckFunction = { (expected, actual, message, file, line) in
    XCTAssertEqual(expected, actual, message, file: file, line: line)
}

typealias MCNSObjectEqualsFunction = (NSObject, NSObject, String, StaticString, UInt) -> Void

private let NSObjectEqualsFunction:MCNSObjectEqualsFunction = { (expected, actual, message, file, line) in
    XCTAssertEqual(expected, actual, message, file: file, line: line)
}

typealias MCOptionalStringEqualsFunction = (String?, String?, String, StaticString, UInt) -> Void

private let optionalStringEqualsFunction: MCOptionalStringEqualsFunction = { (expected, actual, message, file, line) in
    XCTAssertEqual(expected, actual, message, file: file, line: line)
}



public func MCAssertReflectiveEqual<T>(_ expected: T, _ actual: T,
                       file: StaticString = #file,
                       line: UInt = #line,
                       typeCheckFunction:MCTypeCheckFunction = typeCheckFunction,
                       countCheckFunction:MCCountCheckFunction = countCheckFunction,
                       nsObjectCheckFunction:MCNSObjectEqualsFunction = NSObjectEqualsFunction,
                       optionalStringEqualsFunction:MCOptionalStringEqualsFunction = optionalStringEqualsFunction) {
    var expectedVisited:[AnyObject] = []
    var actualVisited:[AnyObject] = []
    
    MCAssertReflectiveEqual(expected, actual, expectedVisited: &expectedVisited, actualVisited: &actualVisited, file: file, line: line, typeCheckFunction: typeCheckFunction, countCheckFunction: countCheckFunction, nsObjectCheckFunction: nsObjectCheckFunction, optionalStringEqualsFunction: optionalStringEqualsFunction)
}

private func MCAssertReflectiveEqual(_ expected: Any,
                               _ actual: Any,
                               expectedVisited: inout [AnyObject],
                               actualVisited: inout [AnyObject],
                               file: StaticString,
                               line: UInt,
                               typeCheckFunction:MCTypeCheckFunction = typeCheckFunction,
                               countCheckFunction:MCCountCheckFunction = countCheckFunction,
                               nsObjectCheckFunction:MCNSObjectEqualsFunction = NSObjectEqualsFunction,
                               optionalStringEqualsFunction:MCOptionalStringEqualsFunction = optionalStringEqualsFunction) {
    let expectedMirror = Mirror(reflecting: expected)
    let actualMirror = Mirror(reflecting: actual)
    typeCheckFunction(expectedMirror.subjectType, actualMirror.subjectType, "Types not the same expected: \(expectedMirror.subjectType) got: \(actualMirror.subjectType)", file, line)
    
    var expectedChildren = expectedMirror.children
    var actualChildren = actualMirror.children
    countCheckFunction(expectedChildren.count, actualChildren.count, "\(expected) has \(expectedChildren.count) child fields. \(actual) has \(actualChildren.count)", file, line)
    
    let x = expected as AnyObject
    let a = actual as AnyObject
    if(x === a) {
        return
    }
    
    if(expectedChildren.count == actualChildren.count) {
        if(expectedChildren.count == 0) {
            if let x = expected as? NSObject, let a = actual as? NSObject {
                nsObjectCheckFunction(x, a, "\(x) not equal to \(a)", file, line)
            } else if(expectedMirror.displayStyle == actualMirror.displayStyle &&
                (expectedMirror.displayStyle == .struct || expectedMirror.displayStyle == .class)) {
                return
            }
            else if(expectedMirror.description.contains("->")) {
                print("ignoring closures")
            }
            else {
                XCTFail("cannot compare \(expected), \(actual)", file: file, line: line)
            }
        } else {
            while(!expectedChildren.isEmpty) {
                let expectedChild = expectedChildren.popFirst()!
                let actualChild = actualChildren.popFirst()!
                let indexOfExpectedChildIfAlreadyVisited = expectedVisited.index(where: { (obj) -> Bool in
                    return obj === expectedChild.value as AnyObject
                })
                let indexOfActualChildIfAlreadyVisited = actualVisited.index(where: { (obj) -> Bool in
                    return obj === actualChild.value as AnyObject
                })
                
                if(indexOfActualChildIfAlreadyVisited != nil || indexOfExpectedChildIfAlreadyVisited != nil)
                {
                    if(indexOfActualChildIfAlreadyVisited == indexOfExpectedChildIfAlreadyVisited && indexOfExpectedChildIfAlreadyVisited != -1) {
                        print("\(expected) and \(actual) are matching looping objects")
                        return
                    } else {
                        XCTFail("failed to compare \(expected) and \(actual) looping objects")
                    }
                }
                
                optionalStringEqualsFunction(expectedChild.label, actualChild.label, "\(expectedChild.label) not equal to \(actualChild.label)", file, line)
                expectedVisited.append(expectedChild.value as AnyObject)
                actualVisited.append(actualChild.value as AnyObject)
                MCAssertReflectiveEqual(expectedChild.value, actualChild.value,
                                  expectedVisited: &expectedVisited, actualVisited: &actualVisited,
                                  file: file, line: line,
                                  typeCheckFunction: typeCheckFunction, countCheckFunction: countCheckFunction, nsObjectCheckFunction: nsObjectCheckFunction, optionalStringEqualsFunction: optionalStringEqualsFunction)
                _ = expectedVisited.popLast()
                _ = actualVisited.popLast()
            }
        }
    }
}
