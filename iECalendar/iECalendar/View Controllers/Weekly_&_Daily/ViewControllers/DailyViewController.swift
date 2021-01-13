//
//  DailyViewController.swift
//  iECalendar
//
//  Created by Shalini on 20/03/20.
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class DailyViewController: UIViewController {
    
    @IBOutlet weak var noDataFound: UIView!
    @IBOutlet weak var dateLabel: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var dailyTableview: UITableView!
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        let dateObj = dateMonthYear.toDate(.dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)
        
        let convertedDate = CalendarElements().calendar.date(byAdding: .day, value: 1, to: dateObj) ?? dateObj
        
        reloadDailyView(convertedDate)
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        
        let dateObj = dateMonthYear.toDate(.dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)
        
        let convertedDate = CalendarElements().calendar.date(byAdding: .day, value: -1, to: dateObj) ?? dateObj
        
        reloadDailyView(convertedDate)
    }
    
    @IBAction func dateLabelTapped(_ sender: Any) {
        customDateTimePicker()
    }
    
    lazy var dateTime = CustomDateTimePicker.getFromNib()
    var dailyEvents = [DailyEvents]()
    
    var dateMonthYear = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyTableview.rowHeight = UITableView.automaticDimension
        dailyTableview.estimatedRowHeight = 120
        dailyTableview.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func viewWillAppearLoad() {
        if CalendarBaseViewController.selectedDate == 0 || CalendarBaseViewController.selectedMonth == 0 || CalendarBaseViewController.selectedYear == 0 {
            
            CalendarBaseViewController.selectedDate = CalendarElements().currentDate
            CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
            CalendarBaseViewController.selectedYear = CalendarElements().currentYear
            
            dateMonthYear = CalendarElements().getCurrentInString(.dd_MMMM_yyyy)
        } else {
            
            dateMonthYear = "\(CalendarBaseViewController.selectedDate) " + CalendarElements().getMonth_IntToString(CalendarBaseViewController.selectedMonth) + " \(CalendarBaseViewController.selectedYear)"
        }
        
        let date_month_year = dateMonthYear.toRequiredDateFormat(.dd_MMMM_yyyy, .EEE_dd_MMM_yyyy)
        dateLabel.setTitle(date_month_year, for: .normal)
        
        loadDateLoad()
        
        //change the color according to current date
        didChangeColor()
    }
    
    //check for current day and chnage it (for now commented to not hightlight current date)
    func didChangeColor() {
        
        //        let currentDateString = CalendarElements().getCurrentInString(.dd_MMMM_yyyy)
        //        if currentDateString == dateMonthYear.toRequiredDateFormat(.dd_MMMM_yyyy, .dd_MMMM_yyyy) {
        //            dateLabel.setTitleColor(UIColor.systemGreen, for: .normal)
        //            previousButton.setTitleColor(UIColor.systemGreen, for: .normal)
        //            nextButton.setTitleColor(UIColor.systemGreen, for: .normal)
        //        } else {
        dateLabel.setTitleColor(UIColor.iECalendarColor, for: .normal)
        previousButton.setTitleColor(UIColor.iECalendarColor, for: .normal)
        nextButton.setTitleColor(UIColor.iECalendarColor, for: .normal)
    }
    
    //reset the view based on the date
    func reloadDailyView(_ date: Date) {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = DateFormat.dd_MMMM_yyyy.rawValue
        dateMonthYear = dateFormatterPrint.string(from: date)
        
        //change the color according to current date
        didChangeColor()
        
        let date_month_year = dateMonthYear.toRequiredDateFormat(.dd_MMMM_yyyy, .EEE_dd_MMM_yyyy)
        dateLabel.setTitle(date_month_year, for: .normal)
        
        CalendarBaseViewController.selectedDate = Int(dateMonthYear.toRequiredDateFormat(.dd_MMMM_yyyy, .dd) ?? CalendarElements().getCurrentInString(.dd)) ?? CalendarElements().currentDate
        CalendarBaseViewController.selectedMonth = CalendarElements().getMonth_StringToInt(dateMonthYear.toRequiredDateFormat(.dd_MMMM_yyyy, .MMMM) ?? CalendarElements().getCurrentInString(.MMMM))
        CalendarBaseViewController.selectedYear = Int(dateMonthYear.toRequiredDateFormat(.dd_MMMM_yyyy, .yyyy) ?? CalendarElements().getCurrentInString(.yyyy)) ?? CalendarElements().currentYear
                
        loadDateLoad()
    }
    
    //get events for a day
    func loadDateLoad() {
        
        dailyEvents.removeAll()
        if let dayEvents = CoreDataStack.sharedInstance.selectAllEventsForDay(dateMonthYear.toDate(.dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)) {
            
            if !dayEvents.isEmpty, dayEvents.count >= 1 {
                for event in dayEvents {
                    dailyEvents.append(DailyEvents(eventID: event.eventID, eventType: event.eventType, eventDate: event.eventDate, eventTitle: event.eventTitle, location: event.location, eventReferenceID: event.eventReferenceID, startTime: event.startTime, endTime: event.endTime, eventDescription: event.eventDescription, reminder: event.reminder, repetation: event.repetation))
                }
                
                dailyEvents.sort(by: { $0.startTime?.toDate(.dd_MMM_yyyy_hhmm_a)?.compare(($1.startTime?.toDate(.dd_MMM_yyyy_hhmm_a))!) == .orderedAscending })
                
                DispatchQueue.main.async {
                    self.noDataFound.isHidden = true
                    self.dailyTableview.isHidden = false
                    self.dailyTableview.reloadData()
                }
            } else {
                
                DispatchQueue.main.async {
                    self.noDataFound.isHidden = false
                    self.dailyTableview.isHidden = true
                }
            }
        } else {
            
            DispatchQueue.main.async {
                self.noDataFound.isHidden = false
                self.dailyTableview.isHidden = true
            }
        }
    }
}

