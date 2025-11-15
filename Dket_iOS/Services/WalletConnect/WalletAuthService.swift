//
//  WalletAuthService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/12/25.
//

import Foundation

final class WalletAuthService {
    static let shared = WalletAuthService()
    private init() {}

    // 외국인 회원가입
    func signUpWithPassport(_ request: PassportSignUpRequestDTO) async throws -> PassportSignUpResponseDTO {
        print("외국인 회원가입 요청 시작")
        return try await APIClient.shared.post(.foreignSignUp, body: request, as: PassportSignUpResponseDTO.self)
    }

    // 회원가입 후 MetaMask 연결 완료 + Face ID 공개키 포함
    func completeMetaMaskSignUp(walletAddress: String) async throws -> MetaMaskCompleteResponseDTO {
        print("MetaMask 연결 완료 요청 시작 (Secure Enclave 공개키 포함)")

        // 1.기존 Secure Enclave 키 불러오기 (없으면 Face ID로 새로 생성)
        let privateKey = try BiometricKeyManager.shared.loadOrCreateKeyPair()

        // 2.공개키 추출
        let rawKey = try BiometricKeyManager.shared.getPublicKeyData(from: privateKey)
        guard let compressed = BiometricKeyManager.shared.compressPublicKey(rawKey) else {
            throw NSError(domain: "KeyCompressError", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "공개키 압축 실패"])
        }

        // 3.공개키 Hex 변환
        let publicKeyHex = compressed.toHexString()
        print("Secure Enclave 공개키 (compressed hex): \(publicKeyHex)")

        // 4.서버 요청 DTO 구성
        let req = MetaMaskCompleteRequestDTO(walletAddress: walletAddress, publicKey: publicKeyHex)

        // 5.서버로 전송
        let response = try await APIClient.shared.post(
            .completeMetaMaskSignUp,
            body: req,
            as: MetaMaskCompleteResponseDTO.self
        )

        print("MetaMask + Face ID 공개키 등록 완료: \(response.message)")
        return response
    }

    // MetaMask 로그인 (기존회원)
    func loginWithMetaMask(walletAddress: String) async throws -> MetaMaskLoginResponseDTO {
        let req = MetaMaskLoginRequestDTO(walletAddress: walletAddress)
        print("MetaMask 로그인 요청 시작")
        return try await APIClient.shared.post(.loginMetaMask, body: req, as: MetaMaskLoginResponseDTO.self)
    }
}
