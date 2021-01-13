//
//  WeeklyViewController.swift
//  iECalendar
//
//  Created by Shalini on 27/03/20.
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class WeeklyViewController: UIViewController {
    
    @IBOutlet weak var weeklyTableView: UITableView!
    @IBOutlet weak var dateMonthYear: UIButton!
    @IBOutlet weak var weeklyCollectionView: UICollectionView!
    @IBOutlet weak var allDayCollectionView: UICollectionView!
    @IBOutlet weak var allDayView: UIView!
    @IBOutlet weak var allDayHeightConstraint: NSLayoutConstraint!
    
    @IBAction func dateMonthYearTapped(_ sender: Any) {
        customDateTimePicker()
    }
    
    lazy var dateTime = CustomDateTimePicker.getFromNib()
    
    var date_Month_Year = String()
    var allDayEvents = [DailyEvents]()
    var events = [DailyEvents]()
    var startTimeEvents = [String]()
    var duplicateStartEvents = [String: Int]()
    var datesForCollectionView = [[Date: DateDetails]]()
    var datesInCollectionView = [Int: [[Date: DateDetails]]]()
    
    var timeValues = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "Noon", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", "12 AM"]
    
    var timeValuesIn24Format = ["12 AM": 24, "1 AM": 1, "2 AM": 2, "3 AM": 3, "4 AM": 4, "5 AM": 5, "6 AM": 6, "7 AM": 7, "8 AM": 8, "9 AM": 9, "10 AM": 10, "11 AM": 11, "Noon": 12, "1 PM": 13, "2 PM": 14, "3 PM": 15, "4 PM": 16, "5 PM": 17, "6 PM": 18, "7 PM": 19, "8 PM": 20, "9 PM": 21, "10 PM": 22, "11 PM": 23]
    
    var currentTimeHoursFormat = ["12 AM": "12 AM", "1 AM": "01 AM", "2 AM": "02 AM", "3 AM": "03 AM", "4 AM": "04 AM", "5 AM": "05 AM", "6 AM": "06 AM", "7 AM": "07 AM", "8 AM": "08 AM", "9 AM": "09 AM", "10 AM": "10 AM", "11 AM": "11 AM", "Noon": "12 PM", "1 PM": "01 PM", "2 PM": "02 PM", "3 PM": "03 PM", "4 PM": "04 PM", "5 PM": "05 PM", "6 PM": "06 PM", "7 PM": "07 PM", "8 PM": "08 PM", "9 PM": "09 PM", "10 PM": "10 PM", "11 PM": "11 PM"]
    
    var sizeRect = ["12 AM": 0, "01 AM": 60, "02 AM": 120, "03 AM": 180, "04 AM": 240, "05 AM": 300, "06 AM": 360, "07 AM": 420, "08 AM": 480, "09 AM": 540, "10 AM": 600, "11 AM": 660, "12 PM": 720, "01 PM": 780, "02 PM": 840, "03 PM": 900, "04 PM": 960, "05 PM": 1020, "06 PM": 1080, "07 PM": 1140, "08 PM": 1200, "09 PM": 1260, "10 PM": 1320, "11 PM": 1380]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weeklyTableView.rowHeight = UITableView.automaticDimension
        weeklyTableView.estimatedRowHeight = 120
        
        weeklyCollectionView.allowsMultipleSelection = true
        weeklyTableView.tableFooterView = UIView()
        
        allDayCollectionView.delegate = self
        allDayCollectionView.dataSource = self
        
        dateMonthYear.setTitleColor(UIColor.black, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
        let allDayHeight = self.allDayCollectionView.contentSize.height
        
        //automatic resizing the height
        if allDayHeight < 80 {
            self.allDayHeightConstraint.constant = allDayHeight
        } else {
            self.allDayHeightConstraint.constant = 80
        }
    }
    
    func viewWillAppearLoad() {
        
        //initialise the tableview
        DispatchQueue.main.async { self.weeklyTableView.scrollToRow(at: IndexPath(row: 0 , section: 0), at: .middle, animated: false) }
        
        if CalendarBaseViewController.selectedDate == 0 || CalendarBaseViewController.selectedMonth == 0 || CalendarBaseViewController.selectedYear == 0 {
            
            CalendarBaseViewController.selectedDate = CalendarElements().currentDate
            CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
            CalendarBaseViewController.selectedYear = CalendarElements().currentYear
            
            date_Month_Year = CalendarElements().getCurrentInString(.dd_MMMM_yyyy)
        } else {
            
            date_Month_Year = "\(CalendarBaseViewController.selectedDate) " + CalendarElements().getMonth_IntToString(CalendarBaseViewController.selectedMonth) + " \(CalendarBaseViewController.selectedYear)"
        }
        
        let datemonthyear = date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .EEEE_dd_MMM_yyyy)
        dateMonthYear.setTitle(datemonthyear, for: .normal)
        
        loadDateEvents()
        
        //reload the date in collection view
        loadCollectionViewDate()
    }
    
    //Alternative method: to obtain width based on the text and width
    func heightWithConstrainedWidth(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    //get current selected date in the view in proper date format
    func getSelectedCurrentDate() -> Date {
        var components = DateComponents()
        components.day = CalendarBaseViewController.selectedDate
        components.month = CalendarBaseViewController.selectedMonth
        components.year = CalendarBaseViewController.selectedYear
        return CalendarElements().calendar.date(from: components) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)
    }
    
    //get current month dates
    func currentMonth() {
        
        let numberOfDaysInMonth = CalendarElements().getNumberOfDaysInMonth(CalendarBaseViewController.selectedMonth, CalendarBaseViewController.selectedYear)
        
        var dateComponents = DateComponents(year: CalendarBaseViewController.selectedYear, month: CalendarBaseViewController.selectedMonth)
        dateComponents.day = 08
        
        var firstDayOfMonth = Int()
        if let date = CalendarElements().calendar.date(from: dateComponents) {
            firstDayOfMonth = CalendarElements().calendar.component(.weekday, from: date)
        }
        
        let dateObj = getSelectedCurrentDate()
        if numberOfDaysInMonth > 1 {
            
            if firstDayOfMonth > 1 {
                
                let previousDate = CalendarElements().calendar.date(byAdding: .month, value: -1, to: dateObj)
                
                let previousMonth = CalendarElements().calendar.component(.month, from: previousDate ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmmss_a))
                let previousYear = CalendarElements().calendar.component(.year, from: previousDate ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmmss_a))
                var numberOfDaysInPreviousMonth = CalendarElements().getNumberOfDaysInMonth(previousMonth, previousYear)
                
                var previousComponents = DateComponents()
                previousComponents.month = previousMonth
                previousComponents.year = previousYear
                
                for _ in 1...(firstDayOfMonth - 1) {
                    
                    numberOfDaysInPreviousMonth = numberOfDaysInPreviousMonth - 1
                    previousComponents.day = numberOfDaysInPreviousMonth
                    setUpDates(previousComponents, numberOfDaysInPreviousMonth, .Previous)
                }
                
                for i in 1...numberOfDaysInMonth {
                    
                    dateComponents.day = i
                    setUpDates(dateComponents, i, .Current)
                }
            } else {
                for i in 1...numberOfDaysInMonth {
                    
                    dateComponents.day = i
                    setUpDates(dateComponents, i, .Current)
                }
            }
        }
        
        let daysInWeek = datesForCollectionView.count / 7
        if daysInWeek % 7 >= 1 {
            
            let nextDate = CalendarElements().calendar.date(byAdding: .month, value: 1, to: dateObj)
            
            let nextMonth = CalendarElements().calendar.component(.month, from: nextDate ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmmss_a))
            let nextYear = CalendarElements().calendar.component(.year, from: nextDate ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmmss_a))
            
            var nextComponents = DateComponents()
            nextComponents.month = nextMonth
            nextComponents.year = nextYear
            
            for i in 1...daysInWeek {
                
                nextComponents.day = i
                setUpDates(nextComponents, i, .Next)
            }
        }
    }
    
    //store dates
    func setUpDates(_ components: DateComponents,_ i: Int,_ status: DateStatus) {
        
        let dateObj = CalendarElements().calendar.date(from: components) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)
        let dayValue = CalendarElements().calendar.component(.weekday, from: dateObj)
        
        var isToday = false
        if (CalendarElements().calendar.component(.year, from: dateObj) == CalendarElements().currentYear) && (CalendarElements().calendar.component(.month, from: dateObj) == CalendarElements().currentMonth) && (CalendarElements().calendar.component(.day, from: dateObj) == CalendarElements().currentDate) {
            isToday = true
        }
        
        var days = [Date: DateDetails]()
        days.updateValue(DateDetails(dateValue: "\(i)", dayValue: dayValue, dateStatus: status, isSelected: false, isToday: isToday), forKey: dateObj)
        
        datesForCollectionView.append(days)
    }
    
    //load the current month dates in collection view
    func loadCollectionViewDate() {
        
        datesForCollectionView.removeAll()
        datesInCollectionView.removeAll()
        
        currentMonth()
        
        datesForCollectionView.sort { (dict1, dict2) -> Bool in
            dict1.keys.first?.compare(dict2.keys.first ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmm_a)) == .orderedAscending
        }
        
        var row = 0
        var section = 0
        let dateObj = getSelectedCurrentDate()
        let daysInWeek = datesForCollectionView.count / 7
        
        var indexForWeek = 0
        for day in 0...(daysInWeek - 1) {
            
            var weekDays = [[Date: DateDetails]]()
            
            for index in 0...6 {
                
                let week = datesForCollectionView[indexForWeek]
                weekDays.append(week)
                
                if week.keys.first == dateObj {
                    row = index
                    section = day
                }
                indexForWeek = (indexForWeek + 1)
            }
            
            datesInCollectionView.updateValue(weekDays, forKey: day)
        }
        
        self.weeklyCollectionView.reloadData()
        
        //scroll current date
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            
            switch row {
            case 0:
                self.weeklyCollectionView.scrollToItem(at: IndexPath(row: row, section: section), at: .left, animated: true)
            case 1:
                self.weeklyCollectionView.scrollToItem(at: IndexPath(row: row - 1, section: section), at: .left, animated: true)
            case 2:
                self.weeklyCollectionView.scrollToItem(at: IndexPath(row: row - 2, section: section), at: .left, animated: true)
            case 3:
                self.weeklyCollectionView.scrollToItem(at: IndexPath(row: row, section: section), at: .centeredHorizontally, animated: true)
            case 4:
                self.weeklyCollectionView.scrollToItem(at: IndexPath(row: row + 2, section: section), at: .right, animated: true)
            case 5:
                self.weeklyCollectionView.scrollToItem(at: IndexPath(row: row + 1, section: section), at: .right, animated: true)
            case 6:
                self.weeklyCollectionView.scrollToItem(at: IndexPath(row: row, section: section), at: .right, animated: true)
                
            default:
                print("error")
            }
            self.weeklyCollectionView.setNeedsLayout()
            
        }
    }
    
    //reset the view based on the date
    func reloadWeeklyView(_ date: Date,_ isEnableScroll: Bool) {
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = DateFormat.dd_MMMM_yyyy.rawValue
        date_Month_Year = dateFormatterPrint.string(from: date)
        
        let date_month_year = date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .EEEE_dd_MMM_yyyy)
        dateMonthYear.setTitle(date_month_year, for: .normal)
        
        CalendarBaseViewController.selectedDate = Int(date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .dd) ?? CalendarElements().getCurrentInString(.dd)) ?? CalendarElements().currentDate
        CalendarBaseViewController.selectedMonth = CalendarElements().getMonth_StringToInt(date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .MMMM) ?? CalendarElements().getCurrentInString(.MMMM))
        CalendarBaseViewController.selectedYear = Int(date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .yyyy) ?? CalendarElements().getCurrentInString(.yyyy)) ?? CalendarElements().currentYear
        
        loadDateEvents()
        
        if isEnableScroll {
            
            //reload the date in collection view
            loadCollectionViewDate()
        } else {
            self.weeklyCollectionView.reloadData()
        }
    }
    
    //set up current time
    func currentTimeOfTheDay() {
        
        //initialise the tableview
        DispatchQueue.main.async { self.weeklyTableView.scrollToRow(at: IndexPath(row: 0 , section: 0), at: .middle, animated: false) }
        
        if CalendarElements().getCurrentInString(.dd_MMMM_yyyy) == date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .dd_MMMM_yyyy) {
            
            //scroll to current time
            CalendarElements().hourMin12Format(CalendarElements().currentTime) { (hours, minutes) in
                self.scrollToParticularEvent(hours)
            }
        } else if events.count > 0 {
            
            //scroll to first event
            let event = events.first
            let startTime = event?.startTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a) ?? CalendarElements().currentTime
            CalendarElements().hourMin12Format(startTime) { (hours, minutes) in
                self.scrollToParticularEvent(hours)
            }
        }
    }
    
    //scroll to current time if its today or else scroll to first event of the day
    func scrollToParticularEvent(_ hourInFormat: String) {
        for (index, item) in currentTimeHoursFormat.enumerated() {
            
            if item.value == hourInFormat {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
                    
                    let indexOfTimeValues = self.timeValues.firstIndex(of: item.key)
                    
                    self.weeklyTableView.scrollToRow(at: IndexPath(row: indexOfTimeValues ?? index , section: 0), at: .middle, animated: true)
                }
                break
            }
        }
    }
    
    //check for same events at a time (start time)
    func getSameEvents(_ eventStartTime: String) -> Int? {
        return self.startTimeEvents.filter( {$0 == eventStartTime} ).count
    }
    
    //add the events
    func createEvents(_ events: [DailyEvents]) {
        
        for (index, event) in events.enumerated() {
            
            let startTime = event.startTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a)
            let endTime = event.endTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a)
            var startminutes = ""
            var starthourInFormat = ""
            
            CalendarElements().hourMin12Format(startTime) { (hours, minutes) in
                starthourInFormat = hours
                startminutes = minutes
            }
            
            var endminutes = ""
            var endhourInFormat = ""
            
            if endTime != "" && endTime != nil {
                
                CalendarElements().hourMin12Format(endTime) { (hours, minutes) in
                    endhourInFormat = hours
                    endminutes = minutes
                }
            }
            
            let startTimeRect = ((sizeRect[starthourInFormat] ?? 0) + 2)
            let endTimeRect = sizeRect[endhourInFormat] ?? 0
            
            // set up starting point (origin Y)
            var originY = startTimeRect + 2
            if startminutes != "", let minutesInInt = Int(startminutes) {
                
                if 1...15 ~= minutesInInt {
                    originY = startTimeRect + 15
                    
                } else if 16...30 ~= minutesInInt {
                    originY = startTimeRect + 30
                    
                } else if 31...40 ~= minutesInInt {
                    originY = startTimeRect + 45
                    
                } else if 40...58 ~= minutesInInt {
                    originY = startTimeRect + 60
                }
            }
            
            //set up (origin X)
            var originX = 50
            
            // set up ending point (height)
            var heightOfEvents = 60
            var endOriginY = endTimeRect
            if endTimeRect > 0 {
                
                if endminutes != "", let minutesInInt = Int(endminutes) {
                    
                    if 1...15 ~= minutesInInt {
                        endOriginY = (endTimeRect) + 15
                        
                    } else if 16...30 ~= minutesInInt {
                        endOriginY = endTimeRect + 30
                        
                    } else if 31...40 ~= minutesInInt {
                        endOriginY = endTimeRect + 45
                        
                    } else if 40...58 ~= minutesInInt {
                        endOriginY = endTimeRect + 60
                    }
                }
                heightOfEvents = endOriginY - originY
            }
            
            //if events are at same time (width)
            var widthOfEvents = Int(UIScreen.main.bounds.width - 50)
            if let sameStartCount = getSameEvents(starthourInFormat) {
                
                if sameStartCount > 1 {
                    widthOfEvents = widthOfEvents / sameStartCount
                    
                    if duplicateStartEvents[starthourInFormat] != nil {
                        originX = widthOfEvents + (duplicateStartEvents[starthourInFormat] ?? originX) + 2
                    }
                    duplicateStartEvents.updateValue(originX, forKey: starthourInFormat)
                }
            }
            
            //change the height for check In/check Out
            if event.eventType == EventType.attendance.rawValue && event.location != nil && event.location != "" {
                heightOfEvents = Int(heightWithConstrainedWidth("\(event.eventTitle ?? "")\n\(event.location ?? "")", width: CGFloat(widthOfEvents), font: UIFont(name: "Helvetica-Bold", size: 14)!)) + 16
            }
            
            //set up the button frame
            let startDate = event.startTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .dd_MMMM_yyyy)
            let endDate = event.endTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .dd_MMMM_yyyy)
            let currentDate = date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .dd_MMMM_yyyy)
                        
            if (endDate != nil && (endDate != "")) {
                
                if (startDate == currentDate) && (endDate == currentDate) {
                                        
                    if Int(heightOfEvents) > 1 {
                        let eventButton = UIButton(frame: CGRect(x: originX, y: originY, width: widthOfEvents, height: Int(heightOfEvents)))
                        setUpEventView(eventButton, event, index)
                        
                    } else {
                        let eventButton = UIButton(frame: CGRect(x: originX, y: originY, width: widthOfEvents, height: Int(heightOfEvents + 5)))
                        setUpEventView(eventButton, event, index)
                    }
                    
                } else if (startDate != currentDate) && (endDate == currentDate) {
                    
                    let eventButton = UIButton(frame: CGRect(x: 50, y: 2, width: Int(UIScreen.main.bounds.width - 50), height: endOriginY))
                    setUpEventView(eventButton, event, index)
                    
                } else if (startDate == currentDate) && (endDate != currentDate) {
                    
                    let height = 1500 - originY
                    let eventButton = UIButton(frame: CGRect(x: originX, y: originY, width: widthOfEvents, height: height))
                    setUpEventView(eventButton, event, index)
                    
                } else if (startDate != currentDate) && (endDate != currentDate) {
                    
                    let eventButton = UIButton(frame: CGRect(x: 50, y: 2, width: Int(UIScreen.main.bounds.width - 50), height: 1500))
                    setUpEventView(eventButton, event, index)
                    
                } else {
                    
                    let eventButton = UIButton(frame: CGRect(x: originX, y: originY, width: widthOfEvents, height: Int(heightOfEvents)))
                    setUpEventView(eventButton, event, index)
                }
            } else {
                
                let eventButton = UIButton(frame: CGRect(x: originX, y: originY, width: widthOfEvents, height: Int(heightOfEvents)))
                setUpEventView(eventButton, event, index)
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    //Event View
    func setUpEventView(_ eventButton: UIButton,_ event: DailyEvents,_ index: Int) {
        eventButton.viewWithTag(index)
        print("\n ******* eventButton frame =>\(eventButton.frame) ******")
        if event.eventType == EventType.attendance.rawValue {
            
            if event.location != nil && event.location != "" {
                eventButton.setTitle("\(event.eventTitle ?? "")\n\(event.location ?? "")", for: .normal)
            } else {
                eventButton.setTitle("\(event.eventTitle ?? "")", for: .normal)
            }
            
            eventButton.setTitleColor(UIColor(netHex: 0x05614F), for: .normal)
            eventButton.backgroundColor = UIColor.iECalendarColor.withAlphaComponent(0.4)
            
        } else if event.eventType == EventType.lead.rawValue {
            
            let eventTitle = ((event.eventTitle ?? "Scheduled an appointment"))
            eventButton.setTitle(eventTitle + " - " + (event.eventDescription ?? "Lead") + "(\(event.endTime ?? ""))", for: .normal)
            
            eventButton.setTitleColor(UIColor(netHex: 0x0C75FF), for: .normal)
            eventButton.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.6)
            
        } else if event.eventType == EventType.added_event.rawValue {
            
            eventButton.setTitle(event.eventTitle, for: .normal)
            
            eventButton.setTitleColor(UIColor(netHex: 0x3F3F3F), for: .normal)
            eventButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.65)
            
            eventButton.tag = index
            eventButton.addTarget(self, action: #selector(self.didTapCreatedEvents(_:)), for: .touchUpInside)
        }
                            
        if eventButton.frame.height < 5 {
            eventButton.titleLabel?.numberOfLines = 1
            eventButton.titleLabel?.adjustsFontSizeToFitWidth = true
            eventButton.titleLabel?.minimumScaleFactor = 0.25
            eventButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)

        } else {
            eventButton.titleLabel?.numberOfLines = 4
            eventButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 0, right: 0)
        }
        eventButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        eventButton.alpha = 1
        eventButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)!
        eventButton.contentHorizontalAlignment = .left
        eventButton.contentVerticalAlignment = .top
        eventButton.makeMultiLineSupport()
                    
        if !eventButton.isDescendant(of: self.weeklyTableView) {
            self.weeklyTableView.insertSubview(eventButton, at: index) }
    }
    
    @objc func didTapCreatedEvents(_ sender: UIButton) {
        
        if (events[sender.tag].eventType == EventType.added_event.rawValue) {
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CreateEventViewControllerID") as! CreateEventViewController
                storyboard.isUpdate = true
                storyboard.eventId = self.events[sender.tag].eventReferenceID ?? ""
                self.navigationController?.pushViewController(storyboard, animated: true)
            }
        }
    }
    
    //get events for a day
    func loadDateEvents() {
        
        duplicateStartEvents.removeAll()
        startTimeEvents.removeAll()
        allDayEvents.removeAll()
        events.removeAll()
        
        weeklyTableView.subviews.forEach { $0.removeFromSuperview() }
        
        var dailyEvents = [DailyEvents]()
        if let dayEvents = CoreDataStack.sharedInstance.selectAllEventsForDay(date_Month_Year.toDate(.dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)) {
            
            if !dayEvents.isEmpty, dayEvents.count >= 1 {
                for event in dayEvents {
                    dailyEvents.append(DailyEvents(eventID: event.eventID, eventType: event.eventType, eventDate: event.eventDate, eventTitle: event.eventTitle, location: event.location, eventReferenceID: event.eventReferenceID, startTime: event.startTime, endTime: event.endTime, eventDescription: event.eventDescription, reminder: event.reminder, repetation: event.repetation))
                }
                
                dailyEvents.sort(by: { $0.startTime?.toDate(.dd_MMM_yyyy_hhmm_a)?.compare(($1.startTime?.toDate(.dd_MMM_yyyy_hhmm_a))!) == .orderedAscending })
                
                //load all-day collection view
                allDayEvents = dailyEvents.filter { (dailyEvent) -> Bool in
                    dailyEvent.eventType == EventType.offical_holiday.rawValue ||  dailyEvent.eventType == EventType.allDay.rawValue || dailyEvent.eventType == EventType.appiled_leaves.rawValue
                }
                
                //load manually created events
                events = dailyEvents.filter { (dailyEvent) -> Bool in
                    dailyEvent.eventType == EventType.added_event.rawValue || dailyEvent.eventType == EventType.attendance.rawValue || dailyEvent.eventType == EventType.lead.rawValue
                }
                print("\n events =>\(events)\n\ndailyEvents =>\(dailyEvents)\n\n allDay =>\(allDayEvents)\n ")
                
                if events.count > 0 {
                    
                    //save start time of the events
                    events.forEach { let startTime = $0.startTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a)
                        CalendarElements().hourMin12Format(startTime) { (hours, minutes) in
                            self.startTimeEvents.append(hours)
                        } }
                    
                    //add events in tableview
                    createEvents(events)
                }
                
                DispatchQueue.main.async {
                    
                    if self.allDayEvents.count > 0 {
                        self.allDayView.isHidden = false
                        self.allDayCollectionView.reloadData()
                        self.weeklyTableView.reloadData()
                        self.view.layoutIfNeeded()
                        
                        let allDayHeight = self.allDayCollectionView.contentSize.height
                        
                        //automatic resizing the height
                        if allDayHeight < 80 {
                            self.allDayHeightConstraint.constant = allDayHeight
                        } else {
                            self.allDayHeightConstraint.constant = 80
                        }
                    } else {
                        self.allDayView.isHidden = true
                        self.view.layoutIfNeeded()
                        self.weeklyTableView.reloadData()
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    self.allDayView.isHidden = true
                    self.view.layoutIfNeeded()
                    self.weeklyTableView.reloadData()
                }
            }
        } else {
            
            DispatchQueue.main.async {
                self.allDayView.isHidden = true
                self.view.layoutIfNeeded()
                self.weeklyTableView.reloadData()
            }
        }
        
        //set up current time
        currentTimeOfTheDay()
    }
}

