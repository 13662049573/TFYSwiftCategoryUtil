//
//  TFYExecutionLimitManager.swift
//  TFYSwiftCategoryUtil
//
//  Created by admin on 2025/9/16.
//

import Foundation

// 提取自 ZSUtils.swift 的执行限制管理工具，独立文件便于维护与复用
// 文件内统一的存储键前缀，集中管理，避免硬编码分散（fileprivate 以便同文件内多个 extension 访问）
fileprivate enum ExecutionStorageKeyPrefix {
    static let count = "execution_count_"
    static let times = "execution_times_"
    static let last = "last_execution_"
}

// 线程安全与共享资源
fileprivate enum ExecutionShared {
    static let queue = DispatchQueue(label: "com.zs.utils.executionlimit")
    static let calendar = Calendar.current
    static let dailyFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    static let weeklyFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-'W'ww"; return f
    }()
    static let monthlyFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM"; return f
    }()
    static let yearlyFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy"; return f
    }()
}

public extension TFYUtils {
    /// 执行限制管理器 - 支持每日、每周、每月等不同时间周期
    enum ExecutionLimit {
        /// 时间周期类型
        public enum TimePeriod {
            case daily
            case weekly
            case monthly
            case yearly
            case custom(TimeInterval)
            case everyDays(Int)  // 每N天
            case everyHours(Int) // 每N小时
            case everyMinutes(Int) // 每N分钟
            case everyWeeks(Int) // 每N周
            case everyMonths(Int) // 每N月
            case everyYears(Int) // 每N年

            /// 所有预定义的时间周期（不包含custom和every系列）
            public static var predefinedCases: [TimePeriod] {
                [.daily, .weekly, .monthly, .yearly]
            }

            var description: String {
                switch self {
                case .daily: return "daily"
                case .weekly: return "weekly"
                case .monthly: return "monthly"
                case .yearly: return "yearly"
                case .custom: return "custom"
                case .everyDays(let days): return "every_\(days)_days"
                case .everyHours(let hours): return "every_\(hours)_hours"
                case .everyMinutes(let minutes): return "every_\(minutes)_minutes"
                case .everyWeeks(let weeks): return "every_\(weeks)_weeks"
                case .everyMonths(let months): return "every_\(months)_months"
                case .everyYears(let years): return "every_\(years)_years"
                }
            }
        }

        /// 限制配置
        public struct LimitConfig {
            let maxExecutions: Int
            let timePeriod: TimePeriod
            let minIntervalBetweenExecutions: TimeInterval
            let allowOverflow: Bool

            public init(
                maxExecutions: Int,
                timePeriod: TimePeriod = .daily,
                minIntervalBetweenExecutions: TimeInterval = 1.0,
                allowOverflow: Bool = false
            ) {
                self.maxExecutions = maxExecutions
                self.timePeriod = timePeriod
                self.minIntervalBetweenExecutions = minIntervalBetweenExecutions
                self.allowOverflow = allowOverflow
            }
        }

        private static let userDefaults = UserDefaults.standard

        /// 检查是否可以执行操作
        public static func canExecute(for key: String, with config: LimitConfig) -> Bool {
            let currentTime = Date()
            // 串行化处理，确保一致性
            var result = false
            ExecutionShared.queue.sync {
                result = canExecuteUnified(for: key, with: config, currentTime: currentTime)
            }
            return result
        }

        /// 获取当前周期的剩余执行次数
        public static func remainingExecutions(for key: String, with config: LimitConfig) -> Int {
            let currentTime = Date()
            let countKey = getCountKey(for: key, timePeriod: config.timePeriod, currentTime: currentTime)
            let currentCount = userDefaults.integer(forKey: countKey)
            return max(0, config.maxExecutions - currentCount)
        }

        /// 获取当前周期的执行次数
        public static func currentExecutionCount(for key: String, with config: LimitConfig) -> Int {
            let currentTime = Date()
            let countKey = getCountKey(for: key, timePeriod: config.timePeriod, currentTime: currentTime)
            return userDefaults.integer(forKey: countKey)
        }

        /// 获取当前周期的执行时间列表
        public static func currentExecutionTimes(for key: String, with config: LimitConfig) -> [Date] {
            let currentTime = Date()
            let executionKey = getExecutionKey(for: key, timePeriod: config.timePeriod, currentTime: currentTime)
            return userDefaults.array(forKey: executionKey) as? [Date] ?? []
        }

        /// 重置当前周期的执行次数
        public static func resetCurrentExecution(for key: String, with config: LimitConfig) {
            let currentTime = Date()
            let executionKey = getExecutionKey(for: key, timePeriod: config.timePeriod, currentTime: currentTime)
            let countKey = getCountKey(for: key, timePeriod: config.timePeriod, currentTime: currentTime)

            userDefaults.removeObject(forKey: executionKey)
            userDefaults.removeObject(forKey: countKey)
            // 同步清理 last_execution_ 记录，避免 every* 系列受旧记录影响
            let lastExecutionKey = "\(ExecutionStorageKeyPrefix.last)\(key)"
            userDefaults.removeObject(forKey: lastExecutionKey)
        }

