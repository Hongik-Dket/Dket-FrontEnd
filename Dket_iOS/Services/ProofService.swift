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

extension ProofService {
    // ① 소유 증명용 챌린지 요청
    func requestOwnChallenge(ticketId: Int64) async throws -> OwnershipChallengeDTO {
        let response: APIResponse<OwnershipChallengeDTO> = try await APIClient.shared.get(
            .proofsOwnChallenge(ticketId: ticketId),
            as: APIResponse<OwnershipChallengeDTO>.self
        )

        guard response.isSuccess else {
            throw NSError(domain: "ProofService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: response.message])
        }

        return response.result
    }

    // ② 서명 후 증명 전송
    func submitOwnProof(
        sessionId: Int64?,
        challengeId: String,
        signature: String,
        publicKey: String
    ) async throws -> OwnershipProofResponseDTO {
        let dto = OwnershipProofRequestDTO(
            sessionId: sessionId,
            challengeId: challengeId,
            signature: signature,
            publicKey: publicKey
        )

        print("📨 OwnProof 전송 JSON: \(dto)")

        let response: APIResponse<OwnershipProofResponseDTO> = try await APIClient.shared.post(
            .proofsOwn,
            body: dto,
            as: APIResponse<OwnershipProofResponseDTO>.self
        )

        guard response.isSuccess else {
            throw NSError(domain: "ProofService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: response.message])
        }

        print("✅ 소유 증명 성공 — QR: \(response.result.qrCodeUrl ?? "none")")
        return response.result
    }
}

extension ProofService {
    func fetchPassportInfo() async throws -> PassportInfoDTO {
        let response: APIResponse<PassportInfoDTO> = try await APIClient.shared.get(
            .userPassportInfo,
            as: APIResponse<PassportInfoDTO>.self
        )

        guard response.isSuccess else {
            throw NSError(
                domain: "ProofService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: response.message]
            )
        }

        print("✅ 여권 정보 조회 성공: \(response.result)")
        return response.result
    }
}
