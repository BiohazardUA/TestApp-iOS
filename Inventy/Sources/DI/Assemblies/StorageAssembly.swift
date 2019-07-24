import SwiftKeychainWrapper
import Swinject

class StorageAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container
            .register(SettingStore.self) { _ in
                KeychainSettingStore(keyChain: KeychainWrapper(serviceName: InfoPlist.bundleId.value))
            }
            .inObjectScope(.container)
        
        container
            .register(MemorySettingStore.self) { _ in
                MemorySettingStore()
            }
            .inObjectScope(.container)
        
        container
            .register(UserDefaultsSettingStore.self) { _ in
                UserDefaultsSettingStore()
            }
            .inObjectScope(.container)
    }
}
