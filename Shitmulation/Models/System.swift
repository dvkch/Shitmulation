//
//  System.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

struct System {
    enum SysKey: String {
        case logicalPerformanceCores = "hw.perflevel0.logicalcpu_max"
    }
    
    static func value(forSys key: SysKey) -> String {
        var outputData = Data()
        let output = Pipe()
        output.fileHandleForReading.readabilityHandler = {
            outputData.append($0.availableData)
        }

         let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysctl")
        process.arguments = [key.rawValue]
        process.standardOutput = output
        try! process.run()
        process.waitUntilExit()

        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        return outputString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: key.rawValue + ": ", with: "")
    }
    
    static var performanceCores: Int {
        let value = self.value(forSys: .logicalPerformanceCores)
        return Int(value) ?? 4
    }
}
