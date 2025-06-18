//
//  UserWalletStore.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

final class UserWalletStore {
    static let shared = UserWalletStore()
    private init() {}
    
    private(set) var address: String?
    
    func saveAddress(_ addr: String) {
        self.address = addr
    }
    
    func clear() {
        self.address = nil
    }
}
