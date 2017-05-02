//
//  ViewController.swift
//  Qubits
//
//  Created by Marc Davis on 3/26/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CircuitComponentDelegate, CircuitLinkDelegate {
    @IBOutlet weak var toolbar: CircuitToolbar?
    @IBOutlet weak var linker: Linker?
    var blocks = [CircuitComponent]()
    let simulator: Quantum = Quantum()
    
    @IBAction func run() {
        if !simulator.runSimulation() {
            simulator.process(components: blocks)
        }
    }
    
    @IBAction func trash() {
        blocks = [CircuitComponent]()
        linker?.links = [CircuitLink]()
        linker?.selectedLink = nil
        linker?.selectedPoint = CGPoint.zero
        simulator.invalidateCache()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let tool = toolbar {
            tool.scrollView.frame = CGRect(origin: CGPoint.zero, size: tool.frame.size)
            tool.scrollView.contentSize = tool.contentSize
            tool.scrollView.alwaysBounceHorizontal = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CircuitComponent.delegate = self
        CircuitLink.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if CircuitComponent.delegate as? ViewController == self {
            CircuitComponent.delegate = nil
        }
        if CircuitLink.delegate as? ViewController == self {
            CircuitLink.delegate = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var lastTouch = CGPoint.zero
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = centerOfTouches(touches, inView: view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTouch = centerOfTouches(touches, inView: view)
        for block in blocks {
            block.center = CGPoint(x: block.center.x + currentTouch.x - lastTouch.x, y: block.center.y + currentTouch.y - lastTouch.y)
        }
        lastTouch = currentTouch
        linker?.setNeedsDisplay()
    }
    
    func addNewComponent(_ component: CircuitComponent) {
        linker?.addSubview(component)
        blocks.append(component)
        if let tool = toolbar {
            self.view.bringSubview(toFront: tool)
        }
    }
    func moveComponent(_ component: CircuitComponent, to touch: UITouch, offset: CGPoint) {
        let point = touch.location(in: view)
        component.frame.origin = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
        toolbar?.scrollView.isScrollEnabled = false
        
        
        // have the linker redraw since nodes could have moved
        linker?.setNeedsDisplay()
       
    }
    func handlePlacement(component: CircuitComponent, at touch: UITouch, offset: CGPoint) {
        if let tool = toolbar {
            if tool.frame.contains(touch.location(in: self.view)) {
                component.removeFromSuperview()
                if let index = blocks.index(of: component) {
                    blocks.remove(at: index)
                }
                for input in component.inputs {
                    if let p = input.partner {
                        p.partner = nil
                        input.partner = nil
                        if let index = linker?.links.index(of: p) {
                            linker!.links.remove(at: index)
                        }
                    }
                    if let index = linker?.links.index(of: input) {
                        linker!.links.remove(at: index)
                    }
                }
                for output in component.outputs {
                    if let p = output.partner {
                        p.partner = nil
                        output.partner = nil
                        if let index = linker?.links.index(of: p) {
                            linker!.links.remove(at: index)
                        }
                    }
                    if let index = linker?.links.index(of: output) {
                        linker!.links.remove(at: index)
                    }
                }
                simulator.invalidateCache()
            }
        }
        linker?.setNeedsDisplay()
        toolbar?.scrollView.isScrollEnabled = true
    }
    func cancelPlacement(component: CircuitComponent) {
        component.removeFromSuperview()
        if let index = blocks.index(of: component) {
            blocks.remove(at: index)
        }
        simulator.invalidateCache()
        toolbar?.scrollView.isScrollEnabled = true
    }
    
    func attemptLinkageFrom(_ link: CircuitLink, toTouch touch: UITouch) {
        let hit = linker!.hitTest(touch.location(in: view), with: nil)
        if let zelda = hit as? CircuitLink {
            if zelda.output != link.output {
                if let third = zelda.partner {
                    third.partner = nil
                    if let index = linker?.links.index(of: third) {
                        linker?.links.remove(at: index)
                    }
                }
                
                zelda.partner = link
                link.partner = zelda
                if !(linker?.links.contains(zelda))! {
                    linker?.links.append(link)
                }
                simulator.invalidateCache()
            }
        }
        linker?.setNeedsDisplay()
    }
    func draggedFrom(_ link: CircuitLink, toTouch touch: UITouch) {
        if link.selected  {
            linker?.selectedLink = link
            linker?.selectedPoint = touch.location(in: view)
            if let p = link.partner {
                // unlink the two so they can be re-linked
                if let index = linker?.links.index(of: link) {
                    linker?.links.remove(at: index)
                }
                else if let index = linker?.links.index(of: p) {
                    linker?.links.remove(at: index)
                }
                
                link.partner = nil
                p.partner = nil
            }
            simulator.invalidateCache()
        }
        linker?.setNeedsDisplay()
    }
    func stopDragFrom(_ link: CircuitLink, atTouch touch: UITouch) {
        linker?.selectedLink = nil
        linker?.setNeedsDisplay()
    }
}

