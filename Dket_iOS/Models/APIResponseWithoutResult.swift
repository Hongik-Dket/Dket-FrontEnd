//
//  APIResponseWithoutResult.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

struct APIResponseWithoutResult: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
}
