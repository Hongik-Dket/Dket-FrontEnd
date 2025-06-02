//
//  WalletConnectManager.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/21/25.
//

import Foundation
import ReownAppKit
import WalletConnectSigner  // 필수
import WalletConnectNetworking
import WalletConnectRelay

final class WalletConnectManager {
    static let shared = WalletConnectManager()
    private init() {}
    
    func configure() {
        let projectId = "549a0d9180df684b3f0a6038d4542092"
        
        // 0. Networking 명시적으로 먼저 초기화
        let groupIdentifier = "group.com.a.Dket-iOS"

        Networking.configure(
            relayHost: "relay.walletconnect.com",
            groupIdentifier: groupIdentifier,
            projectId: projectId,
            socketFactory: DefaultSocketFactory()
        )
        
        // 1. redirect 설정
        let redirect = try! AppMetadata.Redirect(
            native: "dket://",
            universal: nil
        )
        
        // 2. metadata 구성
        let metadata = AppMetadata(
            name: "Dket",
            description: "블록체인 기반 티켓 DApp",
            url: "https://dket.app",
            icons: ["https://dket.app/icon.png"],
            redirect: redirect
        )
        
        // 3. 커스텀 CryptoProvider (서명 알고리즘 구현)
        let crypto = MyCryptoProvider()
        
        // 4. AppKit 설정
        AppKit.configure(
            projectId: projectId,
            metadata: metadata,
            crypto: crypto,
            authRequestParams: nil,
            onError: { error in
                print("❌ AppKit 설정 실패: \(error)")
            }
        )
        
        print("✅ AppKit 설정 완료")
    }
}
