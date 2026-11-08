import Foundation

public enum DinnerSlot: String, Codable, CaseIterable, Identifiable, Sendable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday

    public var id: String { rawValue }

    public var title: String {
        title(in: .chinese)
    }

    public func title(in language: AppContentLanguage) -> String {
        switch self {
        case .monday: language.text("周一", "Mon")
        case .tuesday: language.text("周二", "Tue")
        case .wednesday: language.text("周三", "Wed")
        case .thursday: language.text("周四", "Thu")
        case .friday: language.text("周五", "Fri")
        }
    }
}

public struct PlannedDinner: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var slot: DinnerSlot
    public var recipeID: UUID?

    public init(id: UUID = UUID(), slot: DinnerSlot, recipeID: UUID? = nil) {
        self.id = id
        self.slot = slot
        self.recipeID = recipeID
    }
}

public struct UseItUpSnapshot: Codable, Sendable, Equatable {
    public var pantry: [PantryItem]
    public var recipes: [Recipe]
    public var plan: [PlannedDinner]
    public var groceryChecks: Set<String>

    public init(
        pantry: [PantryItem],
        recipes: [Recipe],
        plan: [PlannedDinner],
        groceryChecks: Set<String> = []
    ) {
        self.pantry = pantry
        self.recipes = recipes
        self.plan = plan
        self.groceryChecks = groceryChecks
    }
}
