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
    
    let date: Date
    @State var items: [CalorieItem] = []
    @State private var isLoading = true
    
    // for title
    var titleString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        let month = dateFormatter.string(from: date)
        return "\(month), \(Calendar.current.component(.day, from: date))"
    }
    
    var totalCalories: Int {
        var total: Int = 0
        for item in items {
            total += item.calories
        }
        return total
    }
    
    var body: some View {
        // list with removed insets so it acts as a scrollview more or less
        // I was going for a custom implementation, but scrollview in swiftui is broken
        List {
            if isLoading {
                ProgressView()
            } else if items.count == 0 {
                Text("There are no items for this day")
                Button {
                    dmodel.sheet = .create(onAction: onAction, date: date)
                } label: {
                    Text("Create New Item")
                }
            } else {
                ForEach(items, id:\.id) { item in
                    ItemCell(onAction: onAction, onDelete: onDelete, item: item)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .navigationTitle(titleString)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            DispatchQueue.global(qos: .background).async {
                // Perform background work
                let result = dmodel.decodeItems(date: date)

                DispatchQueue.main.async {
                    // Update UI
                    self.items = result
                    print("\(items.count) Items found")
                    isLoading = false
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dmodel.sheet = .create(onAction: onAction, date: date)
                }) {
                    Image(systemName: "plus")
                }
            }
            // show a total count in the top left
            ToolbarItem(placement: .navigationBarLeading) {
                // total count
                Text("Total: \(totalCalories)")
                    .font(.system(size: 18, weight: .medium, design: .default))
            }
        }
        .onDisappear {
            // check if items are empty and delete the file if it is
            if items.isEmpty {
                print("there are no items for this day, deleting the file")
                dmodel.deleteFile(date: date)
            } else {
                // save the files to the index file
                dmodel.encodeItems(date: date, items: items)
            }
        }
    }
    
    func onAction(item: CalorieItem) -> Void {
        onDelete(item: item)
        items.append(item)
        sortItems()
        dmodel.encodeItems(date: date, items: items)
    }
    
    func onDelete(item: CalorieItem) -> Void {
        items.removeAll {
            $0.id == item.id
        }
    }
    
    func sortItems() {
        items.sort {
            $0.id > $1.id
        }
    }
}
