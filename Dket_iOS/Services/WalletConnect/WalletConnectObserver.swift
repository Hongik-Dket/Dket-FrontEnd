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

/// MetaMask 로그인 및 회원가입 완료 연결을 공통 처리하는 옵저버
///
/// - Parameters:
///   - appState: 전역 로그인 상태 및 연결 주소를 관리하는 ObservableObject
///   - mode: .login (기존회원 로그인) 또는 .signupComplete (회원가입 후 지갑 연결)
func observeWalletEvents(appState: AppState, mode: WalletMode) {
    cancellables.removeAll()
    AppKit.instance.sessionSettlePublisher
        .sink { session in
            print("🦊 MetaMask 연결 승인됨 — 세션 정보: \(session.peer.name)")

            // 1️⃣ 연결된 지갑 주소 추출
            guard let wallet = session.accounts.first else {
                print("❌ 연결된 지갑 계정을 찾을 수 없습니다.")
                return
            }
            let address = wallet.address
            print("💬 연결된 주소: \(address)")

            // 2️⃣ 로컬에 저장 (UserDefaults 등)
            UserWalletStore.shared.saveAddress(address)
            DispatchQueue.main.async {
                appState.connectedAddress = address
            }

            // 3️⃣ 서버와 인증 로직 처리
            Task {
                do {
                    switch mode {
                    case .signupComplete:
                        print("📨 [회원가입 후 연결 모드] /api/user/signup/metamask/complete 호출 시작")
                        let response = try await WalletAuthService.shared.completeMetaMaskSignUp(walletAddress: address)

                        if response.isSuccess {
                            print("✅ MetaMask 지갑 등록 완료")
                            // result 없음 → token 저장 생략
                            DispatchQueue.main.async {
                                appState.isLoggedIn = true
                            }
                        } else if response.code == "USER_4009" {
                            // 이미 등록된 지갑이라면 → 로그인으로 대체
                            print("⚠️ 이미 등록된 지갑 주소 → 로그인 API로 전환")
                            let loginResponse = try await WalletAuthService.shared.loginWithMetaMask(walletAddress: address)
                            if let token = loginResponse.result?.token {
                                TokenManager.saveToken(token)
                                print("✅ 로그인 성공 (이미 등록된 지갑)")
                                DispatchQueue.main.async { appState.isLoggedIn = true }
                            } else {
                                print("⚠️ 로그인 응답에 토큰이 없습니다.")
                            }
                        } else {
                            print("❌ MetaMask 등록 실패: \(response.message)")
                        }

                    case .login:
                        print("📨 [로그인 모드] /api/auth/login/metamask 호출 시작")
                        let response = try await WalletAuthService.shared.loginWithMetaMask(walletAddress: address)

                        if let token = response.result?.token {
                            TokenManager.saveToken(token)
                            print("✅ 로그인 성공 — 토큰 저장 완료")
                            DispatchQueue.main.async {
                                appState.isLoggedIn = true
                            }
                        } else if response.code == "USER_4001" {
                            print("⚠️ 등록되지 않은 지갑입니다. 회원가입 필요")
                            DispatchQueue.main.async {
                                appState.isLoggedIn = false
                            }
                        } else {
                            print("⚠️ 로그인 실패: \(response.message)")
                        }
                    }
                } catch {
                    print("❌ MetaMask 인증 처리 중 오류 발생:", error.localizedDescription)
                }
            }
        }
        .store(in: &cancellables)

    // 4️⃣ 연결 거절 이벤트
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
