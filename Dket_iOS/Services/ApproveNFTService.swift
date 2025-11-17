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
import UIKit

protocol ApproveNFTServicing {
    func sendApproveTransaction(tokenId: Int64, from: String) async throws
}

// MARK: - Approve Service 구현
final class ApproveNFTService: ApproveNFTServicing {
    
    // MARK: - approve 인코딩
    private func encodeApproveCall(tokenId: Int64) async throws -> Data {
        print("🟦 [DEBUG] Step 0 - encodeApproveCall 시작 (tokenId=\(tokenId))")
        
        // 1️⃣ ABI 파일 로드
        guard let url = Bundle.main.url(forResource: "DketNFT", withExtension: "abi.json") ??
                Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json") else {
            print("❌ [ERROR] ABI 파일을 찾을 수 없습니다.")
            throw NSError(domain: "ApproveNFT", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다"])
        }
        print("🟩 [DEBUG] ABI 파일 경로: \(url.path)")
        
        // 2️⃣ ABI 데이터 읽기
        let abiData = try Data(contentsOf: url)
        print("🟩 [DEBUG] ABI 파일 크기: \(abiData.count) bytes")
        
        guard let abiString = String(data: abiData, encoding: .utf8),
              abiString.isEmpty == false else {
            print("❌ [ERROR] ABI 디코딩 실패 or 내용이 비어있음")
            throw NSError(domain: "ApproveNFT", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 디코딩 실패 또는 빈 내용"])
        }
        print("🟩 [DEBUG] ABI 문자열 앞부분:\n\(abiString.prefix(100))")
        
        // 3️⃣ 컨트랙트 주소 유효성 확인
        guard let contractAddress = EthereumAddress("0x5ae53b6a02a5630373994eaa5665a9669251204c") else {
            print("❌ [ERROR] 잘못된 컨트랙트 주소")
            throw NSError(domain: "ApproveNFT", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "잘못된 컨트랙트 주소"])
        }
        print("🟩 [DEBUG] 컨트랙트 주소 확인 완료: \(contractAddress.address)")
        
        // 4️⃣ 네트워크 연결
        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        print("🟦 [DEBUG] Web3 Provider 초기화 시도 중...")
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)
        print("🟩 [DEBUG] Web3 Provider 연결 성공 (Sepolia)")
        
        // 5️⃣ 컨트랙트 객체 생성
        guard let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2) else {
            print("❌ [ERROR] web3.contract 생성 실패 — ABI 형식 또는 주소 불일치 가능성")
            throw NSError(domain: "ApproveNFT", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Contract 생성 실패"])
        }
        print("🟩 [DEBUG] Contract 객체 생성 완료 ✅")
        
        
        // 6️⃣ approve operation 생성
        guard let op = contract.createWriteOperation(
            "approve",
            parameters: [
                EthereumAddress("0xa90ba6b8333111CE444Fcd0A227E269D2811cc36")!,  // DketResale 주소
                BigUInt(tokenId)
            ]
        ) else {
            print("❌ [ERROR] createWriteOperation('approve', ...) 생성 실패")
            print("🟥 [HINT] 1) ABI에 'approve' 함수가 없거나 2) 파라미터 타입 불일치 가능성 있음")
            throw NSError(domain: "ApproveNFT", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Operation 생성 실패"])
        }
        print("🟩 [DEBUG] approve operation 생성 완료 ✅")
        
        // 7️⃣ 트랜잭션 데이터 확인
        let encodedData = op.transaction.data
        print("🟩 [DEBUG] ABI 인코딩 완료: \(encodedData.count) bytes")
        print("🟩 [DEBUG] ABI Hex Data 시작 부분: 0x\(encodedData.toHexString().prefix(64))")
        
        return encodedData
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
            to: "0x5ae53b6a02a5630373994eaa5665a9669251204c", // DketNFT 컨트랙트 주소
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
        // ✅ MetaMask 딥링크로 전환 (핵심 추가)
            DispatchQueue.main.async {
                if let metamaskURL = URL(string: "metamask://") {
                    UIApplication.shared.open(metamaskURL, options: [:]) { success in
                        print(success ? "🟢 MetaMask 앱 열기 성공" : "🔴 MetaMask 앱 열기 실패")
                    }
                }
            }
        let result = try await Sign.instance.request(params: request)
        
        print("트랜잭션 성공적으로 전송됨: \(result)")
    }
}
