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

func centerOfTouches(_ touches:Set<UITouch>, inView view:UIView) -> CGPoint {
    var centerx: CGFloat = 0
    var centery: CGFloat = 0
    
    for touch in touches {
        let point = touch.location(in: view)
        centerx += point.x
        centery += point.y
    }
    
    return CGPoint(x: centerx / CGFloat(touches.count), y: centery / CGFloat(touches.count))
}
