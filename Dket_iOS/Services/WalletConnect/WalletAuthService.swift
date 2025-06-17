//
//  WalletAuthService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/12/25.
//

struct WalletAuthService {
    private let api = APIClient.shared
    
    func completeLogin(with walletAddress: String) async throws {
        let req = WalletAddressRequest(walletAddress: walletAddress)
        let res: MetaMaskLoginResponse = try await api.post(.connectWallet, body: req)
        
        // JWT 토큰 저장
        TokenManager.saveToken(res.token)
    }
}
