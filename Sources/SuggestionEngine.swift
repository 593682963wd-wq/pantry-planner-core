import Foundation

public struct SuggestionEngine: Sendable {
    public init() {}

    public func rankRecipes(
        pantry: [PantryItem],
        recipes: [Recipe],
        preferredLimit: Int = 6,
        priorSelections: [Recipe] = []
    ) -> [RecipeSuggestion] {
        let pantryIndex = PantryIndex(items: pantry)
        let recentIngredientKeys = Set(priorSelections.flatMap(\.heroIngredients).map(\.normalizedIngredientKey))

        let suggestions = recipes.map { recipe in
            let required = recipe.requiredIngredients
            let matched = required.compactMap { ingredient -> PantryItem? in
                guard let pantryItem = pantryIndex.item(for: ingredient.name, unit: ingredient.unit), pantryItem.quantity > 0 else {
                    return nil
                }
                return pantryItem
            }
            let missing = required.filter { ingredient in
                guard let pantryItem = pantryIndex.item(for: ingredient.name, unit: ingredient.unit) else { return true }
                return pantryItem.quantity < ingredient.amount
            }
            let coverage = required.isEmpty ? 1 : Double(required.count - missing.count) / Double(required.count)
            let urgentHits = matched.filter { $0.urgencyBand != .steady }
            let urgencyScore = urgentHits.reduce(0.0) { partial, item in
                partial + max(0, Double(6 - min(max(item.expiresInDays, 0), 6))) / 6.0
            }
            let leftoverScore = recipe.heroIngredients.reduce(0.0) { partial, ingredient in
                partial + (recentIngredientKeys.contains(ingredient.normalizedIngredientKey) ? 0.18 : 0.0)
            }
            let speedScore = max(0, Double(35 - min(recipe.minutes, 35))) / 35.0
            let score = coverage * 0.58 + min(urgencyScore * 0.16, 0.28) + min(leftoverScore, 0.18) + speedScore * 0.08

            return RecipeSuggestion(
                recipe: recipe,
                score: score,
                coverage: coverage,
                urgentHits: urgentHits.sorted { $0.expiresInDays < $1.expiresInDays },
                missingIngredients: missing
            )
        }

        return suggestions
            .sorted {
                if $0.score == $1.score {
                    return $0.recipe.minutes < $1.recipe.minutes
                }
                return $0.score > $1.score
            }
            .prefix(preferredLimit)
            .map { $0 }
    }
}
