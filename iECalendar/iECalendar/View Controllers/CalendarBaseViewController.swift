//
//  CalendarBaseViewController.swift
//  iECalendar
//
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class CalendarBaseViewController: UIViewController {
    
    @IBOutlet weak var calendarContainerView: UIView!
    
    lazy var yearlyCalendar: YearlyViewController = {
        let viewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "YearlyViewControllerID") as! YearlyViewController
        viewController.calendarDelegate = self
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    lazy var monthlyCalendar: MonthlyViewController = {
        let viewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "MonthlyViewControllerID") as! MonthlyViewController
        viewController.calendarDelegate = self
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    lazy var weeklyCalendar: WeeklyViewController = {
        let viewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "WeeklyViewControllerID") as! WeeklyViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    lazy var dailyCalendar: DailyViewController = {
        let viewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "DailyViewControllerID") as! DailyViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    lazy var eventCalendar: EventListViewController = {
        let viewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "EventListViewControllerID") as! EventListViewController
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    static var selectedYear = Int()
    static var selectedMonth = Int()
    static var selectedDate = Int()
    
    var currentCalendarLayout: CalendarLayout?
    lazy var picker = CustomUIPicker.getFromNib()
    var layoutViews = [CalendarLayout.Yearly.rawValue, CalendarLayout.Monthly.rawValue, CalendarLayout.Daily.rawValue, CalendarLayout.Weekly.rawValue, CalendarLayout.EventWise.rawValue]

    var isBackEnable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Activity Planner"
        
        CalendarBaseViewController.selectedDate = CalendarElements().currentDate
        CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
        CalendarBaseViewController.selectedYear = CalendarElements().currentYear
        
        //add holiday list
        getHolidayList()
        
        currentCalendarLayout = .Daily
        self.add(asChildViewController: dailyCalendar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentViewController = self
        
        //left bar button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBarButtonTapped))
        let backButtonImage = UIButton.init(type: .custom)
        backButtonImage.setImage(UIImage.init(named: "BackButton"), for: UIControl.State.normal)
        backButtonImage.addTarget(self, action:#selector(leftBarButtonTapped), for: UIControl.Event.touchUpInside)
        
        if #available(iOS 11.0, *) {
            backButtonImage.widthAnchor.constraint(equalToConstant: 12).isActive = true
            backButtonImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        } else {
            backButtonImage.frame = CGRect.init(x: 0, y: 0, width: 12, height: 20)
        }
        let barButton = UIBarButtonItem.init(customView: backButtonImage)
        
        let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = -7.0
        
        self.navigationItem.leftBarButtonItems = [fixedSpace, barButton, fixedSpace, newBackButton]
        
        //right bar button
        let addEventBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(eventButtonTapped))
       
        let layoutBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(chooseLayoutTapped))
        
        let syncBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(syncActivityCalendarTapped))
        
        //set uo restore button
        let syncCalendarActivity = UserDefaults.standard.value(forKey: "syncCalendarActivity") as? Bool ?? false
        if !(syncCalendarActivity) || CoreDataStack.sharedInstance.selectAllEvents()?.count ?? 0 < 1 {
            
            self.navigationItem.rightBarButtonItems = [layoutBarButton, fixedSpace, addEventBarButton, fixedSpace, syncBarButton]
        } else {
            
            self.navigationItem.rightBarButtonItems = [layoutBarButton, fixedSpace, addEventBarButton]
        }
    }
    
    @objc func leftBarButtonTapped() {
        
        if currentCalendarLayout == .Yearly {
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        } else if currentCalendarLayout == .Monthly && isBackEnable {
            
            currentCalendarLayout = .Yearly
            self.add(asChildViewController: yearlyCalendar)
            
        } else if currentCalendarLayout == .Daily && isBackEnable {
            
            currentCalendarLayout = .Monthly
            monthlyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: monthlyCalendar)
            
        } else if currentCalendarLayout == .EventWise {
            
            currentCalendarLayout = .Daily
            dailyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: dailyCalendar)
            
        } else if currentCalendarLayout == .Weekly {
            
            currentCalendarLayout = .Daily
            dailyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: dailyCalendar)
            
        } else {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // Choose calendar layout
    @objc func chooseLayoutTapped() {
        if self.view.subviews.filter({ $0 == picker }).isEmpty {
            customPicker()
        }
    }
    
    // Add event
    @objc func eventButtonTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CreateEventViewControllerID") as! CreateEventViewController
            storyboard.isUpdate = false
            storyboard.currentLayout = self.currentCalendarLayout
            self.navigationController?.pushViewController(storyboard, animated: true)
        }
    }
    
    //sync activites
    @objc func syncActivityCalendarTapped() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarActivitesSyncViewControllerID") as! CalendarActivitesSyncViewController
            self.navigationController?.pushViewController(storyboard, animated: true)
        }
    }
    
    // Add child viewController
    private func add(asChildViewController viewController: UIViewController) {
                
        if self.view.subviews.filter({ $0 == viewController.view }).isEmpty {
            addChild(viewController) // Add Child View Controller
            calendarContainerView.addSubview(viewController.view) // Add Child View as Subview
            
            // Configure Child View
            viewController.view.frame = calendarContainerView.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            viewController.didMove(toParent: self) // Notify Child View Controller
        } else {
            viewController.didMove(toParent: self)
        }
    }
    
    // Remove child viewController
    private func remove(asChildViewController viewController: UIViewController) {
        
        if !self.view.subviews.filter({ $0 == viewController.view }).isEmpty {
            viewController.willMove(toParent: nil) // Notify Child View Controller
            viewController.view.removeFromSuperview() // Remove Child View From Superview
            viewController.removeFromParent() // Notify Child View Controller
        } else {
            viewController.removeFromParent()
        }
    }
    
    //holiday list
    func getHolidayList() {
        
        let json = [:] as [String: AnyObject]
        
        if Reachability.isConnectedToNetwork() == true {
            initRequest.requestService(urlReference.urlcollections["holidayList"]! + SessionManager().companyID, data:json){ jsonData in
                
                let attendanceConfig = jsonData["attendanceConfiguration"] as? [String: AnyObject]
                if let holidays = attendanceConfig?["holidays"] as? NSArray {
                    
                    if holidays.count >= 1 {
                        
                        for values in (holidays){
                            if let value = (values as? Dictionary<String, Any>), let holidayDate = value["date"] as? String {
                                
                                //create each holiday as an individual event
                                _ = CoreDataStack.sharedInstance.insertIntoActivityCalendarTable(EventID: UUID().uuidString, EventType: EventType.offical_holiday.rawValue, EventDate: holidayDate.toRequiredDateFormatToDate(.serverDateLeaveFormat, .dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy), EventTitle: value["holidayReason"] as? String ?? "Holiday", Location: "", EventReferenceID: "", StartTime: holidayDate.toRequiredDateFormat(.serverDateLeaveFormat, .dd_MMM_yyyy_hhmm_a) ?? "", EndTime: "", EventDescription: value["remark"] as? String ?? "", Reminder: "", Repetation: "", OtherDetails: "")
                            }
                        }
                    }
                }
            }
        }
    }
    
    //store leaves
    func saveLeavesList(_ file: NSDictionary) {
        let startTime = (file["fromDate"] as? String ?? "").toRequiredDateFormat(.serverDateLeaveFormat, .dd_MMM_yyyy_hhmm_a) ?? ""
        let endTime = (file["toDate"] as? String ?? "").toRequiredDateFormat(.serverDateLeaveFormat, .dd_MMM_yyyy_hhmm_a) ?? ""
                
        //save it as an event in the calendar
        _ = CoreDataStack.sharedInstance.insertIntoActivityCalendarTable(EventID: UUID().uuidString, EventType: EventType.appiled_leaves.rawValue, EventDate: startTime.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy), EventTitle: EventTitle.appiled_leave.rawValue, Location: "", EventReferenceID: "", StartTime: startTime, EndTime: endTime, EventDescription: file["reason"] as? String ?? "", Reminder: "", Repetation: "", OtherDetails: "")
        
        let dates = CalendarElements().datesRange(from: startTime.toDate(.dd_MMM_yyyy_hhmm_a) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmm_a), to: endTime.toDate(.dd_MMM_yyyy_hhmm_a) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmm_a))
        
        for (index, dateTime) in dates.enumerated() {
                        
            if index >= 1 &&  dateTime.toSpecificDateFormat(.dd_MMM_yyyy) != startTime.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy) {
                
                //save it as an event in the calendar
                _ = CoreDataStack.sharedInstance.insertIntoActivityCalendarTable(EventID: UUID().uuidString, EventType: EventType.appiled_leaves.rawValue, EventDate: dateTime.toSpecificDateFormat(.dd_MMM_yyyy), EventTitle: EventTitle.appiled_leave.rawValue, Location: "", EventReferenceID: "", StartTime: startTime, EndTime: endTime, EventDescription: file["reason"] as? String ?? "", Reminder: "", Repetation: "", OtherDetails: "")
            }
        }
    }
    
    //leaves list
    func getAppliedLeavesList() {
        
        var userID = ""
        if let userInfo:[String:String] = (UserDefaults.standard.value(forKey: "userInfo") as? [String : String]) {
            userID = userInfo["UserId"] ?? ""
        }
        let currentDateValue = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let currentdate: String = dateFormatter.string(from: currentDateValue)
        
        let json = ["fromDate": currentdate, "userId": userID] as [String: AnyObject]
        
        if Reachability.isConnectedToNetwork() == true {
            initRequest.requestService(urlReference.urlcollections["listAppliedLeaves"]! + SessionManager().companyID, data:json){ jsonData in
                                
                if jsonData["leaveList"] != nil, let completeLeaveList = jsonData["leaveList"] as? [String: AnyObject] {
                    
                    if let upcomingLeavesList = completeLeaveList["upcomingLeaves"] as? NSArray {
                        
                        for obj in upcomingLeavesList {
                            if let file = obj as? NSDictionary {
                                self.saveLeavesList(file)
                            }
                        }
                    }
                    
                    if let inProgressLeavesList = completeLeaveList["inProgressLeaves"] as? NSArray{
                        
                        for obj in inProgressLeavesList {
                            if let file = obj as? NSDictionary {
                                self.saveLeavesList(file)
                            }
                        }
                    }
                    
                    if let completedLeavesList = completeLeaveList["completedLeaves"] as? NSArray{
                        
                        for obj in completedLeavesList {
                            if let file = obj as? NSDictionary {
                                self.saveLeavesList(file)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CalendarBaseViewController: CustomUIPickerDelegate {
    
    func customPicker() {
        picker.delegate = self
        picker.config.animationDuration = 0.25
        picker.config.pickerArray = layoutViews
        picker.config.selectedRow = layoutViews.firstIndex(of: currentCalendarLayout?.rawValue ?? CalendarLayout.Daily.rawValue)
        
        picker.show(inVC: self)
    }
    
    func customPicker(_ amPicker: CustomUIPicker, didSelect row: Int, value: String, tag: Int, sectiontag: Int) {
        
        let selectedCalendarLayout = CalendarLayout(rawValue: value)
        currentCalendarLayout = selectedCalendarLayout
        
        switch selectedCalendarLayout {
        case .Yearly:
            print("yearWise picker")
            
            CalendarBaseViewController.selectedDate = CalendarElements().currentDate
            CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
            CalendarBaseViewController.selectedYear = CalendarElements().currentYear
            self.add(asChildViewController: yearlyCalendar)
            
        case .Monthly:
            print("monthWise picker")
            
            CalendarBaseViewController.selectedDate = CalendarElements().currentDate
            CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
            CalendarBaseViewController.selectedYear = CalendarElements().currentYear
            monthlyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: monthlyCalendar)
            
        case .Daily:
            print("dateWise picker")
            
            CalendarBaseViewController.selectedDate = CalendarElements().currentDate
            CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
            CalendarBaseViewController.selectedYear = CalendarElements().currentYear
            
            dailyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: dailyCalendar)
            
        case .Weekly:
            print("weekWise picker")
            
            CalendarBaseViewController.selectedDate = CalendarElements().currentDate
            CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
            CalendarBaseViewController.selectedYear = CalendarElements().currentYear
            
            weeklyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: weeklyCalendar)
            
        case .EventWise:
            print("eventWise picker")
            
            eventCalendar.loadEventList()
            self.add(asChildViewController: eventCalendar)
            
        default:
            print("default picker")
        }
    }
    
    func customPickerDidCancelSelection(_ amPicker: CustomUIPicker) {
        print("cancel")
    }
}

extension CalendarBaseViewController: CalendarDelegate {
    
    func didSelect(_ year: Int, _ month: Int, _ date: Int) {
        
        isBackEnable = true
        CalendarBaseViewController.selectedYear = year
        CalendarBaseViewController.selectedMonth = month
        CalendarBaseViewController.selectedDate = date
        
        switch currentCalendarLayout {
        case .Yearly:
            
            currentCalendarLayout = .Monthly
            monthlyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: monthlyCalendar)
            
        case .Monthly:
            
            currentCalendarLayout = .Daily
            dailyCalendar.viewWillAppearLoad()
            self.add(asChildViewController: dailyCalendar)
        default:
            print("default picker")
        }
    }
}
