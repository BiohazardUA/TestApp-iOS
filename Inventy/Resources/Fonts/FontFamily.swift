import UIKit.UIFont

enum FontFamily {
    
    // swiftlint:disable line_length
    enum Lobster {
        static let regular = FontConvertible(name: "Lobster-Regular", family: "Lobster", path: "Lobster-Regular.ttf")
        static let all: [FontConvertible] = [regular]
    }
    
    enum Oswald {
        static let bold = FontConvertible(name: "Oswald-Bold", family: "Oswald", path: "Oswald-Bold.ttf")
        static let extraLight = FontConvertible(name: "Oswald-ExtraLight", family: "Oswald", path: "Oswald-ExtraLight.ttf")
        static let light = FontConvertible(name: "Oswald-Light", family: "Oswald", path: "Oswald-Light.ttf")
        static let medium = FontConvertible(name: "Oswald-Medium", family: "Oswald", path: "Oswald-Medium.ttf")
        static let regular = FontConvertible(name: "Oswald-Regular", family: "Oswald", path: "Oswald-Regular.ttf")
        static let semiBold = FontConvertible(name: "Oswald-SemiBold", family: "Oswald", path: "Oswald-SemiBold.ttf")
        static let all: [FontConvertible] = [bold, extraLight, light, medium, regular, semiBold]
    }
    static let allCustomFonts: [FontConvertible] = [Lobster.all, Oswald.all].flatMap { $0 }
    static func registerAllCustomFonts() {
        allCustomFonts.forEach { $0.register() }
    }
}

// MARK: - Implementation Details
struct FontConvertible {
    
    let name: String
    let family: String
    let path: String
    
    func font(size: CGFloat) -> UIFont! {
        return UIFont(font: self, size: size)
    }
    
    func register() {
        guard let url = url else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
    
    fileprivate var url: URL? {
        let bundle = Bundle(for: BundleToken.self)
        return bundle.url(forResource: path, withExtension: nil)
    }
}

extension UIFont {
    
    convenience init!(font: FontConvertible, size: CGFloat) {
        if UIFont.fontNames(forFamilyName: font.family).contains(font.name) == false {
            font.register()
        }
        
        self.init(name: font.name, size: size)
    }
}

private final class BundleToken {}
