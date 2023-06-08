//
//  Tree.swift
//  Shitmulation
//
//  Created by syan on 22/05/2023.
//

import Foundation

struct Tree {
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
    
    private init(
        strataX: Int, indepA_B: Bool, indepC_B: Bool, indepC_A: Bool, indepC_AB: Bool,
        a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int
    ) {
        self.x = strataX
        self.indepA_B = indepA_B
        self.indepC_B = indepC_B
        self.indepC_A = indepC_A
        self.indepC_AB = indepC_AB

        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.f = f
        self.g = g
        self.h = x - a - b - c - d - e - f - g
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
    static var probabilityIndepA_B: Double = 0
    static var probabilityIndepC_B: Double = 0
    static var probabilityIndepC_A: Double = 0
    static var probabilityIndepC_AB: Double = 0

    static func generateValidTree(population: Int) -> Tree {
        let indepA_B  = Double.random(in: 0...1) > Tree.probabilityIndepA_B
        let indepC_B  = Double.random(in: 0...1) > Tree.probabilityIndepC_B
        let indepC_A  = Double.random(in: 0...1) > Tree.probabilityIndepC_A
        let indepC_AB = Double.random(in: 0...1) > Tree.probabilityIndepC_AB

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
    enum Branch: UInt8, CaseIterable {
        case a = 0b100
        case b = 0b010
        case c = 0b110
        case d = 0b101
        case e = 0b111
        case f = 0b011
        case g = 0b001
        case h = 0b000

        static var length: Int {
            return 3
        }
    }
    
    func generateBranches() -> [Tree.Branch.RawValue] {
        var branches = [Tree.Branch.RawValue]()
        branches.reserveCapacity(x)

        var gen = L64X128PRNG()
        if a > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.a.rawValue, count: a))
        }
        if b > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.b.rawValue, count: b))
        }
        if c > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.c.rawValue, count: c))
        }
        if d > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.d.rawValue, count: d))
        }
        if e > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.e.rawValue, count: e))
        }
        if f > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.f.rawValue, count: f))
        }
        if g > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.g.rawValue, count: g))
        }
        if h > 0 {
            branches.append(contentsOf: [UInt8](repeating: Tree.Branch.h.rawValue, count: h))
        }
        branches.shuffle(using: &gen)
        return branches
    }
}

// MARK: Strata
extension Tree {
    func strataSubtrees(count: Int) -> [Tree] {
        let subpopulation = x / count
        var trees = [Tree]()
        for _ in 0..<(count - 1) {
            let subtree = Tree(
                strataX: subpopulation, indepA_B: indepA_B, indepC_B: indepC_B, indepC_A: indepC_A, indepC_AB: indepC_AB,
                a: Int((Double(a) / Double(count)).rounded(.toNearestOrAwayFromZero)),
                b: Int((Double(b) / Double(count)).rounded(.toNearestOrAwayFromZero)),
                c: Int((Double(c) / Double(count)).rounded(.toNearestOrAwayFromZero)),
                d: Int((Double(d) / Double(count)).rounded(.toNearestOrAwayFromZero)),
                e: Int((Double(e) / Double(count)).rounded(.toNearestOrAwayFromZero)),
                f: Int((Double(f) / Double(count)).rounded(.toNearestOrAwayFromZero)),
                g: Int((Double(g) / Double(count)).rounded(.toNearestOrAwayFromZero))
            )
            trees.append(subtree)
        }
        
        let lastTree = Tree(
            strataX: x - trees.map(\.x).sum(),
            indepA_B: indepA_B, indepC_B: indepC_B, indepC_A: indepC_A, indepC_AB: indepC_AB,
            a: a - trees.map(\.a).sum(),
            b: b - trees.map(\.b).sum(),
            c: c - trees.map(\.c).sum(),
            d: d - trees.map(\.d).sum(),
            e: e - trees.map(\.e).sum(),
            f: f - trees.map(\.f).sum(),
            g: g - trees.map(\.g).sum()
        )
        trees.append(lastTree)
        return trees
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

extension Array where Element == Tree {
    func csvTrees() -> String {
        var csv = [String]()
        csv.append("Tree;scenario;a;b;c;d;e;f;g;h;")
        for (i, t) in self.enumerated() {
            csv.append("\(i + 1);\(t.scenario);\(t.a);\(t.b);\(t.c);\(t.d);\(t.e);\(t.f);\(t.g);\(t.h);")
        }
        return csv.joined(separator: "\n")
    }
}

extension Array where Element == [Tree] {
    func csvScenarios() -> String {
        var csvScenarios = [String]()
        csvScenarios.append("Tree;")
        for i in 1...16 {
            csvScenarios.append("\(i);")
        }

        for (i, iteration) in self.enumerated() {
            csvScenarios[0] += "Iteration \(i + 1);"
            for scenario in 1...16 {
                let count = iteration.filter { $0.scenario == scenario }.count
                csvScenarios[scenario] += "\(count);"
            }
        }
        
        return csvScenarios.joined(separator: "\n")
    }
}
