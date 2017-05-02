//
//  Quantum.swift
//  Qubits
//
//  Created by Marc Davis on 5/2/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

class Quantum: NSObject {
    let vrt2 = 1/sqrt(2)
    
    func process(components: [CircuitComponent]) {
        // qubits are the only pieces that don't have both input and output
        let qubits = components.filter({$0.inputs.count == 0})
        let inputVector = Vector(permuteQubits(qubits: qubits)).normalize()
        
        //each qubit has exactly one output, which is our starting point
        var nodes = qubits.map({$0.outputs[0]})
        
        var notDoneYet = true
        var totalMatrix = Matrix([[ComplexNumber]]())
        while notDoneYet {
            notDoneYet = false
            // traverse the graph and assemble matrices
            var step = Matrix([[ComplexNumber]]())
            for i in 0 ..< nodes.count {
                let n = nodes[i]
                if let p = n.partner {
                    notDoneYet = true
                    
                    let gate = p.owner
                    if gate.inputs.count == 1 {
                        let newMat = matrixForID(gate.ID)
                        if i == 0 {
                            step = newMat
                        }
                        else {
                            step = totalMatrix.tensor(newMat)
                        }
                    }
                }
            }
        }
        
       // 1/sqrtn
    }
    
    
    func valueForQubitType(_ type: String) -> (ComplexNumber, ComplexNumber) {
        switch type {
        case "One":
            return (ComplexNumber(real: 0, imaginary: 0), ComplexNumber(real: 1, imaginary: 0))
        case "Zero":
            return (ComplexNumber(real: 1, imaginary: 0), ComplexNumber(real: 0, imaginary: 0))
        case "Plus":
            return (ComplexNumber(real: vrt2, imaginary: 0), ComplexNumber(real: vrt2, imaginary: 0))
        case "Minus":
            return (ComplexNumber(real: vrt2, imaginary: 0), ComplexNumber(real: -vrt2, imaginary: 0))
        default:
            NSLog("Unrecognized qubit type \(type)")
            return (ComplexNumber(real: 0, imaginary: 0), ComplexNumber(real: 0, imaginary: 0))
        }
    }
    
    func matrixForID(_ ID: String) -> Matrix {
        switch ID {
        case "Identity":
            return Matrix([[1,0],[0,1]])
        case "Hadamard":
            return Matrix([[vrt2,vrt2],[vrt2,-vrt2]])
        default:
            NSLog("Unrecognized gate type \(ID)")
            return Matrix([[ComplexNumber]]())
        }
    }
    
    func permuteQubits(qubits: [CircuitComponent]) -> [ComplexNumber] {
        var current = [ComplexNumber]()
        for q in qubits {
            let (a,b) = valueForQubitType(q.ID)
            if current.count == 0 {
                current = [a,b]
            }
            else {
                current = current.map({$0 * a}) + current.map({$0 * b})
            }
        }
        return current
    }
}
