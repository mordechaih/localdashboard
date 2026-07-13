import Foundation

struct UsageWindowInfo: Sendable {
    let usedUSD: Double
    let limitUSD: Double
    let usedPercent: Int
}

private struct UsageWindowBucket: Decodable {
    let used_credits: Double?
    let monthly_limit: Double?
    let utilization: Double?
}

private struct UsageAPIResponse: Decodable {
    let extra_usage: UsageWindowBucket?
    let five_hour: UsageWindowBucket?
    let seven_day: UsageWindowBucket?
}

func parseUsageWindowResponse(_ data: Data) -> UsageWindowInfo? {
    guard let response = try? JSONDecoder().decode(UsageAPIResponse.self, from: data) else { return nil }
    guard let bucket = response.extra_usage ?? response.five_hour ?? response.seven_day else { return nil }
    guard let usedCredits = bucket.used_credits,
          let monthlyLimit = bucket.monthly_limit,
          let utilization = bucket.utilization else { return nil }

    return UsageWindowInfo(
        usedUSD: usedCredits / 100,
        limitUSD: monthlyLimit / 100,
        usedPercent: Int(utilization.rounded(.down))
    )
}

func daysUntilBillingReset(from date: Date = Date(), resetDay: Int = 1, calendar: Calendar = .current) -> Int {
    let today = calendar.startOfDay(for: date)
    let currentDay = calendar.component(.day, from: today)
    var components = calendar.dateComponents([.year, .month], from: today)
    components.day = resetDay
    if currentDay >= resetDay {
        components.month = (components.month ?? 1) + 1
    }
    guard let resetDate = calendar.date(from: components) else { return 0 }
    let days = calendar.dateComponents([.day], from: today, to: resetDate).day ?? 0
    return max(0, days)
}

func resetLabel(forDays days: Int) -> String {
    if days == 0 { return "today" }
    if days == 1 { return "in 1 day" }
    return "in \(days)d"
}
