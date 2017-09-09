//
//  TLITextFieldCellDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

@objc protocol TLITextFieldCellDelegate {
    @objc optional func shouldReturnForIndexPath(_ indexPath: IndexPath!, value: String) -> Bool
    @objc optional func updateTextLabelAtIndexPath(_ indexPath: IndexPath, value: String)
    @objc optional func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    @objc optional func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    @objc optional func textFieldDidBeginEditing(_ textField: UITextField)
    @objc optional func textFieldDidEndEditing(_ textField: UITextField)
}
