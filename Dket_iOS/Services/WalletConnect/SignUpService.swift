//
//  SignUpService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/3/25.
//

import Foundation

// MARK: - 회원가입 서비스
final class SignUpService {
    static let shared = SignUpService()
    private init() {}
    
    /// 외국인 여권 기반 회원가입
    func signUpForeign(_ request: PassportSignUpRequestDTO) async throws -> PassportSignUpResponseDTO {
        print("외국인 회원가입 요청 시작")
        return try await APIClient.shared.post(
            .foreignSignUp,
            body: request,
            as: PassportSignUpResponseDTO.self
        )
    }
    
    /// 한국인 회원가입 (API 완성 후 구현 예정)
    func signUpKorean(/* request: KoreanSignUpRequestDTO */) async throws {
        // TODO: 추후 한국인 회원가입 API 완성 후 구현
        print("한국인 회원가입 요청 시작.")
    }
}
 
