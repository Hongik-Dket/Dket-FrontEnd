//
//  AppState.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import Foundation
import SwiftUI

final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false      // 로그인 여부
    @Published var userRole: UserRole? = nil     // 사용자 역할 (buyer / host)
    @Published var isConnected: Bool = false     // Wallet 연결 여부
    @Published var connectedAddress: String? = nil  // 연결된 지갑 주소
    
    // Wallet 동작 모드
    enum WalletMode {
        case idle              // 아무 동작 없음
        case login             // 기존회원 로그인
        case signupComplete     // 회원가입 후 연결
    }
    @Published var walletMode: WalletMode = .idle

    enum UserRole {
        case host
        case buyer
    }
}
