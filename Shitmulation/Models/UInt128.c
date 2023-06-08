//
//  UInt128.c
//  Shitmulation
//
//  Created by syan on 29/05/2023.
//

#include "UInt128.h"

bool
uint128_lt(UInt128 a, UInt128 b) {
    return a.value < b.value;
}

bool
uint128_eq(UInt128 a, UInt128 b) {
    return a.value == b.value;
}
