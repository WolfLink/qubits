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
    
    func dot(_ other: Vector) -> Double {
        //implement the dot product between two vectors
        return 0
    }
    func magnitude() -> Double {
        // implement taking the magnitude of a complex vector
        return self.dot(self)
    }
    func normalize() -> Vector {
        // normalize a vector
        return self
    }
    func conjugate() -> Vector {
        // implement taking the complex conjugate of a vector
        return self
    }
}
