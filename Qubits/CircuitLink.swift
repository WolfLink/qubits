//
//  CircuitLink.swift
//  Qubits
//
//  Created by Marc Davis on 5/1/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

class CircuitLink: UIView {
    var owner: CircuitComponent
    var selected: Bool = false
    weak var partner: CircuitLink?
    let radius: CGFloat
    
    
    init(radius: CGFloat, owner: CircuitComponent) {
        self.radius = radius
        self.owner = owner
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2 + 4, height: radius * 2 + 4))
    }
    
    required init?(coder aDecoder: NSCoder) {
        NSLog("Do not use this initializer!  It is only included as a formality for Cocoa reasons.")
        return nil
    }
    

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let rect = CGRect(x: 2, y: 2, width: radius * 2, height: radius * 2)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: rect)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: rect)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            let x = point.x - frame.size.width/2
            let y = point.y - frame.size.height/2
            if sqrt(x * x + y * y) < radius {
                selected = true
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selected = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        selected = false
    }

}
