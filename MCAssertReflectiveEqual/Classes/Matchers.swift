//
// Created by Stefanos Zachariadis first name at last name dot net
// Copyright (c) 2017 motocode ltd. All rights reserved. MIT license
//

public func matchDoubles(withAccuracy accuracy: Double) -> Matcher {
    return matcherFor(Double.self, { (expected, actual) in
        return abs(expected - actual) < accuracy
    })
}