//
//  BuyTicketService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI
import BigInt
import struct Commons.AnyCodable
import web3swift
import Web3Core
import CoinbaseWalletSDK
import WalletConnectSign
import ReownAppKit

protocol BuyTicketServicing {
    func getApprovalInfo(for sessionId: Int64) async throws -> ApprovalResultDTO
    
    /// Proof + Nullifier를 포함한 결제 트랜잭션 전송
    func sendBuyTicketTransaction(
        sessionId: Int64,
        from: String,
        value: BigUInt,
        proof: [String],
        nullifier: String
    ) async throws
}

// MARK: - Service 구현
final class BuyTicketService: BuyTicketServicing {
    
    // 가격 및 Challenge 조회
    func getApprovalInfo(for sessionId: Int64) async throws -> ApprovalResultDTO {
        let endpoint = Endpoint.buyerTicketPrice(sessionId: sessionId)
        let result: ApprovalResultDTO = try await APIClient.shared.getDecoded(endpoint)
        
        print("sessionId: \(result.sessionId)")
        print("priceWei: \(result.priceWei)")
        print("challengeId: \(result.challengeId ?? "없음")")
        print("challenge: \(result.challenge ?? "없음")")
        
        return result
    }
    
    // 네트워크 환경 확인 (Sepolia 연결)
    private func ensureSepoliaEnvironment() async throws {
        guard let session = AppKit.instance.getSessions().first else { return }
        let existingChains = session.namespaces["eip155"]?.accounts.map { $0.reference } ?? []
        if existingChains.contains("11155111") {
            print("이미 세폴리아 네트워크 연결됨, 추가 작업 생략")
            return
        }

        let chain = Blockchain("eip155:1")!
        let params: [[String: AnyCodable]] = [[
            "chainId": AnyCodable("0xaa36a7"),
            "chainName": AnyCodable("Sepolia Testnet"),
            "nativeCurrency": AnyCodable([
                "name": AnyCodable("SepoliaETH"),
                "symbol": AnyCodable("ETH"),
                "decimals": AnyCodable(18)
            ]),
            "rpcUrls": AnyCodable(["https://rpc.sepolia.org"]),
            "blockExplorerUrls": AnyCodable(["https://sepolia.etherscan.io"])
        ]]
        let addRequest = try Request(
            topic: session.topic,
            method: "wallet_addEthereumChain",
            params: AnyCodable(params),
            chainId: chain
        )
        _ = try await Sign.instance.request(params: addRequest)
        print("세폴리아 체인 추가 완료")
    }
    
    // 스마트컨트랙트의 buyTicket(sessionId, proof[24], paymentNullifier) 호출용 데이터 인코딩
    private func encodeBuyTicketCall(
        sessionId: Int64,
        proof: [String],
        nullifier: String
    ) async throws -> Data {
        print("🧩 encodeBuyTicketCall() 시작 — sessionId=\(sessionId)")

        // 1️⃣ ABI 로드
        guard let url = Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json") else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다"])
        }

        let abi = try String(contentsOf: url)
        let contractAddressString = "0x4A1818381B361b0d0C6db04745E824D6EEd7B56E"

        guard let contractAddress = EthereumAddress(contractAddressString) else {
            throw NSError(domain: "BuyTicket", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "잘못된 컨트랙트 주소: \(contractAddressString)"])
        }

        // 2️⃣ Web3 및 provider 구성
        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)

        guard let contract = web3.contract(abi, at: contractAddress, abiVersion: 2) else {
            throw NSError(domain: "BuyTicket", code: -3,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 로드 실패 또는 컨트랙트 생성 실패"])
        }

        // 3️⃣ proof / nullifier 변환
        let proofBigUInts: [BigUInt] = proof.compactMap { BigUInt($0.stripHexPrefix(), radix: 16) }
        guard proofBigUInts.count == 24 else {
            throw NSError(domain: "BuyTicket", code: -4,
                          userInfo: [NSLocalizedDescriptionKey: "proof 배열 길이가 24가 아닙니다 (\(proofBigUInts.count))"])
        }

        let nullifierBytes = Data(hex: nullifier.stripHexPrefix())
        guard nullifierBytes.count == 32 else {
            throw NSError(domain: "BuyTicket", code: -5,
                          userInfo: [NSLocalizedDescriptionKey: "nullifier 길이가 32바이트가 아닙니다 (\(nullifierBytes.count))"])
        }

        // 4️⃣ createWriteOperation 호출 (안전 처리)
        guard let op = contract.createWriteOperation(
            "buyTicket",
            parameters: [
                BigUInt(sessionId),
                proofBigUInts,
                nullifierBytes
            ]
        ) else {
            print("❌ createWriteOperation() 실패 — ABI 함수명 또는 파라미터 불일치")
            if let mirror = Mirror(reflecting: contract).children.first {
                print("🧩 Contract 내부 구조: \(mirror)")
            }

            throw NSError(domain: "BuyTicket", code: -6,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 함수 매칭 실패: buyTicket"])
        }

        print("✅ buyTicket 인코딩 성공 — data 길이: \(op.transaction.data.count) bytes")
        return op.transaction.data
    }
    
    // 트랜잭션 Dict 구성
    private func buildTransactionDict(from: String, to: String, value: BigUInt, data: Data) -> [String: AnyCodable] {
        [
            "from": AnyCodable(from),
            "to": AnyCodable(to),
            "value": AnyCodable("0x" + value.serialize().toHexString()),
            "data": AnyCodable("0x" + data.toHexString()),
            "chainId": AnyCodable("0x" + String(11155111, radix: 16))
        ]
    }
    
    // 최종 트랜잭션 실행
    func sendBuyTicketTransaction(
        sessionId: Int64,
        from: String,
        value: BigUInt,
        proof: [String],
        nullifier: String
    ) async throws {
        guard let session = AppKit.instance.getSessions().first else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"])
        }

        // 트랜잭션 완료 후 세션 초기화
        defer {
            Task {
                for s in AppKit.instance.getSessions() {
                    try? await AppKit.instance.disconnect(topic: s.topic)
                }
                for p in AppKit.instance.getPairings() {
                    try? await AppKit.instance.disconnect(topic: p.topic)
                }
                print("🧹 트랜잭션 이후 세션 초기화 완료 (pending 방지)")
            }
        }

        try await ensureSepoliaEnvironment()
        let encoded = try await encodeBuyTicketCall(sessionId: sessionId, proof: proof, nullifier: nullifier)
        
        let tx = buildTransactionDict(
            from: from,
            to: "0x4A1818381B361b0d0C6db04745E824D6EEd7B56E",
            value: value,
            data: encoded
        )

        guard let chainId = Blockchain("eip155:11155111") else { return }
        let request = try Request(
            topic: session.topic,
            method: "eth_sendTransaction",
            params: AnyCodable([tx]),
            chainId: chainId
        )

        print("🟡 트랜잭션 요청 준비 완료. 사용자 서명 대기 중...")

        // MetaMask 자동 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let url = URL(string: "metamask://"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("❌ MetaMask 열기 실패: 앱 미설치 또는 URL 스킴 비활성화")
            }
        }

        let result = try await Sign.instance.request(params: request)
        print("🟢 트랜잭션 전송 성공:", result)
    }
}
