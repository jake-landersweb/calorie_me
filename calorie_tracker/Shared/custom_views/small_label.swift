//
//  small_label.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/7/22.
//

import Foundation
import SwiftUI

struct SmallLabel: View {
    @Environment(\.colorScheme) var colorScheme
    var text: String
    var padding: CGFloat = 8
    
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundColor(.textColor(colorScheme: colorScheme).opacity(0.3))
            .padding(.leading, padding)
    }
}
