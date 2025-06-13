//  1.FrenchPressView.swift

import SwiftUI

struct FrenchPressView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var recipeStore: CustomRecipeStore
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var store: StoreManager  // Premium kontrolü için eklendi

    // Varsayılan tarif bilgisi
    let recipe: CoffeeRecipe = coffeeRecipes.first { $0.name == "French Press" } ?? CoffeeRecipe(
        name: "French Press",
        coffeeAmount: "15gr",
        waterAmount: "225ml",
        brewTime: "4 dakika",
        instructions: "French Pressi sıcak su ile ısıtın. Orta kalınlıkta öğütülmüş 15gr kahveyi koyun. Üzerine 225ml sıcak suyu yavaş yavaş dökün. Yaklaşık 4 dakika bekleyin ve ardından pistonu yavaşça aşağı itin."
    )

    // Ayar state'leri
    @State private var cupCount: Int = 1
    let coffeePerCup: Double = 15.0
    @State private var coffeeAmountManual: Int = 15
    @State private var waterAmountManual: Int = 225
    @State private var selectedRatio: Int = 15
    @State private var grinderSetting: String = ""
    @State private var brewingTime: TimeInterval = 240
    @State private var waterTemperature: Int = 94

    // Sheet kontrol state'leri
    @State private var showSettings = false
    @State private var showSaveRecipeSheet = false
    @State private var customRecipeName = ""
    @State private var showPremiumSheet = false      // Premium ekranı için eklendi

    // Timer state'leri
    @State private var remainingTime: TimeInterval = 240
    @State private var timerStarted = false
    @State private var countdownTimer: Timer? = nil

    // Dynamic metin
    private var dynamicInstructions: String {
        let brewMinutes = Int(brewingTime / 60)
        if settings.selectedUnit == "Imperial" {
            let coffeeOz = String(format: "%.2f", UnitConverter.gramsToOunces(Double(coffeeAmountManual)))
            let waterOz = String(format: "%.2f", UnitConverter.millilitersToFluidOunces(Double(waterAmountManual)))
            if Locale.current.languageCode == "tr" {
                return """
                       French Pressi sıcak su ile ısıtın. Orta kalınlıkta öğütülmüş \(coffeeOz) oz kahveyi koyun. Üzerine \(waterOz) fl oz sıcak suyu yavaş yavaş dökün. \(brewMinutes) dakika bekleyin ve ardından pistonu yavaşça aşağı itin.
                       """
            } else {
                return """
                       Heat the French Press with hot water. Add \(coffeeOz) oz of medium-ground coffee. Slowly pour \(waterOz) fl oz of hot water. Wait for \(brewMinutes) minutes, then slowly press the plunger down.
                       """
            }
        } else {
            if Locale.current.languageCode == "tr" {
                return """
                       French Pressi sıcak su ile ısıtın. Orta kalınlıkta öğütülmüş \(coffeeAmountManual)g kahveyi koyun. Üzerine \(waterAmountManual)ml sıcak suyu yavaş yavaş dökün. \(brewMinutes) dakika bekleyin ve ardından pistonu yavaşça aşağı itin.
                       """
            } else {
                return """
                       Heat the French Press with hot water. Add \(coffeeAmountManual)g of medium-ground coffee. Slowly pour \(waterAmountManual)ml of hot water. Wait for \(brewMinutes) minutes, then slowly press the plunger down.
                       """
            }
        }
    }

    private func timeString(from time: TimeInterval) -> String {
        let m = Int(time) / 60, s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        let coffeeValue = settings.selectedUnit == "Imperial"
            ? String(format: "%.2f", UnitConverter.gramsToOunces(Double(coffeeAmountManual)))
            : "\(coffeeAmountManual)"
        let waterValue = settings.selectedUnit == "Imperial"
            ? String(format: "%.2f", UnitConverter.millilitersToFluidOunces(Double(waterAmountManual)))
            : "\(waterAmountManual)"
        let unitCoffee = settings.selectedUnit == "Imperial" ? "oz" : "g"
        let unitWater = settings.selectedUnit == "Imperial" ? "fl oz" : "ml"
        let tempText: String = settings.selectedUnit == "Imperial"
            ? "\(Int(Double(waterTemperature) * 9/5 + 32))°F"
            : "\(waterTemperature)°C"

        NavigationView {
            VStack {
                // Özet butonu
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
                    FrenchPressSettingsView(
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

                // Kaydet butonu (PREMIUM KONTROLLÜ)
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
                                    let brew = timeString(from: brewingTime)
                                    let newRecipe = CustomCoffeeRecipe(
                                        id: UUID(),
                                        name: customRecipeName,
                                        coffeeAmount: String(coffeeAmountManual),
                                        waterAmount: String(waterAmountManual),
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

                // Talimatlar ve işlem adımları
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Talimatlar").font(.headline).padding(.horizontal)
                        Text(dynamicInstructions)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        Text("İşlem Adımları:").font(.headline).padding(.horizontal)
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
            .navigationTitle("French Press Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { remainingTime = brewingTime }
            .onChange(of: brewingTime) { remainingTime = $0 }
        }
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

struct FrenchPressView_Previews: PreviewProvider {
    static var previews: some View {
        FrenchPressView()
            .environmentObject(CustomRecipeStore())
            .environmentObject(SettingsModel())
            .environmentObject(StoreManager())
    }
}
