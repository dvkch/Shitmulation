//
//  PrettyPrint.swift
//  
//
//  Created by syan on 08/06/2023.
//

import Foundation

extension Int {
    public var amountString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.hasThousandSeparators = true
        formatter.thousandSeparator = " "
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension UInt64 {
    public var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.includesCount = true
        formatter.includesUnit = true
        return formatter.string(fromByteCount: Int64(self))
    }
}

extension TimeInterval {
    public var durationString: String {
        return String(format: "%.03lfs", self)
    }
}

extension DateFormatter {
    public static var isoString: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH'h'mm"
        df.timeZone = .current
        df.locale = .init(identifier: "en_US_POSIX")
        return df
    }
}

public var printLogs: Bool = true
public func log(_ message: String, newLine: Bool = true) {
    if printLogs {
        print(message, terminator: newLine ? "\n" : "")
    }
}

extension BinaryInteger {
    public var bin: String {
        let length = MemoryLayout<Self>.size * 8
        let binaryString = String(self, radix: 2)
        let padding = [String](repeating: "0", count: length - binaryString.count).joined()
        return padding + binaryString
    }
}
