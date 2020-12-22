//
//  CalendarView.swift
//  Align-iOS
//
//  Created by Basel Farag on 12/5/20.
//

import SwiftUI

extension SignedNumeric {
    
    var screenScaled: CGFloat {
        let originalDesignWidth: CGFloat = 375
        let doubleValue = Double("\(self)") ?? 0
        return UIScreen.main.bounds.size.width / originalDesignWidth * CGFloat(doubleValue)
    }
    
}

//So you don't have to loop through all the appointments. Put them in this hashtable. You can look them up here.
extension Date {
    var dayKey: UInt {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return UInt(components.day! + 1000000 + components.month! * 10000 + components.year!)
    }
    var dayTimeKey: UInt {
        let components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: self)
        return UInt(Calendar.current.date(from: components)!.timeIntervalSince1970)
    }
}

struct CalendarView: View {
    
    private let calendar: Calendar = .current
    
    func goToToday() {
        currentMonth = calendar.component(.month, from: Date())
        currentYear = calendar.component(.year, from: Date())
        selectedTabID = MonthTab(month: currentMonth, year: currentYear).id
    }
    
    @State var currentMonth: Int = Calendar.current.component(.month, from: Date())
    @State var currentYear: Int = Calendar.current.component(.year, from: Date())
    @Binding var selectedDay: Date?
    @State var selectedTabID: Int = 122020
    
    let appointmentsByDay: [UInt: [Appointment]]
    
    var weeksCount: Int {
        return calendar.numberOfWeeks(inMonth: currentMonth,
                                       year: currentYear)
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let itemSize = geometry.size.width / CGFloat(calendar.veryShortWeekdaySymbols.count) * 0.8
            
            VStack(alignment: .center, spacing: 0) {
                
                HStack(spacing: 12.screenScaled) {
                    // Month picker
                    // ------------
                    Button(action: {
                        if currentMonth > 1 {
                            currentMonth -= 1
                        } else {
                            currentYear -= 1
                            currentMonth = 12
                        }
                        selectedTabID = MonthTab(month: currentMonth, year: currentYear).id
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    })
                    
                    let currentTab = MonthTab(id: selectedTabID)
                    Text(calendar.monthSymbols[currentTab.month - 1] + " \(currentTab.year)")
                        .font(.roboto(size: 16))
                        .frame(width: 130)
                    
                    Button(action: {
                        if currentMonth < 12 {
                            currentMonth += 1
                        } else {
                            currentYear += 1
                            currentMonth = 1
                        }
                        selectedTabID = MonthTab(month: currentMonth, year: currentYear).id
                    }, label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    })
                    // :Month picker
                    
                    Spacer()
                    
                    Button(action: {
                        goToToday()
                    }, label: {
                        Text("Today")
                            .font(.roboto(size: 14.screenScaled))
                            .foregroundColor(.blueCE)
                    })
                }.frame(width: itemSize * 6.5)
                .padding(.bottom, 16.screenScaled)
                
                HStack(spacing: 0) {
                    ForEach(calendar.veryShortWeekdaySymbols) { label in
                        Text(label)
                            .foregroundColor(.gray8F)
                            .frame(width: itemSize, height: itemSize, alignment: .center)
                    }
                }//: HStack
                
                // The calendar values
                LazyHStack {
                    MonthsPageView(selectedDay: $selectedDay, appointmentsByDay: appointmentsByDay, selectedTabID: $selectedTabID)
                        .frame(width: geometry.size.width)
                }.background(Color.grayF5)
                .frame(height: geometry.size.width * 0.7)
                
                Spacer()
                
            }//: VStack
            
        }//: GeometryReader
        
    }
}


struct MonthTab: Identifiable {
    var id: Int { return month * 10_000 + year}
    let month: Int
    let year: Int
}

extension MonthTab {
    init(id: Int) {
        month = id / 10_000
        year = id - month * 10_000
    }
    
//    init(month: Int, year: Int) {
//        self.month = month
//        self.year = year
//    }
}

struct MonthsPageView: View {
    
    @State var currentMonth: Int = Calendar.current.component(.month, from: Date())
    @State var currentYear: Int = Calendar.current.component(.year, from: Date())
    @Binding var selectedDay: Date?
    let appointmentsByDay: [UInt: [Appointment]]
    
    @Binding var selectedTabID: Int
    
    func year(forMonth month: Int) -> Int {
        var year = currentYear
        if month < currentMonth && currentMonth == 1 {
            year = currentYear - 1
        }
        if month > currentMonth && currentMonth == 12 {
            year = currentYear + 1
        }
        return year
    }
    
