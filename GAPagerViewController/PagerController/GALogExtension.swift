//
//  GAControllerLogExtension.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 04.03.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

extension NSObject {
    public func gaLog(_ format: String, _ args: CVarArg...) {
        #if GADEBUG
            withVaList(args) { NSLogv(format, $0) }
        #endif
    }
}
