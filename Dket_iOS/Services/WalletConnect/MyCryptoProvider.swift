//
//  MyCryptoProvider.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/22/25.
//

import Foundation
import WalletConnectSigner
import CryptoKit
import CryptoSwift

final class MyCryptoProvider: CryptoProvider {
    
    // 서명된 메시지로부터 공개키 복원 (여기선 간단히 에러 처리)
    func recoverPubKey(signature: EthereumSignature, message: Data) throws -> Data {
        throw NSError(domain: "RecoverPubKey not implemented", code: -1)
    }
    
    // keccak256 해시 함수
    func keccak256(_ data: Data) -> Data {
        let hash = SHA3(variant: .keccak256).calculate(for: [UInt8](data))
        return Data(hash)
    }
}