        /// 清理过期的执行记录
        public static func cleanupExpiredRecords() {
            let allKeys = userDefaults.dictionaryRepresentation().keys
            // 只清理日/周/月/年四类周期的历史记录，避免误删 every* 或自定义周期
            let executionKeys = allKeys.filter { $0.hasPrefix(ExecutionStorageKeyPrefix.times) || $0.hasPrefix(ExecutionStorageKeyPrefix.count) }

            let today = Date()
            let currentDaily = ExecutionShared.dailyFormatter.string(from: today)
            let currentWeekly = ExecutionShared.weeklyFormatter.string(from: today)
            let currentMonthly = ExecutionShared.monthlyFormatter.string(from: today)
            let currentYearly = ExecutionShared.yearlyFormatter.string(from: today)

            for key in executionKeys {
                guard let underscoreIndex = key.lastIndex(of: "_") else { continue }
                let periodString = String(key[key.index(after: underscoreIndex)...])

                // 通过长度/内容判断所属周期，仅处理日/周/月/年
                if periodString.count == 10 { // yyyy-MM-dd
                    if periodString != currentDaily { userDefaults.removeObject(forKey: key) }
                } else if periodString.contains("W") { // yyyy-'W'ww
                    if periodString != currentWeekly { userDefaults.removeObject(forKey: key) }
                } else if periodString.count == 7 { // yyyy-MM
                    if periodString != currentMonthly { userDefaults.removeObject(forKey: key) }
                } else if periodString.count == 4, Int(periodString) != nil { // yyyy
                    if periodString != currentYearly { userDefaults.removeObject(forKey: key) }
                } else {
                    // 跳过小时/分钟/自定义/每N* 等，避免误删
                    continue
                }
            }
        }

        // MARK: - 私有辅助方法

        private static func getCountKey(for key: String, timePeriod: TimePeriod, currentTime: Date) -> String {
            let periodString = getPeriodString(for: timePeriod, currentTime: currentTime)
            return "\(ExecutionStorageKeyPrefix.count)\(key)_\(periodString)"
        }

        private static func getExecutionKey(for key: String, timePeriod: TimePeriod, currentTime: Date) -> String {
            let periodString = getPeriodString(for: timePeriod, currentTime: currentTime)
            return "\(ExecutionStorageKeyPrefix.times)\(key)_\(periodString)"
        }

        private static func getPeriodString(for timePeriod: TimePeriod, currentTime: Date) -> String {
            let formatter = DateFormatter()
            let targetDate: Date

            switch timePeriod {
            case .daily:
                formatter.dateFormat = "yyyy-MM-dd"
                targetDate = currentTime
            case .weekly:
                formatter.dateFormat = "yyyy-'W'ww"
                targetDate = currentTime
            case .monthly:
                formatter.dateFormat = "yyyy-MM"
                targetDate = currentTime
            case .yearly:
                formatter.dateFormat = "yyyy"
                targetDate = currentTime
            case .custom:
                formatter.dateFormat = "yyyy-MM-dd-HH"
                targetDate = currentTime
            case .everyDays:
                formatter.dateFormat = "yyyy-MM-dd"
                targetDate = getBaseDate(for: timePeriod, currentTime: currentTime)
            case .everyHours:
                formatter.dateFormat = "yyyy-MM-dd-HH"
                targetDate = getBaseDate(for: timePeriod, currentTime: currentTime)
            case .everyMinutes:
                formatter.dateFormat = "yyyy-MM-dd-HH-mm"
                targetDate = getBaseDate(for: timePeriod, currentTime: currentTime)
            case .everyWeeks:
                formatter.dateFormat = "yyyy-'W'ww"
                targetDate = getBaseDate(for: timePeriod, currentTime: currentTime)
            case .everyMonths:
                formatter.dateFormat = "yyyy-MM"
                targetDate = getBaseDate(for: timePeriod, currentTime: currentTime)
            case .everyYears:
                formatter.dateFormat = "yyyy"
                targetDate = getBaseDate(for: timePeriod, currentTime: currentTime)
            }

            return formatter.string(from: targetDate)
        }

