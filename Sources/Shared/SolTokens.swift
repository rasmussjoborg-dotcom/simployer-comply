import SwiftUI

public struct SolTokens {
    // MARK: - Linear Dark Obsidian & Surface Architecture (Refined Linear Depth)
    public static let canvasRoot = Color(hex: 0x0B0C0E)   // Deepest window chrome / sidebar background
    public static let paper50  = Color(hex: 0x111216)     // Framed main content canvas
    public static let paper100 = Color(hex: 0x16171D)     // Primary card surface
    public static let paper200 = Color(hex: 0x1C1E25)     // Elevated cards, table headers, hovered rows
    public static let paper250 = Color(hex: 0x22242E)     // Sub-surfaces & inline diff drawers
    public static let paper300 = Color(hex: 0x2A2D3A)     // Hairline 1px border that sticks out cleanly
    public static let paper400 = Color(hex: 0x393D4E)     // Highlighted border / active stroke
    public static let sidebarActivePill = Color(hex: 0x1E2028) // Linear soft active pill
    
    // MARK: - Linear Typography & High-Contrast Ink
    public static let ink900 = Color(hex: 0xF7F8FA)       // High-contrast crisp white primary text
    public static let ink800 = Color(hex: 0xDFE1E8)       // Crisp sub-header text
    public static let ink700 = Color(hex: 0xC5C8D2)       // Body & readable descriptions
    public static let ink600 = Color(hex: 0x8E93A0)       // Secondary metadata & captions
    public static let ink450 = Color(hex: 0x626673)       // Dimmed keycaps, hints & placeholders
    
    // MARK: - Linear Signature Electric Indigo / Blurple meets Sol
    public static let linearIndigo = Color(hex: 0x5E6AD2) // Linear iconic button & primary action
    public static let indigo = linearIndigo               // Direct alias for linearIndigo
    public static let plum900 = Color(hex: 0x5E6AD2)      // Signature electric indigo / primary action
    public static let plum950 = Color(hex: 0x4F59B8)      // Button pressed / deep accent
    public static let plum800 = Color(hex: 0x7A86E8)      // Glowing highlight
    
    public static let lav600 = Color(hex: 0xA5B4FC)       // Focus rings & subtle strokes
    public static let lav500 = Color(hex: 0x818CF8)       // Iconic Linear lavender
    public static let lav400 = Color(hex: 0x93A4F8)       // Bright accent text
    public static let lav100 = Color(hex: 0x1C1D32)       // Subtle violet pill background
    public static let lavBorder = Color(hex: 0x333660)    // Violet border
    public static let lav50  = Color(hex: 0xF5F0FF)       // Contrast text on electric violet
    
    // MARK: - Linear Precision Status Indicators & Muted Micro-Colors (Calm, Never Neon)
    public static let green800 = Color(hex: 0x2E9D68)     // Calm muted green (Compliant / On track)
    public static let green100 = Color(hex: 0x141F1A)     // Quiet dark green ground
    public static let greenBorder = Color(hex: 0x1F382B)
    public static let emerald800 = Color(hex: 0x2E9D68)
    public static let emerald100 = Color(hex: 0x141F1A)
    public static let emeraldBorder = Color(hex: 0x1F382B)
    
    public static let red700 = Color(hex: 0xD14343)       // Muted crimson / brick (Critical risk / Violation)
    public static let red100 = Color(hex: 0x241518)       // Quiet dark red ground
    public static let redBorder = Color(hex: 0x3E1C22)
    public static let coral700 = Color(hex: 0xD14343)
    public static let coral100 = Color(hex: 0x241518)
    public static let coralBorder = Color(hex: 0x3E1C22)
    
    public static let amber400 = Color(hex: 0xD97706)     // Warm muted ochre (Warning / Gap / In progress)
    public static let amber100 = Color(hex: 0x211A11)     // Quiet dark amber ground
    public static let amberBorder = Color(hex: 0x3D2E16)
    
