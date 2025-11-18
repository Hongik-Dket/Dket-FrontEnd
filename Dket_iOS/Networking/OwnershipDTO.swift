//
//  OwnershipDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/16/25.
//

struct OwnershipChallengeDTO: Codable {
    let challengeId: String
    let challenge: String
}

struct OwnershipProofRequestDTO: Codable {
    let sessionId: Int64?
    let challengeId: String
    let signature: String
    let publicKey: String
}

struct OwnershipProofResponseDTO: Codable {
    let qrCodeUrl: String?
    let identityType: String
}
