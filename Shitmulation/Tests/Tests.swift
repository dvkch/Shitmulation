//
//  Tests.swift
//  Shitmulation
//
//  Created by syan on 03/06/2023.
//

import Foundation

struct Tests {
    @inline(never)
    static func run(verbose: Bool) {
        let wasPrintingLogs = printLogs
        printLogs = verbose
        defer { printLogs = wasPrintingLogs }
        
        log("Running tests...")
        
        testStrataTrees()
        log("- trees generation and stratification works")

        testPeopleTraits()
        log("- can add traits to people from left to right")

        testMasking()
        log("- can generate a proper mask to help count from left to right")

        testExport()
        log("- can save people in a binary file")

        testSorting()
        log("- can sort the binary file")

        testCounting()
        log("- can read the binary file again to count uniqueness")

        log("")
    }
    
    @inline(never)
    private static func assert(_ equal: Bool, file: String = #file, line: Int = #line) {
        if !equal {
            fatalError("Test failed at \(file):\(line)")
        }
    }
    
    @inline(never)
    private static func testStrataTrees() {
        // create a tree and its strata trees
        let tree = Tree.generateValidTree(population: 10_000)
        let subtrees = tree.strataSubtrees(count: 4)
        
        // make sure each subtree kept its parent attributes, and also that
        // it is roughly equivalent to the original one divided by the amount
        // of subtrees
        for subtree in subtrees {
            assert(tree.indepA_B  == subtree.indepA_B)
            assert(tree.indepC_A  == subtree.indepC_A)
            assert(tree.indepC_B  == subtree.indepC_B)
            assert(tree.indepC_AB == subtree.indepC_AB)

            assert(abs(tree.a / 4 - subtree.a) < 10)
            assert(abs(tree.b / 4 - subtree.b) < 10)
            assert(abs(tree.c / 4 - subtree.c) < 10)
            assert(abs(tree.d / 4 - subtree.d) < 10)
            assert(abs(tree.e / 4 - subtree.e) < 10)
            assert(abs(tree.f / 4 - subtree.f) < 10)
            assert(abs(tree.g / 4 - subtree.g) < 10)
            assert(abs(tree.h / 4 - subtree.h) < 10)
            assert(abs(tree.a / 4 - subtree.a) < 10)
        }

        // make sure for each possible category, that the sum available in
        // all subtrees combined is equivalent to what was orignally
        // chosen for the original tree
        assert(tree.a == subtrees.map(\.a).sum())
        assert(tree.b == subtrees.map(\.b).sum())
        assert(tree.c == subtrees.map(\.c).sum())
        assert(tree.d == subtrees.map(\.d).sum())
        assert(tree.e == subtrees.map(\.e).sum())
        assert(tree.f == subtrees.map(\.f).sum())
        assert(tree.g == subtrees.map(\.g).sum())
        assert(tree.h == subtrees.map(\.h).sum())
        
        // make sure generating all branches is equivalent between using the main tree, or its subtrees
        assert(tree.generateBranches().sorted() == subtrees.map { $0.generateBranches() }.reduce([], +).sorted())
    }
    