    public static let cyan400 = Color(hex: 0x4896AA)      // Muted steel cyan (Sync / Ingestion)
    public static let cyan100 = Color(hex: 0x111E24)      // Quiet dark cyan ground
    public static let cyanBorder = Color(hex: 0x1B3540)
    
    public static let orange400 = Color(hex: 0xB85D36)    // Muted terracotta / burnt orange
    public static let orange100 = Color(hex: 0x241712)    // Quiet dark orange ground
    public static let orangeBorder = Color(hex: 0x422419)
    
    public static let purple400 = Color(hex: 0x7C78BD)    // Soft slate lavender / muted purple
    public static let purple100 = Color(hex: 0x1C1B2B)    // Quiet dark purple ground
    public static let purpleBorder = Color(hex: 0x333050)
    
    // MARK: - Linear Craft Tokens
    public static let linearGlow = Color(hex: 0x5E6AD2).opacity(0.20)
    public static let hairline = Color.white.opacity(0.08)
    public static let glassChrome = Color(hex: 0x0E0F14).opacity(0.92)
    
#if os(macOS)
    public static let camillaDiskFilePath = "/Users/rasmussjoborg/Documents/antigravity/Simployer Comply/Sources/SimployerComplyMac/Resources/camilla_avatar.png"
    
    public static let camillaAvatar: NSImage? = {
        if let img = NSImage(named: "CamillaAvatar") {
            return img
        }
        let fallbackPaths: [String?] = [
            Bundle.main.path(forResource: "camilla_avatar", ofType: "png"),
            camillaDiskFilePath,
            "/Users/rasmussjoborg/Documents/antigravity/SImployer Comply/Sources/SimployerComplyMac/Resources/camilla_avatar.png"
        ]
        for path in fallbackPaths {
            if let p = path, FileManager.default.fileExists(atPath: p), let img = NSImage(contentsOfFile: p) {
                return img
            }
        }
        return nil
    }()
#endif
}

// MARK: - Linear Typography Engine (Inter Font Integration)

import CoreText

public struct SolTypography {
    public static func registerFonts() {
        let fontNames = ["Inter-Regular", "Inter-Medium", "Inter-SemiBold", "Inter-Bold"]
        for name in fontNames {
            if let fontURL = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") ??
                             Bundle.main.url(forResource: name, withExtension: "ttf") ??
                             Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Resources/Fonts") {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
            }
        }
    }
}

extension Font {
    public static func inter(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = "Inter-Bold"
        case .semibold:
            fontName = "Inter-SemiBold"
        case .medium:
            fontName = "Inter-Medium"
        case .light, .ultraLight, .thin:
            fontName = "Inter-Light"
        default:
            fontName = "Inter-Regular"
        }
        return .custom(fontName, size: size)
    }
    
    public static func inter(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        inter(size, weight)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Linear Native UI Elements & Micro-Highlights

public struct LinearStatusPill: View {
    public let text: String
    public let dotColor: Color
    public var bgColor: Color?
    public var borderColor: Color?
    public var textColor: Color?
    
    public init(text: String, dotColor: Color, bgColor: Color? = nil, borderColor: Color? = nil, textColor: Color? = nil) {
        self.text = text
        self.dotColor = dotColor
        self.bgColor = bgColor
        self.borderColor = borderColor
        self.textColor = textColor
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(dotColor)
                .frame(width: 5, height: 5)
            Text(text)
                .font(.inter(11.5, .medium))
                .foregroundColor(textColor ?? SolTokens.ink700)
                .lineLimit(1)
        }
        .padding(.horizontal, 7.5)
        .padding(.vertical, 3.5)
        .background(bgColor ?? SolTokens.paper200)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor ?? SolTokens.paper300, lineWidth: 1)
        )
    }
}

public struct LinearAvatarBadge: View {
    public let name: String
    public var size: CGFloat
    
    public init(name: String, size: CGFloat = 26) {
        self.name = name
        self.size = size
    }
    
