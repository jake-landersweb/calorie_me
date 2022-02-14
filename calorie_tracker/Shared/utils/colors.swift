//
//  colors.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/5/22.
//

import Foundation
import SwiftUI

extension Color {
    public static func textColor(colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? Color.black : Color.white
    }
    public static func backgroundColor(colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? Color(red: 240/255, green: 240/255, blue: 250/255) : Color(red: 30/255, green: 30/255, blue: 33/255)
    }
    public static func cellColor(colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? Color(red: 243/255, green: 243/255, blue: 244/255) : Color(red: 48/255, green: 48/255, blue: 50/255)
    }
    public static let breakfast = Color(red: 235/255, green: 190/255, blue: 113/255)
    public static let lunch = Color(red: 235/255, green: 113/255, blue: 123/255)
    public static let dinner = Color(red: 113/255, green: 141/255, blue: 235/255)
    public static let water = Color(red: 113/255, green: 196/255, blue: 235/255)
}