    @inline(never)
    private static func testPeopleTraits() {
        var person = Person()
        
        person.addTraits(Tree.Branch.e.rawValue, treeIndex: 0)
        assert(person.traits.bin == "11100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        
        person.addTraits(Tree.Branch.e.rawValue, treeIndex: 1)
        assert(person.traits.bin == "11111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        
        person.addTraits(Tree.Branch.e.rawValue, treeIndex: 4)
        assert(person.traits.bin == "11111100000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        
        person.addTraits(Tree.Branch.g.rawValue, treeIndex: 5)
        assert(person.traits.bin == "11111100000011100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    }
    
    @inline(never)
    private static func testMasking() {
        let first1Trait = Person.mask(forTraitAt: 1)
        assert(first1Trait.bin  == "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

        let first4Traits = Person.mask(forTraitAt: 4)
        assert(first4Traits.bin == "11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    }
    
    private static func generateDummyPeople() -> [Person] {
        var pAA = Person()
        pAA.addTraits(Tree.Branch.a.rawValue, treeIndex: 0)
        pAA.addTraits(Tree.Branch.a.rawValue, treeIndex: 1)
        assert(pAA.traits.bin.subarray(maxCount: 6) == "100100")

        var pEF = Person()
        pEF.addTraits(Tree.Branch.e.rawValue, treeIndex: 0)
        pEF.addTraits(Tree.Branch.f.rawValue, treeIndex: 1)
        assert(pEF.traits.bin.subarray(maxCount: 6) == "111011")

        var pCD = Person()
        pCD.addTraits(Tree.Branch.c.rawValue, treeIndex: 0)
        pCD.addTraits(Tree.Branch.d.rawValue, treeIndex: 1)
        assert(pCD.traits.bin.subarray(maxCount: 6) == "110101")

        var pBB = Person()
        pBB.addTraits(Tree.Branch.b.rawValue, treeIndex: 0)
        pBB.addTraits(Tree.Branch.b.rawValue, treeIndex: 1)
        assert(pBB.traits.bin.subarray(maxCount: 6) == "010010")

        var pAB = Person()
        pAB.addTraits(Tree.Branch.a.rawValue, treeIndex: 0)
        pAB.addTraits(Tree.Branch.b.rawValue, treeIndex: 1)
        assert(pAB.traits.bin.subarray(maxCount: 6) == "100010")

        // trait 1: pBB is unique, all others are common
        // trait 2: pBB is unique, the others are split in 2 groups
        // trait 3: pCD and pEF become unique
        // trait 4: pAA and pAB become unique
        return [pAA, pEF, pCD, pBB, pAB]
    }
    
    @inline(never)
    private static func testExport() {
        // write file
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! generateDummyPeople().writeToFile(url: fileURL, emptyFirst: true)

        // read back its content
        var sortedPeople = [Person.Traits]()
        let content = try! Data(contentsOf: fileURL)
        content.withUnsafeBytes { bytes in
            bytes.withMemoryRebound(to: UInt128.self) { people in
                people.forEach { person in
                    sortedPeople.append(person)
                }
            }
        }

        // ensure sort order
        assert(sortedPeople.count == 5)
        assert(sortedPeople[0].bigEndian.bin.subarray(maxCount: 6) == "100100") // pAA
        assert(sortedPeople[1].bigEndian.bin.subarray(maxCount: 6) == "111011") // pEF
        assert(sortedPeople[2].bigEndian.bin.subarray(maxCount: 6) == "110101") // pCD
        assert(sortedPeople[3].bigEndian.bin.subarray(maxCount: 6) == "010010") // pBB
        assert(sortedPeople[4].bigEndian.bin.subarray(maxCount: 6) == "100010") // pAB
    }
    
    @inline(never)
    private static func testSorting() {
        // write file
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! generateDummyPeople().writeToFile(url: fileURL, emptyFirst: true)

        // sort file
        try! fileURL.binSortFile(lineLengthInBytes: Person.traitsSize)
        
        // read back its content
        var sortedPeople = [Person.Traits]()
        let content = try! Data(contentsOf: fileURL)
        content.withUnsafeBytes { bytes in
            bytes.withMemoryRebound(to: UInt128.self) { people in
                people.forEach { person in
                    sortedPeople.append(person)
                }
            }
        }
        
        // ensure sort order
        assert(sortedPeople.count == 5)
        assert(sortedPeople[0].bigEndian.bin.subarray(maxCount: 6) == "010010") // pBB
        assert(sortedPeople[1].bigEndian.bin.subarray(maxCount: 6) == "100010") // pAB
        assert(sortedPeople[2].bigEndian.bin.subarray(maxCount: 6) == "100100") // pAA
        assert(sortedPeople[3].bigEndian.bin.subarray(maxCount: 6) == "110101") // pCD
        assert(sortedPeople[4].bigEndian.bin.subarray(maxCount: 6) == "111011") // pEF
    }
    
    @inline(never)
    private static func testCounting() {
        // write file
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! generateDummyPeople().writeToFile(url: fileURL, emptyFirst: true)

        // sort file
        try! fileURL.binSortFile(lineLengthInBytes: Person.traitsSize)
        
        // count items
        let counts = Counter.count(fileURL: fileURL, forTraits: Array(1...6))
        let countsDic = counts.reduce(into: [:], { $0[$1.0] = $1.1 })
        let expectedCounts = [
            1: 1,
            2: 1,
            3: 3,
            4: 5,
            5: 5,
            6: 5
        ]
        assert(countsDic == expectedCounts)
    }
}
