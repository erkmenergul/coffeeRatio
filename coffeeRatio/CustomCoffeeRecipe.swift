//  CustomCoffeeRecipe.swift

import Foundation

/// Custom coffee recipe model with grinder setting and water temperature support
struct CustomCoffeeRecipe: Identifiable, Codable {
    let id: UUID
    var name: String
    var coffeeAmount: String
    var waterAmount: String
    var brewTime: String
    var notes: String
    var grinderSetting: String
    var waterTemperature: Int

    enum CodingKeys: String, CodingKey {
        case id, name, coffeeAmount, waterAmount, brewTime, notes, grinderSetting, waterTemperature
    }

    /// Default initializer
    init(
        id: UUID = UUID(),
        name: String,
        coffeeAmount: String,
        waterAmount: String,
        brewTime: String,
        notes: String,
        grinderSetting: String = "",
        waterTemperature: Int = 94
    ) {
        self.id = id
        self.name = name
        self.coffeeAmount = coffeeAmount
        self.waterAmount = waterAmount
        self.brewTime = brewTime
        self.notes = notes
        self.grinderSetting = grinderSetting
        self.waterTemperature = waterTemperature
    }

    /// Custom decoding to provide backward compatibility for `waterTemperature`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        coffeeAmount = try container.decode(String.self, forKey: .coffeeAmount)
        waterAmount = try container.decode(String.self, forKey: .waterAmount)
        brewTime = try container.decode(String.self, forKey: .brewTime)
        notes = try container.decode(String.self, forKey: .notes)
        grinderSetting = try container.decodeIfPresent(String.self, forKey: .grinderSetting) ?? ""
        waterTemperature = try container.decodeIfPresent(Int.self, forKey: .waterTemperature) ?? 94
    }
}

/// Store for managing custom recipes with persistence
class CustomRecipeStore: ObservableObject {
    @Published var recipes: [CustomCoffeeRecipe] = [] {
        didSet {
            saveRecipes()
        }
    }

    init() {
        loadRecipes()
    }

    private func loadRecipes() {
        guard let data = UserDefaults.standard.data(forKey: "CustomCoffeeRecipes") else { return }
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([CustomCoffeeRecipe].self, from: data) {
            recipes = decoded
        }
    }

    private func saveRecipes() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(recipes) {
            UserDefaults.standard.set(data, forKey: "CustomCoffeeRecipes")
        }
    }

    /// Delete a recipe
    func delete(recipe: CustomCoffeeRecipe) {
        recipes.removeAll { $0.id == recipe.id }
    }

    /// Move (reorder) recipes
    func move(from source: IndexSet, to destination: Int) {
        recipes.move(fromOffsets: source, toOffset: destination)
    }
}
