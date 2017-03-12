//
//  FirstViewController.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 19.02.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, PagerConrollerViewControllerDataSrouce, PagerConrollerViewControllerDelegate {

    var pagerController: GAPagerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if (segue.identifier == "PagerSegue") {
            pagerController = segue.destination as! GAPagerViewController
            pagerController.datasource = self
            pagerController.delegate = self
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(pagerController, forKey: "pagerController")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    func pagerControllerNumberOfPages() -> Int {
        return 8
    }
    
    func pagerControllerBindPage(controller: UIViewController, index: Int) {
        let dataController = controller as! DataViewController
        dataController.bind(anIndex: index)
    }
    
    func pagerControllerPageIndentifier(index: Int) -> String {
        return "DataViewController"
    }
    
    func pagerControllerCreateController(identifier: String) -> UIViewController {
        return DataViewController(nibName: "DataViewController", bundle: nil)
    }
    
    func pagerControllerPageDidChange() {
        
    }
    
    func pagerControllerWillAppearPage(controller: UIViewController, index: Int) {
        
    }
    
    func pagerControllerWillDisappearPage(controller: UIViewController, index: Int) {
        
    }
    
    func pagerControllerDidAppearPage(controller: UIViewController, index: Int) {
        
    }
    
    func pagerControllerDidDisappearPage(controller: UIViewController, index: Int) {
        
    }
}

