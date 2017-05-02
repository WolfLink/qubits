//
//  Vector.swift
//  Qubits
//
//  Created by Marc Davis on 4/30/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

struct Vector {
    let contents: [ComplexNumber]
    
    init(_ numbers: [ComplexNumber]) {
        contents = numbers
    }
    
    static func /(left: Vector, right: Double) -> Vector {
        return Vector(left.contents.map({$0 / right}))
    }
    static func * (left: Vector, right: ComplexNumber) -> Vector {
        return Vector(left.contents.map({$0 * right}))
    }
    
    func dot(_ other: Vector) -> ComplexNumber {
        //implement the dot product between two vectors
        var pdct = ComplexNumber(real: 0, imaginary: 0)
        for i in 0..<contents.count {
            pdct = pdct + self.contents[i].conjugate()*other.contents[i]
        }
        return pdct
        
    }
    func magnitude() -> Double {
        // implement taking the magnitude of a complex vector
        var total = 0.0
        for number in contents {
            total += number.magSquared()
        }
        return total.squareRoot()
    }
    func normalize() -> Vector {
        return self / magnitude()
    }
    func conjugate() -> Vector {
        // implement taking the complex conjugate of a vector
        var vec = self.contents
        
        for i in 0..<contents.count {
            vec[i] = vec[i].conjugate()
        }
        return Vector(vec)
    }
}