    public var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))"
        }
        return String(name.prefix(2)).uppercased()
    }
    
    public var avatarColor: (bg: Color, text: Color) {
        let hash = abs(name.hashValue)
        let colors: [(Color, Color)] = [
            (Color(hex: 0x8C4A32), Color.white), // Muted Terracotta
            (Color(hex: 0x3E5A47), Color.white), // Dusty Sage
            (Color(hex: 0x475569), Color.white), // Muted Slate
            (Color(hex: 0x855420), Color.white), // Dusty Ochre
            (Color(hex: 0x5C4668), Color.white), // Soft Mauve
            (Color(hex: 0x335968), Color.white), // Muted Denim
            (Color(hex: 0x6E4C30), Color.white)  // Warm Bronze
        ]
        return colors[hash % colors.count]
    }
    
    public var body: some View {
        let col = avatarColor
        ZStack {
            Circle()
                .fill(col.bg)
                .frame(width: size, height: size)
                .overlay(Circle().stroke(SolTokens.paper300.opacity(0.6), lineWidth: 1))
            Text(initials)
                .font(.system(size: size * 0.40, weight: .semibold, design: .rounded))
                .foregroundColor(col.text)
        }
    }
}

// MARK: - Simployer Brand Logo Asset & Vector Views

#if os(macOS)
import AppKit
#endif

public struct SimployerLogoAsset {
    public static let svgString = """
<svg width="159" height="159" viewBox="0 0 159 159" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M92.328 53.1925H66.3709C59.8422 53.1925 54.5244 58.3046 54.5244 64.5643C54.5244 70.824 59.9475 76.249 66.3709 76.249H93.4863C104.28 76.249 113.02 84.4388 113.02 94.5065C113.02 104.574 104.227 112.764 93.4863 112.764H46.7847C44.5733 112.764 42.7832 114.537 42.7832 116.728C42.7832 118.919 44.5733 120.693 46.7847 120.693H93.4863C108.65 120.693 120.97 108.956 120.97 94.5065C120.97 80.057 108.65 68.3201 93.4863 68.3201H66.3709C64.3175 68.3201 62.4747 66.5465 62.4747 64.5643C62.4747 62.5821 64.2122 61.0693 66.3709 61.0693H92.328C111.967 61.0693 127.92 76.0404 127.92 94.5065C127.92 112.973 111.967 127.944 92.328 127.944H79.7443C77.533 127.944 75.7955 129.717 75.7955 131.908C75.7955 134.099 77.5856 135.873 79.7443 135.873H92.328C116.337 135.873 135.87 117.354 135.87 94.5586C135.87 71.7629 116.337 53.2447 92.328 53.2447V53.1925Z" fill="#FFFDFD"/>
<path d="M66.6675 105.807H92.6245C99.1533 105.807 104.471 100.695 104.471 94.4353C104.471 88.1756 99.048 82.7506 92.6245 82.7506H65.5092C54.7157 82.7506 45.9756 74.5608 45.9756 64.4932C45.9756 54.4255 54.7684 46.2357 65.5092 46.2357H112.211C114.422 46.2357 116.212 44.4622 116.212 42.2713C116.212 40.0804 114.422 38.3068 112.211 38.3068H65.5092C50.3457 38.3068 38.0253 50.0437 38.0253 64.4932C38.0253 78.9426 50.3457 90.6795 65.5092 90.6795H92.6245C94.6779 90.6795 96.5207 92.4531 96.5207 94.4353C96.5207 96.4175 94.7832 97.9303 92.6245 97.9303H66.6675C47.0286 97.9303 31.0753 82.9592 31.0753 64.4932C31.0753 46.0271 47.0286 31.056 66.6675 31.056H79.2511C81.4625 31.056 83.2 29.2824 83.2 27.0915C83.2 24.9007 81.4098 23.1792 79.2511 23.1271H66.6675C42.6586 23.1271 23.125 41.6453 23.125 64.441C23.125 87.2367 42.6586 105.755 66.6675 105.807Z" fill="#FFFDFD"/>
</svg>
"""

#if os(macOS)
    nonisolated(unsafe) public static let sourceImage: NSImage? = {
        if let data = svgString.data(using: .utf8), let img = NSImage(data: data) {
            return img
        }
        return nil
    }()
    
