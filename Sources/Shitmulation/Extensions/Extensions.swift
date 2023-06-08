//
//  Extensions.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

extension Bool {
    var int: Int {
        return self ? 1 : 0
    }
}

extension Collection {
    public func subarray(maxCount: Int) -> Self.SubSequence {
        let max = Swift.min(maxCount, count)
        let maxIndex = index(startIndex, offsetBy: max)
        return self[startIndex..<maxIndex]
    }
}

extension Collection where Element: FixedWidthInteger {
    public func sum() -> Element {
        return reduce(0, +)
    }
}

extension Int {
    func bound(min: Int?, max: Int?) -> Int {
        if let max, self > max { return max }
        if let min, self < min { return min }
        return self
    }
}
