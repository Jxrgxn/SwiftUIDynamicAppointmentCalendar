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
    
    func firstDay(ofMonth month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.month = month
        components.year = year
        components.day = 1
        components.hour = 12
        
        return date(from: components)!
    }
    
    func lastDay(ofMonth month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.month = month
        components.year = year
        components.day = 1
        components.hour = 12
        
        let newComponents = components.addingMonth()!
        return date(from: newComponents)!.adding(days: -1)
    }
    
    func numberOfWeeks(inMonth month: Int, year: Int) -> Int {
        let date = lastDay(ofMonth: month, year: year)
        let weekRange = range(of: .weekOfMonth,
                              in: .month,
                              for: date)
        return weekRange!.count
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
    
}

extension DateComponents {
    
    func addingMonth() -> DateComponents? {
        guard let month = month, let year = year else {
            return nil
        }
        
        var newComponents = self
        
        if month < 12 {
            newComponents.month = month + 1
        } else {
            newComponents.year = year + 1
            newComponents.month = 1
        }
        
        return newComponents
    }
    
}


extension Date {
    
    static func date(day: Int, month:  Int, year: Int, hour: Int = 14) -> Date {
        var components = DateComponents()
        
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        
        return Calendar.current.date(from: components)!
    }
    
}
