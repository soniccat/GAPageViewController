//
//  GAReuseQueue.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 05.03.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit


public protocol GAReuseQueueDelegate {
    func createObject(reuseIdentifier: String) -> GAReusableObject
}

public class GAReuseQueue: NSObject {
    public var delegate: GAReuseQueueDelegate!
    private var pool: [String:[GAReusableObject]] = [:]
    
    public var count: Int {
        get {
            return pool.count
        }
    }
    
    public func enqueue(obj: GAReusableObject) {
        if !pool.keys.contains(obj.reuseIdentifier) {
            pool[obj.reuseIdentifier] = [obj]
            
        } else {
            pool[obj.reuseIdentifier]?.append(obj);
        }
    }
    
    public func dequeue(reuseIdentifier: String) -> GAReusableObject {
        let obj = ensuredObject(reuseIdentifier: reuseIdentifier)
        if let prepareForReuse = obj.prepareForReuse {
            prepareForReuse()
        }
        
        return obj
    }
    
    private func ensuredObject(reuseIdentifier: String) -> GAReusableObject {
        var result: GAReusableObject
        
        if let obj = takeObject(reuseIdentifier: reuseIdentifier) {
            result = obj
            
        } else {
            result = delegate.createObject(reuseIdentifier: reuseIdentifier)
        }
        
        return result
    }
    
    private func takeObject(reuseIdentifier: String) -> GAReusableObject? {
        var result: GAReusableObject?
        
        if let list = pool[reuseIdentifier], list.count > 0 {
            result = pool[reuseIdentifier]!.removeLast()
        }
        
        return result
    }
}
