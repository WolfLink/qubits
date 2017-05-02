//
//  Linker.swift
//  Qubits
//
//  Created by Marc Davis on 5/1/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

class Linker: UIView {
    weak var selectedLink: CircuitLink?
    var selectedPoint = CGPoint.zero
    var links = [CircuitLink]()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(4)
            for link in links {
                context.beginPath()
                context.move(to: link.owner.convert(link.center, to: self))
                context.addLine(to: link.partner!.owner.convert(link.partner!.center, to: self))
                context.strokePath()
            }
            
            if let link = selectedLink {
                context.beginPath()
                context.move(to: link.owner.convert(link.center, to: self))
                context.addLine(to: selectedPoint)
                context.strokePath()
            }
        }
    }
 

}
