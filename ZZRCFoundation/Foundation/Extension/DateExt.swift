//
//  DateExt.swift
//  AFProject
//
//  Created by 田向阳 on 2019/8/2.
//  Copyright © 2019 田向阳. All rights reserved.
//

import Foundation
public extension Date {
    
    /// 根据时间戳转换时间
    ///
    /// - Parameter timeStamp: 时间戳
    /// - Returns: date
    static func dateWithTimeStamp(timeStamp: Double) -> Date {
        var aTimeStamp = timeStamp
        if timeStamp > 140000000000 {
            aTimeStamp = aTimeStamp / 1000
        }
        return Date(timeIntervalSince1970: aTimeStamp)
    }
    
    /// 生成timeStamp
    ///
    /// - Returns: timeStampString
    func timeStamp() -> String {
        let timeStamp = Int64(self.timeIntervalSince1970)
        return String(timeStamp)
    }
    
    /// 获取天数索引
    ///
    /// - Returns: 天数
    func dayIndexSince1970() -> Int {
        let interval = self.changeZone().timeIntervalSince1970
        return Int(interval / Double((24 * 60 * 60)))
    }
    
    /// 获取指定时间距今多少天
    ///
    /// - Returns: 天数
    func dayIndexSinceNow() -> Int {
        return self.dayIndexSinceDate(date: Date())
    }
    
    /// 返回月份的字符串
    ///
    /// - Returns: monthString
    func monthString() -> String {
        let chinaseMonth = ["一月".localized, "二月".localized, "三月".localized, "四月".localized, "五月".localized, "六月".localized, "七月".localized, "八月".localized, "九月".localized, "十月".localized, "十一月".localized, "十二月".localized]
        let monthIndex = self.allDateComponent().month ?? 0
        guard monthIndex < 0, monthIndex > 12 else {
            return chinaseMonth[monthIndex]
        }
        return ""
    }
    
    /// 获取字符串
    ///
    /// - Returns: timeString
    func string() -> String {
        return self.stringWithDateFormat(dateFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    /// 获取不带秒数的字符串
    ///
    /// - Returns: timeString
    func stringWithNoSeconds() -> String {
        return self.stringWithDateFormat(dateFormat: "yyyy-MM-dd HH:mm")
    }
    
    /// //格式化日期 精确到天
    ///
    /// - Returns: date
    func dateAccurateToDay() -> Date? {
        return self.dateAccurate(components: Set(arrayLiteral: .year,.month,.day))
    }
    
    /// 格式化日期 精确到小时
    ///
    /// - Returns: date
    func dateAccurateToHour() -> Date? {
        return self.dateAccurate(components: Set(arrayLiteral: .year,.month,.day,.hour))
    }
    
    
    /// 格式化日期 2018-07-04
    ///
    /// - Returns: 222
    func getpointDate() -> String {
        return self.stringWithDateFormat(dateFormat: "yyyy-MM-dd")
    }
    
    /// 格式化日期 07/04
    ///
    /// - Returns:07/04
    func getMMDD() -> String {
        return self.stringWithDateFormat(dateFormat: "MM/dd")
    }
    
    
    /// 格式化时间
    ///
    /// - Returns: 12:30
    func getHour() -> String {
        return self.stringWithDateFormat(dateFormat: "HH:mm")
    }
    
    static func formatHour(hour: String?) -> Date? {
        guard let `hour` = hour else { return nil }
        let formatter = DateFormatter()
        let current = Date().stringWithNoSeconds()
        let nowTimeString = (current.components(separatedBy: " ").first ?? "") + " " + hour
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: nowTimeString)
    }
    
    func age() -> Int {
        guard self.isValidDate() else {
            return 0
        }
        //出生年月日
        let bornCompontens = self.allDateComponent()
        let bornYear = bornCompontens.year ?? 0
        let bornMonth = bornCompontens.month ?? 0
        let bornDay = bornCompontens.month ?? 0
        
        //系统时间年月日
        let currentDateCompontens = Date().allDateComponent()
        let currentYear = currentDateCompontens.year ?? 0
        let currentMonth = currentDateCompontens.month ?? 0
        let currentDay = currentDateCompontens.day ?? 0
        
        //计算年龄
        var age = currentYear - bornYear - 1
        
        if (currentMonth > bornMonth) || (currentMonth == bornMonth && currentDay >= bornDay) {
            age += 1
        }
        return age
    }
    
}


//MARK:helper
public extension Date {
    
    /// 获取指定时间之间的天数
    ///
    /// - Parameter date: 指定时间
    /// - Returns: 天数
    func dayIndexSinceDate(date: Date) -> Int {
        var days = 0
        let baseBegin = date.dateAccurateToDay()
        let lastBegin = self.dateAccurateToDay()
        guard let aBaseBegin = baseBegin, let aLastBegin = lastBegin else {
            return 0
        }
        days = String(format: ".0f", aLastBegin.timeIntervalSince(aBaseBegin)).toInt()
        return days
    }
    
