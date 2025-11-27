//
//  BiometricService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/15/25.
//

import Foundation
import Security
import LocalAuthentication

final class BiometricKeyManager {
    static let shared = BiometricKeyManager()
    private init() {}

    private let keyTag = "com.dket.faceid.keypair".data(using: .utf8)!

    // MARK: - 1. 키 삭제 (새로 추가된 함수)
    func deleteKeyPair() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag
        ]
        SecItemDelete(query as CFDictionary)
        print("🗑️ 기존 KeyPair 삭제 완료")
    }

    // MARK: - 2. 기존 키 불러오기 or 생성
    func loadOrCreateKeyPair() throws -> SecKey {
        // 1. 기존 키 쿼리
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            print("🔑 기존 Secure Enclave 키 불러옴")
            return item as! SecKey
        }

        // 2. 없으면 새로 생성
        return try createNewKeyPair()
    }
    
    // 키 생성 로직 분리
    private func createNewKeyPair() throws -> SecKey {
        print("✨ Secure Enclave 키 새로 생성 시작")
        
        // ⚠️ .biometryAny로 변경 권장 (개발 중 FaceID 설정 바뀌어도 유지되도록)
        // 보안 강도를 높이려면 .biometryCurrentSet 사용 (설정 바뀌면 키 삭제됨)
        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, .biometryCurrentSet],
            nil
        )!

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyTag,
                kSecAttrAccessControl as String: access
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        return privateKey
    }

    // MARK: - 3. Public Key 추출
    func getPublicKeyData(from privateKey: SecKey) throws -> Data {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw NSError(domain: "KeyError", code: -1)
        }
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        return data
    }

    // MARK: - 4. 압축 Public Key
    func compressPublicKey(_ uncompressedKey: Data) -> Data? {
        guard uncompressedKey.count == 65 else { return nil }
        let x = uncompressedKey[1...32]
        let y = uncompressedKey[33...64]
        let prefix: UInt8 = (y.last! % 2 == 0) ? 0x02 : 0x03
        var compressed = Data([prefix])
        compressed.append(x)
        return compressed
    }

    // MARK: - 5. 서명 (재시도 로직 포함)
    func sign(challenge: String) async throws -> Data {
        // ① 키 로드
        var privateKey = try loadOrCreateKeyPair()
        
        // ② Challenge 변환
        guard let challengeData = challenge.data(using: .utf8) else {
            throw NSError(domain: "FaceID", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid challenge string"])
        }

        // ③ 서명 시도 (실패 시 키 재생성 후 재시도)
        do {
            return try createSignature(key: privateKey, data: challengeData)
        } catch {
            print("⚠️ 서명 실패 (키 무효화 가능성): \(error)")
            print("🔄 키 삭제 후 재생성 및 재시도 진행...")
            
            // 키 삭제 및 재생성
            deleteKeyPair()
            privateKey = try createNewKeyPair()
            
            // 재시도
            return try createSignature(key: privateKey, data: challengeData)
        }
    }
    
    // 실제 서명 수행 헬퍼 함수
    private func createSignature(key: SecKey, data: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            key,
            .ecdsaSignatureMessageX962SHA256,
            data as CFData,
            &error
        ) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        return signature
    }
}

// 5.Hex 변환 Extension
extension Data {
    func toHexString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}
