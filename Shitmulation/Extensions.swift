//
//  Extensions.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

extension Int {
    var amountString: String {
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
    log(message + " " + Date().timeIntervalSince(d).durationString)
    return result
}

func benchmark<T>(_ message: String? = nil, _ closure: () -> T) -> (T, TimeInterval) {
    let d = Date()
    let result = closure()
    if let message {
        log(message + " " + Date().timeIntervalSince(d).durationString)
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
    static var isoString: DateFormatter {
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

var printLogs: Bool = true
func log(_ message: String, newLine: Bool = true) {
    if printLogs {
        print(message, terminator: newLine ? "\n" : "")
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
    static var sourceCodeURL: URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
