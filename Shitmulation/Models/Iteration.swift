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
        self.strata = strata
    }
    
    // MARK: Properties
    let numberOfTrees: Int
    let population: Int
    let strata: Int
    
    // MARK: Results
    private(set) var forest: [Tree] = []
    private var strataForest: [Tree] = []
    private(set) var people: ContiguousArray<Person> = []
    private(set) var uniqCounts: [Int: Int] = [:]
    
    // MARK: Steps
    func run() {
        generateForest()
        generatePeople()
        countUniquePeople()
    }

    private func generateForest() {
        log("Creating \(numberOfTrees * Tree.Branch.length) traits", newLine: false)
        strataForest = benchmark("> Finished in") {
            (0..<numberOfTrees).map { i in
                log(".", newLine: i == numberOfTrees - 1)
                return Tree.generateValidTree(population: population, strata: strata)
            }
        }
        forest = strataForest.map { Tree(multiplying: $0, by: strata) }
        Memory.updatePeakMemoryUsage()
    }
    
    private func generatePeople() {
        log("Populating \(population.string) people using \(numberOfTrees * Tree.Branch.length) traits", newLine: false)
        self.people = benchmark("> Finished distributing in") {
            
            // create empty people
            var people = ContiguousArray<Person>()
            people.reserveCapacity(population)
            for _ in 0..<population {
                people.append(Person())
            }
            
            // iterate on each tree
            for (t, tree) in strataForest.enumerated() {
                log(".", newLine: t == forest.count - 1)
                
                // add traits for this tree to all people, parallelizing on using strata
                (0..<strata).forEachParallel { i in
                    let treeCopy = Tree.init(multiplying: tree, by: 1)
                    let startIndex = self.population / self.strata * i
                    let endIndex   = self.population / self.strata * (i + 1)
                    for p in (startIndex)..<endIndex {
                        people[p].addTraits(treeCopy.pickABranch(), position: t * Tree.Branch.length)
                    }
                }
            }
            return people
        }
        Memory.updatePeakMemoryUsage()
    }
    
    private func countUniquePeople() {
        log("Counting unique over \(population.string) people")
        
        // Mean values for trait # where the pop is divided 50/50 unique
        //  10k => 15
        // 100k => 19
        //   1m => 22
        //  10m => 25
        
        let bisectionIndex = 4 + (Int(Darwin.log(Double(population)) / Darwin.log(Double(10)))) * 3
        
        uniqCounts = [:]
        uniqCounts[bisectionIndex] = people.countUniqueItems(upTo: bisectionIndex, uniquesAtPreviousTrait: 0, markUniques: true)
        
        var duplicatedAtBisection = ContiguousArray(people.filter { $0.unique == false })
        var uniqueAtBisection = ContiguousArray(people.filter { $0.unique })
        uniqueAtBisection.unmarkUnique()
        self.people = []

        benchmark("> Finished counting in") {
            // first loop
            for trait in (1..<bisectionIndex) {
                let count = uniqueAtBisection.countUniqueItems(
                    upTo: trait, uniquesAtPreviousTrait: (uniqCounts[trait - 1] ?? 0), markUniques: true
                )
                uniqCounts[trait] = count

                uniqueAtBisection = uniqueAtBisection.filter { $0.unique == false }

                if count == population {
                    break
                }
            }

            // second loop
            for trait in (bisectionIndex + 1)...(numberOfTrees * Tree.Branch.length) {
                let count = duplicatedAtBisection.countUniqueItems(
                    upTo: trait, uniquesAtPreviousTrait: (uniqCounts[trait - 1] ?? 0), markUniques: true
                )
                uniqCounts[trait] = count

                duplicatedAtBisection = duplicatedAtBisection.filter { $0.unique == false }
                if count == population {
                    break
                }
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
