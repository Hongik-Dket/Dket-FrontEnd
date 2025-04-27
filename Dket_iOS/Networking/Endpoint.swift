//
//  Endpoint.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

enum Endpoint {
    case organizerHome
    case organizerToday
    case organizerClosed
    case organizerAll
    
    var path: String {
        switch self {
        case .organizerHome:   return "/api/organizer/home"
        case .organizerToday:  return "/api/organizer/home/today"
        case .organizerClosed: return "/api/organizer/home/closed"
        case .organizerAll:    return "/api/organizer/home/all"
        }
    }
}
