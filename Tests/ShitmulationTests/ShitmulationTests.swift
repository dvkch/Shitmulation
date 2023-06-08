import XCTest
@testable import Shitmulation

final class ShitmulationTests: XCTestCase {
    func testStrataTrees() throws {
        // create a tree and its strata trees
        let tree = Tree.generateValidTree(population: 10_000)
        let subtrees = tree.strataSubtrees(count: 4)
        
        // make sure each subtree kept its parent attributes, and also that
        // it is roughly equivalent to the original one divided by the amount
        // of subtrees
        for subtree in subtrees {
            XCTAssertEqual(tree.indepA_B,  subtree.indepA_B)
            XCTAssertEqual(tree.indepC_A,  subtree.indepC_A)
            XCTAssertEqual(tree.indepC_B,  subtree.indepC_B)
            XCTAssertEqual(tree.indepC_AB, subtree.indepC_AB)

            XCTAssertTrue(abs(tree.a / 4 - subtree.a) < 10)
            XCTAssertTrue(abs(tree.b / 4 - subtree.b) < 10)
            XCTAssertTrue(abs(tree.c / 4 - subtree.c) < 10)
            XCTAssertTrue(abs(tree.d / 4 - subtree.d) < 10)
            XCTAssertTrue(abs(tree.e / 4 - subtree.e) < 10)
            XCTAssertTrue(abs(tree.f / 4 - subtree.f) < 10)
            XCTAssertTrue(abs(tree.g / 4 - subtree.g) < 10)
            XCTAssertTrue(abs(tree.h / 4 - subtree.h) < 10)
            XCTAssertTrue(abs(tree.a / 4 - subtree.a) < 10)
        }

        // make sure for each possible category, that the sum available in
        // all subtrees combined is equivalent to what was orignally
        // chosen for the original tree
        XCTAssertEqual(tree.a, subtrees.map(\.a).sum())
        XCTAssertEqual(tree.b, subtrees.map(\.b).sum())
        XCTAssertEqual(tree.c, subtrees.map(\.c).sum())
        XCTAssertEqual(tree.d, subtrees.map(\.d).sum())
        XCTAssertEqual(tree.e, subtrees.map(\.e).sum())
        XCTAssertEqual(tree.f, subtrees.map(\.f).sum())
        XCTAssertEqual(tree.g, subtrees.map(\.g).sum())
        XCTAssertEqual(tree.h, subtrees.map(\.h).sum())
        
        // make sure generating all branches is equivalent between using the main tree, or its subtrees
        XCTAssertEqual(tree.generateBranches().sorted(), subtrees.map { $0.generateBranches() }.reduce([], +).sorted())

        print("Trees generation and stratification works")
    }
    
