//
//  AppState.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userRole: UserRole? = nil  // 주최자, 구매자 구분
    @Published var isConnected: Bool = false
    @Published var connectedAddress: String? = nil

    enum UserRole {
        case host
        case buyer
    }
}
