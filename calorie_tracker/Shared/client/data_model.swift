//
//  data_model.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/5/22.
//

import Foundation
import SwiftUI

/*
 Holds all data state for the entire application
 */
class DataModel: ObservableObject {
    // for faster identification of what files exist for calendar view
    @Published var indexes: [String]?
    // list of current items for the day
    @Published var items: [CalorieItem]?
    // current date the user is viewing
    @Published var date = Date()
    // whether the app is open to a day, need this value to properly reload data when in background
    @Published var isOnView = false
    
    init() {
        // get index file on startup
        decodeIndex()
    }
    
    // current filename the user is viewing
    var filename: String = "" {
        didSet {
            // when set, set isOnView and decode the items from the given filename
            isOnView = true
            decodeItems()
        }
    }
    
    func addItem(item: CalorieItem) {
        if self.items != nil {
            // add to list
            self.items!.append(item)
            // save to database
            encodeItems(items: self.items!)
            // sort items by date
            sortItems()
        }
    }

    func updateItem(item: CalorieItem) {
        if self.items != nil {
            // check if item exists
            if self.items!.contains(where: {$0.id == item.id}) {
                // remove the old item
                self.items!.removeAll(where: {$0.id == item.id})
                // add the new item
                addItem(item: item)
            }
        }
    }

    func deleteItem(item: CalorieItem) {
        if self.items != nil {
            // check the item exists
            if self.items!.contains(where: {$0.id == item.id}) {
                // remove the item
                self.items!.removeAll(where: {$0.id == item.id})
                // save to database
                encodeItems(items: self.items!)
            }
        }
    }
    
    // sorts items by date
    func sortItems() {
        if self.items != nil {
            self.items!.sort {
                $0.getDate() < $1.getDate()
            }
        }
    }
    
    // get total calories for the current item list
    func totalCalories() -> Int {
        if self.items != nil {
            var total: Int = 0
            for (item) in self.items! {
                total += item.calories
            }
            return total
        } else {
            return 0
        }
    }
    
    // check if filename exists in index
    func fileExists(name: String) -> Bool {
        if self.indexes != nil {
            return indexes!.contains(where: { $0 == name })
        } else {
            return false
        }
    }
    
    // reloads the item list if user is on a day
    func reload() {
        if isOnView {
            decodeItems()
        }
    }
    
    // writes the passed item list to the current filename
    func encodeItems(items: [CalorieItem]) {
        do {
            // sort the items
            let sortedItems = items.sorted {
                $0.getDate() > $1.getDate()
            }
            // compose the url
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(filename)
            
            // write json form of data to file
            try JSONEncoder().encode(sortedItems)
                .write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    // sets items to whatever is found in the current filename
    func decodeItems() {
        do {
            // get url
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(filename)
            
            // check if file exists
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("file exists")
                let data = try Data(contentsOf: fileURL)
                self.items = try JSONDecoder().decode([CalorieItem].self, from: data)
                sortItems()
                print("successfully decoded json")
            } else {
                // here because the file has not been created yet
                print("file does not exist")
                self.items = []
                encodeItems(items: self.items!)
                // add filename to index
                indexes!.append(filename)
                encodeIndex(indexes: self.indexes!)
            }
        } catch {
            print(error)
            print("the data is bad")
        }
    }
    
    // deletes the current filename
    func deleteCurrentFile() {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(filename)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("deleting file ...")
                try FileManager.default.removeItem(at: fileURL)
                print("successfully deleted file")
                // remove the filename from the index list
                indexes!.removeAll(where: { $0 == filename })
                encodeIndex(indexes: self.indexes!)
                print("updated index list")
            } else {
                print("file to delete does not exist")
            }
        } catch {
            print(error)
            print("there was an issue with loading the file for delete")
        }
    }
    
    // encodes the passed indexes into index.json
    func encodeIndex(indexes: [String]) {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("index.json")

            try JSONEncoder().encode(indexes)
                .write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    // reads whatever is in index.json and sets the indexes list
    func decodeIndex() {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("index.json")
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("index file exists")
                let data = try Data(contentsOf: fileURL)
                self.indexes = try JSONDecoder().decode([String].self, from: data)
                print(self.indexes!)
                print("successfully decoded index json")
            } else {
                print("index file does not exist")
                // here because the file has not been created yet
                self.indexes = []
                encodeIndex(indexes: self.indexes!)
            }
        } catch {
            print(error)
            print("the data is bad")
        }
    }
    
    // for handling multiple sheets
    @Published var showSheet = false
    @Published var sheet: Sheet = .none {
        didSet {
            showSheet = true
        }
    }
    
    // available sheets
    enum Sheet {
        case none
        case create
        case edit(item: CalorieItem)
    }
    
    // show correct view for currently selected sheet sheet
    func sheetView() -> AnyView {
        switch (sheet) {
        case .create:
            return AnyView(CEItem(date: date))
        case .edit(item: let item):
            return AnyView(CEItem(item: item))
        default:
            return AnyView(EmptyView())
        }
    }
    
    // generates the proper filename format when passed a date
    func generateFilename(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "LLLL"
        let month = dateFormatter.string(from: date)
        let day = Calendar.current.component(.day, from: date)
        return "\(year).\(month).\(day)_database.json"
    }
}
