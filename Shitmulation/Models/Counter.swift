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
        // mmap isn't as efficient, really.
        let file = try! FileHandle.init(forReadingFrom: fileURL)
        
        var prevLinesDiffer: Bool = false
        var previousTraits: Person.Traits = (0, 0)
        var currentTraits: Person.Traits = (0, 0)

        var shouldStop = false
        while !shouldStop {
            autoreleasepool {
                // TODO: when comparing a small amount of traits, maybe rebind to UInt8 and skip over some elements ?
                // trying to read chunks by chunks to prevent small syscalls, and yet prevent huge memory copies.
                // for 100 million =>    10_000 people at a time (160KB)
                // for   1 billion => 1_000_000 people at a time  (16MB)
                // for  10 billion => 1_000_000 people at a time  (16MB)
                var chunk = (try? file.read(upToCount: lineLengthInBytes * 1_000_000)) ?? Data()
                defer { chunk.removeAll(keepingCapacity: false) }

                if chunk.isEmpty {
                    if prevLinesDiffer {
                        uniqueItems += 1
                    }
                    shouldStop = true
                    return
                }
                
                // a lot of time is spent in subscript accesses and offset computations, maybe we could do better in C
                chunk.withUnsafeBytes { buffer in
                    buffer.withMemoryRebound(to: UInt64.self) { lines in
                        var index = lines.startIndex
                        while lines.index(after: index) < lines.endIndex {
                            currentTraits.hi = UInt64.init(bigEndian: lines[index]) & comparingMask.hi
                            index = lines.index(after: index)

                            currentTraits.lo = UInt64.init(bigEndian: lines[index]) & comparingMask.lo
                            index = lines.index(after: index)

                            let differ = currentTraits.hi != previousTraits.hi || currentTraits.lo != previousTraits.lo
                            if prevLinesDiffer && differ {
                                uniqueItems += 1
                            }
                            previousTraits = currentTraits
                            prevLinesDiffer = differ
                        }
                    }
                }
            }
        }
    }
}