        private static func extractDateFromKey(_ key: String) -> Date? {
            // 从最后一个下划线后截取周期字符串，避免 key 中包含下划线导致解析失败
            guard let underscoreIndex = key.lastIndex(of: "_") else { return nil }
            let dateString = String(key[key.index(after: underscoreIndex)...])
            let formatter = DateFormatter()

            // 尝试不同的日期格式
            let formats = ["yyyy-MM-dd", "yyyy-'W'ww", "yyyy-MM", "yyyy", "yyyy-MM-dd-HH", "yyyy-MM-dd-HH-mm"]

            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) { return date }
            }
            return nil
        }
        
        // MARK: - 统一执行检查方法
        
        /// 统一处理所有时间周期的执行检查
        private static func canExecuteUnified(for key: String, with config: LimitConfig, currentTime: Date) -> Bool {
            // 获取存储键
            let (countKey, executionKey, lastExecutionKey) = getStorageKeys(for: key, timePeriod: config.timePeriod, currentTime: currentTime)
            
            // 获取当前执行次数
            let currentCount = userDefaults.integer(forKey: countKey)
            
            // 检查是否已经达到最大执行次数
            if currentCount >= config.maxExecutions && !config.allowOverflow {
                return false
            }
            
            // 检查时间间隔限制
            if !isTimeIntervalValid(for: key, timePeriod: config.timePeriod, currentTime: currentTime, config: config, lastExecutionKey: lastExecutionKey) {
                return false
            }
            
            // 更新执行记录
            updateExecutionRecord(countKey: countKey, executionKey: executionKey, lastExecutionKey: lastExecutionKey, currentTime: currentTime, currentCount: currentCount)
            
            return true
        }
        
        /// 检查时间间隔是否有效
        private static func isTimeIntervalValid(for key: String, timePeriod: TimePeriod, currentTime: Date, config: LimitConfig, lastExecutionKey: String) -> Bool {
            // 对于every系列，检查是否满足间隔要求
            if case .everyDays(let days) = timePeriod {
                return checkEveryDaysInterval(lastExecutionKey: lastExecutionKey, currentTime: currentTime, days: days, config: config)
            } else if case .everyHours(let hours) = timePeriod {
                return checkEveryHoursInterval(lastExecutionKey: lastExecutionKey, currentTime: currentTime, hours: hours, config: config)
            } else if case .everyMinutes(let minutes) = timePeriod {
                return checkEveryMinutesInterval(lastExecutionKey: lastExecutionKey, currentTime: currentTime, minutes: minutes, config: config)
            } else if case .everyWeeks(let weeks) = timePeriod {
                return checkEveryWeeksInterval(lastExecutionKey: lastExecutionKey, currentTime: currentTime, weeks: weeks, config: config)
            } else if case .everyMonths(let months) = timePeriod {
                return checkEveryMonthsInterval(lastExecutionKey: lastExecutionKey, currentTime: currentTime, months: months, config: config)
            } else if case .everyYears(let years) = timePeriod {
                return checkEveryYearsInterval(lastExecutionKey: lastExecutionKey, currentTime: currentTime, years: years, config: config)
            } else {
                // 对于传统周期，检查最小时间间隔
                return checkMinInterval(executionKey: getExecutionKey(for: key, timePeriod: timePeriod, currentTime: currentTime), currentTime: currentTime, config: config)
            }
        }
        
        /// 检查每N天的时间间隔
        private static func checkEveryDaysInterval(lastExecutionKey: String, currentTime: Date, days: Int, config: LimitConfig) -> Bool {
            guard let lastTime = userDefaults.object(forKey: lastExecutionKey) as? Date else { return true }
            
            let calendar = ExecutionShared.calendar
            let daysSinceLastExecution = calendar.dateComponents([.day], from: lastTime, to: currentTime).day ?? 0
            
            return daysSinceLastExecution >= days && currentTime.timeIntervalSince(lastTime) >= config.minIntervalBetweenExecutions
        }
        
        /// 检查每N小时的时间间隔
        private static func checkEveryHoursInterval(lastExecutionKey: String, currentTime: Date, hours: Int, config: LimitConfig) -> Bool {
            guard let lastTime = userDefaults.object(forKey: lastExecutionKey) as? Date else { return true }
            
            let hoursSinceLastExecution = currentTime.timeIntervalSince(lastTime) / 3600
            
            return hoursSinceLastExecution >= Double(hours) && currentTime.timeIntervalSince(lastTime) >= config.minIntervalBetweenExecutions
        }
        
        /// 检查每N分钟的时间间隔
        private static func checkEveryMinutesInterval(lastExecutionKey: String, currentTime: Date, minutes: Int, config: LimitConfig) -> Bool {
            guard let lastTime = userDefaults.object(forKey: lastExecutionKey) as? Date else { return true }
            
            let minutesSinceLastExecution = currentTime.timeIntervalSince(lastTime) / 60
            
            return minutesSinceLastExecution >= Double(minutes) && currentTime.timeIntervalSince(lastTime) >= config.minIntervalBetweenExecutions
        }
        
        /// 检查每N周的时间间隔
        private static func checkEveryWeeksInterval(lastExecutionKey: String, currentTime: Date, weeks: Int, config: LimitConfig) -> Bool {
            guard let lastTime = userDefaults.object(forKey: lastExecutionKey) as? Date else { return true }
            let weeksSinceLastExecution = currentTime.timeIntervalSince(lastTime) / (7 * 24 * 3600)
            return weeksSinceLastExecution >= Double(weeks) && currentTime.timeIntervalSince(lastTime) >= config.minIntervalBetweenExecutions
        }
        
        /// 检查每N月的时间间隔
        private static func checkEveryMonthsInterval(lastExecutionKey: String, currentTime: Date, months: Int, config: LimitConfig) -> Bool {
            guard let lastTime = userDefaults.object(forKey: lastExecutionKey) as? Date else { return true }
            let comps = Calendar.current.dateComponents([.month], from: lastTime, to: currentTime)
            let diff = comps.month ?? 0
            return diff >= months && currentTime.timeIntervalSince(lastTime) >= config.minIntervalBetweenExecutions
        }
        
        /// 检查每N年的时间间隔
        private static func checkEveryYearsInterval(lastExecutionKey: String, currentTime: Date, years: Int, config: LimitConfig) -> Bool {
            guard let lastTime = userDefaults.object(forKey: lastExecutionKey) as? Date else { return true }
            let comps = Calendar.current.dateComponents([.year], from: lastTime, to: currentTime)
            let diff = comps.year ?? 0
            return diff >= years && currentTime.timeIntervalSince(lastTime) >= config.minIntervalBetweenExecutions
        }
        
        /// 检查最小时间间隔
        private static func checkMinInterval(executionKey: String, currentTime: Date, config: LimitConfig) -> Bool {
            let executionTimes = userDefaults.array(forKey: executionKey) as? [Date] ?? []
            guard let lastExecutionTime = executionTimes.last else { return true }
            
            let timeInterval = currentTime.timeIntervalSince(lastExecutionTime)
            return timeInterval >= config.minIntervalBetweenExecutions
        }
        
        /// 更新执行记录
        private static func updateExecutionRecord(countKey: String, executionKey: String, lastExecutionKey: String, currentTime: Date, currentCount: Int) {
            // 增加执行次数
            userDefaults.set(currentCount + 1, forKey: countKey)
            
            // 记录执行时间（限制数组增长，最多保留最近 50 条）
            var executionTimes = userDefaults.array(forKey: executionKey) as? [Date] ?? []
            executionTimes.append(currentTime)
            if executionTimes.count > 50 {
                executionTimes.removeFirst(executionTimes.count - 50)
            }
            userDefaults.set(executionTimes, forKey: executionKey)
            
            // 更新最后执行时间（用于every系列）
            userDefaults.set(currentTime, forKey: lastExecutionKey)
        }
        
        /// 获取存储键
        private static func getStorageKeys(for key: String, timePeriod: TimePeriod, currentTime: Date) -> (countKey: String, executionKey: String, lastExecutionKey: String) {
            let countKey = getCountKey(for: key, timePeriod: timePeriod, currentTime: currentTime)
            let executionKey = getExecutionKey(for: key, timePeriod: timePeriod, currentTime: currentTime)
            let lastExecutionKey = "\(ExecutionStorageKeyPrefix.last)\(key)"
            
            return (countKey, executionKey, lastExecutionKey)
        }
        
        /// 获取基础日期（用于分组）
        private static func getBaseDate(for timePeriod: TimePeriod, currentTime: Date) -> Date {
            switch timePeriod {
            case .everyDays(let days):
                return getBaseDateForEveryDays(currentTime: currentTime, days: days)
            case .everyHours(let hours):
                return getBaseDateForEveryHours(currentTime: currentTime, hours: hours)
            case .everyMinutes(let minutes):
                return getBaseDateForEveryMinutes(currentTime: currentTime, minutes: minutes)
            case .everyWeeks(let weeks):
                return getBaseDateForEveryWeeks(currentTime: currentTime, weeks: weeks)
            case .everyMonths(let months):
                return getBaseDateForEveryMonths(currentTime: currentTime, months: months)
            case .everyYears(let years):
                return getBaseDateForEveryYears(currentTime: currentTime, years: years)
            default:
                return currentTime
            }
        }
        
        /// 获取每N天的基础日期（用于分组）
        private static func getBaseDateForEveryDays(currentTime: Date, days: Int) -> Date {
            let daysSinceEpoch = Int(currentTime.timeIntervalSince1970 / 86400)
            let baseDays = (daysSinceEpoch / days) * days
            return Date(timeIntervalSince1970: TimeInterval(baseDays * 86400))
        }
        
        /// 获取每N小时的基础日期（用于分组）
        private static func getBaseDateForEveryHours(currentTime: Date, hours: Int) -> Date {
            let hoursSinceEpoch = Int(currentTime.timeIntervalSince1970 / 3600)
            let baseHours = (hoursSinceEpoch / hours) * hours
            return Date(timeIntervalSince1970: TimeInterval(baseHours * 3600))
        }
        
        /// 获取每N分钟的基础日期（用于分组）
        private static func getBaseDateForEveryMinutes(currentTime: Date, minutes: Int) -> Date {
            let minutesSinceEpoch = Int(currentTime.timeIntervalSince1970 / 60)
            let baseMinutes = (minutesSinceEpoch / minutes) * minutes
            return Date(timeIntervalSince1970: TimeInterval(baseMinutes * 60))
        }
        
        /// 获取每N周的基础日期（用于分组）
        private static func getBaseDateForEveryWeeks(currentTime: Date, weeks: Int) -> Date {
            let weeksSinceEpoch = Int(currentTime.timeIntervalSince1970 / (7 * 24 * 3600))
            let baseWeeks = (weeksSinceEpoch / weeks) * weeks
            return Date(timeIntervalSince1970: TimeInterval(baseWeeks * 7 * 24 * 3600))
        }
        
        /// 获取每N月的基础日期（用于分组）
        private static func getBaseDateForEveryMonths(currentTime: Date, months: Int) -> Date {
            let calendar = Calendar.current
            let comps = calendar.dateComponents([.year, .month], from: currentTime)
            let year = comps.year ?? 1970
            let month = (comps.month ?? 1) - 1
            let monthsSinceEpoch = year * 12 + month
            let baseMonths = (monthsSinceEpoch / months) * months
            let baseYear = baseMonths / 12
            let baseMonthIndex = baseMonths % 12
            var baseComps = DateComponents()
            baseComps.year = baseYear
            baseComps.month = baseMonthIndex + 1
            baseComps.day = 1
            baseComps.hour = 0
            baseComps.minute = 0
            baseComps.second = 0
            return calendar.date(from: baseComps) ?? currentTime
        }
        
        /// 获取每N年的基础日期（用于分组）
        private static func getBaseDateForEveryYears(currentTime: Date, years: Int) -> Date {
            let calendar = Calendar.current
            let comps = calendar.dateComponents([.year], from: currentTime)
            let year = comps.year ?? 1970
            let baseYear = (year / years) * years
            var baseComps = DateComponents()
            baseComps.year = baseYear
            baseComps.month = 1
            baseComps.day = 1
            baseComps.hour = 0
            baseComps.minute = 0
            baseComps.second = 0
            return calendar.date(from: baseComps) ?? currentTime
        }
    }
}

