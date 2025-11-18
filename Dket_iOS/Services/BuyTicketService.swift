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
        
        print("📦 [ApprovalInfo] sessionId: \(result.sessionId)")
        print("📦 [ApprovalInfo] priceWei: \(result.priceWei)")
        print("📦 [ApprovalInfo] challengeId: \(result.challengeId ?? "없음")")
        print("📦 [ApprovalInfo] challenge: \(result.challenge ?? "없음")")
        
        return result
    }
    
    // 네트워크 환경 확인 (Sepolia 연결)
    private func ensureSepoliaEnvironment() async throws {
        print("🌐 네트워크 환경 확인 중...")
        guard let session = AppKit.instance.getSessions().first else {
            print("🚨 세션 없음 (WalletConnect 연결 안됨)")
            return
        }
        
        let existingChains = session.namespaces["eip155"]?.accounts.map { $0.reference } ?? []
        print("🌐 현재 연결된 chains:", existingChains)
        
        if existingChains.contains("11155111") {
            print("✅ 이미 세폴리아 네트워크 연결됨")
            return
        }

        print("🔄 세폴리아 체인 추가 요청 중...")
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
        print("✅ 세폴리아 체인 추가 완료")
    }
    
    // ✅ 인코딩 과정 로깅
    private func encodeBuyTicketCall(
        sessionId: Int64,
        proof: [String],
        nullifier: String
    ) async throws -> Data {
        print("🧩 [encodeBuyTicketCall] 시작 — sessionId=\(sessionId)")
        print("🧩 proof count: \(proof.count)")
        print("🧩 proof[0]: \(proof.first ?? "없음")")
        print("🧩 nullifier(hex): \(nullifier)")

        // 1️⃣ ABI 로드
        guard let url = Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json") else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다"])
        }

        let abi = try String(contentsOf: url)
        let contractAddressString = "0xF0A34dd5e4713C582e196B3eadc8D38DeeE07d4E"

        guard let contractAddress = EthereumAddress(contractAddressString) else {
            throw NSError(domain: "BuyTicket", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "잘못된 컨트랙트 주소: \(contractAddressString)"])
        }

        // 2️⃣ Web3 구성
        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)

        guard let contract = web3.contract(abi, at: contractAddress, abiVersion: 2) else {
            throw NSError(domain: "BuyTicket", code: -3,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 로드 실패 또는 컨트랙트 생성 실패"])
        }

        // 3️⃣ proof → BigUInt[24] 변환 (정확히 32바이트 고정)
        let proofBigUInts: [BigUInt] = proof.map {
            let hex = $0.stripHexPrefix().padding(toLength: 64, withPad: "0", startingAt: 0)
            return BigUInt(hex, radix: 16) ?? BigUInt(0)
        }

        guard proofBigUInts.count == 24 else {
            throw NSError(domain: "BuyTicket", code: -4,
                          userInfo: [NSLocalizedDescriptionKey: "proof 배열 길이가 24가 아닙니다 (\(proofBigUInts.count))"])
        }

        // 4️⃣ nullifier → Data(32바이트)
        let nullifierHex = nullifier.stripHexPrefix().padding(toLength: 64, withPad: "0", startingAt: 0)
        let nullifierBytes = Data(hex: nullifierHex)
        guard nullifierBytes.count == 32 else {
            throw NSError(domain: "BuyTicket", code: -5,
                          userInfo: [NSLocalizedDescriptionKey: "nullifier 길이가 32바이트가 아닙니다 (\(nullifierBytes.count))"])
        }

        // 5️⃣ ABI 인코딩 (정적 배열 [24])
        guard let op = contract.createWriteOperation(
            "buyTicket",
            parameters: [
                BigUInt(sessionId),
                proofBigUInts,
                nullifierBytes
            ]
        ) else {
            throw NSError(domain: "BuyTicket", code: -6,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 함수 매칭 실패: buyTicket"])
        }

        print("✅ buyTicket 인코딩 성공 — data 길이: \(op.transaction.data.count) bytes")
        print("✅ data prefix:", op.transaction.data.toHexString().prefix(16))
        return op.transaction.data
    }
    
    // 트랜잭션 Dict 구성
    private func buildTransactionDict(from: String, to: String, value: BigUInt, data: Data) -> [String: AnyCodable] {
        print("💰 buildTransactionDict() 호출됨")
        print("   from: \(from)")
        print("   to:   \(to)")
        print("   value(wei): \(value)")
        print("   data length: \(data.count)")

        // ✅ 1️⃣ Wei를 안전한 0x-hex 문자열로 변환
        var valueHex = value.serialize().toHexString()
        
        // 홀수 길이일 경우 앞에 0 추가 (MetaMask는 바이트 단위 정렬을 기대)
        if valueHex.count % 2 != 0 {
            valueHex = "0" + valueHex
        }
        
        let formattedValue = "0x" + valueHex.lowercased()
        print("💰 [TX] value(hex): \(formattedValue)")

        // ✅ 2️⃣ 트랜잭션 딕셔너리 구성
        return [
            "from": AnyCodable(from),
            "to": AnyCodable(to),
            "value": AnyCodable(formattedValue), // ← 여기 핵심
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
        print("🚀 sendBuyTicketTransaction() 시작")
        print("   sessionId: \(sessionId)")
        print("   from: \(from)")
        print("   value(wei): \(value)")
        print("   proof count: \(proof.count)")
        print("   nullifier: \(nullifier.prefix(20))...")

        // ✅ 1️⃣ WalletConnect 세션 확인
        guard let session = AppKit.instance.getSessions().first else {
            throw NSError(
                domain: "BuyTicket",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"]
            )
        }

        // ✅ 2️⃣ 네트워크 환경 확인 (Sepolia 연결)
        try await ensureSepoliaEnvironment()
        print("✅ 네트워크 환경 확인 완료")

        // ✅ 3️⃣ ABI 인코딩
        let encoded = try await encodeBuyTicketCall(
            sessionId: sessionId,
            proof: proof,
            nullifier: nullifier
        )
        print("✅ 인코딩 완료 — data hex prefix:", encoded.toHexString().prefix(16))

        // ✅ 4️⃣ 트랜잭션 데이터 구성
        let tx = buildTransactionDict(
            from: from,
            to: "0xF0A34dd5e4713C582e196B3eadc8D38DeeE07d4E", // DketNFT 주소
            value: value,
            data: encoded
        )

        guard let chainId = Blockchain("eip155:11155111") else {
            print("🚨 chainId 변환 실패")
            return
        }

        // ✅ 5️⃣ 트랜잭션 요청 생성
        let request = try Request(
            topic: session.topic,
            method: "eth_sendTransaction",
            params: AnyCodable([tx]),
            chainId: chainId
        )

        print("🟡 트랜잭션 요청 준비 완료. 사용자 서명 대기 중...")

        // ✅ 6️⃣ MetaMask 자동 실행 (앱 → MetaMask)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let url = URL(string: "metamask://"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print("📲 MetaMask 호출 시도됨")
            } else {
                print("❌ MetaMask 열기 실패: 앱 미설치 또는 URL 스킴 비활성화")
            }
        }

        // ✅ 7️⃣ MetaMask에서 사용자 서명 및 전송 대기
        do {
            let result = try await Sign.instance.request(params: request)
            print("🟢 트랜잭션 전송 성공:", result)
        } catch {
            print("❌ 트랜잭션 실패:", error.localizedDescription)
            throw error
        }

        // ✅ 8️⃣ 세션 유지 (disconnect 호출 X)
        print("🧩 WalletConnect 세션 유지 중 — 이후 트랜잭션에서도 재사용 가능")
    }
}
