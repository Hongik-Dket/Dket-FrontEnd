//
//  TicketDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/14/25.
//

import SwiftUI

struct TicketDetailView: View {
    let ticket: TicketDetail
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // 상단 닫기 버튼
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(20)
                    }
                }
                .padding(.trailing, 16)

                // 공연 제목
                Text(ticket.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
                    .padding(.top, 60) // 노치와 겹치지 않게

                // 정보 영역
                VStack(alignment: .leading, spacing: 8) {
                    TicketInfoRow(label: "공연 일시", value: ticket.dateFormatted)
                    TicketInfoRow(label: "예매자 명", value: ticket.userName)
                    TicketInfoRow(label: "생년월일", value: ticket.userBirth)
                    TicketInfoRow(label: "티켓 번호", value: ticket.ticketNumber)
                    TicketInfoRow(label: "좌석 번호", value: ticket.seat)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 50)
                .padding(.top, 20)

                // QR 코드
                if let qr = ticket.qrCodeUrl, let url = URL(string: qr) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 260, height: 260)
                            .padding(.top, 12)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 260, height: 260)
                            .padding(.top, 12)
                    }
                }

                Spacer()

                // 하단 버튼
                VStack(spacing: 12) {
                    Button {
                        // 포토카드 보기 액션
                    } label: {
                        Text("포토카드 보기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 360, maxHeight: 48)
                            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                            .cornerRadius(24)
                            .shadow(radius: 4)
                    }

                    Button {
                        // NFT 티켓 보기 액션
                    } label: {
                        Text("NFT 티켓 보러가기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 360, maxHeight: 48)
                            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                            .cornerRadius(24)
                            .shadow(radius: 4)
                    }
                }
                .padding(.bottom, 50) // 아래 간격 충분히 확보
            }
        }
    }
}

struct TicketInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 80, alignment: .leading) // ← 고정된 너비로 정렬 기준 맞춤

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.leading)
        }
    }
}

struct TicketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TicketDetailView(ticket: TicketDetail(
            id: 1,
            title: "공연 이름",
            dateFormatted: "2025.06.30", // 백엔드에서 LocalDateTime을 받을 경우 형식화한 값
            userName: "여희주",
            userBirth: "2003.02.25",
            ticketNumber: "T152670849345203",
            seat: "39",
            qrCodeUrl: "https://api.qrserver.com/v1/create-qr-code/?data=DKET_SAMPLE"
        ))
    }
}
