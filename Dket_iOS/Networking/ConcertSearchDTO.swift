//
//  ConcertSearchDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/11/25.
//

struct SearchResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [ConcertSearchCardDTO]
}

struct ConcertSearchCardDTO: Codable, Identifiable {
    let concertId: Int64
    let title: String
    let location: String
    let startDate: String
    let endDate: String
    let imageUrl: String
    let concertStatus: ConcertStatus

    var id: Int64 { concertId }
}
