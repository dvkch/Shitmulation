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

func benchmark<T>(_ message: String, closure: () -> T) -> T {
    let d = Date()
    let result = closure()
    print(message, Date().timeIntervalSince(d).durationString)
    return result
}

func benchmark<T>(_ closure: () -> T) -> (T, TimeInterval) {
    let d = Date()
    let result = closure()
    return (result, Date().timeIntervalSince(d))
}

func parallelize<T>(count: Int, concurrency: Int, closure: @escaping (Int) -> (T)) -> [T] {
    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    queue.maxConcurrentOperationCount = concurrency
    
    let group = DispatchGroup()
    let lock = NSLock()
    var results = [Int: T]()

    for i in 0..<count {
        group.enter()
        queue.addOperation {
            let result = closure(i)

            lock.lock()
            results[i] = result
            lock.unlock()

            group.leave()
        }
    }
    group.wait()
    
    return results.sorted(by: { $0.key < $1.key }).map(\.value)
}
