// Models/FontStyle.swift
import Foundation

/// All the Unicode “Mathematical Alphanumeric” styles you support.
enum FontStyle: String, CaseIterable, Identifiable {
    case normal               = "normal Latin Alphanumeric"
    case normalMath           = "normal Mathematical Alphanumeric"
    case bold                 = "bold Mathematical Alphanumeric"
    case italic               = "italic Mathematical Alphanumeric"
    case boldItalic           = "bold＋italic Mathematical Alphanumeric"
    case sansSerif            = "normal Sans-Serif Mathematical Alphanumeric"
    case sansSerifBold        = "bold Sans-Serif Mathematical Alphanumeric"
    case sansSerifItalic      = "italic Sans-Serif Mathematical Alphanumeric"
    case sansSerifBoldItalic  = "bold＋italic Sans-Serif Mathematical Alphanumeric"
    case script               = "normal Calligraphic Script Mathematical Alphanumeric"
    case boldScript           = "bold Calligraphic Script Mathematical Alphanumeric"
    case fraktur              = "normal Fraktur Mathematical Alphanumeric"
    case boldFraktur          = "bold Fraktur Mathematical Alphanumeric"
    case monospace            = "monospace Mathematical Alphanumeric"
    case doubleStruck         = "doublestruck bold Mathematical Alphanumeric"

    var id: String { rawValue }
}

/// Maps ASCII letters/digits into the various Unicode‐math styled blocks.
class FontStyleMapper {
    static let shared = FontStyleMapper()

    private let uppercaseBases: [FontStyle: UInt32] = [
        .bold: UInt32(0x1D400),
        .italic: UInt32(0x1D434),
        .boldItalic: UInt32(0x1D468),
        .script: UInt32(0x1D49C),
        .boldScript: UInt32(0x1D4D0),
        .fraktur: UInt32(0x1D504),
        .doubleStruck: UInt32(0x1D538),
        .sansSerif: UInt32(0x1D5A0),
        .sansSerifBold: UInt32(0x1D5D4),
        .sansSerifItalic: UInt32(0x1D608),
        .sansSerifBoldItalic: UInt32(0x1D63C),
        .monospace: UInt32(0x1D670)
    ]

    private let lowercaseBases: [FontStyle: UInt32] = [
        .bold: UInt32(0x1D41A),
        .italic: UInt32(0x1D44E),
        .boldItalic: UInt32(0x1D482),
        .script: UInt32(0x1D4B6),
        .boldScript: UInt32(0x1D4EA),
        .fraktur: UInt32(0x1D51E),
        .doubleStruck: UInt32(0x1D552),
        .sansSerif: UInt32(0x1D5BA),
        .sansSerifBold: UInt32(0x1D5EE),
        .sansSerifItalic: UInt32(0x1D622),
        .sansSerifBoldItalic: UInt32(0x1D656),
        .monospace: UInt32(0x1D68A)
    ]

    private let digitBases: [FontStyle: UInt32] = [
        .bold: UInt32(0x1D7CE),
        .doubleStruck: UInt32(0x1D7D8),
        .sansSerif: UInt32(0x1D7E2),
        .sansSerifBold: UInt32(0x1D7EC),
        .monospace: UInt32(0x1D7F6)
    ]

    private var reverseMap: [UInt32: UInt32] = [:]

    private init() {
        // Build reverseMap so we can map styled→ASCII
        for (style, base) in uppercaseBases {
            for i in UInt32(0)..<26 {
                reverseMap[base + i] = 0x41 + i
            }
        }
        for (style, base) in lowercaseBases {
            for i in UInt32(0)..<26 {
                reverseMap[base + i] = 0x61 + i
            }
        }
        for (style, base) in digitBases {
            for i in UInt32(0)..<10 {
                reverseMap[base + i] = 0x30 + i
            }
        }
    }

    /// Convert a single character to the given style, preserving non-alphanumerics.
    func map(_ char: Character, style: FontStyle) -> Character {
        guard let scalar = char.unicodeScalars.first else { return char }
        let v = scalar.value
        // 1) If already styled, map back to ASCII
        let ascii = reverseMap[v] ?? v
        // 2) Identity for normal
        if style == .normal || style == .normalMath {
            return Character(UnicodeScalar(ascii)!)
        }
        // 3) Map ASCII→target style
        if (0x41...0x5A).contains(ascii), let base = uppercaseBases[style] {
            return Character(UnicodeScalar(base + (ascii - 0x41))!)
        }
        if (0x61...0x7A).contains(ascii), let base = lowercaseBases[style] {
            return Character(UnicodeScalar(base + (ascii - 0x61))!)
        }
        if (0x30...0x39).contains(ascii), let base = digitBases[style] {
            return Character(UnicodeScalar(base + (ascii - 0x30))!)
        }
        return char
    }
}
