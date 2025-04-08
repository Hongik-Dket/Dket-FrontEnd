//
//  User.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//
import Foundation

// 사용자 역할
enum UserRole: String, Codable {
    case buyer      // 구매자
    case host       // 개최자
}

// 사용자 데이터 모델
struct User: Identifiable, Codable {
    let id: String                  // 사용자 고유 ID
    let role: UserRole              // 사용자 역할 (구매자 or 개최자)
    var walletAddress: String       // Ethereum 지갑 주소
    
    // 프로필 정보 (선택사항)
    var nickname: String?           // 사용자 닉네임
    var email: String?              // 사용자 이메일
    var createdAt: Date             // 가입 날짜
    
    // Optional
    var hostedEventIds: [String]?   // 개최자가 주최한 공연 ID 목록
    var purchasedTicketIds: [String]? // 구매자가 구매한 티켓 NFT ID 목록
}

// 더미 데이터
extension User {
    static let buyerExample = User(
        id: "0xabcdef1234567890abcdef1234567890abcdef12",
        role: .buyer,
        walletAddress: "0xabcdef1234567890abcdef1234567890abcdef12",
        nickname: "ConcertFan",
        email: "fan@example.com",
        createdAt: Date(),
        hostedEventIds: nil,
        purchasedTicketIds: ["ticket123", "ticket456"]
    )
    
    static let hostExample = User(
        id: "0x1234567890abcdef1234567890abcdef12345678",
        role: .host,
        walletAddress: "0x1234567890abcdef1234567890abcdef12345678",
        nickname: "EventOrganizer",
        email: "organizer@example.com",
        createdAt: Date(),
        hostedEventIds: ["event789", "event101"],
        purchasedTicketIds: nil
    )
}

