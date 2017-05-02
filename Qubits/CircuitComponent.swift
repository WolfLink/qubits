//
//  CircuitComponent.swift
//  Qubits
//
//  Created by Marc Davis on 3/26/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit


protocol CircuitComponentDelegate: class {
    func addNewComponent(_ component: CircuitComponent)
    func moveComponent(_ component: CircuitComponent, to touch: UITouch, offset: CGPoint)
    func handlePlacement(component: CircuitComponent, at touch: UITouch, offset: CGPoint)
}

class CircuitComponent: UIView {
    enum DrawMode {
        case active, passive
    }
    let label: UILabel = UILabel(frame: CGRect.zero)
    var drawMode: DrawMode = .passive
    var moving: Bool = false
    static weak var delegate: CircuitComponentDelegate?
    weak var child: CircuitComponent?
    var links = [CircuitLink]()
    
    convenience init(dictionary dict: NSDictionary) {
        self.init(title: dict.value(forKey: "label") as! String)
    }
    
    convenience init(copy original: CircuitComponent) {
        let title: String
        if let text = original.label.text {
            title = text
        }
        else {
            title = ""
        }
        self.init(title: title, frame: original.frame)
    }
    
    init(title text:String, frame rect:CGRect = CGRect.zero) {
        super.init(frame: rect)
        label.text = text
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        label.text = ""
        addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = rect
        label.textAlignment = NSTextAlignment.center
        UIColor.white.setFill()
        UIColor.black.setStroke()
        let rectPath = UIBezierPath(rect: rect)
        rectPath.lineWidth = 10
        rectPath.fill()
        rectPath.stroke()
    }
    
    var startPoint = CGPoint.zero
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first
            if let point = touch?.location(in: self) {
                startPoint = point
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first
            if let point = touch?.location(in: self) {
                if moving && drawMode == DrawMode.active {
                    CircuitComponent.delegate?.moveComponent(self, to: touch!, offset: startPoint)
                }
                else if let component = child {
                    CircuitComponent.delegate?.moveComponent(component, to: touch!, offset: startPoint)
                }
                else if distanceFrom(startPoint, to: point) > 10 {
                    if drawMode == DrawMode.passive {
                        let newComponent = CircuitComponent(copy: self)
                        newComponent.drawMode = DrawMode.active
                        newComponent.moving = true
                        CircuitComponent.delegate?.addNewComponent(newComponent)
                        CircuitComponent.delegate?.moveComponent(newComponent, to: touch!, offset: startPoint)
                        self.child = newComponent
                    }
                    else if drawMode == DrawMode.active {
                        self.moving = true
                        CircuitComponent.delegate?.moveComponent(self, to: touch!, offset: startPoint)
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let component = child {
            CircuitComponent.delegate?.handlePlacement(component: component, at: touches.first!, offset: startPoint)
        }
        else if moving && drawMode == DrawMode.active {
            CircuitComponent.delegate?.handlePlacement(component: self, at: touches.first!, offset: startPoint)
        }
        child = nil
        moving = false
        startPoint = CGPoint.zero
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let component = child {
            CircuitComponent.delegate?.handlePlacement(component: component, at: touches.first!, offset: startPoint)
        }
        else if moving && drawMode == DrawMode.active {
            CircuitComponent.delegate?.handlePlacement(component: self, at: touches.first!, offset: startPoint)
        }
        child = nil
        moving = false
        startPoint = CGPoint.zero
    }
    
    func distanceFrom(_ a: CGPoint, to b: CGPoint) -> Double {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(Double(dx * dx + dy * dy))
    }
}
