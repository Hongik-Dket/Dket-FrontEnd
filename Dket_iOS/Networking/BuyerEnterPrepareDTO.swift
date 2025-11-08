//
//  BuyerEnterPrepareDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/8/25.
//

struct BuyerEnterPrepareResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ChallengeResult?
}

struct ChallengeResult: Decodable {
    let challenge: String
    let expireAt: String
}
