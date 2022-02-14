//
//  calendar_view.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/6/22.
//

import Foundation
import SwiftUI

/*
 This is the first page for the entire app, just a hoster for the calendarview
 */
struct SelectDate: View {
    @Environment(\.calendar) var calendar
    
    @EnvironmentObject var dmodel: DataModel
    
    @State private var selectedDate: Date = Date()
    
    private var year: DateInterval {
        DateInterval(start: Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!, end: Date())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                CalendarView(interval: year) { date in
                    CalendarCell(date: date, selectedDate: $selectedDate)
                }
            }
            .navigationTitle("Select Date")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
