//
//  calorie_item.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/5/22.
//

import Foundation
import SwiftUI

// valid cateories
enum Category: String, Codable, Equatable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case water = "Water"
    case drink = "Drink"
}

/*
 Item that holds all info for a food record
 */
struct CalorieItem: Codable {
    var id: String
    var title: String
    var description: String
    var category: Category
    var date: String
    var calories: Int
    
    // for creating a fileitem otherplaces, generates id and date
    init(title: String, description: String, category: Category, calories: Int) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.category = category
        self.date = Date.now.ISO8601Format()
        self.calories = calories
    }
    
    // get date representation of stored string date
    func getDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self.date)!
    }
    
    // set string date with date
    mutating func setDate(date: Date) {
        self.date = date.ISO8601Format()
    }
    
    // update the valid fields when sent a new CalorieItem
    mutating func update(item: CalorieItem) {
        self.title = item.title
        self.description = item.description
        self.category = item.category
        self.date = item.date
        self.calories = item.calories
    }
    
    // gets date in a human readable format
    func getFormattedDate() -> String {
        let date = getDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm E, d MMM"
        return dateFormatter.string(from: date)
    }
    
    // get correct color based on category
    func getColor(colorScheme: ColorScheme) -> Color {
        return CalorieItem.getColor(colorScheme: colorScheme, category: category)
    }
    
    static func getColor(colorScheme: ColorScheme, category: Category) -> Color {
        switch (category) {
            case .breakfast:
                return Color.breakfast
            case .lunch:
                return Color.lunch
            case .dinner:
                return Color.dinner
            case .water:
                return Color.water
            default:
            return Color.cellColor(colorScheme: colorScheme).opacity(0.3)
        }
    }
    
    // get correct icon based on category
    func getIcon() -> String {
        return CalorieItem.getIcon(category: category)
    }
    
    static func getIcon(category: Category) -> String {
        switch (category) {
            case .breakfast:
                return "sun.min"
            case .lunch:
                return "fork.knife"
            case .dinner:
                return "fork.knife"
            case .water:
                return "drop"
            case .snack:
                return "face.smiling"
            case .drink:
                return "cup.and.saucer"
        }
    }
    
    // get correct text color based on category
    func getTextColor(colorScheme: ColorScheme) -> Color {
        return CalorieItem.getTextColor(colorScheme: colorScheme, category: category)
    }
    
    static func getTextColor(colorScheme: ColorScheme, category: Category) -> Color {
        switch (category) {
            case .breakfast:
                return Color.white
            case .lunch:
                return Color.white
            case .dinner:
                return Color.white
            case .water:
                return Color.white
            default:
                return Color.textColor(colorScheme: colorScheme)
        }
    }
}
