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
                    Task {
                        await connectToWallet()
                    }
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
                
                // RoleSelectionView 연결
                NavigationLink(destination: RoleSelectionView(), isActive: $goToRoleSelection) {
                    EmptyView()
                }
            }
        }
    }
    
    func connectToWallet() async {
        print("🟢 Task 시작")
        do {
            print("🔗 connect() 호출 시작")
            let uri = try await AppKit.instance.connect(walletUniversalLink: nil)
            print("📡 생성된 URI: \(String(describing: uri))")
            
            let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~:/?#[]@!$&'()*+,;=%")
            
            if let encoded = uri?.absoluteString.addingPercentEncoding(withAllowedCharacters: allowed),
               let url = URL(string: "metamask://wc?uri=\(encoded)") {
                print("📱 최종 연결 URL: \(url)")
                
                // ✅ 메타마스크 앱 조건 없이 열기
                await UIApplication.shared.open(url)
                
                // ✅ 연결 성공 여부와 관계없이 다음 화면으로 강제 이동 (임시용)
                DispatchQueue.main.async {
                    goToRoleSelection = true
                }
            } else {
                print("❗ URI 인코딩 실패")
            }
        } catch {
            print("❌ 연결 실패: \(error.localizedDescription)")
        }
    }
}

struct MetaMaskLoginView_Previews: PreviewProvider {
    static var previews: some View {
        MetaMaskLoginView()
    }
}


