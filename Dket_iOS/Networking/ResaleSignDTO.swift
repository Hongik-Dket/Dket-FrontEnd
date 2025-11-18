//
//  ResaleSignDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/17/25.
//

struct ResaleSignRequestDTO: Encodable {
    let resaleId: Int64
    let challengeId: String
    let signature: String
    let publicKey: String
}

// MARK: - Response DTO (서명 응답)
struct ResaleSignResponseDTO: Decodable {
    let isSuccess: Bool
    let code: Int
    let message: String
}
