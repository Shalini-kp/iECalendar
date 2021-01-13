//
//  CalendarData.swift
//  iECalendar
//

import Foundation

// MARK: ----------------------- Enum functions ---------------------

//calendar layout
enum CalendarLayout: String {
    case Yearly = "Yearly View"
    case Monthly = "Monthly View"
    case Daily = "Daily View"
    case Weekly = "Weekly View"
    case EventWise = "Event List"
}

//event creation
enum CreateEvent: String {
    case title = "Title"
    case location = "Location"
    case description = "Description"
    case allDay = "All-day"
    case starts = "Starts"
    case ends = "Ends"
    case repeatEvent = "Repeat"
    case alertEvent = "Reminder"
}

//date format
enum DateFormat: String {
    case EEE_dd_MMM_yyyy = "EEE, dd MMM yyyy" //Mon, 01 Jan 2020
    case EEEE_dd_MMM_yyyy = "EEEE, dd MMM yyyy" //Monday, 01 Jan 2020
    case dd_MMM_yyyy_hhmm_a = "dd MMM yyyy hh:mm a" //01 Jan 2020 12:23 pm
    case dd_MMM_yyyy_hhmmss_a = "dd MMM yyyy hh:mm:ss a" //01 Jan 2020 12:23:10 pm
    case dd_MM_yyyy_HHmmss = "dd-MM-yyyy HH:mm:ss" //01-10-2020 12:20:10
    case dd_MMM_yyyy = "dd MMM yyyy" //01 Jan 2020
    case dd_MMMM_yyyy = "dd MMMM yyyy" //01 January 2020
    case serverDateLeaveFormat = "dd-MM-yyyy"
    case MMMM_yyyy = "MMMM yyyy" //January 2020
    case dd_MMM = "dd, MMM" //01, Jan
    case MMM_yyyy = "MMM yyyy" //Jan 2020
    case hhmm__a = "hh:mm a" //12:34 AM/PM
    case yyyy = "yyyy" //2020
    case MMMM = "MMMM" //January
    case dd = "dd" //01
}

//MARK: * Database entities: event type used while storing in the local *
enum EventType: String {
    case attendance = "Attendance"
    case lead = "Lead"
    case appiled_leaves = "Leaves"
    case offical_holiday = "Holiday"
    case allDay = "All-day"
    case added_event = "Events"
}

enum EventTitle: String {
    case checkIn = "Check In"
    case checkOut = "Check Out"
    case scheduleAppointment = "Scheduled Appointment"
    case followUp = "Follow UP"
    case appiled_leave = "On Leave"
}

enum Reminder: String {
    case atTimeOfEvent = "At time of event"
    case five_min_before = "5 minutes before"
    case fifteen_min_before = "15 minutes before"
    case thirty_min_before = "30 minutes before"
    case one_hour_before = "1 hour before"
    case two_hours_before = "2 hours before"
    case one_day_before = "1 day before"
    case two_days_before = "2 days before"
//    case one_week_before = "1 week before"
}

enum DateStatus {
    case Current
    case Previous
    case Next
}

// MARK: ----------------------- Struct functions -----------------------

struct EventItems {
    var titleName: String?
    var location: String?
    var description: String?
    var allDay = Bool()
    var starts: String?
    var ends: String?
    var repeatEvent: String?
    var alertEvent: String?
}

struct DailyEvents {
    var eventID: String?
    var eventType: String?
    var eventDate: Date?
    var eventTitle: String?
    var location: String?
    var eventReferenceID: String?
    var startTime: String?
    var endTime: String?
    var eventDescription: String?
    var reminder: String?
    var repetation: String?
}

struct MonthlyViewIndicator {
    var date = Int()
    var isToday = Bool()
    var isAppiledLeave = Bool()
    var isHoliday = Bool()
    var hasEvents = Bool()
}

struct DateDetails {
    var dateValue: String?
    var dayValue: Int?
    var dateStatus: DateStatus
    var isSelected: Bool?
    var isToday: Bool?
}

// MARK: ----------------------- Class functions -----------------------

class CalendarElements {
       
    //initialise calendar
    var calendar: Calendar = {
        var calendar = Calendar.current
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }()
    
    // MARK: * Current Year, Month, Date in int format *
    
    //current year
    var currentYear: Int = {
        var calendar = Calendar.current
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar.component(.year, from: Date())
    }()
    
    //current month
    var currentMonth: Int = {
        var calendar = Calendar.current
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar.component(.month, from: Date())
    }()
    
    //current date
    var currentDate: Int = {
        var calendar = Calendar.current
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar.component(.day, from: Date())
    }()
    
