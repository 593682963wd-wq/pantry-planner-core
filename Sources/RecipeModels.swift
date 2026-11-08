import Foundation

public enum GroceryAisle: String, Codable, CaseIterable, Identifiable, Sendable {
    case produce
    case protein
    case dairy
    case dryGoods
    case bakery
    case freezer
    case condiments

    public var id: String { rawValue }

    public var title: String {
        title(in: .chinese)
    }

    public func title(in language: AppContentLanguage) -> String {
        switch self {
        case .produce: language.text("蔬果区", "Produce")
        case .protein: language.text("蛋白区", "Protein")
        case .dairy: language.text("乳品区", "Dairy")
        case .dryGoods: language.text("干货区", "Pantry")
        case .bakery: language.text("主食区", "Bread")
        case .freezer: language.text("冷冻区", "Frozen")
        case .condiments: language.text("调味区", "Condiments")
        }
    }
}

public struct RecipeIngredient: Codable, Hashable, Sendable {
    public var name: String
    public var amount: Double
    public var unit: PantryUnit
    public var aisle: GroceryAisle
    public var isOptional: Bool

    public init(
        name: String,
        amount: Double,
        unit: PantryUnit,
        aisle: GroceryAisle,
        isOptional: Bool = false
    ) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.aisle = aisle
        self.isOptional = isOptional
    }
}

public struct Recipe: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var subtitle: String
    public var minutes: Int
    public var serves: Int
    public var accentHex: String
    public var requiredIngredients: [RecipeIngredient]
    public var optionalIngredients: [RecipeIngredient]
    public var steps: [String]
    public var leftoverNote: String

    public init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        minutes: Int,
        serves: Int,
        accentHex: String,
        requiredIngredients: [RecipeIngredient],
        optionalIngredients: [RecipeIngredient] = [],
        steps: [String],
        leftoverNote: String
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.minutes = minutes
        self.serves = serves
        self.accentHex = accentHex
        self.requiredIngredients = requiredIngredients
        self.optionalIngredients = optionalIngredients
        self.steps = steps
        self.leftoverNote = leftoverNote
    }

    public var heroIngredients: [String] {
        requiredIngredients.prefix(3).map(\.name)
    }

    public func heroIngredients(in language: AppContentLanguage) -> [String] {
        requiredIngredients.prefix(3).map { $0.displayName(in: language) }
    }
}

public struct RecipeSuggestion: Identifiable, Hashable, Sendable {
    public let recipe: Recipe
    public let score: Double
    public let coverage: Double
    public let urgentHits: [PantryItem]
    public let missingIngredients: [RecipeIngredient]

    public var id: UUID { recipe.id }

    public var coverageLabel: String {
        coverageLabel(in: .chinese)
    }

    public func coverageLabel(in language: AppContentLanguage) -> String {
        language.text("库存匹配 \(Int((coverage * 100).rounded()))%", "\(Int((coverage * 100).rounded()))% match")
    }
}

public struct GroceryGapItem: Identifiable, Hashable, Sendable {
    public let name: String
    public let amount: Double
    public let unit: PantryUnit
    public let aisle: GroceryAisle
    public var isChecked: Bool

    public init(name: String, amount: Double, unit: PantryUnit, aisle: GroceryAisle, isChecked: Bool = false) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.aisle = aisle
        self.isChecked = isChecked
    }

    public var id: String { "\(aisle.rawValue)-\(name.normalizedIngredientKey)-\(unit.rawValue)" }

    public var quantityLabel: String {
        quantityLabel(in: .chinese)
    }

    public func quantityLabel(in language: AppContentLanguage) -> String {
        let formatted = amount == amount.rounded()
            ? String(Int(amount))
            : String(format: "%.1f", amount)
        return "\(formatted) \(unit.shortLabel(in: language))"
    }
}
