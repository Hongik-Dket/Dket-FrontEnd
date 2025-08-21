//
//  FirstStepView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct FirstStepView: View {
    @Binding var title: String
    @Binding var ageFilter: String?
    @Binding var location: String
    @Binding var description: String
    @Binding var isResaleAllowed: Bool?
    
    @State private var showResaleInfo = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 35) {
                    HStack {
                        Text("공연명")
                            .frame(width: 80, alignment: .leading)
                            .font(.system(size: 16, weight: .bold))
                        TextField("공연명 입력", text: $title)
                            .textFieldStyle(UnderlineTextFieldStyle())
                    }
                    
                    HStack {
                        Text("관람연령")
                            .frame(width: 80, alignment: .leading)
                            .font(.system(size: 16, weight: .bold))
                        HStack(spacing: 12) {
                            AgeOptionButton(title: "전체",     selected: $ageFilter, value: "전체")
                            AgeOptionButton(title: "12세 이상", selected: $ageFilter, value: "12세 이상")
                            AgeOptionButton(title: "15세 이상", selected: $ageFilter, value: "15세 이상")
                            AgeOptionButton(title: "18세 이상", selected: $ageFilter, value: "18세 이상")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Text("공연장소")
                            .frame(width: 80, alignment: .leading)
                            .font(.system(size: 16, weight: .bold))
                        TextField("공연장소 입력", text: $location)
                            .textFieldStyle(UnderlineTextFieldStyle(icon: "mappin.and.ellipse"))
                    }
                    
                    HStack(alignment: .top) {
                        Text("설명")
                            .frame(width: 80, alignment: .leading)
                            .font(.system(size: 16, weight: .bold))
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                    HStack(alignment: .center, spacing: 12) {
                        HStack(spacing: 4) {
                            Text("리세일")
                                .frame(width: 80, alignment: .leading)
                                .font(.system(size: 16, weight: .bold))
                            
                            Button(action: {
                                showResaleInfo = true
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            ResaleOptionButton(title: "허용", selected: .constant(isResaleAllowed == true), action: {
                                isResaleAllowed = true
                            })
                            ResaleOptionButton(title: "미허용", selected: .constant(isResaleAllowed == false), action: {
                                isResaleAllowed = false
                            })
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .hideKeyboardOnTap()
            }
            
            // 팝업
            if showResaleInfo {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showResaleInfo = false }
                
                ResaleInfoPopup {
                    showResaleInfo = false
                }
                .frame(maxWidth: 300)
                .transition(.scale)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showResaleInfo)
    }
}

struct ResaleOptionButton: View {
    let title: String
    let selected: Binding<Bool>
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selected.wrappedValue ? .black : .gray.opacity(0.4))
                .frame(width: 60, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(selected.wrappedValue ? Color.black : .gray.opacity(0.4), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selected.wrappedValue ? Color.white : Color.white)
                        )
                )
        }
    }
}