    //current day
    var currentDay: Int = {
        var calendar = Calendar.current
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar.component(.weekday, from: Date())
    }()
        
    //current time
    var currentTime: String = {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" //" hh:mm a"
        return formatter.string(from: date)
    }()
    
    //convert string to int
    func getMonth_StringToInt(_ monthValue: String) -> Int {
        
        switch monthValue {
        case "January", "Jan": return 1
        case "February", "Feb": return 2
        case "March", "Mar": return 3
        case "April", "Apr": return 4
        case "May": return 5
        case "June", "Jun": return 6
        case "July", "Jul": return 7
        case "August", "Aug": return 8
        case "September", "Sep", "Sept": return 9
        case "October", "Oct": return 10
        case "November", "Nov": return 11
        case "December", "Dec": return 12
        default: return 1
        }
    }
    
    // MARK: * Current Year, Month, Date in string format *
    
    //current date/month/year : string format
    func getCurrentInString(_ dateFormat: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: Date())
    }
    
    //current date/month/year : date format
    func getCurrentDate(_ dateFormat: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        let dateTimeString = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.date(from: dateTimeString) ?? Date()
    }
    
    //convert int to string
    func getMonth_IntToString(_ monthValue: Int) -> String {
        
        switch monthValue {
        case 1: return "January"
        case 2: return "February"
        case 3: return "March"
        case 4: return "April"
        case 5: return "May"
        case 6: return "June"
        case 7: return "July"
        case 8: return "August"
        case 9: return "September"
        case 10: return "October"
        case 11: return "November"
        case 12: return "December"
        default: return "January"
        }
    }
    
    //number of days in a month
    func getNumberOfDaysInMonth(_ month: Int,_ year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        
        if let date = calendar.date(from: dateComponents), let daysInMonth = calendar.range(of: .day, in: .month, for: date) {
            return daysInMonth.count
        }
        return 30
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }
        
        var tempDate = from
        var array = [tempDate]
        
        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        
        return array
    }
    
    func hourMin12Format(_ HHMMSS: String?, completion: @escaping (String, String) -> ()) {
        
        let timeSpilt = HHMMSS?.components(separatedBy: ":")
        let hour = timeSpilt?.first ?? ""
        let amPmSymbol = timeSpilt?.last?.components(separatedBy: " ").last ?? ""
        let minutes = timeSpilt?.last?.components(separatedBy: " ").first ?? ""
        
        completion("\(hour) \(amPmSymbol)", minutes)
    }
}


// MARK: ----------------------- Protocol & functions -----------------------

protocol CalendarDelegate {
    func didSelect(_ year: Int,_ month: Int,_ date: Int)
}

// MARK: ----------------------- Extensions -----------------------

extension DateFormatter {
    
    //fetch the range of years
    func years<R: RandomAccessCollection>(_ range: R) -> [String] where R.Iterator.Element == Int {
        
        self.dateFormat = "yyyy"
        let res = range.compactMap { DateComponents(calendar: calendar, year: $0).date }.map { string(from: $0) }
        
        return res
    }
}

extension Date {
    
    //convert string to date ** (Only the self date is in same format) ***
    func toString(_ dateFormat: DateFormat) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    //convert to specific date ** (Only the self date is in same format) ***
    func toSpecificDateFormat(_ dateFormat: DateFormat) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        let dateTimeString = dateFormatter.string(from: self)
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.date(from: dateTimeString) ?? Date()
    }
}

extension String {
    
    //convert string to date ** (Only the self string is in same format) ***
    func toDate(_ dateFormat: DateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: self)
    }
    
    //convert from one date format to required format
    func toRequiredDateFormat(_ fromDateFormat: DateFormat,_ toDateFormat: DateFormat) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = fromDateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        if let dateTime = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = toDateFormat.rawValue
            return dateFormatter.string(from: dateTime)
        } else {
            return nil
        }
    }
    
    //convert from one date format to required format
    func toRequiredDateFormatToDate(_ fromDateFormat: DateFormat,_ toDateFormat: DateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = fromDateFormat.rawValue
        dateFormatter.timeZone = TimeZone.current
        if let dateTime = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = toDateFormat.rawValue
            let date_time = dateFormatter.string(from: dateTime)
            dateFormatter.dateFormat = toDateFormat.rawValue
            return dateFormatter.date(from: date_time)
        } else {
            return nil
        }
    }
    
//    /// Returns a Date with the specified amount of components added to the one it is called with
//    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
//        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
//        return Calendar.current.date(byAdding: components, to: self)
//    }
//
//    /// Returns a Date with the specified amount of components subtracted from the one it is called with
//    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
//        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
//    }
}
