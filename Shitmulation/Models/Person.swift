//
//  Person.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

struct Person {
    
    // MARK: Properties
    typealias Traits = UInt128
    private(set) var traits: Traits = .init(lo: 0, hi: 0)

    static var traitsSize: Int {
        return MemoryLayout<Traits>.size
    }
    
    mutating func addTraits(_ branch: Tree.Branch.RawValue, treeIndex: Int) {
        let firstBitPosition = (Person.traitsSize * 8) - (treeIndex + 1) * Tree.Branch.length
        traits = traits | (UInt128(UInt64(branch)) << UInt32(firstBitPosition))
    }
    
    static func mask(forTraitAt traits: Int) -> Traits {
        return UInt128.masking(
            fromBit: (Person.traitsSize * 8) - traits,
            toBit:   (Person.traitsSize * 8)
        )
    }
    
    @inline(__always)
    fileprivate func write(into data: inout Data) {
        var swapped = self.traits.bigEndian
        let swappedData = Data(bytes: &swapped, count: MemoryLayout<UInt128>.size)
        data.append(swappedData)
    }
    
    @inline(__always)
    static func readTraits(from value: UInt128) -> Person.Traits {
        return value.bigEndian
    }
}

// MARK: Export
extension Collection where Element == Person, Index == Int {
    func writeToFile(url: URL, emptyFirst: Bool) throws {
        if emptyFirst || !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: Data())
        }
        
        let file = try FileHandle(forUpdating: url)
        try file.seekToEnd()

        defer { try? file.close() }
        
        let strideSize = 100_000 // it's faster to write big chunks at a time then small chunks very frequently
        try stride(from: 0, to: count, by: strideSize).forEach({ startIndex in
            let endIndex = (startIndex + strideSize).bound(min: 0, max: self.count)
            var data = Data()
            data.reserveCapacity(strideSize * Person.traitsSize)
            
            self[startIndex..<endIndex].forEach { p in
                p.write(into: &data)
            }
            try file.write(contentsOf: data)
        })
    }
}
