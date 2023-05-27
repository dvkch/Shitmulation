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
    let results = parallelize(count: iterationCount, concurrency: concurrency) { i in
        let d = Date()
        let iteration = Iteration(
            numberOfTrees: numberOfTrees,
            population: population,
            strata: strata
        )
        iteration.run()
        print("Finished iteration \(i + 1)")

        let duration = Date().timeIntervalSince(d)
        return (iteration, duration)
    }
    
    // Write results
    let iterations = results.map(\.0)
    let totalDuration = results.map(\.1).reduce(0, +)

    let resultFolder = URL(fileURLWithPath: #file)
        .deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("Results", isDirectory: true)
        .appendingPathComponent(DateFormatter.iso.string(from: startDate), isDirectory: true)
    try! FileManager.default.createDirectory(at: resultFolder, withIntermediateDirectories: true)

    let report = [
        "# Report",
        "",
        "Started: \(DateFormatter.iso.string(from: startDate))",
        "",
        "",
        "Parameters:",
        "",
        "- numberOfTrees: \(numberOfTrees)",
        "- traitsPerTree: \(Tree.Branch.length)",
        "- population: \(population)",
        "- strata: \(strata)",
        "- iterationCount: \(iterationCount)",
        "- concurrency: \(concurrency)",
        "",
        "",
        "Results:",
        "",
        "- saved to CSV files",
        "- total duration: \(totalDuration.durationString)",
        "- peak memory usage: \(Memory.peakMemoryUsage.sizeString)"
    ].joined(separator: "\n")
    
    try! report
        .write(to: resultFolder.appendingPathComponent("README.md"), atomically: true, encoding: .utf8)
    try! iterations.csvUniqueCounts()
        .write(to: resultFolder.appendingPathComponent("uniques.csv"), atomically: true, encoding: .utf8)
    try! iterations.csvScenarios()
        .write(to: resultFolder.appendingPathComponent("scenarios.csv"), atomically: true, encoding: .utf8)
    for (i, iteration) in iterations.enumerated() {
        try! iteration.forest.csvTrees()
            .write(to: resultFolder.appendingPathComponent("trees-\(i + 1).csv"), atomically: true, encoding: .utf8)
    }

    // Console update
    print("All done and saved to \(resultFolder.path)")
    resultFolder.openInFinder()
}

main()
