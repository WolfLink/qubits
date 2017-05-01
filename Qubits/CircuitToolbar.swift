//
//  CircuitToolbar.swift
//  Qubits
//
//  Created by Marc Davis on 3/30/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

class CircuitToolbar: UIView {
    let scrollView = UIScrollView(frame: CGRect.zero)
    var contentSize = CGSize.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.frame = frame
        scrollView.isScrollEnabled = true
        scrollView.contentSize = frame.size
        loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollView.frame = frame
        scrollView.isScrollEnabled = true
        scrollView.contentSize = frame.size
        loadData()
    }
    
    func reset() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    func loadData() {
        let length = self.frame.height - 10
        scrollView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        scrollView.backgroundColor = UIColor.red
        self.addSubview(scrollView)
        var currentX: CGFloat = 5
        var totalLength: CGFloat = 5
        var myList: NSArray?
        if let path = Bundle.main.path(forResource: "ComponentList", ofType: "plist") {
            myList = NSArray(contentsOfFile: path)
        }
        if let list = myList {
            for item in list {
                let component = CircuitComponent(dictionary: item as! NSDictionary)
                component.frame = CGRect(x: currentX, y: 5, width: length, height: length)
                currentX += length + 5
                totalLength += length + 5
                scrollView.addSubview(component)
                component.drawMode = CircuitComponent.DrawMode.unselected
            }
        }
        contentSize = CGSize(width: totalLength, height: self.frame.size.height)
        scrollView.contentSize = contentSize
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog("touched: \(touches)")
    }

}
