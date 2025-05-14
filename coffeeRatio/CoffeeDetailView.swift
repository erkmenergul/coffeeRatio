//CoffeeDetailView.swift

import SwiftUI

struct CoffeeDetailView: View {
    let recipe: CoffeeRecipe
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsModel

    // BrewTime string'ini saniyeye çevirir.
    private var brewTimeInterval: TimeInterval {
        if recipe.brewTime.contains("dakika") {
            let parts = recipe.brewTime.components(separatedBy: " ")
            if let first = parts.first, let minutes = Double(first) {
                return minutes * 60
            }
        } else {
            let parts = recipe.brewTime.split(separator: ":")
            if parts.count == 2,
               let m = Int(parts[0]), let s = Int(parts[1]) {
                return TimeInterval(m * 60 + s)
            }
        }
        return 240
    }

    // Kahve miktarı
    private var displayCoffeeAmount: String {
        let raw = recipe.coffeeAmount.filter { "0123456789.".contains($0) }
        let value = Double(raw) ?? 0
        if settings.selectedUnit == "Imperial" {
            return String(format: "%.2f oz", UnitConverter.gramsToOunces(value))
        } else {
            return "\(raw) gr"
        }
    }

    // Su miktarı (tek parça veya virgülle ayrılmış birden fazla parça)
    private var displayWaterAmount: String {
        let parts = recipe.waterAmount
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }

        if parts.count > 1 {
            return parts.map { part in
                let raw = part.filter { "0123456789.".contains($0) }
                // "ml" birimini etiketten çıkarıyoruz
                var label = part.replacingOccurrences(of: raw, with: "")
                label = label.replacingOccurrences(of: "ml", with: "", options: .caseInsensitive)
                label = label.trimmingCharacters(in: .whitespaces)
                let value = Double(raw) ?? 0
                if settings.selectedUnit == "Imperial" {
                    let oz = UnitConverter.millilitersToFluidOunces(value)
                    return String(format: "%.2f fl oz %@", oz, label)
                } else {
                    return "\(raw) ml \(label)"
                }
            }
            .joined(separator: ", ")
        } else {
            let raw = recipe.waterAmount.filter { "0123456789.".contains($0) }
            let value = Double(raw) ?? 0
            if settings.selectedUnit == "Imperial" {
                let oz = UnitConverter.millilitersToFluidOunces(value)
                return String(format: "%.2f fl oz", oz)
            } else {
                return "\(raw) ml"
            }
        }
    }

    // Talimat metni (Imperial seçiliyse yalnızca ml → fl oz dönüştürülür)
    // Talimat metni (Imperial seçiliyse gr → oz ve ml → fl oz dönüştürülür)
    private var displayInstructions: String {
        guard settings.selectedUnit == "Imperial" else {
            return recipe.instructions
        }
        var result = recipe.instructions

        // 1) Gramları oz’a çevir
        let grPattern = #"(\d+(?:\.\d+)?)\s*gr\b"#
        if let grRegex = try? NSRegularExpression(pattern: grPattern, options: .caseInsensitive) {
            let matches = grRegex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            for m in matches.reversed() {
                if let numRange = Range(m.range(at: 1), in: result),
                   let value = Double(result[numRange]) {
                    let oz = UnitConverter.gramsToOunces(value)
                    let replacement = String(format: "%.2f oz", oz)
                    if let fullRange = Range(m.range, in: result) {
                        result.replaceSubrange(fullRange, with: replacement)
                    }
                }
            }
        }

        // 2) Millilitreleri fl oz’a çevir
        let mlPattern = #"(\d+(?:\.\d+)?)\s*ml\b"#
        if let mlRegex = try? NSRegularExpression(pattern: mlPattern, options: .caseInsensitive) {
            let matches = mlRegex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            for m in matches.reversed() {
                if let numRange = Range(m.range(at: 1), in: result),
                   let value = Double(result[numRange]) {
                    let flOz = UnitConverter.millilitersToFluidOunces(value)
                    let replacement = String(format: "%.2f fl oz", flOz)
                    if let fullRange = Range(m.range, in: result) {
                        result.replaceSubrange(fullRange, with: replacement)
                    }
                }
            }
        }

        return result
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Kahve Miktarı")
                            .font(.headline)
                        Text(displayCoffeeAmount)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Su Miktarı")
                            .font(.headline)
                        Text(displayWaterAmount)
                    }
                }

                VStack(alignment: .leading) {
                    Text("Demleme Süresi")
                        .font(.headline)
                    Text(recipe.brewTime)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Talimatlar")
                        .font(.headline)
                    Text(displayInstructions)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if isBrewingMethod(recipe.name) {
                    Text("İşlem Adımları:")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 10) {
                            ForEach(1...5, id: \.self) { idx in
                                Image("\(recipe.name)_\(idx)")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 150)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    Image("\(recipe.imageName)-\(recipe.imageName)")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 20)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Geri") { presentationMode.wrappedValue.dismiss() }
            }
        }
    }

    private func isBrewingMethod(_ name: String) -> Bool {
        ["French Press","Pour Over (V60)","AeroPress","Moka Pot","Syphon","Chemex"]
            .contains(name)
    }
}

struct CoffeeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoffeeDetailView(
                recipe: CoffeeRecipe(
                    name: "Latte",
                    coffeeAmount: "18gr",
                    waterAmount: "36ml espresso,180ml süt",
                    brewTime: "Espresso: 25-30 saniye",
                    instructions: "18gr kahveden 36ml espresso elde edin. 180ml süt ekleyin."
                )
            )
            .environmentObject(SettingsModel())
        }
    }
}
