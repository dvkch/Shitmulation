//
//  People.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

final class Person {
    
    // MARK: Init
    init(traitsCount: Int) {
        traits.reserveCapacity(traitsCount)
    }
    
    // MARK: Properties
    fileprivate(set) var unique: Bool = false
    private var traits: Data = Data()
    fileprivate var currentTrait: Int = 1

    func addTraits(_ branch: Tree.Branch) {
        traits.append(contentsOf: branch.traits.map(\.char))
    }
}

// MARK: Export
extension Person {
    var fileLine: Data {
        return traits + [0x0A]
    }
}

// MARK: Equality
extension Person: Hashable {
    private func currentTraits() -> Data {
        traits.subarray(maxCount: currentTrait)
    }
    
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.currentTraits() == rhs.currentTraits()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(currentTraits())
    }
}

// MARK: Couting unique
extension ContiguousArray where Element == Person {
    func countUniqueItems(upTo trait: Int, uniquesAtPreviousTrait: Int, markUniques: Bool) -> Int {
        let (count, duration) = benchmark {
            forEach { $0.currentTrait = trait }
            
            let set = Counter(items: self)
            
            let uniquePeople = set.uniqueItems
            if markUniques {
                uniquePeople.markUnique()
            }
            
            Memory.updatePeakMemoryUsage()
            
            return uniquePeople.count + uniquesAtPreviousTrait
        }
        log(" - unique at \(trait): \(count.string) (\(duration.durationString))")
        return count
    }
}

extension Collection where Element == Person {
    func markUnique() {
        forEach { $0.unique = true }
    }
    
    func unmarkUnique() {
        forEach { $0.unique = false }
    }
}
