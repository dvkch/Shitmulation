//
//  main.swift
//  Shitmulation
//
//  Created by syan on 21/05/2023.
//

import Foundation

func main() {
    // PARAMS
    let startDate = Date()
    let numberOfTrees = 42
    let population = 100_000_000
    let strata = (population / 10_000_000).bound(min: 1, max: 100)
    let iterationCount = 1
    
    verbose = true
    
    // COMPUTE
    // don't parallelize this loop, it's better to properly parallelize
    // what it does instead, to prevent huge memory usage)
    var results: [(Iteration, TimeInterval)] = []
    for iterationIndex in 0..<iterationCount {
        let (iteration, duration) = benchmark("Finished iteration \(iterationIndex + 1) in") {
            let iteration = Iteration(
                numberOfTrees: numberOfTrees,
                population: population,
                strata: strata
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
