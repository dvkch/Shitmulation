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
                // read 160KB at a time, preventing small calls to read (syscalls are expensive), while preventing huge reads
                // sweet spot seems to be around 160KB for now.
                var chunk = (try? file.read(upToCount: lineLengthInBytes * 10_000)) ?? Data()
                defer { chunk.removeAll(keepingCapacity: false) }

                if chunk.isEmpty {
                    if previousLine != prevPreviousLine {
                        uniqueItems += 1
                    }
                    shouldStop = true
                    return
                }
                
                chunk.withUnsafeBytes { buffer in
                    buffer.withMemoryRebound(to: UInt64.self) { lines in
                        var index = lines.startIndex
                        while lines.index(after: index) < lines.endIndex {
                            var currentTraits = (
                                hi: UInt64.init(bigEndian: lines[index]),
                                lo: UInt64.init(bigEndian: lines[lines.index(after: index)])
                            )
                            index = lines.index(after: index)
                            index = lines.index(after: index)

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
                    }
                }
            }
        }
    }
}
