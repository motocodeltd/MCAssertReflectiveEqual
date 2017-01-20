# MCAssertReflectiveEqual

[![CI Status](http://img.shields.io/travis/motocodeltd/MCAssertReflectiveEqual.svg?style=flat)](https://travis-ci.org/motocoteltd/MCAssertReflectiveEqual)
[![Version](https://img.shields.io/cocoapods/v/MCAssertReflectiveEqual.svg?style=flat)](http://cocoapods.org/pods/MCAssertReflectiveEqual)
[![License](https://img.shields.io/cocoapods/l/MCAssertReflectiveEqual.svg?style=flat)](http://cocoapods.org/pods/MCAssertReflectiveEqual)
[![Platform](https://img.shields.io/cocoapods/p/MCAssertReflectiveEqual.svg?style=flat)](http://cocoapods.org/pods/MCAssertReflectiveEqual)

MCAssertReflectiveEqual is a function that can be used to write swift test assertions. It works very similarly to XCTest's XCTAssertEqual
but doesn't require Equatable items and uses reflection instead. 
Therefore you don't need to write 
neither equals functions that your production code does not require, nor assert multiple
 individual fields making tests a chore. 
 
 MCAssertReflectiveEquals works on primitives, structs, classes and enums. It gives you a nice error message
 when items do not match. It deeply compares items and handles recursive loops (A -> B -> A, 
 where A & B are objects and -> is a references). It makes tests easier.

## Example

```swift
import XCTest
import MCAssertReflectiveEqual

private class ClassWithVal {
    var val: Int
        
    init(_ val: Int) {
        self.val = val
    }
}

class ClassWithValTest : XCTestCase {

    func testAreEqual() {
        let expected = ClassWithVal(1)
        let actual = ClassWithVal(1)
    
        MCAssertReflectiveEqual(expected, actual) 
        MCAssertReflectiveEqual([expected], [actual])
    
        MCAssertReflectiveEqual(expected, ClassWithVal(5)) //fails
    }

}

```

More examples in [MCAssertReflectiveEqualTest.swift](blob/master/Example/Tests/MCAssertReflectiveEqualTest.swift)

## Installation

MCAssertReflectiveEqual is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile. It really only makes sense to reference it in your test target.

```ruby
use_frameworks!

pod "MCAssertReflectiveEqual"
```

It's implemented in a single file so if you do not want to use CocoaPods it should be easy to integrate with your project.

## Author

Stefanos Zachariadis, motocode ltd, first name at last name dot net, https://moto.co.de

## License

MCAssertReflectiveEqual is available under the MIT license. See the LICENSE file for more info.
