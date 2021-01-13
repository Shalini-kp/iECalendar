//
//  YearlyViewController.swift
//  iECalendar
//
//  Created by Shalini on 11/03/20.
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class YearlyViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UIButton!
    @IBOutlet weak var yearlyCollectionView: UICollectionView!
    
    @IBAction func yearButtonTapped(_ sender: Any) {
        customPicker()
    }
    
    lazy var yearPicker = CustomUIPicker.getFromNib()
    var calendarDelegate: CalendarDelegate?
    
    var selectedYear = String()
    var selectedMonth = Int()
    
    var currentYear = String()
    var currentMonth = String()
    
    var yearsList = [String]()
    var month = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearlyCollectionView.delegate = self
        yearlyCollectionView.dataSource = self
        
        yearlyCollectionView.allowsSelection = true
        yearlyCollectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentMonth = CalendarElements().getCurrentInString(.MMMM)
        currentYear = CalendarElements().getCurrentInString(.yyyy)
        
        selectedYear = currentYear
        yearLabel.setTitle(selectedYear, for: .normal)
        yearLabel.setTitleColor(UIColor.white, for: .normal)
        
        let currentYearInt  = CalendarElements().currentYear
        yearsList = DateFormatter().years((currentYearInt - 20)...(currentYearInt + 20))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        yearlyCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension YearlyViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 //years
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if #available(iOS 11.0, *) {
            let marginsAndInsets = 6 * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + 2 * CGFloat(3 - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(3)).rounded(.down)
            
            return CGSize(width: itemWidth, height: itemWidth + 10)
        } else {
            let frame = collectionView.frame.width/3 - 1
            return CGSize(width: frame, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return month.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCollectionViewCellID", for: indexPath) as! MonthCollectionViewCell
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectMonth))
        cell.tag = indexPath.row + 1
        cell.addGestureRecognizer(tapGesture)
        
        selectedMonth = indexPath.row + 1
        cell.monthLabel.setTitle(month[indexPath.row], for: .normal)
        cell.selectedYear = Int(selectedYear) ?? 2020
        cell.selectedMonth = selectedMonth
        
        if currentMonth.lowercased() == month[indexPath.row].lowercased() && currentYear == selectedYear {
            
            cell.enableCurrentDate = true
            cell.monthLabel.setTitleColor(UIColor(netHex:0x0CE2b8), for: .normal)
        } else {
            
            cell.enableCurrentDate = false
            cell.monthLabel.setTitleColor(UIColor.black, for: .normal)
        }
        cell.awakeFromNib()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\n didSelectMonth \n ")
        calendarDelegate?.didSelect(Int(selectedYear) ?? 2020, indexPath.row + 1, 1)
    }
    
    @objc func didSelectMonth(tapGesture: UITapGestureRecognizer) {
        print("\n didSelectMonth UITapGestureRecognizer \n ")
        calendarDelegate?.didSelect(Int(selectedYear) ?? 2020, tapGesture.view?.tag ?? selectedMonth, 1)
    }
}

//year picker
extension YearlyViewController: CustomUIPickerDelegate {
    
    func customPicker() {
        yearPicker.delegate = self
        yearPicker.config.animationDuration = 0.25
        yearPicker.config.pickerArray = yearsList
        yearPicker.config.selectedRow = yearsList.firstIndex(of: (yearLabel.currentTitle ?? currentYear))
        
        yearPicker.show(inVC: self)
    }
    
    func customPicker(_ amPicker: CustomUIPicker, didSelect row: Int, value: String, tag: Int, sectiontag: Int) {
        if currentYear == value {
            yearLabel.setTitleColor(UIColor.white, for: .normal)
        } else {
            yearLabel.setTitleColor(UIColor(netHex:0x093039), for: .normal)
        }
        
        selectedYear = value
        yearLabel.setTitle(value, for: .normal)
        yearlyCollectionView.reloadData()
    }
    
    func customPickerDidCancelSelection(_ amPicker: CustomUIPicker) {
        print("cancel")
    }
}
