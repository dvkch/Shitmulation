//
//  People.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

@objcMembers
final class Person: NSObject {
    
    // MARK: Init
    init(traitsCount: Int) {
        super.init()
        traits.reserveCapacity(traitsCount)
    }
    
    // MARK: Properties
    fileprivate(set) var unique: Bool = false
    private var traits: Data = Data()
    
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
extension Person {
    fileprivate static var currentTrait: Int = 1
    private func currentTraits() -> Data {
        traits.subarray(maxCount: Person.currentTrait)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        let t1 = currentTraits()
        let t2 = (object as? Person)?.currentTraits()
        return t1 == t2
    }
    
    override var hash: Int {
        currentTraits().hashValue
    }
}

// MARK: Couting unique
extension Array where Element == Person {
    func countUniqueItems(upTo trait: Int) -> Int {
        Person.currentTrait = trait

        let set = NSCountedSet(array: self)

        let uniquePeople = set.allObjects.filter { set.count(for: $0) == 1 }
        uniquePeople.forEach { ($0 as! Person).unique = true }

        return uniquePeople.count
    }
}
