//
//  MonthlyViewController.swift
//  iECalendar
//
//  Created by Shalini on 18/03/20.
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class MonthlyViewController: UIViewController {
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var monthLabel: UIButton!
    @IBOutlet weak var monthlyCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        var components = DateComponents()
        components.month = CalendarBaseViewController.selectedMonth
        components.year = CalendarBaseViewController.selectedYear
        let dateObj = CalendarElements().calendar.date(from: components) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)
        
        let convertedDate = CalendarElements().calendar.date(byAdding: .month, value: -1, to: dateObj)
        
        reloadMonthlyView(convertedDate ?? dateObj)
    }
    
    @IBAction func monthTapped(_ sender: Any) {
        customDateTimePicker()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        var components = DateComponents()
        components.month = CalendarBaseViewController.selectedMonth
        components.year = CalendarBaseViewController.selectedYear
        let dateObj = CalendarElements().calendar.date(from: components) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy)
        
        let convertedDate = CalendarElements().calendar.date(byAdding: .month, value: 1, to: dateObj) ?? dateObj
        
        reloadMonthlyView(convertedDate)
    }
    
    lazy var dateTime = CustomDateTimePicker.getFromNib()
    var calendarDelegate: CalendarDelegate?
    
    var monthlyCalendar = Calendar.current
    var firstDayOfMonth = Int()
    
    var currentMonth = String()
    var currentDate = Int()
    
    var daysInMonth = [MonthlyViewIndicator]()
    var dateMonthYear = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthlyCollectionView.delegate = self
        monthlyCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
        
        //auto resizing the height
        self.collectionViewHeight.constant = self.monthlyCollectionView.contentSize.height
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func viewWillAppearLoad() {
        currentMonth = CalendarElements().getCurrentInString(.MMMM)
        currentDate = CalendarElements().currentDate
        
        if CalendarBaseViewController.selectedMonth == 0 || CalendarBaseViewController.selectedYear == 0 {
            CalendarBaseViewController.selectedMonth = CalendarElements().currentMonth
            CalendarBaseViewController.selectedYear = CalendarElements().currentYear
            CalendarBaseViewController.selectedDate = CalendarElements().currentDate
            
            dateMonthYear = CalendarElements().getCurrentInString(.dd_MMMM_yyyy)
        } else {
            dateMonthYear = "\(CalendarBaseViewController.selectedDate) " + CalendarElements().getMonth_IntToString(CalendarBaseViewController.selectedMonth) + " \(CalendarBaseViewController.selectedYear)"
        }
        
        let date_month_year = dateMonthYear.toRequiredDateFormat(.dd_MMMM_yyyy, .MMMM_yyyy)
        
        monthLabel.setTitle(date_month_year, for: .normal)
        
        loadMonthData()
    }
    
    //get all days in a month
    func loadMonthData() {
        
        var components = DateComponents()
        components.month = CalendarBaseViewController.selectedMonth
        components.year = CalendarBaseViewController.selectedYear
        components.day = 1
        let startDateOfMonth = CalendarElements().calendar.date(from: components)
        
        let endDays = CalendarElements().getNumberOfDaysInMonth(CalendarBaseViewController.selectedMonth, CalendarBaseViewController.selectedYear)
        components.year = CalendarBaseViewController.selectedYear
        components.month = CalendarBaseViewController.selectedMonth
        components.day = endDays
        let endDateOfMonth = CalendarElements().calendar.date(from: components)
        
        let result = CoreDataStack.sharedInstance.selectAllEventsForMonth(startDateOfMonth ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy), endOfMonth: endDateOfMonth ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy))
        
        let numberOfDaysInMonth = CalendarElements().getNumberOfDaysInMonth(CalendarBaseViewController.selectedMonth, CalendarBaseViewController.selectedYear)
        
        monthlyCalendar = CalendarElements().calendar
        let dateComponents = DateComponents(year: CalendarBaseViewController.selectedYear, month: CalendarBaseViewController.selectedMonth)
        if let date = monthlyCalendar.date(from: dateComponents) {
            firstDayOfMonth = monthlyCalendar.component(.weekday, from: date)
        }
        
        daysInMonth.removeAll()
        if numberOfDaysInMonth > 1 {
            
            if firstDayOfMonth > 1 {
                for _ in 1...(firstDayOfMonth - 1) {
                    daysInMonth.append(MonthlyViewIndicator(date: 0, isToday: false, isAppiledLeave: false, isHoliday: false, hasEvents: false))
                }
                self.setEventsForADay(numberOfDaysInMonth, result)
                
            } else {
                self.setEventsForADay(numberOfDaysInMonth, result)
            }
        }
        monthlyCollectionView.reloadData()
    }
    
    //get events for a day
    func setEventsForADay(_ numberOfDaysInMonth: Int,_ result: [ActivityCalendar]?) {
        
        for i in 1...numberOfDaysInMonth {
            
            var isToday = false
            if currentDate == i && currentMonth.lowercased() == CalendarElements().getMonth_IntToString(CalendarBaseViewController.selectedMonth).lowercased() && CalendarElements().currentYear == CalendarBaseViewController.selectedYear {
                isToday = true
            }
            
            var convertDateToString = "\(i)"
            if i < 10 {
                convertDateToString = "0\(i)"
            }
            let dayEvents = result?.filter({ (($0.eventDate?.toString(.dd_MMM_yyyy)?.components(separatedBy: " "))?.first) ?? ($0.startTime?.components(separatedBy: " ").first) == convertDateToString})
            
            let isAppiledLeaves = dayEvents?.filter({ $0.eventType == EventType.appiled_leaves.rawValue }).count ?? 0
            let isHoliday = dayEvents?.filter({ $0.eventType == EventType.offical_holiday.rawValue }).count ?? 0
            let hasEvents = dayEvents?.filter({ $0.eventType == EventType.lead.rawValue || $0.eventType == EventType.attendance.rawValue || $0.eventType == EventType.added_event.rawValue || $0.eventType == EventType.allDay.rawValue }).count ?? 0
            
            daysInMonth.append(MonthlyViewIndicator(date: i, isToday: isToday, isAppiledLeave: (isAppiledLeaves >= 1), isHoliday: (isHoliday >= 1), hasEvents: (hasEvents >= 1)))
        }
    }
    
    //reset the month based on selection
    func reloadMonthlyView(_ date: Date) {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = DateFormat.MMMM_yyyy.rawValue
        dateMonthYear = dateFormatterPrint.string(from: date)
        
        monthLabel.setTitle(dateMonthYear, for: .normal)
        
        CalendarBaseViewController.selectedMonth = CalendarElements().getMonth_StringToInt(dateMonthYear.toRequiredDateFormat(.MMMM_yyyy, .MMMM) ?? currentMonth)
        CalendarBaseViewController.selectedYear = Int(dateMonthYear.toRequiredDateFormat(.MMMM_yyyy, .yyyy) ?? CalendarElements().getCurrentInString(.yyyy)) ?? CalendarElements().currentYear
        
        loadMonthData()
    }
}

