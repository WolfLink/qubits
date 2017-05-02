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
    init(_ numbers: [[Double]]) {
        contents = numbers.map({$0.map({ComplexNumber(real: $0, imaginary: 0)})})
    }
    
    subscript(row: Int, column: Int) -> ComplexNumber {
        get {
            return contents[row][column]
        }
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
        if contents.isEmpty {
          return Matrix(contents)
        }
        var conj = [[ComplexNumber]](repeating: [ComplexNumber](), count: contents[0].count)
        for row in contents {
          for (i, num) in row.enumerated() {
            conj[i].append(num.conjugate())
          }
        }
        return Matrix(conj)
    }

    //scales all components by factor k
    func scale(k: ComplexNumber) -> Matrix {
      var scaled = [[ComplexNumber]]()
      for i in 0..<contents.count {
        scaled.append([ComplexNumber]())
        for j in 0..<contents[i].count {
          scaled[i][j] = k*contents[i][j]
        }
      }
      return Matrix(scaled)
    }
    
    
    func appendRight(_ right: Matrix) -> Matrix {
        return Matrix(contents.enumerated().map({$0.1 + right.contents[$0.0]}))
    }

    //appends another matrix to the right of this one and returns it
    /*func appendRight(right: Matrix) -> Matrix {
      if contents.isEmpty {
        return right
      }
      if right.contents.isEmpty {
        return self
      }
      let temp = ComplexNumber(real: 0, imaginary: 0)
      let halfWidth = contents[0].count
      let width = halfWidth + right.contents[0].count
      var combined = [[ComplexNumber]](repeating: [ComplexNumber](repeating: temp, count: width), count: contents.count)

      for (i, row) in contents.enumerated() {
        for (j, num) in row.enumerated() {
          combined[i][j] = num
        }
        for (j, num) in right.contents[i].enumerated() {
          combined[i][j + halfWidth] = num
        }
      }
      return Matrix(combined)
    }*/

    //note: we could make this an operator if you guys come up with a good symbol to represent it.
    func tensor(_ right: Matrix) -> Matrix {
        //implement tensor product between self and right
        //let topL =
        return right
    }
}
