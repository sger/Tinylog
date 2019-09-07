//
//  UIFont+TinylogiOSAdditions.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_unwrapping
import UIKit

let kTLIRegularFontName: NSString = "HelveticaNeue"
let kTLIBoldFontName: NSString = "HelveticaNeue-Bold"
let kTLIBoldItalicFontName: NSString = "HelveticaNeue-BoldItalic"
let kTLIItalicFontName: NSString = "HelveticaNeue-Italic"

@available(iOS 8.2, *)
let kTLIRegularSFFontName: NSString = UIFont.systemFont(
    ofSize: 10.0,
    weight: UIFont.Weight.regular).fontName as NSString //".SFUIText-Regular"
@available(iOS 8.2, *)
let kTLIBoldSFFontName: NSString = UIFont.systemFont(
    ofSize: 10.0,
    weight: UIFont.Weight.bold).fontName as NSString //".SFUIText-Bold"
@available(iOS 8.2, *)
let kTLIBoldItalicSFFontName: NSString = UIFont.systemFont(
    ofSize: 10.0,
    weight: UIFont.Weight.medium).fontName as NSString //".SFUIText-Medium"
@available(iOS 8.2, *)
let kTLIItalicSFFontName: NSString = UIFont.systemFont(
    ofSize: 10.0,
    weight: UIFont.Weight.light).fontName as NSString //".SFUIText-Light"

let kTLIFontRegularKey: NSString = "Regular"
let kTLIFontItalicKey: NSString = "Italic"
let kTLIFontBoldKey: NSString = "Bold"
let kTLIFontBoldItalicKey: NSString = "BoldItalic"

let kTLIFontDefaultsKey: NSString = "TLIFontDefaults"
let kTLIFontSanFranciscoKey: NSString = "SanFrancisco"
let kTLIFontHelveticaNeueKey: NSString = "HelveticaNeue"
let kTLIFontAvenirKey: NSString = "Avenir"
let kTLIFontHoeflerKey: NSString = "Hoefler"
let kTLIFontCourierKey: NSString = "Courier"
let kTLIFontGeorgiaKey: NSString = "Georgia"
let kTLIFontMenloKey: NSString = "Menlo"
let kTLIFontTimesNewRomanKey: NSString = "TimesNewRoman"
let kTLIFontPalatinoKey: NSString = "Palatino"
let kTLIFontIowanKey: NSString = "Iowan"

// MARK: Extensions UIFont

extension UIFont {

