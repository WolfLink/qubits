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
    let sampleNames: [String] = {
        if let urlList = Bundle.main.urls(forResourcesWithExtension: "q", subdirectory: nil) {
            return urlList.map({$0.deletingPathExtension().lastPathComponent})
        }
        else {
            NSLog("Could not find sample circuits")
            return []
        }
    }()
    @IBOutlet weak var tableView: UITableView?
    
    
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "file")
        if indexPath.first == 0, let names = filenames {
            cell.textLabel?.text = names[indexPath[1]]
        }
        else {
            cell.textLabel?.text = sampleNames[indexPath[1]]
        }
        return cell
    }

    
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if let names = filenames {
                return names.count
            }
            else {
                readDocumentsDirectory()
                return filenames!.count
            }
        }
        else {
            return sampleNames.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "My Circuits" : "Sample Circuits"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.first == 0
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let name = filenames![indexPath[1]]
            filenames?.remove(at: indexPath[1])
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                do {
                    try FileManager.default.removeItem(at: dir.appendingPathComponent(name + ".q"))
                }
                catch {
                    NSLog("Could not delete file \(name).q")
                }
            }
        }
    }
    
    func readDocumentsDirectory() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let paths = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants).filter({$0.pathExtension == "q"})
                filenames = paths.map({$0.deletingPathExtension().lastPathComponent})
            }
            catch {
                NSLog("Unable to read saved circuits")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.first == 0 {
            if let name = filenames?[indexPath[1]], let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let path = dir.appendingPathComponent(name + ".q")
                
                let dict = NSMutableDictionary(contentsOf: path)
                dict?.setValue(name, forKey: "circuitName")
                dict?.setValue(false, forKey: "sample")
                if let d = dict {
                    performSegue(withIdentifier: "load", sender: d)
                }
                else {
                    NSLog("Could not read file \(name).q")
                }
            }
        }
        else {
            let name = sampleNames[indexPath[1]]
            if let path = Bundle.main.path(forResource: name, ofType: "q"), let dict = NSMutableDictionary(contentsOfFile: path) {
                dict.setValue(name, forKey: "circuitName")
                dict.setValue(true, forKey: "sample")
                performSegue(withIdentifier: "load", sender: dict)
            }
            else {
                NSLog("Could not read sample circuit \(name)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readDocumentsDirectory()
        tableView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "load", let dict = sender as? NSDictionary, let dest = segue.destination as? ViewController, let sample = dict.value(forKey: "sample") as? Bool {
            dest.loadDict = dict
            dest.immutable = sample
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
