//
//  SettingsButton.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/3/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class SettingsButton: UrsusButton {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		super.draw(rect)
		
		if !self.glyphOnly && self.changesWithTheme {
			if PreferenceManager.shared.theme == .dark {
				
				StyleKit.drawSettingsIcon(frame: rect, resizing: self.resizingBehavior, iconColor: StyleKit.darkIconGlyphColor)
			} else {
				
				StyleKit.drawSettingsIcon(frame: rect, resizing: self.resizingBehavior, iconColor: StyleKit.lightIconGlyphColor)
			}
		} else {
			
			StyleKit.drawSettingsIcon(frame: rect, resizing: self.resizingBehavior, iconColor: self.tintColor)
		}
    }

}