import Foundation

class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var currentMonth: Date

    // Cache
    private var daysInCurrentMonth: [Date] = []

    init(currentMonth: Date = Date()) {
        self.currentMonth = currentMonth
        self.daysInCurrentMonth = calculateDaysInCurrentMonth()
    }

    func calculateDaysInCurrentMonth() -> [Date] {
        // Calculate and return an array of dates that represent each day of the month.
        var days: [Date] = []
        
        // Assuming the current month starts with the 1st day
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return [] }
        
        for day in range.lowerBound..<range.upperBound {
            if let date = Calendar.current.date(bySetting: .day, value: day, of: currentMonth) {
                days.append(date)
            }
        }
        
        return days
    }

    func daysForCurrentMonth() -> [Date] {
        return daysInCurrentMonth
    }

    func select(date: Date) {
        selectedDate = date
    }

    func goToToday() {
        let today = Date()
        currentMonth = today
        selectedDate = today
        daysInCurrentMonth = calculateDaysInCurrentMonth()
    }

    // Add more functionalities as required.
}
