//
//  Extensions.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

extension Int {
    var string: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.hasThousandSeparators = true
        formatter.thousandSeparator = " "
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension UInt64 {
    var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.includesCount = true
        formatter.includesUnit = true
        return formatter.string(fromByteCount: Int64(self))
    }
    
    var data: Data {
        // using big endian to put back everything in order, trait1 being the first
        // bit appearing. identical to data.reverse(), but way faster
        var int = self.bigEndian
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}

extension Data {
    var traits: Person.Traits {
        assert(count == Person.traitsSize)
        var hi: UInt64 = 0
        var lo: UInt64 = 0
        
        self.withUnsafeBytes { buffer in
            buffer.withMemoryRebound(to: UInt64.self) { bytes in
                hi = bytes[0]
                lo = bytes[1]
            }
        }
        
        hi = .init(bigEndian: hi)
        lo = .init(bigEndian: lo)
        return (hi: hi, lo: lo)
    }
}

extension TimeInterval {
    var durationString: String {
        return String(format: "%.03lfs", self)
    }
}

extension Bool {
    var int: Int {
        return self ? 1 : 0
    }
    var char: UInt8 {
        return self ? 89 : 78
    }
}

public extension Collection {
    func subarray(maxCount: Int) -> Self.SubSequence {
        let max = Swift.min(maxCount, count)
        let maxIndex = index(startIndex, offsetBy: max)
        return self[startIndex..<maxIndex]
    }
}

extension Collection where Element: FixedWidthInteger {
    func sum() -> Element {
        return reduce(0, +)
    }
}

func benchmark<T>(_ message: String, closure: () -> T) -> T {
    let d = Date()
    let result = closure()
    print(message, Date().timeIntervalSince(d).durationString)
    return result
}

func benchmark<T>(_ message: String? = nil, _ closure: () -> T) -> (T, TimeInterval) {
    let d = Date()
    let result = closure()
    if let message {
        print(message, Date().timeIntervalSince(d).durationString)
    }
    return (result, Date().timeIntervalSince(d))
}

func parallelize<T>(count: Int, closure: @escaping (Int) -> (T)) -> [T] {
    let lock = NSLock()
    var results = [Int: T]()

    (0..<count).forEachParallel { i in
        let result = autoreleasepool {
            closure(i)
        }

        lock.lock()
        results[i] = result
        lock.unlock()
    }
    
    return results.sorted(by: { $0.key < $1.key }).map(\.value)
}

extension DateFormatter {
    static var iso: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH'h'mm"
        df.timeZone = .current
        df.locale = .init(identifier: "en_US_POSIX")
        return df
    }
}

extension URL {
    func openInFinder() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [path]
        try! process.run()
        process.waitUntilExit()
    }
}

var verbose: Bool = true
func log(_ message: String, newLine: Bool = true) {
    if verbose {
        print(message, terminator: newLine ? "\n" : "")
    }
}

extension UInt64 {
    static func masking(from: Int, to: Int) -> UInt64 {
        var value: UInt64 = 0
        for i in from...to {
            value += 1 << i
        }
        return value
    }
}

extension Sequence {
    func forEachParallel(_ closure: @escaping (Element) -> ()) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = System.performanceCores - 1
        
        let group = DispatchGroup()

        for item in self {
            group.enter()
            queue.addOperation {
                closure(item)
                group.leave()
            }
        }
        group.wait()
    }
}

extension Int {
    func bound(min: Int?, max: Int?) -> Int {
        if let max, self > max { return max }
        if let min, self < min { return min }
        return self
    }
}

extension BinaryInteger {
    var bin: String {
        let length = MemoryLayout<Self>.size * 8
        let binaryString = String(self, radix: 2)
        let padding = [String](repeating: "0", count: length - binaryString.count).joined()
        return padding + binaryString
    }
}

extension FileManager {
    static var gitRepo: URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

extension URL {
    func binSortFile(lineLengthInBytes: Int) throws {
        let process = Process()
        process.executableURL = FileManager.gitRepo.appending(path: "Vendor/bsort")
        process.arguments = ["-k", String(lineLengthInBytes), "-r", String(lineLengthInBytes), self.path]
        try process.run()
        process.waitUntilExit()
    }
}