    var months: [MonthTab] {
        return (currentMonth-1..<currentMonth+2).map { month in
            
            let theMonth = ((12 + month - 1) % 12) + 1
            let theYear = year(forMonth: month)
            return MonthTab(month: theMonth, year: theYear)
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTabID) {
            ForEach(months) { (tab: MonthTab) in
                CalendarMonthView(currentMonth: tab.month, currentYear: tab.year, selectedDay: $selectedDay, appointmentsByDay: appointmentsByDay)
                .tag(tab.id)
            }
        }
        .onChange(of: selectedTabID, perform: { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let tab = MonthTab(id: selectedTabID)
                currentMonth = tab.month
                currentYear = tab.year
            }
        })
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
}

struct DateCellView: View {
    
    let date: Date
    let selectedDay: Date?
    let appointments: [Appointment]
    let itemSize: CGFloat
    let currentMonth: Int
    
    private let calendar: Calendar = .current
    
    var textColor: Color {
        if calendar.component(.month, from: date) == currentMonth {
            // Current month color
            return .black
        } else {
            return .grayDF
        }
    }
    
    var isSelected: Bool {
        guard let selectedDay = selectedDay else {
            return false
        }
        return calendar.isDate(date, inSameDayAs: selectedDay)
    }
    
    var body: some View {
        
        let label = "\(Calendar.current.component(.day, from: date))"
        let isSelected = self.isSelected
        let tintColor = isSelected ? .white : textColor
        let appointmentsColor: Color = isSelected ? .white : .blueCE
        
        ZStack {
            if isSelected {
                Circle()
                    .foregroundColor(.blueCE)
            }
            
            Text(label)
                .font(.roboto(size: 16.screenScaled))
                .foregroundColor(tintColor)
            
            
            HStack(spacing: 4.screenScaled) {
                ForEach(appointments, id: \.id) { _ in
                    Circle()
                        .frame(width: 6, height: 6.screenScaled)
                        .foregroundColor(appointmentsColor)
                }
            }.offset(y: 13.screenScaled)
            
        }.frame(width: itemSize, height: itemSize, alignment: .center)
    }
    
}


struct Iterator: Identifiable {
    let id: Int
}

struct CalendarMonthView: View {
    
    private let calendar: Calendar = .current
    
    let currentMonth: Int
    let currentYear: Int
    @Binding var selectedDay: Date?
    
    let appointmentsByDay: [UInt: [Appointment]]
    
    let weeksCount: Int
    let firstDayOfMonth: Date
    let firstVisibleDay: Date
    let weekIds: [Iterator]
    let dayIds: [Iterator]
    
    init(currentMonth: Int, currentYear: Int, selectedDay: Binding<Date?>, appointmentsByDay: [UInt: [Appointment]]) {
        self.currentMonth = currentMonth
        self.currentYear = currentYear
        self.appointmentsByDay = appointmentsByDay
        weeksCount = calendar.numberOfWeeks(inMonth: currentMonth,
                                            year: currentYear)
        firstDayOfMonth = calendar.firstDay(ofMonth: currentMonth,
                                                year: currentYear)
        firstVisibleDay = calendar.firstDayInAWeekContaining(date: firstDayOfMonth)
        self._selectedDay = selectedDay
        weekIds = Array((0..<weeksCount)).map{ Iterator(id: $0) }
        dayIds = Array((0..<7)).map{ Iterator(id: $0) }
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            HStack() {
                
                Spacer()
                
                let itemSize = geometry.size.width / CGFloat(calendar.veryShortWeekdaySymbols.count) * 0.8
                VStack(alignment: .center, spacing: 0) {
                    // The calendar values
                    
                    ForEach(weekIds, id: \.id) { row in
                        
                        HStack(spacing: 0) {
                            ForEach(dayIds, id: \.id) { column in
                                
                                let currentDayOffset = row.id * calendar.veryShortWeekdaySymbols.count + column.id
                                
                                let date = firstVisibleDay.adding(days: currentDayOffset)
                                
                                DateCellView(date: date,
                                             selectedDay: selectedDay,
                                             appointments: appointmentsByDay[date.dayKey] ?? [],
                                             itemSize: itemSize,
                                             currentMonth: currentMonth)
                                    .onTapGesture {
                                        selectedDay = date
                                    }
                            }//: ForEach day
                        }
                        
                    }//: ForEach week
                    
                    
                }//: VStack
                
                Spacer()
            }
            
        }//: GeometryReader
        
    }
}

struct CalendarView_Previews: PreviewProvider {
    
    static var selectedDay: Binding<Date?> = .constant(Date())
    
    static var previews: some View {
        CalendarView(selectedDay: selectedDay, appointmentsByDay: [:])
    }
}
