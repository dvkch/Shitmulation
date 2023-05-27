//
//  main.swift
//  Shitmulation
//
//  Created by syan on 21/05/2023.
//

import Foundation

func main() {
    let startDate = Date()
    let numberOfTrees = 21
    let population = 100_000_000
    let strata = (population / 10_000_000).bound(min: 1, max: 100)
    let iterationCount = 1
    let concurrency = 1
    
    verbose = concurrency == 1
    
    // Compute
    var results: [(Iteration, TimeInterval)] = []
    let lock = NSLock()
    (0..<iterationCount).forEachParallel(concurrency: concurrency) { i in
        let (iteration, duration) = benchmark("Finished iteration \(i + 1) in") {
            let iteration = Iteration(
                numberOfTrees: numberOfTrees,
                population: population,
                strata: strata
            )
            iteration.run()
            return iteration
        }
        
        lock.lock()
        results.append((iteration, duration))
        lock.unlock()
        
        Export.saveResult(results, for: startDate, concurrency: concurrency)
    }
    
    // Console update
    let url = Export.exportFolder(for: startDate)
    print("All done and saved to \(url.path)")
    url.openInFinder()
}

main()
