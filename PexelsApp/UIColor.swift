//
//  UIColor.swift
//  PexelsApp
//
//  Created by Daniel Bell on 4/30/22.
//

import UIKit

//https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }

        return nil
    }

    var isLight: Bool? {
        guard let components = cgColor.components, components.count > 3 else {
            return nil
        }
        let redBrightness = components[0] * 255 * 299
        let greenBrightness = components[1] * 255 * 587
        let blueBrightness = components[2] * 255 * 114
        let brightness = (redBrightness + greenBrightness + blueBrightness) / 1000
        return brightness > 125
    }
}

