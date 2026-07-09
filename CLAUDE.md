# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MCAssertReflectiveEqual is a Swift testing library that provides reflective equality assertions for XCTest. It allows testing equality of Swift objects without requiring them to conform to Equatable, using reflection instead.

## Architecture

The library consists of two main Swift files:

- `MCAssertReflectiveEqual/Classes/MCAssertReflectiveEqual.swift` - Core reflection-based equality implementation
- `MCAssertReflectiveEqual/Classes/Matchers.swift` - Custom matcher utilities (currently contains `matchDoubles` for Double comparison with accuracy)

Key components:
- `MCAssertReflectiveEqual<T>()` - Main assertion function that compares any two Swift objects
- `Matcher` class - Allows custom comparison logic for specific types
- `matcherFor<T>()` - Factory function for creating custom matchers
- Loop detection system using `ObjectIdentifier` to handle circular references

## Development Commands

### Testing
```bash
# Run tests using Swift Package Manager
swift test

# Run tests using Xcode
cd Example
xcodebuild test -workspace MCAssertReflectiveEqual.xcworkspace -scheme MCAssertReflectiveEqual_Tests -destination 'platform=iOS Simulator,name=iPhone 14'

# Or run tests in Xcode IDE using the MCAssertReflectiveEqual_Tests scheme
```

### Linting
```bash
# Validate podspec
pod lib lint MCAssertReflectiveEqual.podspec
```

### Build
```bash
# Build using Swift Package Manager
swift build

# Build the library using Xcode
cd Example
xcodebuild build -workspace MCAssertReflectiveEqual.xcworkspace -scheme MCAssertReflectiveEqual
```

## Project Structure

- `MCAssertReflectiveEqual/Classes/` - Library source code
- `Tests/` - Swift Package Manager test files
- `Example/` - Xcode workspace and project for development/testing
- `Example/Tests/` - Unit tests demonstrating library usage
- `Package.swift` - Swift Package Manager manifest
- `MCAssertReflectiveEqual.podspec` - CocoaPods specification

## Testing Framework

The project uses XCTest for testing. Test files are located in `Example/Tests/`:
- `MCAssertReflectiveEqualTest.swift` - Main test cases
- `MatchersTest.swift` - Custom matcher tests
- `Tester.swift` - Test utilities

## Package Manager Integration

### Swift Package Manager
The library supports Swift Package Manager with `Package.swift`. It targets iOS 9.0+, macOS 10.10+, tvOS 9.0+, and watchOS 2.0+. Add as a dependency:

```swift
dependencies: [
    .package(url: "https://github.com/motocodeltd/MCAssertReflectiveEqual.git", from: "0.0.7")
]
```

### CocoaPods
This is also available as a CocoaPods library. The podspec is configured for iOS 8.0+ and uses XCTest framework. The library is designed to be included only in test targets.