//
//  UInt128.swift
//  Shitmulation
//
//  Created by syan on 29/05/2023.
//

import Foundation
import ShitmulationC

extension UInt128 {
    
    init(lo: UInt64, hi: UInt64) {
        self.init()
        self.lo = lo
        self.hi = hi
    }
    
    init(_ lo: UInt64) {
        self.init(lo: lo, hi: 0)
    }
    
    static func &+ (lhs: Self, rhs: Self) -> Self {
        return uint128_add(lhs, rhs)
    }
    
    static func &+ (lhs: Self, rhs: UInt32) -> Self {
        return uint128_add32(lhs, rhs)
    }
    
    static func &+= (lhs: inout Self, rhs: Self) {
        lhs = uint128_add(lhs, rhs)
    }
    
    static prefix func - (rhs: Self) -> Self {
        return uint128_neg(rhs)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        return uint128_add(lhs, rhs)
    }
    
    static func &* (lhs: Self, rhs: Self) -> Self {
        return uint128_mul(lhs, rhs)
    }
    
    static func &*= (lhs: inout Self, rhs: Self) {
        lhs = uint128_mul(lhs, rhs)
    }
    
    static func & (lhs: Self, rhs: UInt32) -> UInt32 {
        return uint128_and32(lhs, rhs)
    }
    
    static func & (lhs: Self, rhs: Self) -> Self {
        return uint128_and128(lhs, rhs)
    }
    
    static func | (lhs: Self, rhs: UInt32) -> Self {
        return uint128_or32(lhs, rhs)
    }
    
    static func | (lhs: Self, rhs: UInt128) -> Self {
        return uint128_or128(lhs, rhs)
    }
    
    static func << (lhs: Self, rhs: UInt32) -> Self {
        return uint128_shl(lhs, rhs)
    }
    
    static func >> (lhs: Self, rhs: UInt32) -> Self {
        return uint128_shr(lhs, rhs)
    }
    
    static func >>= (lhs: inout Self, rhs: UInt32) {
        lhs = uint128_shr(lhs, rhs)
    }
    
    // https://github.com/Jitsusama/UInt128/blob/master/Sources/UInt128/UInt128.swift
    var bigEndian: UInt128 {
#if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
        return self.byteSwapped
#else
        return self
#endif
    }
    
    var littleEndian: UInt128 {
#if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
        return self
#else
        return self.byteSwapped
#endif
    }
    
    var byteSwapped: UInt128 {
        return UInt128(
            lo: self.hi.byteSwapped,
            hi: self.lo.byteSwapped
        )
    }
    
    public static func masking(fromBit from: Int, toBit to: Int) -> UInt128 {
        var value: UInt128 = .init()
        for i in from..<to {
            value = value | (UInt128(1) << UInt32(i))
        }
        return value
    }
    
    func byte(at index: UInt8) -> Int {
        return byte_to_int64((uint128_byte(self, index)))
    }
    
    public var bin: String {
        return hi.bin + lo.bin
    }
}

extension UInt128: Comparable {
    @_transparent
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return uint128_lt(lhs, rhs)
    }

    @_transparent
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return uint128_eq(lhs, rhs)
    }
}
