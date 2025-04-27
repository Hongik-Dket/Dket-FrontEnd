//
//  NetworkError.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

enum NetworkError: Error {
    case invalidURL
    case status(Int)
    case decoding(Error)
    case unknown
}
