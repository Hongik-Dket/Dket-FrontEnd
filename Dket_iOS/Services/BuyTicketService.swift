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
    
    private func encodeBuyTicketCall(sessionId: Int64) async throws -> Data {
        guard let url = Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json") else {
            throw NSError(domain: "BuyTicket", code: 0, userInfo: [NSLocalizedDescriptionKey: "ABI 파일을 찾을 수 없습니다"])
        }
        let abi = try String(contentsOf: url)
        guard let contractAddress = EthereumAddress("0x2ea3dccfc3114f43a0ab126eb24c55cc762a4407") else {
            throw NSError(domain: "BuyTicket", code: 0, userInfo: [NSLocalizedDescriptionKey: "잘못된 컨트랙트 주소"])
        }
        
        let rpcURL = URL(string: "https://eth-sepolia.g.alchemy.com/v2/CiydLLNTXgdxp4WB5-3J33i_8pxyLPwU")!
        let provider = try await Web3HttpProvider(url: rpcURL, network: .Custom(networkID: 11155111))
        let web3 = Web3(provider: provider)
        guard let contract = web3.contract(abi, at: contractAddress, abiVersion: 2),
              let op = contract.createWriteOperation("buyTicket", parameters: [BigUInt(sessionId)]) else {
            throw NSError(domain: "BuyTicket", code: 0, userInfo: [NSLocalizedDescriptionKey: "Contract 또는 Operation 생성 실패"])
        }
        
        let txData = op.transaction.data
        return txData
    }
    
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
    
    func sendBuyTicketTransaction(sessionId: Int64, from: String, value: BigUInt) async throws {
        print("🟠 Step 1: ABI 인코딩 시작")
            let encoded = try await encodeBuyTicketCall(sessionId: sessionId)
            print("🔧 ABI 인코딩 완료: 0x" + encoded.toHexString())

        print("🟠 Step 2: 트랜잭션 딕셔너리 구성")
            let tx = try buildTransactionDict(
                from: from,
                to: "0x2ea3dccfc3114f43a0ab126eb24c55cc762a4407",
                value: value,
                data: encoded
            )
            print("📦 트랜잭션 내용:\n\(tx)")

        guard let session = AppKit.instance.getSessions().first else {
               throw NSError(domain: "BuyTicket", code: 0, userInfo: [NSLocalizedDescriptionKey: "Wallet session not found"])
           }
        guard let sepoliaChainId = Blockchain("eip155:11155111") else {
            throw NSError(domain: "BuyTicket", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sepolia Chain ID 생성 실패"])
        }
        print("🟠 Step 3: WalletConnect 세션 topic=\(session.topic), chain=\(sepoliaChainId)")
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

//func encodeBuyTicket(sessionId: Int64) throws -> Data {
//    // ① ABI JSON 로드
//    let url = Bundle.main.url(forResource: "DketNFT.abi", withExtension: "json")!
//    let abi  = try String(contentsOf: url)
//    // ② 컨트랙트 주소
//    let addr = EthereumAddress("0x3fc31f1a5EF9F401Cc0c584F452dba0384596495")!
//    // ③ web3 객체 (RPC URL은 아무거나)
//    let web3 = Web3(provider: "https://rpc.sepolia.org" as! Web3Provider)
//    // ④ Contract & write op
//    let contract = web3.contract(abi, at: addr, abiVersion: 2)!
//    let op = contract.createWriteOperation(
//        "buyTicket",
//        parameters: [BigUInt(sessionId)]
//    )!
//    return op.transaction.data                     // ← ABI Data
//}
