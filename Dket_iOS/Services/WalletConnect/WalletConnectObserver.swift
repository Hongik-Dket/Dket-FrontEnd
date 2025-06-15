//
//  WalletConnectObserver.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/25/25.
//

import Foundation
import Combine
import ReownAppKit

// 전역 변수
var cancellables = Set<AnyCancellable>()

// 연결 이벤트 관찰 함수
func observeWalletEvents(appState: AppState) {
    AppKit.instance.sessionSettlePublisher
        .sink { session in
            print("메타마스크 연결 성공. 세션 정보: \(session.peer.name)")
            
            // 1. 연결된 지갑 주소 가져오기
            if let wallet = session.accounts.first {
                print("지갑 주소: \(wallet.address)")
                
                UserWalletStore.shared.saveAddress(wallet.address)
                
                DispatchQueue.main.async {
                        appState.connectedAddress = wallet.address  
                    }
                
                Task {
                    do {
                        // 2. 서버에 지갑 주소 전송
                        try await WalletAuthService().completeLogin(with: wallet.address)
                        DispatchQueue.main.async {
                            appState.isLoggedIn = true
                        }
                    } catch {
                        print("❌ 서버에 지갑주소 전송 실패: \(error)")
                    }
                }
            }
        }
        .store(in: &cancellables)
    
    AppKit.instance.sessionRejectionPublisher
        .sink { (_, reason) in
            print("❌ 메타마스크 연결 거절됨: \(reason.message)")
        }
        .store(in: &cancellables)
}
