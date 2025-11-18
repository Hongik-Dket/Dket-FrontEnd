//
//  PassportInfoDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/16/25.
//

struct PassportInfoDTO: Codable {
    let userId: Int64
    let passportNumber: String
    let gender: String       // "MALE" or "FEMALE"
    let firstName: String
    let lastName: String
    let birth: String        // "2025-10-31"
    let nationality: String
    let passportExpiry: String
}
