//
//  CircuitLink.swift
//  Qubits
//
//  Created by Marc Davis on 5/1/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

protocol CircuitLinkDelegate: class {
    func attemptLinkageFrom(_ link: CircuitLink, toTouch touch: UITouch)
    func draggedFrom(_ link: CircuitLink, toTouch touch: UITouch)
    func stopDragFrom(_ link: CircuitLink, atTouch touch: UITouch)
}

class CircuitLink: UIView {
    static weak var delegate: CircuitLinkDelegate?
    
    var owner: CircuitComponent
    var selected: Bool = false
    weak var partner: CircuitLink?
    let radius: CGFloat
    let output: Bool
    
    
    init(radius: CGFloat, owner: CircuitComponent, outputActive: Bool) {
        self.radius = radius
        self.owner = owner
        output = outputActive
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2 + 8, height: radius * 2 + 8))
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        NSLog("Do not use this initializer!  It is only included as a formality for Cocoa reasons.")
        return nil
    }
    

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let rect = CGRect(x: 4, y: 4, width: radius * 2, height: radius * 2)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: rect)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(1.5)
            context.strokeEllipse(in: rect)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            let x = point.x - frame.size.width/2
            let y = point.y - frame.size.height/2
            /*if sqrt(x * x + y * y) < radius + 5 {
                selected = true
            }*/
            selected = true
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, selected {
            CircuitLink.delegate?.draggedFrom(self, toTouch: touch)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if selected {
                CircuitLink.delegate?.attemptLinkageFrom(self, toTouch: touch)
            }
            CircuitLink.delegate?.stopDragFrom(self, atTouch: touch)
        }
        selected = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            CircuitLink.delegate?.stopDragFrom(self, atTouch: touch)
        }
        selected = false
    }

}
