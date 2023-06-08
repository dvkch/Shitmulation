//
//  PopulationFile.swift
//  Shitmulation
//
//  Created by syan on 08/06/2023.
//

import Foundation

struct PopulationFile {
    
    // MARK: Init
    init(uuid: UUID) {
        self.digit = 0
        self.url = FileManager.default.temporaryDirectory.appendingPathComponent(uuid.uuidString)
        self.lock = NSLock()
        empty()
    }

    init(digit: UInt8, empty: Bool) {
        let populationDir = FileManager.sourceCodeURL.appendingPathComponent("Population", isDirectory: true)
        try! FileManager.default.createDirectory(at: populationDir, withIntermediateDirectories: true)

        self.digit = digit
        self.url = populationDir.appending(path: "population-\(digit).bin")
        self.lock = NSLock()

        if empty || !FileManager.default.fileExists(atPath: url.path) {
            self.empty()
        }
    }
    
    // MARK: Properties
    let digit: UInt8
    private let url: URL
    private let lock: NSLock
    
    // MARK: Generic methods
    func empty() {
        lock.lock()
        defer { lock.unlock() }
        
        FileManager.default.createFile(atPath: url.path, contents: Data())
    }

    func write<T: RandomAccessCollection<Person>>(_ people: T) throws where T.Index == Int {
        lock.lock()
        defer { lock.unlock() }
        
        let file = try FileHandle(forUpdating: url)
        defer { try? file.close() }

        try file.seekToEnd()

        // it's faster to write big chunks at a time then small chunks very frequently
        let strideSize = 100_000

        var data = Data()
        data.reserveCapacity(strideSize * Person.traitsSize)

        try stride(from: 0, to: people.count, by: strideSize).forEach { startIndex in
            let endIndex = (startIndex + strideSize).bound(min: 0, max: people.count)

            data.removeAll(keepingCapacity: true)
            people[startIndex..<endIndex].forEach { p in
                p.write(into: &data)
            }
            try file.write(contentsOf: data)
        }
    }
    
    func read(closure: (Array<Person.Traits>, inout Bool) -> ()) {
        lock.lock()
        defer { lock.unlock() }
        
        let file = try! FileHandle.init(forReadingFrom: url)
        var shouldStop = false
        while !shouldStop {
            autoreleasepool {
                // read chunk by chunk to reduce (expensive) syscalls, and yet prevent huge
                // memory copies. we tried, mmap doesn't do better

                // for 100 million =>    10_000 people at a time (160KB)
                // for   1 billion => 1_000_000 people at a time  (16MB)
                // for  10 billion => 1_000_000 people at a time  (16MB)
                var chunk = (try? file.read(upToCount: MemoryLayout<Person.Traits>.size * 1_000_000)) ?? Data()
                defer { chunk.removeAll(keepingCapacity: false) }
                
                // read that chunk as UInt128
                chunk.withUnsafeBytes { buffer in
                    buffer.withMemoryRebound(to: Person.Traits.self) { elements in
                        // compute the chunk
                        closure(elements.map { Person.readTraits(from: $0) }, &shouldStop)
                    }
                }

                // nothing more to read
                if chunk.isEmpty {
                    shouldStop = true
                }
            }
        }
    }
    
    var savedCount: Int {
        lock.lock()
        defer { lock.unlock() }
        
        let file = try! FileHandle.init(forReadingFrom: url)
        let fileSize = try! file.seekToEnd()
        return Int(fileSize / UInt64(MemoryLayout<Person.Traits>.size))
    }
    
    func sortFile(inMemory: Bool = false) throws {
        if inMemory {
            var people = ContiguousArray<Person>()
            people.reserveCapacity(savedCount)
            read { slice, _ in
                // TODO: cost of mapping ?
                people.append(contentsOf: slice.map { Person(traits: $0) })
            }
            people.sort()
            empty()
            try! write(people)
        }
        else {
            let output = Pipe()
            defer {
                output.fileHandleForReading.closeFile()
                output.fileHandleForWriting.closeFile()
            }

            let process = Process()
            process.executableURL = FileManager.sourceCodeURL.appending(path: "Vendor/bsort")
            process.arguments = [
                // TODO: "-c", "8",
                "-r", String(MemoryLayout<Person.Traits>.size),
                "-k", String(MemoryLayout<Person.Traits>.size),
                url.path
            ]
            process.standardOutput = output
            try process.run()
            process.waitUntilExit()
        }
    }
    
    func ensureSorted() -> Bool {
        var isSorted = true
        var prevChunkLastValue: Person.Traits = .init()

        read { elements, shouldStop in
            if elements.isEmpty {
                return
            }

            if elements[0] < prevChunkLastValue {
                isSorted = false
                shouldStop = true
                return
            }

            for i in 1..<elements.count {
                if elements[i] < elements[i - 1] {
                    isSorted = false
                    shouldStop = true
                    return
                }
            }
            prevChunkLastValue = elements.last!
        }
        return isSorted
    }
}

fileprivate extension Person {
    @inline(__always)
    func write(into data: inout Data) {
        var swapped = self.traits.bigEndian
        let swappedData = Data(bytes: &swapped, count: MemoryLayout<UInt128>.size)
        data.append(swappedData)
    }
    
    @inline(__always)
    static func readTraits(from value: UInt128) -> Person.Traits {
        return value.bigEndian
    }
}

extension PopulationFile: Comparable {
    static func ==(lhs: PopulationFile, rhs: PopulationFile) -> Bool {
        return lhs.url == rhs.url
    }

    static func <(lhs: PopulationFile, rhs: PopulationFile) -> Bool {
        return lhs.digit < rhs.digit
    }
}
