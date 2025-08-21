//
//  MyPageService.swift
//  Dket_iOS
//
//  Created by 이지우 on 8/20/25.
//

import Foundation

protocol MypageServicing {
    func fetchWalletInfo() async throws -> WalletInfo
}

struct MypageService: MypageServicing {
    private let api = APIClient.shared
    
    func fetchWalletInfo() async throws -> WalletInfo {
        let wrapper = try await api.get(.userWalletInfo, as: APIResponse<WalletInfoDTO>.self)
        return wrapper.result.toDomain()
    }
}
