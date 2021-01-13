//
//  Extensions.swift
//  iECalendar
//

import UIKit

// MARK: ----------- UIImage ------------
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: ----------- UIView ------------
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

// MARK: ----------- String ------------
extension String {
    
    var parseJSONString: Any? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        guard let jsonData = data else { return nil }
        do { return try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) }
        catch { return nil }
    }
    
    func getGivenName(_ fromName:String) -> String {
        
        let fullNameArr = fromName.split{$0 == " "}.map(String.init)
        
        var nameStr = ""
        if (fullNameArr[0].count + fullNameArr[1].count) > 15{
            nameStr = fullNameArr[0] + " ..."
        } else {
            nameStr = fullNameArr[0] +  fullNameArr[1]
            
        }
        return nameStr
    }
    
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func removingBlankSpaces() -> String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    func removeUnwantedCharaters() -> String{
        return components(separatedBy: ["@","!","$","#","%","^","&","(",")","*","~","`",":",";","'"]).joined()
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined(separator: "_")
    }
    
    var length: Int {
        return utf16.count
    }
    
    //string to image
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func hideMidChars() -> String {
        return String(self.enumerated().map { index, char in
            return [0, 1, self.count - 1, self.count - 2].contains(index) ? char : "*"
        })
    }
    
    //utc to current zone date in string format
    func UTCToStandardFormat() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let tempDateTime = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        
        if tempDateTime != nil {
            return dateFormatter.string(from: tempDateTime!)
        }
        return nil
    }
    
    //utc to current zone date
    func UTCToCurrentZoneDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let tempDateTime = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        return tempDateTime
    }
    
    //insert character between string
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}

// MARK: ----------- Int ------------
extension Int {
    
    //get standard date format 1-1-2020 1:22 pm in string format
    func getStandardDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        let recvdMsgEpochTime = Int64(self)
        let timeInterMsgEpochTime = TimeInterval(recvdMsgEpochTime)
        let recvdmsgLocalDateTime = Date(timeIntervalSince1970: timeInterMsgEpochTime)
        return dateFormatter.string(from: recvdmsgLocalDateTime)
    }
    
    //get standard date format 1-1-2020 1:22 pm in date format
    func getStandardDateFormatInDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        let recvdMsgEpochTime = Int64(self)
        let timeInterMsgEpochTime = TimeInterval(recvdMsgEpochTime)
        return Date(timeIntervalSince1970: timeInterMsgEpochTime)
    }
}

// MARK: ----------- URL ------------
extension URL {
    
    //get the file extension
    func getPathExtension() -> String {
        let fullNameArr = String(describing: self).components(separatedBy: "/")
        let fileNamee = fullNameArr.last.flatMap { $0 }?.removeUnwantedCharaters()
        let pathExtensionArr = fileNamee?.components(separatedBy: ".")
        return pathExtensionArr?.last?.lowercased() ?? ""
    }
}

// MARK: ----------- Date ------------
extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded()) 
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    //duration from start and end date
    func offsetFrom(date : Date) -> String {
        
        let difference = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: self);
        
        var seconds = ""
        var minutes = ""
        var hours = ""
        var days = ""
        
        if difference.second ?? 0 > 0 {
            seconds = "\(difference.second ?? 0)sec"
        }
        
        if difference.minute ?? 0 > 0 {
            
            if difference.second ?? 0 > 0 {
                minutes = "\(difference.minute ?? 0)min" + " " + seconds
            } else {
                minutes = "\(difference.minute ?? 0)min"
            }
        }
        
        if difference.hour ?? 0 > 0 {
            
            if difference.minute ?? 0 > 0 {
                hours = "\(difference.hour ?? 0)hr" + " " + minutes
            } else {
                hours = "\(difference.hour ?? 0)hr"
            }
        }
        
        if difference.day ?? 0 > 0 {
            
            if difference.hour ?? 0 > 0 {
                days = "\(difference.day ?? 0)day(s)" + " " + hours
            } else {
                days = "\(difference.day ?? 0)day(s)"
            }
        }
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
}

// MARK: ----------- UIButton ------------
extension UIButton {
    func leftImage(image: UIImage, renderMode: UIImage.RenderingMode) {
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width / 2)
        self.contentHorizontalAlignment = .left
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func rightImage(image: UIImage, renderMode: UIImage.RenderingMode){
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left:image.size.width / 2, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .right
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func makeMultiLineSupport() {
        guard let titleLabel = titleLabel else {
            return
        }
        //titleLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addConstraints([
            .init(item: titleLabel,
                  attribute: .top,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .top,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.top),
            .init(item: titleLabel,
                  attribute: .bottom,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .bottom,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.bottom),
            .init(item: titleLabel,
                  attribute: .left,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .left,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.left),
            .init(item: titleLabel,
                  attribute: .right,
                  relatedBy: .greaterThanOrEqual,
                  toItem: self,
                  attribute: .right,
                  multiplier: 1.0,
                  constant: contentEdgeInsets.right)
            ])
    }
}

// MARK: ------------- UIViewController ------------
extension UIViewController {

    func removeChild() {
        self.children.forEach {
            print("\n** removeChild $0 =>\($0)**")
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
    }
}

// MARK: -------------- Array --------------
extension Array where Element: Hashable {
    
    //remove duplicates in an array
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

// MARK: -------------- Label --------------
extension UILabel {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}

// MARK: ---------------- TextView ---------------
extension UITextView {
    
    /// ------------ `Text content edge` ------------

    @IBInspectable
     var LeftInsets: CGFloat {
     set { textContainerInset.left = newValue
         setNeedsLayout() }
     get { return textContainerInset.left }
     }

     @IBInspectable
     var RightInsets: CGFloat {
         set { textContainerInset.right = newValue
             setNeedsLayout() }
         get { return textContainerInset.right }
     }

     @IBInspectable
     var TopInsets: CGFloat {
         set { textContainerInset.top = newValue
             setNeedsLayout() }
         get { return textContainerInset.top }
     }

     @IBInspectable
     var BottomInsets: CGFloat {
         set { textContainerInset.bottom = newValue
             setNeedsLayout() }
         get { return textContainerInset.bottom }
     }
}
