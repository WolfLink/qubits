//
//  FileManagerViewController.swift
//  Qubits
//
//  Created by Marc Davis on 5/5/17.
//  Copyright © 2017 Marc Davis. All rights reserved.
//

import UIKit

class FileManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var filenames: [String]?
    @IBOutlet weak var tableView: UITableView?
    
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "file")
        if let names = filenames {
            cell.textLabel?.text = names[indexPath[1]]
        }
        return cell
    }

    
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let names = filenames {
            return names.count
        }
        else {
            readDocumentsDirectory()
            return filenames!.count
        }
    }
    
    func readDocumentsDirectory() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                try filenames = FileManager.default.contentsOfDirectory(atPath: dir.path).map({URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent})
            }
            catch {
                NSLog("Unable to read saved circuits")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = filenames![indexPath[1]]
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(name + ".q")

            let dict = NSMutableDictionary(contentsOf: path)
            dict?.setValue(name, forKey: "circuitName")
            if let d = dict {
                performSegue(withIdentifier: "load", sender: d)
            }
            else {
                NSLog("Could not read file \(name).q")
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readDocumentsDirectory()
        tableView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "load" {
            let dict = sender as! NSDictionary
            (segue.destination as! ViewController).loadDict = dict
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
