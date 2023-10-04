//
//  calendar_cell.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/7/22.
//

import Foundation
import SwiftUI

struct CalendarCell: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.calendar) var calendar
    @EnvironmentObject var dmodel: DataModel
    
    var date: Date
    
    @Binding var selectedDate: Date
    
    var body: some View {
        Group {
            NavigationLink(destination: Index(date: date)) {
                home
            }
            .simultaneousGesture(TapGesture().onEnded{
                selectedDate = date
            })
        }
    }
    
    var foregoundColor: Color {
        if calendar.isDate(Date(), inSameDayAs: date) {
            if calendar.isDate(selectedDate, inSameDayAs: date) {
                return Color.white
            } else {
                return Color.blue
            }
        } else {
            if calendar.isDate(selectedDate, inSameDayAs: date) {
                return Color.blue
            } else {
                return Color.textColor(colorScheme: colorScheme)
            }
        }
    }
    
    var backgroundColor: Color {
        if calendar.isDate(Date(), inSameDayAs: date) {
            if calendar.isDate(selectedDate, inSameDayAs: date) {
                return Color.blue
            } else {
                return Color.white
            }
        } else {
            if calendar.isDate(selectedDate, inSameDayAs: date) {
                return Color.blue.opacity(0.3)
            } else {
                return Color.white
            }
        }
    }
    
    var home: some View {
        ZStack {
            Text("30")
                .hidden()
                .padding(12)
                .background(backgroundColor)
                .clipShape(Circle())
                .padding(.vertical, 4)
            Text(String(self.calendar.component(.day, from: date)))
                .foregroundColor(foregoundColor)
                .font(.system(size: calendar.isDate(selectedDate, inSameDayAs: date) ? 22 : 20, weight: calendar.isDate(selectedDate, inSameDayAs: date) ? .medium : .regular, design: .default))
            if dmodel.fileExists(date: date) {
                VStack {
                    Spacer()
                    Circle()
                        .fill(calendar.isDate(selectedDate, inSameDayAs: date) ? foregoundColor : .textColor(colorScheme: colorScheme).opacity(0.3))
                        .frame(width: 6)
                        .padding(.bottom, 7)
                }
            }
        }
    }
}
