//
//  MenuColorsView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
// swiftlint:disable force_cast
import UIKit

class MenuColorsView: UIView {

    var colors = ["#6a6de2", "#008efe", "#fe4565", "#ffa600", "#50de72", "#ffd401"]
    var buttonsContainer: UIView?
    var tagOffset: Int
    var radius: CGFloat = 40.0
    var selectedIndex: Int?
    var currentColor: String?

    func findIndexByColor(_ color: String) -> Int {
        switch color {
        case "#6a6de2":
            return 0
        case "#008efe":
            return 1
        case "#fe4565":
            return 2
        case "#ffa600":
            return 3
        case "#50de72":
            return 4
        case "#ffd401":
            return 5
        default:
            return -1
        }
    }

    override init(frame: CGRect) {
        tagOffset = 1000
        super.init(frame: frame)
        selectedIndex = 0
        currentColor = colors[0]
        addButtons()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addButtons() {
        // swiftlint:disable force_unwrapping
        buttonsContainer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: 51.0))
        self.addSubview(buttonsContainer!)
        var index: Int = 0

        for item in colors {
            let button: CircleButton = CircleButton(
                frame: CGRect(x: 0.0, y: 0.0, width: radius, height: radius))
            button.tag = tagOffset + index
            button.backgroundColor = UIColor(rgba: item)
            button.addTarget(
                self,
                action: #selector(MenuColorsView.buttonPressed(_:)),
                for: UIControl.Event.touchDown)
            buttonsContainer?.addSubview(button)
            index += 1
        }

        setSelectedIndex(0)
    }

    func selectButton(_ button: UIButton) {
        button.layer.borderWidth = 2.0
    }

    func deselectButton(_ button: UIButton) {
        button.layer.borderWidth = 0.0
    }
    func setSelectedIndex(_ newSelectedIndex: Int) {
        if selectedIndex != NSNotFound {
            let fromButton: UIButton = buttonsContainer!.viewWithTag(tagOffset + selectedIndex!) as! UIButton
            deselectButton(fromButton)
        }
        selectedIndex = newSelectedIndex
        var toButton: UIButton
        if selectedIndex != NSNotFound {
            toButton = buttonsContainer!.viewWithTag(tagOffset + selectedIndex!) as! UIButton
            selectButton(toButton)
        }
    }

    @objc func buttonPressed(_ button: UIButton) {
        currentColor = colors[button.tag - tagOffset]
        setSelectedIndex(button.tag - tagOffset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }

    func layoutButtons() {
        var index: Int = 0
        if let buttonsContainer = self.buttonsContainer {
            let buttons: NSArray = buttonsContainer.subviews as NSArray
            var rect: CGRect = CGRect(x: 0.0, y: 0.0, width: radius, height: radius)
            for item in buttons {
                if let button: UIButton = item as? UIButton {
                    button.frame = rect
                    rect.origin.x += rect.size.width + 10.0
                    index += 1
                }
            }
        }
    }
}
