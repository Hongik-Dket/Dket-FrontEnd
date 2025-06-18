//
//  NetworkError.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case status(Int)
    case decoding(Error)
    case unknown
    case emptyResult
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL 입니다."
        case .status(let code):
            return "서버 응답 오류 (\(code))"
        case .decoding(let err):
            return "데이터 해석 실패: \(err.localizedDescription)"
        case .unknown:
            return "알 수 없는 네트워크 오류가 발생했습니다."
        case .emptyResult:
            return "응답 데이터가 비어 있습니다."
        }
    }
}

