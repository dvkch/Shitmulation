//
//  Parallel.swift
//  
//
//  Created by syan on 08/06/2023.
//

import Foundation

internal func parallelize<T>(count: Int, threads: Int, closure: @escaping (Int) -> (T)) -> [T] {
    let lock = NSLock()
    var results = [Int: T]()

    (0..<count).forEachParallel(threads: threads) { i in
        let result = autoreleasepool {
            closure(i)
        }

        lock.lock()
        results[i] = result
        lock.unlock()
    }
    
    return results.sorted(by: { $0.key < $1.key }).map(\.value)
}

extension Sequence {
    internal func forEachParallel(threads: Int, _ closure: @escaping (Element) -> ()) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = threads
        
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

