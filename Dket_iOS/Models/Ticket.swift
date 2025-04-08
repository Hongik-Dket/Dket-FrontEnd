//
//  Ticket.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import Foundation

// 티켓 상태 (상황에 맞게 확장 가능)
enum TicketStatus: String, Codable {
    case available    // 판매 가능
    case sold         // 판매 완료
    case resold       // 리세일 완료
    case used         // 사용 완료 (입장 완료)
}

// 디지털 굿즈 관련 정보 (NFT 메타데이터)
struct DigitalGoods: Codable {
    let ipfsURL: String          // IPFS URL
    let type: String             // "PhotoCard", "Video", "Image"
    let description: String?     // 굿즈 설명
}

// 티켓 데이터 모델
struct Ticket: Identifiable, Codable {
    let id: String                  // 티켓 고유 ID
    let eventId: String             // 공연 ID
    let seatNumber: String?         // 좌석 번호 (지정석 없으면 nil)
    let ownerAddress: String        // 소유자 Ethereum 지갑 주소
    let price: Double               // 티켓 가격 (ETH 또는 USD 기준)
    var status: TicketStatus        // 티켓 상태
    let issuedDate: Date            // 발행 시점
    
    // 리세일 관련 정보
    let resaleAllowed: Bool         // 리세일 가능 여부
    let resaleMaxPrice: Double?   // 최대 리세일 가격 제한
    
    // NFT 메타데이터
    let metadataURL: String?        // NFT 메타데이터 IPFS URL
    let digitalGoods: [DigitalGoods]? // 디지털 굿즈 목록
    
    // zk-SNARK 인증 관련 (영지식 증명 상태 관리)
    var zkProofSubmitted: Bool
        
    // 입장 시 생체 인증 완료 여부
    var isBiometricVerified: Bool
}

// 예제 데이터 (개발용 더미데이터 생성)
extension Ticket {
    static let example = Ticket(
        id: "1234567890",
        eventId: "event123",
        seatNumber: "A-12",
        ownerAddress: "0x1234567890abcdef1234567890abcdef12345678",
        price: 0.08,
        status: .sold,
        issuedDate: Date(),
        resaleAllowed: true,
        resaleMaxPrice: 0.1,
        metadataURL: "https://ipfs.io/ipfs/QmExampleHash",
        digitalGoods: [
            DigitalGoods(
                ipfsURL: "https://ipfs.io/ipfs/QmDigitalGoodsHash",
                type: "PhotoCard",
                description: "Exclusive artist photocard"
            )
        ],
        zkProofSubmitted: false,
        isBiometricVerified: false
    )
}

