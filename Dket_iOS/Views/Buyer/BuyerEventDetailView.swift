//
//  BuyerEventDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/6/25.
//

import SwiftUI

struct BuyerEventDetailView: View {
    private let eventId: Int64
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: BuyerEventViewModel

    init(eventId: Int64) {
        self.eventId = eventId
        _vm = StateObject(wrappedValue: BuyerEventViewModel(eventId: eventId))
    }

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .task { await vm.fetchEventDetail() }
            } else if let detail = vm.eventDetail {
                content(detail)
            } else if let error = vm.errorMessage {
                VStack {
                    Text(error)
                    Button("다시 시도") {
                        Task { await vm.fetchEventDetail() }
                    }
                }
            }
        }
        .navigationTitle("공연 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .task {
                    await vm.fetchEventDetail()
                }
    }

    @ViewBuilder
    func content(_ detail: EventDetail) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PosterView(url: detail.poster)
                    BasicInfoView(detail: detail)
                    Divider()

                    BuyerSessionPickerView(
                        selectedId: $vm.selectedSessionId,
                        sessions: vm.sessionList
                    )
                    Divider()

                    // 응모상태 및 잔여티켓
                    if let selected = vm.selectedSession {
                        let ui = vm.computeSessionUIState(session: selected,
                                                          eventStatus: detail.status,
                                                          capacity: detail.capacity)
                        if let status = ui.statusText {
                            Text("응모 상태: \(status)")
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            // 하단 플로팅 버튼
            if let selected = vm.selectedSession {
                let ui = vm.computeSessionUIState(session: selected,
                                                  eventStatus: detail.status,
                                                  capacity: detail.capacity)
                VStack {
                    Spacer()
                    if let buttonTitle = ui.buttonTitle {
                        PrimaryButton(
                            title: buttonTitle,
                            action: {
                                // 응모/결제/입장 로직 구현 예정
                                print("버튼 동작 실행")
                            },
                            isDisabled: !ui.buttonEnabled
                        )
                        .padding()
                    }
                }
            }
        }
    }
}


struct BuyerSessionPickerView: View {
    @Binding var selectedId: Int64?
    let sessions: [BuyerSessionDetail]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("공연 날짜")
                .font(.headline)

            Picker("Session", selection: $selectedId) {
                ForEach(sessions) { session in
                    Text(DateFormatter.sessionDateFormatter.string(from: session.date))
                        .tag(session.id as Int64?)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
