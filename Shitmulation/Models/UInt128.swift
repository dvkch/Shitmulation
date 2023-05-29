//
//  UInt128.swift
//  Shitmulation
//
//  Created by syan on 29/05/2023.
//

import Foundation

public extension UInt128 {

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

    static func << (lhs: Self, rhs: UInt32) -> Self {
        return uint128_shl(lhs, rhs)
    }

    static func >> (lhs: Self, rhs: UInt32) -> Self {
        return uint128_shr(lhs, rhs)
    }

    static func >>= (lhs: inout Self, rhs: UInt32) {
        lhs = uint128_shr(lhs, rhs)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        return uint128_lt(lhs, rhs)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return uint128_eq(lhs, rhs)
    }
    
    static func != (lhs: Self, rhs: Self) -> Bool {
        return uint128_neq(lhs, rhs)
    }
}
