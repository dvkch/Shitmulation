//
//  Export.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

struct Export {
    static func exportFolder(for startDate: Date) -> URL {
        let url = FileManager.gitRepo
            .appendingPathComponent("Results", isDirectory: true)
            .appendingPathComponent(DateFormatter.iso.string(from: startDate), isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    
    static func saveResult(_ results: [(Iteration, TimeInterval)], for startDate: Date, concurrency: Int) {
        let exportFolder = exportFolder(for: startDate)
        
        let iterations = results.map(\.0)
        let totalDuration = results.map(\.1).reduce(0, +)

        guard let first = iterations.first else { return }

        let report = [
            "# Report",
            "",
            "Started: \(DateFormatter.iso.string(from: startDate))",
            "",
            "",
            "Parameters:",
            "",
            "- numberOfTrees: \(first.numberOfTrees.string)",
            "- traitsPerTree: \(Tree.Branch.length)",
            "- population: \(first.population.string)",
            "- strata: \(first.strataCount)",
            "- iterationCount: \(iterations.count.string)",
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
            .write(to: exportFolder.appendingPathComponent("README.md"), atomically: true, encoding: .utf8)
        try! iterations.csvUniqueCounts()
            .write(to: exportFolder.appendingPathComponent("uniques.csv"), atomically: true, encoding: .utf8)
        try! iterations.csvScenarios()
            .write(to: exportFolder.appendingPathComponent("scenarios.csv"), atomically: true, encoding: .utf8)
        for (i, iteration) in iterations.enumerated() {
            try! iteration.forest.csvTrees()
                .write(to: exportFolder.appendingPathComponent("trees-\(i + 1).csv"), atomically: true, encoding: .utf8)
        }
    }
}
