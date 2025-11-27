//
//  BuyerProofQRView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/16/25.
//
import SwiftUI

import SwiftUI

struct BuyerProofQRView: View {
    let ticket: BuyerTicketDetail
    let qrCodeUrl: String
    let identityType: String
    @Environment(\.dismiss) private var dismiss

    @State private var passportInfo: PassportInfoDTO? = nil
    @State private var showPassportSheet = false
    @State private var showErrorSheet = false
    @State private var isLoadingPassport = false

    var isForeign: Bool { identityType.uppercased() == "PASSPORT" }
    
    // 1. 캡처 감지 상태 추가
    @State private var isCaptured = false

    var body: some View {
        // 2. 전체를 보안 뷰로 감싸기 (실제 캡처 방지)
        ScreenshotPreventView {
            ZStack {
                // 배경 이미지
                Image("TicketDetail")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    // 상단 제목
                    Button(action: { dismiss() }) {
                        Text(ticket.concertTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.dketBlue)
                            .underline()
                            .padding(.top, 120)
                    }

                    // 기본 정보
                    VStack(alignment: .leading, spacing: 10) {
                        TicketInfoRow(label: "공연 일시", value: ticket.startDateFormatted)
                        TicketInfoRow(label: "예매자 명", value: ticket.buyerName)
                        TicketInfoRow(label: "생년월일", value: ticket.birthDateFormatted)
                        TicketInfoRow(label: "티켓 번호", value: ticket.ticketNumber)
                        TicketInfoRow(label: "좌석 번호", value: ticket.seatNumber)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 50)
                    .padding(.top, 20)

                    // QR 코드 표시
                    if let url = URL(string: qrCodeUrl) {
                        VStack(spacing: 16) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 260, height: 260)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                    .padding(.top, 12)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 260, height: 260)
                                    .padding(.top, 12)
                            }

                            Text("입장 시 아래 QR 코드를 제시해주세요.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("QR 코드가 없습니다.")
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    }

                    Spacer()

                    // 외국인만 "여권 정보 조회" 버튼
                    if isForeign {
                        Button {
                            Task { await fetchPassportInfo() }
                        } label: {
                            if isLoadingPassport {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.dketBlue.opacity(0.5))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 40)
                            } else {
                                Text("여권 정보 조회")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.dketBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                } // End of VStack

                // 닫기 버튼
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                
                // 3. 캡처 감지 시 사용자 화면에 띄울 경고 UI (선택 사항)
                if isCaptured {
                    ZStack {
                        Color.black.opacity(0.95).ignoresSafeArea()
                        VStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            Text("보안 화면")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Text("QR 코드는 캡처할 수 없습니다.")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.body)
                        }
                    }
                    .transition(.opacity)
                    .zIndex(999) // 제일 위에 뜨도록
                }
                
            } // End of ZStack
        } // End of ScreenshotPreventView
        
        // 4. 캡처 감지 옵저버 등록
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation { isCaptured = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { isCaptured = false }
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIScreen.capturedDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation {
                    isCaptured = UIScreen.main.isCaptured
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        }

        // 여권정보 표시 모달
        .fullScreenCover(isPresented: $showPassportSheet) {
            if let info = passportInfo {
                PassportInfoView(info: info)
            } else {
                PassportErrorView()
            }
        }

        // 실패 시 에러 모달
        .sheet(isPresented: $showErrorSheet) {
            PassportErrorView()
        }
    }

    // MARK: - 여권 조회
    private func fetchPassportInfo() async {
        await MainActor.run { isLoadingPassport = true }
        do {
            let info = try await ProofService.shared.fetchPassportInfo()
            await MainActor.run {
                passportInfo = info
                isLoadingPassport = false
                showPassportSheet = true
            }
        } catch {
            print("❌ 여권 조회 실패: \(error.localizedDescription)")
            await MainActor.run {
                isLoadingPassport = false
                passportInfo = nil
                showErrorSheet = true
            }
        }
    }
}
