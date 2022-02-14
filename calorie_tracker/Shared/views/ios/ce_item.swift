//
//  ce_item.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/5/22.
//

import Foundation
import SwiftUI

/*
 Create or Edit item. This is the model that is shown when a user is creating a new CalorieItem
 or is updating an existing one
 */
struct CEItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject private var dmodel: DataModel
    
    @State private var item: CalorieItem
    @State private var date: Date
    private var isCreate: Bool
    
    // constructor without item for creating
    init(date: Date) {
        self._item = State(initialValue: CalorieItem(title: "", description: "", category: .breakfast, calories: 0))
        self.isCreate = true
        self._date = State(initialValue: date)
    }
    
    // constructor with item for editing
    init(item: CalorieItem) {
        self._item = State(initialValue: item)
        self.isCreate = false
        self._date = State(initialValue: item.getDate())
    }
    
    // currently selected textfield
    @FocusState private var focused: Field?

    // available text fields
    private enum Field {
        case title
        case description
    }
    
    // for grid of category cells
    var columns: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 120)), count: 3)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    // title
                    VStack(spacing: 5) {
                        HStack {
                            SmallLabel(text: "Title")
                            Spacer()
                        }
                        CustomField(field: $item.title, isFocused: focused == .title, label: "Title", icon: "t.circle")
                            .focused($focused, equals: .title)
                            .submitLabel(.next)
                    }
                    // description
                    VStack(spacing: 5) {
                        HStack {
                            SmallLabel(text: "Description")
                            Spacer()
                        }
                        CustomField(field: $item.description, isFocused: focused == .description, label: "Description", icon: "doc.text")
                            .focused($focused, equals: .description)
                            .submitLabel(.done)
                    }
                    // date picker
                    VStack(spacing: 5) {
                        HStack {
                            SmallLabel(text: "Date")
                            Spacer()
                        }
                        DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                    }
                    // category picker
                    VStack(spacing: 10) {
                        HStack {
                            SmallLabel(text: "Category")
                            Spacer()
                        }
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(Category.allCases, id:\.self) { category in
                                categoryCell(category: category)
                            }
                        }
                    }
                    // calories
                    HStack {
                        SmallLabel(text: "Calories")
                        Spacer()
                    }
                    .padding(.top, 10)
                    HStack(spacing: 20) {
                        // show count
                        Text("\(item.calories)")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 45, weight: .thin, design: .default))
                            .frame(width: 120)
                        // buttons for add and sub
                        HStack(spacing: 0) {
                            calorieIncrementer(icon: "minus", weight: .bold, color: Color.red.opacity(0.3), amount: -100)
                            calorieIncrementer(icon: "minus", weight: .light, color: Color.red.opacity(0.1), amount: -25)
                            calorieIncrementer(icon: "plus", weight: .light, color: Color.green.opacity(0.1), amount: 25)
                            calorieIncrementer(icon: "plus", weight: .bold, color: Color.green.opacity(0.3), amount: 100)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    // button
                    Button(action: {
                        // set date field
                        item.setDate(date: date)
                        if isCreate {
                            // add item
                            dmodel.addItem(item: item)
                        } else {
                            dmodel.updateItem(item: item)
                        }
                        // dismiss the sheet
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(isCreate ? "Create" : "Update")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 25)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .padding(.bottom, 100)
                .onSubmit {
                    // when defined submit key is clicked, perform a different action
                    switch focused {
                    case .title:
                        focused = .description
                    default:
                        break
                    }
                }
            }
            .navigationTitle(isCreate ? "Create Item" : "Update Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    close
                }
            }
        }
    }
    
    // cell that shows a given category, sets the current category when selected
    private func categoryCell(category: Category) -> some View {
        return Button(action: {
            item.category = category
        }) {
            HStack(spacing: 5) {
                Image(systemName: CalorieItem.getIcon(category: category))
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .default))
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(item.category == category ? CalorieItem.getColor(colorScheme: colorScheme, category: category) : Color.cellColor(colorScheme: colorScheme))
            .foregroundColor(item.category == category ? CalorieItem.getTextColor(colorScheme: colorScheme, category: category) : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
    
    // cell for calorie incrementer, only allows values up to 10000, or as low as 0
    private func calorieIncrementer(icon: String, weight: Font.Weight, color: Color, amount: Int) -> some View {
        return Button(action: {
            if item.calories + amount >= 0 {
                if item.calories + amount < 10000 {
                    item.calories += amount
                } else {
                    item.calories = 10000
                }
            } else {
                item.calories = 0
            }
        }) {
            ZStack {
                color
                Image(systemName: icon)
                    .font(.system(size: 18, weight: weight, design: .default))
                    .foregroundColor(Color.white)
            }
            .aspectRatio(1, contentMode: .fill)
        }
    }
    
    // close model
    private var close: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.blue)
        }
    }
}
