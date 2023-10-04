//
//  item_cell.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/5/22.
//

import Foundation
import SwiftUI

/*
 Simple cell for showing a calorie item
 */
struct ItemCell: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dmodel: DataModel
    
    var onAction: (CalorieItem) -> Void
    var onDelete: (CalorieItem) -> Void
    var item: CalorieItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    // title
                    Text(item.title)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(item.getTextColor(colorScheme: colorScheme))
                    // desc
                    Text(item.description)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(item.getTextColor(colorScheme: colorScheme).opacity(0.7))
                    // date
                    Text(item.getFormattedDate())
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(item.getTextColor(colorScheme: colorScheme).opacity(0.7))
                    // category
                    Text(item.category.rawValue.uppercased())
                        .font(.system(size: 20, weight: .heavy, design: .default))
                        .foregroundColor(item.getTextColor(colorScheme: colorScheme))
                }
                Spacer(minLength: 0)
                // calorie count and icon
                VStack(spacing: 10) {
                    Text("\(item.calories)")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 45, weight: .thin, design: .default))
                    Image(systemName: item.getIcon())
                        .font(.system(size: 30, weight: .thin, design: .default))
                        .frame(width: 30)
                }
                .foregroundColor(item.getTextColor(colorScheme: colorScheme))
            }
        }
        .padding()
        .background(item.getColor(colorScheme: colorScheme))
        .swipeActions(allowsFullSwipe: false) {
            // show a delete and edit because this cell is in a list
            Button("Delete") {
                withAnimation(.spring()) {
                    onDelete(item)
                }
            }
            .tint(.red)
            Button("Edit") {
                dmodel.sheet = .edit(onAction: onAction, item: item)
            }
            .tint(.gray)
        }
    }
}
