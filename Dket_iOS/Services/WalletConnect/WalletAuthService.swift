//
//  WalletAuthService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/12/25.
//

final class WalletAuthService {
    static let shared = WalletAuthService()
    private init() {}
    
    // 외국인 회원가입
    func signUpWithPassport(_ request: PassportSignUpRequestDTO) async throws -> PassportSignUpResponseDTO {
        print("외국인 회원가입 요청 시작")
        return try await APIClient.shared.post(.foreignSignUp, body: request, as: PassportSignUpResponseDTO.self)
    }
    
    // 회원가입 후 MetaMask 연결 완료
    func completeMetaMaskSignUp(walletAddress: String) async throws -> MetaMaskCompleteResponseDTO {
        let req = MetaMaskCompleteRequestDTO(walletAddress: walletAddress)
        print("MetaMask 연결 완료 요청 시작")
        return try await APIClient.shared.post(.completeMetaMaskSignUp, body: req, as: MetaMaskCompleteResponseDTO.self)
    }
    
    // MetaMask 로그인 (기존회원)
    func loginWithMetaMask(walletAddress: String) async throws -> MetaMaskLoginResponseDTO {
        let req = MetaMaskLoginRequestDTO(walletAddress: walletAddress)
        print("MetaMask 로그인 요청 시작")
        return try await APIClient.shared.post(.loginMetaMask, body: req, as: MetaMaskLoginResponseDTO.self)
    }
}
