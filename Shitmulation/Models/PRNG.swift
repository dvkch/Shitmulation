//
//  PRNG.swift
//  Shitmulation
//
//  Created by syan on 27/05/2023.
//

import Foundation

// https://forums.swift.org/t/are-swifts-random-number-generators-able-to-work-concurrently/33801/5
// from https://github.com/apple/swift/blob/ce452f75f3d76b29c52bccbdbf8e9529f0b41a24/benchmark/utils/TestsUtils.swift#L254
public struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    public init() {
        state = .random(in: 0...UInt64.max)
    }

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        self.state &+= 0x9e3779b97f4a7c15
        var z: UInt64 = self.state
        z = (z ^ (z &>> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z &>> 27)) &* 0x94d049bb133111eb
        return z ^ (z &>> 31)
    }
}

// https://dl.acm.org/doi/abs/10.1145/3485525
// from chat gpt and https://github.com/xavierleroy/pringo/commit/2e60db30cc16a7d6ed6be3cebeaae006bff31c56
struct L64X128PRNG: RandomNumberGenerator {
    let M: UInt64 = 0xd1342543de82ef95
    struct LXMState {
        var a: UInt64
        var s: UInt64
        var x: (UInt64, UInt64)
        
        init(a: UInt64, s: UInt64, x: (UInt64, UInt64)) {
            self.a = a
            self.s = s
            self.x = x
        }

        init() {
            var generator = SystemRandomNumberGenerator()

            // Ensure a is odd
            a = 0
            while a % 2 == 0 {
                a = generator.next()
            }
            s = generator.next()

            // Ensure x[0] and x[1] are non-zero
            x = (0, 0)
            while x.0 == 0 {
                x.0 = generator.next()
            }
            while x.1 == 0 {
                x.1 = generator.next()
            }
        }
    }
    private var state: LXMState
    
    init(seed: LXMState = .init()) {
        state = seed
    }
    
    func rotl(_ x: UInt64, _ k: Int) -> UInt64 {
        return (x &<< k) | (x &>> (64 - k))
    }
    
    mutating func next() -> UInt64 {
        /* Combining operation */
        var z = state.s &+ state.x.0
 
        /* Mixing function */
        z = (z ^ (z >> 32)) &* 0xdaba0b6eb09322e3
        z = (z ^ (z >> 32)) &* 0xdaba0b6eb09322e3
        z = (z ^ (z >> 32))
        
        /* LCG update */
        state.s = state.s &* M &+ state.a
        
        /* XBG update */
        var q0 = state.x.0
        var q1 = state.x.1
        q1 ^= q0
        q0 = rotl(q0, 24)
        q0 = q0 ^ q1 ^ (q1 << 16)
        q1 = rotl(q1, 37)
        state.x.0 = q0
        state.x.1 = q1
        
        return z
    }
}


