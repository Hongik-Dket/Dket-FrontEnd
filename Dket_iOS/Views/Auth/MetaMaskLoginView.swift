//
//  MetaMaskLoginView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI
import ReownWalletKit
import ReownAppKit

struct MetaMaskLoginView: View {
    @State private var goToRoleSelection = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // DKet 로고 이미지
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 112.65)
                    .padding(.top, 287)
                
                Spacer()
                
                // 메타마스크로 시작하기 버튼
                Button {
                    print("MetaMask 연결하기 버튼 클릭")
                    connectToWallet()
                } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(red: 255/255, green: 245/255, blue: 229/255))
                                .frame(width: 30, height: 30)
                                .shadow(radius: 2)
                            
                            Image("MetaMaskIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        Text("MetaMask 연결하기")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.trailing, 90)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(red: 246/255, green: 133/255, blue: 29/255))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 100)
                
            }
        }
    }
    
    func connectToWallet() {
        Task {
            do {
                await resetSession()  // optional

                let uri = try await AppKit.instance.connect(walletUniversalLink: nil)

                print("📡 WalletConnect URI 생성됨")

                let base = "https://metamask.app.link/wc?uri="
                guard let encoded = uri?.absoluteString.addingPercentEncoding(
                        withAllowedCharacters: .alphanumerics),
                      let url = URL(string: base + encoded) else {
                    print("❗ URI 인코딩 실패")
                    return
                }

                // ✅ 반드시 Main Thread에서 실행
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }

            } catch {
                print("❌ 연결 실패:", error)
            }
        }
    }
    
    func resetSession() async {
        let sessions = AppKit.instance.getSessions()
        for session in sessions {
            try? await AppKit.instance.disconnect(topic: session.topic)
        }
        print("🧹 기존 세션 정리 완료")
    }
}

struct MetaMaskLoginView_Previews: PreviewProvider {
    static var previews: some View {
        MetaMaskLoginView()
    }
}


