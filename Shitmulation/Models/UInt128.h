//
//  UInt128.h
//  Shitmulation
//
//  Created by syan on 29/05/2023.
//

#pragma once

#ifndef __UInt128_H__
#define __UInt128_H__
#include <stdbool.h>
#include <stdint.h>

typedef union {
    __uint128_t value;
    struct {
        uint64_t lo;
        uint64_t hi;
    };
} UInt128;


inline __attribute__((always_inline))
UInt128
uint128_add(UInt128 a, UInt128 b) {
    UInt128 r = { a.value + b.value };
    return r;
}


inline __attribute__((always_inline))
UInt128
uint128_neg(UInt128 a) {
    UInt128 r = { -a.value };
    return r;
}


inline __attribute__((always_inline))
UInt128
uint128_add32(UInt128 a, uint32_t b) {
    UInt128 r = { a.value + b };
    return r;
}


inline __attribute__((always_inline))
UInt128
uint128_mul(UInt128 a, UInt128 b) {
    UInt128 r = { a.value * b.value };
    return r;
}


inline __attribute__((always_inline))
uint32_t
uint128_and32(UInt128 a, uint32_t b) {
    return a.value & b;
}

inline __attribute__((always_inline))
UInt128
uint128_and128(UInt128 a, UInt128 b) {
    UInt128 r = { a.value & b.value };
    return r;
}

inline __attribute__((always_inline))
UInt128
uint128_or32(UInt128 a, uint32_t b) {
    UInt128 r = { a.value | b };
    return r;
}

inline __attribute__((always_inline))
UInt128
uint128_or128(UInt128 a, UInt128 b) {
    UInt128 r = { a.value | b.value };
    return r;
}

inline __attribute__((always_inline))
UInt128
uint128_shl(UInt128 a, uint32_t b) {
    UInt128 r = { a.value << b };
    return r;
}


inline __attribute__((always_inline))
UInt128
uint128_shr(UInt128 a, uint32_t b) {
    UInt128 r = { a.value >> b };
    return r;
}

extern bool
uint128_lt(UInt128 a, UInt128 b);

extern bool
uint128_eq(UInt128 a, UInt128 b);

inline __attribute__((always_inline))
uint8_t
uint128_byte(UInt128 value, uint8_t index) {
    return (uint8_t)(value.value >> (index * 8));
}

inline __attribute__((always_inline))
size_t
byte_to_int64(uint8_t byte) {
    return byte;
}

#endif
