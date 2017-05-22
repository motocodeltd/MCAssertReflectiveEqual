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
 where A & B are objects and -> is a references). It just makes tests easier.

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

## Custom Matchers

Sometimes simple reflective matching is not good enough. Imagine a complex data structure that contains a geographical coordinate, a CLLocation. We may not be interested that our expected value is identical to the value produced by the system under test, only that they are close enough. Here's how we go about that:

```swift
class FavouriteLocation {
    let user: String
    let location: CLLocation
    
    init(user: String, location: CLLocation) {
        self.user = user
        self.location = location
    }
}
    
let camdenTown = CLLocation(latitude: 51.5390, longitude: 0.1426)
    
let closeToCamdenTown = CLLocation(latitude: 51.5391, longitude: 0.1427)
    
let matcher = matcherFor(CLLocation.self, { (expected, actual) in
                    return expected.distance(from: actual) < 100 //close enough
              }) 
    
MCAssertReflectiveEqual(FavouriteLocation(user: "bob", location: closeToCamdenTown), 
                        FavouriteLocation(user: "bob", location: camdenTown), 
                        matchers: [matcher])        
```

### Provided matchers
For convenience, a matcher for doubles with defined accuracy is provided. Instantiate it with
 
 ```swift
 let accuracy = 0.001
 
 let matcher = matchDoubles(withAccuracy: accuracy)
 
 let expected = 0.01
 let actual = 0.01
 
 MCAssertReflectiveEqual(expected, actual) //fails
 
 MCAssertReflectiveEqual(expected, actual, matchers: [matcher]) //passes
 

```

More examples in [MCAssertReflectiveEqualTest.swift](Example/Tests/MCAssertReflectiveEqualTest.swift)

## Development
The development of MCAssertReflectiveEqual is described [here](https://moto.co.de/blog/writing_reflective_test_assertions_with_swift.html)

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
