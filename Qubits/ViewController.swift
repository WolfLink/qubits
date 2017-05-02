//
//  ViewController.swift
//  Qubits
//
//  Created by Marc Davis on 3/26/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CircuitComponentDelegate {
    @IBOutlet weak var toolbar: CircuitToolbar?
    var blocks = [CircuitComponent]()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let tool = toolbar {
            tool.scrollView.frame = CGRect(origin: CGPoint.zero, size: tool.frame.size)
            tool.scrollView.contentSize = tool.contentSize
            tool.scrollView.alwaysBounceHorizontal = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CircuitComponent.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
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
    }
    
    func addNewComponent(_ component: CircuitComponent) {
        self.view.addSubview(component)
        blocks.append(component)
        if let tool = toolbar {
            self.view.bringSubview(toFront: tool)
        }
    }
    func moveComponent(_ component: CircuitComponent, to touch: UITouch, offset: CGPoint) {
        let point = touch.location(in: view)
        component.frame.origin = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
        toolbar?.scrollView.isScrollEnabled = false
    }
    func handlePlacement(component: CircuitComponent, at touch: UITouch, offset: CGPoint) {
        if let tool = toolbar {
            if tool.frame.contains(touch.location(in: self.view)) {
                component.removeFromSuperview()
                if let index = blocks.index(of: component) {
                    blocks.remove(at: index)
                }
            }
        }
        toolbar?.scrollView.isScrollEnabled = true
    }
    func cancelPlacement(component: CircuitComponent) {
        component.removeFromSuperview()
        if let index = blocks.index(of: component) {
            blocks.remove(at: index)
        }
        toolbar?.scrollView.isScrollEnabled = true
    }
}

