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
        return ComplexNumber(real: left.real*right.real - left.imaginary*right.imaginary, imaginary: left.real*right.imaginary + left.imaginary*right.real)
    }
    
    static func + (left: ComplexNumber, right: ComplexNumber) -> ComplexNumber {
        return ComplexNumber(real: left.real + right.real, imaginary: left.imaginary + right.imaginary)
    }
    
    static func / (left: ComplexNumber, right: Double) -> ComplexNumber {
        // implement division of a complex number by a real number
        return ComplexNumber(real: left.real/right, imaginary: left.imaginary/right)
    }
    func conjugate() -> ComplexNumber {
        // implmenet complex conjugate
        return ComplexNumber(real: self.real, imaginary: -self.imaginary)
        
    }
    func magnitude() -> Double {
        // implement magnitude of a complex number
        return magSquared().squareRoot()
    }
    func magSquared() -> Double {
        return self.real*self.real + self.imaginary*self.imaginary
    }
}
