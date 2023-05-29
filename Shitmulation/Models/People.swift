//
//  People.swift
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
    
    mutating func addTraits(_ branch: Tree.Branch.RawValue, position: Int) {
        // TODO: rewrite in a single C function maybe?
        let positionsPer64 = 64 - (64 % Tree.Branch.length)
        if position < positionsPer64 {
            traits.lo = traits.lo | (UInt64(branch) &<< (position))
        }
        else {
            traits.hi = traits.hi | (UInt64(branch) &<< (position - positionsPer64))
        }
    }
    
    static func mask(forTraitAt trait: Int, reverse: Bool = false) -> Traits {
        if reverse {
            return UInt128(
                lo: UInt64.masking(from: (128 - trait).bound(min: 0, max: 64), to: 64),
                hi: UInt64.masking(from: (64 - trait).bound(min: 0, max: 64), to: 64)
            )
        }
        else {
            // TODO: validate
            return UInt128(
                lo: UInt64.masking(from: 0, to: trait.bound(min: 0, max: 64)),
                hi: UInt64.masking(from: 0, to: (trait - 64).bound(min: 0, max: 64))
            )
        }
    }
    
    func write(into data: inout Data) {
        // faster than a simple '+'
        data.append(traits.hi.data)
        data.append(traits.lo.data)
    }
}

extension Person {
    // TODO: add actual tests ?
    static func test() {
        var p = Person()
        
        for i in 0..<42 {
            p.addTraits(Tree.Branch.e.rawValue, position: i * 3)
            
            var data = Data()
            p.write(into: &data)
            data.enumerated().forEach { i, byte in
                print(byte.bin, terminator: i == data.count - 1 ? "\n" : "")
            }
        }
        
        print("-------")
        
        for i in 0..<128 {
            let traitsMask = (
                hi: UInt64.masking(from: 0, to: (i - 64).bound(min: 0, max: 64)),
                lo: UInt64.masking(from: 0, to: i.bound(min: 0, max: 64))
            )
            print(traitsMask.hi.bin, terminator: "")
            print(traitsMask.lo.bin)
        }
    }
}

// MARK: Couting unique
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
