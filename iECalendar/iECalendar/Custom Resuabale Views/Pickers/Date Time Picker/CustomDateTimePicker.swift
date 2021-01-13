//
//  CustomDateTimePicker.swift
//  iECalendar
//

import UIKit

protocol CustomDateTimePickerDelegate: class {
    func customPicker(_ amDateTimePicker: CustomDateTimePicker, didSelect date: Date, tag: Int, sectiontag: Int)
    func customPickerDidCancelSelection(_ amDateTimePicker: CustomDateTimePicker)
}

class CustomDateTimePicker: UIView {

    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toolBar: UIView!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss()
        delegate?.customPickerDidCancelSelection(self)
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        dismiss()
        
        config.startDate = dateTimePicker.date
        delegate?.customPicker(self, didSelect: dateTimePicker.date, tag: config.pickerTag, sectiontag: config.pickerSectionTag)
    }
    
    // MARK: - Config
    struct Config {
        
        fileprivate let contentHeight: CGFloat = 250
        fileprivate let bouncingOffset: CGFloat = 20
        
        var confirmButtonTitle = "Confirm"
        var cancelButtonTitle = "Cancel"
        
        var pickerArray = [String]()
        var selectedRow:Int?
        var rowHeight:Int?
        var animationDuration: TimeInterval = 0.3
        var pickerSectionTag = 0 //(if multiple pickers are used in many sections)
        var pickerTag = 0
        
        var headerBackgroundColor: UIColor = UIColor(netHex: 0xF4F4F4)
        var confirmButtonColor: UIColor = UIColor.iECalendarColor
        var cancelButtonColor: UIColor = UIColor.iECalendarColor
        var overlayBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.4)
        
        var startDate: Date?
        var minimumDate: Date?
        var maximumDate: Date?
    }
    
    var config = Config()
    weak var delegate: CustomDateTimePickerDelegate?
    var bottomConstraint: NSLayoutConstraint!
    var overlayButton = UIButton()
    var pickerValue:String?
    var pickerRow:Int?
    
    // MARK: - Init
    static func getFromNib() -> CustomDateTimePicker {
        self.superclass()
        return UINib.init(nibName: String(describing: self), bundle: nil).instantiate(withOwner: self, options: nil).last as! CustomDateTimePicker
    }
    
    // MARK: - Private
    fileprivate func setup(_ parentVC: UIViewController) {
        confirmButton.setTitle(config.confirmButtonTitle, for: UIControl.State())
        confirmButton.setTitleColor(config.confirmButtonColor, for: UIControl.State())
        
        cancelButton.setTitle(config.cancelButtonTitle, for: UIControl.State())
        cancelButton.setTitleColor(config.cancelButtonColor, for: UIControl.State())
        
        // Loading configuration
        if let startDate = config.startDate {
            dateTimePicker.date = startDate
        }
        
        toolBar.backgroundColor = config.headerBackgroundColor
        dateTimePicker.minimumDate = config.minimumDate
        dateTimePicker.maximumDate = config.maximumDate
        
        // Overlay view constraints setup
        overlayButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        overlayButton.backgroundColor = config.overlayBackgroundColor
        overlayButton.alpha = 0
        
        overlayButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        
        if !overlayButton.isDescendant(of: parentVC.view) { parentVC.view.addSubview(overlayButton) }
        
        overlayButton.translatesAutoresizingMaskIntoConstraints = false
        
        parentVC.view.addConstraints([
            NSLayoutConstraint(item: overlayButton, attribute: .bottom, relatedBy: .equal, toItem: parentVC.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: overlayButton, attribute: .top, relatedBy: .equal, toItem: parentVC.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: overlayButton, attribute: .leading, relatedBy: .equal, toItem: parentVC.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: overlayButton, attribute: .trailing, relatedBy: .equal, toItem: parentVC.view, attribute: .trailing, multiplier: 1, constant: 0)
            ]
        )
        
        // Setup picker constraints
        frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: config.contentHeight)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: parentVC.view, attribute: .bottom, multiplier: 1, constant: 0)
        
        if !isDescendant(of: parentVC.view) { parentVC.view.addSubview(self) }
        
        parentVC.view.addConstraints([
            bottomConstraint,
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: parentVC.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: parentVC.view, attribute: .trailing, multiplier: 1, constant: 0)
            ]
        )
        addConstraint(
            NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: frame.height)
        )
        move(goUp: false)
    }
    
    fileprivate func move(goUp: Bool) {
        bottomConstraint.constant = goUp ? config.bouncingOffset : config.contentHeight
    }
    
    // MARK: - Public
    func show(inVC parentVC: UIViewController, completion: (() -> ())? = nil) {
        parentVC.view.endEditing(true)
        
        setup(parentVC)
        move(goUp: true)
        
        UIView.animate(
            withDuration: config.animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseIn, animations: {
                
                parentVC.view.layoutIfNeeded()
                self.overlayButton.alpha = 1
                
        }, completion: { (finished) in
            completion?()
        }
        )
        
    }
    
    // MARK: - Dismiss
    func dismiss(_ completion: (() -> ())? = nil) {
        
        move(goUp: false)
        
        UIView.animate(
            withDuration: config.animationDuration, animations: {
                
                self.layoutIfNeeded()
                self.overlayButton.alpha = 0
                
        }, completion: { (finished) in
            completion?()
            self.removeFromSuperview()
            self.overlayButton.removeFromSuperview()
        }
        )
    }
}



