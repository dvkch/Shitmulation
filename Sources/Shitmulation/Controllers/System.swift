//
//  System.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

struct System {
    private static func getOutput(from path: String, arguments: [String]) -> String {
        var outputData = Data()
        let output = Pipe()
        defer {
            output.fileHandleForReading.closeFile()
            output.fileHandleForWriting.closeFile()
        }
        output.fileHandleForReading.readabilityHandler = {
            outputData.append($0.availableData)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        process.standardOutput = output
        try! process.run()
        process.waitUntilExit()

        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        return outputString.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    #if os(macOS)
    enum SysKey: String {
        case logicalPerformanceCores = "hw.perflevel0.logicalcpu_max"
    }
    
    static func sysctl(key: SysKey) -> String {
        let output = getOutput(from: "/usr/sbin/sysctl", arguments: [key.rawValue])
        return output.replacingOccurrences(of: key.rawValue + ": ", with: "")
    }
    #endif
    
    static var performanceCores: Int {
        #if os(macOS)
        let value = self.sysctl(key: .logicalPerformanceCores)
        return Int(value) ?? 4
        #else
        let value = getOutput(from: "/usr/bin/lscpu", arguments: ["--all", "--parse=CPU,SOCKET,CORE"])
        return value
            .split(separator: "\n")
            .filter { !$0.starts(with: "#") }
            .count
        #endif
    }
}
