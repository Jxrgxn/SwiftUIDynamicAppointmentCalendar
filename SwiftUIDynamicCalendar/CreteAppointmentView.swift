//
//  CreateAppointmentsView.swift
//  Align-iOS
//
//  Created by Basel Farag on 12/5/20.
//

import SwiftUI

//So there's a way to put the available slots and the existing appointments into a single Arrau.
protocol CalendarPickable: Codable {
    var startTime: Date { get }
}

extension CalendarPickable {
    var id: UInt { startTime.dayTimeKey }
}

struct Appointment: CalendarPickable, Identifiable {
    typealias ID = UInt
    let startTime: Date
    //let zoomMeetingLink: URL
//    let patient: Patient
}
struct TimeSlot: CalendarPickable, Identifiable {
    typealias ID = UInt
    let startTime: Date
}

extension Calendar {
    
    func isDateWorkday(date: Date) -> Bool {
        if isDateInWeekend(date) { return false }
        
        // TODO: check for holidays
        
        return true
    }
    
}

struct CalendarPickableCellView: View {
    
    let slot: CalendarPickable
    @Binding var selectedAppointments: [Appointment]
    
    var body: some View {
        let isAvailable = slot is TimeSlot
        
        let appointments = selectedAppointments
        let selectedIndex: Int? = appointments.firstIndex(where: { (appointment) -> Bool in
            return appointment.id == slot.id
        })
        let isSelected = selectedIndex != nil
        
        let timeLabel = label(slot: slot)
        Button(action: {
            if let selectedIndex = selectedIndex {
                selectedAppointments.remove(at: selectedIndex)
            } else {
                selectedAppointments.append(Appointment(startTime: slot.startTime))
            }
        }, label: {
            Text(timeLabel)
                .font(.roboto(size: 16.screenScaled))
        })
        .buttonStyle(
            isSelected ?
                ButtonStyles.timeslotSelected
                :
                ButtonStyles.timeslotUnselected
        ).disabled(!isAvailable)
    }
    
    func label(slot: CalendarPickable) -> String {
        return DateFormatter.timeSlotDateFormatter.string(from: slot.startTime).lowercased().replacingOccurrences(of: " ", with: "")
    }
}

extension DateFormatter {
    
    static let timeSlotDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
}


struct GridView: View {
    
    let rows: Int
    let columns: Int
    let width: CGFloat
    var viewAtIndexPath: (_ index: Int) -> AnyView
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 14.screenScaled) {
                
                ForEach(0..<rows) { row in
                    
                    HStack(spacing: 14.screenScaled) {
                        
                        ForEach(0..<columns) { column in
                            
                            let index = row * columns + column
                            viewAtIndexPath(index)
                        }//: Columns
                    }
                }//: Rows
            }
        }//: ScrollView
        .frame(width: width)
    }
    
}

struct CreateAppointmentsView: View {
    
    let appointments: [Appointment] = [
        Appointment(startTime: Date.date(day: 2, month: 12, year: 2020)),
        Appointment(startTime: Date.date(day: 2, month: 12, year: 2020)),
        Appointment(startTime: Date.date(day: 7, month: 12, year: 2020))
    ]
    
    
    @State var selectedDay: Date?
    
    let appointmentsByDay: [UInt: [Appointment]]
    @State var selectedAppointments = [Appointment]()
    
    init() {
        
        var appointmentsByDay = [UInt: [Appointment]]()
        
        for appointment in appointments {
            let key = appointment.startTime.dayKey
            var appointsmentsForKey = appointmentsByDay[key] ?? []
            appointsmentsForKey.append(appointment)
            appointmentsByDay[key] = appointsmentsForKey
        }
        
        self.appointmentsByDay = appointmentsByDay
    }
    
