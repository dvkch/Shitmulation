//
//  People.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

final class Person {
    
    // MARK: Properties
    fileprivate(set) var unique: Bool = false
    private(set) var traits: UInt64 = 0 // TODO: switch to bigger later on
    fileprivate var traitsMask: UInt64 = 0xFFFFFFFF

    func addTraits(_ branch: Tree.Branch.RawValue, position: Int) {
        // TODO: rewrite in a single C function maybe
        traits |= UInt64(branch) << (64 - Tree.Branch.length - position)
    }
}

extension Person {
    // TODO: add actual tests ?
    static func test() {
        let p = Person()

        p.addTraits(Tree.Branch.e.rawValue, position: 0)
        print(String(p.traits, radix: 2))

        p.addTraits(Tree.Branch.e.rawValue, position: 3)
        print(String(p.traits, radix: 2))
        
        p.traitsMask = .masking(from: 0, to: 1)
        print(String(p.currentTraits(), radix: 2))
        
        p.traitsMask = .masking(from: 0, to: 2)
        print(String(p.currentTraits(), radix: 2))
        
        p.traitsMask = .masking(from: 0, to: 3)
        print(String(p.currentTraits(), radix: 2))

    }
}

// MARK: Equality
extension Person: Hashable, Comparable {
    private func currentTraits() -> UInt64 {
        return traits & traitsMask
    }
    
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.currentTraits() == rhs.currentTraits()
    }

    static func <(lhs: Person, rhs: Person) -> Bool {
        return lhs.currentTraits() < rhs.currentTraits()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(currentTraits())
    }
}

// MARK: Couting unique
extension ContiguousArray where Element == Person {
    func countUniqueItems(upTo trait: Int, uniquesAtPreviousTrait: Int, markUniques: Bool) -> Int {
        let (count, duration) = benchmark {
            let traitsMask = UInt64.masking(from: 0, to: trait)
            forEach { $0.traitsMask = traitsMask }
            
            let parallelLevel = 4
            
            let counters = parallelize(count: parallelLevel, concurrency: parallelLevel) { i in
                let startOffset = self.count / parallelLevel * i
                let endOffset   = (self.count / parallelLevel * (i + 1)).bound(min: 0, max: self.count)
                let items = ContiguousArray(self[startOffset..<endOffset])
                return Counter(items: items)
            }
            let counter = Counter.merge(counters)
            
            let uniquePeople = counter.uniqueItems
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
