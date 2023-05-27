//
//  Iteration.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

class Iteration {
    // MARK: Init
    init(numberOfTrees: Int, population: Int) {
        self.numberOfTrees = numberOfTrees
        self.population = population
    }
    
    // MARK: Properties
    let numberOfTrees: Int
    let population: Int
    
    // MARK: Results
    private(set) var forest: [Tree] = []
    private(set) var people: [Person] = []
    private(set) var uniqCounts: [Int] = []
    
    // MARK: Steps
    func run() {
        generateForest()
        generatePeople()
        countUniquePeople()
    }

    private func generateForest() {
        log("Creating \(numberOfTrees * 3) traits", newLine: false)
        self.forest = benchmark("> Finished in") {
            (0..<numberOfTrees).map { i in
                log(".", newLine: i == numberOfTrees - 1)
                return Tree.generateValidTree(population: population)
            }
        }
        Memory.updatePeakMemoryUsage()
    }
    
    private func generatePeople() {
        log("Populating \(population.string) people using \(numberOfTrees * 3) traits", newLine: false)
        self.people = benchmark("> Finished distributing in") {
            
            // create empty people
            var people = [Person]()
            people.reserveCapacity(population)
            for _ in 0..<population {
                people.append(Person(traitsCount: forest.count * 3))
            }

            // iterate on each tree
            for (t, tree) in forest.enumerated() {
                log(".", newLine: t == forest.count - 1)

                // add traits for this tree to all people
                for p in 0..<people.count {
                    people[p].addTraits(tree.pickABranch())
                }
            }
            return people
        }
        Memory.updatePeakMemoryUsage()
    }
    
    // TODO: try using a bisection

    private func countUniquePeople() {
        log("Counting unique over \(population.string) people", newLine: false)
        self.uniqCounts = benchmark("> Finished counting in") {
            var uniqueStats = [Int]()
            for trait in 1...(numberOfTrees * 3) {
                let (count, duration) = benchmark {
                    let count = people.countUniqueItems(upTo: trait) + (uniqueStats.last ?? 0)
                    uniqueStats.append(count)

                    Memory.updatePeakMemoryUsage()
                    self.people = people.filter { $0.unique == false }

                    return count
                }

                log(" - unique at \(trait): \(count.string) (\(duration.durationString))")
                if count == population {
                    break
                }
            }
            return uniqueStats
        }
    }
}


// MARK: Export
extension Array where Element == Iteration {
    func csvUniqueCounts() -> String {
        guard let first else { return "" }

        var csvTraits = [String]()
        csvTraits.append("Trait;")
        for i in 0..<(first.numberOfTrees * 3) {
            csvTraits.append("\(i+1);")
        }

        for (i, iteration) in self.enumerated() {
            csvTraits[0] += "Iteration \(i + 1);"
            for trait in 1...iteration.uniqCounts.count {
                let count = iteration.uniqCounts[trait - 1]
                csvTraits[trait] += "\(count);"
            }
            for trait in iteration.uniqCounts.count..<(first.numberOfTrees * 3) {
                csvTraits[trait + 1] += "\(first.population);"
            }
        }
        
        return csvTraits.joined(separator: "\n")
    }
    
    func csvScenarios() -> String {
        return self.map(\.forest).csvScenarios()
    }
}
