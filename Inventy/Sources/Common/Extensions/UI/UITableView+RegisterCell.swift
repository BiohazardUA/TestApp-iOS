//
//  UITableView+RegisterCell.swift
//  Inventy
//
//  Created by Владислав Терновский on 7/21/19.
//  Copyright © 2019 inventy. All rights reserved.
//

import UIKit

extension UITableView {
    
    /**
     The shorter method for cell registering
     */
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    /**
     The shorter method for cell registering with Nib
     */
    func registerNib<T: UITableViewCell>(_: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)

        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    /**
     The shorter method for header/footer registering with Nib
     */
    func registerHeaderFooterNib<T: UITableViewHeaderFooterView>(_: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
    }

    /**
     The shorter method for reusable cell registering
     */
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            #if DEBUG
                fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
            #else
                return T()
            #endif
        }

        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) -> T {
        
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: T.defaultReuseIdentifier) as? T else {
            #if DEBUG
                fatalError("Could not dequeue tableView header/footer with identifier: \(T.defaultReuseIdentifier)")
            #else
                return T()
            #endif
        }
        return headerFooterView
    }
}
