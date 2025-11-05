//
//  PassportSignUpDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/3/25.
//

import Foundation

// MARK: - Request DTO
struct PassportSignUpRequestDTO: Encodable {
    let passportNumber: String
    let gender: Gender
    let firstName: String
    let lastName: String
    let birthDate: String      // LocalDate → "YYYY-MM-DD"
    let nationality: String
    let passportExpiry: String
    
    enum Gender: String, Encodable {
        case male = "MALE"
        case female = "FEMALE"
    }
}

// MARK: - Response DTO
struct PassportSignUpResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PassportSignUpResult?
}

struct PassportSignUpResult: Decodable {
    let token: String
}

