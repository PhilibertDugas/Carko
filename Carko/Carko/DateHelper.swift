//
//  DateHelper.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-15.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation

struct DateHelper {
    static func getHourString(_ date: Date) -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func getDayOfWeek(_ date: String) -> String {
        let formattedDate = formatString(date)
        let formatter = timestampFormatter()
        let todayDate = formatter.date(from: formattedDate)
        let weekday = commonCalendar().component(.weekday, from: todayDate!)
        return transformWeekdayToString(weekday)
    }

    static func getMonth(_ date: String) -> String {
        let formattedDate = formatString(date)
        let formatter = timestampFormatter()
        let todayDate = formatter.date(from: formattedDate)
        let month = commonCalendar().component(.month, from: todayDate!)
        return transformMonthToString(month)
    }

    static func getDay(_ date: String) -> Int {
        let formattedDate = formatString(date)
        let formatter = timestampFormatter()
        let todayDate = formatter.date(from: formattedDate)
        let day = commonCalendar().component(.day, from: todayDate!)
        return day
    }

    static func isSameDay(first: String?, second: String?) -> Bool {
        guard let first = first, let second = second else { return false }
        let formatter = timestampFormatter()

        let firstString = formatString(first)
        let firstDate = formatter.date(from: firstString)
        let firstDay = commonCalendar().component(.day, from: firstDate!)

        let secondString = formatString(second)
        let secondDate = formatter.date(from: secondString)
        let secondDay = commonCalendar().component(.day, from: secondDate!)

        return firstDay == secondDay
    }

    private static func timestampFormatter() -> DateFormatter {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone.init(abbreviation: "UTC")
        return formatter
    }

    private static func formatString(_ date: String) -> String{
        return date.replacingOccurrences(of: ".000", with: "")
    }

    private static func commonCalendar() -> Calendar {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = NSTimeZone.default
        return calendar
    }

    private static func transformMonthToString(_ month: Int) -> String {
        let formatter = DateFormatter.init()
        let months = formatter.monthSymbols
        return months![month - 1]
    }

    private static func transformWeekdayToString(_ weekDay: Int) -> String {
        let formatter = DateFormatter.init()
        let weekDays = formatter.weekdaySymbols
        return weekDays![weekDay - 1]
    }
}