    nonisolated(unsafe) public static let menuBarIcon: NSImage? = {
        guard let source = sourceImage else { return nil }
        let targetSize = NSSize(width: 18, height: 18)
        let img = NSImage(size: targetSize, flipped: false) { rect in
            source.draw(in: rect, from: NSRect(origin: .zero, size: source.size), operation: .sourceOver, fraction: 1.0)
            return true
        }
        img.isTemplate = true
        return img
    }()
    
    nonisolated(unsafe) public static let plumBadgeIcon: NSImage? = {
        guard let source = sourceImage else { return nil }
        let size = NSSize(width: 20, height: 20)
        let img = NSImage(size: size, flipped: false) { rect in
            let path = NSBezierPath(roundedRect: rect, xRadius: 4.5, yRadius: 4.5)
            // Simployer plum color: #2D0C69
            NSColor(red: 0x2D/255.0, green: 0x0C/255.0, blue: 0x69/255.0, alpha: 1.0).setFill()
            path.fill()
            let iconRect = rect.insetBy(dx: 2.5, dy: 2.5)
            source.draw(in: iconRect, from: NSRect(origin: .zero, size: source.size), operation: .sourceOver, fraction: 1.0)
            return true
        }
        return img
    }()
    
    nonisolated(unsafe) private static var _cachedStatusIcons: [ComplyStore.ComplianceSeverity: NSImage] = [:]
    
    public static func menuBarStatusIcon(severity: ComplyStore.ComplianceSeverity) -> NSImage? {
        if let cached = _cachedStatusIcons[severity] {
            return cached
        }
        guard let source = sourceImage else { return nil }
        let targetSize = NSSize(width: 18, height: 18)
        let img = NSImage(size: targetSize, flipped: false) { rect in
            let isDark = NSAppearance.currentDrawing().bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let swirlColor = isDark ? NSColor.white : NSColor(white: 0.15, alpha: 1.0)
            
            // Draw swirl
            if let cg = source.cgImage(forProposedRect: nil, context: nil, hints: nil),
               let ctx = NSGraphicsContext.current?.cgContext {
                ctx.saveGState()
                ctx.clip(to: rect, mask: cg)
                swirlColor.setFill()
                rect.fill()
                ctx.restoreGState()
            } else {
                source.draw(in: rect, from: NSRect(origin: .zero, size: source.size), operation: .sourceOver, fraction: 1.0)
            }
            
            // Cutout for status dot in bottom right
            let dotRect = NSRect(x: 10.5, y: 1.0, width: 6.5, height: 6.5)
            let borderRect = dotRect.insetBy(dx: -1.0, dy: -1.0)
            
            let ctx = NSGraphicsContext.current?.cgContext
            ctx?.saveGState()
            ctx?.setBlendMode(.clear)
            ctx?.fillEllipse(in: borderRect)
            ctx?.restoreGState()
            
            // Teams-style semantic status dot
            let dotColor: NSColor
            switch severity {
            case .compliant:
                dotColor = NSColor(red: 0.13, green: 0.77, blue: 0.36, alpha: 1.0) // #22C55E Green
            case .warning:
                dotColor = NSColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1.0) // #F59E0B Amber
            case .behind:
                dotColor = NSColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1.0) // #EF4444 Red
            }
            dotColor.setFill()
            let dotPath = NSBezierPath(ovalIn: dotRect)
            dotPath.fill()
            
            return true
        }
        _cachedStatusIcons[severity] = img
        return img
    }
#endif
}

public struct SimployerLogoView: View {
    public var tint: Color? = nil
    
    public init(tint: Color? = nil) {
        self.tint = tint
    }
    
    public var body: some View {
        #if os(macOS)
        if let nsImg = SimployerLogoAsset.sourceImage {
            Image(nsImage: nsImg)
                .renderingMode(tint != nil ? .template : .original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(tint)
        } else {
            Image(systemName: "shield.checkered")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        #else
        Image(systemName: "shield.checkered")
            .resizable()
            .aspectRatio(contentMode: .fit)
        #endif
    }
}
