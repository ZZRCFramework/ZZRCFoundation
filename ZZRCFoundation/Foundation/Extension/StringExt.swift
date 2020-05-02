//
//  String+TCZ.swift
//  Dormouse
//
//  Created by tczy on 2017/8/11.
//  Copyright © 2017年 WangSuyan. All rights reserved.
//

import UIKit
import Foundation
import CommonCrypto


public extension String {
    
    /// 字符长度
    var length: Int {
        return self.utf16.count
    }
    
    /// 检查是否空白
    var isBlank: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    ///去空格换行
    mutating func trim() {
        self = self.trimmed()
    }
    
    /// string字数
    var countofWords: Int {
        let regex = try? NSRegularExpression(pattern: "\\w+", options: NSRegularExpression.Options())
        return regex?.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: self.length)) ?? 0
    }
    
    /// 去空格换行 返回新的字符串
    func trimmed() -> String {
        return self.removeAllSapce.removeAllLine.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    var removeAllLine: String {
        return self.replacingOccurrences(of: "\n", with: "")
    }
    
    ///  json 字符转字典
    func toDictionary() -> [String:AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                Print(error)
            }
        }
        return nil
    }
    
    /// String to Int
    func toInt() -> Int {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return 0
        }
    }
    
    func toInt64() -> Int64 {
        if let num = NumberFormatter().number(from: self) {
            return num.int64Value
        } else {
            return 0
        }
    }
    
    /// String to Double
    func toDouble() -> Double {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return 0.0
        }
    }
    
    /// String to Float
    func toFloat() -> Float {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return 0
        }
    }
    
    /// String to Amount  ¥10,000
    func toAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        if let num =  NumberFormatter().number(from: self), let result = formatter.string(from: num) {
            return result
        }
        return self
    }
    
    /// String to Bool
    func toBool() -> Bool {
        let trimmedString = trimmed().lowercased()
        if trimmedString == "true" || trimmedString == "false" {
            return (trimmedString as NSString).boolValue
        }
        return false
    }
    
    ///  String to NSString
    var toNSString: NSString { return self as NSString }
    
    //最后一个分割
    var lastPathComponent: String {
        return self.components(separatedBy: "/").last ?? ""
    }
    
    // ext
    var pathExtension: String {
        return self.components(separatedBy: ".").last ?? ""
    }
    
    // 截取字符串
    func substring(from index: Int) -> String {
        if self.length > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            return String(subString)
        } else {
            return ""
        }
    }
    
    func subString(from: Int, to: Int) -> String {
        if self.length > from && self.length >= to && to > from {
//            let startIndex = self.index(self.startIndex, offsetBy: from)
//            let endIndex = self.index(self.startIndex, offsetBy: to)
//            let subString = self[startIndex..<endIndex]
//            return String(subString)
            return (self as NSString).substring(with: NSMakeRange(from, to - from))
        }
        return ""
    }
    
    func subString(to: Int) -> String {
        if to > self.length {return self}
        if to <= 0 {return ""}
        let startIndex = self.startIndex
        let endIndex = self.index(self.startIndex, offsetBy: to)
        let subString = self[startIndex..<endIndex]
        return String(subString)
    }
    
    //  let range = Range(uncheckedBounds: (1, 3))

    func subString(range: Range<Int>) -> String {
        if range.endIndex > self.count {
            return ""
        }
        return self.subString(from: range.startIndex, to: range.endIndex)
    }
    
    //获取所有字符串中包含的所有 特定字符串的 range
    func rangesOfString(_ subString: String) -> [NSRange] {
        var ranges = [NSRange]()
        if self.length > 0 {
            for index in 0...self.length - 1 {
                let tempString = self.subString(from: index, to: index + subString.length)
                if tempString == subString {
                    let range = NSMakeRange(index, subString.length)
                    ranges.append(range)
                }
            }
        }
        return ranges
    }
    
    func rangeOfString(_ subString: String) -> NSRange {
        let selfNS = self.toNSString
        return selfNS.range(of: subString)
    }
    /**
     正则表达式获取目的值
     - parameter pattern: 一个字符串类型的正则表达式
     - parameter str: 需要比较判断的对象
     - imports: 这里子串的获取先转话为NSString的[以后处理结果含NS的还是可以转换为NS前缀的方便]
     - returns: 返回目的字符串结果值数组(目前将String转换为NSString获得子串方法较为容易)
     - warning: 注意匹配到结果的话就会返回true，没有匹配到结果就会返回false
     */
    static func regexGetSub(pattern:String, str:String) -> [String] {
        var subStr = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options:[NSRegularExpression.Options.caseInsensitive])
        let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, str.length))
        //解析出子串
        for  rst in results {
            let nsStr = str as  NSString  //可以方便通过range获取子串
            subStr.append(nsStr.substring(with: rst.range))
            //str.substring(with: Range<String.Index>) //本应该用这个的，可以无法直接获得参数，必须自己手动获取starIndex 和 endIndex作为区间
        }
        return subStr
    }
    
    ///字符串高度
    func height(_ width: CGFloat, font: UIFont, lineBreakMode: NSLineBreakMode?) -> CGFloat {
        var attrib: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: font]
        if lineBreakMode != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode!
            attrib.updateValue(paragraphStyle, forKey: NSAttributedString.Key.paragraphStyle)
        }
        let size = CGSize(width: width, height: CGFloat(Double.greatestFiniteMagnitude))
        return ceil((self as NSString).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:attrib, context: nil).height)
    }
    
    //获取富文本的高度
    func stringHeightWith(font: UIFont,width:CGFloat,lineSpace : CGFloat) -> CGFloat{
        
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.lineBreakMode = .byTruncatingTail;
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle:paragraphStyle]
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
    /// MD5
    ///
    /// - Returns: MD5
    func md5() -> String {
        if self.length == 0 {
            return ""
        }
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate()
        return String(format: hash as String)
    }
    
    
    /// 是否为正确的是手机号
    ///
    /// - Parameter phone: 手机号
    /// - Returns: 是否正确
    func isValidPhone() -> Bool{
        let str = "^1+[3456789]+\\d{9}"
        let mobilePredicate = NSPredicate(format: "SELF MATCHES %@",str)
        return mobilePredicate.evaluate(with: self)
    }
    
    func isValidEmail() -> Bool {
        let str = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let mobilePredicate = NSPredicate(format: "SELF MATCHES %@",str)
        return mobilePredicate.evaluate(with: self)
    }
    
    func isValidNick() -> Bool {
       return self.length <= 12
    }
    
    func isValidPassword() -> Bool {
        if self.length < 6 || self.length > 20 {
            return false
        }
        
        let passwordRegex = "^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,20}"
        let predicate = NSPredicate(format: "SELF MATCHES%@", passwordRegex)
        
        return predicate.evaluate(with : self)
    }
    
    /// 千分符 1，000格式
    ///
    /// - Parameter str: 数字
    /// - Returns: 1，000
    static func calcuteSymbolLocation(str: String) -> String {
    
        var resultStr = str
        
        let symbolStr = "."
        
        let subRange = (resultStr as NSString).range(of: symbolStr)
        
        
        if subRange.location == 4  || subRange.location == 5 {
            
            resultStr.insert(",", at: str.index(resultStr.startIndex, offsetBy: 1))
        }
        
        return resultStr
        
    }
    
    /// 清除字符串小数点末尾的0
    func cleanDecimalPointZear() -> String {
        let newStr = self as NSString
        var s = NSString()
        
        var offset = newStr.length - 1
        while offset > 0 {
            s = newStr.substring(with: NSMakeRange(offset, 1)) as NSString
            if s.isEqual(to: "0") || s.isEqual(to: ".") {
                offset -= 1
            } else {
                break
            }
        }
        return newStr.substring(to: offset + 1)
    }
    
    // MARK:- 给证件号、手机号添加***替换
    // 比如 18369901234 -> 18****1234
    func cipherNumber() -> String {
        if self.length < 11 { return "" }
        var ciper = self
        let startIndex = ciper.index(ciper.startIndex, offsetBy: 3)
        let endIndex = ciper.index(ciper.endIndex, offsetBy: -5)
        
        var replaceStr = ""
        for _ in 0...(self.length - 8) {
            replaceStr.append("*")
        }
        ciper.replaceSubrange(startIndex...endIndex, with: replaceStr)
        return ciper
    }
    
    func cipherName() -> String {
        if self.length < 2 { return "*" }
        let ciper = "*" + String(self.last!)
        return ciper
    }
    
    
    // 比如 FF32424 -> F****4
    func cipherPassportNumber() -> String? {
        if self.length < 2 { return nil }
        var ciper = self
        let startIndex = ciper.index(ciper.startIndex, offsetBy: 1)
        let endIndex = ciper.index(ciper.endIndex, offsetBy: -2)
        
        var replaceStr = ""
        for _ in 0...(self.length - 3) {
            replaceStr.append("*")
        }
        ciper.replaceSubrange(startIndex...endIndex, with: replaceStr)
        return ciper
    }
    
    /// 判断是否为合法的身份证号
    ///
    /// - Parameter sfz: 身份证
    /// - Returns: 是否合法
    var isValidateIDCardNumber: Bool {
        let value = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        var length = 0
        if value == "" {
            return false
        }else{
            length = value.length
            if length != 15 && length != 18 {
                return false
            }
        }
        
        //省份代码
        let arearsArray = ["11","12", "13", "14",  "15", "21",  "22", "23",  "31", "32",  "33", "34",  "35", "36",  "37", "41",  "42", "43",  "44", "45",  "46", "50",  "51", "52",  "53", "54",  "61", "62",  "63", "64",  "65", "71",  "81", "82",  "91"]
        let valueStart2 = value.subString(to: 2)
        var arareFlag = false
        
        if arearsArray.contains(valueStart2) {
            
            arareFlag = true
        }
        if !arareFlag{
            return false
        }
        
        var regularExpression = NSRegularExpression()
        var numberofMatch = Int()
        var year = 0
        
        switch (length) {
        case 15:
            year = Int((value as NSString).substring(with: NSRange(location:6,length:2)))!
            if year%4 == 0 || (year%100 == 0 && year%4 == 0){
                do{
                    regularExpression = try NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$", options: .caseInsensitive) //检测出生日期的合法性
                    
                }catch{
                    return false
                }
                
                
            }else{
                do{
                    regularExpression =  try NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$", options: .caseInsensitive) //检测出生日期的合法性
                    
                }catch{
                    return false
                }
            }
            
            numberofMatch = regularExpression.numberOfMatches(in: value, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, value.length))
            
            if(numberofMatch > 0) {
                return true
            }else {
                return false
            }
            
        case 18:
            year = Int((value as NSString).substring(with: NSRange(location:6,length:4)))!
            if year%4 == 0 || (year%100 == 0 && year%4 == 0){
                do{
                    regularExpression = try NSRegularExpression.init(pattern: "^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$", options: .caseInsensitive) //检测出生日期的合法性
                    
                }catch{
                    return false
                }
            }else{
                do{
                    regularExpression =  try NSRegularExpression.init(pattern: "^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$", options: .caseInsensitive) //检测出生日期的合法性
                    
                }catch{
                    return false
                }
            }
            
            numberofMatch = regularExpression.numberOfMatches(in: value, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, value.length))
            
            if(numberofMatch > 0) {
                let s =
                    (Int((value as NSString).substring(with: NSRange(location:0,length:1)))! +
                        Int((value as NSString).substring(with: NSRange(location:10,length:1)))!) * 7 +
                        (Int((value as NSString).substring(with: NSRange(location:1,length:1)))! +
                            Int((value as NSString).substring(with: NSRange(location:11,length:1)))!) * 9 +
                        (Int((value as NSString).substring(with: NSRange(location:2,length:1)))! +
                            Int((value as NSString).substring(with: NSRange(location:12,length:1)))!) * 10 +
                        (Int((value as NSString).substring(with: NSRange(location:3,length:1)))! +
                            Int((value as NSString).substring(with: NSRange(location:13,length:1)))!) * 5 +
                        (Int((value as NSString).substring(with: NSRange(location:4,length:1)))! +
                            Int((value as NSString).substring(with: NSRange(location:14,length:1)))!) * 8 +
                        (Int((value as NSString).substring(with: NSRange(location:5,length:1)))! +
                            Int((value as NSString).substring(with: NSRange(location:15,length:1)))!) * 4 +
                        (Int((value as NSString).substring(with: NSRange(location:6,length:1)))! +
                            Int((value as NSString).substring(with: NSRange(location:16,length:1)))!) *  2 +
                        Int((value as NSString).substring(with: NSRange(location:7,length:1)))! * 1 +
                        Int((value as NSString).substring(with: NSRange(location:8,length:1)))! * 6 +
                        Int((value as NSString).substring(with: NSRange(location:9,length:1)))! * 3
                
                let Y = s%11
                var M = "F"
                let JYM = "10X98765432"
                
                M = (JYM as NSString).substring(with: NSRange(location:Y,length:1))
                if M == (value as NSString).substring(with: NSRange(location:17,length:1))
                {
                    return true
                }else{return false}
                
                
            }else {
                return false
            }
            
        default:
            return false
        }
    }
    
    /// 转换为时间显示  00:00
    ///
    /// - Returns: 1
    func timeShow() -> String {
        let time = self.toInt()
        return timeFormat(time: time)
    }
    
    private func timeFormat(time: Int) -> String {
        return transformTimeStr(time: (time % 3600) / 60) + ":" + transformTimeStr(time:(time) % 60)
    }
    
    private func transformTimeStr(time: Int) -> String{
        if time > 9 {
            return String(time)
        }else{
            return "0" + String(time)
        }
    }
    
    
    /// 时间戳转YYYY-MM-dd
    ///
    /// - Returns: 时间
    func timeStampToDate() -> String{
        let date = Date(timeIntervalSince1970: self.toDouble()/1000)
        return date.getpointDate()
    }
    
    func timeStampToMMDD() -> String {
        let date = Date(timeIntervalSince1970: self.toDouble()/1000)
        return date.getMMDD()
    }
    
    /// 时间戳转YYYY-MM-dd
    ///
    /// - Returns: 时间
    func toDate() -> Date {
        var date: Date?
        if self.toDouble() > 0 {
            date = Date(timeIntervalSince1970: self.toDouble()/1000)
        }
        else {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd"
            date = formatter.date(from: self)
        }
        return date ?? Date()
    }
    
    
    /// 根据固定的size和font计算文字的rect
    ///
    /// - Parameters:
    /// - font: 文字的字体大小
    /// - size: 文字限定的宽高(计算规则:计算宽度, 传入一个实际的高度, 用于计算的宽度则取计算单位的最大值)
    /// - Returns: 返回的CGRect
    func rect(with font: UIFont, size: CGSize) -> CGRect {
        return (self as NSString).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    }
    
    /// 根据固定的size和font计算文字的height
    func height(with font: UIFont, size: CGSize) -> CGFloat {
        return self.rect(with: font, size: size).height
    }
    /// 根据固定的size和font计算文字的width
    func width(with font: UIFont, size: CGSize) -> CGFloat {
        return self.rect(with: font, size: size).width
    }
    
    
    /// 时间戳转 几秒前
    ///
    /// - Returns: 1
    func toTimeLast() -> String {
        var result = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MM dd HH:mm:ss Z yyyy"
        formatter.locale = Locale(identifier: "en")
        
        let createDate = Date(timeIntervalSince1970: self.toDouble()/1000.0) //创建一个日历类
        let calendar = Calendar.current
        var formatterSr = "HH:mm"
        
        if calendar.isDateInToday(createDate) { //今天
            let interval = Int(NSDate().timeIntervalSince(createDate))  //比较两个时间的差值
            if interval < 60 {
                result = "刚刚".localized
            }else if interval < 60 * 60 {
                result = "\(interval/60)" + "分钟前".localized
            }else if interval < 60 * 60 * 24 {
                result = "\(interval / (60 * 60))" + "小时前".localized
            }
        }else if calendar.isDateInYesterday(createDate) {  //昨天
            formatter.dateFormat = formatterSr
            result = "昨天".localized + formatter.string(from: createDate)
        }else {
            //该方法可以获取两个时间之间的差值
            let comps = calendar.dateComponents([Calendar.Component.year], from: createDate, to: Date())
            if comps.year! >= 1 {  //更早时间
                formatterSr = "yyyy-MM-dd " + formatterSr
            }else { //一年以内
                formatterSr = "MM-dd " + formatterSr
            }
            
            formatter.dateFormat = formatterSr
            result = formatter.string(from: createDate)
        }
        return result
    }
    
    func toTimeHour() -> String {
        var result = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MM dd HH:mm:ss Z yyyy"
        formatter.locale = Locale(identifier: "en")
        
        let createDate = Date(timeIntervalSince1970: self.toDouble()/1000.0) //创建一个日历类
        let formatterSr = "HH:mm"
        formatter.dateFormat = formatterSr
        result = formatter.string(from: createDate)
        return result
    }
    
    /// 生成随机字符串
    ///
    /// - Parameter length: 随机字符串的长度
    /// - Returns: 字符串
    static func randomStr(length: Int = 16) -> String {
        let characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var ranStr = ""
        for _ in 0...(length - 1) {
            let index = Int(arc4random_uniform(UInt32(characters.length)))
            ranStr.append(characters.subString(from: index, to: index + 1))
        }
        return ranStr
    }
    
    
    // MARK:- 判断是不是纯数字
    func isPureNumber() -> Bool {
        let regex = "^[0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES%@", regex)
        
        return predicate.evaluate(with: self)
    }
    
    var localized: String {
        return self
//        return Bundle.rmLocalizedString(key: self)
    }
    
    /// 获取随机字符串
    /// Returns a string created from the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
    static func randomString() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}

