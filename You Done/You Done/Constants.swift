//
//  Constants.swift
//  You Done
//
//  Created by Piotr Galar on 12/12/2020.
//

import Foundation
import SwiftUI

class Constants {
    private init() {}
    
    static let ButtonWidth: CGFloat? = 22.0
    static let ButtonHeight: CGFloat? = 22.0
    static let ButtonLeadingPadding: CGFloat? = 4.0
    
    static let BigShadowRadius: CGFloat = 5.0
    static let ShadowRadius: CGFloat = 1.0
    
    static let BigButtonWidth: CGFloat? = 32.0
    static let BigButtonHeight: CGFloat? = 32.0
    static let BigButtonLeadingPadding: CGFloat? = 12.0
    
    static let MagicMint: Color = Color(red: 161 / 255, green: 232 / 255, blue: 195 / 255)
    static let AeroBlue: Color = Color(red: 204 / 255, green: 243 / 255, blue: 226 / 255)
    
    static let NaplesYellow: Color = Color(red: 246 / 255, green: 224 / 255, blue: 110 / 255)
    static let GreenYellowCrayola: Color = Color(red: 251 / 255, green: 242 / 255, blue: 170 / 255)
    
    static let PearlyPurple: Color = Color(red: 198 / 255, green: 104 / 255, blue: 185 / 255)
    static let Mauve: Color = Color(red: 225 / 255, green: 189 / 255, blue: 252 / 255)
    static let DarkPurple: Color = Color(red: 60 / 255, green: 18 / 255, blue: 44 / 255)
    
    static let WildBlueYonder: Color = Color(red: 177 / 255, green: 182 / 255, blue: 225 / 255)
    static let White = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    
    static let Fawn: Color = Color(red: 221 / 255, green: 168 / 255, blue: 106/255)
    static let MiddlePurple: Color = Color(red: 215 / 255, green: 137 / 255, blue: 185 / 255)
    
    static let Colours: [Color] = [
        MagicMint, AeroBlue, NaplesYellow, GreenYellowCrayola, PearlyPurple, Mauve, DarkPurple, WildBlueYonder, White, Fawn, MiddlePurple
    ]
}

extension Color {
    func toUserDefaults(forKey key: String) {
        UserDefaults.standard.setValue(description, forKey: key)
    }
    
    static func fromUserDefaults(forKey key: String) -> Color? {
        guard let description = UserDefaults.standard.string(forKey: key) else { return nil }
        return Color.fromDescription(description)
    }
    
    static func fromDescription(_ description: String) -> Color? {
        switch description {
        case "AccentColorProvider()":
            return Color.accentColor
        case "black":
            return Color.black
        case "blue":
            return Color.blue
        case "gray":
            return Color.gray
        case "green":
            return Color.green
        case "orange":
            return Color.orange
        case "pink":
            return Color.pink
        case "primary":
            return Color.primary
        case "purple":
            return Color.purple
        case "red":
            return Color.red
        case "secondary":
            return Color.secondary
        case "white":
            return Color.white
        case "yellow":
            return Color.yellow
        case _ where description.starts(with: "#"):
            let components = Array(description).map { String($0) }
            let r = Double(Int(components[1] + components[2], radix: 16)!) / 255.0
            let g = Double(Int(components[3] + components[4], radix: 16)!) / 255.0
            let b = Double(Int(components[5] + components[6], radix: 16)!) / 255.0
            let o = Double(Int(components[7] + components[8], radix: 16)!) / 255.0
            return Color(.sRGB, red: r, green: g, blue: b, opacity: o)
        default:
            return nil
        }
    }
}

class ColourScheme: ObservableObject {
    @Published var headerBackground: Color = Color.fromUserDefaults(forKey: "Header Background") ?? Constants.MagicMint
    @Published var headerText: Color = Color.fromUserDefaults(forKey: "Header Text") ?? Constants.DarkPurple
    @Published var bodyBackground: Color = Color.fromUserDefaults(forKey: "Body Background") ?? Constants.WildBlueYonder
    @Published var bodyText: Color = Color.fromUserDefaults(forKey: "Body Text") ?? Constants.White
    
    func commitHeaderBackground() {
        headerBackground.toUserDefaults(forKey: "Header Background")
    }
    func commitHeaderText() {
        headerText.toUserDefaults(forKey: "Header Text")
    }
    func commitBodyBackground() {
        bodyBackground.toUserDefaults(forKey: "Body Background")
    }
    func commitBodyText() {
        bodyText.toUserDefaults(forKey: "Body Text")
    }

}
