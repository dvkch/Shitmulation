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
        
        for digit in 0...UInt8.max {
            peopleFiles.append(.init(digit: digit, empty: writePopulation))
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
    private var peopleFiles: [PopulationFile] = []
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
                people.sort()
                
                // write to file
                let byteIndex = UInt8(MemoryLayout<Person.Traits>.size - 1)
                var groupedPeople = Array(repeating: [Person](), count: 256)
                people.forEach { p in
                    groupedPeople[p.traits.byte(at: byteIndex)].append(p)
                }
                for file in self.peopleFiles {
                    try! file.write(groupedPeople[Int(file.digit)])
                }
                
                // force free memory
                people.removeAll(keepingCapacity: false)

                // small output
                log(".", newLine: strata == self.strataCount - 1)
            }
        }
        
        Memory.updatePeakMemoryUsage()
    }
    
    private func sortPeople() {
        var allSorted = true
        log("Sorting...", newLine: false)
        benchmark("\nSorted population files in") {
            peopleFiles.sorted().forEachParallel { file in
                try! file.sortFile()

                if !file.ensureSorted() {
                    log("\n\(file.digit) not properly sorted!")
                    allSorted = false
                }
                log(".", newLine: false)
            }
        }
        
        if !allSorted {
            fatalError("Not all files are properly sorted, aborting")
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

                var result = Result()
                for file in self.peopleFiles {
                    result += Counter.count(file: file, forTraits: traitsToStudy)
                }
                
                let d = result.duration / TimeInterval(traitsToStudy.count)
                for trait in traitsToStudy {
                    log("- unique at trait \(trait): \(result.counts[trait]!.amountString) (\(d.durationString))")
                }

                lock.lock()
                self.result += result

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