public extension TFYUtils {
    
    /// 获取剩余执行次数
    private static func getRemainingExecutions(for key: String, with config: ExecutionLimit.LimitConfig) -> Int {
        return ExecutionLimit.remainingExecutions(for: key, with: config)
    }
    
    /// 获取当前执行次数
    private static func getCurrentExecutionCount(for key: String, with config: ExecutionLimit.LimitConfig) -> Int {
        return ExecutionLimit.currentExecutionCount(for: key, with: config)
    }
    
    /// 获取当前执行时间列表
    private static func getCurrentExecutionTimes(for key: String, with config: ExecutionLimit.LimitConfig) -> [Date] {
        return ExecutionLimit.currentExecutionTimes(for: key, with: config)
    }
    
    /// 重置多个key的执行记录
    private static func resetExecutionForKeys(_ keys: [String], with config: ExecutionLimit.LimitConfig) {
        for key in keys {
            ExecutionLimit.resetCurrentExecution(for: key, with: config)
        }
    }

    /// 清理过期的执行记录
    static func cleanupExpiredRecords() {
        ExecutionLimit.cleanupExpiredRecords()
    }
     
    /// 清理指定key的所有记录
    static func cleanupRecords(for key: String) {
        resetExecutionRecord(for: key)
    }
    
    /// 批量清理指定keys的所有记录
    static func cleanupRecords(for keys: [String]) {
        for key in keys {
            resetExecutionRecord(for: key)
        }
    }
    