extension WeeklyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60 //UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyTableViewCellID", for: indexPath) as? WeeklyTableViewCell else { return UITableViewCell()}
        
        let timeValue = timeValues[indexPath.row]
        cell.timeLabel.text = timeValue
        
        if timeValues.count - 1 == indexPath.row {
            cell.minutesStackView.isHidden = true
            cell.currentTimeView.isHidden = true
            
        } else {
            cell.minutesStackView.isHidden = false
            cell.fifteenMinLabel.textColor = UIColor.white
            cell.thirtyMinLabel.textColor = UIColor.white
            cell.fourtyFiveMinLabel.textColor = UIColor.white
            
            if CalendarElements().getCurrentInString(.dd_MMMM_yyyy) == date_Month_Year.toRequiredDateFormat(.dd_MMMM_yyyy, .dd_MMMM_yyyy) {
                
                var hourInFormat = ""
                var minutesInFormat = ""
                CalendarElements().hourMin12Format(CalendarElements().currentTime) { (hours, minutes) in
                    
                    hourInFormat = hours
                    minutesInFormat = minutes
                }
                
                if hourInFormat == currentTimeHoursFormat[timeValue] {
                    
                    cell.currentTimeView.isHidden = false
                    cell.currentTime.text = CalendarElements().currentTime
                    
                    if minutesInFormat != "", let minutesInInt = Int(minutesInFormat) {
                        
                        if minutesInInt == 0 {
                            cell.currentTimeTopConstraint.constant = -14.7
                            cell.timeLabel.textColor = UIColor.white
                            
                        } else {
                            cell.timeLabel.textColor = UIColor.darkGray
                            
                            if 1...4 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = -10
                                
                            } else if 5...10 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = -5
                                
                            } else if 11...15 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 0
                                
                            } else if 16...20 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 5
                                
                            } else if 21...25 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 10
                                
                            } else if 26...30 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 15
                                
                            } else if 31...35 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 20
                                
                            }  else if 36...40 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 25
                                
                            } else if 41...45 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 28
                                
                            } else if 46...50 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 32
                                
                            } else if 51...53 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 34
                                
                            } else if 54...59 ~= minutesInInt {
                                cell.currentTimeTopConstraint.constant = 36.5
                            }
                        }
                    }  else {
                        cell.currentTimeView.isHidden = true
                    }
                } else {
                    cell.currentTimeView.isHidden = true
                }
                
            } else {
                cell.currentTimeView.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if timeValues.count - 1 != indexPath.row {
            
            DispatchQueue.main.async {
                
                let storyboard = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CreateEventViewControllerID") as! CreateEventViewController
                storyboard.isUpdate = false
                storyboard.currentLayout = .Weekly
                
                let timeValue = self.timeValues[indexPath.row]
                if let timeValuesIn24Format = self.timeValuesIn24Format[timeValue] {
                    storyboard.weekStartHours = timeValuesIn24Format
                }
                
                if indexPath.row < (self.timeValues.count - 1) {
                    
                    let timeEndValue = self.timeValues[indexPath.row + 1]
                    if let timeEndValuesIn24Format = self.timeValuesIn24Format[timeEndValue] {
                        storyboard.weekEndHours = timeEndValuesIn24Format
                    } else {
                        let endTime = CalendarElements().calendar.date(byAdding: .hour, value: 1, to: Date())
                        storyboard.weekEndHours = CalendarElements().calendar.component(.hour, from: endTime ?? Date())
                    }
                }
                
                //storyboard.eventId = event.eventReferenceID ?? ""
                self.navigationController?.pushViewController(storyboard, animated: true)
            }
        }
    }
}

