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
    
    let results = parallelize(count: iterationCount, concurrency: concurrency) { i in
        let d = Date()
        let iteration = Iteration(
            numberOfTrees: numberOfTrees,
            population: population,
            method: .countWhileGenerating,
            verbose: concurrency == 1
        )
        iteration.run()
        print("Finished iteration \(i + 1)")

        let duration = Date().timeIntervalSince(d)
        return (iteration, duration)
    }
    
    let iterations = results.map(\.0)
    let meanDuration = results.map(\.1).reduce(0, +) / Double(iterationCount)
    print("Duration: \(meanDuration.durationString)") // 1.848s
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
