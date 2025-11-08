//
//  BuyerEnterCodeViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 11/8/25.
//

import SwiftUI
import LocalAuthentication
import CryptoKit
import CryptoSwift

@MainActor
final class BuyerEnterCodeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var challenge: String?
    @Published var isFaceIDAuthorized: Bool = false
    @Published var showSuccessAlert: Bool = false
    
    private let service: BuyerEnterServicing
    
    // MARK: - Init
    init(service: BuyerEnterServicing = BuyerEnterService()) {
        self.service = service
    }
    
    // MARK: - Step 1: 서버에서 challenge 가져오기
    func verifyEntryCode(ticketId: Int64, entryCode: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 서버 호출
            let result = try await service.fetchChallenge(ticketId: ticketId, entryCode: entryCode)
            self.challenge = result.challenge
            print("서버에서 challenge 수신:", result.challenge)
            
            // FaceID 실행 + Secure Enclave 서명
            try await performFaceIDAndSign(challenge: result.challenge, ticketId: ticketId)
            
        } catch {
            errorMessage = "인증번호 확인에 실패했습니다. 다시 시도해주세요."
            print("verifyEntryCode Error:", error)
        }
        
        isLoading = false
    }
    
    // MARK: - Step 2: FaceID 실행 + Secure Enclave 서명
    private func performFaceIDAndSign(challenge: String, ticketId: Int64) async throws {
        let context = LAContext()
        var authError: NSError?
        
        // Face ID 사용 가능 여부 확인
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            throw NSError(domain: "FaceID", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "이 기기에서는 Face ID를 사용할 수 없습니다."])
        }
        
        // Face ID 실행
        let reason = "티켓 입장을 위해 Face ID 인증이 필요합니다."
        try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        print("Face ID 인증 성공")
        
        // Face ID 통과 → Secure Enclave 키 접근
        let tag = "com.dket.ticketkey"  // 키 식별용 태그
        let privateKey = try SecureEnclave.P256.Signing.PrivateKey(tag: tag)
        let publicKey = privateKey.publicKey
        
        // Challenge 데이터 변환
        guard let challengeData = Data(base64Encoded: challenge) ?? challenge.data(using: .utf8) else {
            throw NSError(domain: "Challenge", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "Challenge 데이터 형식이 잘못되었습니다."])
        }
        
        // Secure Enclave 서명 생성
        let signature = try privateKey.signature(for: challengeData)
        let sigBase64 = signature.derRepresentation.base64EncodedString()
        let pubKeyBase64 = publicKey.derRepresentation.base64EncodedString()
        
        print("Secure Enclave 서명 생성 완료")
        print("signature:", sigBase64)
        print("publicKey:", pubKeyBase64)
        
        // 기기 고유 해시 생성 (간단 예시)
        let deviceInfo = "\(UIDevice.current.model)-\(UIDevice.current.systemVersion)"
        let deviceHash = SHA256.hash(data: deviceInfo.data(using: .utf8)!)
            .compactMap { String(format: "%02x", $0) }.joined()
        
        // 서버에 서명 및 공개키, 디바이스 해시 전송
        try await sendSignedProof(ticketId: ticketId,
                                  challenge: challenge,
                                  signature: sigBase64,
                                  publicKey: pubKeyBase64,
                                  deviceHash: deviceHash)
        
        self.isFaceIDAuthorized = true
        self.showSuccessAlert = true
    }
    
    // MARK: - Step 3: 서명 결과 서버로 전송
        private func sendSignedProof(ticketId: Int64,
                                     challenge: String,
                                     signature: String,
                                     publicKey: String,
                                     deviceHash: String) async throws {
            print("📡 서버로 서명 정보 전송 중...")

            try await service.submitSignedProof(
                ticketId: ticketId,
                payload: BuyerSignatureDTO(
                    challenge: challenge,
                    signature: signature,
                    sePublicKey: publicKey,
                    deviceHash: deviceHash
                )
            )
            
            print("✅ 서버 서명 검증 요청 완료")
        }
}



