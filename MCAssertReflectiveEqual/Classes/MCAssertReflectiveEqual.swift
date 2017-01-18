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

//todo: better error messages

public func MCAssertReflectiveEqual<T>(_ expected: T, _ actual: T,
                       file: StaticString = #file,
                       line: UInt = #line,
                       typeCheckFunction:MCTypeCheckFunction = typeCheckFunction,
                       countCheckFunction:MCCountCheckFunction = countCheckFunction,
                       nsObjectCheckFunction:MCNSObjectEqualsFunction = NSObjectEqualsFunction,
                       optionalStringEqualsFunction:MCOptionalStringEqualsFunction = optionalStringEqualsFunction) {
    var expectedVisited:[AnyObject] = []
    var actualVisited:[AnyObject] = []
    
    MCAssertReflectiveEqual(expected, actual, expectedVisited: &expectedVisited, actualVisited: &actualVisited,
                            expectedDescription: "", actualDescription: "", depth: 0,
                            file: file, line: line, typeCheckFunction: typeCheckFunction, countCheckFunction: countCheckFunction, nsObjectCheckFunction: nsObjectCheckFunction, optionalStringEqualsFunction: optionalStringEqualsFunction)
}

private func appendItemDescription(_ item: Any, previousDescription: String, depth: Int) -> String {
    let tabs = (0..<depth).map({ _ in
        return "\t"
    }).reduce("") { (old, new) -> String in
        return old.appending(new)
    }
    
    let initialNewLine = depth == 0 ? "" : "\n"
    
    return "\(initialNewLine)\(tabs) \(item)"
}

private func MCAssertReflectiveEqual(_ expected: Any,
                               _ actual: Any,
                               expectedVisited: inout [AnyObject],
                               actualVisited: inout [AnyObject],
                               expectedDescription: String,
                               actualDescription: String,
                               depth: Int,
                               file: StaticString,
                               line: UInt,
                               typeCheckFunction:MCTypeCheckFunction = typeCheckFunction,
                               countCheckFunction:MCCountCheckFunction = countCheckFunction,
                               nsObjectCheckFunction:MCNSObjectEqualsFunction = NSObjectEqualsFunction,
                               optionalStringEqualsFunction:MCOptionalStringEqualsFunction = optionalStringEqualsFunction) {
    
    let expectedDescription = appendItemDescription(expected, previousDescription: expectedDescription, depth: depth)
    let actualDescription = appendItemDescription(actual, previousDescription: actualDescription, depth: depth)
    let expectedMirror = Mirror(reflecting: expected)
    let actualMirror = Mirror(reflecting: actual)
    typeCheckFunction(expectedMirror.subjectType, actualMirror.subjectType, "Types not the same expected: \(expectedDescription) got: \(actualDescription)", file, line)
    
    var expectedChildren = expectedMirror.children
    var actualChildren = actualMirror.children
    countCheckFunction(expectedChildren.count, actualChildren.count, "\(expectedDescription) has \(expectedChildren.count) child fields. \(actualDescription) has \(actualChildren.count)", file, line)
    
    let x = expected as AnyObject
    let a = actual as AnyObject
    if(x === a) {
        return
    }
    
    if(expectedChildren.count == actualChildren.count) {
        if(expectedChildren.count == 0) {
            if let x = expected as? NSObject, let a = actual as? NSObject {
                nsObjectCheckFunction(x, a, "\(expectedDescription) not equal to \(actualDescription)", file, line)
            } else if(expectedMirror.displayStyle == actualMirror.displayStyle &&
                (expectedMirror.displayStyle == .struct || expectedMirror.displayStyle == .class)) {
                return
            } else if(expectedMirror.displayStyle == actualMirror.displayStyle && expectedMirror.displayStyle == .enum) {
                optionalStringEqualsFunction(x.description, a.description, "\(expectedDescription) not equal to \(actualDescription)", file, line)
            }
            else if(expectedMirror.description.contains("->")) {
                print("ignoring closures")
            }
            else {
                XCTFail("cannot compare \(expectedDescription), \(actualDescription)", file: file, line: line)
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
                        print("\(expectedDescription) and \(actualDescription) are matching looping objects")
                        return
                    } else {
                        XCTFail("failed to compare \(expectedDescription) and \(actualDescription) looping objects")
                    }
                }
                
                optionalStringEqualsFunction(expectedChild.label, actualChild.label, "\(expectedDescription): \(expectedChild.label) not equal to \(actualDescription): \(actualChild.label)", file, line)
                expectedVisited.append(expectedChild.value as AnyObject)
                actualVisited.append(actualChild.value as AnyObject)
                MCAssertReflectiveEqual(expectedChild.value, actualChild.value,
                                  expectedVisited: &expectedVisited, actualVisited: &actualVisited,
                                  expectedDescription: expectedDescription,
                                  actualDescription: actualDescription,
                                  depth: depth + 1,
                                  file: file, line: line,
                                  typeCheckFunction: typeCheckFunction, countCheckFunction: countCheckFunction, nsObjectCheckFunction: nsObjectCheckFunction, optionalStringEqualsFunction: optionalStringEqualsFunction)
                _ = expectedVisited.popLast()
                _ = actualVisited.popLast()
            }
        }
    }
}
