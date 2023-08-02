//
//  Calendar+Extension.swift
//  Align-iOS
//
//  Created by Basel Farag on 12/6/20.
//

import Foundation

extension Calendar {
    
    func firstDayInAWeekContaining(date: Date) -> Date {
        let weekdayOfTheDate = component(.weekday, from: date)
        let numberOfDaysAheadOfTheBeginningOfTheWeek = weekdayOfTheDate - firstWeekday
        return date.adding(days: -numberOfDaysAheadOfTheBeginningOfTheWeek)
    }
    
    func firstDay(ofMonth month: Int, year: Int) -> Date? {
        var components = DateComponents()
        components.month = month
        components.year = year
        components.day = 1
        components.hour = 12
        
        return date(from: components)
    }
    
    func lastDay(ofMonth month: Int, year: Int) -> Date? {
        var components = DateComponents()
        components.month = month == 12 ? 1 : month + 1
        components.year = month == 12 ? year + 1 : year
        components.day = 0
        components.hour = 12
        
        return date(from: components)
    }
    
    func numberOfWeeks(inMonth month: Int, year: Int) -> Int? {
        guard let date = lastDay(ofMonth: month, year: year) else { return nil }
        let weekRange = range(of: .weekOfMonth, in: .month, for: date)
        return weekRange?.count
    }
    
    
    func isDate(_ dateA: Date, theSameAs dateB: Date, inComponents components: Set<Calendar.Component>) -> Bool {
        return dateComponents(components, from: dateA) == dateComponents(components, from: dateB)
    }
}

extension TimeInterval {
    static let hoursInADay: TimeInterval = 24
    static let secondsInAnHour: TimeInterval = 3600
    static let secondsInADay: TimeInterval = 24 * 3600
}

extension Date {
    
    func adding(days: Int) -> Date {
        return addingTimeInterval(.secondsInADay * TimeInterval(days))
    }
    
    static func date(day: Int, month:  Int, year: Int, hour: Int = 14) -> Date? {
        var components = DateComponents()
        
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        
        return Calendar.current.date(from: components)
    }
    
}
