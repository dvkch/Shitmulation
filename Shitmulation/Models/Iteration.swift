//
//  Iteration.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

class Iteration {
    // MARK: Init
    init(numberOfTrees: Int, population: Int, strata: Int) {
        self.numberOfTrees = numberOfTrees
        self.population = population
        self.strataCount = strata

        let populationDir = FileManager.gitRepo.appendingPathComponent("Population", isDirectory: true)
        try! FileManager.default.createDirectory(at: populationDir, withIntermediateDirectories: true)
        peopleFile = populationDir.appending(path: "population.bin")
        FileManager.default.createFile(atPath: peopleFile.path, contents: Data())
    }
    
    // MARK: Properties
    let numberOfTrees: Int
    let population: Int
    let strataCount: Int
    
    // MARK: Results
    private(set) var forest: [Tree] = []
    private var strataForest: [[Tree]] = []
    private let peopleFile: URL
    private(set) var uniqCounts: [Int: Int] = [:]
    
    // MARK: Steps
    func run() {
        generateForest()
        generatePeople()
        sortPeople()
        countUniquePeople()
    }

    private func generateForest() {
        log("Creating \(numberOfTrees * Tree.Branch.length) traits", newLine: false)
        forest = benchmark("> Finished in") {
            (0..<numberOfTrees).map { i in
                log(".", newLine: i == numberOfTrees - 1)
                return Tree.generateValidTree(population: population)
            }
        }
        strataForest = forest.map { $0.strataSubtrees(count: strataCount) }
        Memory.updatePeakMemoryUsage()
    }
    
    private func generatePeople() {
        let fileWritingLock = NSLock()
        
        log("Populating \(population.string) people using \(numberOfTrees * Tree.Branch.length) traits", newLine: false)
        _ = benchmark("> Finished distributing in") {
            parallelize(count: strataCount) { strata in
                let forest = self.strataForest.map { $0[strata] }
                let population = forest.first!.x
                
                // create empty people
                var people = ContiguousArray<Person>()
                people.reserveCapacity(population)
                for _ in 0..<population {
                    people.append(Person())
                }

                // iterate on each tree
                for (t, tree) in forest.enumerated() {
                    let shuffledBranches = tree.generateBranches()
                    assert(people.count == shuffledBranches.count)

                    for p in 0..<people.count {
                        // TODO: since we can't count from 1 to N, but from N to 1, maybe we could associate
                        // traits in reverse order ?
                        people[p].addTraits(shuffledBranches[p], position: t * Tree.Branch.length)
                    }
                }

                // write to file
                fileWritingLock.lock()
                try! people.writeToFile(url: self.peopleFile, emptyFirst: false)
                fileWritingLock.unlock()
                
                // force free memory
                people.removeAll(keepingCapacity: false)

                // small output
                log(".", newLine: strata == self.strataCount - 1)
            }
        }
        
        Memory.updatePeakMemoryUsage()
    }
    
    private func sortPeople() {
        log("Sorting...")
        benchmark("Sorted \(strataCount.string) files in") {
            [peopleFile].forEachParallel { file in
                try! file.binSortFile(lineLengthInBytes: Person.traitsSize)
            }
        }
    }
    
    private func countUniquePeople() {
        log("Counting unique over \(population.string) people")
        
        // Mean values for trait # where the pop is divided 50/50 unique
        //  10k => 15
        // 100k => 19
        //   1m => 22
        //  10m => 25
        
        let bisectionIndex = 4 + (Int(Darwin.log(Double(population)) / Darwin.log(Double(10)))) * 3
        
        benchmark("> Finished counting in") {
            let traitsTotal = numberOfTrees * Tree.Branch.length
            let traits = 1...traitsTotal
            let lock = NSLock()
            var shouldStopAfterTrait: Int = traits.max()!
            traits.forEachParallel { trait in
                if trait > shouldStopAfterTrait {
                    return
                }

                let counter = Counter(fileURL: self.peopleFile, traits: trait)

                lock.lock()
                self.uniqCounts[trait] = counter.uniqueItems
                lock.unlock()

                if counter.uniqueItems == self.population {
                    lock.lock()
                    shouldStopAfterTrait = trait
                    lock.unlock()
                }
            }
            
            // TODO: reverse counts
        }
    }
}

// MARK: Export
extension Array where Element == Iteration {
    func csvUniqueCounts() -> String {
        guard let first else { return "" }

        var csvTraits = [String]()
        csvTraits.append("Trait;")
        for i in 0..<(first.numberOfTrees * Tree.Branch.length) {
            csvTraits.append("\(i+1);")
        }

        for (i, iteration) in self.enumerated() {
            csvTraits[0] += "Iteration \(i + 1);"
            for trait in 1...(first.numberOfTrees * Tree.Branch.length) {
                let count = iteration.uniqCounts[trait] ?? first.population
                csvTraits[trait] += "\(count);"
            }
        }
        
        return csvTraits.joined(separator: "\n")
    }
    
    func csvScenarios() -> String {
        return self.map(\.forest).csvScenarios()
    }
}
