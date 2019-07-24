//
//  UICollectionView+RegisterCell.swift
//  Inventy
//
//  Created by Владислав Терновский on 7/21/19.
//  Copyright © 2019 inventy. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    /**
     The shorter method for cell registering
     */
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    /**
     The shorter method for cell registering with Nib
     */
    func register<T: UICollectionViewCell>(_: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    /**
     The shorter method for reusable cell registering
     */
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
}
