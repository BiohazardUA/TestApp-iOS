import UIKit.UIApplication

let unitTests = NSClassFromString("XCTest") != nil

let delegate = (!unitTests ? NSStringFromClass(AppDelegate.self) : nil)

print("Using AppDelegate:", delegate ?? "none")

let argc = CommandLine.argc
let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv)
    .bindMemory(to: UnsafeMutablePointer<Int8>?.self, capacity: Int(CommandLine.argc))

_ = UIApplicationMain(argc, argv, nil, delegate)
