//
//  main.swift
//  Shitmulation
//
//  Created by syan on 21/05/2023.
//

import Foundation
import ArgumentParser

// TODO: try with UInt128 swift implementation
// TODO: dockerize
// https://contabo.com/en/vps/vps-xl-ssd/?image=ubuntu.267&qty=1&contract=1&storage-type=vps-xl-nvme-400-gb

@main
struct Shitmulation: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Shitmulation",
        version: "1.0"
    )

    @Option(name: .customLong("piAB"), help: "Probability of independant A/B")
    var probabilityIndepA_B: Double = 0.4

    @Option(name: .customLong("piCB"), help: "Probability of independant C/B")
    var probabilityIndepC_B: Double = 0.7

    @Option(name: .customLong("piCA"), help: "Probability of independant C/A")
    var probabilityIndepC_A: Double = 0.7

    @Option(name: .customLong("piCAB"), help: "Probability of independant C/AB")
    var probabilityIndepC_AB: Double = 0.4

    @Option(name: .customLong("trees"), help: "Number of trees")
    var numberOfTrees: Int = 42
    
    @Option(name: .customLong("population"), help: "Population size")
    var population: Int = 100_000_000
    
    @Option(name: .customLong("strata"), help: "Maximum strata size")
    var maxStrataSize: Int = 5_000_000 // 80MB to generate people, seems to be the most efficient
    
    @Option(name: .customLong("iterations"), help: "Number of iterations")
    var iterationCount: Int = 1

    @Option(name: .customLong("threads"), help: "Threads to use")
    var threads: Int = System.recommendedThreadsCount
    
    func run() throws {
        // PARAMS
        let startDate = Date()
        let strata = (population / maxStrataSize).bound(min: 1, max: nil)
        Tree.probabilityIndepA_B = probabilityIndepA_B
        Tree.probabilityIndepC_B = probabilityIndepC_B
        Tree.probabilityIndepC_A = probabilityIndepC_A
        Tree.probabilityIndepC_AB = probabilityIndepC_AB
        
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
                    threads: threads,
                    writePopulation: true
                )
                iteration.run()
                return iteration
            }
            
            results.append((iteration, duration))
            Export.saveResult(results, for: startDate, threads: threads)
        }
        
        // OUTPUT
        let url = Export.exportFolder(for: startDate)
        print("All done and saved to \(url.path)")
        #if os(macOS)
        url.openInFinder()
        #endif
    }
}
