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
        for i in 0..<items.count {
            counts[items[i], default: 0] += 1
        }
    }
    
    // MARK: Properties
    private var counts: [T: Int] = [:]
    
    // MARK: Access
    var uniqueItems: [T] {
        return Array(counts.filter { $0.value == 1 }.keys)
    }
}
