//
//  TicketNumberEntryView.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/4/25.
//

import SwiftUI

struct TicketNumberEntryView: View {
    @State private var ticketNo = ""
    var onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("티켓 번호 입력") {
                    TextField("예: 1234567890", text: $ticketNo)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("티켓 번호로 확인")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("확인") {
                        onSubmit(ticketNo)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { onSubmit("") }
                }
            }
        }
    }
}
