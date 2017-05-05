
//
//  Matrix.swift
//  Qubits
//
//  Created by Marc Davis on 4/30/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//
struct Matrix: CustomStringConvertible {
    let contents: [[ComplexNumber]]
    
    init(_ numbers: [[ComplexNumber]]) {
        contents = numbers
    }
    init(_ numbers: [[Double]]) {
        contents = numbers.map({$0.map({ComplexNumber(real: $0, imaginary: 0)})})
    }
    
    var description: String {
        var str = ""
        for row in contents {
            var rowstr = "|"
            for (i,c) in row.enumerated() {
                if i == row.count - 1 {
                    rowstr += "\(c)|\n"
                }
                else {
                    rowstr += "\(c)  "
                }
            }
            str += rowstr
        }
        return str
    }
    
    subscript(row: Int, column: Int) -> ComplexNumber {
        get {
            return contents[row][column]
        }
    }
    
    static func * (left: Matrix, right: Matrix) -> Matrix {
        //implement matrix-matrix multiplication
        
        var Mat = left.contents
        for i in 0..<left.contents.count {
            for j in 0..<right.contents.count {
                
                Mat[i][j] = left.getRow(index: i).dot(right.getCol(index: j))
                
            }
        }
        return Matrix(Mat)
    }
    
    func vectorMultiply(_ vec: Vector) -> Vector {
        //implement matrix-vector multiplication
        var sol = [ComplexNumber]()
        for i in 0..<self.contents.count {
            sol.append(self.getRow(index: i).dot(vec))
        }
        return Vector(sol)
        
    }
    func getRow(index: Int) -> Vector {
        // get a column of the matrix
        return Vector(self.contents[index])
    }
    
    func getCol(index: Int) -> Vector {
        // get a row of the matrix
        var vec = [ComplexNumber]()
        for i in 0..<self.contents.count {
            vec.append(self.contents[i][index])
        }
        return Vector(vec)
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
    func transpose() -> Matrix {
        //implement the conjugate transpose
        if contents.isEmpty {
            return Matrix(contents)
        }
        var conj = [[ComplexNumber]](repeating: [ComplexNumber](), count: contents[0].count)
        for row in contents {
            for (i, num) in row.enumerated() {
                conj[i].append(num)
            }
        }
        return Matrix(conj)
    }
    
    //scales all components by factor k
    func scale(k: ComplexNumber) -> Matrix {
        /*var scaled = [[ComplexNumber]]()
         for i in 0..<contents.count {
         scaled.append([ComplexNumber]())
         for j in 0..<contents[i].count {
         scaled[i][j] = k*contents[i][j]
         }
         }*/
        return Matrix(contents.map({$0.map({$0 * k})}))
    }
    
    
    func appendRight(_ right: Matrix) -> Matrix {
        if self.contents.isEmpty {
            return right
        } else if right.contents.isEmpty {
            return self
        }
        return Matrix(contents.enumerated().map({$0.1 + right.contents[$0.0]}))
    }
    
    
    func tensor(_ right: Matrix) -> Matrix {
        if self.contents.isEmpty || self.contents[0].isEmpty {
            return right
        } else if right.contents.isEmpty || self.contents[0].isEmpty {
            return self
        }
        
        //implement tensor product between self and right
        var tenMat = [[ComplexNumber]]()
        let ASize = self.contents.count
        let BSize = right.contents.count
        
        
        for i in 0..<ASize {
            var rowMat = Matrix([[ComplexNumber]]())
            for j in 0..<ASize {
                // print("(\(i), \(j))")
                let aij = self.contents[i][j]
                rowMat = rowMat.appendRight(_: right.scale(k: aij))
            }
            for j in 0..<BSize {
                tenMat.append(rowMat.contents[j])
            }
        }
        return Matrix(tenMat)
        
    }
}
