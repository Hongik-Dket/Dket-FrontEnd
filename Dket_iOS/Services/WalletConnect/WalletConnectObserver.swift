//
//  WalletConnectObserver.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/25/25.
//

import Foundation
import Combine
import ReownAppKit

var cancellables = Set<AnyCancellable>()

func observeWalletEvents(appState: AppState) {
    cancellables.removeAll()
    
    AppKit.instance.sessionSettlePublisher
        .sink { session in
            print("🦊 MetaMask 연결 승인됨 — 세션 정보: \(session.peer.name)")
            guard let wallet = session.accounts.first else {
                print("❌ 연결된 지갑 계정을 찾을 수 없습니다.")
                return
            }
            let address = wallet.address
            print("💬 연결된 주소: \(address)")
            
            UserWalletStore.shared.saveAddress(address)
            UserDefaults.standard.set(address, forKey: "userWalletAddress") 
            DispatchQueue.main.async {
                appState.connectedAddress = address
            }
            
            // 서버 인증 단일 로직
            Task {
                do {
                    print("📨 /api/auth/login/metamask 호출 시작")
                    let response = try await WalletAuthService.shared.loginWithMetaMask(walletAddress: address)
                    if let token = response.result?.token {
                        TokenManager.saveToken(token)
                        print("✅ 로그인 성공 — 토큰 저장 완료")
                        DispatchQueue.main.async {
                            appState.isLoggedIn = true
                        }
                    } else {
                        print("⚠️ 로그인 실패 또는 등록되지 않은 지갑")
                    }
                } catch {
                    print("❌ MetaMask 인증 처리 중 오류:", error.localizedDescription)
                }
            }
        }
        .store(in: &cancellables)
    
    AppKit.instance.sessionRejectionPublisher
        .sink { (_, reason) in
            print("❌ MetaMask 연결 거절됨: \(reason.message)")
        }
        .store(in: &cancellables)
}

/// 로그인 플로우 모드 구분용
enum WalletMode {
    case login
    case signupComplete
}
