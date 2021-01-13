//
//  CreateEventViewController.swift
//  iECalendar
//
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {
    
    @IBOutlet weak var createEventTableView: UITableView!
    
    lazy var picker = CustomUIPicker.getFromNib()
    lazy var dateTime = CustomDateTimePicker.getFromNib()
    
    var storeEventItems = EventItems()
    var eventItems = [Int: [[String : Any]]]()
    
    var alertValues = [Reminder.atTimeOfEvent.rawValue, Reminder.five_min_before.rawValue, Reminder.fifteen_min_before.rawValue, Reminder.thirty_min_before.rawValue, Reminder.one_hour_before.rawValue, Reminder.two_hours_before.rawValue, Reminder.one_day_before.rawValue, Reminder.two_days_before.rawValue] //one_week_before
    var repeatValues = ["Never", "Every Day", "Every Week", "Every 2 Weeks", "Every Month", "Every Year"]
    
    var eventId = ""
    var isUpdate = false
    var currentLayout: CalendarLayout?
    var weekStartHours = CalendarElements().calendar.component(.hour, from: Date())
    var weekEndHours = CalendarElements().calendar.component(.hour, from: Date())
    
    //MARK: Alert => Reminder, Repeat => Repetation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUpdate {
            self.title = "Update Event"
        } else {
            self.title = "New Event"
        }
        
        eventItems = [0: [[CreateEvent.title.rawValue : []],
                          [CreateEvent.location.rawValue : []],
                          [CreateEvent.description.rawValue : []]],
                      1: [[CreateEvent.allDay.rawValue : []],
                          [CreateEvent.starts.rawValue : []],
                          [CreateEvent.ends.rawValue : []]],
                      2: [[CreateEvent.repeatEvent.rawValue : []],
                          [CreateEvent.alertEvent.rawValue : []]]]
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        
        if !isUpdate {
            eventId = UUID().uuidString
            
            self.navigationItem.rightBarButtonItems = [doneBarButton]
        } else {
            
            let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
            fixedSpace.width = 5.0
            
            self.navigationItem.rightBarButtonItems = [doneBarButton, fixedSpace, deleteBarButton]
            
            if let details = CoreDataStack.sharedInstance.selectEventDetails(eventId) {
                
                if !details.isEmpty, details.count >= 1 {
                    
                    storeEventItems.titleName = details.first?.eventTitle
                    storeEventItems.location = details.first?.location
                    storeEventItems.description = details.first?.eventDescription
                    storeEventItems.starts = details.first?.startTime
                    storeEventItems.ends = details.first?.endTime
                    storeEventItems.repeatEvent = details.first?.repetation
                    storeEventItems.alertEvent = details.first?.reminder
                    
                    if details.first?.eventType == EventType.allDay.rawValue {
                        storeEventItems.allDay = true
                    } else { storeEventItems.allDay = false }
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createEventTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (self.isMovingFromParent) {
            
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
            self.view.endEditing(true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            createEventTableView.contentInset.bottom = keyboardHeight//UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.createEventTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    //initially set the start and end date while creating new event
    func setUpInitial_StartEndTime(_ type: String) -> String {
        
        if currentLayout == .Daily {
            
            var components = DateComponents()
            components.year = CalendarBaseViewController.selectedYear
            components.month = CalendarBaseViewController.selectedMonth
            components.day = CalendarBaseViewController.selectedDate
            
            if type == "end" {
                let endTime = CalendarElements().calendar.date(byAdding: .hour, value: 1, to: Date())
                components.hour = CalendarElements().calendar.component(.hour, from: endTime ?? Date())
            } else {
                components.hour = CalendarElements().calendar.component(.hour, from: Date())
            }
            
            components.minute = CalendarElements().calendar.component(.minute, from: Date())
            let dateOfMonth = CalendarElements().calendar.date(from: components)
                        
            return dateOfMonth?.toString(.dd_MMM_yyyy_hhmm_a) ?? CalendarElements().getCurrentInString(.dd_MMM_yyyy_hhmm_a)
            
        } else if currentLayout == .Monthly {
            
            var components = DateComponents()
            components.year = CalendarBaseViewController.selectedYear
            components.month = CalendarBaseViewController.selectedMonth
            components.day = CalendarElements().currentDate
            
            if type == "end" {
                let endTime = CalendarElements().calendar.date(byAdding: .hour, value: 1, to: Date())
                components.hour = CalendarElements().calendar.component(.hour, from: endTime ?? Date())
            } else {
                components.hour = CalendarElements().calendar.component(.hour, from: Date())
            }
            
            components.minute = CalendarElements().calendar.component(.minute, from: Date())
            let dateOfMonth = CalendarElements().calendar.date(from: components)
            
            return dateOfMonth?.toString(.dd_MMM_yyyy_hhmm_a) ?? CalendarElements().getCurrentInString(.dd_MMM_yyyy_hhmm_a)
            
        } else if currentLayout == .Weekly {
            
            var components = DateComponents()
            components.year = CalendarBaseViewController.selectedYear
            components.month = CalendarBaseViewController.selectedMonth
            components.day = CalendarBaseViewController.selectedDate
            
            if type == "end" {
                
                if weekStartHours == weekEndHours {
                    let endTime = CalendarElements().calendar.date(byAdding: .hour, value: 1, to: Date())
                    components.hour = CalendarElements().calendar.component(.hour, from: endTime ?? Date())
                } else {
                   components.hour = weekEndHours
                }
                
            } else {
                components.hour = weekStartHours
            }
            
            components.minute = CalendarElements().calendar.component(.minute, from: Date())
            let dateOfMonth = CalendarElements().calendar.date(from: components)
            
            return dateOfMonth?.toString(.dd_MMM_yyyy_hhmm_a) ?? CalendarElements().getCurrentInString(.dd_MMM_yyyy_hhmm_a)
            
        } else {
            
            var components = DateComponents()
            
            components.year = CalendarElements().currentYear
            components.month = CalendarElements().currentMonth
            components.day = CalendarElements().currentDate
            
            if type == "end" {
                let endTime = CalendarElements().calendar.date(byAdding: .hour, value: 1, to: Date())
                components.hour = CalendarElements().calendar.component(.hour, from: endTime ?? Date())
            } else {
                components.hour = CalendarElements().calendar.component(.hour, from: Date())
            }
            
            components.minute = CalendarElements().calendar.component(.minute, from: Date())
            let dateOfMonth = CalendarElements().calendar.date(from: components)
            
            return dateOfMonth?.toString(.dd_MMM_yyyy_hhmm_a) ?? CalendarElements().getCurrentInString(.dd_MMM_yyyy_hhmm_a)
        }
    }
    
    @objc func doneButtonTapped() {
        if (storeEventItems.titleName?.count ?? 0 < 1) || (storeEventItems.titleName?.removingBlankSpaces() == "") {
            CustomAlertView.sharedInstance.timerAlert(self, "Please provide the title to proceed further!", nil, DispatchTime.now() + 1.5, alertStyle: .actionSheet)
        } else {
            
            if self.isUpdate {
                
                //delete the records(event id save event description id : to show start and end in respective day)
                _ = CoreDataStack.sharedInstance.deleteActivityCalendarEvent(self.eventId)
            }
            
            var evenType = EventType.added_event.rawValue
            if storeEventItems.allDay {
                evenType = EventType.allDay.rawValue
            }
            
            let startTime = storeEventItems.starts ?? CalendarElements().getCurrentInString(.dd_MMM_yyyy_hhmm_a)
            let endTime = storeEventItems.ends ?? CalendarElements().getCurrentInString(.dd_MMM_yyyy_hhmm_a)
            
            //save it as an event in the calendar (need to check multiple events for end)
            _ = CoreDataStack.sharedInstance.insertIntoActivityCalendarTable(EventID: self.eventId, EventType: evenType, EventDate: startTime.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy), EventTitle: storeEventItems.titleName ?? "", Location: storeEventItems.location ?? "", EventReferenceID: self.eventId, StartTime: startTime, EndTime: endTime, EventDescription: storeEventItems.description ?? "", Reminder: storeEventItems.alertEvent ?? alertValues[2], Repetation: storeEventItems.repeatEvent ?? repeatValues[0], OtherDetails: "")
            //(event id save event description id : to show start and end in respective day)
            
            let dates = CalendarElements().datesRange(from: startTime.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmm_a), to: endTime.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmm_a))
            
            let startCheckTime = startTime.toRequiredDateFormatToDate(.dd_MMM_yyyy_hhmm_a, .dd_MMM_yyyy)
            
            for (index, dateTime) in dates.enumerated() {
                
                if index >= 1 &&  dateTime.toSpecificDateFormat(.dd_MMM_yyyy) != startCheckTime {
                    
                    //save it as an event in the calendar
                    _ = CoreDataStack.sharedInstance.insertIntoActivityCalendarTable(EventID: UUID().uuidString, EventType: evenType, EventDate: dateTime.toSpecificDateFormat(.dd_MMM_yyyy), EventTitle: storeEventItems.titleName ?? "", Location: storeEventItems.location ?? "", EventReferenceID: self.eventId, StartTime: startTime, EndTime: endTime, EventDescription: storeEventItems.description ?? "", Reminder: storeEventItems.alertEvent ?? alertValues[2], Repetation: storeEventItems.repeatEvent ?? repeatValues[0], OtherDetails: "")
                }
            } //save event id => event description
            
            var title = "Created"
            var alarmType = "insert"
            if self.isUpdate {
                title = "Updated"
                alarmType = "update"
            }
            
            var subTitle = storeEventItems.location ?? ""
            if subTitle == "" {
                subTitle = storeEventItems.description ?? "You have an event coming up!"
            }
            
            //***** Set the alarm *****
            PushLocalNotification().initiateAlarm(alarmType, self.eventId, storeEventItems.titleName ?? "Event Scheduled!", subTitle, startTime.toDate(.dd_MMM_yyyy_hhmm_a) ?? CalendarElements().getCurrentDate(.dd_MMM_yyyy_hhmm_a), storeEventItems.alertEvent ?? alertValues[2], false, evenType, "", "")
            
            DispatchQueue.main.async(execute: {
                
                let alert = UIAlertController(title: "\(title) Successfully!", message: nil, preferredStyle: .actionSheet)
                
                self.present(alert, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                    alert.dismiss(animated: true, completion: nil)
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    @objc func deleteButtonTapped() {
        let confirmationAlert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        
        let confirmDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            _ = CoreDataStack.sharedInstance.deleteActivityCalendarEvent(self.eventId)
            
            //remove the notification
            PushLocalNotification().deinitiateAlarm([self.eventId])
            
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: "Deleted Successfully!", message: nil, preferredStyle: .actionSheet)
                
                self.present(alert, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                    alert.dismiss(animated: true, completion: nil)
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        confirmationAlert.addAction(confirmDelete)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmationAlert.addAction(cancel)
        
        OperationQueue.main.addOperation {
            self.present(confirmationAlert, animated: true)
        }
    }
}

extension CreateEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section != 0 {
            return 48
        }
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventItems.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventItems[section]?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let text = eventItems[indexPath.section]?[indexPath.row]
        
        if indexPath.section == 0 {
            
            guard let textCell = tableView.dequeueReusableCell(withIdentifier: "CreateEventTextTableViewCellID", for: indexPath) as? CreateEventTextTableViewCell else { return UITableViewCell()}
            
            textCell.addEventTextView.delegate = self
            textCell.addEventTextField.delegate = self
            
            textCell.addEventTextView.placeholder = text?.keys.first
            textCell.addEventTextField.placeholder = " " + (text?.keys.first ?? "")
            
            if text?.keys.first == CreateEvent.description.rawValue {
                textCell.addEventTextView.isHidden = false
                textCell.addEventTextField.isHidden = true
                
                if storeEventItems.description == nil || storeEventItems.description == "" {
                    textCell.addEventTextView.placeholder = "Description"
                    textCell.addEventTextView.text = nil
                } else {
                    textCell.addEventTextView.placeholder = ""
                    textCell.addEventTextView.text = storeEventItems.description
                }
                
            } else {
                textCell.addEventTextView.isHidden = true
                textCell.addEventTextField.isHidden = false
                
                if text?.keys.first == CreateEvent.title.rawValue {
                    
                    if storeEventItems.titleName != nil && storeEventItems.titleName != "" {
                        textCell.addEventTextField.text = " " + (storeEventItems.titleName ?? "")
                    } else {
                        textCell.addEventTextField.text = storeEventItems.titleName
                    }
                    
                    textCell.addEventTextField.tag = 1
                    textCell.addEventTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
                    
                } else if text?.keys.first == CreateEvent.location.rawValue {
                    
                    if storeEventItems.location != nil && storeEventItems.location != "" {
                        textCell.addEventTextField.text = " " + (storeEventItems.location ?? "")
                    } else {
                        textCell.addEventTextField.text = storeEventItems.location
                    }
                    
                    textCell.addEventTextField.tag = 2
                    textCell.addEventTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
                }
            }
            
            return textCell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateEventBasicTableViewCellID", for: indexPath) as? CreateEventBasicTableViewCell else { return UITableViewCell()}
            
            cell.titleLabel.text = text?.keys.first
            
            cell.astreikLabel.isHidden = true
            if text?.keys.first == CreateEvent.allDay.rawValue {
                cell.toogleButton.isHidden = false
                cell.dropDownArrow.isHidden = true
                cell.dropDownButton.isHidden = true
                
                cell.toogleButton.isOn = storeEventItems.allDay
                cell.toogleButton.addTarget(self, action: #selector(toogleButtonTapped), for: .touchUpInside)
            } else {
                cell.dropDownArrow.isHidden = false
                cell.dropDownButton.isHidden = false
                cell.toogleButton.isHidden = true
                
                switch text?.keys.first {
                case CreateEvent.starts.rawValue:
                    if storeEventItems.starts == nil || storeEventItems.starts == "" {
                        
                        storeEventItems.starts = setUpInitial_StartEndTime("start")
                        cell.dropDownButton.setTitle(storeEventItems.starts, for: .normal)
                        
                    } else if storeEventItems.allDay {
                        cell.dropDownButton.setTitle(storeEventItems.starts?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .EEE_dd_MMM_yyyy), for: .normal)
                        
                    } else {
                        cell.dropDownButton.setTitle(storeEventItems.starts, for: .normal)
                    }
                    
                    cell.dropDownButton.tag = 1
                    cell.dropDownButton.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                    cell.dropDownArrow.tag = 1
                    cell.dropDownArrow.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                case CreateEvent.ends.rawValue:
                    if storeEventItems.ends == nil || storeEventItems.ends == "" {
                        
                        storeEventItems.ends = setUpInitial_StartEndTime("end")
                        cell.dropDownButton.setTitle(storeEventItems.ends, for: .normal)
                        
                    } else if storeEventItems.allDay {
                        cell.dropDownButton.setTitle(storeEventItems.ends?.toRequiredDateFormat(.dd_MMM_yyyy_hhmm_a, .EEE_dd_MMM_yyyy), for: .normal)
                        
                    } else {
                        cell.dropDownButton.setTitle(storeEventItems.ends, for: .normal)
                    }
                    
                    cell.dropDownButton.tag = 2
                    cell.dropDownButton.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                    cell.dropDownArrow.tag = 2
                    cell.dropDownArrow.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                case CreateEvent.repeatEvent.rawValue:
                    if storeEventItems.repeatEvent == nil || storeEventItems.repeatEvent == "" {
                        
                        storeEventItems.repeatEvent = repeatValues[0]
                        cell.dropDownButton.setTitle(storeEventItems.repeatEvent, for: .normal)
                    } else {
                        cell.dropDownButton.setTitle(storeEventItems.repeatEvent, for: .normal)
                    }
                    
                    cell.dropDownButton.tag = 3
                    cell.dropDownButton.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                    cell.dropDownArrow.tag = 3
                    cell.dropDownArrow.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                case CreateEvent.alertEvent.rawValue:
                    if storeEventItems.alertEvent == nil || storeEventItems.alertEvent == "" {
                        
                        storeEventItems.alertEvent = alertValues[2]
                        cell.dropDownButton.setTitle(storeEventItems.alertEvent, for: .normal)
                    } else {
                        cell.dropDownButton.setTitle(storeEventItems.alertEvent, for: .normal)
                    }
                    
                    cell.dropDownButton.tag = 4
                    cell.dropDownButton.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                    cell.dropDownArrow.tag = 4
                    cell.dropDownArrow.addTarget(self, action: #selector(didSelectItem), for: .touchUpInside)
                    
                default:
                    print("error default")
                }
            }
            return cell
        }
    }
    
    @objc func didSelectItem(_ sender: UIButton) {
        
        // MARK: 1 => Starts, 2 => Ends, 3 => Repeat, 4 => Alert
        
        switch sender.tag {
            
        case 1,2: customDateTimePicker(sender.tag)
            
        case 3: customPicker(repeatValues, sender.tag)
            
        case 4: customPicker(alertValues, sender.tag)
            
        default: print(" \n didSelectItem default \n")
        }
    }
    
    @objc func toogleButtonTapped(_ sender: UISwitch) {
        
        storeEventItems.allDay = sender.isOn
        //  storeEventItems.ends = storeEventItems.starts
        createEventTableView.reloadData()
    }
}

extension CreateEventViewController: CustomUIPickerDelegate {
    
    // MARK: 1 => Starts, 2 => Ends, 3 => Repeat, 4 => Alert
    
    //text picker
    func customPicker(_ pickerarray: [String],_ tag: Int) {
        picker.delegate = self
        picker.config.animationDuration = 0.25
        picker.config.pickerArray = pickerarray
        picker.config.pickerTag = tag
        
        switch tag {
            
        case 3:
            if storeEventItems.repeatEvent == nil || storeEventItems.repeatEvent == "" {
                picker.config.selectedRow = 1
            } else {
                picker.config.selectedRow = pickerarray.firstIndex(of: storeEventItems.repeatEvent ?? "")
            }
            picker.show(inVC: self)
            
        case 4:
            if storeEventItems.alertEvent == nil || storeEventItems.alertEvent == "" {
                picker.config.selectedRow = 1
            } else {
                picker.config.selectedRow = pickerarray.firstIndex(of: storeEventItems.alertEvent ?? "")
            }
            picker.show(inVC: self)
            
        default:
            print(" \n customPicker default \n")
        }
    }
    
    func customPicker(_ amPicker: CustomUIPicker, didSelect row: Int, value: String, tag: Int, sectiontag: Int) {
        
        switch tag {
            
        case 3: storeEventItems.repeatEvent = value
        createEventTableView.reloadData()
            
        case 4: storeEventItems.alertEvent = value
        createEventTableView.reloadData()
        default:
            print(" default customPicker ")
        }
    }
    
    func customPickerDidCancelSelection(_ amPicker: CustomUIPicker) {
        print("cancel")
    }
}

extension CreateEventViewController: CustomDateTimePickerDelegate {
    
    // MARK: 1 => Starts, 2 => Ends, 3 => Repeat, 4 => Alert
    
    //datetime picker
    func customDateTimePicker(_ tag: Int) {
        
        dateTime.delegate = self
        dateTime.config.animationDuration = 0.25
        dateTime.config.pickerTag = tag
        
        if storeEventItems.allDay {
            dateTime.dateTimePicker.datePickerMode = .date
        } else {
            dateTime.dateTimePicker.datePickerMode = .dateAndTime
        }
        
        var components: DateComponents = DateComponents()
        
        switch tag {
            
        case 1:
            components.year = -20
            if let miniDate = Calendar.current.date(byAdding: components, to: Date()) {
                dateTime.config.minimumDate = miniDate
            }
            
            dateTime.config.startDate = storeEventItems.starts?.toDate(.dd_MMM_yyyy_hhmm_a)
            
            components.year = 20
            if let maxDate = Calendar.current.date(byAdding: components, to: Date()) {
                dateTime.config.maximumDate = maxDate
            }
            
        case 2:
            
            dateTime.config.minimumDate = storeEventItems.starts?.toDate(.dd_MMM_yyyy_hhmm_a)
            
            dateTime.config.startDate = storeEventItems.ends?.toDate(.dd_MMM_yyyy_hhmm_a)
            
            components.year = 20
            if let maxDate = Calendar.current.date(byAdding: components, to: Date()) {
                dateTime.config.maximumDate = maxDate
            }
        default:
            print(" default customDateTimePicker ")
        }
        dateTime.show(inVC: self)
    }
    
    func customPicker(_ amDateTimePicker: CustomDateTimePicker, didSelect date: Date, tag: Int, sectiontag: Int) {
        
        switch tag {
            
        case 1: storeEventItems.starts = date.toString(.dd_MMM_yyyy_hhmm_a)
        if (storeEventItems.ends?.toDate(.dd_MMM_yyyy_hhmm_a) ?? Date() <= date) {
            storeEventItems.ends = storeEventItems.starts
        }
        createEventTableView.reloadData()
            
        case 2: storeEventItems.ends = date.toString(.dd_MMM_yyyy_hhmm_a)
        createEventTableView.reloadData()
        default:
            print(" default customPicker ")
        }
        createEventTableView.reloadData()
    }
    
    func customPickerDidCancelSelection(_ amDateTimePicker: CustomDateTimePicker) {
        print("datetime cancel")
    }
}

extension CreateEventViewController: UITextFieldDelegate {
    
    // MARK: 1 => Title, 2 => Location
    
    @objc func textFieldChanged(_ textField: UITextField) {
        
        switch textField.tag {
            
        case 1: storeEventItems.titleName = textField.text
            //createEventTableView.reloadData()
            
        case 2: storeEventItems.location = textField.text
        //createEventTableView.reloadData()
        default:
            print(" default textFieldChanged ")
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
            
        case 1: storeEventItems.titleName = textField.text
            //createEventTableView.reloadData()
            
        case 2: storeEventItems.location = textField.text
        //createEventTableView.reloadData()
        default:
            print(" default textFieldChanged ")
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
            
        case 1: storeEventItems.titleName = ""
            //createEventTableView.reloadData()
            
        case 2: storeEventItems.location = ""
        //createEventTableView.reloadData()
        default:
            print(" default textFieldChanged ")
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

extension CreateEventViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count < 1 {
            textView.placeholder = "Description"
            storeEventItems.description = nil
        } else {
            textView.placeholder = ""
            storeEventItems.description = textView.text
        }
        
        //dynamically expanding the textView
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        // Disabling animations gives us our desired behaviour
        UIView.setAnimationsEnabled(false)
        
        /* These will causes table cell heights to be recaluclated,
         without reloading the entire cell */
        createEventTableView.beginUpdates()
        createEventTableView.endUpdates()
        
        // Re-enable animations
        UIView.setAnimationsEnabled(true)
    }
    
    //restrict the description and final outcome
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //        guard let text = textView.text else { return true }
        //        let newLength = text.count
        
        return textView.text.removingBlankSpaces().count + (text.count - range.length) <= 100
    }
}
