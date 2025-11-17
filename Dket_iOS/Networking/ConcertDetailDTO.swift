//
//  EventDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

// MARK: - ConcertDetailDTO
struct ConcertDetailDTO: Decodable {
    let concertId: Int64
    let title: String
    let posterUrl: URL
    let location: String
    let startDate: String
    let endDate: String
    let startTime: String
    let endTime: String
    let ageLimit: AgeLimit
    let priceKrw: Int
    let applyStart: String
    let applyEnd: String
    let capacity: Int
    let concertStatus: ConcertStatus
    let sessionIds: [Int64]
    let description: String
    let photoCardList: [PhotoCardInfoDTO]   // ✅ 포토카드 정보 DTO
    let isResaleAllowed: Bool
}

// MARK: - DTO → Domain 변환
extension ConcertDetailDTO {
    var domain: ConcertDetail {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let startDateObj = dateFormatter.date(from: startDate) ?? .now
        let endDateObj = dateFormatter.date(from: endDate) ?? .now

        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let applyStartDate = dateTimeFormatter.date(from: applyStart) ?? .now
        let applyEndDate = dateTimeFormatter.date(from: applyEnd) ?? .now

        return ConcertDetail(
            id: concertId,
            title: title,
            poster: posterUrl,
            location: location,
            period: startDateObj ... endDateObj,
            timeRange: (startTime, endTime),
            ageLimit: ageLimit,
            priceKrw: priceKrw,
            applyPeriod: applyStartDate ... applyEndDate,
            capacity: capacity,
            status: concertStatus,
            sessionIds: sessionIds,
            description: description,
            photoCards: photoCardList.map { $0.toDomain() }, // ✅ PhotoCardInfo로 변환
            isResaleAllowed: isResaleAllowed
        )
    }
}

// MARK: - PhotoCardInfoDTO
struct PhotoCardInfoDTO: Decodable {
    let photoCardId: Int64
    let imageUrl: String
}

// MARK: - Domain 모델
struct PhotoCardInfo: Identifiable {
    let id: Int64
    let imageUrl: String
}

// MARK: - DTO → Domain 변환
extension PhotoCardInfoDTO {
    func toDomain() -> PhotoCardInfo {
        PhotoCardInfo(id: photoCardId, imageUrl: imageUrl)
    }
}
