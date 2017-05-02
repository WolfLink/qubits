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
        //let newVector = matrix.vectorMultiply(vector)
        //NSLog("before: \(vector.debugString()) after: \(newVector.debugString())")
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
        let picked = pickIndex(vector: vector)
        //NSLog("picked: \(picked) for index \(index)")
        let length = vector.contents.count
        if index < 0 {
            NSLog("measurement failed")
            return vector
        }
        
        let result = posForIndex(i: picked, j: index, length: length)
        NSLog("result \(result) for index \(index) and picked \(picked)")
        output.label.text = result ? "1" : "0"
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        
        let newVector = Vector(vector.contents.enumerated().map({posForIndex(i: $0.0, j: index, length: length) == result ? $0.1 : ComplexNumber(real: 0, imaginary: 0)})).normalize()
        
        return newVector
    }
    
    func posForIndex(i: Int, j: Int, length: Int) -> Bool {
        if i == 0 {
            return false
        }
        return Int(floor(Double(i) / (Double(length) / pow(2, Double(j + 1))))) % 2 != 0
    }
    
    func pickIndex(vector: Vector) -> Int {
        let value = Int(arc4random_uniform(1000000000))
        //NSLog("today's random \(value)")
        var current = 0
        for (i, v) in vector.contents.enumerated() {
            let ms = v.magSquared()
            if ms > 0.000000001 { // if its less than that number I'll consider it zero
                current += Int(ms * 1000000000)
                if value < current {
                    return i
                }
            }
        }
        NSLog("something went wrong with finding an index in the vector")
        return -1
    }
}