    func testPeopleTraits() throws {
        var person = Person()
        
        person.addTraits(Tree.Branch.e.rawValue, treeIndex: 0)
        XCTAssertEqual(person.traits.bin, "11100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        
        person.addTraits(Tree.Branch.e.rawValue, treeIndex: 1)
        XCTAssertEqual(person.traits.bin, "11111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        
        person.addTraits(Tree.Branch.e.rawValue, treeIndex: 4)
        XCTAssertEqual(person.traits.bin, "11111100000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        
        person.addTraits(Tree.Branch.g.rawValue, treeIndex: 5)
        XCTAssertEqual(person.traits.bin, "11111100000011100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

        print("Can add traits to people from left to right")
    }
    
    func testMasking() throws {
        let first1Trait = Person.mask(forTraitAt: 1)
        XCTAssertEqual(first1Trait.bin, "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

        let first4Traits = Person.mask(forTraitAt: 4)
        XCTAssertEqual(first4Traits.bin, "11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

        print("Can generate a proper mask to help count from left to right")
    }
    
    private func generateDummyPeople() -> [Person] {
        var pAA = Person()
        pAA.addTraits(Tree.Branch.a.rawValue, treeIndex: 6)
        pAA.addTraits(Tree.Branch.a.rawValue, treeIndex: 7)
        XCTAssertEqual(pAA.traits.bin.subarray(maxCount: 24), "000000000000000000100100")

        var pEF = Person()
        pEF.addTraits(Tree.Branch.e.rawValue, treeIndex: 6)
        pEF.addTraits(Tree.Branch.f.rawValue, treeIndex: 7)
        XCTAssertEqual(pEF.traits.bin.subarray(maxCount: 24), "000000000000000000111011")

        var pCD = Person()
        pCD.addTraits(Tree.Branch.c.rawValue, treeIndex: 6)
        pCD.addTraits(Tree.Branch.d.rawValue, treeIndex: 7)
        XCTAssertEqual(pCD.traits.bin.subarray(maxCount: 24), "000000000000000000110101")

        var pBB = Person()
        pBB.addTraits(Tree.Branch.b.rawValue, treeIndex: 6)
        pBB.addTraits(Tree.Branch.b.rawValue, treeIndex: 7)
        XCTAssertEqual(pBB.traits.bin.subarray(maxCount: 24), "000000000000000000010010")

        var pAB = Person()
        pAB.addTraits(Tree.Branch.a.rawValue, treeIndex: 6)
        pAB.addTraits(Tree.Branch.b.rawValue, treeIndex: 7)
        XCTAssertEqual(pAB.traits.bin.subarray(maxCount: 24), "000000000000000000100010")

        // trait 1: pBB is unique, all others are common
        // trait 2: pBB is unique, the others are split in 2 groups
        // trait 3: pCD and pEF become unique
        // trait 4: pAA and pAB become unique
        return [pAA, pEF, pCD, pBB, pAB]
    }
    
    func testExport() throws {
        // write file
        let file = PopulationFile(uuid: UUID())
        try! file.write(generateDummyPeople())

        // read back its content
        var readPeople = [Person.Traits]()
        file.read { elements, _ in
            readPeople.append(contentsOf: elements)
        }

        // ensure sort order
        XCTAssertEqual(readPeople.count, 5)
        XCTAssertEqual(readPeople[0].bin.subarray(maxCount: 24), "000000000000000000100100") // pAA
        XCTAssertEqual(readPeople[1].bin.subarray(maxCount: 24), "000000000000000000111011") // pEF
        XCTAssertEqual(readPeople[2].bin.subarray(maxCount: 24), "000000000000000000110101") // pCD
        XCTAssertEqual(readPeople[3].bin.subarray(maxCount: 24), "000000000000000000010010") // pBB
        XCTAssertEqual(readPeople[4].bin.subarray(maxCount: 24), "000000000000000000100010") // pAB

        print("Can save people in a binary file")
    }
    
    func testSortingSimple() throws {
        // write file
        var people = [Person]()
        for i in stride(from: 0, to: 128, by: 3) {
            let p = Person(traits: .masking(fromBit: 128 - i, toBit: 128))
            people.append(p)
        }
        people.shuffle()

        let file = PopulationFile(uuid: UUID())
        try! file.write(people)

        // sort file
        try! file.sortFile()
        
        // ensure it is right
        XCTAssertTrue(file.ensureSorted())
        
        // read back its content
        var sortedPeople = [Person.Traits]()
        file.read { elements, _ in
            sortedPeople.append(contentsOf: elements)
        }
        XCTAssertEqual(sortedPeople, people.sorted().map(\.traits))

        print("Can sort a simple binary file")
    }
    
    func testSortingBig() throws {
        // write file
        var people = Set<Person>()
        people.reserveCapacity(1_000_000)
        
        var prng = L64X128PRNG()

        for _ in 0..<people.capacity {
            var person = Person()
            for t in 0..<42 {
                person.addTraits(Tree.Branch.allCases.randomElement(using: &prng)!.rawValue, treeIndex: t)
            }
            people.insert(person)
        }

        let file = PopulationFile(uuid: UUID())
        let sortedPeople = people.sorted()
        
        let fileSize = sortedPeople.count * MemoryLayout<Person.Traits>.size
        log("- writing test file \(UInt64(fileSize).sizeString)")

        // sort file in memory
        file.empty()
        try! file.write(sortedPeople.shuffled(using: &prng))
        benchmark("- in memory sorting in") {
            try! file.sortFile(inMemory: true)
            XCTAssertTrue(file.ensureSorted())
        }
        
        // sort file using bsort
        file.empty()
        try! file.write(sortedPeople.shuffled(using: &prng))
        benchmark("- bsort sorting in") {
            try! file.sortFile(inMemory: false)
            XCTAssertTrue(file.ensureSorted())
        }

        // read back its content
        var readPeople = [Person.Traits]()
        file.read { elements, _ in
            readPeople.append(contentsOf: elements)
        }
        
        XCTAssertEqual(readPeople.count, sortedPeople.count)
        var differingElements = 0
        for i in 0..<readPeople.count {
            differingElements += readPeople[i] != sortedPeople[i].traits ? 1 : 0
        }
        XCTAssertEqual(differingElements, 0)

        print("Can sort a big binary file")
    }

    func testCounting() throws {
        // write file
        let file = PopulationFile(uuid: UUID())
        try! file.write(generateDummyPeople())

        // sort file
        try! file.sortFile()
        
        // count items
        let counts = Counter.count(file: file, forTraits: Array(15...24))
        let countsDic = counts.counts.reduce(into: [:], { $0[$1.0] = $1.1 })
        let expectedCounts = [
            15: 0,
            16: 0,
            17: 0,
            18: 0,
            19: 1,
            20: 1,
            21: 3,
            22: 5,
            23: 5,
            24: 5,
        ]
        XCTAssertEqual(countsDic, expectedCounts)

        print("Can read the binary file again to count uniqueness")
    }
}
