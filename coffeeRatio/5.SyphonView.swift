//  5.SyphonView.swift

import SwiftUI

struct SyphonView: View {
    @EnvironmentObject var recipeStore: CustomRecipeStore
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var store: StoreManager          // Premium kontrolü için eklendi

    // Default recipe
    let recipe: CoffeeRecipe = coffeeRecipes.first { $0.name == "Syphon" } ?? CoffeeRecipe(
        name: "Syphon",
        coffeeAmount: "20gr",
        waterAmount: "300ml",
        brewTime: "3-4 dakika",
        instructions: "Syphonun alt kısmını sıcak suyla doldurun. Üst bölümü ve filtreyi yerleştirin. Orta kalınlıkta öğütülmüş 20gr kahveyi üst kısma koyun. Altındaki ısıtıcıyı açın ve suyun ısınarak yukarı çıkmasını izleyin. Bütün su yukarı çıkınca ısıtıcıyı kapatın ve kahvenin alt hazneye inmesini bekleyin."
    )

    // State vars
    @State private var cupCount: Int = 1
    let coffeePerCup: Double = 20.0
    @State private var coffeeAmountManual: Int = 20
    @State private var waterAmountManual: Int = 300
    @State private var selectedRatio: Int = 15
    @State private var grinderSetting: String = ""
    @State private var waterTemperature: Int = 95
    @State private var brewingTime: TimeInterval = 210

    // Sheet controls
    @State private var showSettings = false
    @State private var showSaveRecipeSheet = false
    @State private var customRecipeName = ""
    @State private var showPremiumSheet = false         // Premium ekranı için eklendi

    // Timer vars
    @State private var remainingTime: TimeInterval = 210
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
                       Syphonun alt kısmını \(waterOz) fl oz sıcak suyla doldurun. Üst bölümü ve filtreyi yerleştirin. \
                       Orta kalınlıkta öğütülmüş \(coffeeOz) oz kahveyi üst kısma koyun. Yaklaşık \(brewMin) dakika suyun tamamen üst kısma çıkmasını bekleyin. Isıtıcıyı kapatın ve kahvenin alt hazneye inmesini bekleyin.
                       """
            } else {
                return """
                       Fill the lower part of the syphon with \(waterOz) fl oz of hot water. Place the upper chamber and filter. \
                       Add \(coffeeOz) oz of medium-ground coffee to the upper chamber. Wait about \(brewMin) minutes for all the water to rise. Turn off the heater and wait for the coffee to flow down to the lower chamber.
                       """
            }
        } else {
            if Locale.current.languageCode == "tr" {
                return """
                       Syphonun alt kısmını \(waterAmountManual)ml sıcak suyla doldurun. Üst bölümü ve filtreyi yerleştirin. \
                       Orta kalınlıkta öğütülmüş \(coffeeAmountManual)g kahveyi üst kısma koyun. Yaklaşık \(brewMin) dakika suyun tamamen üst kısma çıkmasını bekleyin. Isıtıcıyı kapatın ve kahvenin alt hazneye inmesini bekleyin.
                       """
            } else {
                return """
                       Fill the lower part of the syphon with \(waterAmountManual)ml of hot water. Place the upper chamber and filter. \
                       Add \(coffeeAmountManual)g of medium-ground coffee to the upper chamber. Wait about \(brewMin) minutes for all the water to rise. Turn off the heater and wait for the coffee to flow down to the lower chamber.
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
                // Settings summary button
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
                    SyphonSettingsView(
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

                // Instructions & steps
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
            .navigationTitle("Syphon Ayarları")
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

struct SyphonView_Previews: PreviewProvider {
    static var previews: some View {
        SyphonView()
            .environmentObject(CustomRecipeStore())
            .environmentObject(SettingsModel())
            .environmentObject(StoreManager())
    }
}
