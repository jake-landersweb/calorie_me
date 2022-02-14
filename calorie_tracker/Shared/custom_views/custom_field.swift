//
//  custom_field.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/5/22.
//

import Foundation
import SwiftUI

/*
 For showing a more stylized text input field. No special code
 */
struct CustomField: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var field: String
    var isFocused: Bool
    let label: String
    let icon: String
    var obscure = false
    var color1 = Color.blue
    var color2 = Color.blue.opacity(0.5)

    var body: some View {
        HStack(spacing: 16) {
            // show highlighted icon when field is actively being edited
            if isFocused {
                LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .top, endPoint: .bottom)
                    .mask(Image(systemName: icon))
                    .frame(width: 32)
            } else {
                Image(systemName: icon)
                    .frame(width: 32)
            }
            // show obscure text field when specified
            if obscure {
                SecureField(label, text: $field)
                    .textFieldStyle(PlainTextFieldStyle())
            } else {
                TextField(label, text: $field)
                    .textFieldStyle(PlainTextFieldStyle())
            }
        }
        .accentColor(color2)    // text line color
        .padding(16)
        .frame(height: 50)
        .background(Color.cellColor(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
