//
//  Counter.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

class Counter<T: Hashable> {

    // MARK: Init
    init(items: ContiguousArray<T>) {
        for item in items {
            counts[item, default: 0] += 1
        }
    }
    
    static func merge(_ counters: [Counter<T>]) -> Counter<T> {
        let merged = Counter(items: [])
        guard counters.count > 0 else { return merged }

        let sorted = counters.sorted(by: { $0.counts.count > $1.counts.count })
        merged.counts = sorted.first!.counts
        sorted.dropFirst().forEach { otherCounter in
            merged.merge(with: otherCounter)
        }
        return merged
    }
    
    // MARK: Properties
    private var counts: [T: Int] = [:]
    
    // MARK: Access
    var uniqueItems: [T] {
        return Array(counts.filter { $0.value == 1 }.keys)
    }
    
    func merge(with counter: Counter<T>) {
        counter.counts.forEach { key, value in
            counts[key, default: 0] += value
        }
    }
}
