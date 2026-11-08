import Foundation

public struct GroceryPlanner: Sendable {
    public init() {}

    public func buildList(
        plan: [PlannedDinner],
        pantry: [PantryItem],
        recipes: [Recipe],
        checkedItems: Set<String> = []
    ) -> [GroceryGapItem] {
        let recipeMap = Dictionary(recipes.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let pantryIndex = PantryIndex(items: pantry)
        var grouped: [String: GroceryGapItem] = [:]
        var available: [String: Double] = [:]

        for dinner in plan {
            guard let recipeID = dinner.recipeID, let recipe = recipeMap[recipeID] else { continue }
            for ingredient in recipe.requiredIngredients {
                let inventoryKey = PantryIndex.key(ingredient.name, ingredient.unit)
                let pantryAmount = available[inventoryKey] ?? (pantryIndex.item(for: ingredient.name, unit: ingredient.unit)?.quantity ?? 0)
                let neededAmount = max(0, ingredient.amount - pantryAmount)
                available[inventoryKey] = max(0, pantryAmount - ingredient.amount)
                guard neededAmount > 0 else { continue }

                let key = "\(ingredient.aisle.rawValue)-\(ingredient.name.normalizedIngredientKey)-\(ingredient.unit.rawValue)"
                if var existing = grouped[key] {
                    existing = GroceryGapItem(
                        name: existing.name,
                        amount: existing.amount + neededAmount,
                        unit: existing.unit,
                        aisle: existing.aisle,
                        isChecked: checkedItems.contains(existing.id)
                    )
                    grouped[key] = existing
                } else {
                    let item = GroceryGapItem(
                        name: ingredient.name,
                        amount: neededAmount,
                        unit: ingredient.unit,
                        aisle: ingredient.aisle,
                        isChecked: checkedItems.contains("\(ingredient.aisle.rawValue)-\(ingredient.name.normalizedIngredientKey)-\(ingredient.unit.rawValue)")
                    )
                    grouped[key] = item
                }
            }
        }

        return grouped.values.sorted {
            if $0.aisle == $1.aisle {
                return $0.name < $1.name
            }
            return $0.aisle.title < $1.aisle.title
        }
    }
}
