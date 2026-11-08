import Foundation

public enum PantryCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case produce
    case protein
    case dairy
    case pantry
    case freezer
    case bakery
    case spice

    public var id: String { rawValue }

    public var title: String {
        title(in: .chinese)
    }

    public func title(in language: AppContentLanguage) -> String {
        switch self {
        case .produce: language.text("蔬果", "Produce")
        case .protein: language.text("蛋白", "Protein")
        case .dairy: language.text("乳品", "Dairy")
        case .pantry: language.text("干货", "Pantry")
        case .freezer: language.text("冷冻", "Freezer")
        case .bakery: language.text("主食", "Bread")
        case .spice: language.text("调味", "Spices")
        }
    }
}

public enum PantryUnit: String, Codable, CaseIterable, Sendable {
    case item
    case bag
    case bunch
    case can
    case carton
    case cup
    case jar
    case pack
    case piece
    case pound

    public var shortLabel: String {
        shortLabel(in: .chinese)
    }

    public func shortLabel(in language: AppContentLanguage) -> String {
        switch self {
        case .item: language.text("个", "pcs")
        case .bag: language.text("袋", "bag")
        case .bunch: language.text("把", "bunch")
        case .can: language.text("罐", "can")
        case .carton: language.text("盒", "carton")
        case .cup: language.text("杯", "cup")
        case .jar: language.text("瓶", "jar")
        case .pack: language.text("包", "pack")
        case .piece: language.text("块", "piece")
        case .pound: language.text("磅", "lb")
        }
    }
}

public enum UrgencyBand: String, Codable, CaseIterable, Sendable {
    case today
    case soon
    case steady

    public var title: String {
        title(in: .chinese)
    }

    public func title(in language: AppContentLanguage) -> String {
        switch self {
        case .today: language.text("今天优先", "Use today")
        case .soon: language.text("本周先用", "Use this week")
        case .steady: language.text("可以继续放", "Safe to hold")
        }
    }
}

public struct PantryItem: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var category: PantryCategory
    public var quantity: Double
    public var unit: PantryUnit
    public var expiresInDays: Int
    public var note: String
    public var isStaple: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        category: PantryCategory,
        quantity: Double,
        unit: PantryUnit,
        expiresInDays: Int,
        note: String = "",
        isStaple: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.expiresInDays = expiresInDays
        self.note = note
        self.isStaple = isStaple
    }

    public var urgencyBand: UrgencyBand {
        switch expiresInDays {
        case ...1: .today
        case 2...5: .soon
        default: .steady
        }
    }

    public var freshnessHeadline: String {
        freshnessHeadline(in: .chinese)
    }

    public func freshnessHeadline(in language: AppContentLanguage) -> String {
        switch urgencyBand {
        case .today: language.text("今晚先做掉", "Cook it tonight")
        case .soon: language.text("这周尽快安排", "Plan it this week")
        case .steady: language.text("还能放心放", "Still in good shape")
        }
    }

    public var expiryLabel: String {
        expiryLabel(in: .chinese)
    }

    public func expiryLabel(in language: AppContentLanguage) -> String {
        switch expiresInDays {
        case ..<0: language.text("已过期", "Expired")
        case 0: language.text("今天到期", "Expires today")
        case 1: language.text("还剩 1 天", "1 day left")
        default: language.text("还剩 \(expiresInDays) 天", "\(expiresInDays) days left")
        }
    }

    public var quantityLabel: String {
        quantityLabel(in: .chinese)
    }

    public func quantityLabel(in language: AppContentLanguage) -> String {
        let formatted = quantity == quantity.rounded()
            ? String(Int(quantity))
            : String(format: "%.1f", quantity)
        return "\(formatted) \(unit.shortLabel(in: language))"
    }

    public func urgencyActionLabel(in language: AppContentLanguage) -> String {
        expiresInDays <= 0 ? language.text("立刻处理", "Handle now") : language.text("建议尽快安排", "Plan soon")
    }
}
