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
    func cancelPlacement(component: CircuitComponent)
}

class CircuitComponent: UIView {
    
    let linkRadius: CGFloat = 25
    
    enum DrawMode {
        case active, passive
    }
    let label: UILabel = UILabel(frame: CGRect.zero)
    let ID: String
    var moving: Bool = false
    static weak var delegate: CircuitComponentDelegate?
    weak var child: CircuitComponent?
    var inputs = [CircuitLink]()
    var outputs = [CircuitLink]()
    
    var drawMode: DrawMode = .passive {
        didSet {
            if drawMode == .passive {
                for view in inputs {
                    view.removeFromSuperview()
                }
                for view in outputs {
                    view.removeFromSuperview()
                }
            }
            else {
                if inputs.count == 2 {
                    inputs[0].center = CGPoint(x: 0, y: frame.height)
                    inputs[1].center = CGPoint(x: 0, y: 0)
                }
                else if inputs.count == 1 {
                    inputs[0].center = CGPoint(x: 0, y: frame.height / 2)
                }
                if outputs.count == 2 {
                    outputs[0].center = CGPoint(x: frame.width, y: frame.height)
                    outputs[1].center = CGPoint(x: frame.width, y: 0)
                }
                else if outputs.count == 1 {
                    outputs[0].center = CGPoint(x: frame.width, y: frame.height / 2)
                }
                
                for v in inputs {
                    addSubview(v)
                }
                for v in outputs {
                    addSubview(v)
                }
                
                /*
                let inputOffset = self.frame.height / CGFloat(inputs.count + 1)
                for i in 0..<inputs.count {
                    let offset = inputOffset * CGFloat(i + 1)
                    inputs[i].center = CGPoint(x: 0, y: offset)
                    addSubview(inputs[i])
                }
                let outputOffset = self.frame.height / CGFloat(outputs.count + 1)
                for i in 0..<outputs.count {
                    let offset = outputOffset * CGFloat(i + 1)
                    outputs[i].center = CGPoint(x: frame.size.width, y: offset)
                    addSubview(outputs[i])
                }
                */
            }
        }
    }
    
    
    
    // initializers
    init(dictionary dict: NSDictionary) {
        //self.init(title: dict.value(forKey: "label") as! String)
        ID = dict.value(forKey: "name") as! String
        super.init(frame: CGRect.zero)
        label.text = dict.value(forKey: "label") as? String
        addSubview(label)
        if let type = dict.value(forKey: "type") as? String {
            let qubits = dict.value(forKey: "qubits") as! Int
            inputs = []
            outputs = []
            if type == "input" || type == "gate" {
                for _ in 0..<qubits {
                    let output = CircuitLink(radius: linkRadius, owner: self, outputActive: true)
                    outputs.append(output)
                }
            }
            if type == "output" || type == "gate" {
                for _ in 0..<qubits {
                    inputs.append(CircuitLink(radius: linkRadius, owner: self, outputActive: false))
                }
            }
        }
    }
    
    init(copy original: CircuitComponent) {
        ID = original.ID
        super.init(frame: original.frame)
        label.text = original.label.text
        addSubview(label)
        inputs = []
        outputs = []
        for _ in original.inputs {
            inputs.append(CircuitLink(radius: linkRadius, owner: self, outputActive: false))
        }
        for _ in original.outputs {
            outputs.append(CircuitLink(radius: linkRadius, owner: self, outputActive: true))
        }
    }
    
    /*init(title text:String, frame rect:CGRect = CGRect.zero) {
        super.init(frame: rect)
        label.text = text
        addSubview(label)
    }*/
    
    required init?(coder aDecoder: NSCoder) {
        NSLog("You should not be using this initializer!  It is just a formality to comply with Cocoa")
        return nil
    }
    
    // custom drawing
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
    
    // handling touches and duplication
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
                if let _ = hitTest(point, with: nil) as? CircuitLink {
                    super.next?.touchesMoved(touches, with: event)
                }
                
                if moving && drawMode == DrawMode.active {
                    CircuitComponent.delegate?.moveComponent(self, to: touch!, offset: startPoint)
                }
                else if let component = child {
                    CircuitComponent.delegate?.moveComponent(component, to: touch!, offset: startPoint)
                }
                else if startPoint.distanceTo(point) > 10 {
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
}
