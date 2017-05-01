//
//  Matrix.swift
//  Qubits
//
//  Created by Marc Davis on 4/30/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

struct Matrix {
    let contents: [[ComplexNumber]]
    
    init(_ numbers: [[ComplexNumber]]) {
        contents = numbers
    }
    
    static func * (left: Matrix, right: Matrix) -> Matrix {
        //implement matrix-matrix multiplication
        return left
    }
    
    func vectorMultiply(_ vec: Vector) -> Vector {
        //implement matrix-vector multiplication
        return vec
    }
    
    func conjugate() -> Matrix {
        //implement the conjugate transpose
        return self
    }
    
    //note: we could make this an operator if you guys come up with a good symbol to represent it.
    func tensor(_ right: Matrix) -> Matrix {
        //implement tensor product between self and right
        return self
    }
}
