import Foundation

extension String {
    var normalizedIngredientKey: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
    }
}

struct PantryIndex {
    private let storage: [String: PantryItem]
    static func key(_ name: String, _ unit: PantryUnit) -> String {
        "\(name.normalizedIngredientKey)|\(unit.rawValue)"
    }
    init(items: [PantryItem]) {
        var values: [String: PantryItem] = [:]
        for item in items {
            let key = Self.key(item.name, item.unit)
            if var existing = values[key] {
                existing.quantity += item.quantity
                existing.expiresInDays = min(existing.expiresInDays, item.expiresInDays)
                values[key] = existing
            } else { values[key] = item }
        }
        storage = values
    }
    func item(for ingredientName: String, unit: PantryUnit) -> PantryItem? {
        storage[Self.key(ingredientName, unit)]
    }
}
