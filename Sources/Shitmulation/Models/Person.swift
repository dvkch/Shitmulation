//
//  Person.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation
import ShitmulationC

public struct Person {
    public init(traits: Traits = .init()) {
        self.traits = traits
    }
    
    // MARK: Properties
    public typealias Traits = UInt128
    public private(set) var traits: Traits = .init(lo: 0, hi: 0)

    static var traitsSize: Int {
        return MemoryLayout<Traits>.size
    }
    
    public mutating func addTraits(_ branch: Tree.Branch.RawValue, treeIndex: Int) {
        let firstBitPosition = (Person.traitsSize * 8) - (treeIndex + 1) * Tree.Branch.length
        traits = traits | (UInt128(UInt64(branch)) << UInt32(firstBitPosition))
    }
    
    public static func mask(forTraitAt traits: Int) -> Traits {
        return UInt128.masking(
            fromBit: (Person.traitsSize * 8) - traits,
            toBit:   (Person.traitsSize * 8)
        )
    }
}

extension Person: Comparable, Hashable {
    public static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.traits == rhs.traits
    }

    public static func <(lhs: Person, rhs: Person) -> Bool {
        return lhs.traits < rhs.traits
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(traits.hi)
        hasher.combine(traits.lo)
    }
}
