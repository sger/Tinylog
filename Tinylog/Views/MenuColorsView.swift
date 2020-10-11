//
//  MenuColorsView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

protocol MenuColorsViewDelegate: AnyObject {
    func menuColorsViewDidSelectColor(_ view: MenuColorsView, selectedColor color: String?)
}

final class MenuColorsView: UIView {

    private var buttonsContainer: UIView = UIView()
    private var tagOffset: Int
    private let radius: CGFloat = 40.0
    private var selectedIndex: Int = 0
    private var viewModel: MenuColorsViewModel = MenuColorsViewModel()

    weak var delegate: MenuColorsViewDelegate?

    func configure(with list: TLIList?) {
        guard let list = list else {
            return
        }
        viewModel.configure(list: list)
        setSelectedIndex(viewModel.index)
    }

    override init(frame: CGRect) {
        tagOffset = 1000
        super.init(frame: frame)
        selectedIndex = 0
        createButtons()
        setSelectedIndex(0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createButtons() {
        addSubview(buttonsContainer)

        buttonsContainer.snp.makeConstraints { maker in
            maker.top.equalTo(self)
            maker.left.equalTo(self)
            maker.width.equalTo(self)
            maker.height.equalTo(51.0)
        }

        var index: Int = 0

        viewModel.colors.forEach { color in
            let button: CircleButton = CircleButton(
                frame: CGRect(x: 0.0, y: 0.0, width: radius, height: radius))
            button.tag = tagOffset + index
            button.backgroundColor = UIColor(rgba: color)
            button.addTarget(
                self,
                action: #selector(MenuColorsView.buttonTapped(_:)),
                for: UIControl.Event.touchDown)
            buttonsContainer.addSubview(button)
            index += 1
        }
    }

    private func select(with button: UIButton) {
        button.layer.borderWidth = 2.0
    }

    private func deselect(with button: UIButton) {
        button.layer.borderWidth = 0.0
    }

    private func setSelectedIndex(_ newSelectedIndex: Int) {
        if selectedIndex != NSNotFound {
            if let button: UIButton = buttonsContainer.viewWithTag(tagOffset + selectedIndex) as? UIButton {
                deselect(with: button)
            }
        }

        selectedIndex = newSelectedIndex

        if selectedIndex != NSNotFound {
            if let button: UIButton = buttonsContainer.viewWithTag(tagOffset + selectedIndex) as? UIButton {
                select(with: button)
            }
        }
    }

    @objc func buttonTapped(_ button: UIButton) {
        let currentColor: String = viewModel.colors[button.tag - tagOffset]
        setSelectedIndex(button.tag - tagOffset)
        delegate?.menuColorsViewDidSelectColor(self, selectedColor: currentColor)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }

    private func layoutButtons() {
        var rect: CGRect = CGRect(x: 0.0,
                                  y: 0.0,
                                  width: radius,
                                  height: radius)

        buttonsContainer.subviews.forEach {
            $0.frame = rect
            rect.origin.x += rect.size.width + 10.0
        }
    }
}
