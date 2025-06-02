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
            print("메타마스크 연결 성공. 세션 정보: \(session)")
            DispatchQueue.main.async {
                appState.isLoggedIn = true
            }
        }
        .store(in: &cancellables)
    
    AppKit.instance.sessionRejectionPublisher
        .sink { (proposal, reason) in
            print("❌ 메타마스크 연결 거절됨: \(reason.message)")
        }
        .store(in: &cancellables)
}