    // MARK: - Every系列便捷方法
    
    /// 检查是否可以执行操作（每N天）
    static func canExecuteEveryDays(for key: String, days: Int, maxExecutions: Int = 1, minInterval: TimeInterval = 1.0) -> Bool {
        return canExecuteWithTimePeriod(for: key, timePeriod: .everyDays(days), maxExecutions: maxExecutions, minInterval: minInterval)
    }
    
    /// 检查是否可以执行操作（每N小时）
    static func canExecuteEveryHours(for key: String, hours: Int, maxExecutions: Int = 1, minInterval: TimeInterval = 1.0) -> Bool {
        return canExecuteWithTimePeriod(for: key, timePeriod: .everyHours(hours), maxExecutions: maxExecutions, minInterval: minInterval)
    }
    
    /// 检查是否可以执行操作（每N分钟）
    static func canExecuteEveryMinutes(for key: String, minutes: Int, maxExecutions: Int = 1, minInterval: TimeInterval = 1.0) -> Bool {
        return canExecuteWithTimePeriod(for: key, timePeriod: .everyMinutes(minutes), maxExecutions: maxExecutions, minInterval: minInterval)
    }
    
    /// 检查是否可以执行操作（每N周）
    static func canExecuteEveryWeeks(for key: String, weeks: Int, maxExecutions: Int = 1, minInterval: TimeInterval = 1.0) -> Bool {
        return canExecuteWithTimePeriod(for: key, timePeriod: .everyWeeks(weeks), maxExecutions: maxExecutions, minInterval: minInterval)
    }
    
    /// 检查是否可以执行操作（每N月）
    static func canExecuteEveryMonths(for key: String, months: Int, maxExecutions: Int = 1, minInterval: TimeInterval = 1.0) -> Bool {
        return canExecuteWithTimePeriod(for: key, timePeriod: .everyMonths(months), maxExecutions: maxExecutions, minInterval: minInterval)
    }
    
    /// 检查是否可以执行操作（每N年）
    static func canExecuteEveryYears(for key: String, years: Int, maxExecutions: Int = 1, minInterval: TimeInterval = 1.0) -> Bool {
        return canExecuteWithTimePeriod(for: key, timePeriod: .everyYears(years), maxExecutions: maxExecutions, minInterval: minInterval)
    }

    // MARK: - 按周期（天/周/月/年）计次便捷方法

