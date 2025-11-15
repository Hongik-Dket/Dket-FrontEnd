//
//  WinProof.swift
//  Dket_iOS
//
//  Created by M-136 on 11/15/25.
//

// MARK: - Request DTO
struct WinProofRequestDTO: Encodable {
    let sessionId: Int64          // 세션 아이디
    let challengeId: String       // 서버에서 받은 challengeId
    let signature: String         // Face ID 서명 결과(hex)
    let publicKey: String         // Secure Enclave 공개키(hex, 66글자)
}

// MARK: - Response DTO
struct WinProofResponseDTO: Decodable {
    let proof: [String]           // 당첨 증명
    let nullifier: String         // Nullifier
}
