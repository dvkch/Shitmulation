//
//  Counter.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

// This class will count the number of unique lines in a sorted file, considering only the first N bits for each chunk.
// To do so quickly over large files, we have an easy method that will read the file once, and count for multiple values of N.
class Counter {
    static func count(fileURL: URL, forTraits: [Int]) -> [(Int, Int)] {
        let counters = forTraits.map { Counter(comparedTraitsCount: $0) }

        let (_, duration) = benchmark {
            // open file
            let file = try! FileHandle.init(forReadingFrom: fileURL)
            var shouldStop = false
            while !shouldStop {
                autoreleasepool {
                    // read chunk by chunk to reduce (expensive) syscalls, and yet prevent huge
                    // memory copies. we tried, mmap doesn't do better

                    // for 100 million =>    10_000 people at a time (160KB)
                    // for   1 billion => 1_000_000 people at a time  (16MB)
                    // for  10 billion => 1_000_000 people at a time  (16MB)
                    var chunk = (try? file.read(upToCount: Person.traitsSize * 1_000_000)) ?? Data()
                    defer { chunk.removeAll(keepingCapacity: false) }
                    
                    // read that cunk as UInt128
                    chunk.withUnsafeBytes { buffer in
                        buffer.withMemoryRebound(to: Person.Traits.self) { people in
                            // for each number of traits to consider, count the number of unique lines in that chunk
                            counters.forEach { $0.count(people: people) }
                        }
                    }

                    // nothing more to count, let's abort
                    if chunk.isEmpty {
                        shouldStop = true
                    }
                }
            }
        }

        // print report, return results
        let d = duration / TimeInterval(forTraits.count)
        for counter in counters {
            print("- unique at trait \(counter.traits): \(counter.uniqueItems.string) (\(d.durationString))")
        }
        return counters.map { ($0.comparedTraitsCount, $0.uniqueItems) }
    }
    
    // MARK: Init
    private init(comparedTraitsCount: Int) {
        self.comparedTraitsCount = comparedTraitsCount
        self.comparingMask = Person.mask(forTraitAt: comparedTraitsCount)
    }
    
    // MARK: Properties
    let comparedTraitsCount: Int
    let comparingMask: Person.Traits
    
    // MARK: Internal properties
    private(set) var uniqueItems: Int = 0
    
    // MARK: Counting
    private var prevLinesDiffer: Bool = false
    private var previousTraits: Person.Traits?
    private var currentTraits: Person.Traits = .init()
    private func count(people: UnsafeBufferPointer<Person.Traits>) {
        if people.isEmpty {
            if prevLinesDiffer {
                uniqueItems += 1
            }
            return
        }
        
        // TODO: a lot of time is spent in subscript accesses and offset
        // computations, maybe we could do better in C, or by iterating using forEach
        var index = people.startIndex
        while index < people.endIndex {
            currentTraits = Person.readTraits(from: people[index]) & comparingMask
            index = people.index(after: index)

            let differ = previousTraits == nil || currentTraits != previousTraits!
            if prevLinesDiffer && differ {
                uniqueItems += 1
            }
            previousTraits = currentTraits
            prevLinesDiffer = differ
        }
    }
}