extension MonthlyViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 //years
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if #available(iOS 11.0, *) {
            let marginsAndInsets = 2 * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right * CGFloat(7 - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(7)).rounded(.down)
            
            print("\n itemWidth =>\(itemWidth)\n collectionView.bounds.size.width =>\(collectionView.bounds.size.width)\n marginsAndInsets =>\(marginsAndInsets)")
            
            if itemWidth >= 55 {
                 return CGSize(width: itemWidth - 3, height: itemWidth + 15)
            } else {
                return CGSize(width: itemWidth + 1, height: itemWidth + 15)
            }
           
        } else {
            let frame = collectionView.frame.width/7
            return CGSize(width: frame, height: 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthlyDateCollectionViewCellID", for: indexPath) as! DateCollectionViewCell
        
        if daysInMonth[indexPath.row].date != 0 {
            cell.dateLabel.setTitle("\(daysInMonth[indexPath.row].date)", for: .normal)
            
            if daysInMonth[indexPath.row].isToday {
                
                if daysInMonth[indexPath.row].isHoliday {
                    cell.dateLabel.setTitleColor(UIColor.systemGreen, for: .normal)
                    
                } else if daysInMonth[indexPath.row].isAppiledLeave {
                    cell.dateLabel.setTitleColor(UIColor.systemRed, for: .normal)
                    
                } else {
                    cell.dateLabel.setTitleColor(UIColor.white, for: .normal)
                }
                
                cell.dateLabel.backgroundColor = UIColor(netHex:0x0CE2b8)
                
            } else if daysInMonth[indexPath.row].isHoliday {
                cell.dateLabel.setTitleColor(UIColor.systemGreen, for: .normal)
                cell.dateLabel.backgroundColor = UIColor.white
                
            } else if daysInMonth[indexPath.row].isAppiledLeave {
                cell.dateLabel.setTitleColor(UIColor.systemRed, for: .normal)
                cell.dateLabel.backgroundColor = UIColor.white
                
            } else {
                cell.dateLabel.setTitleColor(UIColor.darkGray, for: .normal)
                cell.dateLabel.backgroundColor = UIColor.white
            }
            
            //if there are events
            if daysInMonth[indexPath.row].hasEvents {
                cell.indicatorButton.isHidden = false
            } else {
                cell.indicatorButton.isHidden = true
            }
            
        } else {
            cell.dateLabel.setTitle("", for: .normal)
            cell.dateLabel.backgroundColor = UIColor.white
            cell.indicatorButton.isHidden = true
        }
        
        cell.dateLabel.tag = daysInMonth[indexPath.row].date
        cell.dateLabel.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        calendarDelegate?.didSelect(CalendarBaseViewController.selectedYear, CalendarBaseViewController.selectedMonth, daysInMonth[indexPath.row].date)
    }
    
    @objc func didSelectItem(_ sender: UIButton) {
        calendarDelegate?.didSelect(CalendarBaseViewController.selectedYear, CalendarBaseViewController.selectedMonth, sender.tag)
    }
}

