//  6.ChemexView.swift

import SwiftUI

struct ChemexView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var recipeStore: CustomRecipeStore
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var store: StoreManager               // Premium kontrolü için eklendi

    // Default recipe
    let recipe: CoffeeRecipe = coffeeRecipes.first { $0.name == "Chemex" } ?? CoffeeRecipe(
        name: "Chemex",
        coffeeAmount: "22gr",
        waterAmount: "300ml",
        brewTime: "3-4 dakika",
        instructions: "Önce kağıt filtreyi koyun, su ile yıkayın ve suyu boşaltın. Orta kalınlıkta öğütülmüş 22gr kahveyi filtreye yerleştirin. Suyu yavaşça ve dairesel hareketlerle dökün. Yaklaşık 3-4 dakika demleyin."
    )

    // State vars
    @State private var cupCount: Int = 1
    let coffeePerCup: Double = 22.0
    @State private var coffeeAmountManual: Int = 15
    @State private var waterAmountManual: Int = 225
    @State private var selectedRatio: Int = 14
    @State private var grinderSetting: String = ""
    @State private var waterTemperature: Int = 94
    @State private var brewingTime: TimeInterval = 180

    // Sheet controls
    @State private var showSettings = false
    @State private var showSaveRecipeSheet = false
    @State private var customRecipeName = ""
    @State private var showPremiumSheet = false           // Premium ekranı için eklendi

    // Timer vars
    @State private var remainingTime: TimeInterval = 180
    @State private var timerStarted = false
    @State private var countdownTimer: Timer? = nil

    private func timeString(from time: TimeInterval) -> String {
        let m = Int(time) / 60, s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var dynamicInstructions: String {
        let brewMin = Int(brewingTime / 60)
        if settings.selectedUnit == "Imperial" {
            let coffeeOz = String(format: "%.2f", UnitConverter.gramsToOunces(Double(coffeeAmountManual)))
            let waterOz  = String(format: "%.2f", UnitConverter.millilitersToFluidOunces(Double(waterAmountManual)))
            if Locale.current.languageCode == "tr" {
                return """
                       Önce kağıt filtreyi koyun, su ile yıkayın ve suyu boşaltın. \
                       Orta kalınlıkta öğütülmüş \(coffeeOz) oz kahveyi filtreye yerleştirin. \
                       Üzerine \(waterOz) fl oz sıcak suyu dairesel hareketlerle dökün ve yaklaşık \(brewMin) dakika demleyin.
                       """
            } else {
                return """
                       First, place the paper filter, rinse it with water and discard the water. \
                       Place \(coffeeOz) oz of medium-ground coffee in the filter. \
                       Pour \(waterOz) fl oz of hot water in a circular motion and brew for about \(brewMin) minutes.
                       """
            }
        } else {
            if Locale.current.languageCode == "tr" {
                return """
                       Önce kağıt filtreyi koyun, su ile yıkayın ve suyu boşaltın. \
                       Orta kalınlıkta öğütülmüş \(coffeeAmountManual)g kahveyi filtreye yerleştirin. \
                       Üzerine \(waterAmountManual)ml sıcak suyu dairesel hareketlerle dökün ve yaklaşık \(brewMin) dakika demleyin.
                       """
            } else {
                return """
                       First, place the paper filter, rinse it with water and discard the water. \
                       Place \(coffeeAmountManual)g of medium-ground coffee in the filter. \
                       Pour \(waterAmountManual)ml of hot water in a circular motion and brew for about \(brewMin) minutes.
                       """
            }
        }
    }

    var body: some View {
        let coffeeValue = settings.selectedUnit == "Imperial"
            ? String(format: "%.2f", UnitConverter.gramsToOunces(Double(coffeeAmountManual)))
            : "\(coffeeAmountManual)"
        let waterValue = settings.selectedUnit == "Imperial"
            ? String(format: "%.2f", UnitConverter.millilitersToFluidOunces(Double(waterAmountManual)))
            : "\(waterAmountManual)"
        let unitCoffee = settings.selectedUnit == "Imperial" ? "oz" : "g"
        let unitWater  = settings.selectedUnit == "Imperial" ? "fl oz" : "ml"
        let tempText   = settings.selectedUnit == "Imperial"
            ? "\(Int(Double(waterTemperature) * 9/5 + 32))°F"
            : "\(waterTemperature)°C"

        NavigationView {
            VStack {
                // Settings summary
                Button { showSettings = true } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Bardak: \(cupCount)")
                            Text("Kahve: \(coffeeValue) \(unitCoffee)")
                            Text("Su: \(waterValue) \(unitWater), Oran: 1/\(selectedRatio)")
                            Text("Su Sıcaklığı: \(tempText)")
                            Text("Öğütücü: \(grinderSetting.isEmpty ? "-" : grinderSetting)")
                            Text("Süre: \(timeString(from: brewingTime))")
                        }
                        .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
                }
                .padding()
                .sheet(isPresented: $showSettings) {
                    ChemexSettingsView(
                        cupCount: $cupCount,
                        coffeeAmountManual: $coffeeAmountManual,
                        waterAmountManual: $waterAmountManual,
                        selectedRatio: $selectedRatio,
                        grinderSetting: $grinderSetting,
                        brewingTime: $brewingTime,
                        waterTemperature: $waterTemperature,
                        coffeePerCup: coffeePerCup
                    )
                    .environmentObject(settings)
                }

                Divider()

                // Save recipe button (PREMIUM KONTROLLÜ)
                Button {
                    if store.isPurchased {
                        showSaveRecipeSheet = true
                    } else {
                        showPremiumSheet = true
                    }
                } label: {
                    Text("Bu Tarifi Kaydet")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showSaveRecipeSheet) {
                    NavigationView {
                        Form {
                            Section(header: Text("Tarif Adı")) {
                                TextField("Tarif adını giriniz", text: $customRecipeName)
                            }
                        }
                        .navigationTitle("Tarifi Kaydet")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("İptal") { showSaveRecipeSheet = false }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Kaydet") {
                                    let coffeeAmt = "\(coffeeAmountManual)"
                                    let waterAmt  = "\(waterAmountManual)"
                                    let brew = timeString(from: brewingTime)
                                    let newRecipe = CustomCoffeeRecipe(
                                        id: UUID(),
                                        name: customRecipeName,
                                        coffeeAmount: coffeeAmt,
                                        waterAmount: waterAmt,
                                        brewTime: brew,
                                        notes: "",
                                        grinderSetting: grinderSetting,
                                        waterTemperature: waterTemperature
                                    )
                                    recipeStore.recipes.append(newRecipe)
                                    showSaveRecipeSheet = false
                                }
                                .disabled(customRecipeName.isEmpty)
                            }
                        }
                    }
                    .environmentObject(recipeStore)
                    .environmentObject(settings)
                }
                .sheet(isPresented: $showPremiumSheet) {
                    PremiumInfoView()
                }
                Divider()

                // Countdown timer
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Geri Sayım:").font(.title2)
                        Spacer()
                        Text(timeString(from: remainingTime)).font(.title2)
                    }
                    .padding(.horizontal, 16) // SOLDAN/SAĞDAN boşluk

                    HStack(spacing: 12) {
                        Button { timerStarted ? stopTimer() : startTimer() } label: {
                            HStack {
                                Spacer()
                                Text(timerStarted ? "Durdur" : (remainingTime < brewingTime ? "Devam et" : "Başlat"))
                                    .foregroundColor(.white)
                                    .font(.body)
                                Spacer()
                            }
                            .padding(8)
                            .background(timerStarted ? Color.red : Color.green)
                            .cornerRadius(8)
                        }
                        Button {
                            stopTimer()
                            remainingTime = brewingTime
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sıfırla").foregroundColor(.white).font(.body)
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.gray)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16) // SOLDAN/SAĞDAN boşluk
                    .padding(.vertical, 4)
                }
                .padding(.bottom, 4)
                Divider()

                // Instructions & steps
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Talimatlar")
                            .font(.headline)
                            .padding(.horizontal)
                        Text(dynamicInstructions)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        Text("İşlem Adımları:")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { idx in
                                    Image("\(recipe.name)_\(idx)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 150)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Chemex Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { remainingTime = brewingTime }
            .onChange(of: brewingTime) { remainingTime = $0 }
        }
        .navigationViewStyle(.stack)  // ← iPad’de split yerine stack modu
    }

    private func startTimer() {
        timerStarted = true
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 { remainingTime -= 1 } else { stopTimer() }
        }
    }

    private func stopTimer() {
        timerStarted = false
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

struct ChemexView_Previews: PreviewProvider {
    static var previews: some View {
        ChemexView()
            .environmentObject(CustomRecipeStore())
            .environmentObject(SettingsModel())
            .environmentObject(StoreManager())
    }
}
