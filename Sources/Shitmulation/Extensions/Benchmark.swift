//
//  Benchmark.swift
//  
//
//  Created by syan on 08/06/2023.
//

import Foundation

public func benchmark<T>(_ message: String, closure: () -> T) -> T {
    let d = Date()
    let result = closure()
    log(message + " " + Date().timeIntervalSince(d).durationString)
    return result
}

public func benchmark<T>(_ message: String? = nil, _ closure: () -> T) -> (T, TimeInterval) {
    let d = Date()
    let result = closure()
    if let message {
        log(message + " " + Date().timeIntervalSince(d).durationString)
    }
    return (result, Date().timeIntervalSince(d))
}
