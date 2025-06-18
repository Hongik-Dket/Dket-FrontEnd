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
    
    var body: some View {
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
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .hideKeyboardOnTap()
        }
    }
}

struct FirstStepView_Previews: PreviewProvider {
    static var previews: some View {
        FirstStepView(
            title: .constant(""),
            ageFilter: .constant(nil),
            location: .constant(""),
            description: .constant("")
        )
    }
}
