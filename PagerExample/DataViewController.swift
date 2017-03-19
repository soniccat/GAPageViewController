//
//  DataViewController.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 19.02.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit
import GAPagerViewController

protocol DataViewControllerDelegate {
    func dataViewControllerDeletePressed(controller: DataViewController)
}

class DataViewController: UIViewController, UIViewControllerRestoration {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var logLabel: UILabel!
    
    public var delegate: DataViewControllerDelegate?
    
    override var reuseIdentifier: String {
        get {
            return "DataViewController"
        }
    }
    
    public var index = 0
    var appearCount: Int = 0
    var disappearCount: Int = 0
    var log: [String] = []
    
    public static func viewController(withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        let controller = DataViewController.init(nibName: "DataViewController", bundle: Bundle.main)
        return controller
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.restorationIdentifier = "DataViewController"
        self.restorationClass = DataViewController.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(index, forKey: "index")
        coder.encode(appearCount, forKey: "appearCount")
        coder.encode(disappearCount, forKey: "disappearCount")
        coder.encode(log, forKey: "log")
    }
    
    public override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        index = coder.decodeInteger(forKey: "index")
        appearCount = coder.decodeInteger(forKey: "appearCount")
        disappearCount = coder.decodeInteger(forKey: "disappearCount")
        log = coder.decodeObject(forKey: "log") as! [String]
        
        updateText()
        updateColor()
    }
    
    public func bind(anIndex: Int) {
        index = anIndex
        NSLog("bind %d", anIndex)
        
        log = []
        appearCount = 0
        disappearCount = 0

        updateText()
        updateColor()
    }
    
    private func updateColor() {
        view.backgroundColor = UIColor(red: CGFloat(index)/8.0, green: 0.5, blue: 0.5, alpha: 1)
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
        NSLog("viewWillAppear %d %@", index, self)
        log.append("viewWillAppear")
        appearCount = appearCount + 1
        updateText()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("viewDidAppear %d %@", index, self)
        log.append("viewDidAppear")
        appearCount = appearCount - 1
        updateText()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("viewWillDisappear %d %@", index, self)
        log.append("viewWillDisappear")
        disappearCount = disappearCount + 1
        updateText()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("viewDidDisappear %d %@", index, self)
        log.append("viewDidDisappear")
        disappearCount = disappearCount - 1
        updateText()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        NSLog("viewWillTransition %@ %@", self, NSStringFromCGSize(size))
    }
    
    private func updateText() {
        label.text = String(format: "%p %d %d", self, appearCount, disappearCount)
        logLabel.text = log.joined(separator: "\n")
    }
    
    @IBAction func onDeletePressed() {
        delegate?.dataViewControllerDeletePressed(controller: self)
    }
}
