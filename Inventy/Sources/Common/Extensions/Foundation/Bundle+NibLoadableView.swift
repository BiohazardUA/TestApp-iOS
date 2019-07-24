//
//  Bundle+NibLoadableView.swift
//  Inventy
//
//  Created by Владислав Терновский on 7/21/19.
//  Copyright © 2019 inventy. All rights reserved.
//

import UIKit

protocol NibLoadableView: class { }

extension NibLoadableView where Self: UIView {
    
    static var nibName: String {
        return String(describing: self)
    }
    
}

extension Bundle {
    
    func load<T: UIView>(_: T.Type) -> T where T: NibLoadableView {
        guard let views = loadNibNamed(T.nibName, owner: nil, options: nil) as? [UIView],
            let view = views.first as? T else {
                fatalError("Couldn't find \(T.nibName)")
        }
        
        return view
    }
}
