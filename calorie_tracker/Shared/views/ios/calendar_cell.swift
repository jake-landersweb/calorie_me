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
    
    @State private var hasFile: Bool = false
    
    var body: some View {
        Group {
            if date < Calendar.current.date(byAdding: .minute, value: 1, to: Date())! {
                NavigationLink(destination: Index()) {
                    home
                }
                .simultaneousGesture(TapGesture().onEnded{
                    selectedDate = date
                    dmodel.date = date
                    print(dmodel.generateFilename(date: date))
                    dmodel.filename = dmodel.generateFilename(date: date)
                })
            } else {
                home.opacity(0.3)
            }
        }
        .onAppear {
            // only check if file exists if the date is less than the current date
            if date < Calendar.current.date(byAdding: .minute, value: 1, to: Date())! {
                hasFile = dmodel.fileExists(name: dmodel.generateFilename(date: date))
            }
        }
    }
    
    var home: some View {
        ZStack(alignment: .bottom) {
            if calendar.isDate(Date(), inSameDayAs: date) {
                // stack so cells are constant size
                ZStack {
                    Text("30")
                        .hidden()
                        .padding(12)
                        .background(calendar.isDate(selectedDate, inSameDayAs: date) ? Color.blue : Color.clear)
                        .clipShape(Circle())
                        .padding(.vertical, 4)
                    Text(String(self.calendar.component(.day, from: date)))
                        .foregroundColor(calendar.isDate(selectedDate, inSameDayAs: date) ? Color.white : Color.blue)
                        .font(.system(size: 22, weight: calendar.isDate(selectedDate, inSameDayAs: date) ? .medium : .regular, design: .default))
                    // show a dot if there is data for that day
                    if hasFile {
                        VStack {
                            Spacer()
                            Circle()
                                .fill(calendar.isDate(selectedDate, inSameDayAs: date) ? .clear : .textColor(colorScheme: colorScheme).opacity(0.3))
                                .frame(width: 6)
                                .padding(.bottom, -30)
                        }
                    }
                }
            } else {
                ZStack {
                    Text("30")
                        .hidden()
                        .padding(12)
                        .background(calendar.isDate(selectedDate, inSameDayAs: date) ? Color.blue.opacity(0.1) : Color.clear)
                        .clipShape(Circle())
                        .padding(.vertical, 4)
                    Text(String(self.calendar.component(.day, from: date)))
                        .foregroundColor(calendar.isDate(selectedDate, inSameDayAs: date) ? Color.blue : .textColor(colorScheme: colorScheme))
                        .font(.system(size: calendar.isDate(selectedDate, inSameDayAs: date) ? 22 : 20, weight: calendar.isDate(selectedDate, inSameDayAs: date) ? .medium : .regular, design: .default))
                    if hasFile {
                        VStack {
                            Spacer()
                            Circle()
                                .fill(calendar.isDate(selectedDate, inSameDayAs: date) ? .clear : .textColor(colorScheme: colorScheme).opacity(0.3))
                                .frame(width: 6)
                                .padding(.bottom, -30)
                        }
                    }
                }
            }
        }
    }
}
