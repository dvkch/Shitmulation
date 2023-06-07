//
//  main.swift
//  Shitmulation
//
//  Created by syan on 21/05/2023.
//

import Foundation

// TODO: run for some hours on 1B and 10B, pusblish results, stop.

func main() {
    Tests.run(verbose: false)
    
    // PARAMS
    Tree.probabilityIndepA_B = 0.4
    Tree.probabilityIndepC_B = 0.7
    Tree.probabilityIndepC_A = 0.7
    Tree.probabilityIndepC_AB = 0.4

    let startDate = Date()
    let numberOfTrees = 42
    let population = 1_000_000_000
    let maxStrataSize = 10_000_000 // 160MB to generate people
    let strata = (population / maxStrataSize).bound(min: 1, max: nil)
    let iterationCount = 1
    
    // COMPUTE
    // don't parallelize this loop, it's better to properly parallelize
    // what it does instead, to prevent huge memory usage)
    var results: [(Iteration, TimeInterval)] = []
    for iterationIndex in 0..<iterationCount {
        let (iteration, duration) = benchmark("Finished iteration \(iterationIndex + 1) in") {
            let iteration = Iteration(
                numberOfTrees: numberOfTrees,
                population: population,
                strata: strata,
                writePopulation: true
            )
            iteration.run()
            return iteration
        }
        
        results.append((iteration, duration))
        Export.saveResult(results, for: startDate, concurrency: 1)
    }
    
    // OUTPUT
    let url = Export.exportFolder(for: startDate)
    print("All done and saved to \(url.path)")
    url.openInFinder()
}

main()
