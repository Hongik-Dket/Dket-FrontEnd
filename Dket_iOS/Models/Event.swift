//
//  Evernt.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//
import Foundation

// 공연 상태 관리
enum EventStatus: String, Codable {
    case scheduled    // 예정된 공연
    case ongoing      // 현재 진행 중
    case ended        // 종료된 공연
    case canceled     // 취소된 공연
}

// 공연 데이터 모델
struct Event: Identifiable, Codable {
    let id: String                      // 공연 고유 ID
    let hostId: String                  // 주최자 지갑 주소
    let title: String                   // 공연명
    let description: String?            // 공연 설명
    let location: String                // 공연 장소
    let startDate: Date                 // 공연 시작 일시
    let endDate: Date                   // 공연 종료 일시
    let createdAt: Date                 // 이벤트 생성 일시
    
    var status: EventStatus             // 공연 진행 상태
    
    let maxTickets: Int                 // 최대 티켓 수량
    var ticketsSold: Int                // 판매된 티켓 수
    var ticketPrice: Double             // 티켓 가격
    
    // 디지털 굿즈 관련 정보 (NFT 메타데이터)
    var digitalGoodsMetadataURL: URL?   // IPFS에 저장된 굿즈 메타데이터 URL
    
    // 리세일 정책
    var isResaleAllowed: Bool           // 리세일 허용 여부
    var resalePriceCap: Double?         // 리세일 가격 상한선
    
    // 응모 및 추첨 관련 일정
    var applicationStart: Date          // 응모 시작 일시
    var applicationEnd: Date            // 응모 마감 일시
    var paymentDeadline: Date           // 결제 마감 일시
    
    // 스마트 컨트랙트 연동 정보 (Optional)
    var contractAddress: String?        // NFT 티켓 스마트 컨트랙트 주소
}

// 개발 및 테스트를 위한 더미 데이터
extension Event {
    static let exampleEvent = Event(
        id: "event789",
        hostId: "0x1234567890abcdef1234567890abcdef12345678",
        title: "Dket Live Concert",
        description: "Experience a fantastic evening with great artists!",
        location: "Olympic Stadium, Seoul",
        startDate: Date().addingTimeInterval(86400 * 30), // 한 달 후
        endDate: Date().addingTimeInterval(86400 * 30 + 7200), // 한 달 후 + 2시간 공연
        createdAt: Date(),
        status: .scheduled,
        maxTickets: 500,
        ticketsSold: 150,
        ticketPrice: 0.05, // ETH로 예시
        digitalGoodsMetadataURL: URL(string: "https://ipfs.io/ipfs/QmExampleMetaData"),
        isResaleAllowed: true,
        resalePriceCap: 0.1, // ETH로 예시
        applicationStart: Date().addingTimeInterval(86400 * 10), // 10일 후 응모 시작
        applicationEnd: Date().addingTimeInterval(86400 * 15), // 15일 후 응모 마감
        paymentDeadline: Date().addingTimeInterval(86400 * 17), // 17일 후 결제 마감
        contractAddress: "0xContractAddressExample"
    )
}