public extension Array where Element == UInt8 {
    var hexString: String {
        return self.compactMap { String(format: "%02x", $0).uppercased() }
            .joined(separator: "")
    }
}

public extension String.StringInterpolation {
    /// 提供 `Optional` 字符串插值
    /// 而不必强制使用 `String(describing:)`
    /// 可选值插值样式
    enum OptionalStyle {
        /// 有值和没有值两种情况下都包含单词 `Optional`
        case descriptive
        /// 有值和没有值两种情况下都去除单词 `Optional`
        case stripped
        /// 使用系统的插值方式，在有值时包含单词 `Optional`，没有值时则不包含
        case `default`
    }
    
    /// 使用提供的 `optStyle` 样式来插入可选值
    mutating func appendInterpolation<T>(_ value: T?, optStyle style: String.StringInterpolation.OptionalStyle) {
        switch style {
        // 有值和没有值两种情况下都包含单词 `Optional`
        case .descriptive:
            if value == nil {
                appendLiteral("Optional(nil)")
            } else {
                appendLiteral(String(describing: value))
            }
        // 有值和没有值两种情况下都去除单词 `Optional`
        case .stripped:
            if let value = value {
                appendInterpolation(value)
            } else {
                appendLiteral("nil")
            }
        // 使用系统的插值方式，在有值时包含单词 `Optional`，没有值时则不包含
        default:
            appendLiteral(String(describing: value))
        }
    }
    
    /// 使用 `stripped` 样式来对可选值进行插值
    /// 有值和没有值两种情况下都省略单词 `Optional`
    mutating func appendInterpolation<T>(_ value: T?) {
        appendInterpolation(value, optStyle: .stripped)
    }
}
