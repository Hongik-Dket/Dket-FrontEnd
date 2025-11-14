//
//  BuyResaleWithSigService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import Foundation
import BigInt
import struct Commons.AnyCodable
import web3swift
import Web3Core
import WalletConnectSign
import ReownAppKit
import UIKit

protocol BuyResaleWithSigServicing {
    func sendBuyResaleTransaction(
        resaleId: Int64,
        tokenId: Int64,
        expireAt: Int64,
        signature: String,
        priceWei: Int64,
        from: String
    ) async throws
}

final class BuyResaleWithSigService: BuyResaleWithSigServicing {
    
    // MARK: - 1️⃣ 인코딩
    private func encodeBuyResaleWithSigCall(
        resaleId: Int64,
        tokenId: Int64,
        expireAt: Int64,
        signature: String
    ) async throws -> Data {
        print("🟢 [DEBUG] buyResaleWithSig 인코딩 시작")

        guard let url = Bundle.main.url(forResource: "DketResale", withExtension: "abi.json") ??
                        Bundle.main.url(forResource: "DketResale.abi", withExtension: "json") else {
            throw NSError(domain: "BuyResaleWithSig", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다."])
        }

        let abiData = try Data(contentsOf: url)
        let abiString = String(data: abiData, encoding: .utf8)!

        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)
        
        guard let contractAddress = EthereumAddress("0x1C5dB92Cf1e1417b8c981911d095365b784Fe87F"),
              let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        else {
            throw NSError(domain: "BuyResaleWithSig", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Contract 생성 실패"])
        }

        let signatureBytes = Data(hex: signature.drop0xPrefix())

        guard let op = contract.createWriteOperation(
            "buyResaleWithSig",
            parameters: [
                BigUInt(resaleId),
                BigUInt(tokenId),
                BigUInt(expireAt),
                signatureBytes
            ]
        ) else {
            throw NSError(domain: "BuyResaleWithSig", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 인코딩 실패"])
        }

        print("✅ [DEBUG] buyResaleWithSig 인코딩 성공")
        return op.transaction.data
    }

    // MARK: - 2️⃣ 트랜잭션 딕셔너리 구성
    private func buildTransactionDict(
        from: String,
        data: Data,
        priceWei: Int64
    ) -> [String: AnyCodable] {
        [
            "from": AnyCodable(from),
            "to": AnyCodable("0x1C5dB92Cf1e1417b8c981911d095365b784Fe87F"),
            "data": AnyCodable("0x" + data.toHexString()),
            "value": AnyCodable(priceWei > 0 ? "0x" + String(priceWei, radix: 16) : "0x0"),
            "chainId": AnyCodable("0x" + String(11155111, radix: 16))
        ]
    }

    // MARK: - 3️⃣ 트랜잭션 전송
    func sendBuyResaleTransaction(
        resaleId: Int64,
        tokenId: Int64,
        expireAt: Int64,
        signature: String,
        priceWei: Int64,
        from: String
    ) async throws {
        print("🟢 [DEBUG] buyResaleWithSig 트랜잭션 시작")

        let encoded = try await encodeBuyResaleWithSigCall(
            resaleId: resaleId,
            tokenId: tokenId,
            expireAt: expireAt,
            signature: signature
        )
        
        let tx = buildTransactionDict(from: from, data: encoded, priceWei: priceWei)
        
        guard let session = AppKit.instance.getSessions().first else {
            throw NSError(domain: "BuyResaleWithSig", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"])
        }
        guard let sepoliaChainId = Blockchain("eip155:11155111") else {
            throw NSError(domain: "BuyResaleWithSig", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Chain ID 생성 실패"])
        }

        let request = try Request(
            topic: session.topic,
            method: "eth_sendTransaction",
            params: AnyCodable([tx]),
            chainId: sepoliaChainId
        )

        if let url = URL(string: "metamask://") {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }

                print("🟦 [DEBUG] MetaMask 서명 대기 중...")
                let result = try await Sign.instance.request(params: request)
                print("✅ [SUCCESS] buyResaleWithSig 트랜잭션 완료: \(result)")
    }
}

extension String {
    func drop0xPrefix() -> String {
        hasPrefix("0x") ? String(dropFirst(2)) : self
    }
}
