//
//  Counter.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

class Counter {

    // MARK: Init
    init(fileURL: URL, traits: Int) {
        self.fileURL = fileURL
        self.lineLengthInBytes = Person.traitsSize
        self.comparingMask = Person.mask(forTraitAt: traits, reverse: true)

        let (_, duration) = benchmark {
            count()
        }
        print("- unique at trait \(traits): \(uniqueItems.string) (\(duration.durationString))")
    }
    
    // MARK: Properties
    let fileURL: URL
    let lineLengthInBytes: Int
    let comparingMask: Person.Traits
    
    // MARK: Internal properties
    private(set) var uniqueItems: Int = 0
    
    // MARK: Counting
    private func count() {
        let file = try! FileHandle.init(forReadingFrom: fileURL)
        
        var prevPreviousLine: Person.Traits = (0, 0)
        var previousLine: Person.Traits = (0, 0)

        var shouldStop = false
        while !shouldStop {
            autoreleasepool {
                var lines = (try? file.read(upToCount: lineLengthInBytes * 1_000_000)) ?? Data()
                if lines.isEmpty {
                    if previousLine != prevPreviousLine {
                        uniqueItems += 1
                    }
                    shouldStop = true
                    return
                }
                for l in 0..<(lines.count / lineLengthInBytes) {
                    let lineStart = lineLengthInBytes * l
                    let lineEnd   = lineStart + lineLengthInBytes
                    let currentLine = lines[lineStart..<lineEnd]
                    var currentTraits = currentLine.traits
                    currentTraits = (
                        hi: currentTraits.hi & comparingMask.hi,
                        lo: currentTraits.lo & comparingMask.lo
                    )

                    if currentTraits != previousLine && previousLine != prevPreviousLine {
                        uniqueItems += 1
                    }
                    prevPreviousLine = previousLine
                    previousLine = currentTraits
                }
                lines.removeAll(keepingCapacity: false)
            }
        }
    }
}
