//
//  calendar.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 2/6/22.
//

import SwiftUI

/*
 This is a custom built calendar view manager where most of the code was found here:
 https://swiftwithmajid.com/2020/05/06/building-calendar-without-uicollectionview-in-swiftui/
 I edited a few things, like reversing the dates and changing the header code
 */
extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}

struct WeekView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let week: Date
    let content: (Date) -> DateView

    init(week: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.week = week
        self.content = content
    }

    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
            else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        ).reversed()
    }

    var body: some View {
        HStack {
            ForEach(days, id: \.self) { date in
                HStack {
                    Group {
                        if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                            self.content(date)
                        } else {
                            self.content(date).hidden()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct MonthView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let month: Date
    let showHeader: Bool
    let content: (Date) -> DateView

    init(
        month: Date,
        showHeader: Bool = true,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.month = month
        self.content = content
        self.showHeader = showHeader
    }

    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
            else { return [] }
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: calendar.firstWeekday)
        ).reversed()
    }

    private var header: some View {
        let component = calendar.component(.month, from: month)
        let formatter = component == 12 ? DateFormatter.monthAndYear : .month
        return HStack {
            Text(formatter.string(from: month))
                .font(.system(size: 40, weight: .ultraLight, design: .default))
                .padding()
            Spacer(minLength: 0)
        }
    }
    
    private func weekView() -> some View {
        let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"].reversed()
        return HStack(spacing: 0) {
            ForEach(days, id:\.self) { day in
                dayCell(day: day)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func dayCell(day: String) -> some View {
        return Text(day)
            .font(.system(size: 12, weight: .medium, design: .default))
            .opacity(0.4)
    }

    var body: some View {
        VStack {
            if showHeader {
                header
            }
            weekView()
            ForEach(weeks, id: \.self) { week in
                WeekView(week: week, content: self.content)
            }
        }
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let interval: DateInterval
    let content: (Date) -> DateView

    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
    }

    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        ).reversed()
    }
    
    private func getMonth(date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return Int(formatter.string(from: date)) ?? 0
    }

    var body: some View {
        LazyVStack {
            ForEach(months, id: \.self) { month in
                MonthView(month: month, content: self.content)
                    .id(getMonth(date: month))
                    .padding(.horizontal, 5)
            }
        }
    }
}
