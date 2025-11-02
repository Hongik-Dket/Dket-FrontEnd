//
//  ApproveNFTService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/2/25.
//

import Foundation
import BigInt
import struct Commons.AnyCodable
import web3swift
import Web3Core
import WalletConnectSign
import ReownAppKit

protocol ApproveNFTServicing {
    func sendApproveTransaction(tokenId: Int64, from: String) async throws
}

// MARK: - Approve Service 구현
final class ApproveNFTService: ApproveNFTServicing {
    
    // MARK: - approve 인코딩
    private func encodeApproveCall(tokenId: Int64) async throws -> Data {
        guard let url = Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json") else {
            throw NSError(domain: "ApproveNFT", code: 0, userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다"])
        }
        
        let abi = try String(contentsOf: url)
        
        // DketNFT 컨트랙트 주소
        guard let contractAddress = EthereumAddress("0x3de27b56e716b618c7354a4f23cf104a8db62330") else {
            throw NSError(domain: "ApproveNFT", code: 0, userInfo: [NSLocalizedDescriptionKey: "잘못된 컨트랙트 주소"])
        }
        
        // Sepolia RPC
        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)
        
        // approve(address,uint256) 인코딩
        guard let contract = web3.contract(abi, at: contractAddress, abiVersion: 2),
              let op = contract.createWriteOperation(
                "approve",
                parameters: ["0xF73744c62923d1Fb6F86f62F89A755D0dC348D1C",  // DketResale 주소
                             BigUInt(tokenId)]
              ) else {
            throw NSError(domain: "ApproveNFT", code: 0, userInfo: [NSLocalizedDescriptionKey: "Contract 또는 Operation 생성 실패"])
        }
        
        return op.transaction.data
    }
    
    // MARK: - 트랜잭션 딕셔너리 구성
    private func buildTransactionDict(from: String, to: String, data: Data) -> [String: AnyCodable] {
        [
            "from": AnyCodable(from),
            "to": AnyCodable(to),
            "data": AnyCodable("0x" + data.toHexString()),
            "value": AnyCodable("0x0"),
            "chainId": AnyCodable("0x" + String(11155111, radix: 16))
        ]
    }
    
    // MARK: - approve 트랜잭션 전송
    func sendApproveTransaction(tokenId: Int64, from: String) async throws {
        print("Step 1: ABI 인코딩 시작")
        let encoded = try await encodeApproveCall(tokenId: tokenId)
        print("🔧 ABI 인코딩 완료: 0x" + encoded.toHexString())
        
        print("Step 2: 트랜잭션 구성")
        let tx = buildTransactionDict(
            from: from,
            to: "0x3de27b56e716b618c7354a4f23cf104a8db62330", // DketNFT 컨트랙트 주소
            data: encoded
        )
        print("트랜잭션 내용:\n\(tx)")
        
        // WalletConnect 세션 가져오기
        guard let session = AppKit.instance.getSessions().first else {
            throw NSError(domain: "ApproveNFT", code: 0, userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"])
        }
        guard let sepoliaChainId = Blockchain("eip155:11155111") else {
            throw NSError(domain: "ApproveNFT", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sepolia Chain ID 생성 실패"])
        }
        
        print("Step 3: WalletConnect topic=\(session.topic), chain=\(sepoliaChainId)")
        
        // 서명 요청 생성
        let request = try Request(
            topic: session.topic,
            method: "eth_sendTransaction",
            params: AnyCodable([tx]),
            chainId: sepoliaChainId
        )
        
        print("트랜잭션 요청 준비 완료. 사용자 MetaMask 서명 대기 중...")
        let result = try await Sign.instance.request(params: request)
        
        print("트랜잭션 성공적으로 전송됨: \(result)")
    }
}
