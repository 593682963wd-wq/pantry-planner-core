import Foundation

public struct WeekPlanner: Sendable {
    private let engine = SuggestionEngine()

    public init() {}

    public func makeWorkweekPlan(
        pantry: [PantryItem],
        recipes: [Recipe]
    ) -> [PlannedDinner] {
        var remainingPantry = pantry
        var selectedRecipes: [Recipe] = []
        var result: [PlannedDinner] = []

        for slot in DinnerSlot.allCases {
            let suggestions = engine.rankRecipes(
                pantry: remainingPantry,
                recipes: recipes,
                preferredLimit: recipes.count,
                priorSelections: selectedRecipes
            )
            guard let chosenSuggestion = suggestions.first(where: { candidate in
                !selectedRecipes.contains(candidate.recipe) &&
                candidate.coverage >= 0.5
            }) ?? suggestions.first else {
                result.append(PlannedDinner(slot: slot))
                continue
            }
            let chosen = chosenSuggestion.recipe

            result.append(PlannedDinner(slot: slot, recipeID: chosen.id))
            selectedRecipes.append(chosen)
            remainingPantry = consumePantry(from: remainingPantry, using: chosen)
        }

        return result
    }

    private func consumePantry(from pantry: [PantryItem], using recipe: Recipe) -> [PantryItem] {
        var updated = pantry
        for ingredient in recipe.requiredIngredients {
            var needed = ingredient.amount
            for index in updated.indices where updated[index].name.normalizedIngredientKey == ingredient.name.normalizedIngredientKey && updated[index].unit == ingredient.unit {
                let consumed = min(updated[index].quantity, needed)
                updated[index].quantity -= consumed
                needed -= consumed
                if needed <= 0 { break }
            }
        }
        return updated
    }
}