    class func mediumFontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
    }

    class func regularFontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
    }

    class func tinylogFontMapForFontKey(_ key: NSString) -> NSDictionary? {
        var fontDictionary: NSDictionary?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {

            let sf = NSDictionary(objects: [
                ".SFUIText-Regular",
                ".SFUIText-Light",
                ".SFUIText-Bold",
                ".SFUIText-Medium"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let helveticaNeue = NSDictionary(objects: [
                "HelveticaNeue",
                "HelveticaNeue-Italic",
                "HelveticaNeue-Bold",
                "HelveticaNeue-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let avenir = NSDictionary(objects: [
                "Avenir-Book",
                "Avenir-BookOblique",
                "Avenir-Black",
                "Avenir-BlackOblique"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let hoefler = NSDictionary(objects: [
                "HoeflerText-Regular",
                "HoeflerText-Italic",
                "HoeflerText-Black",
                "HoeflerText-BlackItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let courier = NSDictionary(objects: [
                "Courier",
                "Courier-Oblique",
                "Courier-Bold",
                "Courier-BoldOblique"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let georgia = NSDictionary(objects: [
                "Georgia",
                "Georgia-Italic",
                "Georgia-Bold",
                "Georgia-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let menlo = NSDictionary(objects: [
                "Menlo-Regular",
                "Menlo-Italic",
                "Menlo-Bold",
                "Menlo-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let timesNewRoman = NSDictionary(objects: [
                "TimesNewRomanPSMT",
                "TimesNewRomanPS-ItalicMT",
                "TimesNewRomanPS-BoldMT",
                "TimesNewRomanPS-BoldItalicMT"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let palatino = NSDictionary(objects: [
                "Palatino-Roman",
                "Palatino-Italic",
                "Palatino-Bold",
                "Palatino-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let iowan = NSDictionary(objects: [
                "IowanOldStyle-Roman",
                "IowanOldStyle-Italic",
                "IowanOldStyle-Bold",
                "IowanOldStyle-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

                let defaultFontSF = NSDictionary(objects: [
                    kTLIRegularSFFontName,
                    kTLIItalicSFFontName,
                    kTLIBoldSFFontName,
                    kTLIBoldItalicSFFontName], forKeys: [
                        kTLIFontRegularKey,
                        kTLIFontItalicKey,
                        kTLIFontBoldKey,
                        kTLIFontBoldItalicKey])

                fontDictionary = NSDictionary(objects: [
                    defaultFontSF,
                    sf,
                    helveticaNeue,
                    avenir,
                    hoefler,
                    courier,
                    georgia,
                    menlo,
                    timesNewRoman,
                    palatino,
                    iowan], forKeys: [
                        kTLIFontSanFranciscoKey,
                        kTLIFontSanFranciscoKey,
                        kTLIFontHelveticaNeueKey,
                        kTLIFontAvenirKey,
                        kTLIFontHoeflerKey,
                        kTLIFontCourierKey,
                        kTLIFontGeorgiaKey,
                        kTLIFontMenloKey,
                        kTLIFontTimesNewRomanKey,
                        kTLIFontPalatinoKey,
                        kTLIFontIowanKey])

        }

        return fontDictionary!.object(forKey: key) as? NSDictionary
    }

    class func tinylogFontNameForFontKey(_ key: NSString, style: NSString) -> NSString? {
        return UIFont.tinylogFontMapForFontKey(key)?.object(forKey: style)! as? NSString
    }

    class func tinylogFontNameForStyle(_ style: NSString) -> NSString? {
        return UIFont.tinylogFontNameForFontKey(
            SettingsFontPickerViewController.selectedKey()!,
            style: style)
    }

    // MARK: Fonts
    class func tinylogFontOfSize(_ fontSize: CGFloat, key: NSString) -> UIFont? {
        let fontName: NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontRegularKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }

    class func italicTinylogFontOfSize(_ fontSize: CGFloat, key: NSString) -> UIFont? {
        let fontName: NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontItalicKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }

    class func boldTinylogFontOfSize(_ fontSize: CGFloat, key: NSString) -> UIFont? {
        let fontName: NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontBoldKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }

    class func boldItalicTinylogFontOfSize(_ fontSize: CGFloat, key: NSString) -> UIFont? {
        let fontName: NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontBoldItalicKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }

    // MARK: Standard

    class func tinylogFontOfSize(_ fontSize: CGFloat) -> UIFont {
        var size: CGFloat = fontSize
        size += SettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.tinylogFontOfSize(fontSize, key: SettingsFontPickerViewController.selectedKey()!)!
    }

    class func italicTinylogFontOfSize(_ fontSize: CGFloat) -> UIFont {
        var size: CGFloat = fontSize
        size += SettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.italicTinylogFontOfSize(
            fontSize,
            key: SettingsFontPickerViewController.selectedKey()!)!
    }

    class func boldTinylogFontOfSize(_ fontSize: CGFloat) -> UIFont {
        var size: CGFloat = fontSize
        size += SettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.boldTinylogFontOfSize(
            fontSize,
            key: SettingsFontPickerViewController.selectedKey()!)!
    }

    class func boldItalicTinylogFontOfSize(_ fontSize: CGFloat) -> UIFont {
        var size: CGFloat = fontSize
        size += SettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.boldItalicTinylogFontOfSize(
            fontSize,
            key: SettingsFontPickerViewController.selectedKey()!)!
    }

    // MARK: Interface
    class func tinylogInterfaceFontOfSize(_ fontSize: CGFloat) -> UIFont? {
        return UIFont(name: kTLIRegularFontName as String, size: fontSize)
    }

    class func boldTinylogInterfaceFontOfSize(_ fontSize: CGFloat) -> UIFont? {
        return UIFont(name: kTLIBoldFontName as String, size: fontSize)
    }

    class func italicTinylogInterfaceFontOfSize(_ fontSize: CGFloat) -> UIFont? {
        return UIFont(name: kTLIItalicFontName as String, size: fontSize)
    }

    class func boldItalicTinylogInterfaceFontOfSize(_ fontSize: CGFloat) -> UIFont? {
        return UIFont(name: kTLIBoldItalicFontName as String, size: fontSize)
    }

    class func preferredHelveticaNeueFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "HelveticaNeue"
        let fontNameMedium: NSString = "HelveticaNeue-Medium"
        // swiftlint:disable syntactic_sugar
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                                                      UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                                                      UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                                                      UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                                                      UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                                                      UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                                                  UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                                                  UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                                                  UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                                                  UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                                                  UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                                             UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                                             UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                                             UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                                             UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                                             UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                                              UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                                              UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                                              UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                                              UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                                              UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                                                       UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                                                       UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                                                       UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                                                       UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                                                       UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }

    }

    class func preferredAvenirFontForTextStyle(_ textStyle: NSString) -> UIFont? {

        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "Avenir-Book"
        let fontNameMedium: NSString = "Avenir-Medium"
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }
    }

    class func preferredCourierFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "Courier"
        let fontNameMedium: NSString = "Courier-Bold"
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [
                    UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [
                    UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [
                    UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [
                    UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }
    }

    class func preferredGeorgiaFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "Georgia"
        let fontNameMedium: NSString = "Georgia-Bold"
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [
                    UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [
                    UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [
                    UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [
                    UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }
    }

    class func preferredMenloFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "Menlo-Regular"
        let fontNameMedium: NSString = "Menlo-Bold"
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [
                    UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [
                    UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [
                    UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [
                    UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }
    }

    class func preferredTimesNewRomanFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "TimesNewRomanPSMT"
        let fontNameMedium: NSString = "TimesNewRomanPS-BoldMT"
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [
                    UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [
                    UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [
                    UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [
                    UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }
    }

    class func preferredPalatinoFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "Palatino-Roman"
        let fontNameMedium: NSString = "Palatino-Bold"
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [
                    UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [
                    UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [
                    UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [
                    UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }
    }

    class func preferredIowanFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize: String = UIApplication.shared.preferredContentSizeCategory.rawValue
        let fontNameRegular: NSString = "IowanOldStyle-Roman"
        let fontNameMedium: NSString = "IowanOldStyle-Bold"
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [
                    UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [
                    UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [
                    UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [
                    UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {
            return UIFont(name: fontNameMedium as String, size: CGFloat(fontSize))
        } else {
            return UIFont(name: fontNameRegular as String, size: CGFloat(fontSize))
        }
    }

    class func preferredSFFontForTextStyle(_ textStyle: NSString) -> UIFont? {
        var fontSize = 16.0
        let contentSize = UIApplication.shared.preferredContentSizeCategory.rawValue
        var fontSizeOffsetDictionary: Dictionary<String, Dictionary<String, AnyObject>>?

        let _onceToken = NSUUID().uuidString

        DispatchQueue.once(token: _onceToken) {
            fontSizeOffsetDictionary = [
                UIContentSizeCategory.large.rawValue: [
                    UIFont.TextStyle.body.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -3 as AnyObject],

                UIContentSizeCategory.extraSmall.rawValue: [
                    UIFont.TextStyle.body.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -4 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.small.rawValue: [
                    UIFont.TextStyle.body.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.medium.rawValue: [
                    UIFont.TextStyle.body.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 0 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -5 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -4 as AnyObject],

                UIContentSizeCategory.extraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 3 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 1 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -3 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: -1 as AnyObject],

                UIContentSizeCategory.extraExtraExtraLarge.rawValue: [
                    UIFont.TextStyle.body.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.headline.rawValue: 4 as AnyObject,
                    UIFont.TextStyle.subheadline.rawValue: 2 as AnyObject,
                    UIFont.TextStyle.caption1.rawValue: -1 as AnyObject,
                    UIFont.TextStyle.caption2.rawValue: -2 as AnyObject,
                    UIFont.TextStyle.footnote.rawValue: 0 as AnyObject]]
        }

        let fontSizeOffset = fontSizeOffsetDictionary![contentSize]?[textStyle as String]?.doubleValue
        fontSize += fontSizeOffset!

        if textStyle as UIFont.TextStyle == UIFont.TextStyle.headline ||
            textStyle as UIFont.TextStyle ==  UIFont.TextStyle.subheadline {

            if #available(iOS 8.2, *) {
                return UIFont.systemFont(ofSize: CGFloat(fontSize), weight: UIFont.Weight.medium)
            }
        } else {

            if #available(iOS 8.2, *) {
                return UIFont.systemFont(ofSize: CGFloat(fontSize), weight: UIFont.Weight.regular)
            }
        }
        return  UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
}
