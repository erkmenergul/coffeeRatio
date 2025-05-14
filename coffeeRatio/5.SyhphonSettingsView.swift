//  5.SyphonSettingsView.swift

//  SyphonSettingsView.swift

import SwiftUI

struct SyphonSettingsView: View {
    @Binding var cupCount: Int
    @Binding var coffeeAmountManual: Int
    @Binding var waterAmountManual: Int
    @Binding var selectedRatio: Int
    @Binding var grinderSetting: String
    @Binding var brewingTime: TimeInterval
    @Binding var waterTemperature: Int
    let coffeePerCup: Double

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsModel

    private var numberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }

    private func timeString(from t: TimeInterval) -> String {
        let m = Int(t) / 60, s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
    private func fahrenheit(from c: Int) -> Int { Int(Double(c) * 9/5 + 32) }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bardak")) {
                    Stepper("Bardak: \(cupCount)", value: $cupCount, in: 1...4)
                }
                Section(header: Text("Kahve & Su")) {
                    if settings.selectedUnit == "Imperial" {
                        HStack {
                            Text("Kahve:")
                            Spacer()
                            let oz = String(format: "%.2f", UnitConverter.gramsToOunces(Double(coffeeAmountManual)))
                            Text("\(oz) oz")
                        }
                        HStack {
                            Text("Su:")
                            Spacer()
                            let fl = String(format: "%.2f", UnitConverter.millilitersToFluidOunces(Double(waterAmountManual)))
                            Text("\(fl) fl oz")
                        }
                    } else {
                        HStack {
                            Text("Kahve:")
                            Spacer()
                            TextField("", value: $coffeeAmountManual, formatter: numberFormatter)
                                .keyboardType(.numberPad)
                            Text("gr")
                        }
                        HStack {
                            Text("Su:")
                            Spacer()
                            TextField("", value: $waterAmountManual, formatter: numberFormatter)
                                .keyboardType(.numberPad)
                            Text("ml")
                        }
                    }
                }
                Section(header: Text("Oran")) {
                    Picker("Oran", selection: $selectedRatio) {
                        Text("1/13").tag(13)
                        Text("1/14").tag(14)
                        Text("1/15").tag(15)
                        Text("1/16").tag(16)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Su Sıcaklığı")) {
                    HStack {
                        Text("Su Sıcaklığı:")
                        Spacer()
                        Picker("", selection: $waterTemperature) {
                            ForEach(92...95, id: \.self) { t in
                                if settings.selectedUnit == "Imperial" {
                                    Text("\(fahrenheit(from: t))°F").tag(t)
                                } else {
                                    Text("\(t)°C").tag(t)
                                }
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                Section(header: Text("Öğütücü Ayarı")) {
                    TextField("Öğütücü ayarını giriniz", text: $grinderSetting)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Section(header: Text("Demleme Süresi")) {
                    VStack(alignment: .leading) {
                        Text("Süre: \(timeString(from: brewingTime))")
                        Slider(value: $brewingTime, in: 60...600, step: 15)
                            .accentColor(.orange)
                    }
                }
            }
            .onAppear { if waterTemperature == 0 { waterTemperature = 95 } }
            .onChange(of: cupCount) { v in
                switch v {
                case 1:
                    coffeeAmountManual = 15; waterAmountManual = 225; brewingTime = 3 * 60
                case 2:
                    coffeeAmountManual = 30; waterAmountManual = 450; brewingTime = 4 * 60
                case 3:
                    coffeeAmountManual = 40; waterAmountManual = 675; brewingTime = 5 * 60
                case 4:
                    coffeeAmountManual = 50; waterAmountManual = 900; brewingTime = 6 * 60
                default:
                    break
                }
            }
            .onChange(of: selectedRatio) { newRatio in
                waterAmountManual = cupCount * Int(coffeePerCup) * newRatio
            }
            .navigationTitle("Syphon Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Tamam") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}

struct SyphonSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SyphonSettingsView(
            cupCount: .constant(1),
            coffeeAmountManual: .constant(15),
            waterAmountManual: .constant(225),
            selectedRatio: .constant(15),
            grinderSetting: .constant("Medium"),
            brewingTime: .constant(180),
            waterTemperature: .constant(95),
            coffeePerCup: 20.0
        )
        .environmentObject(SettingsModel())
        .environmentObject(CustomRecipeStore())
    }
}