    /// 按天：每天最多可执行 N 次
    static func canExecutePerDay(for key: String, maxExecutions: Int, minInterval: TimeInterval = 1.0, allowOverflow: Bool = false) -> Bool {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .daily, minIntervalBetweenExecutions: minInterval, allowOverflow: allowOverflow)
        return ExecutionLimit.canExecute(for: key, with: config)
    }

    /// 按周：每周最多可执行 N 次
    static func canExecutePerWeek(for key: String, maxExecutions: Int, minInterval: TimeInterval = 1.0, allowOverflow: Bool = false) -> Bool {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .weekly, minIntervalBetweenExecutions: minInterval, allowOverflow: allowOverflow)
        return ExecutionLimit.canExecute(for: key, with: config)
    }

    /// 按月：每月最多可执行 N 次
    static func canExecutePerMonth(for key: String, maxExecutions: Int, minInterval: TimeInterval = 1.0, allowOverflow: Bool = false) -> Bool {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .monthly, minIntervalBetweenExecutions: minInterval, allowOverflow: allowOverflow)
        return ExecutionLimit.canExecute(for: key, with: config)
    }

    /// 按年：每年最多可执行 N 次
    static func canExecutePerYear(for key: String, maxExecutions: Int, minInterval: TimeInterval = 1.0, allowOverflow: Bool = false) -> Bool {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .yearly, minIntervalBetweenExecutions: minInterval, allowOverflow: allowOverflow)
        return ExecutionLimit.canExecute(for: key, with: config)
    }
    
    /// 获取每N天的剩余执行次数
    static func remainingExecutionsEveryDays(for key: String, days: Int, maxExecutions: Int = 1) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .everyDays(days))
        return getRemainingExecutions(for: key, with: config)
    }
    
    /// 获取每N小时的剩余执行次数
    static func remainingExecutionsEveryHours(for key: String, hours: Int, maxExecutions: Int = 1) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .everyHours(hours))
        return getRemainingExecutions(for: key, with: config)
    }
    
    /// 获取每N分钟的剩余执行次数
    static func remainingExecutionsEveryMinutes(for key: String, minutes: Int, maxExecutions: Int = 1) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .everyMinutes(minutes))
        return getRemainingExecutions(for: key, with: config)
    }
    
    /// 获取每N周的剩余执行次数
    static func remainingExecutionsEveryWeeks(for key: String, weeks: Int, maxExecutions: Int = 1) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .everyWeeks(weeks))
        return getRemainingExecutions(for: key, with: config)
    }
    
    /// 获取每N月的剩余执行次数
    static func remainingExecutionsEveryMonths(for key: String, months: Int, maxExecutions: Int = 1) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .everyMonths(months))
        return getRemainingExecutions(for: key, with: config)
    }
    
    /// 获取每N年的剩余执行次数
    static func remainingExecutionsEveryYears(for key: String, years: Int, maxExecutions: Int = 1) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .everyYears(years))
        return getRemainingExecutions(for: key, with: config)
    }

    // MARK: - 剩余次数（按周期）
    static func remainingExecutionsPerDay(for key: String, maxExecutions: Int) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .daily)
        return getRemainingExecutions(for: key, with: config)
    }

    static func remainingExecutionsPerWeek(for key: String, maxExecutions: Int) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .weekly)
        return getRemainingExecutions(for: key, with: config)
    }

    static func remainingExecutionsPerMonth(for key: String, maxExecutions: Int) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .monthly)
        return getRemainingExecutions(for: key, with: config)
    }

    static func remainingExecutionsPerYear(for key: String, maxExecutions: Int) -> Int {
        let config = ExecutionLimit.LimitConfig(maxExecutions: maxExecutions, timePeriod: .yearly)
        return getRemainingExecutions(for: key, with: config)
    }
    
    /// 统一的执行检查方法
    private static func canExecuteWithTimePeriod(for key: String, timePeriod: ExecutionLimit.TimePeriod, maxExecutions: Int, minInterval: TimeInterval) -> Bool {
        let config = ExecutionLimit.LimitConfig(
            maxExecutions: maxExecutions,
            timePeriod: timePeriod,
            minIntervalBetweenExecutions: minInterval
        )
        return ExecutionLimit.canExecute(for: key, with: config)
    }
    
    /// 获取上次执行时间
    static func getLastExecutionTime(for key: String) -> Date? {
        let lastExecutionKey = "\(ExecutionStorageKeyPrefix.last)\(key)"
        return UserDefaults.standard.object(forKey: lastExecutionKey) as? Date
    }
    
    /// 获取距离下次可执行的时间间隔（秒）
    static func getTimeIntervalUntilNextExecution(for key: String, timePeriod: ExecutionLimit.TimePeriod) -> TimeInterval? {
        guard let lastTime = getLastExecutionTime(for: key) else { return nil }
        
        let currentTime = Date()
        
        switch timePeriod {
        case .everyDays(let days):
            return calculateTimeIntervalForEveryDays(lastTime: lastTime, currentTime: currentTime, days: days)
        case .everyHours(let hours):
            return calculateTimeIntervalForEveryHours(lastTime: lastTime, currentTime: currentTime, hours: hours)
        case .everyMinutes(let minutes):
            return calculateTimeIntervalForEveryMinutes(lastTime: lastTime, currentTime: currentTime, minutes: minutes)
        case .everyWeeks(let weeks):
            return calculateTimeIntervalForEveryWeeks(lastTime: lastTime, currentTime: currentTime, weeks: weeks)
        case .everyMonths(let months):
            return calculateTimeIntervalForEveryMonths(lastTime: lastTime, currentTime: currentTime, months: months)
        case .everyYears(let years):
            return calculateTimeIntervalForEveryYears(lastTime: lastTime, currentTime: currentTime, years: years)
        default:
            return nil
        }
    }
    
    /// 获取每N天的下次执行时间间隔
    static func getTimeIntervalUntilNextExecutionEveryDays(for key: String, days: Int) -> TimeInterval? {
        return getTimeIntervalUntilNextExecution(for: key, timePeriod: .everyDays(days))
    }
    
    /// 获取每N小时的下次执行时间间隔
    static func getTimeIntervalUntilNextExecutionEveryHours(for key: String, hours: Int) -> TimeInterval? {
        return getTimeIntervalUntilNextExecution(for: key, timePeriod: .everyHours(hours))
    }
    
    /// 获取每N分钟的下次执行时间间隔
    static func getTimeIntervalUntilNextExecutionEveryMinutes(for key: String, minutes: Int) -> TimeInterval? {
        return getTimeIntervalUntilNextExecution(for: key, timePeriod: .everyMinutes(minutes))
    }
    
    /// 计算每N天的时间间隔
    private static func calculateTimeIntervalForEveryDays(lastTime: Date, currentTime: Date, days: Int) -> TimeInterval {
        let calendar = ExecutionShared.calendar
        let daysSinceLastExecution = calendar.dateComponents([.day], from: lastTime, to: currentTime).day ?? 0
        
        if daysSinceLastExecution >= days {
            return 0
        } else {
            let nextExecutionTime = calendar.date(byAdding: .day, value: days - daysSinceLastExecution, to: lastTime) ?? lastTime
            return nextExecutionTime.timeIntervalSince(currentTime)
        }
    }
    
    /// 计算每N小时的时间间隔
    private static func calculateTimeIntervalForEveryHours(lastTime: Date, currentTime: Date, hours: Int) -> TimeInterval {
        let hoursSinceLastExecution = currentTime.timeIntervalSince(lastTime) / 3600
        
        if hoursSinceLastExecution >= Double(hours) {
            return 0
        } else {
            let remainingHours = Double(hours) - hoursSinceLastExecution
            return remainingHours * 3600
        }
    }
    
    /// 计算每N分钟的时间间隔
    private static func calculateTimeIntervalForEveryMinutes(lastTime: Date, currentTime: Date, minutes: Int) -> TimeInterval {
        let minutesSinceLastExecution = currentTime.timeIntervalSince(lastTime) / 60
        
        if minutesSinceLastExecution >= Double(minutes) {
            return 0
        } else {
            let remainingMinutes = Double(minutes) - minutesSinceLastExecution
            return remainingMinutes * 60
        }
    }
    
    /// 计算每N周的时间间隔
    private static func calculateTimeIntervalForEveryWeeks(lastTime: Date, currentTime: Date, weeks: Int) -> TimeInterval {
        let weeksSinceLastExecution = currentTime.timeIntervalSince(lastTime) / (7 * 24 * 3600)
        if weeksSinceLastExecution >= Double(weeks) {
            return 0
        } else {
            let remainingWeeks = Double(weeks) - weeksSinceLastExecution
            return remainingWeeks * 7 * 24 * 3600
        }
    }
    
    /// 计算每N月的时间间隔
    private static func calculateTimeIntervalForEveryMonths(lastTime: Date, currentTime: Date, months: Int) -> TimeInterval {
        let calendar = ExecutionShared.calendar
        let monthsDiff = calendar.dateComponents([.month], from: lastTime, to: currentTime).month ?? 0
        if monthsDiff >= months {
            return 0
        } else {
            guard let next = calendar.date(byAdding: .month, value: months, to: lastTime) else { return 0 }
            return max(0, next.timeIntervalSince(currentTime))
        }
    }
    
    /// 计算每N年的时间间隔
    private static func calculateTimeIntervalForEveryYears(lastTime: Date, currentTime: Date, years: Int) -> TimeInterval {
        let calendar = ExecutionShared.calendar
        let yearsDiff = calendar.dateComponents([.year], from: lastTime, to: currentTime).year ?? 0
        if yearsDiff >= years {
            return 0
        } else {
            guard let next = calendar.date(byAdding: .year, value: years, to: lastTime) else { return 0 }
            return max(0, next.timeIntervalSince(currentTime))
        }
    }
    
    /// 重置指定key的执行记录
    static func resetExecutionRecord(for key: String) {
        let lastExecutionKey = "\(ExecutionStorageKeyPrefix.last)\(key)"
        UserDefaults.standard.removeObject(forKey: lastExecutionKey)
        
        // 清理所有相关的计数记录
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let relatedKeys = allKeys.filter { $0.contains(key) && ($0.hasPrefix(ExecutionStorageKeyPrefix.count) || $0.hasPrefix(ExecutionStorageKeyPrefix.times)) }
        
        for relatedKey in relatedKeys {
            UserDefaults.standard.removeObject(forKey: relatedKey)
        }
    }
    
    // MARK: - 实用工具方法
    
    /// 获取人性化的下次执行时间描述
    static func getNextExecutionDescription(for key: String, timePeriod: ExecutionLimit.TimePeriod) -> String {
        guard let interval = getTimeIntervalUntilNextExecution(for: key, timePeriod: timePeriod) else {
            return "可以立即执行"
        }
        
        if interval <= 0 {
            return "可以立即执行"
        }
        
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60
        
        if hours > 24 {
            let days = hours / 24
            return "\(days)天后可执行"
        } else if hours > 0 {
            return "\(hours)小时后可执行"
        } else if minutes > 0 {
            return "\(minutes)分钟后可执行"
        } else {
            return "\(seconds)秒后可执行"
        }
    }
    
    /// 检查是否可以显示弹窗（每N天一次）
    static func canShowPopup(everyDays days: Int, for key: String) -> Bool {
        return canExecuteEveryDays(for: "popup_\(key)", days: days)
    }
    
    /// 检查是否可以发送通知（每N小时一次）
    static func canSendNotification(everyHours hours: Int, for key: String) -> Bool {
        return canExecuteEveryHours(for: "notification_\(key)", hours: hours)
    }
    
    /// 检查是否可以执行定时任务（每N分钟一次）
    static func canExecuteScheduledTask(everyMinutes minutes: Int, for key: String) -> Bool {
        return canExecuteEveryMinutes(for: "task_\(key)", minutes: minutes)
    }
    
    /// 获取所有执行限制相关的key
    static func getAllExecutionKeys() -> [String] {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        return allKeys.filter { $0.hasPrefix(ExecutionStorageKeyPrefix.count) || $0.hasPrefix(ExecutionStorageKeyPrefix.times) || $0.hasPrefix(ExecutionStorageKeyPrefix.last) }
    }
    
    /// 清理所有执行限制记录
    static func cleanupAllExecutionRecords() {
        let allKeys = getAllExecutionKeys()
        for key in allKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}




