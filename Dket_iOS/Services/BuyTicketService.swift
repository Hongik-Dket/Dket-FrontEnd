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
    func getPriceWei(for sessionId: Int64) async throws -> BigUInt
    func sendBuyTicketTransaction(sessionId: Int64, from: String, value: BigUInt) async throws
}

// MARK: - Service 구현
final class BuyTicketService: BuyTicketServicing {
    
    // MARK: - 1️⃣ 가격 조회
    func getPriceWei(for sessionId: Int64) async throws -> BigUInt {
        let endpoint = Endpoint.buyerTicketPrice(sessionId: sessionId)
        let result: PriceWeiResult = try await APIClient.shared.getDecoded(endpoint)
        return BigUInt(result.priceWei)
    }
    
    // MARK: - 2️⃣ 체인 추가 및 전환 관련
    private func addSepoliaChain() async throws {
        guard let session = AppKit.instance.getSessions().first else { return }
        guard let chain = Blockchain("eip155:1") else { return }
        
        let params: [[String: AnyCodable]] = [[
            "chainId": AnyCodable("0xaa36a7"), // 11155111
            "chainName": AnyCodable("Sepolia Testnet"),
            "nativeCurrency": AnyCodable([
                "name": AnyCodable("SepoliaETH"),
                "symbol": AnyCodable("ETH"),
                "decimals": AnyCodable(18)
            ]),
            "rpcUrls": AnyCodable(["https://rpc.sepolia.org"]),
            "blockExplorerUrls": AnyCodable(["https://sepolia.etherscan.io"])
        ]]
        
        let request = try Request(
            topic: session.topic,
            method: "wallet_addEthereumChain",
            params: AnyCodable(params),
            chainId: chain
        )
        
        print("➕ MetaMask에 세폴리아 체인 추가 요청")
        _ = try await Sign.instance.request(params: request)
        print("✅ 세폴리아 체인 추가 완료")
    }
    
    private func ensureSepoliaChain() async throws {
        guard let session = AppKit.instance.getSessions().first else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"])
        }
        guard let chain = Blockchain("eip155:1") else { return }
        
        let params: [[String: AnyCodable]] = [[
            "chainId": AnyCodable("0xaa36a7")
        ]]
        
        let request = try Request(
            topic: session.topic,
            method: "wallet_switchEthereumChain",
            params: AnyCodable(params),
            chainId: chain
        )
        
        print("🔄 MetaMask에 세폴리아 체인 전환 요청")
        _ = try await Sign.instance.request(params: request)
        print("✅ 세폴리아 체인 전환 완료 (Sepolia)")
    }
    
    // MARK: - 3️⃣ ABI 인코딩
    private func encodeBuyTicketCall(sessionId: Int64) async throws -> Data {
        guard let url = Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json") else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다"])
        }
        let abi = try String(contentsOf: url)
        
        guard let contractAddress = EthereumAddress("0x3de27b56e716b618c7354a4f23cf104a8db62330") else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "잘못된 컨트랙트 주소"])
        }
        
        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)
        
        guard let contract = web3.contract(abi, at: contractAddress, abiVersion: 2),
              let op = contract.createWriteOperation("buyTicket", parameters: [BigUInt(sessionId)]) else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Contract 또는 Operation 생성 실패"])
        }
        
        return op.transaction.data
    }
    
    // MARK: - 4️⃣ 트랜잭션 구성
    private func buildTransactionDict(
        from: String,
        to: String,
        value: BigUInt,
        data: Data
    ) throws -> [String: AnyCodable] {
        return [
            "from": AnyCodable(from),
            "to": AnyCodable(to),
            "value": AnyCodable("0x" + value.serialize().toHexString()),
            "data": AnyCodable("0x" + data.toHexString()),
            "chainId": AnyCodable("0x" + String(11155111, radix: 16))
        ]
    }
    
    // MARK: - 5️⃣ 트랜잭션 전송
    func sendBuyTicketTransaction(sessionId: Int64, from: String, value: BigUInt) async throws {
        // (0) 세션 체크
        guard let session = AppKit.instance.getSessions().first else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"])
        }
        
        // (1) 체인 추가 및 전환
        do {
            try await addSepoliaChain()
            try await ensureSepoliaChain()
        } catch {
            print("⚠️ 체인 추가/전환 중 오류 발생 (무시 가능):", error.localizedDescription)
        }
        
        // (2) ABI 인코딩
        print("🟠 Step 1: ABI 인코딩 시작")
        let encoded = try await encodeBuyTicketCall(sessionId: sessionId)
        print("🔧 ABI 인코딩 완료: 0x" + encoded.toHexString())
        
        // (3) 트랜잭션 구성
        print("🟠 Step 2: 트랜잭션 딕셔너리 구성")
        let tx = try buildTransactionDict(
            from: from,
            to: "0x3de27b56e716b618c7354a4f23cf104a8db62330",
            value: value,
            data: encoded
        )
        print("📦 트랜잭션 내용:\n\(tx)")
        
        // (4) 세션 로그 출력
        let sessions = AppKit.instance.getSessions()
        for s in sessions {
            print("✅ Session chains:", s.namespaces.keys)
            print("✅ Accounts:", s.namespaces["eip155"]?.accounts ?? [])
            print("✅ Methods:", s.namespaces["eip155"]?.methods ?? [])
        }
        
        // (5) 체인 ID 지정
        guard let sepoliaChainId = Blockchain("eip155:11155111") else {
            throw NSError(domain: "BuyTicket", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Sepolia Chain ID 생성 실패"])
        }
        
        print("🟠 Step 3: WalletConnect 세션 topic=\(session.topic), chain=\(sepoliaChainId)")
        
        // (6) 트랜잭션 요청
        let request = try Request(
            topic: session.topic,
            method: "eth_sendTransaction",
            params: AnyCodable([tx]),
            chainId: sepoliaChainId
        )
        
        print("🟡 트랜잭션 요청 준비 완료. 사용자 서명 대기 중...")
        let result = try await Sign.instance.request(params: request)
        print("🟢 사용자 서명 및 트랜잭션 요청 전송 성공: \(result)")
    }
}
