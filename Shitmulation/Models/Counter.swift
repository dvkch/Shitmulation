//
//  Counter.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

class Counter {
    // TODO: compare for multiple traits value at the same time.
    static func count(fileURL: URL, forTraits: [Int]) -> [(Int, Int)] {
        let counters = forTraits.map { Counter(traits: $0) }
        let lineLengthInBytes = Person.traitsSize

        let (_, duration) = benchmark {
            // mmap isn't as efficient, really.
            let file = try! FileHandle.init(forReadingFrom: fileURL)
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
                    
                    chunk.withUnsafeBytes { buffer in
                        buffer.withMemoryRebound(to: UInt64.self) { lines in
                            counters.forEach { $0.count(lines: lines) }
                        }
                    }

                    if chunk.isEmpty {
                        shouldStop = true
                    }
                }
            }
        }

        let d = duration / TimeInterval(forTraits.count)
        for counter in counters {
            print("- unique at trait \(counter.traits): \(counter.uniqueItems.string) (\(d.durationString))")
        }
        return counters.map { ($0.traits, $0.uniqueItems) }
    }
    
    // MARK: Init
    private init(traits: Int) {
        self.traits = traits
        self.comparingMask = Person.mask(forTraitAt: traits, reverse: true)
    }
    
    // MARK: Properties
    let traits: Int
    let comparingMask: Person.Traits
    
    // MARK: Internal properties
    private(set) var uniqueItems: Int = 0
    
    // MARK: Counting
    private var prevLinesDiffer: Bool = false
    private var previousTraits: Person.Traits = (0, 0)
    private var currentTraits: Person.Traits = (0, 0)
    private func count(lines: UnsafeBufferPointer<UInt64>) {
        if lines.isEmpty {
            if prevLinesDiffer {
                uniqueItems += 1
            }
            return
        }
        
        // a lot of time is spent in subscript accesses and offset computations, maybe we could do better in C
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
