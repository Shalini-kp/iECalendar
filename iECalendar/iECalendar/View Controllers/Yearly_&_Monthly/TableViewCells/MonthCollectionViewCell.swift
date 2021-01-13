//
//  MonthCollectionViewCell.swift
//  iECalendar
//
//  Created by Shalini on 11/03/20.
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class MonthCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UIButton!
    @IBOutlet weak var monthCollectionView: UICollectionView!
    
    var selectedYear = Int()
    var selectedMonth = Int()
    
    var enableCurrentDate = Bool()
    var currentDate = Int()
    var firstDayOfMonth = Int()
    
    var daysInMonth = [MonthlyViewIndicator]()
    var monthlyCalendar = Calendar.current
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        monthCollectionView.delegate = self
        monthCollectionView.dataSource = self
        monthCollectionView.isScrollEnabled = false
                       
        monthlyCalendar = CalendarElements().calendar
        currentDate = CalendarElements().currentDate
        
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        components.day = 1
        let startDateOfMonth = CalendarElements().calendar.date(from: components)
        
        let endDays = CalendarElements().getNumberOfDaysInMonth(selectedMonth, selectedYear)
        components.year = selectedYear
        components.month = selectedMonth
        components.day = endDays
        let endDateOfMonth = CalendarElements().calendar.date(from: components)
        
        let result = CoreDataStack.sharedInstance.selectAllEventsForMonth(startDateOfMonth ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy), endOfMonth: endDateOfMonth ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy))
        
        let numberOfDaysInMonth = CalendarElements().getNumberOfDaysInMonth(selectedMonth, selectedYear)
        
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
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
        monthCollectionView.reloadData()
    }
    
    //get events for a day
    func setEventsForADay(_ numberOfDaysInMonth: Int,_ result: [ActivityCalendar]?) {
        
        for i in 1...numberOfDaysInMonth {
            
            var isToday = false
            if currentDate == i && enableCurrentDate {
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
}

extension MonthCollectionViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if #available(iOS 11.0, *) {
            let marginsAndInsets = 2 * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right * CGFloat(7 - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(7)).rounded(.down)
            
            return CGSize(width: itemWidth + 0.2, height: itemWidth)
        } else {
            
            let frame = collectionView.frame.width/7
            return CGSize(width: frame, height: 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCellID", for: indexPath) as! DateCollectionViewCell
        
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
                
            }  else if daysInMonth[indexPath.row].hasEvents {
                cell.dateLabel.setTitleColor(UIColor.iECalendarColor, for: .normal)
                cell.dateLabel.backgroundColor = UIColor.white
                
            } else {
                cell.dateLabel.setTitleColor(UIColor.darkGray, for: .normal)
                cell.dateLabel.backgroundColor = UIColor.white
            }
            
        } else {
            cell.dateLabel.setTitle("", for: .normal)
            cell.dateLabel.backgroundColor = UIColor.white
        }
        cell.indicatorButton.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\n month view didSelectMonth \n ")
    }
}

//extension Date {
//    func startOfMonth() -> Date {
//        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
//    }
//
//    func endOfMonth() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
//    }
//}
