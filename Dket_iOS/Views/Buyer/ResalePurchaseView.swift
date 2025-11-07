//
//  ResaleTicketView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResalePurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ResalePurchaseViewModel

    init(resaleId: Int64) {
        _vm = StateObject(wrappedValue: ResalePurchaseViewModel(resaleId: resaleId))
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            if vm.isLoading {
                ProgressView("불러오는 중...")
            } else if let info = vm.ticketInfo {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - 티켓 정보 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("티켓 정보")
                                .font(.headline)
                                .bold()

                            HStack(alignment: .top, spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    InfoTextRow(label: "공연명", value: info.concertTitle)
                                    InfoTextRow(label: "공연 장소", value: info.location)
                                    InfoTextRow(label: "공연 일시", value: "\(info.date) \(info.startTime)")
                                    InfoTextRow(label: "좌석 번호", value: info.seatCode)
                                }
                                Spacer()
                                AsyncImage(url: info.photoCardUrl) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                                .clipped()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                        }

                        // MARK: - 구매 정보 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("구매 정보")
                                .font(.headline)
                                .bold()

                            VStack(alignment: .leading, spacing: 8) {
                                InfoTextRow(label: "티켓 정가", value: info.originalPrice.formattedKrw)
                                InfoTextRow(label: "구매가", value: info.priceKrw.formattedKrw)
                                InfoTextRow(label: "결제 금액", value: info.priceWei.formattedEth, valueColor: .dketBlue)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                        }

                        // MARK: - 구매 규정 섹션
                        VStack(alignment: .leading, spacing: 8) {
                            Text("구매 규정")
                                .font(.headline)
                                .bold()

                            VStack(alignment: .leading, spacing: 6) {
                                RuleText("결제는 요청 후 수분 내에 처리됩니다.")
                                RuleText("구매 요청 후 취소는 불가능합니다.")
                                RuleText("거래된 티켓은 MY 티켓 및 MY 포토카드에 자동으로 등록됩니다.")
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                        }

                        Spacer(minLength: 32)

                        // MARK: - 구매 버튼
                        Button {
                            Task { await vm.purchaseTicket() }
                        } label: {
                            Text("구매하기")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 54)
                                .background(Color.dketBlue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            } else if let error = vm.errorMessage {
                // MARK: - 커스텀 알림창
                CustomAlertView(message: error) {
                    dismiss()
                }
            } else {
                Text("티켓 정보를 불러올 수 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationTitle("리세일 티켓 구매")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.reserveTicket()
        }
        .onDisappear {
            Task.detached {
                await vm.cancelReservation()
            }
        }
    }
}

// MARK: - InfoTextRow
private struct InfoTextRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundColor(.white)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
            Spacer()
        }
    }
}

// MARK: - 구매 규정 텍스트 스타일
private struct RuleText: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundColor(.gray)
            Text(text)
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

// MARK: - Custom Alert
struct CustomAlertView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image("DketEmpty")
                .resizable()
                .frame(width: 80, height: 80)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            Button("돌아가기") {
                onDismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.dketBlue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: 280)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 6)
    }
}

// MARK: - Formatting
extension Int {
    var formattedKrw: String {
        NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal) + " 원"
    }
}

extension Int64 {
    var formattedEth: String {
        let eth = Double(self) / 1_000_000_000_000_000_000
        return String(format: "%.15f ETH", eth)
    }
}

