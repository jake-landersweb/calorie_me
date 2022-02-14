# Calorie Me

## About

Calorie me is a simple application created with SwiftUI to keep a running track of your calories for a given day. Currently, a user selects from a calendar view to select a day, then has a list of the items they have created for that day. You can add, edit, and delete these items, which are sorted by date.

<img src="https://github.com/jake-landersweb/calorie_me/blob/main/assets/AppIcons/appstore.png" width=300px>
<img src="https://github.com/jake-landersweb/calorie_me/blob/main/assets/iphone_home.jpeg" width=250px>
<img src="https://github.com/jake-landersweb/calorie_me/blob/main/assets/iphone_day.jpeg" width=250px>
<img src="https://github.com/jake-landersweb/calorie_me/blob/main/assets/iphone_create.jpeg" width=250px>
<img src="https://github.com/jake-landersweb/calorie_me/blob/main/assets/iphone_edit.jpeg" width=250px>

If you want to check it out, the link to the app store can be found [here](https://apps.apple.com/us/app/calorie-me/id1608922326).

The app was built using the multiplatform setting in XCode, and it would not take much effort to port this over to macOS. But currently, this only runs on **iOS** and **iPadOS**. 

## Why

The purpose behind this application was to see what I could build in a single day. I finished most of the application after my day was done, with only minor optimizations and bug fixes to package it into a releasable app. The app is completely offline, and uses a custom build NoSQL-like document system for storing all of the user's data on the device in JSON format. A new document is created for every day a user inputs data to, and an index file keeps track of all of the filenames for an easy way to check if data has been written for a single day, which I use to show a dot under that specific day.

This is a viable alternative to using the native solution of Persistent Storage or MongoDB Realm. This has many less features, but considering the documents are stored in JSON format, it can be very easily imagined how this could interop with a cloud service like AWS S3 for data persistence across many different devices.

## Code

Here is the code used for reading the file for a particular day

The filenames are stored like: year.monthName.day_database.json. For example: 2022.February.13_database.json

```swift
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
```

If the file does not exist, then we can set the list to be empty and encode the items to write the file. Then, we can add this filename to out index list. The index list uses an identical process for reading and writing.

To encode items:

```swift
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
```

And thats the idea behind the app. On the day screen appear you can check if the file exists and set the items array to be the contents of the file. If no file exists, a file is created holding an empty list. On dissapear, the items list is checked for emptiness. If it is empty, the day is removed from the index and then the file is deleted.

For deleting a file:
```swift
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
```

And lastly, some misc code for how I handle edits and removes of items:
```swift
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
```

And that is a fully custom persistent storage solution that is lightning fast.