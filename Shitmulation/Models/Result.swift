//
//  Result.swift
//  Shitmulation
//
//  Created by syan on 08/06/2023.
//

import Foundation

struct Result {
    init(duration: Double = 0, counts: [(Int, Int)] = []) {
        self.duration = duration
        counts.forEach { (traits, uniques) in
            self.counts[traits] = uniques
        }
    }

    private(set) var duration: Double = 0
    private(set) var counts: [Int: Int] = [:]
    
    static func += (lhs: inout Result, rhs: Result) {
        lhs.duration += rhs.duration
        rhs.counts.forEach { trait, count in
            lhs.counts[trait, default: 0] += count
        }
    }
}
