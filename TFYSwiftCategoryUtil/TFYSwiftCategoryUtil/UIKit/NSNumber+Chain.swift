//
//  NSNumber+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/15.
//

import Foundation

public extension TFY where Base: NSNumber {
    
    enum TFYSwiftOperators:Int {
        case TFYSwiftAdd = 0
        case TFYSwiftMul = 1
        case TFYSwiftSub = 2
        case TFYSwiftDiv = 3
    }
    
    /// 转化为字符串
    func displayCount() -> String {
        if base.doubleValue <= 0 {
            return "0"
        }
        if base.doubleValue < 1000 {
            return base.description
        }
        if base.doubleValue >= 999_999 {
            return "999.9K+"
        }
        let result = base.doubleValue / 1000.0
        let num1 = NSNumber(value: result)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.roundingMode = .down
        numberFormatter.positiveFormat = "#0.0"
        return numberFormatter.string(from: num1)! + "K"
    }
    
    func getResult(oneNumber:NSNumber,type:TFYSwiftOperators,twoNumber:NSNumber) -> Base {
        var resultNum:NSDecimalNumber = NSDecimalNumber()
        let one:NSDecimalNumber = NSDecimalNumber(decimal: oneNumber.decimalValue)
        let two:NSDecimalNumber = NSDecimalNumber(decimal: twoNumber.decimalValue)
        let roundingBehavior:NSDecimalNumberHandler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

        switch type {
        case .TFYSwiftAdd:
            resultNum = one.adding(two, withBehavior: roundingBehavior)
        case .TFYSwiftMul:
            resultNum = one.multiplying(by: two, withBehavior: roundingBehavior)
        case .TFYSwiftSub:
            resultNum = one.subtracting(two, withBehavior: roundingBehavior)
        case .TFYSwiftDiv:
            resultNum = one.dividing(by: two, withBehavior: roundingBehavior)
        }
        return Base(nonretainedObject: resultNum)
    }
    
    ///  无格式,四舍五入
    func changeToumberFormatterNoStyle() -> String {
        return changeStyle(style: .none)
    }
    
    ///小数型,
    func changeToNumberFormatterDecimalStyle() -> String {
        return changeStyle(style: .decimal)
    }
    
    ///货币型,
    func changeToNumberFormatterCurrencyStyle() -> String {
        return changeStyle(style: .currency)
    }
    
    ///百分比型
    func changeToNumberFormatterPercentStyle() -> String {
        return changeStyle(style: .percent)
    }
    
    ///科学计数型,
    func changeToNumberFormatterScientificStyle() -> String {
        return changeStyle(style: .scientific)
    }
    
    ///全拼
    func changeToNumberFormatterSpellOutStyle() -> String {
        return changeStyle(style: .spellOut)
    }
    
    /// 序数
    func changeToNumberFormatterOrdinalStyle() -> String {
        return changeStyle(style: .ordinal)
    }
    
    /// 代码
    func changeToNumberFormatterCurrencyISOCodeStyle() -> String {
        return changeStyle(style: .currencyISOCode)
    }
    
    /// 复数
    func changeToNumberFormatterCurrencyPluralStyle() -> String {
        return changeStyle(style: .currencyPlural)
    }
    
    /// 会计
    func changeToNumberFormatterCurrencyAccountingStyle() -> String {
        return changeStyle(style: .currencyAccounting)
    }
    
    func changeStyle(style:NumberFormatter.Style) -> String {
        let formatter:NumberFormatter = NumberFormatter()
        formatter.numberStyle = style
        return formatter.string(from: base) ?? ""
    }
    
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}

/// ¥###,##0.00
public let kNumFormat = "¥###,##0.00";

//MARK: -NumberFormatter
@objc public extension NumberFormatter{
    
    static func number(_ style: NumberFormatter.Style = .currency) -> NumberFormatter {
        let dic = Thread.current.threadDictionary
        
        let key = "NumberFormatter.Style.RawValue.\(style.rawValue)"
        if let formatter = dic.object(forKey: key) as? NumberFormatter {
            return formatter
        }
        
        let fmt = NumberFormatter()
        fmt.numberStyle = style
        dic.setObject(fmt, forKey: (key as NSString))
        return fmt
    }
    
    /// 数值格式化
    /// - Parameters:
    ///   - style: NumberFormatter.Style
    ///   - minFractionDigits: minimumFractionDigits = 2
    ///   - maxFractionDigits: maximumFractionDigits = 2
    /// - Returns: NumberFormatter
    static func format(_ style: NumberFormatter.Style = .none,
                       minFractionDigits: Int = 2,
                       maxFractionDigits: Int = 2,
                       positivePrefix: String = "¥",
                       groupingSeparator: String = ",",
                       groupingSize: Int = 3) -> NumberFormatter {
        let fmt = NumberFormatter.number(style)
        fmt.minimumIntegerDigits = 1
        fmt.minimumFractionDigits = minFractionDigits
        fmt.maximumFractionDigits = maxFractionDigits

        fmt.positivePrefix = positivePrefix
//        fmt.positiveSuffix = ""

        fmt.usesGroupingSeparator = true //分隔设true
        fmt.groupingSeparator = groupingSeparator //分隔符
        fmt.groupingSize = groupingSize  //分隔位数
        return fmt
    }

    /// format 格式金钱显示
    /// - Parameters:
    ///   - obj: number
    ///   - format: @",###.##"...
    /// - Returns: String?
    static func positiveFormat(_ style: NumberFormatter.Style = .none,
                               obj: CGFloat,
                               format: String = kNumFormat,
                               defalut: String = "-") -> String? {
        let fmt = NumberFormatter.number(style)
        fmt.positiveFormat = format
        return fmt.string(for: obj)
    }
}

public extension String.StringInterpolation {
    /// 插值 NumberFormatter
    mutating func appendInterpolation(_ obj: Any?, fmt: NumberFormatter) {
        guard let value = fmt.string(for: obj) else { return }
        appendLiteral(value)
    }
}


//MARK: -Number
@objc public extension NSNumber {
    
    var decNumer: NSDecimalNumber {
        return NSDecimalNumber(decimal: self.decimalValue)
    }
     
    /// 获取对应的字符串
    func toString(_ max: Int = 2) -> String?{
        let fmt = NumberFormatter.format(.none, minFractionDigits: 1, maxFractionDigits: max, positivePrefix: "", groupingSeparator: "", groupingSize: 3)
        return fmt.string(for: self)
    }
  
}


