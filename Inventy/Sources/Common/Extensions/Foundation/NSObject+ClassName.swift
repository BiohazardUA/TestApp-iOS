//
//  NSObject+ClassName.swift
//  Inventy
//
//  Created by Владислав Терновский on 7/21/19.
//  Copyright © 2019 inventy. All rights reserved.
//

import Foundation

extension NSObject {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
    
}
