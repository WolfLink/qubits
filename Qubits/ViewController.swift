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

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*for touch in touches {
            let c = CircuitComponent(title: "Hello World")
            let location = touch.location(in: view)
            c.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            c.center = location
            view.addSubview(c)
        }*/
    }
    
    func addNewComponent(_ component: CircuitComponent) {
        self.view.addSubview(component)
    }
    func moveComponent(_ component: CircuitComponent, to touch: UITouch, offset: CGPoint) {
        let point = touch.location(in: self.view)
        component.frame.origin = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
        toolbar?.scrollView.isScrollEnabled = false
    }
    func handlePlacement(component: CircuitComponent, at touch: UITouch, offset: CGPoint) {
        if let tool = toolbar {
            if tool.frame.contains(touch.location(in: self.view)) {
                component.removeFromSuperview()
            }
        }
        toolbar?.scrollView.isScrollEnabled = true
    }
}

