# MCAssertReflectiveEqual

[![Version](https://img.shields.io/cocoapods/v/MCAssertReflectiveEqual.svg?style=flat)](http://cocoapods.org/pods/MCAssertReflectiveEqual)
[![License](https://img.shields.io/cocoapods/l/MCAssertReflectiveEqual.svg?style=flat)](http://cocoapods.org/pods/MCAssertReflectiveEqual)
[![Platform](https://img.shields.io/cocoapods/p/MCAssertReflectiveEqual.svg?style=flat)](http://cocoapods.org/pods/MCAssertReflectiveEqual)

MCAssertReflectiveEqual is a function that can be used to write swift test assertions. It works very similarly to XCTAssertEqual
but doesn't require Equatable items and uses reflection instead. Therefore you don't need to write 
neither equals functions that your production code does not require, and you don't need to assert multiple
 individual fields. 
 
 MCAssertReflectiveEquals works on primitives, strucs, classes and enums. It gives you a nice error message
 when items do not match. It deeply compares items and handles recursive loops (A -> B -> A, 
 where A & B re objects and -> is a references)

## Example
```swift
import MCAssertReflectiveEqual

private class ClassWithVal {
    var val: Int
        
    init(_ val: Int) {
        self.val = val
    }
}

func testAreEqual() {
    let expected = ClassWithVal(1)
    let actual = ClassWithVal(2)
    
    MCAssertReflectiveEqual(expected, actual)
}

```

## Installation

MCAssertReflectiveEqual is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile. It really only makes sense to reference it in your test target:

```ruby
pod "MCAssertReflectiveEqual"
```

## Author

Stefanos Zachariadis, first name at last name dot net, https://moto.co.de

## License

MCAssertReflectiveEqual is available under the MIT license. See the LICENSE file for more info.
