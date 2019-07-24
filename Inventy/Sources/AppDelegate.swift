//
//  AppDelegate.swift
//  Inventy
//
//  Created by v.ternovskyi on 7/18/19.
//  Copyright © 2019 inventy. All rights reserved.
//

import SwinjectStoryboard

typealias AppService = UIApplicationDelegate
class AppDelegate: UIResponder, UIApplicationDelegate {

    let mainAssembler = MainAssembler()
    let appServices: AppService
    var window: UIWindow?
    
    override init() {
        UIViewController.swizzleSegues
        appServices = mainAssembler.appService()
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let result = appServices.application?(application, didFinishLaunchingWithOptions: launchOptions)
        return result ?? true
    }
    
    //swiftlint:disable - colon
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let result = appServices.application?(app, open: url, options: options)
        return result ?? true
    }
}

