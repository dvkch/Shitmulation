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
    
    typealias Traits = (hi: UInt64, lo: UInt64)
    private(set) var traits: Traits = (0, 0)
    fileprivate var traitsMask: Traits = (0xFFFFFFFF, 0xFFFFFFFF)

    static var traitsSize: Int {
        return MemoryLayout<Traits>.size
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
    
    static func mask(forTraitAt trait: Int, reverse: Bool = false) -> Traits {
        if reverse {
            return (
                hi: UInt64.masking(from: (64 - trait).bound(min: 0, max: 64), to: 64),
                lo: UInt64.masking(from: (128 - trait).bound(min: 0, max: 64), to: 64)
            )
        }
        else {
            // TODO: validate
            return (
                hi: UInt64.masking(from: 0, to: (trait - 64).bound(min: 0, max: 64)),
                lo: UInt64.masking(from: 0, to: trait.bound(min: 0, max: 64))
            )
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
                hi: UInt64.masking(from: 0, to: (i - 64).bound(min: 0, max: 64)),
                lo: UInt64.masking(from: 0, to: i.bound(min: 0, max: 64))
            )
            print(traitsMask.hi.bin, terminator: "")
            print(traitsMask.lo.bin)
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
extension Collection where Element == Person, Index == Int {
    func writeToFile(url: URL, emptyFirst: Bool) throws {
        if emptyFirst || !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: Data())
        }
        
        let file = try FileHandle(forUpdating: url)
        try file.seekToEnd()

        defer { try? file.close() }
        
        let strideSize = 100_000 // it's faster to write big chunks at a time then small chunks very frequently
        try stride(from: 0, to: count, by: strideSize).forEach({ startIndex in
            let endIndex = (startIndex + strideSize).bound(min: 0, max: self.count)
            var data = Data()
            data.reserveCapacity(strideSize * Person.traitsSize)
            
            self[startIndex..<endIndex].forEach { p in
                p.write(into: &data)
            }
            try file.write(contentsOf: data)
        })
    }
}
