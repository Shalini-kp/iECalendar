//
//  EventListViewController.swift
//  iECalendar
//
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController {
    
    @IBOutlet weak var eventListTableView: UITableView!
    @IBOutlet weak var noDataFound: UIView!
    
    var dayWiseEvents = [[Date: [DailyEvents]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventListTableView.rowHeight = UITableView.automaticDimension
        eventListTableView.estimatedRowHeight = 120
        eventListTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       loadEventList()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    
    func loadEventList() {
        var allEvents = [DailyEvents]()
        if let events = CoreDataStack.sharedInstance.selectAllEvents() {
            
            dayWiseEvents.removeAll()
            if !events.isEmpty, events.count >= 1 {
                for event in events {
                    allEvents.append(DailyEvents(eventID: event.eventID, eventType: event.eventType, eventDate: event.eventDate, eventTitle: event.eventTitle, location: event.location, eventReferenceID: event.eventReferenceID, startTime: event.startTime, endTime: event.endTime, eventDescription: event.eventDescription, reminder: event.reminder, repetation: event.repetation))
                }
                
                let dayWiseEventsDict = Dictionary(grouping: allEvents, by: {($0.eventDate ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy))})
                
                let dict = dayWiseEventsDict.sorted { (key1, key2) -> Bool in
                    key1.key.compare(key2.key) == .orderedAscending
                }
                
                var isToday = false
                var section = 0
                
                for (index, i) in dict.enumerated() {
                    
                    var dayWiseEvents_Dict = [Date: [DailyEvents]]()
                    var value = i.value
                    value.sort(by: { $0.startTime?.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .hhmm__a)?.compare(($1.startTime?.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .hhmm__a) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy))) == .orderedAscending })
                    dayWiseEvents_Dict.updateValue(value, forKey: i.key)
                    
                    dayWiseEvents.append(dayWiseEvents_Dict)
                    
                    //find out to current date events in the list
                    if i.key == CalendarElements().getCurrentDate(.dd_MMM_yyyy) {
                        isToday = true
                        section = index
                    }
                }
                
                DispatchQueue.main.async {
                    self.noDataFound.isHidden = true
                    self.eventListTableView.isHidden = false
                    self.eventListTableView.reloadData()
                }
                
                if isToday {
                    
                    //scroll to current date
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.eventListTableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    self.noDataFound.isHidden = false
                    self.eventListTableView.isHidden = true
                }
            }
        }
    }
}

extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
        
        if CalendarElements().getCurrentInString(.dd_MMM_yyyy) == dayWiseEvents[section].keys.first?.toString(.dd_MMM_yyyy) {
            header?.textLabel?.textColor = UIColor.iECalendarColor
        } else {
            header?.textLabel?.textColor = UIColor.black
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dayWiseEvents.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dayWiseEvents[section].keys.first?.toString(.dd_MMM_yyyy)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayWiseEvents[section].values.flatMap({$0}).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventListTableViewCellID", for: indexPath) as? EventListTableViewCell else { return UITableViewCell()}
        
        let dateDict = dayWiseEvents[indexPath.section].values.flatMap({$0})
        let event = dateDict[indexPath.row]
        let startTime = event.startTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a)
        let endTime = event.endTime?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .hhmm__a)
        
        switch event.eventType {
        case EventType.attendance.rawValue:
            
            //cell.eventTitle.textColor = UIColor.iECalendarColor
            cell.borderView.backgroundColor = UIColor.iECalendarColor
            
            cell.toDate.isHidden = true
            cell.eventTitle.text = " " + (event.eventTitle ?? "" )
            cell.fromDate.text = startTime
            cell.eventListTextView.text = event.location
            
        case EventType.lead.rawValue:
            
            //cell.eventTitle.textColor = UIColor.systemTeal
            cell.borderView.backgroundColor = UIColor.systemTeal
            
            let eventTitle = (" " + (event.eventTitle ?? "Scheduled an appointment"))
            cell.eventTitle.text =  eventTitle + " - " + (event.eventDescription ?? "Lead") + "(\(event.endTime ?? ""))" //endtime => cmrId
            
            cell.toDate.isHidden = true
            cell.fromDate.text = startTime
            cell.eventListTextView.text = event.location
            
        case EventType.appiled_leaves.rawValue:
            
            //cell.eventTitle.textColor = UIColor.systemRed
            cell.borderView.backgroundColor = UIColor.systemRed
            
            cell.eventTitle.text = " " + (event.eventTitle ?? "")
            cell.fromDate.text = "All-day"
            cell.toDate.isHidden = true
            cell.eventListTextView.text = event.eventDescription
            
        case EventType.offical_holiday.rawValue, EventType.allDay.rawValue:
            
            //cell.eventTitle.textColor = UIColor.systemGreen
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
            
            //cell.eventTitle.textColor = UIColor.darkGray
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
        
        let dateDict = dayWiseEvents[indexPath.section].values.flatMap({$0})
        let event = dateDict[indexPath.row]
        
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
