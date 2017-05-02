//
//  QuantumProcess.swift
//  Qubits
//
//  Created by Marc Davis on 5/2/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

protocol QuantumProcess: class {
    
    func processVector(_ vector: Vector) -> Vector

}

class Gates: NSObject, QuantumProcess {
    let matrix: Matrix
    
    init(matrix: Matrix) {
        self.matrix = matrix
    }
    
    func processVector(_ vector: Vector) -> Vector {
        return matrix.vectorMultiply(vector)
    }
}


class Measurement: NSObject, QuantumProcess {
    let output: CircuitComponent
    let index: Int
    
    init(component: CircuitComponent, index i: Int) {
        output = component
        index = i
    }
    
    func processVector(_ vector: Vector) -> Vector {
        return vector
    }
}
