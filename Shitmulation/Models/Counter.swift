//
//  Counter.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

// This class will count the number of unique lines in a sorted file, considering only the first N bits for each chunk.
// To do so quickly over large files, we have an easy method that will read the file once, and count for multiple values of N.
class Counter {
    static func count(file: PopulationFile, forTraits: [Int]) -> Result {
        // TODO: make sure empty files are handled properly
        let counters = forTraits.map { Counter(comparedTraitsCount: $0) }

        let (_, duration) = benchmark {
            file.read { elements, _ in
                // for each number of traits to consider, count the number of unique lines in that chunk
                counters.forEach { $0.count(people: elements) }
            }
        }
        
        let counts = counters.map { ($0.comparedTraitsCount, $0.uniqueItems) }
        return Result(duration: duration, counts: counts)
    }
    
    // MARK: Init
    private init(comparedTraitsCount: Int) {
        self.comparedTraitsCount = comparedTraitsCount
        self.comparingMask = Person.mask(forTraitAt: comparedTraitsCount)
    }
    
    // MARK: Properties
    let comparedTraitsCount: Int
    let comparingMask: Person.Traits
    
    // MARK: Internal properties
    private(set) var uniqueItems: Int = 0
    
    // MARK: Counting
    private var prevLinesDiffer: Bool = false
    private var previousTraits: Person.Traits?
    private var currentTraits: Person.Traits = .init()
    private func count(people: [Person.Traits]) {
        if people.isEmpty {
            if prevLinesDiffer {
                uniqueItems += 1
            }
            return
        }
        
        for person in people {
            currentTraits = person & comparingMask

            let differ = previousTraits == nil || currentTraits != previousTraits!
            if prevLinesDiffer && differ {
                uniqueItems += 1
            }
            previousTraits = currentTraits
            prevLinesDiffer = differ
        }
    }
}
