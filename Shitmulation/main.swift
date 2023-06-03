//
//  main.swift
//  Shitmulation
//
//  Created by syan on 21/05/2023.
//

import Foundation

// TODO: switch to UInt128
// TODO: switch to Swift package instead of Xcode project
// TODO: make tests
// TODO: traits from hi to low bit, should allow better sorting and couting uniques from t1 to t128 instead of reversed
// TODO: run for some hours on 1B and 10B, pusblish results, stop.

func main() {
    // PARAMS
    let startDate = Date()
    let numberOfTrees = 42
    let population = 1_000_000_000
    let maxStrataSize = 10_000_000 // 160MB to generate people
    let strata = (population / maxStrataSize).bound(min: 1, max: nil)
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
