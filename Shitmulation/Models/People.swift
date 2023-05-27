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
    private(set) var traits: (hi: UInt64, lo: UInt64) = (0, 0)
    fileprivate var traitsMask: (hi: UInt64, lo: UInt64) = (0xFFFFFFFF, 0xFFFFFFFF)

    static var lineSize: Int {
        return MemoryLayout<UInt64>.size * 2
    }
    
    func addTraits(_ branch: Tree.Branch.RawValue, position: Int) {
        // TODO: rewrite in a single C function maybe?
        let positionsPer64 = 64 - (64 % Tree.Branch.length)
        if position < positionsPer64 {
            traits.lo = traits.lo | (UInt64(branch) &<< (position))
        }
        else {
            traits.hi = traits.hi | (UInt64(branch) &<< (position - positionsPer64))
        }
    }
    
    func write(into data: inout Data) {
        // faster than a simple '+'
        data.append(traits.hi.data)
        data.append(traits.lo.data)
    }
}

extension Person {
    // TODO: add actual tests ?
    static func test() {
        let p = Person()
        
        for i in 0..<42 {
            p.addTraits(Tree.Branch.e.rawValue, position: i * 3)
            
            var data = Data()
            p.write(into: &data)
            data.enumerated().forEach { i, byte in
                print(byte.bin, terminator: i == data.count - 1 ? "\n" : "")
            }
        }
        
        print("-------")
        
        for i in 0..<128 {
            let traitsMask = (
                UInt64.masking(from: 0, to: i.bound(min: 0, max: 64)),
                UInt64.masking(from: 0, to: (i - 64).bound(min: 0, max: 64))
            )
            print(traitsMask.0.bin, terminator: " ")
            print(traitsMask.1.bin)
        }
    }
}

// MARK: Equality
extension Person: Hashable, Comparable {
    private func currentTraits() -> (UInt64, UInt64) {
        return (traits.0 & traitsMask.0, traits.1 & traitsMask.1)
    }
    
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.currentTraits() == rhs.currentTraits()
    }

    static func <(lhs: Person, rhs: Person) -> Bool {
        return lhs.currentTraits() < rhs.currentTraits()
    }

    func hash(into hasher: inout Hasher) {
        let values = currentTraits()
        hasher.combine(values.0)
        hasher.combine(values.1)
    }
}

// MARK: Couting unique
extension ContiguousArray where Element == Person {
    func countUniqueItems(upTo trait: Int, uniquesAtPreviousTrait: Int, markUniques: Bool) -> Int {
        let (count, duration) = benchmark {
            let traitsMask = (
                UInt64.masking(from: 0, to: trait.bound(min: 0, max: 64)),
                UInt64.masking(from: 0, to: (trait - 64).bound(min: 0, max: 64))
            )
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

extension Collection where Element == Person, Index == Int {
    func markUnique() {
        forEach { $0.unique = true }
    }
    
    func unmarkUnique() {
        forEach { $0.unique = false }
    }
    
    func writeToFile(url: URL) throws {
        FileManager.default.createFile(atPath: url.path, contents: Data())
        let file = try FileHandle(forWritingTo: url)
        defer { try? file.close() }
        
        let strideSize = 100_000 // it's faster to write big chunks at a time then small chunks very frequently
        try stride(from: 0, to: count, by: strideSize).forEach({ startIndex in
            let endIndex = (startIndex + strideSize).bound(min: 0, max: self.count)
            var data = Data()
            data.reserveCapacity(strideSize * Person.lineSize)
            
            self[startIndex..<endIndex].forEach { p in
                p.write(into: &data)
            }
            try file.write(contentsOf: data)
        })
    }
}
