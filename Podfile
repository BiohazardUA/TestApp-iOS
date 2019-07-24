platform :ios, '11.0'

use_frameworks!
inhibit_all_warnings!

def helper_pods
    pod 'SwiftGen'
    pod 'SwiftLint'
    pod 'Swinject'
    pod 'SwinjectStoryboard'
    pod 'Moya/RxSwift'
    pod 'RxSwift'
    pod 'RxCocoa'
end

def ui_pods
  
end

target 'Inventy' do
    helper_pods
    ui_pods


  target 'InventyTests' do
    inherit! :search_paths
    pod 'Nimble'
    pod 'RxBlocking'
    pod 'RxTest'
  end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_WHOLE_MODULE_OPTIMIZATION'] = 'YES'
    end
  end
end

end
