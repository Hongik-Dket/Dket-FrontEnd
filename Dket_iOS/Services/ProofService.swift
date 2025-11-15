//
//  ProofService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/15/25.
//

import Foundation
import LocalAuthentication
import Security

final class ProofService {
    static let shared = ProofService()
    private init() {}

    func submitWinProof(
        sessionId: Int64,
        challengeId: String,
        signature: String,
        publicKey: String
    ) async throws -> WinProofResponseDTO {
        let dto = WinProofRequestDTO(
            sessionId: sessionId,
            challengeId: challengeId,
            signature: signature,
            publicKey: publicKey
        )

        print("📨 Proof 전송 JSON: \(dto)")

        let response: APIResponse<WinProofResponseDTO> = try await APIClient.shared.post(
            .proofsWin,
            body: dto,
            as: APIResponse<WinProofResponseDTO>.self
        )

        guard response.isSuccess else {
            throw NSError(
                domain: "ProofService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: response.message]
            )
        }

        print("✅ Proof 제출 성공 (nullifier: \(response.result.nullifier))")
        return response.result
    }
}
