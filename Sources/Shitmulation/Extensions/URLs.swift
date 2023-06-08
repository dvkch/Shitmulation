//
//  URLs.swift
//  
//
//  Created by syan on 08/06/2023.
//

import Foundation

extension FileManager {
    internal static var currentFolder: URL {
        #if os(macOS)
        // root of source code project
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        #else
        // current path
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        #endif
    }
}

extension URL {
    #if os(macOS)
    internal func openInFinder() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [path]
        try! process.run()
        process.waitUntilExit()
    }
    #endif
}
