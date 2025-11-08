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
    func getPriceWei(for sessionId: Int64) async throws -> BigUInt {
        let endpoint = Endpoint.buyerTicketPrice(sessionId: sessionId)
        let result: PriceWeiResult = try await APIClient.shared.getDecoded(endpoint)
        return BigUInt(result.priceWei)
    }

    private func ensureSepoliaEnvironment() async throws {
        guard let session = AppKit.instance.getSessions().first else { return }

        let existingChains = session.namespaces["eip155"]?.accounts.map { $0.reference } ?? []
        if existingChains.contains("11155111") {
            print("✅ 이미 세폴리아 네트워크 연결됨, 추가 작업 생략")
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
        print("✅ 세폴리아 체인 추가 완료")
    }

    private func encodeBuyTicketCall(sessionId: Int64) async throws -> Data {
        guard let url = Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json") else {
            throw NSError(domain: "BuyTicket", code: 0, userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다"])
        }
        let abi = try String(contentsOf: url)
        let contractAddress = EthereumAddress("0x3de27b56e716b618c7354a4f23cf104a8db62330")!
        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)
        let contract = web3.contract(abi, at: contractAddress, abiVersion: 2)!
        let op = contract.createWriteOperation("buyTicket", parameters: [BigUInt(sessionId)])!
        return op.transaction.data
    }

    private func buildTransactionDict(from: String, to: String, value: BigUInt, data: Data) -> [String: AnyCodable] {
        [
            "from": AnyCodable(from),
            "to": AnyCodable(to),
            "value": AnyCodable("0x" + value.serialize().toHexString()),
            "data": AnyCodable("0x" + data.toHexString()),
            "chainId": AnyCodable("0x" + String(11155111, radix: 16))
        ]
    }

    func sendBuyTicketTransaction(sessionId: Int64, from: String, value: BigUInt) async throws {
        guard let session = AppKit.instance.getSessions().first else {
            throw NSError(domain: "BuyTicket", code: 0, userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"])
        }

        // ✅ 트랜잭션 완료 시 세션 정리용 defer
        defer {
            Task {
                for session in AppKit.instance.getSessions() {
                    try? await AppKit.instance.disconnect(topic: session.topic)
                }
                for pairing in AppKit.instance.getPairings() {
                    try? await AppKit.instance.disconnect(topic: pairing.topic)
                }
                print("🧹 트랜잭션 이후 세션 초기화 완료 (pending 방지)")
            }
        }

        try await ensureSepoliaEnvironment()
        let encoded = try await encodeBuyTicketCall(sessionId: sessionId)
        let tx = buildTransactionDict(from: from, to: "0x3de27b56e716b618c7354a4f23cf104a8db62330", value: value, data: encoded)

        guard let chainId = Blockchain("eip155:11155111") else { return }
        let request = try Request(topic: session.topic, method: "eth_sendTransaction", params: AnyCodable([tx]), chainId: chainId)
        print("🟡 트랜잭션 요청 준비 완료. 사용자 서명 대기 중...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let url = URL(string: "metamask://") {
                    if UIApplication.shared.canOpenURL(url) {
                        print("📲 MetaMask로 전환 시도")
                        UIApplication.shared.open(url)
                    } else {
                        print("❌ MetaMask 열기 실패: 앱이 설치되지 않았거나 URL 스킴이 비활성화됨")
                    }
                }
            }

        let result = try await Sign.instance.request(params: request)
        print("🟢 트랜잭션 전송 성공:", result)
    }
}
