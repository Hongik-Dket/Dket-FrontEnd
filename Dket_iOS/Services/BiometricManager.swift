//
//  BiometricService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/15/25.
//

import Foundation
import LocalAuthentication
import Security

final class BiometricKeyManager {
    static let shared = BiometricKeyManager()
    private init() {}

    private let keyTag = "com.dket.faceid.keypair".data(using: .utf8)!

    // 1. 기존 키 불러오거나, 없으면 생성
    func loadOrCreateKeyPair() throws -> SecKey {
        // 기존 키가 있는지 확인
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            let existingKey = item as! SecKey
            print("🔑 기존 Secure Enclave 키 불러옴")
            return existingKey
        }

        // 없으면 새로 생성
        print("Secure Enclave 키 새로 생성")
        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, .biometryCurrentSet], // Face ID 보호
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

    // 2.Public Key 추출
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

    // 3.압축 Public Key (33 bytes)
    func compressPublicKey(_ uncompressedKey: Data) -> Data? {
        guard uncompressedKey.count == 65 else { return nil }
        let x = uncompressedKey[1...32]
        let y = uncompressedKey[33...64]
        let prefix: UInt8 = (y.last! % 2 == 0) ? 0x02 : 0x03
        var compressed = Data([prefix])
        compressed.append(x)
        return compressed
    }

    // 4.Secure Enclave 서명 (Face ID 인증 포함)
    func sign(challenge: String) async throws -> Data {
        // ① Face ID context 생성
        let context = LAContext()
        context.localizedReason = "티켓 결제를 위해 Face ID 인증이 필요합니다."

        // ② 키 로드 (없으면 자동 생성)
        let privateKey = try loadOrCreateKeyPair()

        // ③ Face ID 가능 여부 확인
        var authError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            throw authError ?? NSError(domain: "FaceID", code: -2, userInfo: [NSLocalizedDescriptionKey: "Face ID not available"])
        }

        // ④ Challenge를 Data로 변환
        guard let challengeData = challenge.data(using: .utf8) else {
            throw NSError(domain: "FaceID", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid challenge string"])
        }

        // ⑤ Secure Enclave로 서명
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            challengeData as CFData,
            &error
        ) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        print("Face ID 서명 완료 (\(signature.count) bytes)")
        print("서명(hex): \(signature.toHexString())")
        return signature
    }
}

// 5.Hex 변환 Extension
extension Data {
    func toHexString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}
