//
//  ResaleTicketView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleTicketView: View {
    @StateObject private var viewModel = ResaleTicketViewModel()
    @Environment(\.dismiss) var dismiss

    let ticketId: Int64

    var body: some View {
        ScrollView {
            if let ticket = viewModel.resalePurchase {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - 티켓 정보
                    GroupBox(label: Text("티켓 정보").font(.headline)) {
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(label: "공연명", value: ticket.concertTitle)
                                InfoRow(label: "공연 장소", value: ticket.location)
                                InfoRow(label: "공연 일시", value: "\(ticket.date) \(ticket.startTime)")
                                InfoRow(label: "좌석 번호", value: ticket.seatNumber)
                            }
                            Spacer()
                            if let url = ticket.photoCardUrl {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 90, height: 120)
                                        .clipped()
                                        .cornerRadius(8)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 90, height: 120)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // MARK: - 구매 정보
                    GroupBox(label: Text("구매 정보").font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "티켓 정가", value: ticket.originalPrice.formattedKrw)
                            InfoRow(label: "구매가", value: ticket.resalePrice.formattedKrw)
                            InfoRow(label: "결제 금액", value: ticket.priceWei.formattedEth, valueColor: .blue)
                        }
                        .padding(.vertical, 4)
                    }

                    // MARK: - 구매 규정
                    GroupBox(label: Text("구매 규정").font(.headline)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("• 결제는 요청 후 수분 내에 처리됩니다.")
                            Text("• 구매 요청 후 취소는 불가능합니다.")
                            Text("• 거래된 티켓은 MY 티켓 및 MY 포토카드에 자동으로 등록됩니다.")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView("티켓 정보를 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                Text("티켓 정보를 불러올 수 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationTitle("구매")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.purchase(ticketId: ticketId)
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - InfoRow Subview
private struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
            Spacer()
        }
    }
}

extension Int {
    var formattedKrw: String {
        NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal) + "원"
    }
}

extension Int64 {
    var formattedEth: String {
        let eth = Double(self) / 1_000_000_000_000_000_000
        return String(format: "%.4f ETH", eth)
    }
}

