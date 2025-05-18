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
    @Binding var price: String
    @Binding var capacity: String
    @Binding var enrollStart: Date
    @Binding var enrollEnd: Date

    var body: some View {
        // 1) ScrollView로 감싸서 전체 화면을 터치 영역으로 확보
        ScrollView {
            VStack(alignment: .leading, spacing: 35) {
                // 공연기간
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

                // 공연시간
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

                // 가격
                HStack {
                    Text("가격")
                        .frame(width: 80, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))

                    TextField("0", text: $price)
                        .keyboardType(.numberPad)
                        .textFieldStyle(UnderlineTextFieldStyle())
                    Text("원")
                        .font(.system(size: 16))
                }

                // 관람인원
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

                // 응모기간
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Text("응모기간")
                            .frame(width: 80, alignment: .leading)
                            .font(.system(size: 16, weight: .bold))

                        HStack(spacing: 6) {
                            DatePicker("", selection: $enrollStart, displayedComponents: .date)
                                .datePickerStyle(.compact)
                            DatePicker("", selection: $enrollStart, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                        }
                    }

                    HStack(spacing: 12) {
                        Text("") // 정렬용 빈칸
                            .frame(width: 80)

                        HStack(spacing: 6) {
                            DatePicker("", selection: $enrollEnd, displayedComponents: .date)
                                .datePickerStyle(.compact)
                            DatePicker("", selection: $enrollEnd, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20) 
            .hideKeyboardOnTap()
        }
    }
}

/// 간단한 언더라인 텍스트필드 래퍼
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