    var body: some View {
        let width = UIScreen.main.bounds.width
        
        VStack(spacing: 0) {
            CalendarView(selectedDay: $selectedDay, appointmentsByDay: appointmentsByDay)
                .frame(width: width, height: width * 0.9)
                .padding(.vertical, 22.screenScaled)
            
            /// Description
            if let selectedDay = selectedDay {
                
                let (pickableSlots, availableSlots) = pickables(date: selectedDay)
                
                VStack(alignment: .leading, spacing: 24.screenScaled) {
                    
                    Text("\(availableSlots - selectedAppointments.count) AVAILABLE TIMESLOTS")
                        .font(.roboto(size: 14))
                        .foregroundColor(.gray8F)
                    
                    let columnsCount = 3
                    let rowsCount = Int(ceil(Float(pickableSlots.count) / Float(columnsCount)))
                    
                    let scrollViewHorizontalPadding: CGFloat = 40.screenScaled
                    let scrollViewWidth: CGFloat = width - scrollViewHorizontalPadding * 2
                    
                    GridView(rows: rowsCount, columns: columnsCount, width: scrollViewWidth) { (index: Int) -> AnyView in
                        if index < pickableSlots.count {
                            let slot = pickableSlots[index]
                            return AnyView(
                                CalendarPickableCellView(slot: slot, selectedAppointments: self.$selectedAppointments)
                                    .frame(width: scrollViewWidth / CGFloat(columnsCount))
                            )
                        } else {
                            return AnyView(
                                Text("")
                                    .frame(width: scrollViewWidth / CGFloat(columnsCount))
                            )
                        }
                    }
                    
                }//: VStack (timeslots)
                .padding(.bottom, 20.screenScaled)
                
            } else {
                Spacer()
                Text("Pick a date first")
                    .font(.roboto(size: 16))
                Spacer()
            }
            
            Button("Confirm time") {
                print("Confirmed!")
            }.buttonStyle(ButtonStyles.primary)
            .disabled(selectedAppointments.count == 0)
            .padding(.horizontal, 20.screenScaled)
        }
    }
    
    
    func pickables(date: Date) -> ([CalendarPickable], Int) {
        // TODO: remove the artificial limit
        let slots = timeSlots(date: date).prefix(6)
        var appointments = appointmentsByDay[date.dayKey] ?? []
        
        var pickables = [CalendarPickable]()
        var availableSlots = 0
        for slot in slots {
            if let index = appointments.firstIndex(where: { a in
                return Calendar.current.isDate(a.startTime, theSameAs: slot.startTime, inComponents: [.hour, .minute])
            }) {
                pickables.append(appointments[index])
                appointments.remove(at: index)
            } else {
                pickables.append(slot)
                availableSlots += 1
            }
        }
        
        return (pickables, availableSlots)
    }
    
    func timeSlots(date: Date) -> [TimeSlot] {
        guard Calendar.current.isDateWorkday(date: date) else { return [] }
        
        var components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        // Start of the day
        components.hour = 8
        components.minute = 0
        let forenoonSlots = timeSlots(components: components, hours: 4)
        
        // Afternoon
        components.hour = 13
        components.minute = 0
        let afternoonSlots = timeSlots(components: components, hours: 4)
        
        return forenoonSlots + afternoonSlots
    }
    
    func timeSlots(components: DateComponents, hours: Int) -> [TimeSlot] {
        let initialDate = Calendar.current.date(from: components)!
        var slots = [TimeSlot]()
        for halfhour in 0..<hours*2 {
            let startTime = initialDate.addingTimeInterval(TimeInterval.secondsInAnHour / 2 * TimeInterval(halfhour))
            slots.append(TimeSlot(startTime:startTime))
        }
        return slots
    }
}

struct CreateAppointmentsView_Previews: PreviewProvider {
    static var previews: some View {
//        CreateAppointmentsView()
        ZStack {
//            Color.gray70
            
            HalfModalView(isShown: .constant(true),
                          modalHeight: 563.screenScaled,
//                          modalHeight: UIScreen.main.bounds.size.height * 0.8,
                          showToolbar: false, cornerRadius: 20.screenScaled) {
                CreateAppointmentsView()
            }
        }
//        .previewDevice("iPhone 8")
//        Text("")
//            .sheet(isPresented: .constant(true), content: {
//                CreateAppointmentsView()
//            })
    }
}
