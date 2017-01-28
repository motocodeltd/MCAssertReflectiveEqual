import Foundation
import XCTest

typealias MCNSObjectEqualsFunction = (NSObject, NSObject, String, StaticString, UInt) -> Void

private let NSObjectEqualsFunction:MCNSObjectEqualsFunction = { (expected, actual, message, file, line) in
    XCTAssertEqual(expected, actual, message, file: file, line: line)
}

typealias MCOptionalStringEqualsFunction = (String?, String?, String, StaticString, UInt) -> Void

private let optionalStringEqualsFunction: MCOptionalStringEqualsFunction = { (expected, actual, message, file, line) in
    XCTAssertEqual(expected, actual, message, file: file, line: line)
}

typealias MCFailFunction = (String, StaticString, UInt) -> Void

private let failFunction: MCFailFunction = { (message, file, line) in
    XCTFail(message, file: file, line: line)
}

public func MCAssertReflectiveEqual<T>(_ expected: T, _ actual: T,
                                    file: StaticString = #file,
                                    line: UInt = #line,
                                    nsObjectCheckFunction: MCNSObjectEqualsFunction = NSObjectEqualsFunction,
                                    optionalStringEqualsFunction: MCOptionalStringEqualsFunction = optionalStringEqualsFunction,
                                    failFunction: MCFailFunction = failFunction) {
    var expectedVisited:[AnyObject] = []
    var actualVisited:[AnyObject] = []
    
    MCAssertReflectiveEqual(expected, actual, expectedVisited: &expectedVisited, actualVisited: &actualVisited,
                            expectedDescription: "", actualDescription: "", depth: 0,
                            file: file, line: line,
                            nsObjectCheckFunction: nsObjectCheckFunction,
                            optionalStringEqualsFunction: optionalStringEqualsFunction,
                            failFunction: failFunction)
}

private func appendItemDescription(_ item: Any, previousDescription: String, depth: Int) -> String {
    let tabs = (0...depth).map({ _ in
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
                                     nsObjectCheckFunction: MCNSObjectEqualsFunction,
                                     optionalStringEqualsFunction: MCOptionalStringEqualsFunction,
                                     failFunction: MCFailFunction) {
    
    let expectedDescription = appendItemDescription(expected, previousDescription: expectedDescription, depth: depth)
    let actualDescription = appendItemDescription(actual, previousDescription: actualDescription, depth: depth)
    let expectedMirror = Mirror(reflecting: expected)
    let actualMirror = Mirror(reflecting: actual)
    
    guard expectedMirror.subjectType == actualMirror.subjectType else {
        failFunction( "Types not the same expected: \(expectedDescription) is a \(expectedMirror.subjectType) \ngot:\n\(actualDescription) which is a \(actualMirror.subjectType)", file, line)
        return
    }
    
    let expectedAsObject = expected as AnyObject
    let actualAsObject = actual as AnyObject
    
    if(expectedAsObject === actualAsObject) {
        return
    }
    
    var expectedChildren = expectedMirror.children
    var actualChildren = actualMirror.children
    
    guard expectedChildren.count == actualChildren.count else {
        failFunction("\(expectedDescription) has \(expectedChildren.count) but \(actualDescription) has \(actualChildren.count)", file, line)
        return
    }
    
    if(expectedChildren.count == 0) {
        if let expectedNsObj = expected as? NSObject, let actualNsObj = actual as? NSObject {
            nsObjectCheckFunction(expectedNsObj, actualNsObj, "\(expectedDescription)\nnot equal to\n\(actualDescription)", file, line)
        } else if(expectedMirror.displayStyle == .struct || expectedMirror.displayStyle == .class) {
            return
        } else if(expectedMirror.displayStyle == .enum) {
            optionalStringEqualsFunction(String(describing: expected), String(describing: actual), "\(expectedDescription)\nnot equal to\n\(actualDescription)", file, line)
        }
        else if(expectedMirror.description.contains("->")) {
            print("ignoring closures in \n\(expectedDescription)\nand\n\(actualDescription)")
        }
        else {
            failFunction("cannot compare\n\(expectedDescription)\n\(actualDescription)", file, line)
        }
    } else {
        while(!expectedChildren.isEmpty) {
            let expectedChild = expectedChildren.popFirst()!
            let actualChild = actualChildren.popFirst()!
            
            let canHoldChildrenByReference = expectedMirror.displayStyle == .class

            if(canHoldChildrenByReference) {
                let expectedChildAsObject = expectedChild.value as AnyObject
                let actualChildAsObject = actualChild.value as AnyObject
                let indexOfExpectedChildIfAlreadyVisited = expectedVisited.index(where: { (obj) -> Bool in
                    return obj === expectedChildAsObject
                })
                let indexOfActualChildIfAlreadyVisited = actualVisited.index(where: { (obj) -> Bool in
                    return obj === actualChildAsObject
                })
                
                if(indexOfActualChildIfAlreadyVisited != nil || indexOfExpectedChildIfAlreadyVisited != nil) {
                    if(indexOfActualChildIfAlreadyVisited == indexOfExpectedChildIfAlreadyVisited && indexOfExpectedChildIfAlreadyVisited != nil) {
                        print("\(expectedDescription)\nand\(actualDescription)\n are matching looping objects")
                        return
                    } else {
                        failFunction("failed to compare\n\(expectedDescription)\n and \n\(actualDescription)\nlooping objects", file, line)
                    }
                }
                
                expectedVisited.append(expectedChildAsObject)
                actualVisited.append(actualChildAsObject)
            }
            
            
            optionalStringEqualsFunction(expectedChild.label, actualChild.label, "\(expectedDescription): \(expectedChild.label) not equal to \n\(actualDescription): \(actualChild.label)", file, line)
            
            MCAssertReflectiveEqual(expectedChild.value, actualChild.value,
                                    expectedVisited: &expectedVisited, actualVisited: &actualVisited,
                                    expectedDescription: expectedDescription,
                                    actualDescription: actualDescription,
                                    depth: depth + 1,
                                    file: file, line: line,
                                    nsObjectCheckFunction: nsObjectCheckFunction,
                                    optionalStringEqualsFunction: optionalStringEqualsFunction,
                                    failFunction: failFunction)
            if(canHoldChildrenByReference) {
                _ = expectedVisited.popLast()
                _ = actualVisited.popLast()
            }
            
        }
    }
}
