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
    @IBOutlet weak var titleBar: UINavigationBar?
    var blocks = [CircuitComponent]()
    let simulator: Quantum = Quantum()
    var circuitName: String?
    var loadDict: NSDictionary?
    
    @IBAction func run() {
        // do the simulation on the background thread
        if self.simulator.cache == nil || self.simulator.inputCache == nil {
            self.titleBar?.topItem?.title = "Compiling..."
            DispatchQueue.global(qos: .userInitiated).async {
                self.simulator.process(components: self.blocks)
                DispatchQueue.main.async {
                    self.titleBar?.topItem?.title = "Running..."
                }
                self.simulator.runSimulation()
                DispatchQueue.main.async {
                    self.titleBar?.topItem?.title = "Ready."
                }
            }
        }
        else {
            self.titleBar?.topItem?.title = "Running..."
            DispatchQueue.global(qos: .userInitiated).async {
                self.simulator.runSimulation()
                DispatchQueue.main.async {
                    self.titleBar?.topItem?.title = "Ready."
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        linker?.setNeedsDisplay()
    }
    
    @IBAction func trash() {
        for block in blocks {
            block.removeFromSuperview()
        }
        
        blocks = [CircuitComponent]()
        linker?.links = [CircuitLink]()
        linker?.selectedLink = nil
        linker?.selectedPoint = CGPoint.zero
        simulator.invalidateCache()
        titleBar?.topItem?.title = "Needs Compiling"
        linker?.setNeedsDisplay()
    }
    
    @IBAction func back() {
        if let name = circuitName {
            let dict = serializeToDictionary()
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let path = dir.appendingPathComponent(name + ".q")
                
                //writing
                if dict.write(to: path, atomically: true) {
                    dismiss(animated: true, completion: nil)
                    return
                }
            }
            NSLog("Failed to save circuit to file")
        }
        else {
            let alertController = UIAlertController(title: "Save Circuit As:", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                
                let textField = alertController.textFields![0] as UITextField
                
                self.circuitName = textField.text
                DispatchQueue.main.async {
                    self.back()
                }
            })
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
                alert -> Void in
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addTextField(configurationHandler: {
                (textField: UITextField!) -> Void in
                
                textField.placeholder = "circuit name"
            })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func serializeToDictionary() -> NSDictionary {
        let outBlocks = NSMutableArray()
        let outLinks = NSMutableArray()
        for (b, block) in blocks.enumerated() {
            let dict = block.dictionaryValue() as! NSMutableDictionary
            dict.setValue(block.center.dictionaryRepresentation, forKey: "location")
            outBlocks.add(dict)
            for (i, o) in block.outputs.enumerated() {
                if let p = o.partner {
                    // this node is linked so lets serialize the link
                    let link = NSMutableDictionary()
                    link.setValue(i, forKey: "outputIndex")
                    link.setValue(p.owner.inputs.index(of: p), forKey: "inputIndex")
                    link.setValue(b, forKey: "outputBlock")
                    link.setValue(blocks.index(of: p.owner), forKey: "inputBlock")
                    outLinks.add(link)
                }
            }
        }
        let returnDict = NSMutableDictionary()
        returnDict.setValue(outBlocks, forKey: "blocks")
        returnDict.setValue(outLinks, forKey: "links")
        return returnDict
    }
    
    func loadFromDictionary(_ dict: NSDictionary) {
        let inBlocks = dict.value(forKey: "blocks") as! NSArray
        let inLinks = dict.value(forKey: "links") as! NSArray
        
        for b in inBlocks {
            let bDict = b as! NSDictionary
            let newBlock = CircuitComponent(dictionary: bDict)
            addNewComponent(newBlock)
            let coords = bDict.value(forKey: "location") as! CFDictionary
            newBlock.center = CGPoint(dictionaryRepresentation: coords)!
        }
        
        for l in inLinks {
            let lDict = l as! NSDictionary
            let a = blocks[lDict.value(forKey: "outputBlock") as! Int]
            let b = blocks[lDict.value(forKey: "inputBlock") as! Int]
            let link = a.outputs[lDict.value(forKey: "outputIndex") as! Int]
            let zelda = b.inputs[lDict.value(forKey: "inputIndex") as! Int]
            attemptLinkageFrom(link, toNode: zelda)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let tool = toolbar {
            tool.scrollView.frame = CGRect(origin: CGPoint.zero, size: tool.frame.size)
            tool.scrollView.contentSize = tool.contentSize
            tool.scrollView.alwaysBounceHorizontal = true
        }
        
        if let dict = loadDict {
            circuitName = dict.value(forKey: "circuitName") as? String
            loadFromDictionary(dict)
            loadDict = nil
            linker?.backgroundColor = UIColor.clear
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CircuitComponent.delegate = self
        CircuitLink.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                titleBar?.topItem?.title = "Needs Compiling"
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
        titleBar?.topItem?.title = "Needs Compiling"
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
                titleBar?.topItem?.title = "Needs Compiling"
            }
        }
        linker?.setNeedsDisplay()
    }
    func attemptLinkageFrom(_ link: CircuitLink, toNode zelda: CircuitLink) {
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
        }
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
            titleBar?.topItem?.title = "Needs Compiling"
        }
        linker?.setNeedsDisplay()
    }
    func stopDragFrom(_ link: CircuitLink, atTouch touch: UITouch) {
        linker?.selectedLink = nil
        linker?.setNeedsDisplay()
    }
}

