//
//  GAReusableController.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 05.03.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

extension UIViewController: GAReusableObject {
    open var reuseIdentifier: String {
        get {
            return NSStringFromClass(type(of:self))
        }
    }
}
