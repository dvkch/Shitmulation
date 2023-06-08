//
//  Iteration.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

class Iteration {
    // MARK: Init
    init(numberOfTrees: Int, population: Int, strata: Int, writePopulation: Bool) {
        self.numberOfTrees = numberOfTrees
        self.population = population
        self.strataCount = strata
        self.writePopulation = writePopulation
        
        let populationDir = FileManager.sourceCodeURL.appendingPathComponent("Population", isDirectory: true)
        try! FileManager.default.createDirectory(at: populationDir, withIntermediateDirectories: true)
        peopleFile = populationDir.appending(path: "population.bin")
        
        if writePopulation {
            FileManager.default.createFile(atPath: peopleFile.path, contents: Data())
        }
    }
    
    // MARK: Properties
    let numberOfTrees: Int
    let population: Int
    let strataCount: Int
    let writePopulation: Bool
    
    // MARK: Results
    private(set) var forest: [Tree] = []
    private var strataForest: [[Tree]] = []
    private let peopleFile: URL
    private(set) var result = Result()
    
    // MARK: Steps
    func run() {
        if writePopulation {
            generateForest()
            generatePeople()
            sortPeople()
        }
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
        
        log("Populating \(population.amountString) people using \(numberOfTrees * Tree.Branch.length) traits", newLine: false)
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
                        people[p].addTraits(shuffledBranches[p], treeIndex: t)
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
        benchmark("Sorted population files in") {
            try! peopleFile.binSortFile(lineLengthInBytes: Person.traitsSize)
        }
    }
    
    private func countUniquePeople() {
        log("Counting unique over \(population.amountString) people")
        
        benchmark("> Finished counting in") {
            let traitsTotal = numberOfTrees * Tree.Branch.length
            let lock = NSLock()
            var shouldStopAfterTrait: Int = traitsTotal
            
            let traitsAtATime = 8
            stride(from: 1, to: traitsTotal, by: traitsAtATime).forEachParallel { trait in
                if trait > shouldStopAfterTrait {
                    return
                }
                
                let traitsToStudy = Array(trait..<(trait + traitsAtATime))

                let counts = Counter.count(fileURL: self.peopleFile, forTraits: traitsToStudy)

                lock.lock()
                self.result += counts
                if self.result.counts.values.contains(self.population) {
                    shouldStopAfterTrait = trait
                }
                lock.unlock()
            }
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
                let count = iteration.result.counts[trait] ?? first.population
                csvTraits[trait] += "\(count);"
            }
        }
        
        return csvTraits.joined(separator: "\n")
    }
    
    func csvScenarios() -> String {
        return self.map(\.forest).csvScenarios()
    }
}
