//
//  Person.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

struct Person {
    
    // MARK: Properties
    typealias Traits = UInt128
    private(set) var traits: Traits = .init(lo: 0, hi: 0)

    static var traitsSize: Int {
        return MemoryLayout<Traits>.size
    }
    
    mutating func addTraits(_ branch: Tree.Branch.RawValue, treeIndex: Int) {
        let firstBitPosition = (Person.traitsSize * 8) - (treeIndex + 1) * Tree.Branch.length
        traits = traits | (UInt128(UInt64(branch)) << UInt32(firstBitPosition))
    }
    
    static func mask(forTraitAt traits: Int) -> Traits {
        return UInt128.masking(
            fromBit: (Person.traitsSize * 8) - traits,
            toBit:   (Person.traitsSize * 8)
        )
    }
}

extension Person: Comparable {
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.traits == rhs.traits
    }

    static func <(lhs: Person, rhs: Person) -> Bool {
        return lhs.traits < rhs.traits
    }
}
