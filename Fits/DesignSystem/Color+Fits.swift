//
//  Color+Fits.swift
//  Fits
//

import SwiftUI

extension Color {
    static let alabasterGrey = Color(hex: "D8E2DC")
    static let powderPetal   = Color(hex: "FFE5D9")
    static let pastelPink    = Color(hex: "FFCAD4")
    static let cherryBlossom = Color(hex: "F4ACB7")
    static let dustyMauve    = Color(hex: "9D8189")

    init(hex: String) {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

enum FitsTheme {
    static let background = Color.powderPetal
    static let surface    = Color.white
    static let muted      = Color.alabasterGrey
    static let highlight  = Color.pastelPink
    static let accent     = Color.cherryBlossom
    static let primary    = Color.dustyMauve
}
