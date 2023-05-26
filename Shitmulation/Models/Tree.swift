//
//  Tree.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

class Tree {
    // MARK: Init
    init(x: Int, indepA_B: Bool, indepC_B: Bool, indepC_A: Bool, indepC_AB: Bool) {
        assert(x % 4 == 0)
        
        self.x = x
        self.indepA_B = indepA_B
        self.indepC_B = indepC_B
        self.indepC_A = indepC_A
        self.indepC_AB = indepC_AB
        
        if indepA_B && indepC_B && indepC_A && indepC_AB {
            // TODO: check this up again later
            let abch = Int.random(in: 1..<x) / 4
            self.a = abch
            self.b = abch
            self.c = abch
            self.h = abch
            
            let defg = x / 4 - abch
            self.d = defg
            self.e = defg
            self.f = defg
            self.g = defg
        }
        else {
            let a = Int.random(in: 0..<x)
            let b = Int.random(in: 0..<x)
            let c = Int.random(in: 0..<x)
            let d = Int.random(in: 0..<x)
            let e = Int.random(in: 0..<x)
            let f = Int.random(in: 0..<x)
            let g = Int.random(in: 0..<x)
            let h = Int.random(in: 0..<x)
            
            let factor: Double = Double(x) / Double(a + b + c + d + e + f + g + h)
            
            self.a = Int(Double(a) * factor)
            self.b = Int(Double(b) * factor)
            self.c = Int(Double(c) * factor)
            self.d = Int(Double(d) * factor)
            self.e = Int(Double(e) * factor)
            self.f = Int(Double(f) * factor)
            self.g = Int(Double(g) * factor)
            self.h = self.x - self.a - self.b - self.c - self.d - self.e - self.f - self.g
        }
    }
    
    // MARK: Properties
    let indepA_B: Bool
    let indepC_B: Bool
    let indepC_A: Bool
    let indepC_AB: Bool
    
    let x: Int
    
    let a: Int
    let b: Int
    let c: Int
    let d: Int
    let e: Int
    let f: Int
    let g: Int
    let h: Int
    
    private var remainingBranches: [Tree.Branch] = []
    
    // MARK: Computed properties
    var eqG: Double {
        return Double(c + e) / Double(c + e + a + d)
    }
    var eqH: Double {
        return Double(b + f) / Double(b + f + g + h)
    }
    var eqI: Double {
        return Double(e + d) / Double(e + d + c + a)
    }
    var eqJ: Double {
        return Double(f + g) / Double(b + f + g + h)
    }
    var eqK: Double {
        return Double(e + f) / Double(e + f + b + c)
    }
    var eqL: Double {
        return Double(d + g) / Double(d + g + a + h)
    }
    var eqM: Double {
        guard e + c > 0 else { return 0 }
        return Double(e) / Double(e + c)
    }
    var eqN: Double {
        return Double(d + f + g) / Double(d + f + g + a + b + h)
    }
}

// MARK: Validation
extension Tree {
    static func generateValidTree(population: Int) -> Tree {
        let indepA_B  = Double.random(in: 0...1) > 0.4
        let indepC_B  = Double.random(in: 0...1) > 0.7
        let indepC_A  = Double.random(in: 0...1) > 0.7
        let indepC_AB = Double.random(in: 0...1) > 0.4

        var tree = Tree(x: population, indepA_B: indepA_B, indepC_B: indepC_B, indepC_A: indepC_A, indepC_AB: indepC_AB)
        
        while (!tree.isValid) {
            tree = Tree(x: population, indepA_B: indepA_B, indepC_B: indepC_B, indepC_A: indepC_A, indepC_AB: indepC_AB)
        }
        return tree
    }

    var isValid: Bool {
        // A
        guard a + c + d + e > 1 else { return false }
        guard a + c + d + e < x else { return false }
        
        // B
        guard b + h + f + g > 1 else { return false }
        guard b + h + f + g < x else { return false }
        
        // C
        guard b + c + e + f > 1 else { return false }
        guard b + c + e + f < x else { return false }
        
        // D
        guard a + h + d + g > 1 else { return false }
        guard a + h + d + g < x else { return false }
        
        // E
        guard d + e + f + g > 1 else { return false }
        guard d + e + f + g < x else { return false }
        
        // F
        guard a + b + c + h > 1 else { return false }
        guard a + b + c + h < x else { return false }
        
        // G => N
        for eq in [eqG, eqH, eqI, eqJ, eqK, eqL, eqM, eqN] {
            guard eq >= 0 && eq <= 1 else { return false }
        }
        
        let cond1 = validate(eqG, eqH, equal: indepA_B,  within: Tree.margin)
        let cond2 = validate(eqI, eqJ, equal: indepC_B,  within: Tree.margin)
        let cond3 = validate(eqK, eqL, equal: indepC_A,  within: Tree.margin)
        let cond4 = validate(eqM, eqN, equal: indepC_AB, within: Tree.margin)
        return cond1 && cond2 && cond3 && cond4
    }
    
    private static let margin: Double = 0.005
    private func validate(_ a: Double, _ b: Double, equal: Bool, within margin: Double) -> Bool {
        if equal {
            return fabs(a - b) <= margin
        }
        else {
            return fabs(a - b) > margin
        }
    }
}

// MARK: Populating
extension Tree {
    enum Branch {
        case a, b, c, d, e, f, g, h
        
        static let correspondance: [Branch: [Bool]] = [
            .a: [true,  false, false],
            .b: [false, true,  false],
            .c: [true,  true,  false],
            .d: [true,  false, true],
            .e: [true,  true,  true],
            .f: [false, true,  true],
            .g: [false, false, true],
            .h: [false, false, false],
        ]

        var traits: [Bool] {
            return type(of: self).correspondance[self]!
        }
    }

    func pickABranch() -> Tree.Branch {
        if remainingBranches.isEmpty {
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .a, count: a))
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .b, count: b))
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .c, count: c))
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .d, count: d))
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .e, count: e))
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .f, count: f))
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .g, count: g))
            remainingBranches.append(contentsOf: [Tree.Branch](repeating: .h, count: h))
            remainingBranches.shuffle()
        }
        
        // removeFirst() is too expensive, and since the array is shuffled it shouldn't change anything
        return remainingBranches.removeLast()
    }
}

// MARK: Export
extension Tree {
    var scenario: Int {
        return (
            indepA_B.int * 8 +
            indepC_B.int * 4 +
            indepC_A.int * 2 +
            indepC_AB.int +
            1
        )
    }
}

extension Array where Element == [Tree] {
    func csvExport() -> String {
        var csvScenarios = [String]()
        csvScenarios.append("Scenario;")
        for i in 1...16 {
            csvScenarios.append("\(i);")
        }

        for (i, iteration) in self.enumerated() {
            csvScenarios[0] += "\(i);"
            for scenario in 1...16 {
                let count = iteration.filter { $0.scenario == scenario }.count
                csvScenarios[scenario] += "\(count);"
            }
        }
        
        return csvScenarios.joined(separator: "\n")
    }
}