extension WeeklyViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Formats the insets for the various headers and sections.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == allDayCollectionView {
            return 1.5
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == allDayCollectionView {
            return 1.5
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == allDayCollectionView {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: 2, height: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if collectionView == allDayCollectionView {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: 2, height: 2)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == allDayCollectionView {
            return 1
        }
        
        if collectionView == weeklyCollectionView {
            return datesInCollectionView.keys.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == allDayCollectionView {
            return allDayEvents.count
        }
        
        if collectionView == weeklyCollectionView {
            return datesInCollectionView[section]?.count ?? 7
        }
        return allDayEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == allDayCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllDayCollectionViewCellID", for: indexPath) as! AllDayCollectionViewCell
            
            let eventType = allDayEvents[indexPath.row].eventType
            let eventTitle = allDayEvents[indexPath.row].eventTitle ?? ""
            cell.addDayEventTitle.text = "  \(eventTitle)  "
            
            if eventType == EventType.appiled_leaves.rawValue {
                cell.addDayEventTitle.textColor = UIColor.white
                cell.addDayEventTitle.backgroundColor = UIColor.systemRed
                
            } else if eventType == EventType.offical_holiday.rawValue {
                cell.addDayEventTitle.textColor = UIColor.white
                cell.addDayEventTitle.backgroundColor = UIColor.systemGreen
                
            } else {
                cell.addDayEventTitle.textColor = UIColor(netHex: 0x1C6E31)
                cell.addDayEventTitle.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.6)
                //heightWithConstrainedWidth(eventTitle, height: collectionView.bounds.size.height, font: UIFont(name: "Helvetica", size: 14.0)!) + 8.0
            }
            
            cell.addDayEventTitle.alpha = 1
            cell.eventWidth.constant = collectionView.bounds.size.width
            self.view.layoutIfNeeded()
            
            return cell
        }
        
        if collectionView == weeklyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCellID", for: indexPath) as! DateCollectionViewCell
            
            let datesDict = datesInCollectionView[indexPath.section]
            let dateDetails = datesDict?[indexPath.row]
            
            cell.dateLabel.setTitle(dateDetails?.first?.value.dateValue, for: .normal)
            
            let dateObj = getSelectedCurrentDate()
            
            if dateDetails?.first?.value.isToday ?? false {
                
                cell.dateLabel.setTitleColor(UIColor.white, for: .normal)
                cell.dateLabel.backgroundColor = UIColor(netHex:0x0CE2b8)
                
            } else if dateObj == dateDetails?.first?.key {
                
                cell.dateLabel.setTitleColor(UIColor.white, for: .normal)
                cell.dateLabel.backgroundColor = UIColor.lightGray
                
            } else {
                cell.dateLabel.setTitleColor(UIColor.darkGray, for: .normal)
                cell.dateLabel.backgroundColor = UIColor.white
            }
            
            cell.dateLabel.superview?.tag = indexPath.section
            cell.dateLabel.tag = indexPath.row
            cell.dateLabel.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    //choose the date
    @objc func didSelectItem(_ sender: UIButton) {
        
        let datesDict = datesInCollectionView[sender.superview?.tag ?? 0]
        let dateDetails = datesDict?[sender.tag]
        guard let selectedDate = dateDetails?.first?.key else { return }
        
        var dateComponents = DateComponents()
        dateComponents.day = CalendarElements().calendar.component(.day, from: selectedDate)
        dateComponents.month = CalendarElements().calendar.component(.month, from: selectedDate)
        dateComponents.year = CalendarElements().calendar.component(.year, from: selectedDate)
        let date = CalendarElements().calendar.date(from: dateComponents)
        
        reloadWeeklyView(date ?? Date(), false)
    }
    
    //click on all-day events
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView == allDayCollectionView) && (allDayEvents[indexPath.row].eventType == EventType.allDay.rawValue) {
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CreateEventViewControllerID") as! CreateEventViewController
                storyboard.isUpdate = true
                storyboard.eventId = self.allDayEvents[indexPath.row].eventReferenceID ?? ""
                self.navigationController?.pushViewController(storyboard, animated: true)
            }
        }
    }
}

//dateMonthYear picker
extension WeeklyViewController: CustomDateTimePickerDelegate {
    
    func customDateTimePicker() {
        
        dateTime.delegate = self
        dateTime.config.animationDuration = 0.25
        dateTime.dateTimePicker.datePickerMode = .date
        var components: DateComponents = DateComponents()
        
        components.year = -20
        if let miniDate = Calendar.current.date(byAdding: components, to: Date()) {
            dateTime.config.minimumDate = miniDate
        }
        
        dateTime.config.startDate = date_Month_Year.toDate(.dd_MMM_yyyy)
        
        components.year = 20
        if let maxDate = Calendar.current.date(byAdding: components, to: Date()) {
            dateTime.config.maximumDate = maxDate
        }
        dateTime.show(inVC: self)
    }
    
    func customPicker(_ amDateTimePicker: CustomDateTimePicker, didSelect date: Date, tag: Int, sectiontag: Int) {
        
        //get the selected date data
        reloadWeeklyView(date, true)
    }
    
    func customPickerDidCancelSelection(_ amDateTimePicker: CustomDateTimePicker) {
        print("datetime cancel")
    }
}
