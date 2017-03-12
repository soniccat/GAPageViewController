//
//  GAReusableObject.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 05.03.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

@objc public protocol GAReusableObject {
    var reuseIdentifier: String {get}
    
    @objc optional func prepareForReuse()
}