//month picker
extension MonthlyViewController: CustomDateTimePickerDelegate {
    
    func customDateTimePicker() {
        
        dateTime.delegate = self
        dateTime.config.animationDuration = 0.25
        dateTime.dateTimePicker.datePickerMode = .date
        var components: DateComponents = DateComponents()
        
        components.year = -20
        if let miniDate = Calendar.current.date(byAdding: components, to: Date()) {
            dateTime.config.minimumDate = miniDate
        }
        
        dateTime.config.startDate = dateMonthYear.toDate(.MMMM_yyyy)
        
        components.year = 20
        if let maxDate = Calendar.current.date(byAdding: components, to: Date()) {
            dateTime.config.maximumDate = maxDate
        }
        dateTime.show(inVC: self)
    }
    
    func customPicker(_ amDateTimePicker: CustomDateTimePicker, didSelect date: Date, tag: Int, sectiontag: Int) {
        
        reloadMonthlyView(date)
    }
    
    func customPickerDidCancelSelection(_ amDateTimePicker: CustomDateTimePicker) {
        print("datetime cancel")
    }
}

//        if CalendarElements().getCurrentInString(.MMMM_yyyy).lowercased() == dateMonthYear.lowercased() {
//            monthLabel.setTitleColor(UIColor.white, for: .normal)
//            backButton.setTitleColor(UIColor.white, for: .normal)
//            nextButton.setTitleColor(UIColor.white, for: .normal)
//        } else {
//            monthLabel.setTitleColor(UIColor.white, for: .normal)
//            backButton.setTitleColor(UIColor.white, for: .normal)
//            nextButton.setTitleColor(UIColor.white, for: .normal)
//        }
