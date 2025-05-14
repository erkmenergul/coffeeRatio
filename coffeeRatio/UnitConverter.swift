//  UnitConverter.swift

import Foundation

struct UnitConverter {
    static func gramsToOunces(_ grams: Double) -> Double {
        return grams * 0.0353
    }
    
    static func millilitersToFluidOunces(_ ml: Double) -> Double {
        return ml * 0.0338
    }
    
    // İsteğe bağlı: Cup hesaplaması (örneğin 1 cup = 240 ml)
    static func millilitersToCups(_ ml: Double) -> Double {
        return ml / 240.0
    }
}