extension DailyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyEventListTableViewCellID", for: indexPath) as? EventListTableViewCell else { return UITableViewCell()}
        
        let event = dailyEvents[indexPath.row]
        let startTime = event.startTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a)
        let endTime = event.endTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a)
        
        switch event.eventType {
        case EventType.attendance.rawValue:
            
            cell.eventTitle.text = " " + (event.eventTitle ?? "")
            
            cell.toDate.isHidden = true
            cell.fromDate.text = startTime
            cell.eventListTextView.text = event.location
            
            cell.eventTitle.textColor = UIColor.darkGray
            //cell.eventTitle.textAlignment = .center
            cell.borderView.backgroundColor = UIColor.iECalendarColor
            
        case EventType.lead.rawValue:
            
            cell.eventTitle.textColor = UIColor.darkGray
            cell.borderView.backgroundColor = UIColor.systemTeal
            
            let eventTitle = (" " + (event.eventTitle ?? "Scheduled an appointment"))
            cell.eventTitle.text = eventTitle + " - " + (event.eventDescription ?? "Lead") + "(\(event.endTime ?? ""))" //endtime => cmrId
            
            cell.toDate.isHidden = true
            cell.fromDate.text = startTime
            cell.eventListTextView.text = event.location
            
        case EventType.appiled_leaves.rawValue:
            
            cell.eventTitle.textColor = UIColor.darkGray
            cell.borderView.backgroundColor = UIColor.systemRed
            
            cell.eventTitle.text = " " + (event.eventTitle ?? "")
            cell.fromDate.text = "All-day"
            cell.toDate.isHidden = true
            cell.eventListTextView.text = event.eventDescription
            
        case EventType.offical_holiday.rawValue, EventType.allDay.rawValue:
            
            cell.eventTitle.textColor = UIColor.darkGray
            cell.borderView.backgroundColor = UIColor.systemGreen
            
            cell.eventTitle.text = " " + (event.eventTitle ?? "")
            cell.fromDate.text = "All-day"
            cell.toDate.isHidden = true
            
            if event.eventType == EventType.offical_holiday.rawValue {
                cell.eventListTextView.text = "Holiday"
            } else if event.location != "" {
                cell.eventListTextView.text = event.location
            } else {
                cell.eventListTextView.text = event.eventDescription
            }
            
        case EventType.added_event.rawValue:
            
            cell.eventTitle.textColor = UIColor.darkGray
            cell.borderView.backgroundColor = UIColor.lightGray
            
            cell.toDate.isHidden = false
            cell.eventTitle.text = " " + (event.eventTitle ?? "")
            
            let startCheckTime = event.startTime?.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy)
            let endCheckTime = event.endTime?.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy)
            
            if startCheckTime != endCheckTime {
                
                if startCheckTime?.toString(.dd_MMM) != "" {
                    cell.fromDate.text = (startTime ?? "") + "\n(\(startCheckTime?.toString(.dd_MMM) ?? ""))"
                } else {
                    cell.fromDate.text = startTime
                }
                
                if endCheckTime?.toString(.dd_MMM) != "" {
                    cell.toDate.text = (endTime ?? "") + "\n(\(endCheckTime?.toString(.dd_MMM) ?? ""))"
                } else {
                    cell.toDate.text = endTime
                }
                
            } else {
                cell.fromDate.text = startTime
                cell.toDate.text = endTime
            }
            
            if event.location != "" {
                cell.eventListTextView.text = event.location
            } else {
                cell.eventListTextView.text = event.eventDescription
            }
            
        default: print("\n default event type")
        }
        
        if cell.eventListTextView.text.isEmpty || cell.eventListTextView.text == "" {
            cell.eventListTextView.isHidden = true
        } else {
            cell.eventListTextView.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let event = dailyEvents[indexPath.row]
        
        switch event.eventType {
            
        case EventType.allDay.rawValue, EventType.added_event.rawValue:
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CreateEventViewControllerID") as! CreateEventViewController
                storyboard.isUpdate = true
                storyboard.eventId = event.eventReferenceID ?? ""
                self.navigationController?.pushViewController(storyboard, animated: true)
            }
        default: print("\n default event type")
        }
    }
}

//dateMonthYear picker
extension DailyViewController: CustomDateTimePickerDelegate {
    
    func customDateTimePicker() {
        
        dateTime.delegate = self
        dateTime.config.animationDuration = 0.25
        dateTime.dateTimePicker.datePickerMode = .date
        var components: DateComponents = DateComponents()
        
        components.year = -20
        if let miniDate = Calendar.current.date(byAdding: components, to: Date()) {
            dateTime.config.minimumDate = miniDate
        }
        
        dateTime.config.startDate = dateMonthYear.toDate(.EEE_dd_MMM_yyyy)
        
        components.year = 20
        if let maxDate = Calendar.current.date(byAdding: components, to: Date()) {
            dateTime.config.maximumDate = maxDate
        }
        dateTime.show(inVC: self)
    }
    
    func customPicker(_ amDateTimePicker: CustomDateTimePicker, didSelect date: Date, tag: Int, sectiontag: Int) {
        
        reloadDailyView(date)
    }
    
    func customPickerDidCancelSelection(_ amDateTimePicker: CustomDateTimePicker) {
        print("datetime cancel")
    }
}