    /// 按照指定formatter格式化date
    ///
    /// - Parameter dateFormat: formatter 如:yyyy-MM-dd HH:mm:ss
    /// - Returns: timeString
    func stringWithDateFormat(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
    
    /// 格式化日期
    ///
    /// - Parameter components: 精度
    /// - Returns: date
    func dateAccurate(components: Set<Calendar.Component>) -> Date? {
        var current: Date?
        let calendar = NSCalendar.current
        let aComponents = calendar.dateComponents(components, from: self)
        current =  calendar.date(from: aComponents)
        guard let aCurrent = current else {
            return nil
        }
        return aCurrent
    }
    
    //获取components
    func allDateComponent() -> DateComponents {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(Set(arrayLiteral: .year,.month,.day,.hour,.minute,.second,.weekday), from: self)
        return components
    }
    
    //加上时区偏移
    func changeZone() -> Date {
        let zone = NSTimeZone.system
        let interval = zone.secondsFromGMT(for: self as Date)
        return self.addingTimeInterval(TimeInterval(interval))
    }
    
    /// 判断时间是否有效
    ///
    /// - Returns: bool
    func isValidDate() -> Bool {
        //        let bornCompontens = self.allDateComponent()
        //        guard bornCompontens.isValidDate else {
        //            return false
        //        }
        return true
    }
    
    
    func isToday() -> Bool {
        let calendar = Calendar.current
        //当前时间
        let nowComponents = calendar.dateComponents([.day,.month,.year], from: Date() )
        //self
        let selfComponents = calendar.dateComponents([.day,.month,.year], from: self as Date)
        
        return (selfComponents.year == nowComponents.year) && (selfComponents.month == nowComponents.month) && (selfComponents.day == nowComponents.day)
    }
    
    func isYesterday() -> Bool {
        let calendar = Calendar.current
        //当前时间
        let nowComponents = calendar.dateComponents([.day], from: Date() )
        //self
        let selfComponents = calendar.dateComponents([.day], from: self as Date)
        let cmps = calendar.dateComponents([.day], from: selfComponents, to: nowComponents)
        return cmps.day == 1
        
    }
    
    func isSameWeek() -> Bool {
        let calendar = Calendar.current
        //当前时间
        let nowComponents = calendar.dateComponents([.weekdayOrdinal,.weekOfMonth,.weekday,.day,.month,.year], from: Date() )
        //self
        let selfComponents = calendar.dateComponents([.weekdayOrdinal,.weekOfMonth,.weekday,.day,.month,.year], from: self as Date)
        
        return (selfComponents.year == nowComponents.year) && (selfComponents.month == nowComponents.month) && (selfComponents.weekOfMonth == nowComponents.weekOfMonth)
    }
    
    static func converTotimeString(timeInterval: String) -> String {
        //如果服务端返回的时间戳精确到毫秒，需要除以1000,否则不需要
        let date = timeInterval.toDate()
        if date.isToday() {
            //是今天
            return "今天".localized
        }else if date.isYesterday(){
            //是昨天
            return "昨天".localized
        }else if date.isSameWeek(){
            //是同一周
            return "本周".localized
        }else{
            return "更早".localized
        }
    }
    
    static func chatSectionDate(timeInterval: String) -> String {
        let date = timeInterval.toDate()
        if date.isToday() {
            //是今天
            return "今天".localized
        }else if date.isYesterday(){
            //是昨天
            return "昨天".localized
        }else if date.isSameWeek(){
            let weeks = ["星期日".localized,"星期一".localized,"星期二".localized,"星期三".localized,"星期四".localized,"星期五".localized,"星期六".localized];
            //是同一周
            let components = Calendar.current.dateComponents([.weekday], from: date)
            let weekDay = (components.weekday! - 1) == 0 ? 7 : (components.weekday! - 1)
            return weeks.safeObjectAtIndex(index: weekDay) ?? "星期日".localized
        }else{
            return timeInterval.timeStampToDate()
        }
    }
    
    /// 根据本地时区转换
    static func getNowDateFromatAnDate(_ anyDate: Date?) -> Date {
        //设置源日期时区
        let sourceTimeZone = NSTimeZone(abbreviation: "UTC")
        //或GMT
        //设置转换后的目标日期时区
        let destinationTimeZone = NSTimeZone.local as NSTimeZone
        //得到源日期与世界标准时间的偏移量
        var sourceGMTOffset: Int? = nil
        if let aDate = anyDate {
            sourceGMTOffset = sourceTimeZone?.secondsFromGMT(for: aDate)
        }
        //目标日期与本地时区的偏移量
        var destinationGMTOffset: Int? = nil
        if let aDate = anyDate {
            destinationGMTOffset = destinationTimeZone.secondsFromGMT(for: aDate)
        }
        //得到时间偏移量的差值
        let interval = TimeInterval((destinationGMTOffset ?? 0) - (sourceGMTOffset ?? 0))
        //转为现在时间
        var destinationDateNow: Date? = nil
        if let aDate = anyDate {
            destinationDateNow = Date(timeInterval: interval, since: aDate)
        }
        return destinationDateNow!
    }
}

