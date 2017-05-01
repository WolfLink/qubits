//
//  ComplexNumber.swift
//  Qubits
//
//  Created by Marc Davis on 4/30/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

struct ComplexNumber {
    let real: Double
    let imaginary: Double
    
    init(real r: Double, imaginary i: Double) {
        real = r
        imaginary = i
    }
    
    static func * (left: ComplexNumber, right: ComplexNumber) -> ComplexNumber {
        //implement complex number multiplication
        return left
    }
    
    static func / (left: ComplexNumber, right: Double) -> ComplexNumber {
        // implement division of a complex number by a real number
        return left
    }
    func conjugate() -> ComplexNumber {
        // implmenet complex conjugate
        return self
    }
    func magnitude() -> Double {
        // implement magnitude of a complex number
        return 0
    }
}
