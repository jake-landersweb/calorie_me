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
    @Published var indexes: Set<String> = []
    
    // list of current items for the day
//    @Published var items: [CalorieItem]?
    
    init() {
        // get index file on startup
        decodeIndex()
    }
    
    // sorts items by date
    func sortItems(items: [CalorieItem]) -> [CalorieItem] {
        return items.sorted {
            $0.getDate() < $1.getDate()
        }
    }
    
    // check if filename exists in index
    func fileExists(date: Date) -> Bool {
        return indexes.contains(generateFilename(date: date))
    }
    
    // writes the passed item list to the current filename
    func encodeItems(date: Date, items: [CalorieItem]) {
        do {
            let filename = generateFilename(date: date)
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
            indexes.insert(filename)
            encodeIndex(indexes: indexes)
        } catch {
            print(error)
        }
    }
    
    // sets items to whatever is found in the current filename
    func decodeItems(date: Date) -> [CalorieItem] {
        do {
            let filename = generateFilename(date: date)
            // get url
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(filename)
            
            // check if file exists
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("file exists")
                let data = try Data(contentsOf: fileURL)
                let items = try JSONDecoder().decode([CalorieItem].self, from: data)
                return sortItems(items: items)
            } else {
                // here because the file has not been created yet
                print("file does not exist")
                return []
            }
        } catch {
            print(error)
            print("the data is bad")
            return []
        }
    }
    
    // deletes the current filename
    func deleteFile(date: Date) {
        do {
            let filename = generateFilename(date: date)
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(filename)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("deleting file ...")
                try FileManager.default.removeItem(at: fileURL)
                print("successfully deleted file")
                // remove the filename from the index list
                indexes.remove(filename)
                encodeIndex(indexes: self.indexes)
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
    func encodeIndex(indexes: Set<String>) {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("index.json")

            try JSONEncoder().encode(Array(indexes))
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
                let tmp = try JSONDecoder().decode([String].self, from: data)
                self.indexes = Set(tmp)
                print("successfully decoded index json")
                print(self.indexes)
            } else {
                print("index file does not exist")
                // here because the file has not been created yet
                self.indexes = []
                encodeIndex(indexes: self.indexes)
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
        case workout_notepad
        case create(onAction: (CalorieItem) -> Void, date: Date)
        case edit(onAction: (CalorieItem) -> Void,item: CalorieItem)
    }
    
    // show correct view for currently selected sheet sheet
    func sheetView() -> AnyView {
        switch (sheet) {
        case .workout_notepad:
            return AnyView(SettingsView())
        case .create(onAction: let onAction, date: let date):
            return AnyView(CEItem(onAction: onAction, date: date))
        case .edit(onAction: let onAction, item: let item):
            return AnyView(CEItem(onAction: onAction, item: item))
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
    
    func filenameToDate(filename: String) -> Date? {
        let components = filename.split(separator: ".")
        guard components.count >= 3 else { return nil }
        
        let year = String(components[0])
        let month = String(components[1])
        let dayString = String(components[2].split(separator: "_")[0])
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy LLLL d"
        return dateFormatter.date(from: "\(year) \(month) \(dayString)")
    }
}