// MARK: - 使用示例（Usage Examples）
// 注意：以下均为示例代码，请根据业务替换 key、阈值参数
//
// 基础Key
// let key = "feature_key"
//
// 1) 按周期计次（每天/每周/每月/每年）：每个周期内最多执行 N 次
// let canDay   = TFYUtils.canExecutePerDay(for: key,  maxExecutions: 3)
// let canWeek  = TFYUtils.canExecutePerWeek(for: key, maxExecutions: 5)
// let canMonth = TFYUtils.canExecutePerMonth(for: key, maxExecutions: 10)
// let canYear  = TFYUtils.canExecutePerYear(for: key,  maxExecutions: 20)
// let remDay   = TFYUtils.remainingExecutionsPerDay(for: key,   maxExecutions: 3)
// let remWeek  = TFYUtils.remainingExecutionsPerWeek(for: key,  maxExecutions: 5)
// let remMonth = TFYUtils.remainingExecutionsPerMonth(for: key, maxExecutions: 10)
// let remYear  = TFYUtils.remainingExecutionsPerYear(for: key,  maxExecutions: 20)
//
// 2) 每N单位一次（分/时/天/周/月/年）：同一分组内最多执行 maxExecutions 次（默认1次）
// let canEveryMin   = TFYUtils.canExecuteEveryMinutes(for: key, minutes: 10, maxExecutions: 1)
// let canEveryHour  = TFYUtils.canExecuteEveryHours(for: key,   hours: 2,   maxExecutions: 1)
// let canEveryDay   = TFYUtils.canExecuteEveryDays(for: key,    days: 3,    maxExecutions: 1)
// let canEveryWeek  = TFYUtils.canExecuteEveryWeeks(for: key,   weeks: 2,   maxExecutions: 1)
// let canEveryMonth = TFYUtils.canExecuteEveryMonths(for: key,  months: 3,  maxExecutions: 1)
// let canEveryYear  = TFYUtils.canExecuteEveryYears(for: key,   years: 1,   maxExecutions: 1)
// let remEveryMin   = TFYUtils.remainingExecutionsEveryMinutes(for: key, minutes: 10, maxExecutions: 1)
// let remEveryHour  = TFYUtils.remainingExecutionsEveryHours(for: key,   hours: 2,   maxExecutions: 1)
// let remEveryDay   = TFYUtils.remainingExecutionsEveryDays(for: key,    days: 3,    maxExecutions: 1)
// let remEveryWeek  = TFYUtils.remainingExecutionsEveryWeeks(for: key,   weeks: 2,   maxExecutions: 1)
// let remEveryMonth = TFYUtils.remainingExecutionsEveryMonths(for: key,  months: 3,  maxExecutions: 1)
// let remEveryYear  = TFYUtils.remainingExecutionsEveryYears(for: key,   years: 1,   maxExecutions: 1)
//
// 3) 获取当前执行信息
// let cfg = TFYUtils.ExecutionLimit.LimitConfig(maxExecutions: 3, timePeriod: .daily)
// let used = TFYUtils.ExecutionLimit.currentExecutionCount(for: key, with: cfg)
// let times = TFYUtils.ExecutionLimit.currentExecutionTimes(for: key, with: cfg) // [Date]
//
// 4) 计算下次可执行时间
// if let secs = TFYUtils.getTimeIntervalUntilNextExecution(for: key, timePeriod: .everyDays(3)) {
//     print("next in seconds: \(secs)")
// }
// let desc = TFYUtils.getNextExecutionDescription(for: key, timePeriod: .everyHours(2))
//
// 5) 记录清理与查询
// TFYUtils.cleanupExpiredRecords()             // 仅清理日/周/⽉/年四类分组的过期键
// TFYUtils.resetExecutionRecord(for: key)      // 清理某key的所有记录（含 count/times/last）
// TFYUtils.cleanupRecords(for: ["k1","k2"])   // 批量清理
// let allKeys = TFYUtils.getAllExecutionKeys() // 列出所有相关键
// if let last = TFYUtils.getLastExecutionTime(for: key) { print(last) }
//
// 6) 直接使用底层配置（示例：每周最多3次，最短间隔600秒，不允许溢出）
// let weeklyCfg = TFYUtils.ExecutionLimit.LimitConfig(maxExecutions: 3, timePeriod: .weekly, minIntervalBetweenExecutions: 600, allowOverflow: false)
// if TFYUtils.ExecutionLimit.canExecute(for: key, with: weeklyCfg) {
//     // 执行你的逻辑
// }
// let leftWeekly = TFYUtils.ExecutionLimit.remainingExecutions(for: key, with: weeklyCfg)
