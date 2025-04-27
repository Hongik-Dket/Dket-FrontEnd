//
//  APIResponse.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

struct APIResponse<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T
}
