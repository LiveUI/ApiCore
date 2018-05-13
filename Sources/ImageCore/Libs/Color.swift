//
//  Color.swift
//  ImageCore
//
//  Created by Ondrej Rafaj on 15/04/2018.
//

import Foundation


/// Color
public class Color {
    
    /// Red
    public let r: Int
    
    /// Green
    public let g: Int
    
    /// Blue
    public let b: Int
    
    
    // MARK: Initialization
    
    /// Initializer
    public init(r: Int, g: Int, b: Int) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    // MARK: Public interface
    
    /// Value of the color in hex (FF0000)
    public var hexValue: String {
        return Color.convert(r: r, g: g, b: b)
    }
    
    /// Is the color dark?
    public var isDark: Bool {
        let RGB = floatComponents()
        return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
    }
    
    /// Is the color B/W
    public var isBlackOrWhite: Bool {
        let RGB = floatComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91) || (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    /// Is the color black
    public var isBlack: Bool {
        let RGB = floatComponents()
        return (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    /// Is the color white
    public var isWhite: Bool {
        let RGB = floatComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91)
    }
    
    /// Is the color distinct from another color
    public func isDistinct(from color: Color) -> Bool {
        let bg = floatComponents()
        let fg = color.floatComponents()
        let threshold: Double = 0.25
        var result = false
        
        if fabs(bg[0] - fg[0]) > threshold || fabs(bg[1] - fg[1]) > threshold || fabs(bg[2] - fg[2]) > threshold {
            if fabs(bg[0] - bg[1]) < 0.03 && fabs(bg[0] - bg[2]) < 0.03 {
                if fabs(fg[0] - fg[1]) < 0.03 && fabs(fg[0] - fg[2]) < 0.03 {
                    result = false
                }
            }
            result = true
        }
        
        return result
    }
    
    /// Is color contrasting with nother color
    public func isContrasting(with color: Color) -> Bool {
        let bg = floatComponents()
        let fg = color.floatComponents()
        
        let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
        let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.0722 * fg[2]
        let contrast = bgLum > fgLum
            ? (bgLum + 0.05) / (fgLum + 0.05)
            : (fgLum + 0.05) / (bgLum + 0.05)
        
        return 1.6 < contrast
    }
    
    // MARK: Private interface
    
    /// Float components
    internal func floatComponents() -> [Double] {
        return [r.floatColorValue, g.floatColorValue, b.floatColorValue]
    }
    
    /// Random value
    internal static var random: Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
    
    // MARK: Static helpers
    
    /// Convert color to hex
    public static func convert(r: Int, g: Int, b: Int) -> String {
        let hexValue = String(format:"%02X", r) + String(format:"%02X", g) + String(format:"%02X", b)
        return hexValue
    }
    
    /// Get random color
    public static func randomColor() -> Color {
        return Color(r: .random, g: .random, b: .random)
    }
    
}


extension Int {
    
    /// Float color value
    internal var floatColorValue: Double {
        return Double(self) / 255.0
    }
    
    /// Random value
    internal static var random: Int {
        return Int((Double(arc4random()) / Double(UInt32.max)) * 256.0)
    }
    
}
