//
//  OrganizerOfflineVerifyView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/18/25.
//

import SwiftUI

struct OrganizerOfflineVerifyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let ticketId: Int64
    private let service = TicketService()
    
    /// ✅ 입장 완료 후 상위에서 QRScanner를 다시 열게 하는 클로저
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                // 닫기 버튼
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(20)
                    }
                }
                .padding(.trailing, 16)

                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .foregroundColor(Color.dketBlue)

                    Text("""
                    이 티켓은 오프라인 본인확인이 필요합니다.

                    영지식 증명(ZKP) 인증이 불가하거나 외국인 사용자로 확인되었습니다.

                    관객의 신분증(국내) 또는 여권(외국인)을 직접 확인한 뒤,
                    아래의 [입장 완료하기] 버튼을 눌러 입장을 처리하세요.
                    """)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)

                Spacer()

                Button {
                    Task { await enterTicket() }
                } label: {
                    if isProcessing {
                        ProgressView()
                            .frame(maxWidth: 360, maxHeight: 48)
                            .background(Color.dketBlue.opacity(0.6))
                            .cornerRadius(24)
                    } else {
                        Text("입장 완료하기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 360, maxHeight: 48)
                            .background(Color.dketBlue)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                    }
                }
                .disabled(isProcessing)
                .padding(.bottom, 60)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("입장 처리 결과"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인")) {
                    if alertMessage.contains("성공") {
                        // ✅ Alert 닫히면 QR 스캐너로 복귀
                        dismiss()
                        onFinish()
                    }
                }
            )
        }
    }

    // MARK: - API 호출
    private func enterTicket() async {
        await MainActor.run { isProcessing = true }
        do {
            // ✅ PATCH 요청으로 입장 완료
            let response = try await APIClient.shared.patch(
                .organizerEnterTicket(ticketId: ticketId),
                as: APIResponseWithoutResult.self
            )
            await MainActor.run {
                isProcessing = false
                alertMessage = response.message
                showAlert = true
            }
        } catch {
            await MainActor.run {
                isProcessing = false
                alertMessage = "서버 요청 중 오류가 발생했습니다."
                showAlert = true
            }
        }
    }
}
