//
//  SecondStepView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct SecondStepView: View {
    @Binding var performanceStart: Date
    @Binding var performanceEnd: Date
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var priceKrw: String
    @Binding var capacity: String
    @Binding var enrollStartDate: Date
    @Binding var enrollStartTime: Date
    @Binding var enrollEndDate: Date
    @Binding var enrollEndTime: Date
    
    let now = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 35) {
                HStack {
                    Text("공연기간")
                        .frame(width: 80, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                    
                    DatePicker("", selection: $performanceStart, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    Text("~")
                    DatePicker("", selection: $performanceEnd, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                HStack {
                    Text("공연시간")
                        .frame(width: 80, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                    
                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                    Text("~")
                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                }
                
                HStack {
                    Text("가격")
                        .frame(width: 80, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                    
                    TextField("0", text: $priceKrw)
                        .keyboardType(.numberPad)
                        .textFieldStyle(UnderlineTextFieldStyle())
                    Text("원")
                        .font(.system(size: 16))
                }
                
                HStack {
                    Text("관람인원")
                        .frame(width: 80, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                    
                    TextField("0", text: $capacity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(UnderlineTextFieldStyle())
                    Text("명")
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Text("응모시작")
                            .frame(width: 80, alignment: .leading)
                            .font(.system(size: 16, weight: .bold))
                        DatePicker("", selection: $enrollStartDate, in: now..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                        
                        DatePicker("", selection: $enrollStartTime, in: now..., displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                    }
                    
                    HStack(spacing: 12) {
                        Text("응모마감")
                            .frame(width: 80, alignment: .leading)
                            .font(.system(size: 16, weight: .bold))
                        DatePicker("", selection: $enrollEndDate, in: now..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                        
                        DatePicker("", selection: $enrollEndTime, in: now..., displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .hideKeyboardOnTap()
        }
    }
}

struct UnderlineTextField: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.vertical, 8)
            .overlay(Rectangle().frame(height: 1).padding(.top, 36), alignment: .bottom)
    }
}

struct LabeledRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .frame(width: 80, alignment: .leading)
                .font(.system(size: 16, weight: .bold))
            content()
        }
        .padding(.vertical, 4)
    }
}
