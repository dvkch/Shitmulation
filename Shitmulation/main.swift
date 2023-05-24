//
//  main.swift
//  Shitmulation
//
//  Created by syan on 21/05/2023.
//

import Foundation

func main() {
    let numberOfTrees = 25
    let population = 100_000_000
    let iterationCount = 1
    let concurrency = 1
    
    let iterations = parallelize(count: iterationCount, concurrency: concurrency) { i in
        let iteration = Iteration(numberOfTrees: numberOfTrees, population: population, verbose: concurrency == 1)
        iteration.run()
        print("Finished iteration \(i + 1)")
        return iteration
    }
    
    print("Peak memory usage: \(Memory.peakMemoryUsage.sizeString)")
    sleep(2)
    
    print("-------")
    print("RESULTS")
    print("-------")
    print("")
    print(iterations.csvScenarios())
    print("-------")
    print("")
    print(iterations.csvTraits())
}

main()
