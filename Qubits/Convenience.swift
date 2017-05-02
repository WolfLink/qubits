//
//  Convenience.swift
//  Qubits
//
//  Created by Marc Davis on 5/1/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import Foundation
import UIKit


// a place to put general utility functions and class extensions

extension CGPoint {
    func distanceTo(_ other: CGPoint) -> CGFloat {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }
}


enum UnimplemntedFunction: Error {
    case unusedInitializer
}
