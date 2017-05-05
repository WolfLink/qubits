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
    var cache: [QuantumProcess]?
    var inputCache: Vector?
    
    func invalidateCache() {
        cache = nil
        inputCache = nil
    }
    
    func runSimulation() {
        if let c = cache, let i = inputCache {
            var v = i
            for process in c {
                v = process.processVector(v)
            }
        }
    }
    
    func process(components: [CircuitComponent]) {
        // qubits are the only pieces that don't have both input and output
        let qubits = components.filter({$0.inputs.count == 0})
        inputCache = Vector(permuteQubits(qubits: qubits)).normalize()
        
        //each qubit has exactly one output, which is our starting point
        var nodes = qubits.map({$0.outputs[0]})
        
        var notDoneYet = true
        var process = [QuantumProcess]()
        while notDoneYet {
            notDoneYet = false
            // traverse the graph and assemble matrices
            var step = Matrix([[ComplexNumber]]())
            var pass = [Int]()
            var processed = [CircuitLink]()
            for i in 0 ..< nodes.count {
                if pass.contains(i) {
                    continue
                }
                let n = nodes[i]
                if let p = n.partner {
                    notDoneYet = true
                    
                    let gate = p.owner
                    if gate.type == "output" {
                        // for output qubits, insert a measurement process before this iteration of gates and use an identity for this iteration of gates
                        process.append(Measurement(component: gate, index: i))
                        step = step.tensor(matrixForID("Identity"))
                        nodes[i] = gate.outputs[0]
                        processed.append(nodes[i])
                    }
                    else if gate.inputs.count == 1 {
                        let newMat = matrixForID(gate.ID)
                        step = step.tensor(newMat)
                        nodes[i] = gate.outputs[0] // move on to the next node
                        processed.append(nodes[i])
                    }
                    else if gate.inputs.count == 2 {
                        let index = gate.inputs.index(of: p)!
                        let friend = gate.inputs[1 - index] // this will give 1 if index==0 and 0 if index==1
                        if nodes.contains(friend.partner!) && !processed.contains(friend.partner!) {
                            // the other input is ready to apply the gate
                            if index == 0 {
                                // if the index of this qubit is 1, let the other responsible qubit be in charge
                                // but if the index is 0, this qubit is in charge
                                let j: Int! = nodes.index(of: friend.partner!)
                                if j == i + 1 {
                                    // the nodes are in position so we don't have to worry about any swapping
                                    step = step.tensor(matrixForID(gate.ID))
                                    nodes[i] = gate.outputs[0]
                                    nodes[j] = gate.outputs[1]
                                    pass.append(j)
                                    processed.append(nodes[i])
                                    processed.append(nodes[j])
                                }
                                else if j == i - 1 {
                                    // the nodes are switched so we have to swap our gate
                                    let mat = matrixForID("Swap") * matrixForID(gate.ID) * matrixForID("Swap")
                                    print(mat)
                                    step = step.tensor(mat)
                                    nodes[i] = gate.outputs[0]
                                    nodes[j] = gate.outputs[1]
                                    pass.append(j)
                                    processed.append(nodes[i])
                                    processed.append(nodes[j])
                                }
                                else {
                                    NSLog("Implied swaps have not yet been implemented!")
                                }
                            }
                        }
                        else {
                            // the other input node isn't ready yet, so insert an identity
                            step = step.tensor(matrixForID("Identity"))
                            processed.append(nodes[i])
                        }
                    }
                }
                else {
                    // no more gates so processes this qubit with an identity
                    step = step.tensor(matrixForID("Identity"))
                }
            }
            process.append(Gates(matrix: step))
        }
        cache = process
        
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
        case "Swap" :
            return Matrix([[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]])
        case "Hadamard":
            return Matrix([[vrt2,vrt2],[vrt2,-vrt2]])
        case "Pauli-X":
            return Matrix([[0,1],[1,0]])
        case "Pauli-Y":
            return Matrix([[ComplexNumber.zero, -ComplexNumber.i],[ComplexNumber.i,ComplexNumber.zero]])
        case "Pauli-Z":
            return Matrix([[1,0],[0,-1]])
        case "Controlled Not":
            return Matrix([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]])
        case "Controlled Y":
            // this is a long one so I am defining these constants for readability's sake
            let c1 = ComplexNumber.one
            let c0 = ComplexNumber.zero
            let ci = ComplexNumber.i
            return Matrix([[c1,c0,c0,c0],[c0,c1,c0,c0],[c0,c0,c0,-ci],[c0,c0,ci,c0]])
        case "Controlled Z":
            return Matrix([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]])
        case "Controlled Not":
            return Matrix([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]])
        default:
            NSLog("Unrecognized gate type \(ID)")
            return Matrix([[ComplexNumber]]())
        }
    }
    
    func permuteQubits(qubits: [CircuitComponent]) -> [ComplexNumber] {
        var current = [ComplexNumber]()
        for q in qubits.reversed() {
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
