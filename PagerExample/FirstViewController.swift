//
//  FirstViewController.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 19.02.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit
import GAPagerViewController

class FirstViewController: UIViewController, PagerConrollerViewControllerDataSrouce, PagerConrollerViewControllerDelegate, DataViewControllerDelegate {

    var pageCount = 8
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
    
    
    // MARK: PagerConrollerViewControllerDelegate
    
    func pagerControllerNumberOfPages() -> Int {
        return pageCount
    }
    
    func pagerControllerBindPage(controller: UIViewController, index: Int) {
        let dataController = controller as! DataViewController
        dataController.bind(anIndex: index)
    }
    
    func pagerControllerPageIndentifier(index: Int) -> String {
        return "DataViewController"
    }
    
    func pagerControllerCreateController(identifier: String) -> UIViewController {
        let controller = DataViewController(nibName: "DataViewController", bundle: nil)
        controller.delegate = self
        
        return controller
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
    
    func pagerControllerIndexChanged(controller: UIViewController, newIndex: Int) {
        let dataController = controller as! DataViewController
        dataController.index = newIndex
    }
    
    // MARK: DataViewControllerDelegate
    
    func dataViewControllerDeletePressed(controller: DataViewController) {
        pageCount -= 1
        pagerController.deletePages(pages: [controller.index])
    }
}

