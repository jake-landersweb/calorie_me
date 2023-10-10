//
//  ContentView.swift
//  Shared
//
//  Created by Jake Landers on 2/5/22.
//

import SwiftUI

/*
 Host of app, initialized the data layer,
 checks if app was in background,
 and shows a sheet when requested
 */
struct ContentView: View {
    @Environment(\.calendar) var calendar
    @StateObject var dmodel = DataModel()
    @State private var years: [Int] = []
    
    @State private var selectedDate = Date()
    @State private var selectedYear = 2023
    
    private var year: DateInterval {
        let calendar = Calendar.current
        let yearComponents = DateComponents(year: selectedYear)
        let startOfYear = calendar.date(from: yearComponents)!
        let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
        let interval = DateInterval(start: startOfYear, end: endOfYear)
        return interval
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { reader in
                ScrollView {
                    CalendarView(interval: year) { date in
                        CalendarCell(date: date, selectedDate: $selectedDate)
                            .id(date)
                    }
                    .id(selectedYear)
                }
                .onAppear {
                    let calendar = Calendar.current
                    let month = calendar.component(.month, from: Date())
                    reader.scrollTo(month)
                }
            }
            .navigationTitle("Select Date")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Select Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(formatNumber(year)).tag(year)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .frame(width: 80)
                    .labelsHidden()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dmodel.sheet = .workout_notepad
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(Color.gray)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $dmodel.showSheet) {
            dmodel.sheetView()
        }
        .environmentObject(dmodel)
        .onAppear {
            let tmp = Calendar.current.dateComponents([.year], from: Date())
            withAnimation {
                selectedYear = tmp.year!
                years = Array(tmp.year!-5...tmp.year!)
            }
            
            // check if wn ad has been shown
            if let flag = UserDefaults.standard.object(forKey: "shownWorkoutNotepad") as? Bool {
                if !flag {
                    dmodel.sheet = .workout_notepad
                }
            } else {
                dmodel.sheet = .workout_notepad
                UserDefaults.standard.set(true, forKey: "shownWorkoutNotepad")
            }
        }
    }
    
    func formatNumber(_ number: Int) -> String {
       let formatter = NumberFormatter()
       formatter.groupingSeparator = ""
       return formatter.string(from: NSNumber(value: number)) ?? ""
   }
}
