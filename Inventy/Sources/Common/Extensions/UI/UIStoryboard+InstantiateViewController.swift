//
//  UIStoryboard+InstantiateViewController.swift
//  Inventy
//
//  Created by Владислав Терновский on 7/21/19.
//  Copyright © 2019 inventy. All rights reserved.
//

import UIKit

extension UIStoryboard {

    static func instantiate<T: UIViewController>(viewController: T.Type) -> UIViewController {
        return  UIStoryboard.init(T.className).instantiateViewController(withIdentifier: T.className)
    }
}
