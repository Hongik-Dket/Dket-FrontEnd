//
//  BuyerEnterCodeViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 11/8/25.
//

import Foundation
import LocalAuthentication
import CryptoKit
import Security
import UIKit

@MainActor
final class BuyerEnterCodeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    
    private let service: BuyerEnterServicing
    private let keyTag = "com.dket.ticketkey" // Secure Enclave 키 태그 (고정)
    
    // MARK: - Init
    init(service: BuyerEnterServicing = BuyerEnterService()) {
        self.service = service
    }
    
    // MARK: - Step 1. 서버에서 challenge 가져오기
    func verifyEntryCode(ticketId: Int64, entryCode: String) async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            // ① 서버에서 challenge 수신
//            let result = try await service.fetchChallenge(ticketId: ticketId, entryCode: entryCode)
//            guard let challenge = result.challenge else {
//                throw NSError(domain: "Challenge", code: -1,
//                              userInfo: [NSLocalizedDescriptionKey: "서버로부터 유효한 Challenge를 받지 못했습니다."])
//            }
//            
//            print("📡 서버에서 challenge 수신:", challenge)
//            
//            // ② Face ID + Secure Enclave 서명
//            try await performBiometricSignAndSubmit(challenge: challenge, ticketId: ticketId)
//            
//        } catch {
//            errorMessage = error.localizedDescription
//            print("❌ verifyEntryCode Error:", error)
//        }
//        
//        isLoading = false
    }
    
    // MARK: - Step 2. Face ID 인증 후 Secure Enclave 서명 및 서버 전송
    private func performBiometricSignAndSubmit(challenge: String, ticketId: Int64) async throws {
//        // Face ID 인증 실행
//        let context = LAContext()
//        let reason = "티켓 입장을 위해 Face ID 인증이 필요합니다."
//        try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
//        print("✅ Face ID 인증 성공")
//        
//        // Challenge → Data 변환 (base64 or hex 지원)
//        guard let challengeData =
//                Data(base64Encoded: challenge)
//                ?? Data(hex: challenge)
//                ?? challenge.data(using: .utf8) else {
//            throw NSError(domain: "Challenge", code: -2,
//                          userInfo: [NSLocalizedDescriptionKey: "Challenge 데이터 형식이 올바르지 않습니다."])
//        }
//        
//        // ① Secure Enclave 키 생성/조회
//        let privateKey = try getOrCreateSecureEnclaveKey(tag: keyTag)
//        print("🔑 Secure Enclave 키 접근 성공")
//        
//        // ② 공개키 추출
//        let publicKeyData = try exportPublicKeyData(from: privateKey)
//        
//        // ③ challenge 서명
//        let signature = try signChallenge(privateKey: privateKey, message: challengeData)
//        
//        // ④ 디바이스 해시 생성
//        let model = UIDevice.current.model
//        let version = UIDevice.current.systemVersion
//        let deviceHash = sha256Hex("\(model)|\(version)|\(keyTag)")
//        
//        // ⑤ 서버 전송
//        try await service.submitSignedProof(
//            ticketId: ticketId,
//            payload: BuyerSignatureDTO(
//                challenge: challenge,
//                signature: signature.base64EncodedString(),
//                sePublicKey: publicKeyData.base64EncodedString(),
//                deviceHash: deviceHash
//            )
//        )
//        
//        print("✅ 서버로 서명 결과 전송 완료")
//        showSuccessAlert = true
    }
}


// MARK: - Secure Enclave Helper Functions

private func getOrCreateSecureEnclaveKey(tag: String) throws -> SecKey {
    let tagData = tag.data(using: .utf8)!
    
    // 1️⃣ 기존 키 조회
    let query: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrApplicationTag as String: tagData,
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecReturnRef as String: true
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == errSecSuccess, let key = item as! SecKey? {
        return key
    }
    
    // 2️⃣ 없으면 새로 생성 (Face ID 보호)
    guard let access = SecAccessControlCreateWithFlags(
        nil,
        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        [.privateKeyUsage, .biometryCurrentSet],
        nil
    ) else {
        throw NSError(domain: "SecureEnclave", code: -10,
                      userInfo: [NSLocalizedDescriptionKey: "AccessControl 생성 실패"])
    }
    
    let attributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeySizeInBits as String: 256,
        kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
        kSecPrivateKeyAttrs as String: [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: tagData,
            kSecAttrAccessControl as String: access
        ]
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        throw error?.takeRetainedValue() ?? NSError(domain: "SecureEnclave", code: -11,
                                                   userInfo: [NSLocalizedDescriptionKey: "Secure Enclave 키 생성 실패"])
    }
    print("🔐 Secure Enclave 키 최초 생성 완료")
    return privateKey
}

private func exportPublicKeyData(from privateKey: SecKey) throws -> Data {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
        throw NSError(domain: "SecureEnclave", code: -12,
                      userInfo: [NSLocalizedDescriptionKey: "공개키 추출 실패"])
    }
    var error: Unmanaged<CFError>?
    guard let pubData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
        throw error?.takeRetainedValue() ?? NSError(domain: "SecureEnclave", code: -13,
                                                   userInfo: [NSLocalizedDescriptionKey: "공개키 변환 실패"])
    }
    return pubData
}

private func signChallenge(privateKey: SecKey, message: Data) throws -> Data {
    let algorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
    guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
        throw NSError(domain: "SecureEnclave", code: -14,
                      userInfo: [NSLocalizedDescriptionKey: "알고리즘 지원 안 됨"])
    }
    var error: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(privateKey, algorithm, message as CFData, &error) as Data? else {
        throw error?.takeRetainedValue() ?? NSError(domain: "SecureEnclave", code: -15,
                                                   userInfo: [NSLocalizedDescriptionKey: "서명 실패"])
    }
    return signature
}


// MARK: - 유틸: SHA256 해시
import CryptoKit
private func sha256Hex(_ string: String) -> String {
    let data = Data(string.utf8)
    let hash = SHA256.hash(data: data)
    return Data(hash).map { String(format: "%02x", $0) }.joined()
}

// MARK: - 유틸: hex string → Data
private extension Data {
    init?(hex: String) {
        var hex = hex
        if hex.hasPrefix("0x") { hex = String(hex.dropFirst(2)) }
        var data = Data()
        var temp = ""
        for c in hex {
            temp.append(c)
            if temp.count == 2 {
                if let num = UInt8(temp, radix: 16) {
                    data.append(num)
                }
                temp = ""
            }
        }
        self = data
    }
}

