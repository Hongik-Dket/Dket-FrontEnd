//
//  ApplyResponseDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/14/25.
//

import Foundation

struct ApplyResponseDTO: Codable {
    let applyId: Int64
    let sessionId: Int64
    let appliedAt: Date
}
