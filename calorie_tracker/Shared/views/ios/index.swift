//
//  index.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/5/22.
//

import Foundation
import SwiftUI

/*
 This is the view for a specific day
 */
struct Index: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dmodel: DataModel
    
    // for title
    func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        let month = dateFormatter.string(from: dmodel.date)
        return "\(month), \(Calendar.current.component(.day, from: dmodel.date))"
    }
    
    var body: some View {
        // list with removed insets so it acts as a scrollview more or less
        // I was going for a custom implementation, but scrollview in swiftui is broken
        List {
            if dmodel.items != nil {
                ForEach(dmodel.items!, id:\.id) { item in
                    ItemCell(item: item)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .navigationTitle(getDate())
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dmodel.sheet = .create
                }) {
                    Image(systemName: "plus")
                }
            }
            // show a total count in the top left
            ToolbarItem(placement: .navigationBarLeading) {
                // total count
                Text("Total: \(dmodel.totalCalories())")
                    .font(.system(size: 18, weight: .medium, design: .default))
            }
        }
        .onDisappear {
            // check if items are empty and delete the file if it is
            if dmodel.items != nil {
                if dmodel.items!.isEmpty {
                    print("there are no items for this day, deleting the file")
                    dmodel.deleteCurrentFile()
                }
            }
            dmodel.isOnView = false
        }
    }
}
